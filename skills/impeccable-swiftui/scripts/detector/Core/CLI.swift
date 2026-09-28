import Foundation

/// Command-line front end. `main.swift` only forwards to `ImpeccableCLI.run`.
public enum ImpeccableCLI {
    public struct IO {
        public var out: (String) -> Void
        public var err: (String) -> Void
        public var readStdin: () -> Data

        public init(out: @escaping (String) -> Void, err: @escaping (String) -> Void, readStdin: @escaping () -> Data) {
            self.out = out
            self.err = err
            self.readStdin = readStdin
        }

        public static let standard = IO(
            out: { FileHandle.standardOutput.write(Data($0.utf8)) },
            err: { FileHandle.standardError.write(Data($0.utf8)) },
            readStdin: { FileHandle.standardInput.readDataToEndOfFile() }
        )
    }

    public static let usage = """
    impeccable-swiftui \(impeccableVersion): SwiftUI design anti-pattern detector for the impeccable-swiftui skill

    USAGE
      impeccable-swiftui context [--target <path>]       project design context (run from the project root)
      impeccable-swiftui detect [--json] [--no-config] <paths…>
                                                          scan .swift files; exit 0 clean, 2 findings, 1 error
      impeccable-swiftui rules [--json]                  list rule ids, severity, rationale
      impeccable-swiftui hook                            Claude Code PostToolUse hook (reads hook JSON on stdin)
      impeccable-swiftui --help | --version

    WAIVERS (Swift comments)
      // impeccable-disable <rule>[, <rule>][: reason]        whole file
      // impeccable-disable-line <rule>[: reason]             this line
      // impeccable-disable-next-line <rule>[: reason]        next line

    CONFIG
      .impeccable/config.json then .impeccable/config.local.json (nearest ancestor of each file):
      { "detector": { "ignoreRules": ["any-view"], "ignoreFiles": ["**/Previews/**"] }, "buildPath": "code" }

    """

    public static func run(_ args: [String], io: IO = .standard) -> Int32 {
        guard let verb = args.first else {
            io.out(usage)
            return 0
        }
        let rest = Array(args.dropFirst())
        switch verb {
        case "-h", "--help", "help":
            io.out(usage)
            return 0
        case "-v", "--version", "version":
            io.out("impeccable-swiftui \(impeccableVersion)\n")
            return 0
        case "rules":
            return rules(json: rest.contains("--json"), io: io)
        case "detect":
            return detect(rest, io: io)
        case "hook":
            let text = Hook.run(stdin: io.readStdin())
            if let t = text { io.out(t + "\n") }
            return 0
        case "context":
            var target: String?
            var i = 0
            while i < rest.count {
                if rest[i] == "--target", i + 1 < rest.count { target = rest[i + 1]; i += 2; continue }
                if rest[i].hasPrefix("--target=") { target = String(rest[i].dropFirst(9)) }
                if rest[i] == "--help" || rest[i] == "-h" { io.out(usage); return 0 }
                i += 1
            }
            io.out(ProjectContext.render(root: FileManager.default.currentDirectoryPath, target: target))
            return 0
        default:
            io.err("impeccable-swiftui: unknown command '\(verb)'\n\n" + usage)
            return 1
        }
    }

    static func rules(json: Bool, io: IO) -> Int32 {
        if json {
            let enc = JSONEncoder()
            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let d = try? enc.encode(RuleCatalog.all) { io.out(String(decoding: d, as: UTF8.self) + "\n") }
            return 0
        }
        let w = RuleCatalog.all.map(\.id.count).max() ?? 20
        var category = ""
        for r in RuleCatalog.all {
            if r.category != category {
                category = r.category
                io.out("\n\(category.uppercased())\n")
            }
            io.out("  \(r.id.padding(toLength: w + 2, withPad: " ", startingAt: 0))\(r.severity.rawValue.padding(toLength: 9, withPad: " ", startingAt: 0))\(r.rationale)\n")
        }
        return 0
    }

    static func detect(_ args: [String], io: IO) -> Int32 {
        var json = false, useConfig = true
        var paths: [String] = []
        for a in args {
            switch a {
            case "--json": json = true
            case "--no-config": useConfig = false
            case "-h", "--help": io.out(usage); return 0
            default:
                if a.hasPrefix("--") { io.err("impeccable-swiftui detect: unknown option \(a)\n"); return 1 }
                paths.append(a)
            }
        }
        if paths.isEmpty { paths = ["."] }
        let result = Detector.scan(paths: paths, useConfig: useConfig)
        for e in result.errors { io.err("impeccable-swiftui: \(e)\n") }
        if json {
            io.out(Report.json(result) + "\n")
        } else {
            io.err(Report.human(result))
        }
        if !result.errors.isEmpty && result.filesScanned == 0 { return 1 }
        return result.findings.isEmpty ? 0 : 2
    }
}

enum Report {
    static func json(_ r: ScanResult) -> String {
        struct Summary: Encodable { let files: Int; let findings: Int; let errors: Int; let warnings: Int; let info: Int }
        struct Out: Encodable { let version: String; let summary: Summary; let findings: [Finding] }
        let s = Summary(files: r.filesScanned, findings: r.findings.count,
                        errors: r.findings.filter { $0.severity == .error }.count,
                        warnings: r.findings.filter { $0.severity == .warning }.count,
                        info: r.findings.filter { $0.severity == .info }.count)
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard let d = try? enc.encode(Out(version: impeccableVersion, summary: s, findings: r.findings)) else { return "{}" }
        return String(decoding: d, as: UTF8.self)
    }

    static func human(_ r: ScanResult) -> String {
        var out = ""
        var byFile: [String: [Finding]] = [:]
        var order: [String] = []
        for f in r.findings {
            if byFile[f.file] == nil { order.append(f.file) }
            byFile[f.file, default: []].append(f)
        }
        for file in order {
            for f in byFile[file]! {
                out += "\(f.file):\(f.line):\(f.column)  \(f.severity.rawValue)  \(f.rule)  \(f.message)\n"
            }
            out += "\n"
        }
        let e = r.findings.filter { $0.severity == .error }.count
        let w = r.findings.filter { $0.severity == .warning }.count
        let i = r.findings.filter { $0.severity == .info }.count
        let files = "\(r.filesScanned) Swift file\(r.filesScanned == 1 ? "" : "s")"
        if r.findings.isEmpty {
            out += "impeccable-swiftui: no findings in \(files)\n"
        } else {
            out += "impeccable-swiftui: \(r.findings.count) finding\(r.findings.count == 1 ? "" : "s") (\(e) error\(e == 1 ? "" : "s"), \(w) warning\(w == 1 ? "" : "s"), \(i) info) in \(order.count) of \(files)\n"
        }
        return out
    }
}

/// Claude Code PostToolUse hook.
public enum Hook {
    /// Returns the JSON to print, or nil for a silent no-op. Never throws.
    public static func run(stdin: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: stdin) as? [String: Any] else { return nil }
        var path: String?
        if let ti = obj["tool_input"] as? [String: Any] {
            path = (ti["file_path"] as? String) ?? (ti["path"] as? String) ?? (ti["notebook_path"] as? String)
        }
        if path == nil, let tr = obj["tool_response"] as? [String: Any] {
            path = (tr["filePath"] as? String) ?? (tr["file_path"] as? String)
        }
        guard var file = path, file.hasSuffix(".swift") else { return nil }
        if !file.hasPrefix("/"), let cwd = obj["cwd"] as? String {
            file = (cwd as NSString).appendingPathComponent(file)
        }
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: file, isDirectory: &isDir), !isDir.boolValue else { return nil }
        let result = Detector.scan(paths: [file], useConfig: true)
        guard !result.findings.isEmpty else { return nil }
        var lines: [String] = []
        let name = (file as NSString).lastPathComponent
        lines.append("Impeccable SwiftUI detector: \(result.findings.count) finding\(result.findings.count == 1 ? "" : "s") in \(name)")
        for f in result.findings.prefix(25) {
            lines.append("- L\(f.line):\(f.column) \(f.rule) (\(f.severity.rawValue)): \(f.message)")
        }
        if result.findings.count > 25 { lines.append("- … \(result.findings.count - 25) more (run detect on the file)") }
        lines.append("Fix these or waive with // impeccable-disable-line <rule>: reason")
        let payload: [String: Any] = ["hookSpecificOutput": ["hookEventName": "PostToolUse", "additionalContext": lines.joined(separator: "\n")]]
        guard let d = try? JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys, .withoutEscapingSlashes]) else { return nil }
        return String(decoding: d, as: UTF8.self)
    }
}

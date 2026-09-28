import Foundation

public struct ScanResult {
    public var findings: [Finding] = []
    public var filesScanned: Int = 0
    public var errors: [String] = []
}

/// Inline waivers parsed from comments.
struct Waivers {
    /// nil entry = all rules.
    var fileRules: Set<String>? = []
    var fileAll = false
    var lineRules: [Int: Set<String>] = [:]
    var lineAll: Set<Int> = []

    init(_ src: SourceFile) {
        guard let re = SourceFile.regex(#"impeccable-disable(-next-line|-line)?(?![\w-])([^\n*]*)"#) else { return }
        for c in src.comments {
            let ns = c.text as NSString
            for m in re.matches(in: c.text, range: NSRange(location: 0, length: ns.length)) {
                let kind = m.range(at: 1).location == NSNotFound ? "" : ns.substring(with: m.range(at: 1))
                var rest = m.range(at: 2).location == NSNotFound ? "" : ns.substring(with: m.range(at: 2))
                // Reason after `:` or `--`.
                if let r = rest.range(of: ":") { rest = String(rest[..<r.lowerBound]) }
                if let r = rest.range(of: "--") { rest = String(rest[..<r.lowerBound]) }
                let ids = rest.split(whereSeparator: { $0 == "," || $0 == " " || $0 == "\t" }).map(String.init).filter { !$0.isEmpty }
                let all = ids.isEmpty || ids.contains("all") || ids.contains("*")
                let line = src.line(of: c.start)
                switch kind {
                case "-line", "-next-line":
                    let target = kind == "-line" ? line : line + 1
                    if all { lineAll.insert(target) } else { lineRules[target, default: []].formUnion(ids) }
                default:
                    if all { fileAll = true } else { fileRules?.formUnion(ids) }
                }
            }
        }
    }

    func waives(_ rule: String, line: Int) -> Bool {
        if fileAll || fileRules?.contains(rule) == true { return true }
        if lineAll.contains(line) || lineRules[line]?.contains(rule) == true { return true }
        return false
    }
}

public enum Detector {
    static let tokenMarkers = ["theme", "token", "designsystem", "palette", "colors", "color+", "typography", "fonts", "style"]

    /// Token files (Theme, Token, DesignSystem, Palette, Colors, Color+, Typography, Fonts, Style)
    /// are exempt from `hardcoded-color` and `fixed-font-size`.
    public static func isTokenFile(_ path: String) -> Bool {
        let name = (path as NSString).lastPathComponent.lowercased()
        return tokenMarkers.contains { name.contains($0) }
    }

    static let skipDirs: Set<String> = [".build", "DerivedData", "Pods", "Carthage", ".git", ".swiftpm", "node_modules", "SourcePackages"]

    /// Scan one source text. `config` filters rules/files; waivers always apply.
    public static func scan(source: String, path: String, config: ImpeccableConfig? = nil, displayPath: String? = nil) -> [Finding] {
        let src = SourceFile(path: path, text: source)
        var ctx = CheckContext(src: src, isTokenFile: isTokenFile(path))
        Checks.run(&ctx)
        let waivers = Waivers(src)
        let previews = previewRanges(src)
        let ignored = Set(config?.ignoreRules ?? [])
        let shown = displayPath ?? path
        var out: [Finding] = []
        for f in ctx.findings {
            let line = src.line(of: f.offset)
            if ignored.contains(f.rule) || waivers.waives(f.rule, line: line) { continue }
            if previews.contains(where: { $0.contains(f.offset) }) { continue }
            out.append(Finding(file: shown, line: line, column: src.column(of: f.offset), severity: RuleCatalog.severity(f.rule), rule: f.rule, message: f.message))
        }
        return out.sorted { ($0.line, $0.column, $0.rule) < ($1.line, $1.column, $1.rule) }
    }

    /// Bodies of `#Preview { … }` and `PreviewProvider` types: preview scaffolding is not shipped UI.
    static func previewRanges(_ src: SourceFile) -> [Range<Int>] {
        var out: [Range<Int>] = []
        for m in src.matches(#"#Preview\b"#) {
            var k = m.range.location + m.range.length
            k = src.skipWS(k, newlines: false)
            if src.char(k) == 40, let c = src.match[k] { k = src.skipWS(c + 1, newlines: false) }
            if src.char(k) == 123, let c = src.match[k] { out.append(m.range.location..<c) }
        }
        for m in src.matches(#":\s*PreviewProvider\s*\{"#) {
            let brace = m.range.location + m.range.length - 1
            if let c = src.match[brace] { out.append(m.range.location..<c) }
        }
        return out
    }

    /// Enumerate `.swift` files under a path (or the file itself).
    public static func swiftFiles(at path: String) -> [String] {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: path, isDirectory: &isDir) else { return [] }
        if !isDir.boolValue { return path.hasSuffix(".swift") ? [path] : [] }
        var out: [String] = []
        guard let e = fm.enumerator(atPath: path) else { return [] }
        while let rel = e.nextObject() as? String {
            let name = (rel as NSString).lastPathComponent
            let type = e.fileAttributes?[.type] as? FileAttributeType
            if type == .typeDirectory {
                // Hidden directories (.git, .claude worktrees, .build…) are never scanned.
                if name.hasPrefix(".") || skipDirs.contains(name) || name.hasSuffix(".xcassets") || name.hasSuffix(".xcodeproj") || name.hasSuffix(".xcworkspace") { e.skipDescendants() }
                continue
            }
            // Keep the caller's spelling of the path (relative stays relative).
            if name.hasSuffix(".swift") { out.append((path as NSString).appendingPathComponent(rel)) }
        }
        return out.sorted()
    }

    static func absolute(_ p: String) -> String {
        let s = p.hasPrefix("/") ? p : (FileManager.default.currentDirectoryPath as NSString).appendingPathComponent(p)
        return (s as NSString).standardizingPath
    }

    static func display(_ p: String) -> String {
        let abs = absolute(p)
        let cwd = (FileManager.default.currentDirectoryPath as NSString).standardizingPath
        if abs.hasPrefix(cwd + "/") { return String(abs.dropFirst(cwd.count + 1)) }
        return abs
    }

    /// Scan files/directories. With `useConfig`, each file uses the nearest `.impeccable` config.
    public static func scan(paths: [String], useConfig: Bool = true) -> ScanResult {
        var result = ScanResult()
        var configCache: [String: ImpeccableConfig] = [:]
        var seen = Set<String>()
        for p in paths {
            let files = swiftFiles(at: p)
            if files.isEmpty {
                var isDir: ObjCBool = false
                if !FileManager.default.fileExists(atPath: p, isDirectory: &isDir) {
                    result.errors.append("no such file or directory: \(p)")
                }
                continue
            }
            for f in files {
                let abs = absolute(f)
                guard !seen.contains(abs) else { continue }
                seen.insert(abs)
                var config: ImpeccableConfig?
                if useConfig, let root = ImpeccableConfig.findRoot(from: abs) {
                    if configCache[root] == nil { configCache[root] = ImpeccableConfig.load(projectRoot: root) }
                    config = configCache[root]
                    if config!.ignores(file: abs) { continue }
                }
                guard let data = FileManager.default.contents(atPath: abs) else {
                    result.errors.append("cannot read \(f)")
                    continue
                }
                let text = String(decoding: data, as: UTF8.self)
                result.filesScanned += 1
                result.findings += scan(source: text, path: abs, config: config, displayPath: display(abs))
            }
        }
        return result
    }
}

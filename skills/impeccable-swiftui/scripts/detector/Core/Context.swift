import Foundation

/// `context` verb: a compact, LLM-oriented summary of the project's design inputs.
public enum ProjectContext {
    struct Evidence {
        var pbxprojs: [String] = []
        var packages: [String] = []
        var swiftFiles = 0
        var swiftUI = 0, uiKit = 0, appKit = 0
        var colorsets: [String] = []
        var tokenFiles: [String] = []
        var fonts: [String] = []
    }

    public static func render(root: String, target: String? = nil) -> String {
        let fm = FileManager.default
        let root = (root as NSString).standardizingPath
        var out: [String] = []
        out.append("IMPECCABLE_SWIFTUI_CONTEXT v\(impeccableVersion)")
        out.append("ROOT: \(root)")

        // PRODUCT.md / DESIGN.md
        for (name, directive, hint) in [
            ("PRODUCT.md", "NO_PRODUCT_MD", "No PRODUCT.md at the project root. Run the `init` command to write it (users, jobs, brand voice) before design work."),
            ("DESIGN.md", "NO_DESIGN_MD", "No DESIGN.md. Infer the system from the code evidence below; run `document` to capture it once the direction is settled."),
        ] {
            let p = (root as NSString).appendingPathComponent(name)
            if let data = fm.contents(atPath: p) {
                let text = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
                out.append("")
                out.append("=== \(name) ===")
                out.append(fence(text, lang: "markdown"))
            } else {
                out.append("\(directive): \(hint)")
            }
        }

        let ev = gather(root: root)

        // Platforms
        var targets: [String: Set<String>] = [:] // platform -> versions
        var families = Set<String>()
        var supported = Set<String>()
        var sdkroots = Set<String>()
        let keyMap = ["IPHONEOS_DEPLOYMENT_TARGET": "iOS", "MACOSX_DEPLOYMENT_TARGET": "macOS", "XROS_DEPLOYMENT_TARGET": "visionOS", "WATCHOS_DEPLOYMENT_TARGET": "watchOS", "TVOS_DEPLOYMENT_TARGET": "tvOS"]
        for pbx in ev.pbxprojs {
            guard let data = fm.contents(atPath: pbx) else { continue }
            let text = String(decoding: data, as: UTF8.self)
            for (key, plat) in keyMap {
                for v in text.matches(#"\b\#(key)\s*=\s*"?([0-9.]+)"?;"#) { targets[plat, default: []].insert(v) }
            }
            for v in text.matches(#"\bTARGETED_DEVICE_FAMILY\s*=\s*"?([0-9, ]+)"?;"#) {
                for f in v.split(separator: ",") { families.insert(f.trimmingCharacters(in: .whitespaces)) }
            }
            for v in text.matches(#"\bSUPPORTED_PLATFORMS\s*=\s*"?([a-z ]+)"?;"#) {
                for f in v.split(separator: " ") { supported.insert(String(f)) }
            }
            for v in text.matches(#"\bSDKROOT\s*=\s*"?([a-z]+)"?;"#) { sdkroots.insert(v) }
        }
        var pkgPlatforms: [String: Set<String>] = [:]
        for pkg in ev.packages {
            guard let data = fm.contents(atPath: pkg) else { continue }
            let text = String(decoding: data, as: UTF8.self)
            guard let re = SourceFile.regex(#"\.(iOS|macOS|watchOS|tvOS|visionOS|macCatalyst)\s*\(\s*(?:\.v([0-9_]+)|"([0-9.]+)")"#) else { continue }
            let ns = text as NSString
            for m in re.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
                let plat = ns.substring(with: m.range(at: 1))
                let v = m.range(at: 2).location != NSNotFound ? ns.substring(with: m.range(at: 2)).replacingOccurrences(of: "_", with: ".") : ns.substring(with: m.range(at: 3))
                pkgPlatforms[plat, default: []].insert(v)
            }
        }
        // Evidence from SDKROOT / SUPPORTED_PLATFORMS without explicit deployment targets.
        let sdkMap = ["iphoneos": "iOS", "macosx": "macOS", "xros": "visionOS", "watchos": "watchOS", "appletvos": "tvOS"]
        for s in supported.union(sdkroots) { if let p = sdkMap[s], targets[p] == nil { targets[p] = [] } }

        func versions(_ s: Set<String>) -> String {
            let sorted = s.sorted { $0.compare($1, options: .numeric) == .orderedAscending }
            return sorted.isEmpty ? "" : " " + sorted.joined(separator: "/")
        }
        let order = ["iOS", "macOS", "watchOS", "visionOS", "tvOS", "macCatalyst"]
        var platLine: [String] = []
        for p in order { if let v = targets[p] { platLine.append(p + versions(v)) } }
        var pkgLine: [String] = []
        for p in order { if let v = pkgPlatforms[p] { pkgLine.append(p + versions(v)) } }
        out.append("")
        if ev.pbxprojs.isEmpty && ev.packages.isEmpty {
            out.append("PLATFORMS: unknown (no .xcodeproj or Package.swift found under root)")
        } else {
            if !ev.pbxprojs.isEmpty {
                out.append("PLATFORMS (xcodeproj: \(ev.pbxprojs.map { rel($0, root).components(separatedBy: "/project.pbxproj")[0] }.prefix(4).joined(separator: ", "))): \(platLine.isEmpty ? "none declared" : platLine.joined(separator: ", "))")
            }
            if !ev.packages.isEmpty {
                out.append("PLATFORMS (Package.swift): \(pkgLine.isEmpty ? "none declared" : pkgLine.joined(separator: ", "))")
            }
        }
        let familyNames = ["1": "iPhone", "2": "iPad", "3": "tv", "4": "watch", "6": "Mac Catalyst", "7": "Vision"]
        if !families.isEmpty {
            out.append("DEVICE_FAMILIES: \(families.sorted().map { familyNames[$0] ?? $0 }.joined(separator: ", "))")
        }
        out.append("UI_FRAMEWORKS: SwiftUI \(ev.swiftUI), UIKit \(ev.uiKit), AppKit \(ev.appKit) (files importing, of \(ev.swiftFiles) Swift files)")

        // Design-system evidence
        if ev.colorsets.isEmpty {
            out.append("COLORSETS: none")
        } else {
            let names = Array(Set(ev.colorsets)).sorted()
            let shown = names.prefix(40).joined(separator: ", ")
            out.append("COLORSETS (\(names.count)): \(shown)\(names.count > 40 ? ", …" : "")")
        }
        out.append("TOKEN_FILES: \(ev.tokenFiles.isEmpty ? "none" : ev.tokenFiles.prefix(20).map { rel($0, root) }.joined(separator: ", ") + (ev.tokenFiles.count > 20 ? ", …" : ""))")
        out.append("BUNDLED_FONTS: \(ev.fonts.isEmpty ? "none (system fonts)" : ev.fonts.prefix(20).map { ($0 as NSString).lastPathComponent }.joined(separator: ", "))")

        // Config
        let cfgRoot = ImpeccableConfig.findRoot(from: root + "/.") ?? root
        let cfg = ImpeccableConfig.load(projectRoot: cfgRoot)
        out.append("BUILD_PATH: \(cfg.buildPath ?? "unset (ask: comp-led or code-led)")")
        if !cfg.ignoreRules.isEmpty { out.append("DETECTOR_IGNORE_RULES: \(cfg.ignoreRules.joined(separator: ", "))") }

        // Surface briefs
        let surfacesDir = (cfgRoot as NSString).appendingPathComponent(".impeccable/surfaces")
        let briefs = ((try? fm.contentsOfDirectory(atPath: surfacesDir)) ?? []).filter { $0.hasSuffix(".md") }.sorted()
        if let match = matchBrief(target: target, root: root, briefs: briefs) {
            let p = (surfacesDir as NSString).appendingPathComponent(match)
            let text = fm.contents(atPath: p).map { String(decoding: $0, as: UTF8.self) } ?? ""
            out.append("")
            out.append("=== SURFACE_BRIEF: .impeccable/surfaces/\(match) ===")
            out.append(fence(text.trimmingCharacters(in: .whitespacesAndNewlines), lang: "markdown"))
        } else if briefs.isEmpty {
            out.append("SURFACE_BRIEFS: none")
        } else {
            out.append("SURFACE_BRIEFS_AVAILABLE: \(briefs.joined(separator: ", "))\(target == nil ? "" : " (none matched target)")")
        }

        // Platform references
        var refs: [String] = []
        let hasIOS = targets["iOS"] != nil || pkgPlatforms["iOS"] != nil || families.contains("1") || families.contains("2")
        let hasMac = targets["macOS"] != nil || pkgPlatforms["macOS"] != nil || families.contains("6") || pkgPlatforms["macCatalyst"] != nil
        let hasWatch = targets["watchOS"] != nil || pkgPlatforms["watchOS"] != nil || families.contains("4")
        let hasVision = targets["visionOS"] != nil || pkgPlatforms["visionOS"] != nil || families.contains("7") || supported.contains("xros")
        let hasTV = targets["tvOS"] != nil || pkgPlatforms["tvOS"] != nil || families.contains("3")
        let iPad = families.contains("2") || (families.isEmpty && hasIOS)
        if hasIOS { refs.append("platforms/ios.md") }
        if hasIOS && iPad { refs.append("platforms/ipados.md") }
        if hasMac { refs.append("platforms/macos.md") }
        if hasWatch { refs.append("platforms/watchos.md") }
        if hasVision { refs.append("platforms/visionos.md") }
        if hasTV && !hasIOS { refs.append("platforms/ios.md") }
        if refs.isEmpty { refs = ["platforms/ios.md"] }
        out.append("")
        if hasTV { out.append("NOTE: tvOS target present; no dedicated tvOS reference, apply ios.md with focus-engine rules.") }
        if refs == ["platforms/ios.md"] && !hasIOS && !hasTV { out.append("NOTE: no platform detected; defaulting to iOS.") }
        out.append("LOAD_PLATFORM_REFERENCES: \(refs.joined(separator: " "))")
        return out.joined(separator: "\n") + "\n"
    }

    static func fence(_ text: String, lang: String) -> String {
        var ticks = "```"
        while text.contains(ticks) { ticks += "`" }
        return "\(ticks)\(lang)\n\(text)\n\(ticks)"
    }

    static func rel(_ p: String, _ root: String) -> String {
        p.hasPrefix(root + "/") ? String(p.dropFirst(root.count + 1)) : p
    }

    static func normalize(_ s: String) -> String {
        s.lowercased().filter { $0.isLetter || $0.isNumber }
    }

    static func matchBrief(target: String?, root: String, briefs: [String]) -> String? {
        guard let target = target, !briefs.isEmpty else { return nil }
        let abs = Detector.absolute(target)
        var candidates: [String] = []
        var p = abs
        // Target basename first, then parent directories up to the root.
        while p.count > 1 {
            let base = ((p as NSString).lastPathComponent as NSString).deletingPathExtension
            candidates.append(normalize(base))
            if p == root { break }
            let parent = (p as NSString).deletingLastPathComponent
            if parent == p { break }
            p = parent
            if !p.hasPrefix(root) { break }
        }
        let names = briefs.map { (file: $0, key: normalize(($0 as NSString).deletingPathExtension)) }
        for c in candidates where !c.isEmpty {
            if let exact = names.first(where: { $0.key == c }) { return exact.file }
        }
        for c in candidates where c.count >= 3 {
            // "OnboardingView" ↔ "onboarding"
            let stripped = c.replacingOccurrences(of: "view", with: "").replacingOccurrences(of: "screen", with: "")
            if let hit = names.first(where: { $0.key.count >= 3 && (stripped == $0.key || c.hasPrefix($0.key) || $0.key.hasPrefix(stripped) && !stripped.isEmpty) }) {
                return hit.file
            }
        }
        return nil
    }

    static func gather(root: String) -> Evidence {
        var ev = Evidence()
        let fm = FileManager.default
        guard let e = fm.enumerator(atPath: root) else { return ev }
        let importRe = SourceFile.regex(#"(?m)^\s*(?:@\w+(?:\([^)]*\))?\s+)*import\s+(?:struct\s+|class\s+|enum\s+)?(SwiftUI|UIKit|AppKit)\b"#)
        var visited = 0
        while let rel = e.nextObject() as? String {
            visited += 1
            if visited > 60_000 { break }
            let name = (rel as NSString).lastPathComponent
            let path = (root as NSString).appendingPathComponent(rel)
            let isDir = (e.fileAttributes?[.type] as? FileAttributeType) == .typeDirectory
            if isDir {
                if name.hasPrefix(".") || Detector.skipDirs.contains(name) { e.skipDescendants(); continue }
                if name.hasSuffix(".xcodeproj") {
                    let pbx = (path as NSString).appendingPathComponent("project.pbxproj")
                    if fm.fileExists(atPath: pbx) { ev.pbxprojs.append(pbx) }
                    e.skipDescendants()
                    continue
                }
                if name.hasSuffix(".xcworkspace") { e.skipDescendants(); continue }
                if name.hasSuffix(".colorset") {
                    ev.colorsets.append((name as NSString).deletingPathExtension)
                    e.skipDescendants()
                    continue
                }
                if name.hasSuffix(".imageset") || name.hasSuffix(".appiconset") || name.hasSuffix(".symbolset") || name.hasSuffix(".bundle") { e.skipDescendants() }
                continue
            }
            let lower = name.lowercased()
            if name == "Package.swift" { ev.packages.append(path); continue }
            if lower.hasSuffix(".ttf") || lower.hasSuffix(".otf") { ev.fonts.append(path); continue }
            if lower.hasSuffix(".swift") {
                ev.swiftFiles += 1
                if Detector.isTokenFile(name) { ev.tokenFiles.append(path) }
                guard let data = fm.contents(atPath: path), let re = importRe else { continue }
                let text = String(decoding: data.prefix(8_192), as: UTF8.self)
                let ns = text as NSString
                var seen = Set<String>()
                for m in re.matches(in: text, range: NSRange(location: 0, length: ns.length)) { seen.insert(ns.substring(with: m.range(at: 1))) }
                if seen.contains("SwiftUI") { ev.swiftUI += 1 }
                if seen.contains("UIKit") { ev.uiKit += 1 }
                if seen.contains("AppKit") { ev.appKit += 1 }
            }
        }
        ev.pbxprojs.sort()
        ev.packages.sort()
        ev.tokenFiles.sort()
        ev.fonts.sort()
        return ev
    }
}

import Foundation

/// Merged `.impeccable/config.json` + `.impeccable/config.local.json`.
public struct ImpeccableConfig: Equatable {
    public var root: String?
    public var ignoreRules: [String] = []
    public var ignoreFiles: [String] = []
    public var buildPath: String?

    public init(root: String? = nil, ignoreRules: [String] = [], ignoreFiles: [String] = [], buildPath: String? = nil) {
        self.root = root
        self.ignoreRules = ignoreRules
        self.ignoreFiles = ignoreFiles
        self.buildPath = buildPath
    }

    public static let empty = ImpeccableConfig()

    /// Load config from `dir/.impeccable/` (shared first, then local overrides per key).
    public static func load(projectRoot dir: String) -> ImpeccableConfig {
        var cfg = ImpeccableConfig(root: dir)
        for name in ["config.json", "config.local.json"] {
            let p = (dir as NSString).appendingPathComponent(".impeccable/\(name)")
            guard let data = FileManager.default.contents(atPath: p),
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { continue }
            if let det = obj["detector"] as? [String: Any] {
                if let r = det["ignoreRules"] as? [String] { cfg.ignoreRules = r }
                if let f = det["ignoreFiles"] as? [String] { cfg.ignoreFiles = f }
            }
            if let b = obj["buildPath"] as? String { cfg.buildPath = b }
        }
        return cfg
    }

    /// Walk up from `path` to the nearest directory holding `.impeccable/config(.local).json`.
    public static func findRoot(from path: String) -> String? {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        var dir = (path as NSString).standardizingPath
        if !(fm.fileExists(atPath: dir, isDirectory: &isDir) && isDir.boolValue) {
            dir = (dir as NSString).deletingLastPathComponent
        }
        if !dir.hasPrefix("/") {
            dir = (fm.currentDirectoryPath as NSString).appendingPathComponent(dir)
            dir = (dir as NSString).standardizingPath
        }
        while true {
            for name in ["config.json", "config.local.json"] {
                if fm.fileExists(atPath: (dir as NSString).appendingPathComponent(".impeccable/\(name)")) { return dir }
            }
            let parent = (dir as NSString).deletingLastPathComponent
            if parent == dir || parent.isEmpty { return nil }
            dir = parent
        }
    }

    /// True when `absolutePath` matches one of `ignoreFiles` (relative to the config root).
    public func ignores(file absolutePath: String) -> Bool {
        guard !ignoreFiles.isEmpty else { return false }
        var rel = absolutePath
        if let root = root, absolutePath.hasPrefix(root + "/") { rel = String(absolutePath.dropFirst(root.count + 1)) }
        for g in ignoreFiles {
            var pattern = g
            if pattern.hasPrefix("./") { pattern.removeFirst(2) }
            if pattern.hasSuffix("/") { pattern += "**" }
            if Glob.match(pattern, rel) { return true }
            if !pattern.contains("/"), Glob.match(pattern, (rel as NSString).lastPathComponent) { return true }
            if !pattern.hasPrefix("**/"), Glob.match("**/" + pattern, rel), !pattern.contains("/") { return true }
        }
        return false
    }
}

enum Glob {
    /// Glob match supporting `**` (any path segments), `*` (within a segment) and `?`.
    static func match(_ pattern: String, _ path: String) -> Bool {
        var re = "^"
        let chars = Array(pattern)
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if c == "*" {
                if i + 1 < chars.count, chars[i + 1] == "*" {
                    // `**/` matches zero or more directories; bare `**` matches anything.
                    if i + 2 < chars.count, chars[i + 2] == "/" {
                        re += "(?:.*/)?"
                        i += 3
                    } else {
                        re += ".*"
                        i += 2
                    }
                    continue
                }
                re += "[^/]*"
            } else if c == "?" {
                re += "[^/]"
            } else if "\\.+()[]{}^$|".contains(c) {
                re += "\\" + String(c)
            } else {
                re += String(c)
            }
            i += 1
        }
        re += "$"
        return path.range(of: re, options: .regularExpression) != nil
    }
}

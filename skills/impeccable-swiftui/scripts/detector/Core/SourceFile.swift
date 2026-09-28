import Foundation

/// A string literal found in the source. Offsets are UTF-16 offsets into the file.
public struct StringLiteral {
    /// Offset of the first delimiter character (`#` of a raw string, or the opening quote).
    public let start: Int
    /// Offset just past the closing delimiter.
    public let end: Int
    /// Raw source text between the delimiters (escapes and interpolations kept verbatim).
    public let value: String
    public let hasInterpolation: Bool
    public let isMultiline: Bool
}

struct Comment {
    let start: Int
    let text: String
}

/// One `.modifier(args) { closure }` link in a view expression chain.
struct Modifier {
    let name: String
    /// Offset of the leading dot.
    let dot: Int
    /// Range strictly inside the parentheses, if the modifier is called.
    let args: Range<Int>?
    /// Ranges strictly inside trailing closure braces (labeled or not).
    let closures: [(label: String?, range: Range<Int>)]
    /// Offset just past the modifier (after parens/closures).
    let end: Int
}

/// A view expression: `Root(args) { closure } label: { … }` followed by `.modifier` links.
struct Chain {
    let rootStart: Int
    let rootName: String
    let rootArgs: Range<Int>?
    let rootClosures: [(label: String?, range: Range<Int>)]
    let modifiers: [Modifier]
    let end: Int

    func has(_ name: String) -> Bool { modifiers.contains { $0.name == name } }
    func modifiers(named name: String) -> [Modifier] { modifiers.filter { $0.name == name } }
}

/// Lexed Swift source. `code` is the source with comment text and string-literal
/// contents blanked to spaces (delimiters and newlines preserved), so offsets and
/// line numbers line up exactly with the original.
final class SourceFile {
    let path: String
    let raw: [UInt16]
    private(set) var code: [UInt16]
    private(set) var literals: [StringLiteral] = []
    private(set) var comments: [Comment] = []
    private(set) var lineStarts: [Int] = [0]
    /// Bracket offset -> matching bracket offset (both directions).
    private(set) var match: [Int: Int] = [:]
    /// For every offset, the offset of the innermost enclosing open bracket (or -1).
    private(set) var enclosing: [Int32] = []

    init(path: String, text: String) {
        self.path = path
        self.raw = Array(text.utf16)
        self.code = raw
        lex()
        self.code16 = String(decoding: code, as: UTF16.self) as NSString
        computeLines()
        computeBrackets()
    }

    /// Blanked code as an NSString (for NSRegularExpression; offsets are UTF-16).
    private(set) var code16: NSString = ""

    var count: Int { raw.count }

    // MARK: - Lexing

    private enum Ctx {
        case interp(depth: Int)
        case string(start: Int, contentStart: Int, hashes: Int, multiline: Bool, interp: Bool)
    }

    private static let quote: UInt16 = 34      // "
    private static let hash: UInt16 = 35       // #
    private static let slash: UInt16 = 47      // /
    private static let star: UInt16 = 42       // *
    private static let backslash: UInt16 = 92  // \
    private static let lparen: UInt16 = 40
    private static let rparen: UInt16 = 41
    private static let newline: UInt16 = 10
    private static let space: UInt16 = 32

    private func at(_ i: Int) -> UInt16 { i >= 0 && i < raw.count ? raw[i] : 0 }

    private func blank(_ i: Int) {
        if i < code.count, raw[i] != SourceFile.newline { code[i] = SourceFile.space }
    }

    private func lex() {
        var stack: [Ctx] = []
        var i = 0
        let n = raw.count

        /// Inside an interpolation every character belongs to the enclosing literal and is blanked.
        func insideInterpolation() -> Bool {
            stack.contains { if case .interp = $0 { return true } else { return false } }
        }

        while i < n {
            let c = raw[i]
            if case let .string(start, contentStart, hashes, multiline, hadInterp)? = stack.last {
                // Escape or interpolation: backslash followed by `hashes` #s.
                if c == SourceFile.backslash {
                    var k = i + 1
                    var h = 0
                    while h < hashes, at(k) == SourceFile.hash { h += 1; k += 1 }
                    if h == hashes {
                        if at(k) == SourceFile.lparen {
                            for j in i...k { blank(j) }
                            stack[stack.count - 1] = .string(start: start, contentStart: contentStart, hashes: hashes, multiline: multiline, interp: true)
                            stack.append(.interp(depth: 0))
                            i = k + 1
                            continue
                        }
                        // Plain escape: blank the backslash, hashes and the escaped char.
                        for j in i...min(k, n - 1) { blank(j) }
                        i = k + 1
                        continue
                    }
                }
                // Closing delimiter?
                if c == SourceFile.quote {
                    let isClose: Bool
                    var k = i
                    if multiline {
                        isClose = at(i + 1) == SourceFile.quote && at(i + 2) == SourceFile.quote
                        k = i + 3
                    } else {
                        isClose = true
                        k = i + 1
                    }
                    if isClose {
                        var h = 0
                        while h < hashes, at(k) == SourceFile.hash { h += 1; k += 1 }
                        if h == hashes {
                            let valueEnd = i
                            let value = String(decoding: raw[contentStart..<max(contentStart, valueEnd)], as: UTF16.self)
                            literals.append(StringLiteral(start: start, end: k, value: value, hasInterpolation: hadInterp, isMultiline: multiline))
                            stack.removeLast()
                            if insideInterpolation() { for j in i..<k { blank(j) } }
                            i = k
                            continue
                        }
                    }
                }
                // Single-line string hit a newline: malformed; recover.
                if !multiline && c == SourceFile.newline {
                    stack.removeLast()
                    i += 1
                    continue
                }
                blank(i)
                i += 1
                continue
            }

            // Code (top level or inside an interpolation).
            let blankAll = insideInterpolation()
            if c == SourceFile.slash && at(i + 1) == SourceFile.slash {
                var k = i
                while k < n, raw[k] != SourceFile.newline { k += 1 }
                comments.append(Comment(start: i, text: String(decoding: raw[i..<k], as: UTF16.self)))
                for j in i..<k { blank(j) }
                i = k
                continue
            }
            if c == SourceFile.slash && at(i + 1) == SourceFile.star {
                var depth = 0
                var k = i
                while k < n {
                    if raw[k] == SourceFile.slash && at(k + 1) == SourceFile.star { depth += 1; k += 2; continue }
                    if raw[k] == SourceFile.star && at(k + 1) == SourceFile.slash {
                        depth -= 1; k += 2
                        if depth == 0 { break }
                        continue
                    }
                    k += 1
                }
                k = min(k, n)
                comments.append(Comment(start: i, text: String(decoding: raw[i..<k], as: UTF16.self)))
                for j in i..<k { blank(j) }
                i = k
                continue
            }
            // String start (optionally raw with leading #s).
            if c == SourceFile.quote || c == SourceFile.hash {
                var k = i
                var hashes = 0
                while at(k) == SourceFile.hash { hashes += 1; k += 1 }
                if at(k) == SourceFile.quote {
                    let multiline = at(k + 1) == SourceFile.quote && at(k + 2) == SourceFile.quote
                    let contentStart = multiline ? k + 3 : k + 1
                    if blankAll { for j in i..<contentStart { blank(j) } }
                    stack.append(.string(start: i, contentStart: contentStart, hashes: hashes, multiline: multiline, interp: false))
                    i = contentStart
                    continue
                }
                if c == SourceFile.hash {
                    if blankAll { blank(i) }
                    i += 1
                    continue
                }
            }
            if case let .interp(depth)? = stack.last {
                if c == SourceFile.lparen {
                    stack[stack.count - 1] = .interp(depth: depth + 1)
                } else if c == SourceFile.rparen {
                    if depth == 0 {
                        blank(i)
                        stack.removeLast()
                        i += 1
                        continue
                    }
                    stack[stack.count - 1] = .interp(depth: depth - 1)
                }
            }
            if blankAll { blank(i) }
            i += 1
        }
    }

    private func computeLines() {
        for (i, c) in raw.enumerated() where c == SourceFile.newline {
            lineStarts.append(i + 1)
        }
    }

    private func computeBrackets() {
        enclosing = Array(repeating: -1, count: code.count + 1)
        var stack: [Int] = []
        for i in 0..<code.count {
            let c = code[i]
            enclosing[i] = Int32(stack.last ?? -1)
            switch c {
            case 40, 91, 123: // ( [ {
                stack.append(i)
            case 41, 93, 125: // ) ] }
                let open: UInt16 = c == 41 ? 40 : (c == 93 ? 91 : 123)
                if let idx = stack.lastIndex(where: { code[$0] == open }) {
                    let o = stack[idx]
                    match[o] = i
                    match[i] = o
                    stack.removeSubrange(idx...)
                }
            default:
                break
            }
        }
    }

    // MARK: - Positions

    func line(of offset: Int) -> Int {
        var lo = 0, hi = lineStarts.count - 1
        while lo < hi {
            let mid = (lo + hi + 1) / 2
            if lineStarts[mid] <= offset { lo = mid } else { hi = mid - 1 }
        }
        return lo + 1
    }

    func column(of offset: Int) -> Int {
        offset - lineStarts[line(of: offset) - 1] + 1
    }

    var lineCount: Int { lineStarts.count }

    /// Code text (blanked) of a 1-based line, without the newline.
    func codeLine(_ line: Int) -> String {
        guard line >= 1, line <= lineStarts.count else { return "" }
        let s = lineStarts[line - 1]
        var e = line < lineStarts.count ? lineStarts[line] - 1 : code.count
        e = max(s, e)
        return String(decoding: code[s..<e], as: UTF16.self)
    }

    func codeText(_ r: Range<Int>) -> String {
        let lo = max(0, r.lowerBound), hi = min(code.count, r.upperBound)
        guard lo < hi else { return "" }
        return String(decoding: code[lo..<hi], as: UTF16.self)
    }

    func rawText(_ r: Range<Int>) -> String {
        let lo = max(0, r.lowerBound), hi = min(raw.count, r.upperBound)
        guard lo < hi else { return "" }
        return String(decoding: raw[lo..<hi], as: UTF16.self)
    }

    func char(_ i: Int) -> UInt16 { i >= 0 && i < code.count ? code[i] : 0 }

    // MARK: - Regex

    func matches(_ pattern: String, in range: Range<Int>? = nil, options: NSRegularExpression.Options = []) -> [NSTextCheckingResult] {
        guard let re = SourceFile.regex(pattern, options) else { return [] }
        let r = range.map { NSRange(location: $0.lowerBound, length: $0.count) } ?? NSRange(location: 0, length: code16.length)
        return re.matches(in: code16 as String, options: [], range: r)
    }

    private static var regexCache: [String: NSRegularExpression] = [:]
    private static let regexLock = NSLock()

    static func regex(_ pattern: String, _ options: NSRegularExpression.Options = []) -> NSRegularExpression? {
        let key = "\(options.rawValue)|\(pattern)"
        regexLock.lock(); defer { regexLock.unlock() }
        if let r = regexCache[key] { return r }
        let r = try? NSRegularExpression(pattern: pattern, options: options)
        regexCache[key] = r
        return r
    }

    func contains(_ pattern: String, in range: Range<Int>, options: NSRegularExpression.Options = []) -> Bool {
        !matches(pattern, in: range, options: options).isEmpty
    }

    // MARK: - Lexical helpers

    static func isIdent(_ c: UInt16) -> Bool {
        (c >= 48 && c <= 57) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95
    }

    static func isWS(_ c: UInt16) -> Bool { c == 32 || c == 9 || c == 10 || c == 13 }

    func skipWS(_ i: Int, newlines: Bool = true) -> Int {
        var i = i
        while i < code.count {
            let c = code[i]
            if c == 32 || c == 9 || c == 13 || (newlines && c == 10) { i += 1 } else { break }
        }
        return i
    }

    func skipWSBack(_ i: Int, newlines: Bool = true) -> Int {
        var i = i
        while i >= 0 {
            let c = code[i]
            if c == 32 || c == 9 || c == 13 || (newlines && c == 10) { i -= 1 } else { break }
        }
        return i
    }

    func identifier(at i: Int) -> String {
        var k = i
        while k < code.count, SourceFile.isIdent(code[k]) { k += 1 }
        return codeText(i..<k)
    }

    func identStartBack(_ i: Int) -> Int {
        var k = i
        while k - 1 >= 0, SourceFile.isIdent(code[k - 1]) { k -= 1 }
        return k
    }

    /// The string literal whose first delimiter is at `offset`, if any.
    func literal(at offset: Int) -> StringLiteral? {
        var lo = 0, hi = literals.count - 1
        while lo <= hi {
            let mid = (lo + hi) / 2
            if literals[mid].start == offset { return literals[mid] }
            if literals[mid].start < offset { lo = mid + 1 } else { hi = mid - 1 }
        }
        return nil
    }

    /// First string literal starting inside `range`.
    func firstLiteral(in range: Range<Int>) -> StringLiteral? {
        literals.first { $0.start >= range.lowerBound && $0.start < range.upperBound }
    }

    // MARK: - Arguments

    struct Arg {
        let label: String?
        let value: Range<Int>
    }

    /// Split an argument range (inside parentheses) into top-level arguments.
    func arguments(_ range: Range<Int>) -> [Arg] {
        var args: [Arg] = []
        var start = range.lowerBound
        var i = range.lowerBound
        func flush(_ end: Int) {
            let s = skipWS(start)
            guard s < end else { return }
            // label: `ident :` (but not `::`)
            var label: String?
            var valueStart = s
            let id = identifier(at: s)
            if !id.isEmpty {
                let k = skipWS(s + id.utf16.count)
                if k < end, code[k] == 58 /* : */ {
                    label = id
                    valueStart = skipWS(k + 1)
                }
            }
            var e = end
            while e > valueStart, SourceFile.isWS(code[e - 1]) { e -= 1 }
            args.append(Arg(label: label, value: valueStart..<max(valueStart, e)))
        }
        while i < range.upperBound {
            let c = code[i]
            if (c == 40 || c == 91 || c == 123), let m = match[i], m < range.upperBound {
                i = m + 1
                continue
            }
            if c == 44 { // ,
                flush(i)
                start = i + 1
            }
            i += 1
        }
        flush(range.upperBound)
        return args
    }

    func arg(_ label: String, in range: Range<Int>) -> Range<Int>? {
        arguments(range).first { $0.label == label }?.value
    }

    /// Parse a numeric literal (optionally negative, optionally wrapped in CGFloat(...)) in a range.
    func number(in range: Range<Int>) -> Double? {
        var text = codeText(range).trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("CGFloat("), text.hasSuffix(")") {
            text = String(text.dropFirst(8).dropLast())
        }
        text = text.replacingOccurrences(of: "_", with: "")
        guard !text.isEmpty, text.range(of: #"^-?(\d+\.?\d*|\.\d+)$"#, options: .regularExpression) != nil else { return nil }
        return Double(text)
    }

    // MARK: - Chains

    /// Parse optional `(args)` and trailing closures (including labeled trailing closures) at `i`.
    private func parseCall(at i: Int) -> (args: Range<Int>?, closures: [(label: String?, range: Range<Int>)], end: Int) {
        var k = i
        var args: Range<Int>?
        if char(k) == 40, let m = match[k] { // (
            args = (k + 1)..<m
            k = m + 1
        }
        var closures: [(label: String?, range: Range<Int>)] = []
        let j = skipWS(k, newlines: false)
        if char(j) == 123, let m = match[j] { // {
            closures.append((nil, (j + 1)..<m))
            k = m + 1
            // Labeled trailing closures: `} label: {`
            while true {
                let s = skipWS(k)
                let id = identifier(at: s)
                guard !id.isEmpty else { break }
                let colon = skipWS(s + id.utf16.count, newlines: false)
                guard char(colon) == 58 else { break }
                let brace = skipWS(colon + 1, newlines: false)
                guard char(brace) == 123, let m2 = match[brace] else { break }
                closures.append((id, (brace + 1)..<m2))
                k = m2 + 1
            }
        }
        return (args, closures, k)
    }

    /// Parse a chain whose root identifier starts at `start`.
    func chain(fromRoot start: Int) -> Chain {
        let name = identifier(at: start)
        let call = parseCall(at: start + name.utf16.count)
        var k = call.end
        var mods: [Modifier] = []
        while true {
            let j = skipWS(k)
            guard char(j) == 46 else { break } // .
            let id = identifier(at: j + 1)
            guard !id.isEmpty, let first = id.utf16.first, !(first >= 48 && first <= 57) else { break }
            let c = parseCall(at: j + 1 + id.utf16.count)
            mods.append(Modifier(name: id, dot: j, args: c.args, closures: c.closures, end: c.end))
            k = c.end
        }
        return Chain(rootStart: start, rootName: name, rootArgs: call.args, rootClosures: call.closures, modifiers: mods, end: k)
    }

    /// Walk backwards from a modifier's dot to the start of the expression chain.
    func chainRoot(beforeDot dot: Int) -> Int {
        var start = dot
        var i = dot - 1
        while true {
            let p = skipWSBack(i)
            guard p >= 0 else { break }
            let c = code[p]
            if c == 41 || c == 93 { // ) ]
                guard let o = match[p] else { break }
                // A call group must be glued to an identifier (or another group).
                let before = o - 1
                if before >= 0, SourceFile.isIdent(code[before]) || code[before] == 41 || code[before] == 93 || code[before] == 63 || code[before] == 33 {
                    start = o
                    i = before
                    // Continue into the identifier directly (no whitespace).
                    if SourceFile.isIdent(code[before]) {
                        let s = identStartBack(before)
                        start = s
                        let q = skipWSBack(s - 1)
                        if q >= 0, code[q] == 46 { i = q - 1; start = q; continue }
                        break
                    }
                    continue
                }
                break
            }
            if c == 125 { // }
                guard let o = match[p] else { break }
                start = o
                // `label: {` labeled trailing closure
                var q = skipWSBack(o - 1, newlines: false)
                if q >= 0, code[q] == 58 {
                    q = skipWSBack(q - 1, newlines: false)
                    guard q >= 0, SourceFile.isIdent(code[q]) else { break }
                    let s = identStartBack(q)
                    let r = skipWSBack(s - 1)
                    guard r >= 0, code[r] == 125 else { break }
                    i = r
                    continue
                }
                guard q >= 0 else { break }
                if code[q] == 41 { i = q; continue }
                if SourceFile.isIdent(code[q]) {
                    let s = identStartBack(q)
                    let word = codeText(s..<(q + 1))
                    if SourceFile.keywords.contains(word) { break }
                    start = s
                    let r = skipWSBack(s - 1)
                    if r >= 0, code[r] == 46 { i = r - 1; start = r; continue }
                    break
                }
                break
            }
            if SourceFile.isIdent(c) {
                let s = identStartBack(p)
                let word = codeText(s..<(p + 1))
                if SourceFile.keywords.contains(word) { break }
                start = s
                let r = skipWSBack(s - 1)
                if r >= 0, code[r] == 46 { i = r - 1; start = r; continue }
                break
            }
            break
        }
        // Normalise: never start on a dot.
        while start < dot, code[start] == 46 || SourceFile.isWS(code[start]) { start += 1 }
        return start
    }

    static let keywords: Set<String> = ["return", "else", "in", "if", "guard", "case", "default", "some", "any", "var", "let", "try", "await", "throw", "switch", "for", "while", "do", "catch", "where", "is", "as"]

    /// The chain containing the modifier whose dot is at `dot`.
    func chain(containingDot dot: Int) -> Chain {
        let root = chainRoot(beforeDot: dot)
        if root < dot {
            let ch = chain(fromRoot: root)
            if ch.modifiers.contains(where: { $0.dot == dot }) { return ch }
        }
        // Fallback: chain starting at this modifier.
        let id = identifier(at: dot + 1)
        let c = parseCall(at: dot + 1 + id.utf16.count)
        let first = Modifier(name: id, dot: dot, args: c.args, closures: c.closures, end: c.end)
        let rest = chain(fromRoot: dot + 1)
        return Chain(rootStart: dot, rootName: "", rootArgs: nil, rootClosures: [], modifiers: [first] + rest.modifiers, end: rest.end)
    }

    /// Innermost enclosing open bracket offset for `offset`, or nil.
    func enclosingOpen(_ offset: Int) -> Int? {
        guard offset >= 0, offset < enclosing.count else { return nil }
        let e = Int(enclosing[offset])
        return e >= 0 ? e : nil
    }
}

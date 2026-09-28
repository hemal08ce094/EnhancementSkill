import Foundation

/// Collects raw findings for one file. Waivers/config are applied later by `Detector`.
struct CheckContext {
    let src: SourceFile
    let isTokenFile: Bool
    let importsAppKitOnly: Bool
    /// SceneKit / RealityKit / SpriteKit: UIColor values are material/scene colors, not UI tokens.
    let importsSceneFramework: Bool
    private(set) var findings: [(rule: String, offset: Int, message: String)] = []
    private var seen = Set<String>()

    init(src: SourceFile, isTokenFile: Bool) {
        self.src = src
        self.isTokenFile = isTokenFile
        let imports = src.matches(#"(?m)^\s*(?:@\w+\s+)*import\s+(\w+)"#).map { src.codeText(Range($0.range(at: 1))!) }
        self.importsAppKitOnly = imports.contains("AppKit") && !imports.contains("UIKit")
        self.importsSceneFramework = imports.contains { ["SceneKit", "RealityKit", "SpriteKit"].contains($0) }
    }

    mutating func add(_ rule: String, _ offset: Int, _ message: String) {
        let key = "\(rule)@\(offset)"
        guard !seen.contains(key) else { return }
        seen.insert(key)
        findings.append((rule, offset, message))
    }
}

enum Checks {
    static func run(_ ctx: inout CheckContext) {
        typography(&ctx)
        color(&ctx)
        surface(&ctx)
        motion(&ctx)
        interaction(&ctx)
        platform(&ctx)
    }

    // MARK: - Shared vocab

    static let hues = "red|orange|yellow|green|mint|teal|cyan|blue|indigo|purple|pink|brown|accentColor|accent"

    static func fmt(_ d: Double) -> String {
        d == d.rounded() ? String(Int(d)) : String(d)
    }

    /// The chain root name for the expression that owns the modifier at `dot`.
    static func owner(_ src: SourceFile, _ dot: Int) -> String {
        src.chain(containingDot: dot).rootName
    }

    /// Walk outward through enclosing call parentheses; returns names, innermost first.
    static func enclosingCalls(_ src: SourceFile, _ offset: Int) -> [(name: String, nameStart: Int, open: Int)] {
        var out: [(String, Int, Int)] = []
        var o = src.enclosingOpen(offset)
        while let open = o {
            if src.char(open) == 40, open - 1 >= 0, SourceFile.isIdent(src.char(open - 1)) {
                let s = src.identStartBack(open - 1)
                out.append((src.codeText(s..<open), s, open))
            }
            o = src.enclosingOpen(open)
        }
        return out
    }

    // MARK: - Typography

    static func typography(_ ctx: inout CheckContext) {
        let src = ctx.src

        // .system(size: N …) used as a Font; UIFont/NSFont systemFont(ofSize:)
        for m in src.matches(#"(?<![\w])(?:Font)?\.system\s*\(\s*size\s*:"#) {
            guard let parenAt = (m.range.location..<(m.range.location + m.range.length)).first(where: { src.char($0) == 40 }),
                  let close = src.match[parenAt] else { continue }
            let args = (parenAt + 1)..<close
            guard let sizeRange = src.arg("size", in: args) else { continue }
            let size = src.number(in: sizeRange)
            // Only a Font context: `.font(.system(size:))`, `Font.system(size:)`, `: Font = .system`.
            let calls = enclosingCalls(src, parenAt)
            let isFontModifier = calls.first?.name == "font"
            let explicitFont = src.codeText(m.range.location..<(m.range.location + 4)) == "Font"
            let typedFont = !isFontModifier && !explicitFont && src.contains(#"(:\s*Font\s*=|->\s*Font\b|return)\s*$"#, in: max(0, m.range.location - 60)..<m.range.location)
            guard isFontModifier || explicitFont || typedFont else { continue }
            // Icons sized with a point size are an established idiom; stay quiet for Image(systemName:).
            var ownerName = ""
            if isFontModifier, let fontCall = calls.first, fontCall.nameStart - 1 >= 0, src.char(fontCall.nameStart - 1) == 46 {
                ownerName = owner(src, fontCall.nameStart - 1)
            }
            if ownerName == "Image" { continue }
            // Text drawn into a Canvas/GraphicsContext is graphics, sized with the drawing.
            let inDrawing = calls.contains { $0.name == "draw" || $0.name == "resolve" }
            if let s = size {
                if s < 11 && !ctx.importsAppKitOnly {
                    ctx.add("tiny-font", m.range.location, "\(fmt(s)) pt is below the 11 pt legibility floor. Use .caption2 (11 pt) or larger, or cut the text.")
                }
                if !ctx.isTokenFile && !inDrawing {
                    ctx.add("fixed-font-size", m.range.location, "Fixed .system(size: \(fmt(s))) ignores Dynamic Type. Use a text style (.font(.title2), .font(.body.weight(.semibold))) or @ScaledMetric for the size; keep raw sizes in a Typography token file.")
                }
            }
            // Non-literal sizes (@ScaledMetric, computed/fitted) are left alone: prefer missing a finding.
        }
        for m in src.matches(#"\b(?:UIFont|NSFont)\s*\.\s*(?:systemFont|boldSystemFont|italicSystemFont|monospacedSystemFont|monospacedDigitSystemFont)\s*\(\s*ofSize\s*:\s*([0-9.]+)"#) {
            let size = Double(src.codeText(Range(m.range(at: 1))!)) ?? 0
            if size < 11 && size > 0 && !ctx.importsAppKitOnly {
                ctx.add("tiny-font", m.range.location, "\(fmt(size)) pt is below the 11 pt legibility floor. Use UIFont.preferredFont(forTextStyle: .caption2) or larger.")
            }
            if !ctx.isTokenFile {
                ctx.add("fixed-font-size", m.range.location, "systemFont(ofSize: \(fmt(size))) ignores Dynamic Type. Use UIFont.preferredFont(forTextStyle:) / UIFontMetrics(forTextStyle:).scaledFont(for:), or a SwiftUI text style.")
            }
        }

        // Font.custom(_:size:) without relativeTo:, or with fixedSize:
        for m in src.matches(#"(?<![\w])(?:Font)?\.custom\s*\("#) {
            let parenAt = m.range.location + m.range.length - 1
            guard let close = src.match[parenAt] else { continue }
            let args = src.arguments((parenAt + 1)..<close)
            let labels = args.map { $0.label ?? "_" }
            guard let first = args.first, first.label == nil else { continue }
            let nameLit = src.firstLiteral(in: first.value)
            let fontName = nameLit?.value ?? src.codeText(first.value)
            if labels.contains("fixedSize") {
                ctx.add("custom-font-no-relative", m.range.location, "Font.custom(\(q(fontName)), fixedSize:) never scales. Use .custom(name, size: 17, relativeTo: .body) matched to the text role.")
            } else if labels.contains("size") && !labels.contains("relativeTo") {
                ctx.add("custom-font-no-relative", m.range.location, "Font.custom(\(q(fontName)), size:) without relativeTo: only scales like .body. Use Font.custom(_:size:relativeTo:) with the matching text style (.title2, .caption…).")
            }
            if let sizeArg = args.first(where: { $0.label == "size" || $0.label == "fixedSize" }), let s = src.number(in: sizeArg.value), s < 11, !ctx.importsAppKitOnly {
                ctx.add("tiny-font", m.range.location, "\(fmt(s)) pt is below the 11 pt legibility floor. Use at least 11 pt (caption2) for text.")
            }
            if let lit = nameLit, let hit = overusedFont(lit.value) {
                ctx.add("overused-font", lit.start, "\"\(lit.value)\" (\(hit)) is a default-template face that erases brand voice. Choose a face with character for display text, or use SF Pro with .fontDesign/.fontWidth.")
            }
        }
        for m in src.matches(#"\b(?:UIFont|NSFont)\s*\(\s*name\s*:\s*""#) {
            let quoteAt = m.range.location + m.range.length - 1
            if let lit = src.literal(at: quoteAt), let hit = overusedFont(lit.value) {
                ctx.add("overused-font", lit.start, "\"\(lit.value)\" (\(hit)) is a default-template face that erases brand voice. Choose a face with character for display text, or use the system font.")
            }
        }
    }

    static func q(_ s: String) -> String { s.hasPrefix("\"") ? s : "\"\(s)\"" }

    static let overused: [(key: String, name: String)] = [
        ("plusjakartasans", "Plus Jakarta Sans"), ("spacegrotesk", "Space Grotesk"), ("opensans", "Open Sans"),
        ("montserrat", "Montserrat"), ("poppins", "Poppins"), ("manrope", "Manrope"), ("roboto", "Roboto"),
        ("dmsans", "DM Sans"), ("outfit", "Outfit"), ("inter", "Inter"), ("lato", "Lato"),
    ]

    /// Returns the family name if `fontName` is one of the overused faces.
    static func overusedFont(_ fontName: String) -> String? {
        let chars = Array(fontName)
        var norm = ""
        var map: [Int] = [] // norm index -> original index
        for (i, ch) in chars.enumerated() where ch.isLetter || ch.isNumber {
            norm.append(Character(ch.lowercased()))
            map.append(i)
        }
        for (key, name) in overused where norm.hasPrefix(key) {
            let n = key.count
            if norm.count == n { return name }
            let origNext = map[n]
            let prev = map[n - 1]
            let nextChar = chars[origNext]
            // Boundary: a separator in the original, or an uppercase letter (InterVariable, RobotoMono).
            if origNext > prev + 1 || nextChar.isUppercase || nextChar.isNumber { return name }
        }
        return nil
    }

    // MARK: - Color

    static func color(_ ctx: inout CheckContext) {
        let src = ctx.src
        if !ctx.isTokenFile {
            let pattern = #"(?<![\w.])(?:(?:SwiftUI\.)?Color\s*\(\s*(?:\.sRGB\s*,\s*|\.displayP3\s*,\s*)?(?:red|hex|hue|white|rgb|rgba|hexString)\s*:|(?:UI|NS)Color\s*\(\s*(?:red|hex|hue|white|displayP3Red|calibratedRed|srgbRed|deviceRed|rgb)\s*:|(?:UI|NS)Color\s*\.\s*init\s*\(\s*(?:red|hex)\s*:|#colorLiteral\s*\()"#
            for m in src.matches(pattern) {
                let text = src.codeText(m.range.location..<(m.range.location + m.range.length))
                let isPlatformColor = !text.hasPrefix("Color") && !text.hasPrefix("SwiftUI")
                if isPlatformColor && ctx.importsSceneFramework { continue }
                if let idx = text.utf16.firstIndex(of: 40),
                   case let open = m.range.location + text.utf16.distance(from: text.utf16.startIndex, to: idx),
                   let close = src.match[open] {
                    // `UIColor(…).cgColor` feeds Core Graphics / layers, not a SwiftUI surface.
                    if isPlatformColor, src.contains(#"^\s*\.\s*cgColor\b"#, in: (close + 1)..<min(src.count, close + 40)) { continue }
                    // Computed colors (`Color(red: r, …)`, `Color(hex: model.hex)`) are data, not hard-coded values.
                    if !text.hasPrefix("#"), let first = src.arguments((open + 1)..<close).first(where: { $0.label != nil }) {
                        let v = src.codeText(first.value).trimmingCharacters(in: .whitespaces)
                        let literal = v.range(of: #"^(?:[0-9.]|0x|"|CGFloat\s*\(\s*[0-9.])"#, options: .regularExpression) != nil
                        if !literal { continue }
                    }
                }
                ctx.add("hardcoded-color", m.range.location, "Hard-coded \(text.replacingOccurrences(of: " ", with: "")) outside a token file. Add an asset-catalog color with Any/Dark (and High Contrast) appearances or a Color/ShapeStyle extension in the theme file, and reference it semantically.")
            }
            // Color("#FF00AA") / Color(hex: "…") via string literal
            for m in src.matches(#"(?<![\w.])Color\s*\(\s*""#) {
                let quoteAt = m.range.location + m.range.length - 1
                if let lit = src.literal(at: quoteAt), lit.value.hasPrefix("#") || lit.value.range(of: #"^(0x)?[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$"#, options: .regularExpression) != nil && lit.value.range(of: "[0-9]", options: .regularExpression) != nil {
                    ctx.add("hardcoded-color", m.range.location, "Hex color string \(q(lit.value)) outside a token file. Define it once as an asset-catalog color (Any/Dark) and reference it by semantic name.")
                }
            }
        }

        // Pure black/white surfaces. watchOS is black by design, so `.black` is fine there.
        let isWatch = src.path.range(of: "watch", options: .caseInsensitive) != nil || src.contains(#"(?m)^\s*import\s+WatchKit\b"#, in: 0..<src.count)
        for m in src.matches(#"\.background\s*\(\s*(?:Color\s*)?\.(black|white)\s*[),]"#) {
            let which = src.codeText(Range(m.range(at: 1))!)
            if which == "black" && isWatch { continue }
            ctx.add("pure-black-white-surface", m.range.location, "Pure .\(which) background skips semantic adaptation. Use Color(.systemBackground) / .background(.background), or a tinted surface color from the palette.")
        }
        for m in src.matches(#"(?<![\w.])Color\s*\.\s*(black|white)\s*\.\s*(?:ignoresSafeArea|edgesIgnoringSafeArea)\b"#) {
            let which = src.codeText(Range(m.range(at: 1))!)
            if which == "black" && isWatch { continue }
            ctx.add("pure-black-white-surface", m.range.location, "Full-screen Color.\(which) surface skips semantic adaptation. Use Color(.systemBackground) or a tinted asset color with a dark variant.")
        }

        // Gray text on a colored background, within one modifier chain.
        for m in src.matches(#"\.(?:foregroundStyle|foregroundColor)\s*\(\s*(?:Color\s*)?\.gray\s*\)"#) {
            let ch = src.chain(containingDot: m.range.location)
            guard ["Text", "Label", "Image"].contains(ch.rootName) else { continue }
            for bg in ch.modifiers(named: "background") {
                guard let a = bg.args else { continue }
                let t = src.codeText(a)
                if t.range(of: #"^\s*(?:Color\s*)?\.(?:\#(hues)|tint)\b(?!\s*\.\s*opacity\s*\(\s*0?\.[0-2])"#, options: .regularExpression) != nil
                    || t.range(of: #"^\s*(?:Color\s*)?\.(?:\#(hues))\s*,"#, options: .regularExpression) != nil {
                    ctx.add("gray-on-color", m.range.location, "Gray text on a colored background looks washed out and fails contrast. Use .foregroundStyle(.white) or a darker shade of the background hue, checked at 4.5:1 in both appearances.")
                    break
                }
            }
        }

        // Gradients: purple/indigo + blue/pink/cyan.
        for m in src.matches(#"(?<![\w])(?:LinearGradient|RadialGradient|AngularGradient|EllipticalGradient|MeshGradient|Gradient|\.linearGradient|\.radialGradient|\.angularGradient|\.ellipticalGradient)\s*\("#) {
            let parenAt = m.range.location + m.range.length - 1
            guard let close = src.match[parenAt] else { continue }
            // Only check outermost gradient constructor (Gradient(colors:) nested inside LinearGradient is covered).
            if enclosingCalls(src, m.range.location).contains(where: { $0.name.hasSuffix("Gradient") || $0.name.hasSuffix("gradient") }) { continue }
            let body = (parenAt + 1)..<close
            let hasPurple = src.contains(#"(?<![\w])(?:Color\s*)?\.(?:purple|indigo)\b"#, in: body)
            let hasCool = src.contains(#"(?<![\w])(?:Color\s*)?\.(?:blue|pink|cyan)\b"#, in: body)
            if hasPurple && hasCool {
                ctx.add("ai-gradient-palette", m.range.location, "Purple/indigo-to-blue/pink/cyan gradient is the stock AI-app look. Derive colors from the brand palette in DESIGN.md, or use a solid tint with material depth.")
            }
        }

        // Gradient text: Text…foregroundStyle(<gradient>) or gradient.mask(Text).
        for m in src.matches(#"\.foregroundStyle\s*\("#) {
            let ch = src.chain(containingDot: m.range.location)
            guard ch.rootName == "Text" || ch.rootName == "Label" else { continue }
            guard let mod = ch.modifiers.first(where: { $0.dot == m.range.location }), let a = mod.args else { continue }
            if src.contains(#"(?:LinearGradient|RadialGradient|AngularGradient|MeshGradient|\.linearGradient|\.radialGradient|\.angularGradient)\b"#, in: a) {
                ctx.add("gradient-text", m.range.location, "Gradient-filled text is a template tell and hurts legibility. Use a solid .foregroundStyle from the palette; let weight and size carry emphasis.")
            }
        }
        for m in src.matches(#"\.mask\s*(?:\(\s*Text\s*\(|\{\s*Text\s*\()"#) {
            let ch = src.chain(containingDot: m.range.location)
            if ch.rootName.hasSuffix("Gradient") {
                ctx.add("gradient-text", m.range.location, "Gradient masked by Text is gradient text: a template tell that hurts legibility. Use a solid .foregroundStyle.")
            }
        }

        // Opacity hierarchy on text.
        for m in src.matches(#"\.(?:foregroundStyle|foregroundColor)\s*\(\s*(?:Color\s*)?\.?(?:primary|black|white|label)\s*\.\s*opacity\s*\(\s*(0?\.\d+)\s*\)\s*\)"#) {
            let ch = src.chain(containingDot: m.range.location)
            guard ["Text", "Label"].contains(ch.rootName) else { continue }
            let v = Double(src.codeText(Range(m.range(at: 1))!)) ?? 1
            guard v >= 0.25 && v <= 0.85 else { continue }
            ctx.add("opacity-hierarchy", m.range.location, "Text dimmed with opacity(\(fmt(v))). Use .foregroundStyle(.secondary) / .tertiary, which adapt to vibrancy, dark mode and Increase Contrast.")
        }
        for m in src.matches(#"\.opacity\s*\(\s*(0?\.\d+)\s*\)"#) {
            let ch = src.chain(containingDot: m.range.location)
            guard ch.rootName == "Text", ch.modifiers.first(where: { $0.dot == m.range.location }) != nil else { continue }
            let v = Double(src.codeText(Range(m.range(at: 1))!)) ?? 1
            guard v >= 0.25 && v <= 0.85 else { continue }
            ctx.add("opacity-hierarchy", m.range.location, "Text dimmed with .opacity(\(fmt(v))). Use .foregroundStyle(.secondary) / .tertiary for hierarchy instead.")
        }
    }

    // MARK: - Surface

    static func surface(_ ctx: inout CheckContext) {
        let src = ctx.src

        // Shadows.
        for m in src.matches(#"\.shadow\s*\("#) {
            let parenAt = m.range.location + m.range.length - 1
            guard let close = src.match[parenAt] else { continue }
            let args = src.arguments((parenAt + 1)..<close)
            func val(_ l: String) -> Range<Int>? { args.first { $0.label == l }?.value }
            let x = val("x").flatMap { src.number(in: $0) }
            let y = val("y").flatMap { src.number(in: $0) }
            let xText = val("x").map { src.codeText($0) }, yText = val("y").map { src.codeText($0) }
            let radius = val("radius").flatMap { src.number(in: $0) }
            let xZero = xText == nil || x == 0, yZero = yText == nil || y == 0
            if radius == 0, (x ?? 0) != 0 || (y ?? 0) != 0 {
                ctx.add("hard-offset-shadow", m.range.location, "Radius-0 offset shadow is a web-brutalist gimmick. Use a soft shadow (.shadow(color: .black.opacity(0.1), radius: 8, y: 4)) or a stroke.")
                continue
            }
            if let c = val("color"), xZero, yZero, (radius ?? 1) > 0 {
                let t = src.codeText(c)
                if t.range(of: #"(?<![\w])(?:Color\s*)?\.(?:\#(hues)|tint)\b"#, options: .regularExpression) != nil,
                   t.range(of: #"\b(?:black|gray|grey|shadow|primary)\b"#, options: .regularExpression) == nil {
                    ctx.add("glow-shadow", m.range.location, "Colored zero-offset shadow reads as neon glow. Use a neutral, offset shadow (.shadow(color: .black.opacity(0.12), radius: 8, y: 4)) or drop it.")
                }
            }
        }

        // Glass / material overuse.
        let glass = src.matches(#"(?<![\w])\.(?:ultraThinMaterial|thinMaterial|regularMaterial|thickMaterial|ultraThickMaterial)\b|\.glassEffect\s*\("#)
        if glass.count > 3, let first = glass.first {
            ctx.add("glass-by-default", first.range.location, "\(glass.count) material/glass uses in one file. Glass belongs to system chrome (bars, controls, floating accessories), not every card: use solid grouped backgrounds (Color(.secondarySystemGroupedBackground)) for content.")
        }

        // Side stripe: thin colored shape as first child of an HStack, or a leading overlay/background.
        for m in src.matches(#"(?<![\w.])(?:Rectangle|Capsule|RoundedRectangle|UnevenRoundedRectangle)\s*\("#) {
            let ch = src.chain(fromRoot: m.range.location)
            guard let frame = ch.modifiers(named: "frame").last, let fa = frame.args else { continue }
            guard let w = src.arg("width", in: fa).flatMap({ src.number(in: $0) }), w > 0, w <= 6 else { continue }
            if let h = src.arg("height", in: fa).flatMap({ src.number(in: $0) }), h <= 2 * w { continue }
            let fill = ch.modifiers.first { ["fill", "foregroundStyle", "foregroundColor"].contains($0.name) }
            guard let fillArgs = fill?.args else { continue }
            let ft = src.codeText(fillArgs)
            guard ft.range(of: #"\b(?:gray|grey|separator|secondary|tertiary|quaternary|clear|primary)\b"#, options: .regularExpression) == nil else { continue }
            guard let open = src.enclosingOpen(m.range.location) else { continue }
            var isStripe = false
            if src.char(open) == 123 {
                // First child of an HStack closure?
                let firstTok = src.skipWS(open + 1)
                if firstTok == m.range.location {
                    let before = src.skipWSBack(open - 1, newlines: false)
                    var nameEnd = before
                    if before >= 0, src.char(before) == 41, let o = src.match[before] { nameEnd = o - 1 }
                    if nameEnd >= 0 {
                        let s = src.identStartBack(nameEnd)
                        let name = src.codeText(s..<(nameEnd + 1))
                        if name == "HStack" { isStripe = true }
                        if (name == "overlay" || name == "background"), let o = src.match[before], src.char(before) == 41,
                           src.codeText((o + 1)..<before).contains(".leading") { isStripe = true }
                    }
                }
            } else if src.char(open) == 40 {
                let calls = enclosingCalls(src, m.range.location)
                if let c = calls.first, c.name == "overlay" || c.name == "background",
                   let close = src.match[c.open], src.codeText((c.open + 1)..<close).contains("alignment: .leading") {
                    isStripe = true
                }
            }
            if isStripe {
                ctx.add("side-stripe", m.range.location, "Leading \(fmt(w)) pt color stripe on a card is a dashboard cliché. Carry status with a tinted SF Symbol, a badge, or a subtle background tint.")
            }
        }

        // Over-rounded cards.
        for m in src.matches(#"(?:\.cornerRadius\s*\(\s*|(?<![\w])(?:RoundedRectangle|\.rect|\.rounded|UnevenRoundedRectangle)\s*\(\s*cornerRadius\s*:\s*)(-?[0-9.]+)\b"#) {
            guard let r = Double(src.codeText(Range(m.range(at: 1))!)), r >= 32 else { continue }
            // Pills/circles: a nearby fixed height <= 2r means it is a capsule, not a card.
            let line = src.line(of: m.range.location)
            var pill = false
            for l in max(1, line - 8)...min(src.lineCount, line + 8) {
                let t = src.codeLine(l)
                for hm in t.matches(#"height\s*:\s*([0-9.]+)"#) {
                    if let h = Double(hm), h <= 2 * r + 1 { pill = true }
                }
            }
            if pill { continue }
            ctx.add("over-rounded", m.range.location, "Corner radius \(fmt(r)) on a card is bubbly and off-platform. Use 10-20 pt with style: .continuous (.clipShape(.rect(cornerRadius: 16, style: .continuous))), concentric with its container.")
        }

        // Eyebrow label: uppercase + tracked small Text followed by a heading.
        for m in src.matches(#"(?<![\w.])Text\s*\("#) {
            let ch = src.chain(fromRoot: m.range.location)
            let upper = ch.modifiers.contains { $0.name == "textCase" && $0.args.map { src.codeText($0).contains("uppercase") } == true }
                || (ch.rootArgs.flatMap { src.firstLiteral(in: $0) }.map { isAllCaps($0.value) } ?? false)
            guard upper else { continue }
            let tracked = ch.modifiers.contains { m in
                (m.name == "tracking" || m.name == "kerning") && (m.args.flatMap { src.number(in: $0) } ?? 0) >= 0.5
            }
            guard tracked else { continue }
            // Next Text within a few lines carries a heading font?
            let endLine = src.line(of: ch.end)
            let windowEnd = src.lineStarts.count > endLine + 6 ? src.lineStarts[endLine + 6] : src.count
            guard let next = src.matches(#"(?<![\w.])Text\s*\("#, in: ch.end..<windowEnd).first else { continue }
            let nch = src.chain(fromRoot: next.range.location)
            let heading = nch.modifiers(named: "font").contains { f in
                guard let a = f.args else { return false }
                let t = src.codeText(a)
                if t.range(of: #"^\s*\.(?:largeTitle|title|title2|title3|headline)\b"#, options: .regularExpression) != nil { return true }
                if let s = t.matches(#"size\s*:\s*([0-9.]+)"#).first, let v = Double(s), v >= 20 { return true }
                return false
            }
            if heading {
                ctx.add("eyebrow-label", m.range.location, "Uppercase tracked eyebrow above a heading is a landing-page tell. Let the heading stand alone, or put a .subheadline .secondary line below it.")
            }
        }

        // Numbered sections: Text("01") / Text("02 — Title").
        var numbered: [StringLiteral] = []
        for lit in src.literals where !lit.hasInterpolation {
            guard lit.value.range(of: #"^0[1-9](?:\s*[.)/·—–-]?\s*\S.*)?$"#, options: .regularExpression) != nil else { continue }
            // Must be the direct first argument of Text(…) / Label(…).
            let before = src.skipWSBack(lit.start - 1)
            guard before >= 0, src.char(before) == 40 else { continue }
            let s = src.identStartBack(before)
            let name = src.codeText(s..<before)
            guard name == "Text" || name == "Label" else { continue }
            numbered.append(lit)
        }
        if numbered.count >= 2 {
            for lit in numbered {
                ctx.add("numbered-section", lit.start, "\"\(lit.value)\"-style section number is an editorial-web tell. Drop the numbers, or use real structure (List sections, headers, a progress indicator for steps).")
            }
        }

        // Emoji standing in for icons.
        for lit in src.literals where !lit.hasInterpolation {
            let v = lit.value
            guard let kind = emojiIconKind(v) else { continue }
            let before = src.skipWSBack(lit.start - 1)
            guard before >= 0, src.char(before) == 40 else { continue }
            let s = src.identStartBack(before)
            let name = src.codeText(s..<before)
            let hosts: Set<String> = kind == .only ? ["Text", "Label", "Button", "Section", "navigationTitle"] : ["Label", "Button", "Section", "navigationTitle", "Text"]
            guard hosts.contains(name) else { continue }
            if kind == .prefix && name == "Text" {
                // Only flag emoji-prefixed Text when it acts as a title/list label (short).
                guard v.count <= 30 else { continue }
            }
            ctx.add("emoji-icon", lit.start, "Emoji standing in for an icon (\(q(v))). Use Image(systemName:) or Label(_:systemImage:) so it tints, scales with Dynamic Type and reads in VoiceOver.")
        }
    }

    static func isAllCaps(_ s: String) -> Bool {
        let letters = s.filter { $0.isLetter }
        return letters.count >= 3 && letters.allSatisfy { $0.isUppercase } && !s.contains("\\(")
    }

    enum EmojiKind { case only, prefix }

    static func isEmoji(_ ch: Character) -> Bool {
        guard let first = ch.unicodeScalars.first else { return false }
        let p = first.properties
        if p.isEmojiPresentation { return true }
        if p.isEmoji, first.value > 0x2000, ch.unicodeScalars.contains(where: { $0.value == 0xFE0F }) { return true }
        return false
    }

    static func emojiIconKind(_ v: String) -> EmojiKind? {
        let trimmed = v.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        let chars = Array(trimmed)
        if chars.count <= 3, chars.allSatisfy({ isEmoji($0) || $0 == " " }), chars.contains(where: isEmoji) { return .only }
        if chars.count >= 3, isEmoji(chars[0]), chars[1] == " ", chars[2].isLetter { return .prefix }
        return nil
    }

    // MARK: - Motion

    static func motion(_ ctx: inout CheckContext) {
        let src = ctx.src
        for m in src.matches(#"(?<![\w])\.bouncy\b"#) {
            ctx.add("bounce-easing", m.range.location, ".bouncy spring feels toy-like in product UI. Use .smooth or .snappy, or .spring(duration: 0.4, bounce: 0.1) (bounce <= 0.15).")
        }
        for m in src.matches(#"(?<![\w])bounce\s*:\s*(0?\.\d+|\d+(?:\.\d+)?)"#) {
            if let v = Double(src.codeText(Range(m.range(at: 1))!)), v > 0.3 {
                ctx.add("bounce-easing", m.range.location, "bounce: \(fmt(v)) overshoots like a toy. Keep bounce <= 0.15 (.spring(duration:bounce:)) or use .smooth / .snappy.")
            }
        }
        for m in src.matches(#"(?<![\w])dampingFraction\s*:\s*(0?\.\d+|\d+(?:\.\d+)?)"#) {
            if let v = Double(src.codeText(Range(m.range(at: 1))!)), v < 0.6 {
                ctx.add("bounce-easing", m.range.location, "dampingFraction: \(fmt(v)) wobbles. Use .spring(duration: 0.4, bounce: 0.1), .smooth or .snappy (dampingFraction >= 0.8 if you must).")
            }
        }
        for m in src.matches(#"(?<![\w])extraBounce\s*:\s*(0?\.\d+|\d+(?:\.\d+)?)"#) {
            if let v = Double(src.codeText(Range(m.range(at: 1))!)), v >= 0.15 {
                ctx.add("bounce-easing", m.range.location, "extraBounce: \(fmt(v)) adds toy-like overshoot. Drop extraBounce (plain .smooth / .snappy) for product UI.")
            }
        }

        // Reduce motion.
        let loops = src.matches(#"\brepeatForever\b|(?<![\w])(?:PhaseAnimator|KeyframeAnimator)\b|\.(?:phaseAnimator|keyframeAnimator)\s*\("#)
        if let first = loops.first {
            let reads = src.contains(#"accessibilityReduceMotion|reduceMotion|isReduceMotionEnabled|ReduceMotion"#, in: 0..<src.count, options: [.caseInsensitive])
            if !reads {
                let what = src.codeText(first.range.location..<(first.range.location + first.range.length)).trimmingCharacters(in: CharacterSet(charactersIn: ".( "))
                ctx.add("reduce-motion-ignored", first.range.location, "\(what) runs in a file that never reads accessibilityReduceMotion. Add @Environment(\\.accessibilityReduceMotion) and fall back to a static state or cross-fade.")
            }
        }

        // Section fades.
        // Only entrance-style flags (appeared/show/visible/animate…), not focus or selection toggles.
        let fades = src.matches(#"\.opacity\s*\(\s*!?\s*([\w.]+)\s*\?\s*1(?:\.0)?\s*:\s*0(?:\.0)?\s*\)"#).filter { m in
            let name = src.codeText(Range(m.range(at: 1))!)
            return name.range(of: #"(?i)appear|show|visible|animat|loaded|reveal|enter|isIn\b|started|present|ready|intro"#, options: .regularExpression) != nil
        }
        if fades.count >= 3, let first = fades.first {
            ctx.add("section-fade", first.range.location, "\(fades.count) opacity(x ? 1 : 0) entrance fades in one file: the scroll-reveal web cliché. Show content immediately; animate only state changes that carry meaning (and honor Reduce Motion).")
        }
    }

    // MARK: - Interaction & accessibility

    static func interaction(_ ctx: inout CheckContext) {
        let src = ctx.src

        // onTapGesture used as a button.
        for m in src.matches(#"\.onTapGesture\b"#) {
            let ch = src.chain(containingDot: m.range.location)
            guard let mod = ch.modifiers.first(where: { $0.dot == m.range.location }) else { continue }
            if let a = mod.args, let c = src.arg("count", in: a), (src.number(in: c) ?? 1) >= 2 { continue }
            let a11y = ch.modifiers.contains { ["accessibilityAddTraits", "accessibilityAction", "accessibilityHidden", "accessibilityRepresentation", "accessibilityElement", "accessibilityRespondsToUserInteraction"].contains($0.name) }
            if a11y { continue }
            if ch.rootName.hasPrefix("Color") || ch.rootName == "Spacer" { continue }
            // Nearby trait (chain parse fallback).
            let line = src.line(of: m.range.location)
            var nearby = false
            for l in max(1, line - 3)...min(src.lineCount, line + 3) where src.codeLine(l).contains(".isButton") || src.codeLine(l).contains("accessibilityAction") {
                nearby = true
            }
            if nearby { continue }
            // Keyboard-dismiss taps are not buttons.
            if let body = mod.closures.first?.range ?? mod.args {
                let t = src.codeText(body)
                if t.range(of: #"(?i)focus|resignFirstResponder|endEditing|keyboard"#, options: .regularExpression) != nil { continue }
            }
            ctx.add("tap-gesture-as-button", m.range.location, ".onTapGesture makes a silent button: no button trait, highlight, focus, keyboard or Switch Control support. Use Button with a custom ButtonStyle, or add .accessibilityAddTraits(.isButton) + .accessibilityLabel.")
        }

        // Buttons: icon-only label / small fixed target.
        for m in src.matches(#"(?<![\w.])Button\s*[({]"#) {
            let ch = src.chain(fromRoot: m.range.location)
            guard let label = buttonLabel(src, ch) else { continue }
            let labelText = src.codeText(label)
            let chainHas = { (names: [String]) in ch.modifiers.contains { names.contains($0.name) } }

            // icon-button-no-label
            if labelText.range(of: #"(?<![\w.])Image\s*\("#, options: .regularExpression) != nil,
               labelText.range(of: #"(?<![\w.])(?:Text|Label|TextField|ProgressView)\s*[({]|accessibilityLabel|accessibilityHidden"#, options: .regularExpression) == nil,
               !chainHas(["accessibilityLabel", "accessibilityHidden", "accessibilityRepresentation", "accessibilityElement"]),
               !labelHasImageLabel(src, label) {
                ctx.add("icon-button-no-label", m.range.location, "Image-only Button has no accessibility label. Use Button(\"Title\", systemImage: \"…\") or Label(\"Title\", systemImage:) with .labelStyle(.iconOnly), or add .accessibilityLabel(\"…\").")
            }

            // small-touch-target
            if !ctx.importsAppKitOnly,
               !chainHas(["contentShape", "padding", "controlSize"]),
               !ch.modifiers(named: "frame").contains(where: { f in f.args.map { src.codeText($0).contains("min") || frameAtLeast44(src, $0) } ?? false }),
               !src.contains(#"contentShape|\.padding|minWidth|minHeight|(?i:tapTarget|touchTarget|hitTarget|hitArea|tapArea|minTap)"#, in: label),
               !ch.modifiers.contains(where: { $0.name.range(of: #"(?i)tapTarget|touchTarget|hitTarget|hitArea|tapArea|minTap"#, options: .regularExpression) != nil }) {
                let start = src.skipWS(label.lowerBound)
                if SourceFile.isIdent(src.char(start)) {
                    let inner = src.chain(fromRoot: start)
                    // The label must be a single expression.
                    if src.skipWS(inner.end) >= label.upperBound, let f = inner.modifiers(named: "frame").last, let fa = f.args,
                       let w = src.arg("width", in: fa).flatMap({ src.number(in: $0) }),
                       let h = src.arg("height", in: fa).flatMap({ src.number(in: $0) }),
                       min(w, h) < 44 {
                        ctx.add("small-touch-target", f.dot, "Button label fixed at \(fmt(w))x\(fmt(h)) pt, below the 44x44 pt minimum. Keep the visual size but add .frame(minWidth: 44, minHeight: 44) + .contentShape(.rect), or padding.")
                    }
                }
            }
        }

        // Hidden navigation bar.
        for m in src.matches(#"\.navigationBarHidden\s*\(\s*true\s*\)|\.toolbar\s*\(\s*\.hidden\s*,\s*for\s*:\s*\.navigationBar\s*\)|\.toolbarVisibility\s*\(\s*\.hidden\s*,\s*for\s*:\s*\.navigationBar\s*\)"#) {
            ctx.add("hidden-nav-bar", m.range.location, "Hiding the navigation bar removes the back button, title and large-title collapse. Keep the bar (use .toolbarBackground(.hidden, for: .navigationBar) for an immersive look) unless the screen supplies its own back affordance.")
        }
    }

    static func frameAtLeast44(_ src: SourceFile, _ a: Range<Int>) -> Bool {
        let w = src.arg("width", in: a).flatMap { src.number(in: $0) } ?? 0
        let h = src.arg("height", in: a).flatMap { src.number(in: $0) } ?? 0
        return w >= 44 && h >= 44
    }

    /// `Image("name", label: Text(…))` or `Image(systemName:)` with `.accessibilityLabel` inside the label.
    static func labelHasImageLabel(_ src: SourceFile, _ label: Range<Int>) -> Bool {
        src.contains(#"Image\s*\([^)]*\blabel\s*:"#, in: label)
    }

    /// The range of a Button's label content, or nil when the Button uses a title initializer.
    static func buttonLabel(_ src: SourceFile, _ ch: Chain) -> Range<Int>? {
        if let labeled = ch.rootClosures.first(where: { $0.label == "label" }) { return labeled.range }
        if let a = ch.rootArgs {
            let args = src.arguments(a)
            if let l = args.first(where: { $0.label == "label" }) {
                let s = src.skipWS(l.value.lowerBound)
                if src.char(s) == 123, let e = src.match[s] { return (s + 1)..<e }
                return nil
            }
            if args.contains(where: { $0.label == "action" }), let c = ch.rootClosures.first, c.label == nil { return c.range }
        }
        return nil
    }

    // MARK: - Platform & performance

    static func platform(_ ctx: inout CheckContext) {
        let src = ctx.src
        let simple: [(String, String)] = [
            (#"(?<![\w.])NavigationView\s*[({]"#, "NavigationView is deprecated. Use NavigationStack (or NavigationSplitView for sidebar/detail layouts)."),
            (#"(?<![\w])\.foregroundColor\s*\("#, ".foregroundColor(_:) is deprecated. Use .foregroundStyle(_:) (accepts hierarchical styles like .secondary)."),
            (#"(?<![\w])\.cornerRadius\s*\("#, ".cornerRadius(_:) is deprecated. Use .clipShape(.rect(cornerRadius: 16, style: .continuous))."),
            (#"(?<![\w])\.navigationBarTitle\s*\("#, ".navigationBarTitle(_:) is deprecated. Use .navigationTitle(_:) with .navigationBarTitleDisplayMode(_:)."),
            (#"(?<![\w])\.edgesIgnoringSafeArea\s*\("#, ".edgesIgnoringSafeArea(_:) is deprecated. Use .ignoresSafeArea(edges:) (backgrounds only; keep content in the safe area)."),
            (#"(?<![\w])\.accentColor\s*\("#, ".accentColor(_:) is deprecated. Use .tint(_:) (or the AccentColor asset)."),
        ]
        for (p, msg) in simple {
            for m in src.matches(p) {
                // `.cornerRadius(` on a CALayer-ish receiver isn't a SwiftUI modifier; those are assignments, so calls are fine to flag.
                ctx.add("deprecated-api", m.range.location, msg)
            }
        }
        for m in src.matches(#"(?<![\w])\.animation\s*\("#) {
            let parenAt = m.range.location + m.range.length - 1
            guard let close = src.match[parenAt] else { continue }
            let args = src.arguments((parenAt + 1)..<close)
            guard let first = args.first, first.label == nil, !args.contains(where: { $0.label == "value" }) else { continue }
            // Must be chained onto a view (`TimelineView(.animation(…))` is a schedule, not the modifier).
            let prev = src.skipWSBack(m.range.location - 1)
            guard prev >= 0 else { continue }
            let pc = src.char(prev)
            guard pc == 41 || pc == 125 || pc == 93 || SourceFile.isIdent(pc) else { continue }
            // `.animation(.default) { content in … }` (iOS 17 scoped animation) has a trailing closure — not deprecated.
            let after = src.skipWS(close + 1, newlines: false)
            if src.char(after) == 123 { continue }
            // Must be a view modifier (preceded by an expression), not `Animation.animation`/declarations.
            ctx.add("deprecated-api", m.range.location, ".animation(_:) without value: is deprecated and animates every change. Use .animation(_:value:) or withAnimation at the state change.")
        }
        for m in src.matches(#"\bUIScreen\s*\.\s*main\s*\.\s*(?:bounds|nativeBounds)\b"#) {
            ctx.add("screen-bounds-layout", m.range.location, "UIScreen.main.bounds ignores the real window (iPad multitasking, Stage Manager, rotation, iPhone Duo) and is deprecated. Use containerRelativeFrame, size classes, or GeometryReader for the container.")
        }
        for m in src.matches(#"(?<![\w.])AnyView\s*\("#) {
            ctx.add("any-view", m.range.location, "AnyView erases view identity and defeats diffing. Use @ViewBuilder, Group, or `some View` with if/switch branches.")
        }
    }
}

extension String {
    /// Capture group 1 of every match of `pattern`.
    func matches(_ pattern: String) -> [String] {
        guard let re = SourceFile.regex(pattern) else { return [] }
        let ns = self as NSString
        return re.matches(in: self, range: NSRange(location: 0, length: ns.length)).compactMap {
            $0.numberOfRanges > 1 && $0.range(at: 1).location != NSNotFound ? ns.substring(with: $0.range(at: 1)) : nil
        }
    }
}

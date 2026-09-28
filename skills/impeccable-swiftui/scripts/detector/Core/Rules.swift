import Foundation

/// Tool version, printed by `--version` and embedded in JSON output.
public let impeccableVersion = "0.1.0"

public enum Severity: String, Codable, CaseIterable, Comparable {
    case error, warning, info

    var rank: Int {
        switch self {
        case .error: return 0
        case .warning: return 1
        case .info: return 2
        }
    }

    public static func < (lhs: Severity, rhs: Severity) -> Bool { lhs.rank < rhs.rank }
}

public struct Rule: Codable, Equatable {
    public let id: String
    public let severity: Severity
    public let category: String
    /// One-line rationale (why it matters).
    public let rationale: String
}

public struct Finding: Codable, Equatable {
    public let file: String
    public let line: Int
    public let column: Int
    public let severity: Severity
    public let rule: String
    public let message: String

    public init(file: String, line: Int, column: Int, severity: Severity, rule: String, message: String) {
        self.file = file
        self.line = line
        self.column = column
        self.severity = severity
        self.rule = rule
        self.message = message
    }
}

public enum RuleCatalog {
    public static let all: [Rule] = [
        // Typography
        Rule(id: "fixed-font-size", severity: .error, category: "typography",
             rationale: ".font(.system(size:)) / UIFont.systemFont(ofSize:) outside a token file ignores Dynamic Type."),
        Rule(id: "custom-font-no-relative", severity: .warning, category: "typography",
             rationale: "Font.custom(_:size:) without relativeTo: (or with fixedSize:) does not scale with its text style."),
        Rule(id: "overused-font", severity: .info, category: "typography",
             rationale: "Inter, Poppins, Montserrat & co. are the template display faces; they erase brand voice."),
        Rule(id: "tiny-font", severity: .error, category: "typography",
             rationale: "Point sizes below 11 pt are below the platform legibility floor."),
        // Color
        Rule(id: "hardcoded-color", severity: .warning, category: "color",
             rationale: "Color(red:)/Color(hex:)/#colorLiteral/UIColor(red:) outside token files bypass dark mode and the palette."),
        Rule(id: "pure-black-white-surface", severity: .info, category: "color",
             rationale: "Pure black/white backgrounds skip semantic adaptation and read harsh."),
        Rule(id: "gray-on-color", severity: .warning, category: "color",
             rationale: "Gray text on a saturated background looks washed out and fails contrast."),
        Rule(id: "ai-gradient-palette", severity: .warning, category: "color",
             rationale: "Purple/indigo + blue/pink/cyan gradients are the stock AI-app look."),
        Rule(id: "gradient-text", severity: .warning, category: "color",
             rationale: "Gradient-filled text is a template tell and hurts legibility."),
        Rule(id: "opacity-hierarchy", severity: .info, category: "color",
             rationale: "Text dimmed with opacity instead of .secondary/.tertiary ignores vibrancy and Increase Contrast."),
        // Surface
        Rule(id: "glow-shadow", severity: .warning, category: "surface",
             rationale: "Colored zero-offset shadows read as neon glow."),
        Rule(id: "hard-offset-shadow", severity: .warning, category: "surface",
             rationale: "Radius-0 offset shadows are a web-brutalist gimmick, off-platform on Apple UIs."),
        Rule(id: "glass-by-default", severity: .warning, category: "surface",
             rationale: "More than 3 material/glass uses in a file: glass is for system chrome, not every card."),
        Rule(id: "side-stripe", severity: .warning, category: "surface",
             rationale: "A leading colored bar on a card is a dashboard cliché."),
        Rule(id: "over-rounded", severity: .warning, category: "surface",
             rationale: "Corner radius >= 32 on cards is bubbly and off-platform."),
        Rule(id: "eyebrow-label", severity: .warning, category: "surface",
             rationale: "Uppercase tracked caption above a heading is a landing-page tell."),
        Rule(id: "numbered-section", severity: .warning, category: "surface",
             rationale: "\"01\" / \"02\" section numbers are an editorial-web tell."),
        Rule(id: "emoji-icon", severity: .warning, category: "surface",
             rationale: "Emoji standing in for icons don't tint, scale with symbols, or read well in VoiceOver."),
        // Motion
        Rule(id: "bounce-easing", severity: .warning, category: "motion",
             rationale: ".bouncy, bounce > 0.3, dampingFraction < 0.6, extraBounce: toy-like motion."),
        Rule(id: "reduce-motion-ignored", severity: .warning, category: "motion",
             rationale: "repeatForever / PhaseAnimator / KeyframeAnimator in a file that never reads accessibilityReduceMotion."),
        Rule(id: "section-fade", severity: .info, category: "motion",
             rationale: "3+ opacity(x ? 1 : 0) entrance toggles: the scroll-reveal web cliché."),
        // Interaction & accessibility
        Rule(id: "tap-gesture-as-button", severity: .warning, category: "interaction",
             rationale: ".onTapGesture without a button trait is invisible to VoiceOver, keyboard and Switch Control."),
        Rule(id: "icon-button-no-label", severity: .error, category: "interaction",
             rationale: "Image-only Button without an accessibility label."),
        Rule(id: "small-touch-target", severity: .warning, category: "interaction",
             rationale: "Button label fixed below 44x44 pt with no contentShape/min frame."),
        Rule(id: "hidden-nav-bar", severity: .warning, category: "interaction",
             rationale: "Hiding the navigation bar removes the back button and title."),
        // Platform & performance
        Rule(id: "deprecated-api", severity: .warning, category: "platform",
             rationale: "NavigationView, .foregroundColor, .cornerRadius, .navigationBarTitle, .edgesIgnoringSafeArea, .accentColor, .animation(_:) without value:."),
        Rule(id: "screen-bounds-layout", severity: .warning, category: "platform",
             rationale: "UIScreen.main.bounds ignores the real window (multitasking, Stage Manager, rotation, foldables)."),
        Rule(id: "any-view", severity: .info, category: "performance",
             rationale: "AnyView erases view identity and defeats diffing."),
    ]

    public static let byID: [String: Rule] = {
        var d: [String: Rule] = [:]
        for r in all { d[r.id] = r }
        return d
    }()

    public static var ids: [String] { all.map(\.id) }

    static func severity(_ id: String) -> Severity { byID[id]?.severity ?? .warning }
}

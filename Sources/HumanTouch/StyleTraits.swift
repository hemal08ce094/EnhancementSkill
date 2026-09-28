import DesignSkills

/// Where each editorially safe DesignSkills style sits on the human axes.
///
/// Only styles that hold up in an App Store feature are listed: every one is
/// adaptive or deliberately single-scheme, passes contrast, and keeps native
/// structure. Styles that are strong costumes (pacman, matrix, fantasy…) stay
/// available through `TouchDirection.overriding(theme:)` but are never picked
/// automatically.
public struct StyleTraits: Sendable, Hashable {
    public var slug: String
    public var energy: Double
    public var warmth: Double
    public var craft: Double
    /// The highest stakes this style still reads as trustworthy at.
    public var maxStakes: TouchProfile.Stakes

    public static let catalog: [StyleTraits] = [
        // Quiet, precise, trustworthy
        .init(slug: "premium", energy: 0.35, warmth: 0.40, craft: 0.10, maxStakes: .high),
        .init(slug: "clean", energy: 0.20, warmth: 0.45, craft: 0.10, maxStakes: .high),
        .init(slug: "minimal", energy: 0.10, warmth: 0.50, craft: 0.20, maxStakes: .high),
        .init(slug: "enterprise", energy: 0.30, warmth: 0.25, craft: 0.05, maxStakes: .high),
        .init(slug: "corporate", energy: 0.30, warmth: 0.15, craft: 0.05, maxStakes: .high),
        .init(slug: "claude", energy: 0.10, warmth: 0.65, craft: 0.35, maxStakes: .high),
        .init(slug: "refined", energy: 0.25, warmth: 0.70, craft: 0.30, maxStakes: .high),
        // Warm, readable, human
        .init(slug: "editorial", energy: 0.25, warmth: 0.55, craft: 0.40, maxStakes: .everyday),
        .init(slug: "paper", energy: 0.15, warmth: 0.75, craft: 0.55, maxStakes: .everyday),
        .init(slug: "cafe", energy: 0.35, warmth: 0.90, craft: 0.50, maxStakes: .everyday),
        .init(slug: "friendly", energy: 0.50, warmth: 0.95, craft: 0.55, maxStakes: .everyday),
        .init(slug: "bento", energy: 0.45, warmth: 0.70, craft: 0.30, maxStakes: .everyday),
        .init(slug: "glassmorphism", energy: 0.55, warmth: 0.50, craft: 0.15, maxStakes: .everyday),
        // Playful, handmade
        .init(slug: "claymorphism", energy: 0.65, warmth: 0.85, craft: 0.60, maxStakes: .low),
        .init(slug: "lingo", energy: 0.80, warmth: 0.85, craft: 0.45, maxStakes: .low),
        .init(slug: "doodle", energy: 0.60, warmth: 0.85, craft: 0.95, maxStakes: .low),
        .init(slug: "riso", energy: 0.70, warmth: 0.75, craft: 0.85, maxStakes: .low),
        .init(slug: "fiction", energy: 0.75, warmth: 0.90, craft: 0.80, maxStakes: .low),
        .init(slug: "neobrutalism", energy: 0.85, warmth: 0.70, craft: 0.70, maxStakes: .low),
        // Bold, kinetic
        .init(slug: "power", energy: 0.80, warmth: 0.30, craft: 0.20, maxStakes: .everyday),
        .init(slug: "dramatic", energy: 0.90, warmth: 0.35, craft: 0.30, maxStakes: .low),
        .init(slug: "pulse", energy: 0.95, warmth: 0.60, craft: 0.40, maxStakes: .low),
        .init(slug: "levels", energy: 0.60, warmth: 0.30, craft: 0.10, maxStakes: .high),
    ]

    /// Squared distance to a profile on the three axes. Energy and warmth are
    /// what people feel first, so they weigh more than craft.
    func distance(to p: TouchProfile) -> Double {
        let e = energy - p.energy, w = warmth - p.warmth, c = craft - p.craft
        return 1.2 * e * e + 1.2 * w * w + 0.8 * c * c
    }
}

extension TouchProfile.Stakes: Comparable {
    private var rank: Int { switch self { case .low: 0; case .everyday: 1; case .high: 2 } }
    public static func < (a: Self, b: Self) -> Bool { a.rank < b.rank }
}

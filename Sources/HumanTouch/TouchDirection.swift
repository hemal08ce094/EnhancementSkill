import DesignSkills
import SwiftUI
import ThinkingOrbs

/// The visual direction derived from a ``TouchProfile``: which style, how much
/// hand-drawn texture, what the assistant looks like, how things move and feel.
///
/// Every field carries a reason in ``rationale`` so a designer (or an App Store
/// editor reading the pitch) can see why the app looks the way it does.
public struct TouchDirection: Sendable {
    public var profile: TouchProfile
    /// The DesignSkills style for surfaces, type, color and components.
    public var theme: DesignTheme
    /// How much of the Drawably pen-sketch look to use.
    public var handDrawn: HandDrawn
    /// How the assistant (if any) shows up.
    public var assistant: Assistant
    /// Multiplier for Thinking Orb speed; calmer apps think slower.
    public var orbSpeed: Double
    /// Default spring for state changes.
    public var spring: Animation
    /// How strongly the app answers touches with haptics.
    public var haptics: Haptics
    /// Why each choice was made, in plain language.
    public var rationale: [String]

    public enum HandDrawn: String, Sendable, CaseIterable {
        /// No sketch texture anywhere.
        case none
        /// Pen underlines, circles and highlights on a few key words; arrows in onboarding.
        case accents
        /// Sketched controls and cards on expressive surfaces (onboarding, empty states, rewards).
        case controls
    }

    public enum Assistant: Sendable, Hashable {
        case none
        /// Thinking Orbs only; no face.
        case orb
        /// A Bot Avatar character. Falls back to an orb where BotAvatars is unavailable (macOS).
        case bot(BotPersona)
    }

    /// Platform-independent description of a bot, so the direction stays
    /// resolvable on macOS where BotAvatars is not linked.
    public struct BotPersona: Sendable, Hashable {
        /// A BotAvatars type raw value (`clover`, `pebble`, `droid`…).
        public var type: String
        public var reason: String
    }

    public enum Haptics: String, Sendable, CaseIterable {
        case subtle, standard, expressive
    }
}

public extension TouchDirection {
    /// Resolves a profile into a direction. Deterministic: the same profile
    /// always gives the same answer.
    init(_ profile: TouchProfile) {
        self = TouchDirector.resolve(profile)
    }

    /// The same direction with a different DesignSkills style, for when the
    /// team has already chosen one (or wants a costume style like `pacman`).
    func overriding(theme slug: String) -> TouchDirection {
        guard let theme = DesignTheme.named(slug) else { return self }
        var copy = self
        copy.theme = theme
        copy.rationale.append("Style pinned to \(theme.name) by the team.")
        return copy
    }
}

/// Maps human traits to design ingredients.
public enum TouchDirector {
    public static func resolve(_ p: TouchProfile) -> TouchDirection {
        var why: [String] = []

        // 1. Style: nearest style on the energy / warmth / craft axes that can
        //    carry the stakes. Trust is not negotiable, so stakes filter first.
        let eligible = StyleTraits.catalog.filter { $0.maxStakes >= p.stakes }
        let best = eligible.min { $0.distance(to: p) < $1.distance(to: p) } ?? StyleTraits.catalog[0]
        let theme = DesignTheme.named(best.slug) ?? .premium
        why.append("\(theme.name): closest style to \(describe(p)), and safe at \(p.stakes.rawValue) stakes.")

        // 2. Hand-drawn texture: craft opens it, stakes cap it. Glance apps
        //    stay clean because boiling strokes are noise when you have 2 seconds.
        var hand: TouchDirection.HandDrawn =
            p.craft >= 0.75 ? .controls : p.craft >= 0.45 ? .accents : .none
        if p.stakes == .high, hand == .controls { hand = .accents }
        if p.moment == .glance, hand != .none { hand = .none }
        switch hand {
        case .none: why.append("No sketch texture: \(p.moment == .glance ? "glanceable screens need clean edges" : "the app should feel engineered, not handmade").")
        case .accents: why.append("Pen accents only: a human mark on key words and first-run arrows, without making controls look unfinished.")
        case .controls: why.append("Sketched controls on expressive screens: the app is handmade in spirit, so its buttons can be too.")
        }

        // 3. Assistant.
        let assistant: TouchDirection.Assistant
        switch p.assistant {
        case .none:
            assistant = .none
        case .quiet:
            assistant = .orb
            why.append("Thinking Orbs instead of spinners: the AI shows its work without becoming a character.")
        case .character:
            let persona = botPersona(for: p)
            assistant = .bot(persona)
            why.append("A \(persona.type) bot as the assistant's face: \(persona.reason)")
        }

        // 4. Motion and haptics follow energy; high stakes damp both.
        let response = 0.55 - 0.25 * p.energy                 // 0.30 lively … 0.55 calm
        var damping = 0.95 - 0.30 * p.energy                   // 0.65 bouncy … 0.95 settled
        if p.stakes == .high { damping = max(damping, 0.9) }
        let haptics: TouchDirection.Haptics =
            p.stakes == .high || p.energy < 0.3 ? .subtle : p.energy > 0.7 ? .expressive : .standard
        why.append("Springs \(p.energy > 0.6 ? "snap with a little bounce" : "settle softly") and haptics are \(haptics.rawValue), matching the app's energy.")

        return TouchDirection(
            profile: p,
            theme: theme,
            handDrawn: hand,
            assistant: assistant,
            orbSpeed: 0.75 + 0.5 * p.energy,
            spring: .spring(response: response, dampingFraction: damping),
            haptics: haptics,
            rationale: why
        )
    }

    static func botPersona(for p: TouchProfile) -> TouchDirection.BotPersona {
        switch (p.warmth >= 0.6, p.energy >= 0.55) {
        case (true, true): .init(type: "clover", reason: "warm and lively, a friendly sidekick.")
        case (true, false): .init(type: "pebble", reason: "warm and calm, a soft presence that listens.")
        case (false, true): .init(type: "mech", reason: "confident and fast, a capable operator.")
        case (false, false): .init(type: "droid", reason: "precise and composed, an assistant you can trust.")
        }
    }

    static func describe(_ p: TouchProfile) -> String {
        let e = p.energy < 0.35 ? "calm" : p.energy > 0.65 ? "lively" : "steady"
        let w = p.warmth < 0.35 ? "cool" : p.warmth > 0.65 ? "warm" : "balanced"
        let c = p.craft < 0.35 ? "precise" : p.craft > 0.65 ? "handmade" : "crafted"
        return "a \(e), \(w), \(c) feel"
    }
}

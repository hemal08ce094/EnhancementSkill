import DesignSkills
import Drawably
import SwiftUI
import ThinkingOrbs
#if canImport(BotAvatars)
import BotAvatars
#endif

// MARK: - Thinking

/// An AI activity indicator that follows the direction: a Thinking Orb at the
/// profile's pace, tinted by the theme when the style is colorful enough to carry it.
public struct TouchThinking: View {
    @Environment(\.touchDirection) private var direction
    var state: OrbState
    var size: OrbSize
    var label: String?

    public init(_ state: OrbState = .working, size: OrbSize = .small, label: String? = nil) {
        self.state = state; self.size = size; self.label = label
    }

    public var body: some View {
        ThinkingOrb(state, size: size, speed: direction.orbSpeed, label: label)
    }
}

// MARK: - Assistant

/// What the assistant is doing, shared by orbs and bots.
public enum TouchAssistantState: Sendable, Hashable {
    case idle, working, resting
}

/// The assistant's face, as the direction decides: a Bot Avatar character, a
/// breathing orb, or nothing. On macOS a bot direction falls back to an orb.
public struct TouchAssistant: View {
    @Environment(\.touchDirection) private var direction
    var state: TouchAssistantState
    var size: CGFloat
    var interactive: Bool

    public init(_ state: TouchAssistantState = .idle, size: CGFloat = 40, interactive: Bool = false) {
        self.state = state; self.size = size; self.interactive = interactive
    }

    public var body: some View {
        switch direction.assistant {
        case .none:
            EmptyView()
        case .orb:
            orb
        case let .bot(persona):
            #if canImport(BotAvatars)
            BotAvatar(
                type: BotAvatarType(rawValue: persona.type) ?? .clover,
                state: botState,
                size: size,
                color: botColor,
                speed: direction.orbSpeed,
                interactive: interactive
            )
            #else
            orb
            #endif
        }
    }

    private var orb: some View {
        let orbState: OrbState = switch state {
        case .idle, .resting: .breathing
        case .working: .composing
        }
        return ThinkingOrb(orbState, speed: direction.orbSpeed, paused: state == .resting, renderSize: size)
    }

    #if canImport(BotAvatars)
    private var botState: BotAvatarState {
        switch state {
        case .idle: .default
        case .working: .working
        case .resting: .sleeping
        }
    }

    @Environment(\.colorScheme) private var scheme
    /// The first theme color bright and saturated enough to read as a friendly
    /// body. Ink-dark primaries (common in editorial styles) make a black blob;
    /// if nothing fits, the bot keeps its own color.
    private var botColor: BotColor? {
        let palette = direction.theme.palette(for: scheme)
        for c in [palette.accent, palette.primary, palette.secondary] {
            let luminance = 0.2126 * c.red + 0.7152 * c.green + 0.0722 * c.blue
            let chroma = max(c.red, c.green, c.blue) - min(c.red, c.green, c.blue)
            if (0.2...0.8).contains(luminance) && chroma > 0.2 {
                return BotColor(r: c.red * 255, g: c.green * 255, b: c.blue * 255)
            }
        }
        return nil
    }
    #endif
}

// MARK: - Emphasis

public extension View {
    /// Marks a key word or number. A pen mark when the direction allows
    /// hand-drawn texture (highlight by default, since it reads on short numbers
    /// too); otherwise the theme's primary color at heavier weight.
    func touchEmphasis(_ style: TouchEmphasisStyle = .highlight) -> some View {
        modifier(TouchEmphasisModifier(style: style))
    }
}

public enum TouchEmphasisStyle: Sendable { case underline, highlight, circle }

struct TouchEmphasisModifier: ViewModifier {
    @Environment(\.touchDirection) private var direction
    let style: TouchEmphasisStyle

    func body(content: Content) -> some View {
        if direction.handDrawn == .none {
            content
                .fontWeight(.semibold)
                .foregroundStyle(direction.theme.dynamicColor(.primary))
        } else {
            switch style {
            case .underline: content.drawablyUnderline()
            case .highlight: content.drawablyHighlight()
            case .circle: content.drawablyCircle()
            }
        }
    }
}

// MARK: - Cards and buttons

/// A card in the direction's material: a pen-sketched card when the direction
/// uses sketched controls and `expressive` is true, the theme's card otherwise.
///
/// Pass `expressive: true` only on Persuade and Experience surfaces
/// (onboarding, empty states, rewards); everyday screens keep the theme card.
public struct TouchCard<Content: View>: View {
    @Environment(\.touchDirection) private var direction
    var expressive: Bool
    var content: Content

    public init(expressive: Bool = false, @ViewBuilder content: () -> Content) {
        self.expressive = expressive
        self.content = content()
    }

    public var body: some View {
        if expressive && direction.handDrawn == .controls {
            DrawablyCard { content }
        } else {
            ThemedCard { content }
        }
    }
}

/// A primary action in the direction's material, with haptics that match its energy.
public struct TouchButton: View {
    @Environment(\.touchDirection) private var direction
    @State private var taps = 0
    var title: LocalizedStringKey
    var role: Role
    var expressive: Bool
    var action: () -> Void

    public enum Role: Sendable { case primary, secondary, destructive }

    public init(_ title: LocalizedStringKey, role: Role = .primary, expressive: Bool = false, action: @escaping () -> Void) {
        self.title = title; self.role = role; self.expressive = expressive; self.action = action
    }

    public var body: some View {
        Group {
            if expressive && direction.handDrawn == .controls {
                // Full width like the themed button, so layout doesn't change with the profile.
                // Secondary keeps the pen tone: Drawably's neutral grey is too faint on warm paper.
                DrawablyButton(
                    variant: role == .primary ? .solid : .outline,
                    tone: role == .destructive ? .danger : .pen,
                    action: tap
                ) {
                    Text(title).frame(maxWidth: .infinity)
                }
            } else {
                Button(title, action: tap)
                    .buttonStyle(.themed(themedRole, fullWidth: true))
            }
        }
        .modifier(TouchHapticModifier(haptics: direction.haptics, role: role, trigger: taps))
    }

    private func tap() { taps += 1; action() }

    private var themedRole: ThemedButtonRole {
        switch role {
        case .primary: .primary
        case .secondary: .secondary
        case .destructive: .destructive
        }
    }
}

/// Haptics per direction; visionOS has no sensory feedback before 26.
struct TouchHapticModifier: ViewModifier {
    let haptics: TouchDirection.Haptics
    let role: TouchButton.Role
    let trigger: Int

    func body(content: Content) -> some View {
        if #available(visionOS 26, *) {
            content.sensoryFeedback(haptics.feedback(for: role), trigger: trigger)
        } else {
            content
        }
    }
}

@available(visionOS 26, *)
extension TouchDirection.Haptics {
    func feedback(for role: TouchButton.Role) -> SensoryFeedback {
        if role == .destructive { return .warning }
        return switch self {
        case .subtle: .selection
        case .standard: .impact(weight: .light)
        case .expressive: .impact(weight: .medium, intensity: 0.9)
        }
    }
}

// MARK: - Motion

public extension View {
    /// Animates `value` changes with the direction's spring (off under Reduce Motion).
    func touchAnimation<V: Equatable>(value: V) -> some View {
        modifier(TouchAnimationModifier(value: value))
    }
}

struct TouchAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.touchDirection) private var direction
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : direction.spring, value: value)
    }
}

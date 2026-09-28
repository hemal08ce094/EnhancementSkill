import DesignSkills
import Drawably
import SwiftUI

extension EnvironmentValues {
    /// The direction set by `.humanTouch(_:)`. Defaults to the trusted-tool profile.
    @Entry public var touchDirection: TouchDirection = TouchDirection(.trustedTool)
}

public extension View {
    /// Applies the whole kit from a human brief: DesignSkills theme, Drawably
    /// pen colors taken from that theme, and the direction every `Touch*` view reads.
    ///
    /// Put it once at the root of the app (or of one flow).
    func humanTouch(_ profile: TouchProfile) -> some View {
        humanTouch(TouchDirection(profile))
    }

    /// Applies an already-resolved (or overridden) direction.
    func humanTouch(_ direction: TouchDirection) -> some View {
        modifier(HumanTouchModifier(direction: direction))
    }
}

struct HumanTouchModifier: ViewModifier {
    let direction: TouchDirection

    func body(content: Content) -> some View {
        let theme = direction.theme
        content
            .environment(\.touchDirection, direction)
            // Pen ink and paper come from the theme so sketches belong to the same world.
            .drawably(
                stroke: theme.dynamicColor(.text),
                fill: theme.dynamicColor(.primary),
                paper: theme.dynamicColor(.background),
                boil: direction.profile.energy < 0.3 ? 0.15 : 0.3
            )
            .drawablyTheme { $0.font = .body }
            .designTheme(theme)
    }
}

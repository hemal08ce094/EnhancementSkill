# iOS

For SwiftUI apps on iPhone. iPad targets also load [ipados.md](ipados.md).

On iPhone the mode narrows what expression may override. HIG conformance governs structure, navigation, and interaction in every mode; brand expresses through the layers the platform leaves open: tint, type, color, imagery, motion, haptics, content.

## The iOS slop test

Would a fluent iPhone user trust this app, or pause at off-spec controls? The tell is "ported from a website": a hand-built nav bar, a hamburger menu, web-shaped buttons with drop shadows, a floating action button, hover-dependent affordances, a splash screen. Default to the platform's components; depart only for a reason the user would thank you for.

## Layout & structure

- **Safe area.** Content may bleed under bars (`.ignoresSafeArea` on backgrounds and art only); controls stay inside the insets, clear of the Dynamic Island, home indicator, and corners. (detector: `deprecated-api` catches `.edgesIgnoringSafeArea`)
- **System navigation.** `TabView` for 2–5 top-level sections (sections, never actions), `NavigationStack` for hierarchy, `.sheet` for self-contained tasks. On iOS 18+ use the `Tab` API; on iOS 26+ search is a `Tab(role: .search)`. No custom global nav, no mixed metaphors.
- **Edge-swipe back stays alive.** `.navigationBarBackButtonHidden(true)` and custom back buttons kill it; so does a hidden nav bar. (detector: `hidden-nav-bar`)
- **Large titles** on top-level screens (`.navigationBarTitleDisplayMode(.large)`), collapsing to inline on scroll. Detail screens stay inline.
- **Toolbars, not floating buttons.** Actions go in `.toolbar` placements (`.primaryAction`, `.bottomBar`, `.topBarTrailing`); on iOS 26 they render on glass and group automatically, with `ToolbarSpacer` to separate groups.

## Targets

- **44×44 pt** minimum for every tappable control, with room between neighbors. Grow the hit area with `.contentShape(Rectangle())` and padding, not a bigger icon. (detector: `small-touch-target`)

## Typography

- **Dynamic Type everywhere.** Text styles or `Font.custom(_:size:relativeTo:)`; `@ScaledMetric` for icons and spacing that sit with text. Cap with `.dynamicTypeSize(...DynamicTypeSize.accessibility2)` only on fixed chrome, never on content. (detector: `fixed-font-size`, `custom-font-no-relative`)
- **SF carries the UI.** Body, labels, and controls stay on SF Pro; a brand face earns display moments. `.fontDesign(.rounded)` and `.fontWidth` are real voices, not defaults.
- **11 pt floor** (Caption 2); Body is 17 pt. (detector: `tiny-font`)

## Color & materials

- **Semantic colors** (`.primary`, `.secondary`, `Color(.systemBackground)`, `Color(.separator)`, the tint) and asset-catalog colorsets with Any/Dark and High Contrast appearances. Raw RGB in view code breaks in dark mode and Increase Contrast. (detector: `hardcoded-color`)
- **Dark mode is a first-class appearance.** Design and test both; dark is not inverted light.
- **One tint** drives interactive elements; decoration is not its job.
- **Liquid Glass is system chrome.** On iOS 26+ bars, tab bars, toolbars, and sheets get it for free. Your own floating controls may adopt `.glassEffect()` or `.buttonStyle(.glass)` inside a `GlassEffectContainer`, gated with `if #available(iOS 26, *)` and a material fallback. Content never sits on glass cards, and glass never stacks on glass. Check any material you placed with Reduce Transparency on. (detector: `glass-by-default`)

## Components

- **Platform controls.** `Toggle`, `Picker` (menu, segmented, wheel), `Stepper`, `DatePicker`, `Menu`, `.confirmationDialog`, `.alert`, `.contextMenu`, `.swipeActions`, `ShareLink`, `PhotosPicker`. Reinventing these for flavor is the most common native slop.
- **SF Symbols** in one weight, scale, and rendering mode (`.symbolRenderingMode(.hierarchical)` is a strong default); custom glyphs as exported custom symbols. No web icon sets, no emoji. (detector: `emoji-icon`)
- **Deliberate modality.** `.sheet` with `.presentationDetents` for a focused, dismissible sub-task; `.fullScreenCover` for immersion. Clear Cancel and a named confirm; swipe-to-dismiss stays unless unsaved data needs `.interactiveDismissDisabled` plus a confirmation.
- **Inset grouped lists** for settings-shaped content (`Form`, `.listStyle(.insetGrouped)`); no bespoke card stacks.

## Motion

- **System transitions.** Push slides, sheets rise, dismiss reverses the entrance. `.navigationTransition(.zoom(sourceID:in:))` with `.matchedTransitionSource` (iOS 18+) is the sanctioned hero move from a thumbnail; custom transitions that fight the stack disorient.
- **Springs, low bounce.** `.smooth`, `.snappy`, `.spring(duration:bounce:)` ≤ 0.15. (detector: `bounce-easing`)
- **Haptics are motion too.** `.sensoryFeedback` on real state changes: `.success` on completion, `.selection` on picker steps, `.impact` on a snap.
- **Honor Reduce Motion.** Crossfade instead of zooms, parallax, and large slides. (detector: `reduce-motion-ignored`)

## iPhone Duo

On iOS 27.1+ the unfolded iPhone Duo is one continuous inner display with a reserved fold region; treat it with [ipados.md](ipados.md)'s wide-layout rules (branch on real size, never center a phone column) and its fold section. Folded, it's an iPhone.

## Verifying the build

- **Previews for speed, Simulator for truth.** A `#Preview` matrix (light, dark, `.dynamicTypeSize(.accessibility3)`) catches most regressions in seconds. Then build and run: `xcodebuild -scheme <S> -destination 'platform=iOS Simulator,id=<UDID>' build`, `xcrun simctl install <UDID> <App.app>`, `xcrun simctl launch <UDID> <bundle-id>`, and capture with `xcrun simctl io <UDID> screenshot .impeccable/shots/<name>.png`. Use UDIDs from `xcrun simctl list devices booted`; names collide, UDIDs don't. DEBUG launch arguments that jump straight to a screen make captures repeatable.
- **Cover what ships.** The smallest and largest shipped iPhone at minimum; iPad too when it's a target.
- **Appearance and type belong in the pass.** `xcrun simctl ui <UDID> appearance dark` and `xcrun simctl ui <UDID> content_size accessibility-extra-extra-extra-large` catch what a default capture hides.
- **Simulators give breadth; haptics, gestures, camera, thermals, and real performance need hardware.** Say which one produced the evidence.

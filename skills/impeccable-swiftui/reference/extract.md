# Extract Flow

Find reusable patterns, values, and styles in the target, then consolidate them into the app's design system so screens consume one source of truth.

## Step 1: Discover the design system

Find where shared UI lives: a `DesignSystem` folder or local Swift package, `Theme` / `Tokens` / `Styles` files, asset catalogs with brand colorsets, `Color` and `Font` extensions, custom `ButtonStyle`s and `ViewModifier`s. `context` lists the evidence. Learn its structure and conventions: naming (`Color.brandTint` vs `Color.Brand.tint` vs `.accent`), access (`public` in a package vs internal), file layout, and how screens import it.

**CRITICAL**: if no design system exists, don't create one yet. Ask where it should live and in what shape (with the structured question tool when available, otherwise plain text and stop). Offer concrete options:

- a `DesignSystem/` group inside the app target (simplest; right for a single-target app);
- a local Swift package (`Packages/DesignSystem`) when widgets, a watch app, App Clips, or extensions must share it;
- an existing module the team already uses.

## Step 2: Identify patterns

Search the target for extraction candidates:

- **Colors**: `Color(red:…)`, `Color(hex:)`, `#colorLiteral`, `UIColor(red:…)` (`hardcoded-color`), and the same asset name spelled as a string in many places (`Color("Brand")`).
- **Type**: repeated `.font(.system(size:weight:))` combinations (`fixed-font-size`), repeated `.font(.headline).fontWeight(…).foregroundStyle(…)` stacks, custom faces without `relativeTo:` (`custom-font-no-relative`).
- **Spacing and shape**: recurring literal paddings, spacings, and corner radii; `.cornerRadius(` (`deprecated-api`) vs `RoundedRectangle(cornerRadius:style:)`.
- **Components**: buttons built from `Text` + `.padding` + `.background` + `.clipShape` in several places; the same row, card, badge, or empty state rebuilt per screen.
- **Modifier stacks**: the same 4–6 modifiers applied together (card surface, section header, pill); these become a `ViewModifier` with a `View` extension.
- **Motion and haptics**: repeated `.spring(…)` parameters, durations, and `.sensoryFeedback` pairings.

Run `<skill-base-dir>/scripts/impeccable-swiftui detect --json <target>` for a fast inventory of literals. Only extract what's used **3+ times with the same intent**. Premature abstraction is worse than duplication.

## Step 3: Plan the extraction

Write the plan before code:

- **Tokens**: which values become colorsets and semantic `Color` names, which become `Font` roles, which become spacing and radius constants.
- **Styles and components**: which become `ButtonStyle`, `LabelStyle`, `ToggleStyle`, `GroupBoxStyle`, `ViewModifier`s, or small `View` components.
- **Variants**: what each needs (prominence, size, destructive role), expressed with the platform's own inputs where possible (`.controlSize`, `role`, `isEnabled`, `configuration.isPressed`) rather than a pile of custom parameters.
- **Naming**: semantic and role-based, matching existing conventions.
- **Migration**: which call sites move, in what order.

**IMPORTANT**: systems grow incrementally. Extract what is clearly reusable now.

## Step 4: Extract and enrich

Semantic names over primitives: `surfaceRaised`, `textSecondary` (if you truly need it over `.secondary`), `danger`, not `gray100` or `red500`. Primitives may exist privately; screens see roles.

### Color

Colorsets in the asset catalog, with Any and Dark appearances (and High Contrast where contrast is tight), exposed as `ShapeStyle` members so they work in `foregroundStyle`, `background`, `fill`, and `tint`:

```swift
// DesignSystem/Colors.swift
extension ShapeStyle where Self == Color {
    static var brandTint: Color { Color("BrandTint", bundle: .module) }   // drop bundle: in an app target
    static var surface: Color { Color("Surface", bundle: .module) }
    static var surfaceRaised: Color { Color("SurfaceRaised", bundle: .module) }
    static var danger: Color { Color("Danger", bundle: .module) }
}
// usage: .foregroundStyle(.danger), .background(.surfaceRaised)
```

With Xcode's generated asset symbols on, `Color(.surface)` / `Color.surface` already exist for app-target catalogs; don't shadow them with duplicates, extend only what's missing. Set the brand tint as `AccentColor` and apply `.tint(.brandTint)` once at the root.

### Type

Named roles that stay on Dynamic Type:

```swift
extension Font {
    static let sectionTitle = Font.title3.weight(.semibold)
    static let stat = Font.system(.title, design: .rounded, weight: .semibold)
    static func brandDisplay(_ style: Font.TextStyle = .largeTitle, size: CGFloat = 34) -> Font {
        .custom("Fraunces-SemiBold", size: size, relativeTo: style)
    }
}
```

Numeric treatment (`.monospacedDigit()`) and tracking stay at call sites or move into a modifier; they aren't `Font` properties.

### Spacing, radius, and metrics

```swift
enum Spacing { static let xs: CGFloat = 4, s: CGFloat = 8, m: CGFloat = 12, l: CGFloat = 16, xl: CGFloat = 24, xxl: CGFloat = 32 }
enum Radius  { static let control: CGFloat = 10, card: CGFloat = 16 }
```

Always draw radii with `.continuous` style (`RoundedRectangle(cornerRadius: Radius.card, style: .continuous)`). Values that must scale with text become `@ScaledMetric` at the use site, seeded from the constant.

### Styles

Style protocols give you pressed, disabled, and accessibility behavior for free; prefer them over wrapper views:

```swift
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.brandTint.opacity(isEnabled ? 1 : 0.4),
                        in: .rect(cornerRadius: Radius.control, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { .init() }
}
// usage: Button("Start Route") { … }.buttonStyle(.primary)
```

Same pattern for `LabelStyle` (icon and title arrangement), `ToggleStyle` (only when the system switch truly doesn't fit the world), `GroupBoxStyle`, `ProgressViewStyle`. Don't wrap system controls whose default is right.

### Modifiers and components

- Repeated modifier stacks → a `ViewModifier` plus a `View` extension (`.cardSurface()`, `.sectionHeader()`).
- Repeated structures with content → a small `View` with `@ViewBuilder` slots (`EmptyState(title:systemImage:actions:)` wrapping `ContentUnavailableView` if the project needs a house version at all).
- Build accessibility in: combined elements for rows, header traits, labels on icon buttons, 44 pt minimum hit areas, layout switch at accessibility sizes.
- Add `#Preview`s for each style and component showing light, dark, AX size, and disabled or pressed states. The previews are the component catalog.

### Environment-injected theme (only when warranted)

A custom `EnvironmentKey` / `@Entry` theme value is justified only when the app genuinely switches whole palettes at runtime (user-selectable themes, per-workspace branding, white-label builds). Otherwise colorsets already handle light, dark, and High Contrast, and an environment theme is ceremony that every view must remember to read.

```swift
extension EnvironmentValues { @Entry var theme: Theme = .standard }
```

## Step 5: Migrate

- Find every instance of the extracted patterns (grep the literal values and modifier stacks, rerun `detect`).
- Replace systematically, screen by screen, and check each in `#Preview` or the Simulator for visual parity in light and dark.
- Delete the old implementations, orphaned helpers, unused colorsets, and duplicate extensions.
- Rerun `detect` on the migrated files: `hardcoded-color`, `fixed-font-size`, and `deprecated-api` counts should fall; token files are exempt by name (Theme, Token, DesignSystem, Palette, Colors, Color+, Typography, Fonts, Style).

## Step 6: Document

Update DESIGN.md via [document.md](document.md) so each section names the new code symbols and files. The `#Preview`s are the living catalog; DESIGN.md is the rulebook.

**NEVER**:
- Extract one-offs or things that merely look alike but differ in intent (a destructive and a primary button stay separate styles even if shaped alike)
- Name tokens by appearance (`blue500`, `gray2`) where a role name exists
- Bypass Dynamic Type in a `Font` role, or bake opacity hierarchy into text colors
- Wrap system controls in custom views that lose their accessibility and platform behavior
- Add an environment theme when colorsets suffice
- Create a token for every value; tokens carry meaning

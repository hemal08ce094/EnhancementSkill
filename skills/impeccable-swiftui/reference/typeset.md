Typography carries information, hierarchy, and voice. Improve it inside the established visual world; do not replace the identity unless the user asked to.

---

## Visitor mode

- **Persuade + Experience:** display type may carry the voice: a brand face, `.fontWidth(.expanded)`, New York for an editorial register, decisive scale contrast.
- **Operate + Read:** stability, scanability, and Dynamic Type come first. SF and the system text styles, tuned well, are usually right.
- **Platform:** follow the Typography section of the relevant platform file ([platforms/ios.md](platforms/ios.md), [platforms/macos.md](platforms/macos.md), [platforms/watchos.md](platforms/watchos.md), ...); macOS and watchOS have different base sizes and densities.

If replacing typography would create a new identity, route through [new-work.md](new-work.md) and update DESIGN.md. Otherwise preserve confirmed faces and improve their use.

## Two isolated assessments

When a sub-agent tool is available and permitted, run these independently; otherwise run them yourself in this order. Do not let detector findings anchor the design assessment.

1. **Typographic assessment:** inspect representative screens and the `Font` extensions. Answer every question with a file, modifier, or rendered capture:
   - **Authority and fit:** which faces, weights and roles are established? Do they fit the product, or are they unexamined defaults (an overused web face like Inter or Poppins bundled for no reason)? Is every family necessary?
   - **Hierarchy:** can title, body, label, metadata, and data roles be told apart at a glance? Are adjacent styles (`.subheadline` vs `.callout`) too close to carry different jobs?
   - **Scale and consistency:** are roles mapped to text styles, or is it a pile of `.system(size:)` values? Do repeated roles stay identical across screens?
   - **Reading:** is long-form text a comfortable measure (roughly 45–75 characters; constrain with a max width on iPad and Mac)? Line spacing and tracking tuned to the face?
   - **Stress:** what happens at `.accessibility5`, with German or Finnish strings, long names, narrow widths, and on the smallest supported device?
   - **Delivery:** are bundled fonts registered in `UIAppFonts` and actually used? Are unused weights shipped?
2. **Mechanical scan:**

```bash
<skill-base-dir>/scripts/impeccable-swiftui detect --json <target files or dirs>
```

Typography rules: `fixed-font-size`, `custom-font-no-relative`, `overused-font`, `tiny-font`, plus `eyebrow-label`. Also inspect sizes computed at runtime the detector can't see. Synthesize both passes before editing, noting what each caught alone. A clean scan is a floor, not proof of good typography.

## Set the system

Before editing, state the roles, the contrast between them, the reading measure and density, which faces and weights are authoritative, and localization or accessibility constraints. Use the fewest roles and families that make the hierarchy unmistakable. Name roles by purpose in one `Font` extension:

```swift
extension Font {
    static let display = Font.custom("Fraunces-SemiBold", size: 34, relativeTo: .largeTitle)
    static let cardTitle = Font.headline
    static let metric = Font.system(.title, design: .rounded, weight: .semibold).monospacedDigit()
}
```

## Apply

- **Text styles first.** `.largeTitle` … `.caption2` scale with Dynamic Type and carry platform-correct sizes, leading and tracking (Body is 17 pt on iOS). `.font(.system(size: 15))` in a view freezes the size (`fixed-font-size`).
- **Brand faces scale too.** `Font.custom(_:size:relativeTo:)` always; bare `.custom(_:size:)` or `fixedSize:` opts out of Dynamic Type (`custom-font-no-relative`). Use `@ScaledMetric(relativeTo:)` for icon sizes and spacing that sit next to text.
- **System variants before bundling.** `.fontDesign(.rounded | .serif | .monospaced)` (New York via `.serif`), `.fontWidth(.condensed | .compressed | .expanded)`, weights `.ultraLight` … `.black`. These are the whole SF family, free and hinted. A brand face earns its place in display roles; SF carries body, labels and controls.
- **Numbers.** `.monospacedDigit()` for anything that updates or aligns in columns; `.contentTransition(.numericText(value:))` for counters that change.
- **Floor.** Nothing below `.caption2` (11 pt at default size) for content (`tiny-font`). Uppercase tracked micro-labels above headings are a web tic (`eyebrow-label`); use a text style and `.secondary` instead.
- **Light on dark** may need one weight step up and slightly looser leading.
- **Leading and tracking** only by small, deliberate amounts: `.lineSpacing(2)`, `.tracking(0.2)`. Paragraph rhythm comes from spacing between `Text` views, not both indent and spacing.

### Truncation and fitting

Decide per role what happens when text doesn't fit:

- **Titles and body wrap.** Don't put `.lineLimit(1)` on anything a person needs to read in full.
- **Rows and metadata may truncate** with `.lineLimit(1...2)` and the right `.truncationMode` (`.middle` for file names and paths).
- **`.lineLimit(2, reservesSpace: true)`** keeps grid cells aligned without fixed heights.
- **`.minimumScaleFactor`** is for single short values in fixed chrome (a big number in a widget), never for body or labels; pair with `.lineLimit(1)` and keep the factor ≥ 0.75.
- **`ViewThatFits`** to swap a long label for a short one before shrinking anything.

### Dynamic Type through AX5

- At accessibility sizes (`dynamicTypeSize.isAccessibilitySize`), horizontal arrangements become vertical: swap `HStackLayout` for `VStackLayout` via `AnyLayout`, or let `ViewThatFits` choose.
- Icons beside text scale with `@ScaledMetric` or `.imageScale`.
- Cap with `.dynamicTypeSize(...DynamicTypeSize.accessibility2)` only on fixed chrome (a tab accessory, a compact badge), never on content.

## Verify

- Title, body, and metadata roles recognizable without reading the copy (try `.redacted(reason: .placeholder)`).
- Every screen captured at default size and at AX sizes: `#Preview` with `.dynamicTypeSize(.accessibility3)`, and Simulator with `xcrun simctl ui <UDID> content_size accessibility-extra-extra-extra-large`.
- Long and localized strings (a pseudo-language scheme option) don't clip or collide.
- The typography belongs to the product and its established world.
- The final scan has no unexplained findings.

Answer each item with rendered or source evidence, then rerun the scan. Do not substitute a bare "yes" for verification.

When the hierarchy holds, hand off to `/impeccable-swiftui polish`.

> **Additional context needed**: existing brand colors.

Introduce color as hierarchy, meaning, and atmosphere. Preserve confirmed brand and semantic conventions; do not replace a visual world under the guise of colorizing it.

---

## Visitor mode

- **Persuade + Experience:** color may carry the voice and own large regions when the selected world calls for it.
- **Operate + Read:** color primarily encodes action, selection, status, wayfinding, and reading hierarchy. Rarity gives the tint its force.

## Audit before choosing

Read DESIGN.md, the asset catalogs (`*.colorset`), `Color`/`ShapeStyle` extensions, the AccentColor, and representative states in both appearances. Identify:

- which colors are confirmed brand commitments;
- current canvas, text, action, and semantic roles;
- places where grayscale obscures hierarchy or state;
- contrast failures and color-only communication;
- Dark Mode, Increase Contrast, and chart requirements;
- whether the task asks for more color or a new identity.

If a new identity is required, use [new-work.md](new-work.md). Ask only when a binding brand decision cannot be inferred.

Run `<skill-base-dir>/scripts/impeccable-swiftui detect --json <target>` for `hardcoded-color`, `pure-black-white-surface`, `gray-on-color`, `ai-gradient-palette`, `gradient-text` and `opacity-hierarchy`.

## Choose a strategy

Name the emotional temperature, dominant relationship, contrast range, and dosage before editing. Restrained or immersive, it follows the brief and the world, not a fixed percentage.

Build roles, not a bag of swatches:

- canvas and elevated surfaces (system backgrounds, or brand surfaces with explicit dark variants);
- primary / secondary / tertiary text (`.primary`, `.secondary`, `.tertiary` hierarchical styles);
- action, focus, and selection (the tint);
- separators and fills;
- success, warning, error, information;
- data categories or scales when needed.

Choose hue from product meaning and visual direction, never from a category default (finance ≠ automatically green, AI ≠ automatically purple-to-blue).

## Where color lives in SwiftUI

- **Asset-catalog colors are the source of truth.** Each colorset gets Any and Dark appearances, and a High Contrast variant for both (check "High Contrast" under Appearances). Xcode generates symbols, so use `Color(.brandSurface)` / `.foregroundStyle(.brandInk)` instead of strings.
- **Raw values live only in a token file** (`Theme.swift`, `Palette.swift`); `Color(red:…)` or `Color(hex:)` in a view is `hardcoded-color`. If you need a computed dynamic color, build it in the token file with `UIColor { traits in … }` / `NSColor(name:dynamicProvider:)`.
- **One tint.** Set AccentColor in the asset catalog (or `.tint(.brand)` at the root). Controls, links, selection and toggles pick it up. Don't spend it on decoration.
- **Semantic system colors** for everything not brand: `Color(.systemGroupedBackground)`, `.background.secondary` (iOS 17+), `.separator`, `.red`/`.orange`/`.green` system variants, which already adapt to Dark Mode and Increase Contrast.
- **Hierarchy through styles, not alpha.** `.foregroundStyle(.secondary)` adapts on vibrant materials and in high contrast; `.opacity(0.6)` on text doesn't (`opacity-hierarchy`).

## Apply at system scale

- Let the strongest color own a deliberate region or role instead of scattering tiny accents.
- Keep the primary action easy to find; don't use the tint for non-interactive icons and headers.
- Tint neutrals only when the brand hue genuinely creates cohesion. System grays are valid.
- On colored surfaces, derive secondary text from the surface hue, not generic gray (`gray-on-color`).
- Keep semantic meanings consistent and respect platform conventions (destructive is red; `Button(role: .destructive)` handles it).
- Dark Mode is designed, not inverted: elevated surfaces get lighter, saturated brand colors come down in chroma, pure `#000`/`#FFF` slabs are rare (`pure-black-white-surface`).
- Charts: `chartForegroundStyleScale` with distinct lightness, plus `.symbol(by:)` or labels so color isn't the only code.
- Theme changes remap semantic roles; views never branch on `colorScheme` to pick hex values.

### Gradients, used with intent

A gradient needs a reason: light, depth, a material, a map of a value. `Color.accentColor.gradient` gives a subtle system-grade fill. `MeshGradient` (iOS 18+) can build a genuinely world-specific atmosphere behind a hero or a Now Playing surface; derive its points and colors from the brand, keep it behind content, not under body text. Purple/indigo-to-blue/pink blends are the signature of generated UI (`ai-gradient-palette`), and gradient-filled headline text (`gradient-text`) trades legibility for trend.

Decoration without a relationship to hierarchy, state, content, or the visual world is not a color strategy.

## Contrast and perception

| Content | Minimum |
|---|---|
| body text | 4.5:1 |
| large text (≥ 18 pt, or ≥ 14 pt bold) | 3:1 |
| controls, icons, focus indicators | 3:1 |

Check every pair in **both** appearances and with Increase Contrast on; `Color.resolve(in:)` (iOS 17+) gives the components for a quick computed check. Check pressed/disabled states, text on images and materials, and tinted buttons. Honor `@Environment(\.accessibilityDifferentiateWithoutColor)` where status is color-coded: add a symbol or label. Prefer explicit colors over stacks of translucent overlays whose contrast depends on what's behind them.

## Verify

- Every color has a stable role or a world-specific atmospheric purpose.
- Attention lands on the intended action, content, or state.
- The palette works across quiet, dense, interactive, error, and empty states.
- Light and dark are each composed; High Contrast variants exist for brand colors.
- Previews with `.environment(\.colorScheme, .dark)` and Simulator captures (`xcrun simctl ui <UDID> appearance dark`) both checked.
- The result is recognizably this product, not a generic "colorful" treatment.

When the palette earns its place, hand off to `/impeccable-swiftui polish` for the final pass.

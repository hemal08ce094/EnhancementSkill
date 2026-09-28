Generate a `DESIGN.md` at the project (or app target) root that captures the app's current visual system, so agents building new screens stay on-brand. This file owns the DESIGN.md format; every other reference points here.

DESIGN.md is prose with exact values in parentheses and the code names that hold them. **Code is the source of truth**: colorsets, `Color` / `ShapeStyle` extensions, `Font` roles, spacing and radius constants, styles. DESIGN.md describes them, names where they live, and states the rules for using them. It never defines a value the code doesn't have.

## When to run

- New-work found a coherent incumbent system but no DESIGN.md.
- The first build of a new visual world is done and its provisional decisions need recording.
- DESIGN.md is stale: the code has drifted from it.
- Before a large redesign, to capture the current state as reference.
- After `/impeccable-swiftui extract` consolidated the system.

If DESIGN.md exists, **don't silently overwrite it.** Show it, then ask (structured question tool when available, otherwise plain text and stop): refresh, overwrite, or merge.

## The format

### Front matter

```yaml
---
name: Trailhead
platforms: [iOS 18, iPadOS 18, watchOS 11]
updated: 2026-09-28
---
```

`name` is the product; `platforms` lists shipped platforms with minimum versions (from `context`); `updated` is the date of this write. Nothing else goes in front matter; tokens live in code.

### Sections, in this order, with these exact headings

1. `## Overview`: the atmosphere. A named North Star, 2–3 short paragraphs of personality, density, and philosophy, then **Key Characteristics** bullets.
2. `## Color`: semantic roles → asset or `Color` names, light and dark hex (and High Contrast where defined), contrast notes, tint.
3. `## Typography`: roles → system text style or custom face with its `relativeTo:` style, weights, design (`.rounded`, `.serif`, `.monospaced`), width, numeric treatment.
4. `## Spacing & Layout`: spacing scale constants, margins, size-class behavior, reading widths, grid columns, Duo and window behavior.
5. `## Shape & Depth`: corner radii (and whether `.continuous`), materials and Liquid Glass placement, shadows, borders, layering.
6. `## Motion`: named springs and durations, where each is used, Reduce Motion fallbacks.
7. `## Components`: button, toggle, and label styles; rows, cards, fields, navigation chrome; each with the code name and file it lives in.
8. `## Iconography`: SF Symbols weight, scale, rendering mode, variable values; custom symbols; app icon variants.
9. `## Haptics & Sound`: which `.sensoryFeedback` fires for which events; sounds, if any.
10. `## Platform Notes`: what changes per platform (iPad sidebar, Mac density, watch simplifications, visionOS glass).

Omit a section that genuinely doesn't apply rather than inventing rules. Keep the headings exact and the order fixed; tooling and other commands find sections by heading.

### Style rules

- **Descriptive first, exact second**: "Softly squared cards (16 pt, continuous)" beats "radius 16". Always the number in parentheses and the code name in backticks.
- **Where and why, not just what**: each value says where it's used and why.
- **Named Rules**: `**The [Name] Rule.** [short doctrine].` Memorable and citable: "The One Tint Rule. Evergreen marks what's tappable and nothing else." Aim for 1–3 in the sections that need them.
- **Decisive where the evidence is decisive**; softer for provisional guidance.
- **Group colors by role** (brand, surfaces, text, status), not by hue.
- **Visual only.** Product truth lives in PRODUCT.md; surface strategy lives in `.impeccable/surfaces/<name>.md`. Carry a PRODUCT.md line only when it's a durable constraint on the visual system (a required logo treatment, an accessibility commitment).

## Two paths

- **Scan mode** (default): the project has UI code. Extract, then confirm the descriptive language with the user.
- **Seed mode**: pre-implementation. Route through [new-work.md](new-work.md)'s world workshop and write a directional seed.

Scan first. If the scan finds no colorsets, no style extensions, no custom styles, and no screens beyond the template, offer seed mode; don't switch silently. A seed request doesn't authorize replacing a coherent incumbent system; offer scan mode, or route an explicit identity replacement through new-work.

## Scan mode

### Step 1: Find the system

Start from `context`'s design-system evidence, then read in this order:

1. **Asset catalogs**: every `*.colorset/Contents.json` in `*.xcassets` (name, Any/Dark/High Contrast components; convert `srgb` components to hex), `AccentColor`, image sets with dark variants, `AppIcon` (light/dark/tinted), custom symbol sets (`*.symbolset`).
2. **Color code**: `extension Color`, `extension ShapeStyle where Self == Color`, `extension UIColor`, palette enums. Note literals (`hardcoded-color` findings from `detect` show where the system is bypassed).
3. **Typography**: `extension Font`, `Font.custom(_:size:relativeTo:)` roles, `.fontDesign` / `.fontWidth` use, `UIAppFonts` in Info.plist and bundled font files, `@ScaledMetric` usage.
4. **Spacing and shape**: enums or constants named `Spacing`, `Metrics`, `Layout`, `Radius`, `Corner`; recurring literal paddings and radii (count them; the frequent ones are the de facto scale).
5. **Styles and modifiers**: `ButtonStyle`, `PrimitiveButtonStyle`, `LabelStyle`, `ToggleStyle`, `GroupBoxStyle`, `ProgressViewStyle`, custom `ViewModifier`s (`.cardStyle()`, `.sectionHeader()`), shared rows and cards.
6. **Motion**: `Animation` extensions and constants, `.spring(…)` / `.smooth` / `.snappy` use, `PhaseAnimator` / `KeyframeAnimator`, `matchedGeometryEffect`, `navigationTransition`, and where `accessibilityReduceMotion` is read.
7. **Haptics and icons**: `.sensoryFeedback` triggers, `UIImpactFeedbackGenerator` use; SF Symbol names, `.symbolRenderingMode`, `.fontWeight` on images, `.symbolEffect`.
8. **Rendered truth**: Simulator captures of 3–5 representative screens in light and dark (`.impeccable/shots/document/`). They catch values tokens miss and show which rules the code actually follows.

Delegating to the `impeccable-swiftui-documenter` agent is appropriate for a large app; give it this file and the project root.

### Step 2: Extract

- **Color**: one entry per role actually used, keyed by the code name. Light and dark hex from the colorset; compute contrast of text roles against their surfaces in both appearances and note any pair below 4.5:1. If the app has one accent, say so; don't invent secondary and tertiary.
- **Typography**: map each role to its text style or custom face; note `relativeTo:` for custom faces (and flag any without it: `custom-font-no-relative`), weight, design, and numeric treatment (`.monospacedDigit()`, `contentTransition(.numericText())`).
- **Spacing & Layout**: the scale as it exists; margins; how screens change between compact and regular width; reading width caps; Duo and multi-window behavior if shipped.
- **Shape & Depth**: radii with style, where materials and glass appear (chrome vs content), shadow vocabulary or "flat".
- **Motion, Components, Iconography, Haptics**: what exists, with code names and file paths.

Skip what the project doesn't have. One-off values are not tokens; record the reused ones.

### Step 3: Ask for the qualitative language

Atmosphere can't be extracted. Ask in at most two rounds of up to three questions, waiting between rounds, each with 2–3 concrete options grounded in PRODUCT.md and what you found:

- **North Star**: a named metaphor for the system ("The Field Notebook", "The Quiet Instrument", "The Night Market"). Offer 2–3.
- **Overview voice**: mood adjectives, the philosophy in two sentences, any confirmed anti-reference.
- **Color character**: descriptive names for key colors ("Evergreen", "Trail Dust", not "green500").
- **Depth philosophy**: flat, layered, or lifted; whether materials are chrome-only.
- **Component feel**: one phrase ("tactile and sure-footed" vs "precise and restrained").

Don't write the Overview until the user confirms the atmosphere language.

### Step 4: Write DESIGN.md

Record only what the build evidences. Two ways a rule goes wrong: a prohibition that bans something the world itself uses, and a value recorded to legitimize a defect. Never canonize a [craft-floor.md](craft-floor.md) refusal (eyebrow labels, emoji icons, glow shadows, gradient text, glass on content cards) into the system; list it under drift in your summary to the user instead.

### Step 5: Confirm

Show the full file. Call out the non-obvious choices (color names, North Star, Named Rules) and any drift you found but didn't canonize. Offer to revise a section or add components you missed. Your write is the freshest source; later commands in this session don't need a reload.

## Seed mode

PRODUCT.md is the prerequisite; without it, load [init.md](init.md) first. Then load [new-work.md](new-work.md), resolve the first surface (ask if none was named), and run its world workshop and commit. Stop after the seed DESIGN.md and the surface brief; don't implement. If new-work already ran the workshop this session, use its chosen direction without asking again.

Write the same sections in the same order, opening with:

```markdown
<!-- SEED: chosen with the user before implementation. Re-run /impeccable-swiftui document once there's code to record the real tokens and components. -->
```

Fill each section with the chosen direction stated as invariants. Mark unresolved values `[to be resolved during implementation]`; include hex, fonts, and radii only when the user or an existing asset established them. Omit `## Components` entirely; none exist yet. Then show the seed and tell the user to re-run `/impeccable-swiftui document` once there's code.

## Example

```markdown
---
name: Trailhead
platforms: [iOS 18, iPadOS 18, watchOS 11]
updated: 2026-09-28
---

# Design System: Trailhead

## Overview

**North Star: "The Field Notebook"**

Trailhead feels like a well-kept notebook carried on a hike: warm paper, confident ink, nothing ornamental. Density is moderate; maps and route data get room, chrome stays out of the way. Brand lives in the tint, the rounded numerals, and the terrain illustrations, never in decoration on surfaces.

**Key Characteristics:**
- One evergreen tint; everything else is paper and ink
- SF Pro for UI, SF Rounded for numbers that matter
- Flat content surfaces; materials only on bars and floating controls
- Motion is quick and settled, never bouncy

## Color

Warm neutrals with a single saturated voice.

### Brand
- **Evergreen** (`Color.brandTint` → `Evergreen` colorset; light #2F6B4F, dark #6FBF95): the app tint and `AccentColor`. Tappable things and the current selection only.

### Surfaces
- **Trail Paper** (`Color.surface` → `Surface`; light #FAF7F2, dark #161513): screen background. Never pure white or black.
- **Pack Canvas** (`Color.surfaceRaised` → `SurfaceRaised`; light #FFFFFF, dark #22201D): cards and grouped rows.

### Text
- Primary and secondary text use `.primary` / `.secondary` foreground styles over these surfaces (≥ 7:1 and ≥ 4.6:1 in both appearances). No opacity-based hierarchy.

### Status
- **Summit Red** (`Color.danger` → `Danger`; light #B3261E, dark #FF8A80; High Contrast #8C1D18 / #FFB4AB): destructive actions and errors, always paired with a symbol.

**The One Tint Rule.** Evergreen marks what's tappable and nothing else. Decoration never borrows it.

## Typography

System text styles throughout; one rounded accent.

- **Screen titles**: `.largeTitle`, bold, via `.navigationTitle`; inline titles on detail screens.
- **Section titles**: `.title3.weight(.semibold)` (`Font.sectionTitle` in `DesignSystem/Typography.swift`).
- **Body and rows**: `.body`; secondary lines `.subheadline` with `.secondary`.
- **Stats**: `Font.stat` = `.system(.title, design: .rounded, weight: .semibold)` with `.monospacedDigit()`; changes animate with `.contentTransition(.numericText())`.
- **Captions**: `.footnote`; nothing below `.caption` (11 pt at default size).

**The Numbers Speak Rule.** Distance, elevation, and time are the only rounded text. If it isn't a measurement, it's SF Pro.

## Spacing & Layout

- Scale (`Spacing` in `DesignSystem/Metrics.swift`): `xs` 4, `s` 8, `m` 12, `l` 16, `xl` 24, `xxl` 32. Screen margins come from the system (list insets, `.scenePadding()`).
- Compact width: single column, map above list. Regular width: `NavigationSplitView` with the route list as sidebar and the map as detail; an `.inspector` for filters.
- Reading content caps at 680 pt inside its column; the map always takes the rest.
- iPhone Duo (iOS 27.1): partially open splits map and itinerary with `ArrangementView(.split)` along the fold.

## Shape & Depth

- Radii (`Radius` in `Metrics.swift`), all `.continuous`: control 10, card 16, sheet uses the system default.
- Depth is tonal: Pack Canvas on Trail Paper. One shadow, `Shadow.lifted` (black 12%, radius 12, y 4), only on the floating record button.
- Materials: system bars and the floating map controls use `.regularMaterial` (iOS 26+: `.glassEffect()` behind `if #available`). Content cards are never glass.

**The Flat Paper Rule.** Content never floats. Only controls that sit over the map get material or shadow.

## Motion

- `Motion.settle` = `.spring(duration: 0.35, bounce: 0.1)`: state changes, card expansion.
- `Motion.quick` = `.snappy(duration: 0.2)`: toggles and selection.
- Route detail opens with `.navigationTransition(.zoom(sourceID:in:))` from its card.
- Reduce Motion: zoom becomes the default push; springs become `.easeInOut(duration: 0.2)` crossfades. Read in `MotionModifier.swift`.

## Components

- **Primary button**: `.buttonStyle(.trailPrimary)` (`DesignSystem/Styles/TrailButtonStyle.swift`): Evergreen fill, white `.headline` label, 50 pt min height, control radius, scales to 0.97 on press. One per screen.
- **Secondary button**: system `.bordered` with Evergreen tint.
- **Route row**: `RouteRow` (`Components/RouteRow.swift`): thumbnail, name, stat line; combines into one accessibility element; switches to a vertical stack at accessibility sizes.
- **Card**: `.cardSurface()` modifier: Pack Canvas, card radius, `Spacing.l` padding, no border.
- **Fields**: system `Form` rows; errors appear in the section footer in Summit Red with an exclamation symbol.
- **Navigation**: tab bar (Explore, Record, Profile) on iPhone; sidebar-adaptable on iPad.

## Iconography

SF Symbols only, `.medium` weight to match body text, `.hierarchical` rendering. Custom symbols `trail.fill` and `summit` in `Symbols.xcassets`, exported from the SF Symbols template with all weights. App icon ships light, dark, and tinted variants.

## Haptics & Sound

- `.sensoryFeedback(.success, trigger:)` when a recording saves.
- `.sensoryFeedback(.selection, trigger:)` on segmented and filter changes.
- `.sensoryFeedback(.warning, trigger:)` when GPS signal drops during recording.
- No custom sounds.

## Platform Notes

- **iPadOS**: sidebar-adaptable tabs, inspector for filters, ⌘R starts recording, hover lift on route cards.
- **watchOS**: record and stats only; stats use `Font.stat` at `.title2`; always-on dims the map to outlines (`isLuminanceReduced`).
```

## Pitfalls

- Don't record a value the code doesn't have, or two values for one role.
- Don't paste raw code in prose; name the symbol and describe it.
- Don't document every literal. Stop at what's reused.
- Don't invent components, sections' content, or platforms that don't ship.
- Don't rename or reorder sections.
- Don't duplicate PRODUCT.md; DESIGN.md is strictly visual.
- Don't overwrite an existing DESIGN.md without asking.

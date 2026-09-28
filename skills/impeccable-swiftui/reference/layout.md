Layout turns product priority into reading order, grouping, rhythm, and usable space. Diagnose the structural problem before moving views.

---

## Visitor mode

- **Persuade + Experience:** composition may be asymmetric, full-bleed, or deliberately paced when the selected world earns it.
- **Operate + Read:** predictable structure, stable density, and system containers (`List`, `Form`, `Table`, `NavigationSplitView`) are affordances.
- **Platform:** follow the platform file ([platforms/ios.md](platforms/ios.md), [platforms/ipados.md](platforms/ipados.md), [platforms/macos.md](platforms/macos.md), ...) for navigation, safe areas, size classes, and targets.

Preserve the established visual world. A layout command changes structure inside it; identity replacement belongs to [new-work.md](new-work.md).

## Two isolated assessments

When a sub-agent tool is available and permitted, run these independently; otherwise run them yourself in this order.

1. **Layout assessment:** inspect representative states on the smallest and largest supported devices. Answer each with a capture or source evidence:
   - **Reading order:** squint at a capture. Can you still find the primary element, the secondary, and the major groups, in order?
   - **Grouping:** are related items close and groups separated, or are cards compensating for weak proximity?
   - **Rhythm:** do tight and generous intervals create cadence, or is `.padding()` repeated until everything weighs the same?
   - **Structure:** does the topology match the task? Are those repeated cards genuinely equivalent, or a grid of rounded rectangles because it was easy?
   - **Density:** does information per screen fit use frequency and decision complexity?
   - **Adaptation:** in compact and regular width, Split View and Slide Over on iPad, a resized Mac window, landscape, AX Dynamic Type: what reflows, collapses, scrolls, or stays fixed? Does VoiceOver order still match visual order?
   - **Extremes:** long content, empty states, keyboards, sheets, safe areas, the Dynamic Island, and small targets.
2. **Mechanical scan:**

```bash
<skill-base-dir>/scripts/impeccable-swiftui detect --json <target files or dirs>
```

Layout-relevant rules: `screen-bounds-layout`, `small-touch-target`, `over-rounded`, `side-stripe`, `numbered-section`, `hidden-nav-bar`, `deprecated-api` (`edgesIgnoringSafeArea`, `NavigationView`). Keep the scan out of the first assessment, then synthesize. A clean scan cannot prove hierarchy or rhythm.

## Set the spatial thesis

Before editing, name the primary reading or task path, what belongs together and what separates, which element leads, the intended density and rhythm, and how the structure changes across size classes, input modes, and content extremes. Choose the simplest structure that expresses those relationships.

## Apply

### Spacing
- **One scale, named.** A 4-pt base gives the useful middle steps an 8-only scale misses. Define it once; scale it with Dynamic Type where it sits beside text.

```swift
enum Space { static let xs: CGFloat = 4, s: CGFloat = 8, m: CGFloat = 12, l: CGFloat = 16, xl: CGFloat = 24, xxl: CGFloat = 40 }
@ScaledMetric(relativeTo: .body) private var rowGap = Space.m
```

- **Stack `spacing:` for sibling rhythm**, padding for insets. Explicit `spacing:` beats the default's per-pair guess when rhythm matters.
- **Margins come from the system.** `.contentMargins(_:for:)` and `.safeAreaPadding` (iOS 17+), `.scenePadding()`, and the readable content guide for text on wide screens.

### Safe areas
- Content lives inside the safe area; backgrounds may bleed: `.background(Color.canvas.ignoresSafeArea())`, not `.ignoresSafeArea()` on the content stack.
- Pin floating actions and bars with `.safeAreaInset(edge: .bottom) { … }` so scroll content insets correctly, instead of a `ZStack` overlay that covers the last row.
- Never compute from `UIScreen.main.bounds` (`screen-bounds-layout`); it's wrong in Split View, Stage Manager, external displays and multi-window.

### Structure
- **Group by meaning.** Proximity and section headers before containers.
- **System containers first.** `List` with `.insetGrouped` / `.plain` / `.sidebar`, `Form` with `.formStyle(.grouped)`, `LabeledContent` for label-value rows, `.listSectionSpacing(.compact)` (iOS 17+) when sections crowd. They bring separators, swipe actions, selection, editing and accessibility for free.
- **`Grid` / `GridRow`** for aligned label-value or stat tables; `.gridCellColumns` to span. `LazyVGrid` with `.adaptive(minimum:)` for collections.
- **Alignment guides** for optical and cross-stack alignment: `.alignmentGuide(.firstTextBaseline)`, `HStack(alignment: .firstTextBaseline)`, or a custom `AlignmentID` to line up values across rows.
- **`Layout` protocol** when a real custom arrangement recurs (flow of tags, radial menu), rather than `GeometryReader` math inside a view.
- **`GeometryReader` only when needed**; prefer `containerRelativeFrame`, `onGeometryChange(for:of:action:)`, or a `Layout`.

### Adaptation
- **Branch on real space, not device.** `horizontalSizeClass`, `ViewThatFits(in: .horizontal)` to choose between arrangements, `AnyLayout` to switch `HStackLayout` ⇄ `VStackLayout` without losing state.
- **No phone column centered in a wide window.** On iPad and Mac use `NavigationSplitView`, multi-column grids, inspectors (`.inspector`, iOS 17+), or a readable-width text column beside real secondary content.
- **Carousels and pagers**: `containerRelativeFrame(.horizontal, count: 3, span: 2, spacing: Space.l)` sizes items to the scroll container; `.scrollTargetBehavior(.viewAligned)` with `.scrollTargetLayout()` (or `.paging`) snaps them (iOS 17+). Use them when items are browsed, not when they must be compared.
- Keep targets 44×44 pt even when the visible mark is smaller: `.frame(minWidth: 44, minHeight: 44)` plus `.contentShape(.rect)` (`small-touch-target`).

### Avoid card soup
A screen of rounded rectangles each holding one fact is not a layout. Cards are for independent, movable, or tappable units. Otherwise use rows, sections, dividers and space. Never nest cards; keep one radius per level with `.continuous` corners and radii in the system scale (`over-rounded`); drop leading color stripes (`side-stripe`) and `"01"`/`"02"` section numbering (`numbered-section`). Materials are for chrome, not every card (`glass-by-default`).

Variation is not a goal. Repetition supports recognition; break it only when content or priority changes. Use depth only when it clarifies state or hierarchy.

## Verify

- Squint test still reveals primary, secondary, and groups in order.
- Captured on the smallest and largest supported devices, landscape, iPad split widths, and a resized Mac window where applicable (`#Preview(traits: .landscapeLeft)`, Simulator for truth, stored in `.impeccable/shots/`).
- AX Dynamic Type, long localized strings, empty and loading (`.redacted(reason: .placeholder)`) states don't break the structure.
- Keyboard appearance doesn't cover the focused field or primary action.
- VoiceOver and keyboard focus order match visual order.
- The final scan has no unexplained findings.

Answer each item with rendered or source evidence, then rerun the scan. Do not substitute a bare "yes" for verification.

When the structure holds, hand off to `/impeccable-swiftui polish`.

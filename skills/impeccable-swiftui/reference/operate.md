# Operate mode depth (and Read notes)

When design SERVES the product: most app screens, lists, detail views, editors, dashboards, settings, forms, inboxes, tools, anything where the person is in a task. The essentials live in SKILL.md's modes and [craft-floor.md](craft-floor.md); this file is extended depth for Operate screens. Read screens (articles, help, release notes, reading apps) take SKILL.md's Read mode plus this file's typography and consistency rules and the Read notes at the end; measure and navigation matter more there than density.

## The product slop test

Familiarity is a feature here. The test is whether a person fluent in the platform can trust the screen immediately, or has to pause at every subtly-off control.

App UI's failure mode isn't flatness, it's strangeness without purpose: over-decorated buttons, a hand-rolled toggle next to a system one, gratuitous springs, a display face on row labels, invented gestures for standard tasks. The bar is earned familiarity. The app should disappear into the task.

## Typography

- **One family is usually right.** SF carries titles, buttons, labels, body, and data. Operate screens don't need a display/body pairing; a brand face, if any, stays in titles and hero moments.
- **The text-style ramp is the scale.** `.largeTitle` through `.caption2` already scale with Dynamic Type and step at a product-appropriate ratio. Emphasis within a style comes from `.weight` or `.bold()`, not a custom size. A custom ramp is a `Font` extension built on `relativeTo:`, defined once.
- **Density is fine; truncation is not.** Rows can be tight at default sizes, but they must reflow, not clip, at accessibility sizes. Tables (`Table` on iPad and Mac) and dense data can run long lines; prose still holds 65–75 characters.
- **Numbers are data.** `.monospacedDigit()` in columns and counters, `Text(value, format:)` with the right `FormatStyle` for currency, dates, and measurements. Never hand-format a number.

## Color

Operate defaults to Restrained. A single screen can earn Committed (a dashboard where one category color carries a report, a welcome screen drenched in the brand), but Restrained is the floor.

- A state-rich semantic vocabulary: pressed, focused, selected, disabled, loading, error, warning, success. Define each once as a named color or `ShapeStyle` and reuse it.
- The tint is for primary actions, current selection, and state indicators only, not decoration. One tint per app; a second accent needs a reason.
- A second neutral layer for sidebars, inspectors, grouped backgrounds, and toolbars: use the system's (`systemGroupedBackground`, `secondarySystemBackground`, sidebar list style) before inventing one, and let materials sit under bars only.

## Layout

- Adaptivity is structural, not scaling: `NavigationSplitView` columns collapse to a stack in compact width, grids change column count, toolbars move items into menus, `ViewThatFits` swaps a row for a stack. Branch on `horizontalSizeClass` or the real container size, never on the device model.
- `List` and `Form` before custom stacks for anything row-shaped; they bring insets, separators, swipe actions, selection, editing, and accessibility for free.

## Components

Every interactive component has: default, pressed, focused, disabled, selected, loading, error. Don't ship with half of these.

- Skeletons for loading: `.redacted(reason: .placeholder)` over the real row layout, not a spinner in the middle of the screen.
- Empty states that teach the screen and offer its first action (`ContentUnavailableView` with an actions closure on iOS 17+), not "No items."
- Consistent affordances across the app: one primary `ButtonStyle`, one form-control vocabulary, one SF Symbols weight and rendering mode.
- Overlays escape their container. A hand-positioned `.overlay` dropdown inside a `ScrollView` or a `.clipped()` card gets cut off; reach for `Menu`, `.popover` (with `.presentationCompactAdaptation(.popover)` on iOS 16.4+ when it should stay a popover on iPhone), `.contextMenu`, or a sheet with `.presentationDetents`.
- Search is `.searchable` with suggestions and scopes, not a text field glued above a list.

## Motion

- Quick: `.snappy` or `.smooth(duration: 0.25)` for most state changes. People are in flow; don't make them wait for choreography.
- Motion conveys state, not decoration: a change, feedback, loading, a reveal. Nothing else. `.contentTransition(.numericText())` for values, `.symbolEffect` for symbol state, `withAnimation` around the state change so the whole screen agrees.
- No orchestrated launch sequences or splash animations. The app opens into the task; nobody wants to watch it load.

## Product constraints

- Decorative motion that doesn't convey state.
- Inconsistent component vocabulary across screens. If "Save" looks different in two places, one is wrong.
- Display faces in labels, buttons, rows, or data.
- Reinventing standard controls for flavor: custom toggles, pickers, segmented controls, alerts, back buttons, pull-to-refresh.
- Heavy color or full saturation on inactive states: unselected tabs, disabled buttons, idle rows.
- A sheet as first thought. Exhaust inline editing, a pushed view, a popover, or an undoable action first.

## Product permissions

Operate screens can afford things Persuade screens can't.

- SF everywhere and the system type ramp untouched.
- Standard structures: tab bar, navigation stack, sidebar, toolbar, inspector, `Table`, `Form`, `.searchable`, menu-bar commands on iPad and Mac.
- Density. Long lists, dense rows, many labels, when the person needs them.
- Consistency over surprise. The same vocabulary screen to screen is a virtue; delight is saved for moments (a completion haptic, a matched transition), not screens.

## Read notes

- Reading type: body at `.body` or one step up, New York (`.fontDesign(.serif)`) or a bundled text face with `relativeTo: .body`, `.lineSpacing` a touch above default, measure capped at 65–75 characters on wide windows.
- Reader controls respect Dynamic Type first; an in-app size setting layers on top with `.dynamicTypeSize`, never replaces it.
- Long-form text is selectable (`.textSelection(.enabled)`), links are real (`Text` with Markdown or `AttributedString`, `.environment(\.openURL, …)` to route them), headings are VoiceOver headings.
- Position persists: restore scroll with `.scrollPosition(id:)` (iOS 17+) or `ScrollViewReader`, so returning to an article lands where they left.
- Chrome recedes while reading: `.tabBarMinimizeBehavior(.onScrollDown)` (iOS 26+) or hiding bars on scroll is a choice for reading apps, never for task screens.

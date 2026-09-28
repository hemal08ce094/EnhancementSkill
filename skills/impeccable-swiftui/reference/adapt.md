> **Additional context needed**: target platforms and devices, and usage contexts.

Adapt an existing SwiftUI design to a different context: another size class, window size, orientation, posture, device, platform, or input method. The trap is treating adaptation as scaling. The job is rethinking the experience for the new context, inside that platform's conventions. Read the target's platform reference first if Setup hasn't: [platforms/ios.md](platforms/ios.md), [platforms/ipados.md](platforms/ipados.md), [platforms/macos.md](platforms/macos.md), [platforms/watchos.md](platforms/watchos.md), [platforms/visionos.md](platforms/visionos.md).

## Assess the Adaptation

1. **Source context**: what was it built for, and what did it assume? Portrait iPhone only? Touch only? A fixed width? A website being ported?
2. **Target context**: device class, window size range (an iPad window can be phone-narrow), orientation, posture (Duo folded, partially open, flat), input (touch, keyboard, pointer, trackpad, gaze and pinch, Digital Crown), and usage posture (one-handed on the move, two-handed at rest, at a desk, glancing at a wrist, standing in a room).
3. **What breaks**: navigation that doesn't fit, layouts that stretch instead of restructure, gestures and controls that don't exist there, content under a fold or a camera, text that can't grow.

**CRITICAL**: restructure, don't stretch. A scaled-up phone UI on iPad or Mac is the failure mode, and so is a centered phone column floating on a wide window.

## Drive layout from real size, never device checks

Branch on what the view actually has, not on what device you think it's on. `UIDevice.current.userInterfaceIdiom == .pad` is wrong the moment an iPad window is narrow; `UIScreen.main.bounds` is wrong in every multitasking and multi-window case (`screen-bounds-layout`).

- **Size classes** for structure: `@Environment(\.horizontalSizeClass)` / `verticalSizeClass`. Compact vs regular chooses stack vs split, tab bar vs sidebar, sheet vs popover.
- **`ViewThatFits`** when content decides: `ViewThatFits(in: .horizontal) { HStack { … } ; VStack { … } }`.
- **`AnyLayout`** to switch between `HStackLayout`, `VStackLayout`, and `GridLayout` while preserving child identity and animating the change.
- **`containerRelativeFrame`** for sizes relative to the scroll view or window (`.containerRelativeFrame(.horizontal, count: columns, span: 1, spacing: 16)`), not `GeometryReader`.
- **`GeometryReader`** or `.onGeometryChange(for:of:action:)` only when a value truly depends on measured size (column count from width). Never wrap whole screens in it.
- **Custom `Layout`** when a recurring arrangement has rules no stack expresses.
- Content width: readable measure caps with `.frame(maxWidth: 700)` belong to *reading* columns inside a structure that uses the rest of the width (sidebar, inspector, supplementary column), not to the whole screen.

## Adaptation Strategies

### iPhone → iPad

- **Navigation changes shape.** List-detail content moves to `NavigationSplitView` (two or three columns); on iOS 18+, `TabView` with `.tabViewStyle(.sidebarAdaptable)` turns a tab bar into a sidebar in regular width. Keep one navigation model; change its presentation.
- **Use the width**: detail beside list, `.inspector` for secondary controls, multi-column `LazyVGrid` with adaptive columns (`GridItem(.adaptive(minimum: 160))`), popovers where the phone used sheets (`.popover` degrades to a sheet in compact width automatically).
- **Windows, not screens.** iPadOS 26 makes every app's windows freely resizable; Split View, Slide Over, and Stage Manager can hand you a compact-width window on a 13-inch display. Test the full range from phone-narrow to full-screen landscape. Don't set `UIRequiresFullScreen` to dodge it.
- **Multiple windows**: `WindowGroup` supports them by default; per-window state lives in `@SceneStorage` and scene-scoped models, not singletons. `openWindow(value:)` for opening an item in its own window.
- **Keyboard and pointer**: `.keyboardShortcut` for primary actions (hold ⌘ shows them), `@FocusState` and `.focusable()` for keyboard navigation, `.hoverEffect(.highlight)` or `.lift` on custom tappable surfaces, `.contextMenu` for secondary actions, drag and drop (`.draggable`, `.dropDestination`).

### iPhone Duo (iOS 27.1)

Duo has a compact outer display and a large inner display that is **one continuous screen** with a hinge down the middle, not two screens. When partially open, the fold is a reserved region content must respect.

- **Closed** (outer display): the iPhone layout, compact width.
- **Fully open** (inner display): a regular-width canvas. No centered phone column; use the width as on iPad (split, sidebar, grid).
- **Partially open**: the fold becomes an active `.division` reserved region. Keep text, controls, and faces out of it; split content along it.

```swift
if #available(iOS 27.1, *) {
    ArrangementView {
        TripMap()                      // primary
    } secondary: {
        TripItinerary()
    }
    .arrangementViewStyle(.split)      // .overlay or .automatic when primary should dominate
}
```

- `ArrangementView` is the system two-pane container that respects the fold: `.split` places panes side by side and adapts its axis; `.overlay` stacks until partially folded, then separates. Keep `NavigationStack` / `NavigationSplitView` **outside** it, and don't nest it in scroll views or lists.
- For custom layouts, read the fold: `GeometryReader { proxy in … proxy.reservedRegions(kind: .division) }` returns `ReservedRegion`s with `frame`, `margins`, and `isActive`; `.occlusion` regions mark cameras.
- React to posture with `.onHingeChange { old, new in … }`; `DeviceHinge` gives `status` (`.closed`, `.partiallyOpen`, `.fullyOpen`) and `angle`. Prefer `status`; angle updates follow system policy and aren't meant for continuous input unless that *is* the feature.
- Bars can move to the side on Duo; don't hard-code bottom-anchored chrome positions.
- Grids use even column counts so they split cleanly at the fold. Don't letterbox; change aspect instead.
- Gate every Duo API with `if #available(iOS 27.1, *)`. Add a DEBUG launch argument that fakes a posture so Simulator captures and UI tests don't depend on manual pose switching.

### Orientation

Landscape restructures: side-by-side panes, controls moved to the trailing edge, media full-bleed. Never clip or letterbox. Lock orientation only when the task truly demands it (a camera capture UI, a game), and then fill the screen in every supported orientation. Watch the keyboard in landscape: it can cover most of the height.

### iPad → Mac

- **Mac Catalyst** is a reasonable route for an iPad-first app: turn on **Optimize Interface for Mac** so controls render at Mac size and scale, then add a real menu bar (`.commands { CommandGroup … }`), a `Settings` scene, window sizing (`.defaultSize`, `.windowResizability`), and keyboard shortcuts for everything in menus.
- **Native macOS SwiftUI** when the Mac experience should be first-class: `Table` for dense data, `NavigationSplitView` with a source-list sidebar, `.toolbar` in the window, `MenuBarExtra` for glanceable utilities, `.onHover` and `.help("…")` tooltips, right-click `.contextMenu`, multi-select with ⇧ and ⌘.
- Density rises on Mac: smaller controls (`.controlSize(.small)` where appropriate), tighter rows, more visible information, less progressive disclosure. Hover is available but never the only path.
- Don't ship iOS idioms unchanged: no tab bar at the bottom of a Mac window, no full-screen modal sheets for small edits, no swipe-only actions.

### iPhone → Apple Watch

Rethink, don't shrink. One glanceable fact or one quick action per screen; sessions last seconds.

- `NavigationStack` with short lists; vertical paging `TabView` (`.tabViewStyle(.verticalPage)`) for peer screens.
- Digital Crown for scrolling and value input (`.digitalCrownRotation`); large, full-width buttons; SF Compact via the system text styles.
- Move depth to the phone. Complications and Smart Stack widgets are often the real product on the wrist.
- Always-on: dim and simplify with `@Environment(\.isLuminanceReduced)`.

### iPad / iPhone → visionOS

- Windows float in the room on glass: `.glassBackgroundEffect()` is the default window material; don't paint opaque full-bleed backgrounds.
- Targets are 60 pt minimum; eyes need space. Every custom interactive surface gets `.hoverEffect()` (gaze highlight).
- Secondary controls go in **ornaments** (`.ornament(attachmentAnchor:)`) or the toolbar, not crowded into the window.
- Depth is meaningful, not decorative: `.offset(z:)` and volumes (`.windowStyle(.volumetric)`) only when 3D content earns it; immersive spaces for experiences that need the room.
- Text sits on glass: favor vibrant, semantic foreground styles over custom colors; test legibility against varied backgrounds.

### Web → native (porting a site or web app)

Reconform, don't reflow. Replace web navigation with the platform's model, HTML-shaped controls with system controls, hover affordances with touch-first ones, px type with Dynamic Type text styles, and "pages" with a navigation hierarchy. Then hold the result to the full platform reference; its slop test is the acceptance bar.

## Input and keyboard handling everywhere

- Software keyboard: SwiftUI avoids it for focused fields; composers pin with `.safeAreaInset(edge: .bottom)`, scroll views use `.scrollDismissesKeyboard(.interactively)`, and a keyboard toolbar (`ToolbarItemGroup(placement: .keyboard)`) carries Done or field navigation where return can't. Use `.ignoresSafeArea(.keyboard)` only on backgrounds.
- Hardware keyboard on iPad, Mac, and visionOS: shortcuts, `@FocusState` traversal, `.onKeyPress` for custom key handling, `.focusEffectDisabled()` only when you draw your own focus.
- Pointer on iPad and Mac: hover effects, context menus, tooltips on Mac, drag and drop.

## Implement & Verify

- Drive structure from size classes, `ViewThatFits`, and measured size, never device-model checks.
- Respect safe areas and reserved regions in every configuration: Dynamic Island, home indicator, keyboard, Duo's fold and cameras, Mac window toolbar.
- Preview the matrix fast: `#Preview(traits: .landscapeLeft)`, `.environment(\.horizontalSizeClass, .compact)`, `.dynamicTypeSize(.accessibility3)`.
- Then the Simulator for truth, captures into `.impeccable/shots/adapt-<target>/`: at least one iPhone, one iPad (full screen and a narrow window), the Duo simulator in each pose when Duo ships, and a Mac window at its minimum and a wide size. `xcrun simctl io <UDID> screenshot <path>`; `screencapture -l <windowID> <path>` for Mac.
- Hardware for posture, gestures, pointer feel, and performance. Say which evidence came from Previews, the Simulator, or hardware, and name what stayed untested.

**NEVER**:
- Ship a stretched phone layout, or a centered phone column, on a wide window
- Branch on device idiom or `UIScreen.main.bounds` for layout
- Put text or controls in Duo's fold region when partially open
- Transplant iOS idioms onto Mac, watchOS, or visionOS unchanged
- Hide core functionality on smaller sizes (if it matters, make it work)
- Lock orientation or require full screen to dodge a layout bug
- Trust Previews or the Simulator alone for gestures, posture, and feel

When the adaptation feels native to each context, hand off to `/impeccable-swiftui polish` for the final pass.

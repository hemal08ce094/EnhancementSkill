# macOS

For SwiftUI apps on the Mac, including Mac Catalyst and "Designed for iPad" builds that ship to the Mac.

## The Mac slop test

Would a longtime Mac user trust this app, or feel a phone app in a window? The tells: giant touch-sized controls, a tab bar, sheets for everything, no menu bar commands, no keyboard shortcuts, a window that can't resize or remembers nothing, content that ignores the pointer, settings inside the main window. The Mac user drives with keyboard and pointer, runs many windows, and expects the menu bar to be the manual.

## Structure

- **Windows are the unit.** `WindowGroup` for documents or multiple instances, `Window` for a single utility window, `DocumentGroup` for document apps, `MenuBarExtra` for menu bar utilities. Open with `@Environment(\.openWindow)`.
- **Sidebar + content (+ inspector).** `NavigationSplitView` with a sidebar list is the default shape; `.inspector` (macOS 14+) on the trailing edge for properties. No tab bar for top-level navigation; `TabView` is for preference panes and small grouped content.
- **Size the window.** `.defaultSize(width:height:)`, `.frame(minWidth:minHeight:)` on the root, `.windowResizability(.contentMinSize)` or `.contentSize` where it truly shouldn't grow. Every size between min and full screen must look composed.
- **Settings is a scene.** `Settings { … }` gives ⌘, and the standard window; a `TabView` of `Form`s with `.formStyle(.grouped)` inside it. Never a settings screen in the sidebar.
- **Toolbars.** `.toolbar` with `.primaryAction`, `.navigation`, `.principal` placements; `.toolbar(id:)` makes it customizable. `.searchable` lands in the toolbar. Choose `.windowToolbarStyle(.unified)` or `.unifiedCompact` deliberately.

## Menus & commands

- **The menu bar is complete.** Every action reachable from a menu: `.commands { CommandMenu("…") { … }; CommandGroup(replacing: .newItem) { … } }`. Standard groups (`.sidebar`, `.toolbar`, `.textEditing`) with `SidebarCommands()`, `ToolbarCommands()`, `TextEditingCommands()`.
- **Commands target the focused window** through `@FocusedValue` / `.focusedSceneValue`, and disable themselves when they don't apply.
- **Shortcuts** via `.keyboardShortcut` on the standard keys (⌘N, ⌘O, ⌘S, ⌘W, ⌘F, ⌘Z, ⌘⇧Z, ⌘,, Delete). Don't reassign system shortcuts.
- **Context menus** (`.contextMenu`) on every selectable item, mirroring the menu bar's verbs.

## Controls & density

- **Mac density.** Regular control size is the default and smaller than iOS; `.controlSize(.small)` for inspectors and dense toolbars, `.large` only for a hero action. Rows around 24–28 pt, not 44.
- **Native controls.** `Table` with sortable columns, `List` with selection (`List(selection:)`, multi-select with ⌘/⇧), `Picker` as pop-up, `Toggle` as checkbox (`.toggleStyle(.checkbox)`) in forms, `Stepper`, `ColorPicker`, `DatePicker`. `.buttonStyle(.borderedProminent)` is for the default action only; `.keyboardShortcut(.defaultAction)` gives Return.
- **Tooltips:** `.help("…")` on every icon-only control.

## Pointer & keyboard

- **Hover is real.** `.onHover` reveals row actions and previews; `.pointerStyle` (macOS 15+) for resize handles and link cursors. Nothing essential lives only on hover.
- **Keyboard focus.** `@FocusState`, `.focusable()`, `.onKeyPress` (macOS 14+), `.defaultFocus`; Tab walks fields when Full Keyboard Access is on, focus rings stay visible. Arrow keys move selection in lists and grids; Space previews; Escape cancels.
- **Drag and drop** in and out of the app (`.draggable`, `.dropDestination`, file promises) is part of the Mac contract.

## Type, color & materials

- **Text styles still apply**; the Mac body is 13 pt. `.font(.body)` everywhere, no iOS-sized 17 pt custom body. Mac text doesn't scale with Dynamic Type the way iOS does, so never assume the user can enlarge a too-small custom size.
- **System colors and the accent.** Respect the user's accent and highlight colors: use `.tint`/`Color.accentColor` for selection and prominent actions and leave the user's choice visible.
- **Materials.** The sidebar and toolbar take the system material automatically; on macOS 26 windows gain Liquid Glass chrome. Content stays opaque on `.background` or the window's background; `.containerBackground(for: .window)` (macOS 15+) for a deliberate translucent window.
- Light, dark, and "Increase contrast" all ship.

## Motion

- Restraint. Mac motion is fast and small: `.snappy` for state changes, system window and sheet animations, no bouncing panels. Honor Reduce Motion.

## Verifying the build

- `xcodebuild -scheme <S> -destination 'platform=macOS' build`, run the app, and capture the window with `screencapture -l <windowid> .impeccable/shots/<name>.png` (get the id from the window list, or `screencapture -w` interactively).
- Capture at minimum and at a large window size, light and dark, and with the sidebar collapsed.
- Check the menu bar by opening each menu; check keyboard-only operation once with Full Keyboard Access.

# iPadOS

For SwiftUI apps on iPad, and for the unfolded iPhone Duo. Load with [ios.md](ios.md); everything there applies unless this file overrides it.

## The iPad slop test

Is this an iPad app, or an iPhone app with more margin? The tells: a phone-width column centered in a wide window, a tab bar with nothing behind it, sheets where a popover or inspector belongs, no pointer or keyboard story, a layout that breaks when the window is resized. iPad users bring a keyboard, a trackpad, and a Pencil; the app should notice.

## Layout & structure

- **Restructure, don't stretch.** Branch on `horizontalSizeClass` and the real container size, never the device model. A regular-width screen gets columns, a grid that adds columns, an inspector; a compact one gets the stack. Never center a phone column on a wide window.
- **Sidebars carry the app.** `NavigationSplitView` (two or three columns) for hierarchical content; on iOS 18+ `TabView` with `.tabViewStyle(.sidebarAdaptable)` and `TabSection` gives a tab bar that becomes a sidebar, user-customizable via `.tabViewCustomization`. Size columns with `.navigationSplitViewColumnWidth(min:ideal:max:)`.
- **Inspectors, not sheets, for properties.** `.inspector(isPresented:)` (iOS 17+) sits beside content in regular width and becomes a sheet in compact.
- **Popovers where the phone used sheets.** `.popover` anchored to its control for pickers, filters, and quick edits.
- **Readable width.** Prose and forms cap their measure (`.frame(maxWidth:)` around 600–700 pt) inside a wide column; backgrounds still run edge to edge.

## Windows & multitasking

- **Every size is a real size.** iPadOS 26 windows resize freely; Split View and Slide Over hand you a phone-width window on a 13-inch screen. Size-class-driven layout handles all of them; test compact, a narrow regular, half, and full.
- **Multiple windows** when documents or conversations are independent: `WindowGroup(for:)` with `@Environment(\.openWindow)`, and `UIApplicationSupportsMultipleScenes` in Info.plist. Scene state in `@SceneStorage`.
- **Menu bar.** On iPadOS 26 the app's `.commands` appear in the menu bar; give real commands (`CommandMenu`, `CommandGroup(replacing:)`) with keyboard shortcuts rather than leaving it empty.

## Pointer & keyboard

- **Pointer:** controls get `.hoverEffect(.highlight)` or `.hoverEffect(.lift)`; system buttons and list rows already do. Custom tappable views need a `.contentShape(.hoverEffect, …)` that matches their visual shape.
- **Keyboard:** `.keyboardShortcut` on primary actions (⌘N, ⌘F, ⌘Return, Escape to cancel); `@FocusState`, `.focusable()`, and `.onKeyPress` (iOS 17+) for list and grid navigation with the arrow keys. Tab moves through fields in order.
- **Right-click** is `.contextMenu`; drag and drop is `.draggable` / `.dropDestination` between your views and other apps. Both are expected, not extra.
- **Pencil:** PencilKit for ink, `.onPencilDoubleTap` and `.onPencilSqueeze` (iOS 17.5+) for tool switching. Pencil input never replaces touch for a core action.

## Type & color

- Same Dynamic Type and semantic color rules as iPhone. Larger canvases tempt larger custom sizes; the text styles already suit the distance.
- Sidebars use the sidebar list style and its material; don't paint them.

## iPhone Duo (iOS 27.1+)

The unfolded Duo is one continuous inner display with a reserved fold region, not two screens. Gate everything with `if #available(iOS 27.1, *)`.

- **Posture:** `DeviceHinge` reports `status` (`.closed`, `.partiallyOpen`, `.fullyOpen`) and `angle`; react with `.onHingeChange { old, new in … }`. Partially open is tabletop or tent: controls on the lower half, content on the upper.
- **The fold:** `GeometryProxy.reservedRegions(kind: .division)` for the crease, `.occlusion` for hardware cutouts. No text, controls, or faces across the division; imagery may span it.
- **Two panes, one app:** `ArrangementView { primary } secondary: { … }` with `.arrangementViewStyle(.split)`, `.overlay`, or `.automatic` puts list/detail or canvas/tools on either side of the fold.
- **Same rule as iPad:** branch on real size; no centered phone column when open.

## Verifying the build

- Capture at least one 11-inch and one 13-inch iPad, full screen and a narrow window, landscape and portrait: `xcrun simctl io <UDID> screenshot .impeccable/shots/<name>.png`.
- Previews: `#Preview(traits: .landscapeLeft)` and a compact-width preview catch the collapse from split to stack.
- Pointer, keyboard, Pencil, and fold posture need hardware or a connected keyboard and trackpad in the Simulator; say which produced the evidence.

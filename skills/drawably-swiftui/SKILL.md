---
name: drawably-swiftui
description: Apply the Drawably hand-drawn look (the SwiftUI port of the drawably npm library, github.com/hemal08ce094/DrawablySwiftUI) to an iOS/macOS SwiftUI project — add the package, theme it, and convert buttons, toggles, checkboxes, fields, pickers, cards, badges, lists, dividers and text emphasis into boiling pen-sketch controls. Use when the user asks to make an app (or a screen, onboarding, paywall, empty state) look hand-drawn, sketchy, doodled, pen-drawn, "drawably", or to apply/add Drawably to a project.
---

# Apply Drawably to a SwiftUI project

Drawably draws each control as a seeded pen sketch that boils (3 micro-wobbled frames on a shared 1200ms clock). The package is `https://github.com/hemal08ce094/DrawablySwiftUI`, product `Drawably`, first release `0.1.0`. Full API: `references/api.md`. Package wiring: `references/xcode-package.md`.

Target look: https://github.com/hemal08ce094/DrawablySwiftUI/blob/main/docs/media/demo-mac.gif (and `demo-phone.gif`). If the user isn't sure what they're getting, link it before converting anything.

Work in this order. Don't skip the preflight.

## 1. Preflight

- Find the app target and its deployment targets (`grep -n "DEPLOYMENT_TARGET" *.xcodeproj/project.pbxproj`, or `platforms:` in Package.swift). Drawably needs **iOS 18 / macOS 15 / visionOS 2**. If the target is lower, stop and ask whether to raise it. Don't scatter `#available` checks through the UI.
- Decide the **scope** from the request: one screen, one flow, or the whole app. "Make X hand-drawn" means X only. Don't reskin screens nobody mentioned.
- Read the screens in scope before editing, and note the brand colour and background colour each one uses.

## 2. Add the package

Follow `references/xcode-package.md`: either a Package.swift dependency, or an `XCRemoteSwiftPackageReference` in the pbxproj pinned `upToNextMajorVersion` from `0.1.0`. Resolve and build once before converting anything:

```sh
xcodebuild -project App.xcodeproj -scheme App -resolvePackageDependencies
```

## 3. Theme once, at the root of the scope

```swift
import Drawably

RootView()
    .drawably(stroke: brand, fill: brand, paper: background)   // paper = the colour behind the controls
```

- `paper` is used for the text on solid buttons and for the select's options list, so it must equal the real background.
- For dark mode, use adaptive colours (asset-catalog colours, or `Color(uiColor: .label)` for stroke and `.systemBackground` for paper). The defaults are light-only pen blue on white.
- Controls take their type from `theme.font` (Inter 15 by default). To match the app's type, use `.drawablyTheme { $0.font = .body }`. `.font()` on a control only reaches labels it doesn't style itself, such as checkbox, radio and toggle labels.
- Other knobs: `width`, `roughness`, `boil` (0 means a static sketch), `error`, `success`, `neutral`, `placeholder`.

## 4. Convert: stock → Drawably

| Stock SwiftUI | Drawably |
|---|---|
| `Button` (plain/bordered) | `DrawablyButton("Title") { … }`, or keep the `Button` and add `.buttonStyle(.drawably)` |
| `.borderedProminent` / primary CTA | `variant: .solid` |
| secondary / cancel | `tone: .neutral` |
| `role: .destructive` | `tone: .danger` |
| async submit with a spinner | `state: isSaving ? .loading : .idle`, then `.error` / `.success` briefly |
| decorative "sketchy" fill | `variant: .scribble` |
| `Toggle` | `DrawablyToggle(isOn:)`. Its label sits **right** of the switch. To keep a settings-row layout, put `Text` + `Spacer()` + `DrawablyToggle(isOn:)` in an `HStack` |
| checkmark rows / multi-select | `DrawablyCheckbox("Label", isOn:)` |
| single choice (few options) | `DrawablyRadio("A", value: .a, selection: $x)`, one per option |
| `Picker(.menu)` | `DrawablySelect(selection:options:)` (see gotchas) |
| `Picker(.segmented)` | `DrawablyTabs(selection:) { Text…; Text… }` |
| `TextField` | `DrawablyTextField("placeholder", text:)` |
| `TextField(axis: .vertical)` / `TextEditor` | `DrawablyTextEditor("placeholder", text:, rows:)` |
| `Divider()` | `DrawablyDivider()` |
| `GroupBox` / card built from `RoundedRectangle().stroke/fill` | `DrawablyCard { … }` |
| capsule tag / pill / version label | `DrawablyBadge("new")` (`.scribble` for emphasis) |
| bullet or feature list | `DrawablyList(marker: .dash/.check) { Text…; Text… }` |
| numbered steps / checklist | `DrawablySteps { … }` |
| keyboard shortcut hint | `DrawablyKbd("⌘K")` |
| filter chips | `DrawablyChip("label", isOn:)` |
| banner / notice | `DrawablyAlert(tag: "new") { Text… }` |
| page dots / pagination | `DrawablyPager(page:count:)` |
| emphasised word | `.drawablyUnderline()`, `.drawablyHighlight()` or `.drawablyCircle()` on the `Text` |
| emphasis inside a sentence | `DrawablyText(Text("… \(Text("word").drawably(.highlight)) …"))` |
| coach mark / "tap here" callout | `.drawablyAnchor("a")` on both ends, `.drawablyArrow(from:to:)`, and `.drawablyArrows()` on a container holding both; or `DrawablyTooltip("hint", to: "a")` |

**Leave these native:** navigation bars, tab bars, toolbars, sheets and alerts, system `List`/`Form` chrome, `DatePicker`, `SecureField` (there's no Drawably equivalent, so keep it native and say so), `Slider`, `Stepper`, maps, media. Converting system chrome fights the platform and breaks accessibility.

Keep the existing bindings, actions and accessibility labels. Swap the view, not the logic.

## 5. Gotchas

- **Select dropdown:** it's an in-hierarchy overlay, so it can render under siblings that come later. Put `.zIndex(1)` on the select (or on its container, if it's nested) inside the parent stack, and don't put it inside a `.clipped()` container.
- **Arrows and tooltips** draw only under a `.drawablyArrows()` that contains **both** anchors. Put it high: on the screen's root or the ScrollView content. Anchor ids are plain strings and must be unique on screen.
- **Inline marks** (`Text.drawably(_:)`) render only inside `DrawablyText`. On their own they're plain text.
- **List markers** centre on `lineHeight` (default 22). Pass the real first-line height (for example, 21 for 14pt text).
- **Long lists:** every sketch runs a small TimelineView. For lists of hundreds of rows, set `.drawably(boil: 0)` on that subtree.
- **Custom shapes:** `Boiling(options) { o in RoughShape(o) { size, o in Rough.roundedRect(3, 3, size.width - 6, size.height - 6, 8, o) }.stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)) }`, with `options = RoughOptions(seed: randomSeed())` kept in `@State`. Never fake the look with plain `RoundedRectangle` strokes.
- **Fixed seeds:** pass `seed:` only when a sketch must be reproducible (for example, snapshot tests). Otherwise let each mount draw fresh.
- **Reduce Motion** is already handled (the boil freezes and hover re-sketching stops). Don't add extra motion on top.

## 6. Verify

1. Build every platform the target supports (`xcodebuild … build`). Fix all errors before reporting.
2. Run in the simulator (`xcrun simctl install/launch`, then `xcrun simctl io <udid> screenshot`) and look at each converted screen. Check that tap targets still work, the paper colour matches the background, and nothing is clipped. The circle decoration and focus rings draw a few points outside the view.
3. If the app supports dark mode, screenshot it in dark mode too.
4. Report which screens and controls were converted, what was deliberately left native and why, and any deployment-target change.

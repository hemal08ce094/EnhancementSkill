# Drawably for SwiftUI — API

Native SwiftUI port of drawably: hand-drawn controls, a fresh seeded pen sketch per mount, strokes boiling on one shared 1200ms clock. Same renderer as the JS library, bit for bit: a seed draws the same strokes on both.

Add the package (`https://github.com/hemal08ce094/DrawablySwiftUI`, branch `main`), then `import Drawably`. iOS 18, macOS 15, visionOS 2. Inter, Geist Mono and the optional Drawably Pen font are bundled.

## Controls

```swift
DrawablyButton("Done", variant: .solid) { submit() }        // .outline (default) | .solid | .scribble
DrawablyButton("Cancel", tone: .neutral)                     // .pen | .neutral | .danger
DrawablyButton("Save", state: saving ? .loading : .idle)     // .idle | .loading | .error | .success
Button("Any") { }.buttonStyle(.drawably(variant: .scribble)) // the same sketch as a ButtonStyle
DrawablyCheckbox("Ship it", isOn: $ship)
DrawablyRadio("Pen", value: "pen", selection: $ink)          // same selection binding groups them
DrawablyToggle(isOn: $on)
DrawablyTextField("your name", text: $name)
DrawablyTextEditor("a note", text: $note, rows: 4)
DrawablySelect(selection: $tool, options: ["Pen", "Pencil"]) // width reserved for the widest option
DrawablyDivider()
DrawablyCard { … }
DrawablyBadge("new", variant: .scribble)                     // .outline | .scribble
DrawablyList(marker: .check) { Text("a"); Text("b") }        // .dash | .check; each child is an item
```

Every control takes `seed:` (omit for a unique sketch per mount). Hover and press re-sketch buttons, checkboxes, radios, toggles, underlines and circles. Buttons lift on hover and sink on press; loading dims and boils faster; error/success redraw in red/green.

## Text decoration

```swift
Text("Hand-drawn").drawablyUnderline()
Text("fresh sketch").drawablyHighlight()
Text("$0").drawablyCircle()

// inside a paragraph, one drawing per line a mark wraps onto
DrawablyText(Text("\(Text("Hand-drawn").drawably(.underline)) UI, a \(Text("fresh sketch").drawably(.highlight))."))
```

## Arrows

```swift
VStack {
    Text("note").drawablyAnchor("note")
    DrawablyButton("Go").drawablyAnchor("go")
}
.drawablyArrow(from: "note", to: "go")   // declare anywhere inside…
.drawablyArrows()                         // …drawn by the nearest container holding both ends
```

## Composites

```swift
DrawablyChip("pen", isOn: $pen)
DrawablyTabs(selection: $tab) { Text("a"); Text("b") }
DrawablyTooltip("undo", to: "undoButton")   // needs .drawablyArrows() above it
DrawablyAlert(tag: "new") { Text("Import lands Friday") }
DrawablySteps { Text("record"); Text("label") }
DrawablyKbd("⌘K")
DrawablyQuote(Text("less, but better")) { Text("Rams") }
DrawablyPager(page: $page, count: 3)
```

## Theme

```swift
content.drawably(stroke: .black, fill: .black, paper: .white, width: 2, roughness: 1, boil: 0.3)
content.drawablyTheme { $0.error = .red; $0.font = .drawablyInter(17) }
```

`boil: 0` renders one static path. Reduce Motion freezes the boil, skips hover re-sketching and drops the check/dot/knob transitions.

## Rules

- Don't fake the look with borders or `RoundedRectangle` strokes; use the controls or `RoughShape` + `Rough.*`.
- Theme with `.drawably(...)` / `.drawablyTheme`, not by restyling internals.
- Don't apply `.drawablyPen` unless asked; controls use Inter.
- Custom shapes: `RoughShape(options) { size, o in Rough.roundedRect(…, o) }` inside `Boiling(options) { o in … }`. Also `Rough.line/circle/ellipse/arrow/checkmark/scribbleFill/variants`, `Mulberry32`, `randomSeed()`.

MIT.


## Signatures (0.1.0)

```swift
// Buttons
DrawablyButton(_ title: LocalizedStringKey | String, variant: .outline|.solid|.scribble = .outline,
               tone: .pen|.neutral|.danger = .pen, state: .idle|.loading|.error|.success = .idle,
               seed: UInt32? = nil, action: () -> Void = {})
DrawablyButton(variant:tone:state:seed:action:) { label }
.buttonStyle(.drawably)  /  .buttonStyle(.drawably(variant:tone:state:seed:))

// Choices — each also has (isOn:) with no label and (isOn:) { label }
DrawablyCheckbox(_ title:, isOn: Binding<Bool>, seed:)
DrawablyRadio(_ title:, value: V, selection: Binding<V>, seed:)
DrawablyToggle(_ title:, isOn: Binding<Bool>, seed:)

// Fields
DrawablyTextField(_ placeholder: String = "", text: Binding<String>, seed:)
DrawablyTextEditor(_ placeholder: String = "", text: Binding<String>, rows: Int = 2, seed:)
DrawablySelect(selection: Binding<String>, options: [String], seed:)
DrawablySelect(selection: Binding<V>, options: [V], seed:, title: (V) -> String)

// Containers
DrawablyDivider(seed:)                                   // 10pt tall, fills width
DrawablyCard(padding: EdgeInsets = 16 all round, seed:) { content }
DrawablyBadge(_ title:, variant: .outline|.scribble = .outline, seed:)   // or { content }
DrawablyList(marker: .dash|.check = .dash, lineHeight: 22, spacing: 0, seed:) { items }

// Decoration
view.drawablyUnderline(seed:)  .drawablyHighlight(seed:)  .drawablyCircle(seed:)
Text("x").drawably(.underline|.highlight|.circle)  → render inside DrawablyText(_ text: Text, seed:)
view.drawablyAnchor(_ id: String)
view.drawablyArrow(from: String, to: String, seed:)   // declare anywhere inside…
container.drawablyArrows()                            // …drawn here

// Composites
DrawablyChip(_ title:, isOn:, seed:)          DrawablyTabs(selection: Binding<Int>, seed:) { tabs }
DrawablyTooltip(_ title:, to: String, seed:)  DrawablyAlert(tag: String? = nil, seed:) { content }
DrawablySteps(lineHeight: 22, seed:) { items } DrawablyKbd(_ key: String, seed:)
DrawablyQuote(_ line: Text, seed:) { footer }  DrawablyPager(page: Binding<Int>, count: Int, seed:)

// Theme
view.drawably(stroke:fill:paper:width:roughness:boil:)
view.drawablyTheme { (t: inout DrawablyTheme) in … }  // stroke fill paper width error success neutral
                                                        // placeholder roughness boil font monoSize
Font.drawablyInter(_:weight:)  Font.drawablyMono(_:weight:)  Font.drawablyPen(_:)

// Renderer (custom shapes)
RoughOptions(seed:roughness:boil:)   randomSeed()   Mulberry32(seed).next()
Boiling(options, cycle: 1.2) { o in … }   BoilClock(active:cycle:) { frameIndex in … }
RoughShape(o) { size, o in Path }
Rough.line/circle/ellipse/arrow/roundedRect/checkmark/scribbleFill(…, o)   Rough.variants(o) { Path }
```

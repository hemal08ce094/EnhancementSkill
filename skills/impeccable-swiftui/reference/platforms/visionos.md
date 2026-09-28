# visionOS

For SwiftUI and RealityKit apps on Apple Vision Pro.

## The visionOS slop test

Does this belong in the room, or is it an iPad app floating in space? The tells: an opaque rectangle with no glass, tiny controls that make eyes work, content pinned to the head, a full immersive space the person didn't ask for, 3D for decoration, motion that moves the world instead of objects in it. Space is the medium; comfort is the constraint.

## Scenes: pick the smallest that works

- **Windows** (`WindowGroup`) for most of the app: 2D SwiftUI on glass, placed and resized by the person. Start here.
- **Volumes** (`.windowStyle(.volumetric)`, sized with `.defaultSize(width:height:depth:in:)`) for bounded 3D content that others could walk around: a model, a board game, a globe. `Model3D` for a static asset, `RealityView` for anything interactive.
- **Immersive spaces** (`ImmersiveSpace`, opened with `@Environment(\.openImmersiveSpace)`) only when the experience needs the room. Choose `.immersionStyle(selection:in:)` from `.mixed`, `.progressive`, `.full` deliberately; `.progressive` lets the person dial the Digital Crown. Always offer an obvious way out.
- Open additional windows with `@Environment(\.openWindow)`; never spawn windows the person didn't request.

## Layout & glass

- **Glass is the default window material** and the platform's identity: it keeps the room visible and adapts to lighting. Don't paint opaque backgrounds over it; `.glassBackgroundEffect()` for custom surfaces (ornaments, floating panels, attachments). There is no dark or light mode; glass handles contrast.
- **Ornaments** (`.ornament(attachmentAnchor: .scene(.bottom)) { … }`) hold toolbars and controls outside the window's edge, so content keeps the full pane. `TabView` renders as a leading ornament automatically; `.toolbar` items land in a bottom ornament.
- **Depth with purpose.** Layer with `.offset(z:)`, `.padding3D`, and `.frame(depth:)` to lift what's active or selected; a few points of z reads clearly. Don't stack z for decoration.
- **Placement.** Windows appear in front at a comfortable distance; content stays within the field of view, horizontal, near eye level. Never head-lock content; anchor to the world or the window.
- **Size for distance.** Default window sizes around 1280×720 pt; keep key content in the center, where eyes rest.

## Interaction

- **Look and tap.** Eyes target, pinch commits. Every interactive element needs a visible gaze highlight: system controls have one; custom views get `.hoverEffect()` with a `.contentShape(.hoverEffect, …)` that matches their shape. Privacy: you never get gaze location, only the highlight.
- **60 pt targets** minimum, with generous spacing; round and capsule shapes (`.buttonBorderShape(.circle)`, `.capsule`) read best under gaze.
- **Direct touch** for close 3D content in immersive or volumetric scenes; gestures on entities via `.gesture(… .targetedToAnyEntity())`. Keep gestures standard: tap, drag, magnify, rotate.
- **No sustained arm-raised interaction.** Precision and long tasks stay indirect.

## Type & color

- **Text styles, bolder by default.** visionOS type is slightly heavier for legibility on glass; `.extraLargeTitle` and `.extraLargeTitle2` exist for hero moments. Dynamic Type applies.
- **Vibrancy over color.** `.foregroundStyle(.primary/.secondary/.tertiary)` renders vibrant on glass; custom-colored text on glass loses contrast as the room changes. Color goes into symbols, fills, and 3D content, and white stays readable.
- Avoid large bright white surfaces; they glare in dim rooms.

## Motion & comfort

- **Move objects, never the viewer.** No camera motion, no forced acceleration, no world shaking. Fade and scale content in; `.preferredSurroundingsEffect(.systemDark)` (visionOS 2+) to dim passthrough when focus matters.
- Springs with low bounce; slower than iPhone for large 3D moves. Honor Reduce Motion.
- Spatial audio anchored to its source object, sparingly.

## Verifying the build

- `xcodebuild -scheme <S> -destination 'platform=visionOS Simulator,id=<UDID>' build`, run, and capture with `xcrun simctl io <UDID> screenshot .impeccable/shots/<name>.png`. Check a bright and a dim simulated room, and a resized window.
- Gaze feel, comfort, scale, and depth are only trustworthy on the device. Say which produced the evidence.

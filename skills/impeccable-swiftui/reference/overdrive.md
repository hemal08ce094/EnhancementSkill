Start your response with:

```
──────────── ⚡ OVERDRIVE ─────────────
》》》 Entering overdrive mode...
```

Push an interface past conventional limits. This isn't just visual effects. It's using the full power of the device, the GPU, Metal, RealityKit, the Taptic Engine, ProMotion, to make any part of an app feel extraordinary: a list that scrolls a million rows without a hitch, a photo that zooms into its detail, a control cluster that morphs, a surface that responds to light and touch like a material.

**EXTRA IMPORTANT FOR THIS COMMAND**: Context determines what "extraordinary" means. A shader-driven particle field on a music visualizer is impressive. The same field on a Settings screen is embarrassing. But a Settings screen with instant optimistic toggles and a zoom transition into each detail? That's extraordinary too. Understand the product's personality and goals before deciding what fits.

### Propose before building

This command has the highest potential to misfire. Do NOT jump straight into implementation:

1. **Think through 2–3 directions**: different techniques, levels of ambition, aesthetic approaches. For each, describe what the result looks and feels like.
2. **Get the user's pick before writing any code.** Ask with the AskUserQuestion tool when it is available, otherwise ask directly and stop. Carry each direction's description and trade-offs (minimum OS, GPU/battery cost, complexity, fallback) inside the option itself: a structured question blocks the message it rides in, so directions written alongside it stay invisible while the user chooses.
3. Proceed only with the confirmed direction.

### Iterate on the real thing

Ambitious effects almost never work on the first try. Build, run, capture (`xcrun simctl io <UDID> screenshot .impeccable/shots/<name>.png`, or a screen recording with `xcrun simctl io <UDID> recordVideo`), look, adjust. Expect several rounds. Shaders render in the Simulator but its frame rate means nothing; judge smoothness on hardware and say which evidence came from where.

---

## Assess what "extraordinary" means here

Ask: **what would make a user of THIS screen say "oh, that's nice"?**

- **Expressive surfaces** (media, onboarding moments, a hero, a game-adjacent app): the wow is sensory: a shader material, an animated `MeshGradient` atmosphere, a scroll-linked distortion, depth you can look into.
- **Functional UI** (lists, forms, editors, navigation): the wow is in how it *feels*: a cell zooming into its detail, a floating control cluster that morphs as modes change, drag-and-drop that springs with the finger's velocity.
- **Performance-critical UI**: the wow is invisible: search over 50k items with no dropped frame, an editor that previews filters in real time, a timeline that never stutters.
- **Data-heavy UI**: fluidity: Swift Charts animating between states, scrollable chart domains, dense plots drawn in `Canvas`.

The common thread: the implementation goes beyond what people expect from an app. The technique serves the experience.

## The toolkit

### Cinematic continuity
- `.navigationTransition(.zoom(sourceID:in:))` + `.matchedTransitionSource` (iOS 18+): the system-grade morph from cell to detail, interactive and interruptible for free.
- `matchedGeometryEffect`, custom `Transition` conformances, `KeyframeAnimator` for multi-track choreography (iOS 17+).
- Liquid Glass morphing (iOS 26+): `GlassEffectContainer` with `.glassEffectID(_:in:)` lets floating controls merge and split. Chrome only, never content cards.

### Shaders on any view (iOS 17+, macOS 14+)
Metal `[[ stitchable ]]` functions applied through `ShaderLibrary`:

- `.colorEffect` recolors each pixel (grain, duotone, light sweep);
- `.distortionEffect(_:maxSampleOffset:)` moves pixels (ripple, lens, heat haze);
- `.layerEffect(_:maxSampleOffset:)` samples the rendered layer (blur-like, chromatic, pixelate).

```metal
#include <metal_stdlib>
using namespace metal;
[[ stitchable ]] float2 ripple(float2 p, float2 center, float t, float amp) {
    float d = distance(p, center);
    return p + normalize(p - center) * sin(d * 0.06 - t * 6) * amp * exp(-d * 0.01);
}
```

```swift
TimelineView(.animation(paused: calm)) { tl in
    let t = tl.date.timeIntervalSince(start)
    card.distortionEffect(
        ShaderLibrary.ripple(.float2(tap), .float(t), .float(calm ? 0 : 8)),
        maxSampleOffset: CGSize(width: 8, height: 8))
}
```

Use `.visualEffect { content, proxy in … }` to feed geometry (size, scroll position) into a shader. Precompile with `try await shader.compile(as:)` (iOS 18+) to avoid a first-use hitch.

### Generative drawing
- `Canvas` + `TimelineView(.animation)` for particle fields, trails, generative patterns, dense plots: one view, immediate-mode drawing, no view-per-particle. Pass SF Symbols or views through `symbols:` and `context.resolveSymbol(id:)`.
- `MeshGradient` (iOS 18+) with control points animated from the timeline's date for a slow, living atmosphere. Motion measured in seconds per cycle, not frames.
- SpriteKit via `SpriteView` (`SKEmitterNode`) when particles need physics or authored emitters.
- `drawingGroup()` to flatten a complex vector composite into one Metal-rendered layer.

### Depth and space
- `RealityView` (visionOS 1+, iOS/macOS 18+) for real 3D content: a product you can turn, a globe, a scene behind glass. `ParticleEmitterComponent` for volumetric particles.
- visionOS: volumes (`.windowStyle(.volumetric)`), `ImmersiveSpace` with `.immersionStyle(selection:in: .mixed, .progressive, .full)`, opened through `@Environment(\.openImmersiveSpace)`. Full immersion is a destination people choose, never where the app starts. See [platforms/visionos.md](platforms/visionos.md).

### Data that feels alive
- `List` / `LazyVStack` with stable `id`s and lightweight rows for huge collections; filtering in a `.task(id: query)` that cancels on each keystroke, off the main actor.
- Swift Charts: animate between states with `withAnimation`, `.chartScrollableAxes` + `.chartScrollPosition` (iOS 17+) for long series, selection with `.chartXSelection` (iOS 17+).

### The body
- Custom Core Haptics patterns synchronized to a visual (a dial's detents, a snap into place).
- Pencil hover (`.onContinuousHover`), squeeze and barrel-roll on iPad; pointer and gaze `.hoverEffect` shapes.

**NOTE**: Overdrive changes how an interface FEELS, not what the product DOES. Sync, offline, collaboration are product decisions, not UI enhancements.

## Implement with discipline

### Fallbacks are non-negotiable

Every effect needs a good static or reduced version:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
@Environment(\.scenePhase) private var phase
private var calm: Bool {
    reduceMotion || phase != .active || ProcessInfo.processInfo.isLowPowerModeEnabled
}
```

- Gate new APIs with `if #available(iOS 18, *)` and ship an older path that still looks designed.
- Reduce Motion: stop loops, freeze the mesh at a composed frame, replace distortion with a crossfade (`reduce-motion-ignored` flags loops in files that never check).
- Reduce Transparency: materials and glass fall back to solid surfaces.
- Low Power Mode and `ProcessInfo.processInfo.thermalState` ≥ `.serious`: pause or simplify.

### Performance budgets

- Frame budget: 16.7 ms at 60 Hz, 8.3 ms at 120 Hz on ProMotion. Target zero hitches during scroll and transitions; if the effect costs more than half the frame, simplify.
- Pause what isn't visible: `TimelineView(.animation(paused:))`, `.onScrollVisibilityChange` (iOS 18+), `scenePhase`.
- Keep `maxSampleOffset` as small as the effect allows; layer effects over large regions are expensive.
- Measure with Instruments (SwiftUI, Animation Hitches, Metal System Trace, Energy Log) on the oldest supported device, not the newest.

### Polish is the difference

The gap between "cool" and "extraordinary" is the last 20%: the spring's settle, the phase offset between two tracks, the secondary motion that makes a transition physical, the moment a shader's intensity follows touch pressure. Ship the version that feels inevitable, not the first one that runs.

**NEVER**:
- Ship effects that hitch on the oldest supported device
- Use a new API without a designed fallback
- Add sound without opt-in, or haptics on every frame
- Put Liquid Glass or materials on content to look "premium" (`glass-by-default`)
- Use technical ambition to mask weak fundamentals; fix those with other commands first
- Layer competing extraordinary moments. Focus creates impact, excess creates noise

## Verify the result

- **The wow test**: show someone who hasn't seen it. Do they react?
- **The removal test**: take it away. Does the app feel diminished, or does nobody notice?
- **The device test**: oldest supported iPhone, an iPad, a Mac window, Low Power Mode on. Still smooth?
- **The fallback test**: Reduce Motion and Reduce Transparency on. Still designed?
- **The context test**: does this make sense for THIS product and audience?

"Technically extraordinary" isn't about using the newest API. It's about making an app do something people didn't expect an app could do.

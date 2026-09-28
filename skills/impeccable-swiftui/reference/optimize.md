Performance is a feature. Find the actual bottleneck for THIS screen, fix it, then measure. Don't optimize what isn't slow.

## Assess

1. **Name the symptom**: slow launch, hitchy scroll, laggy typing, a stutter on a transition, a spinner that sits too long, memory growth, battery drain, heat.
2. **Reproduce on the right hardware**: a Release build on a real device, ideally an older one the app still supports. The Simulator runs on your Mac's CPU and GPU; its frame times are fiction. Debug builds are unoptimized and add SwiftUI checks. Use the Simulator only to find *what* re-renders, never to prove *how fast*.
3. **Measure before touching code.** Record a trace, note the numbers, keep the file.

**CRITICAL**: measure before and after. A fix without a before/after number is a guess.

## Measure

### Instruments

```bash
xcrun xctrace list templates
xcrun xctrace list devices
xcrun xctrace record --template 'SwiftUI' --device <device-UDID> \
  --launch -- /path/to/<App>.app --output .impeccable/traces/before.trace
xcrun xctrace record --template 'Animation Hitches' --device <device-UDID> \
  --attach <App> --time-limit 30s --output .impeccable/traces/scroll.trace
```

Or Product → Profile (⌘I) in Xcode, which builds Release and opens Instruments.

- **SwiftUI** template: view body update counts and durations, and (Xcode 26+) long view body updates and the cause-and-effect graph of which state change invalidated which views. Start here for any "SwiftUI is slow" complaint.
- **Animation Hitches**: hitch time ratio and each hitch's commit vs render phase. Commit hitches are your main-thread work; render hitches are too many layers, offscreen passes, or oversized images.
- **Time Profiler**: where main-thread time goes. Filter to your module; invert the call tree.
- **App Launch**: time to first frame, broken down by phase.
- **Allocations**, **Leaks**, and Xcode's **Memory Graph Debugger**: growth, retain cycles, abandoned memory.

### In code

- `let _ = Self._printChanges()` at the top of a `body` logs which dependency invalidated it. Debug only; delete before committing.
- `XCTest` metrics lock gains in: `measure(metrics: [XCTApplicationLaunchMetric()]) { XCUIApplication().launch() }`, `XCTOSSignpostMetric.scrollDecelerationMetric` around a scroll, `XCTMemoryMetric`, `XCTCPUMetric`.
- Field data: Xcode Organizer (launch, hangs, hitches, memory, energy) and `MetricKit` payloads. What users feel beats what your iPhone 17 Pro feels.

## Fix by cause

### Body invalidation (the most common SwiftUI problem)

- **Observe narrowly.** With `@Observable` (iOS 17+), a view re-evaluates only when a property its `body` actually read changes. Don't read the whole model in a parent and pass it down; pass the model and let each child read what it needs, or pass plain values.
- **Retire broad `ObservableObject`s** on hot screens: any `@Published` change invalidates every observing view. Migrate to `@Observable`, or split the object.
- **Keep environment values stable.** A frequently-changing value injected at the root invalidates everything that reads it. Environment objects at the root are fine; reading them everywhere is not.
- **Split big bodies into small `View` structs** with `let` inputs. SwiftUI skips unchanged children by comparing their stored properties; closures and non-`Equatable` inputs defeat that. `.equatable()` with an `Equatable` view is a targeted tool, not a default.
- **No work in `body`**: no `DateFormatter()` / `NumberFormatter()` creation (use `FormatStyle` or a static), no sorting or filtering large arrays (compute in the model on change), no image decoding, no `UUID()`.
- **Timers and continuous state**: a 60 Hz `@State` tick at the top of a screen re-renders the screen. Isolate it in the smallest leaf, or use `TimelineView` scoped to that leaf.

### Identity

- Stable, unique ids: `ForEach(items)` with `Identifiable` models whose `id` persists. Never `id: \.self` on non-unique or mutable values, never `ForEach(items.indices, id: \.self)` over a mutable array, never `.id(UUID())` (resets state and animation every render).
- Avoid `AnyView` (`any-view`): it erases structural identity and defeats diffing. Use `@ViewBuilder`, `Group`, or generics.
- Conditional `if` branches swap identity; toggling a modifier value (`.opacity(isVisible ? 1 : 0)`) preserves it. Pick deliberately.

### Lists and scrolling

- Long or unbounded content goes in `List` or `LazyVStack` / `LazyVGrid` inside `ScrollView`. A plain `VStack` of 500 rows builds 500 rows.
- `List` recycles and is usually faster than `LazyVStack` for uniform rows; `LazyVStack` doesn't reclaim rows that scroll far away. Pick by measurement.
- No `GeometryReader` per row. Use `containerRelativeFrame`, `.onGeometryChange(for:of:action:)` (iOS 18+, back-deployed to 16), or `visualEffect` for position-driven effects without layout feedback.
- Heavy per-row effects (blurred materials, large soft shadows, masks) are render-phase cost multiplied by rows. Flatten, cache, or remove.
- Prefetch the next page before the end; don't block scroll on it.

### Images

- Decode at display size. A 4032×3024 photo in a 80 pt thumbnail costs ~48 MB decoded. Downsample with ImageIO (`CGImageSourceCreateThumbnailAtIndex` with `kCGImageSourceThumbnailMaxPixelSize` and `kCGImageSourceCreateThumbnailFromImageAlways`), or `UIImage.byPreparingThumbnail(ofSize:)` off the main actor.
- `AsyncImage` has no cache beyond `URLCache` and restarts on identity change; in long lists use a small cached loader (an `actor` with `NSCache`) or the project's image library.
- Prefer vector assets (PDF/SVG with Preserve Vector Data) and SF Symbols for UI glyphs; asset catalogs for bundled bitmaps (app thinning ships only the needed scale).

### Launch time

- Do nothing on the main actor before the first frame that the first frame doesn't need. Defer analytics, migrations, prefetch, and SDK setup into a `.task` on the root view or a detached background task.
- Show real structure immediately: the root view renders from cached or placeholder data (`.redacted(reason: .placeholder)`), then fills in.
- Fewer dynamic frameworks, fewer static initializers, no synchronous file or network I/O in `App.init`.
- Targets: first frame well under 400 ms warm on supported hardware; measure with the App Launch template or `XCTApplicationLaunchMetric`.

### Async work and the main actor

- `.task { }` over `.onAppear { Task { } }`: it cancels on disappear. `.task(id: query)` restarts on change and cancels the stale run, which is your debounce for search (add `try await Task.sleep(for: .milliseconds(250))` at its top).
- Parsing, image processing, and database work run off the main actor (`@concurrent` functions or a dedicated actor); only UI state updates hop back.
- Watch for hangs in the Xcode console and Organizer; anything over 250 ms on main is a hang users feel.

### Animation and effects

- Animate transforms, opacity, and `visualEffect` offsets; animating frame sizes of large subtrees re-lays out every frame.
- `drawingGroup()` flattens many composited shapes into one Metal-rendered layer; `Canvas` draws hundreds of elements without a view per element; `TimelineView(.animation)` drives continuous effects without state churn. Metal shaders (`.colorEffect`, `.distortionEffect`, `.layerEffect`) move per-pixel work to the GPU.
- Pause continuous animations off-screen and in the background (`scenePhase`), and honor Reduce Motion (`reduce-motion-ignored`), which also saves power.
- Scope `.animation(_:value:)` to the view that changes; `deprecated-api` flags the value-less form, which animates everything.

### Memory

- Leaks: closures stored on `@Observable` classes capturing `self` strongly; `NotificationCenter` observers and `Timer`s never invalidated; `Task`s holding models forever. Use `[weak self]` where ownership is circular, and cancel tasks.
- Caches: `NSCache` (purges under pressure), bounded counts, cleared on memory warning.
- Verify with Allocations "Mark Generation" across navigate-in / navigate-out cycles: memory should return to baseline.

## Verify

- Before/after trace numbers from the same device, build configuration, and scenario: hitch time ratio, body update counts on the hot view, launch time, peak memory.
- Test on the oldest supported device you can reach; say which devices produced the evidence and what stayed untested.
- No regressions: behavior, accessibility, and animation feel unchanged.
- User perception: does it *feel* faster? Perceived speed (skeletons, optimistic updates, instant feedback) counts.

**NEVER**:
- Optimize without measuring, or measure in the Simulator or a Debug build and call it performance
- Trade away accessibility (Dynamic Type, VoiceOver, Reduce Motion) for speed
- Sprinkle `.equatable()`, `drawingGroup()`, or `@MainActor` removals as rituals
- Use `.id(UUID())` or `AnyView` to "force" updates
- Micro-optimize while the big bottleneck stands
- Leave `_printChanges()` or signposts in shipped code

When the measured numbers move, hand off to `/impeccable-swiftui polish` for the final pass.

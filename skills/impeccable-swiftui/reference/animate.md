> **Additional context needed**: performance constraints and target devices.

Use motion to explain state, relationship, and hierarchy, or to create one authored moment the screen has earned. Decoration without purpose is animation debt.

---

## Visitor mode

- **Persuade + Experience:** motion may carry the voice. Prefer one rehearsed focal sequence to a staggered entrance on every screen.
- **Operate + Read:** motion serves feedback, state, and continuity. Keep routine transitions fast; never make people wait through choreography to reach a control.
- **Always:** system navigation motion (push, sheet, dismiss) is the baseline. Follow the Motion section of the platform file ([platforms/ios.md](platforms/ios.md), [platforms/macos.md](platforms/macos.md), [platforms/visionos.md](platforms/visionos.md), ...). Custom transitions that fight the navigation model disorient.

## Find the job

Inspect the existing motion language (named springs in DESIGN.md, `Animation` extensions), interaction states, target devices, and budget. Animate only where motion would:

- acknowledge an action;
- make a state change or spatial relationship legible;
- preserve continuity through navigation or layout change;
- direct attention at a meaningful moment;
- embody the selected visual world.

Do not animate a static area merely because it exists.

## Set the motion thesis

Before implementation, write:

- **Focal moment:** the one sequence or interaction that deserves authorship, if any.
- **Continuity:** the state, layout, or navigation changes that need explanation.
- **Feedback:** the controls and outcomes that need acknowledgment (and which get a haptic).
- **Budget:** which effects are expensive and how often they run.

The focal moment must come from this product. A fade-and-rise on appear, a `scaleEffect` press on every card, a parallax header, or a `scrollTransition` fade on every row is not a thesis (`section-fade`).

## Choose the tool by meaning

- **Continuity and relationship:** `.navigationTransition(.zoom(sourceID:in:))` with `.matchedTransitionSource(id:in:)` (iOS 18+) for a cell opening into its detail; `matchedGeometryEffect` for an element moving between two layouts in the same view; implicit layout animation for insert/remove/reorder with stable `id`s.
- **State and feedback:** the smallest change that makes cause and result unmistakable. `contentTransition(.numericText(value:))` for counters, `.contentTransition(.symbolEffect(.replace))` for symbol swaps, `.symbolEffect(.bounce, value:)` once on a meaningful change (iOS 17+; `.wiggle`, `.rotate`, `.breathe` iOS 18+; `.drawOn` iOS 26+).
- **Sequences:** `PhaseAnimator` for a small set of discrete stages, `KeyframeAnimator` when separate tracks (scale, rotation, offset) need independent timing (both iOS 17+).
- **Reveal and composition:** `.transition(.blurReplace)`, `.asymmetric(insertion:removal:)`, a custom `Transition` (iOS 17+), masks and `clipShape` changes.
- **Scroll relationship:** `scrollTransition` and `visualEffect { content, proxy in }` (iOS 17+) only when the scroll position itself carries meaning, e.g. a carousel whose centered item is the selection.
- **Material and energy:** shaders and `TimelineView`, which belong to [overdrive.md](overdrive.md).

```swift
// Continuity: the photo grows into its detail (iOS 18+)
NavigationLink(value: photo) {
    Thumbnail(photo).matchedTransitionSource(id: photo.id, in: ns)
}
// destination
PhotoDetail(photo).navigationTransition(.zoom(sourceID: photo.id, in: ns))
```

Don't stack techniques for spectacle. One strong idea, carried through the focal moment, with quiet supporting states. Stagger only a list appearing as a list, and cap the total delay around 200 ms.

## Timing and springs

Springs are the platform's native language. They retarget smoothly when interrupted; timing curves don't.

| Duration | Typical use |
|---|---|
| 0.1–0.2 s | press feedback, toggles |
| 0.25–0.35 s | routine state change (`.snappy`, `.smooth`) |
| 0.35–0.5 s | layout, overlay, or navigation continuity |
| 0.5–0.8 s | a deliberately authored focal entrance |

- Default: `.smooth` or `.spring(duration: 0.35, bounce: 0)`; `.snappy` for small, quick feedback. Keep `bounce` ≤ 0.15 unless the object is physically thrown. `.bouncy`, `bounce:` > 0.3 and low `dampingFraction` read as toy-like (`bounce-easing`).
- Name springs once in DESIGN.md and an `Animation` extension; don't scatter magic numbers.
- Exit faster than entrance. Long feedback feels like latency.
- Always `.animation(_:value:)` or `withAnimation`; the value-less `.animation(_:)` is deprecated and animates everything (`deprecated-api`). Scope with `.animation(.smooth) { $0.opacity(x) }` (iOS 17+) when only one property should move.
- Sequencing: `withAnimation(.smooth) { … } completion: { … }` (iOS 17+) instead of `DispatchQueue.asyncAfter` chains.

## Gestures and interruption

Motion driven by a finger must follow the finger and hand off with its velocity.

```swift
.gesture(DragGesture()
    .updating($drag) { value, state, _ in state = value.translation }
    .onEnded { value in
        withAnimation(.spring(duration: 0.4, bounce: 0.1)) {
            settle(predicted: value.predictedEndTranslation)
        }
    })
```

- Use `@GestureState` for in-flight values so cancellation resets cleanly.
- Decide the resting state from `predictedEndTranslation`, not the release point.
- A new tap mid-animation retargets; never lock input until motion finishes.
- Keep system gestures alive: edge-swipe back, sheet drag-to-dismiss, scroll.

## Pair with haptics

Motion that confirms a consequential outcome pairs with `.sensoryFeedback(_:trigger:)` (iOS 17+): `.success` / `.error` for outcomes, `.selection` for picker-like changes, `.impact(weight:intensity:)` for a physical landing. Fire on the state change, not on the tap. Not every animation gets a haptic.

## Accessibility and control

Read `@Environment(\.accessibilityReduceMotion)` in every file that loops, sequences or moves things spatially; the detector flags `repeatForever`, `PhaseAnimator` and `KeyframeAnimator` in files that never read it (`reduce-motion-ignored`).

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .smooth) { expanded.toggle() }
.transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
```

Reduce Motion means replacing spatial movement, zooms and parallax with crossfades, and stopping decorative loops. It does not mean removing feedback: state changes, numeric transitions and symbol replacement stay legible. `PhaseAnimator` / `KeyframeAnimator` should drop to a static final state. Nonessential loops stop when off-screen or when `scenePhase` isn't `.active`. Also honor Low Power Mode for expensive loops.

## Verify

- The focal motion is specific to this product and screen.
- Every supporting animation explains feedback, state, or relationship.
- Interrupt everything: tap during transitions, drag mid-spring, rotate mid-animation. Nothing snaps, sticks or double-fires.
- Reduce Motion (Settings > Accessibility > Motion) path verified in Simulator, not assumed.
- Hitches measured with the Instruments SwiftUI / Animation Hitches templates on a real device for anything expensive; Simulator frame rates are not evidence.
- Removing an animation would lose meaning or authored character, not merely decoration.

When motion earns its place, hand off to `/impeccable-swiftui polish` for the final pass.

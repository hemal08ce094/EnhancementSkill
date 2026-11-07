---
name: signature-moment-swiftui
description: Design and spec one memorable "signature moment" screen or transition for a native iOS, iPadOS, watchOS, macOS or visionOS app before building it, such as a story onboarding, a touch-reactive hero, a plan picker, a hold-to-reveal toy or a playful empty state. It writes an exact moment spec (tokens, verbatim copy, a progress timeline, input and haptics, adaptive layout, states, accessibility, performance) from a template, then builds it in layers. Use when an app needs a wow moment, when the user asks for a signature screen, a delight moment, an interactive hero or an onboarding that people remember, or says "spec this like a prompt".
---

# Signature moment for native apps

Method distilled from the public sections library at supply.madebyoversight.com, recast for SwiftUI. No third-party code, copy or assets are included.

Read `references/catalogue.md` to choose an archetype, then copy `references/spec-template.md` and fill every part before writing code.

## The idea

Generic UI comes from vague briefs. "A modern onboarding" gets the average of every onboarding. Oversight's fix is to hand the builder one finished, self-contained section, written as an exact spec, and ask it to adapt the content and keep the decisions.

For a mobile app, that section is a **signature moment**: the one screen or transition people remember. A hero that reacts to touch, an onboarding that is a scroll story, a paywall plan picker that morphs, an empty state that plays, a result screen with a payoff. Spec it once, in full, then build it.

Use it when a use case has a "wow moment" (see the baseline requirements). Skip it for settings, lists and forms.

## What the source specs always contain

Both samples (a scroll-driven particle hero and a drag-anywhere photo table) share one skeleton. A good moment spec has every part:

1. **Pitch paragraph.** What the user sees, does and feels, in plain words, including what happens when nobody touches it.
2. **Stack and dependencies.** Exact frameworks, minimum OS, fonts, packages. No "or similar".
3. **Layout and content.** Every colour as a named token with a value. Every string verbatim. Every size as a rule, not a feeling.
4. **Interaction and animation timeline.** A table: progress from, to, what changes. Named ease and duration. Stagger values.
5. **Responsive behaviour.** Breakpoints and what changes at each.
6. **Accessibility and robustness.** Roles, labels, reduced motion, focus order, failure paths.
7. **Performance notes.** What is computed once, what runs per frame, what pauses.
8. **Assets.** Each file, its path, its job.
9. **Limitations.** What breaks and what the fallback is.

The method that made them feel designed, not generated:

- One owner for motion. A single frame loop or a single progress value writes all moving things. No scattered timers.
- Heavy work once. Sample an image into a grid once; later frames only move things.
- Scroll or touch progress is a single number from 0 to 1, with named stops and `smoothstep` chapters. Everything else derives from it.
- Depth from ratios. Bigger items sit nearer and move faster. Items lean with velocity and sink slightly under the finger.
- Connection. Hairlines tie related things together and are redrawn every frame.
- Idle life. When untouched, it drifts. Reduced motion removes the drift.
- Pause off screen. The loop runs only when visible and active.
- Every state is written down: loading, ready, error, reduced motion, small screen.
- Copy is final. No invented stats, logos or testimonials.

## Casting it for native mobile

Translate web inputs and APIs. Do not port web code.

| Web idea | Native mobile equivalent |
| --- | --- |
| Sticky stage in a tall scroll track | `ScrollView` with a pinned layer, driven by `onScrollGeometryChange` or `scrollTransition`; or a paged `TabView`/`scrollTargetBehavior(.paging)` |
| Scroll progress 0–1 with stops | One `@State progress`, snapped with `scrollTargetBehavior`; stops as an array |
| `requestAnimationFrame` loop | `TimelineView(.animation)` plus `Canvas`; keep model state in a class, not in view state |
| Canvas 2D particles | SwiftUI `Canvas`, or Metal via `MTKView` when over a few thousand elements |
| Pointer move and hover | `DragGesture(minimumDistance: 0)` for touch; no hover on iPhone, so expose the same payoff through press and hold. Pointer hover only on iPad and Mac |
| Click sends a pulse | Tap with `SpatialTapGesture`, plus `sensoryFeedback` |
| Momentum drag with idle drift | `DragGesture` velocity into a decaying model; drift from `TimelineView` time |
| Lightbox with FLIP | `matchedGeometryEffect` or `navigationTransition(.zoom)` |
| `prefers-reduced-motion` | `@Environment(\.accessibilityReduceMotion)`; park at discrete states, no idle drift |
| Pause when off screen | `onScrollVisibilityChange`, `@Environment(\.scenePhase)`, and stop the `TimelineView` schedule |
| Phone URL bar resize guard | Ignore size changes below 2 pt that come from safe-area or keyboard; do not rebuild heavy models on them |
| Hover caption | Long-press preview or `contextMenu`; never hide required info behind it |
| ARIA roles and live regions | `accessibilityLabel`, `accessibilityValue`, `.accessibilityAddTraits`, `AccessibilityNotification.Announcement` |
| Fonts via package | Bundled font registered in Info.plist, with a system fallback and `Font.custom(_, relativeTo:)` for Dynamic Type |

Mobile-only additions the web specs lack:

- **Haptics.** Name the moment and the generator: soft impact on pulse, selection on stops, success on payoff.
- **Safe areas, Dynamic Island, home indicator.** Say which layers bleed and which respect.
- **Dynamic Type up to accessibility sizes.** Say how the moment degrades, for example the figure shrinks before the caption truncates.
- **Dark and light.** Give both token sets, or state that the moment is dark-only and why.
- **Thumb reach.** Primary controls in the lower third. The stage is not a button.
- **One-handed and landscape.** State whether landscape is supported.
- **Low Power Mode.** Cap frame rate and particle count.
- **Battery and thermal.** Stop the loop when the screen is static.
- **iPad and Duo.** Say how the moment lays out on a wide or folded window instead of centring a phone column.

## Extra techniques from five more samples

- **Adaptive quality.** Average the last 40 frame times. Drop resolution or particle count when slow, raise it when fast, and cap lower on small phones. On iOS also lower it in Low Power Mode and when `ProcessInfo.thermalState` is serious.
- **Fixed-size artefact.** Make the thing the user creates at a fixed resolution, independent of the screen, so saving and sharing produce the same image everywhere.
- **Accumulate, then composite when dirty.** Heavy layers update on a slow clock; the display layer redraws only when something changed.
- **Interpolated palette.** Time of day or progress drives a keyframed palette, and the text colour follows it so contrast holds at every stop. Check contrast at each key.
- **Text that reacts.** Headline letters can lean from their baseline toward the touch. Keep the accessible label as the whole sentence.
- **Generated audio.** Create the audio engine on the first tap. Tempo and pitch follow a single speed value. Scratch noise follows drag speed. Ship a mute path.
- **Preserve user work across rebuilds.** A rotation, resize or size-class change must not erase what the user planted or placed.
- **Name the real numbers.** A live log or counter reads engine state, never invented values.

## Procedure

1. **Choose the moment.** From the use case, pick the one thing users should remember. Name its archetype from `references/catalogue.md`.
2. **Write the spec** from `references/spec-template.md`. Fill every part. If a part does not apply, write why.
3. **Check it against the contract.** Tokens named, strings final, timeline tabled, states listed, reduced-motion path written, off-screen pause written.
4. **Build in layers.** Static layout first, then the progress value, then motion, then touch, then haptics.
5. **Verify.** Run on a small phone, a large phone and iPad. Test Reduce Motion, largest Dynamic Type, dark and light, Low Power Mode, and the error state. Record what was and was not tested.

## Rules

- Copy the method, never another team's code, copy, photography or brand. Their paid and free prompts carry their own licence.
- If a reference spec is supplied by the user, treat its tokens and timings as the starting contract, re-express them natively, and say what you changed.
- One signature moment per screen, and at most one per flow. A second one dilutes the first.
- The moment must not block the task. A skip, a tap-through, or a plain path must exist.
- Do not add a moment because the skill exists. Add it when the use case earns it.

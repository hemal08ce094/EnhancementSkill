> **Additional context needed**: the brand's emotional range.

Make the experience memorable at moments that earn it. Delight is not a layer of generic whimsy; it is product character revealed through a useful interaction, a humane response, or an unexpectedly considered detail.

---

## Visitor mode

- **Persuade + Experience:** personality may run through voice, composition, motion, sound, and discovery, provided the content stays the focus.
- **Operate + Read:** concentrate delight at first use, completion, recovery, or mastery. Reliability carries everything else.

## Find the opportunity

Inspect the target, DESIGN.md (especially Motion and Haptics & Sound), product voice, how often the moment repeats, and its emotional context. Look for:

- effort worth acknowledging;
- waiting that can become informative;
- an empty or first-use state that can orient;
- an error or recovery moment that needs empathy;
- an interaction whose physical response (motion, haptic, sound) could express the brand;
- a useful capability worth discovering: a long-press menu, a widget, a Shortcut.

Do not manufacture a celebration for an ordinary tap. Ask only when the emotional range or stakes can't be inferred.

## Define one delight thesis

One sentence: what the person should feel and why that feeling belongs to this product. Then the smallest system that delivers it:

- a distinctive response to a meaningful action;
- product-specific language that clarifies while carrying voice;
- a transition with a recognizable material behavior;
- a symbol, sound, haptic, or illustration grounded in the product world;
- a discovery that reveals real utility.

Derive it from the product's mechanism and world, not a stock catalog. Confetti on task completion is the stock catalog.

## The native palette

- **Haptics.** `.sensoryFeedback(_:trigger:)` (iOS 17+) pairs a physical response with a state change: `.success`, `.warning`, `.error`, `.selection`, `.increase` / `.decrease`, `.impact(weight:intensity:)`, `.levelChange`. Use the conditional form to fire only on the transition that matters. A signature pattern (a latch clicking, a dial's detents) is a job for Core Haptics (`CHHapticEngine`), designed once and documented in DESIGN.md.

```swift
.sensoryFeedback(trigger: streak) { old, new in
    new > old && new % 7 == 0 ? .success : nil   // a week, not every day
}
```

- **Symbols with behavior.** `.symbolEffect(.bounce, value:)` once on a meaningful change, `.contentTransition(.symbolEffect(.replace))` for state swaps (iOS 17+); `.wiggle`, `.breathe` iOS 18+; `.drawOn` iOS 26+. Variable-value symbols (`Image(systemName:variableValue:)`) show a level honestly. A custom SF Symbol for the product's own noun beats a generic glyph.
- **Numbers that move.** `.contentTransition(.numericText(value:))` makes a total that changes feel alive and legible.
- **Sound, rarely.** Only for moments where sound is part of the product (a timer, a game, a camera). Play through an `AVAudioSession` category of `.ambient` so the silent switch and other audio are respected; ship an in-app toggle; keep it under a second.
- **Words.** Alerts, empty states and success copy in the product's voice. Clarity first.
- **Easter eggs.** A hidden gesture or seasonal detail is fine when it's discoverable by curiosity, harmless if never found, and never the only path to a feature.

## Beyond the screen

The best delight often lives in system surfaces:

- **Widgets** that show the one number people open the app for, with `.contentTransition(.numericText())` between timeline entries, `.widgetAccentable()` for tinted modes, and an interactive `Button(intent:)` (iOS 17+) for the one action worth doing in place.
- **Live Activities / Dynamic Island** for real ongoing events only (a delivery, a timer, a match), compact leading/trailing carrying the essential state, updates that animate rather than jump.
- **App icon variants**: dark and tinted appearances (iOS 18+) designed, not auto-generated; layered icons for Liquid Glass (iOS 26+, Icon Composer). Alternate icons (`setAlternateIconName`) as a small reward or a supporter perk, not a settings maze.
- **Context menu previews, Spotlight, Shortcuts, Control Center controls** (iOS 18+): capabilities that feel considered because they're there when reached for.

## Build for the emotional moment

- **Success:** match the response to effort and consequence. A milestone can expand; a routine save should simply feel certain (a check, a `.success` haptic, done).
- **Waiting:** truthful progress (`ProgressView(value:)`), `.redacted(reason: .placeholder)` skeletons shaped like the real content, or product-specific activity. Never fake work or delay completion to stage a flourish.
- **Empty and first use:** make the next action clear before adding personality ([onboard.md](onboard.md)).
- **Error and recovery:** problem and fix first. Warmth may reduce stress; jokes must not trivialize loss, money, privacy, or blocked work.
- **Repeated interaction:** still satisfying on the hundredth use. Variation only when it stays coherent and trustworthy.
- **Discovery:** reward curiosity without hiding required functionality.

## Protect the experience

Delight must not:

- delay, block, or obscure the primary task;
- override platform conventions or accessibility;
- add unrequested factual claims;
- play sound without consent or ignore the silent switch;
- vibrate on every tap (haptic fatigue makes the meaningful ones meaningless);
- become mandatory, unskippable, or exhausting on repeat;
- add a dependency or asset cost disproportionate to the moment.

For authored motion, load [animate.md](animate.md). Honor Reduce Motion (`reduce-motion-ignored`), keep springs calm (`bounce-easing`), keep emoji out of icon roles (`emoji-icon`), give VoiceOver an equivalent (announce the milestone, don't just animate it). Nonessential loops stop off-screen and in the background. Celebration intensity is proportional to frequency and consequence.

## Verify

- The moment is specific enough that a neighboring app couldn't use it unchanged.
- It improves comprehension, confidence, motivation, or recovery.
- The app remains fast and obvious without the flourish.
- The hundredth time is still fine.
- Silent switch, Reduce Motion, VoiceOver, and localized paths work. Haptics verified on hardware; the Simulator can't feel them.
- The result feels like the selected world, not a generic "delight" treatment.

When the personality feels earned, hand off to `/impeccable-swiftui polish` for the final pass.

# Editorial readiness checklist

What App Store editors consistently reward, as checks you can run on a SwiftUI app. Report every line as done, not applicable, or a recommendation with the file to change. None of this guarantees a feature; it removes the reasons not to.

## A point of view
- [ ] The Touch Brief exists and the app visibly serves that one person.
- [ ] One style, applied consistently; no screen falls back to stock grey forms by accident.
- [ ] A signature moment exists and is designed (first run, completion, the daily check-in).
- [ ] Copy has a voice that matches the feeling; no "Error occurred", no lorem, no placeholder names.

## Native fluency
- [ ] System navigation: `NavigationStack`/`NavigationSplitView`, `TabView`, sheets, toolbars, swipe actions, context menus.
- [ ] Current platform look: Liquid Glass / materials where the system uses them; no custom tab bars fighting the system one.
- [ ] SF Symbols with matching weights; symbol effects for state changes.
- [ ] Works on every shipped device class: iPad uses the space (split view, sidebars), not a stretched phone layout.

## Care for every person
- [ ] Dynamic Type through accessibility sizes with no truncated controls.
- [ ] VoiceOver: every control labeled, custom views grouped, orbs and bots announce their state.
- [ ] Contrast passes in light and dark; Increase Contrast and Reduce Transparency respected.
- [ ] Reduce Motion: no parallax, springs off, kits frozen (they do this themselves).
- [ ] Localizable strings; layout survives German length and right-to-left.

## Craft
- [ ] Every state designed: empty, loading, error, offline, first run, populated, overflow.
- [ ] Motion has purpose and one consistent spring; nothing animates just to move.
- [ ] Haptics on meaningful moments only (commit, success, warning), matching the direction.
- [ ] 60/120 fps scrolling; orbs and sketches only on visible, active rows.
- [ ] App icon matches the world; dark and tinted icon variants provided.

## Apple platform reach (feature multipliers)
- [ ] Widgets (including Lock Screen / StandBy) for the glanceable part of the app.
- [ ] App Intents / Shortcuts / Spotlight for the top one or two actions.
- [ ] Live Activities for anything with a live timeline.
- [ ] Privacy: minimal permissions, primed with context before the system prompt; no tracking.

## Store presence
- [ ] Screenshots tell the brief's story (the person, the moment, the signature moment), light and dark.
- [ ] App preview video shows the signature moment in the first three seconds.
- [ ] Promotional text and "What's New" in the app's voice.

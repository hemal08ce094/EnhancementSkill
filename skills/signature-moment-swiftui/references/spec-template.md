# {Moment name} — {archetype} for {app}

{Pitch: what the user sees, does and feels. What happens untouched. What the payoff is.}

## Stack and dependencies

- Platform and minimum OS:
- Frameworks (SwiftUI, Canvas, Metal, SwiftData, StoreKit):
- Packages (none unless needed):
- Fonts and how they are registered:

## Layout and content

Tokens (light / dark):

| Token | Light | Dark | Use |
| --- | --- | --- | --- |

Type scale (max four sizes, each with `relativeTo:` style):

Strings (verbatim, final, in the String Catalog):

Geometry rules (safe areas, sizes as ratios, thumb zone):

## Progress and timeline

Stops: `0, …, 1`. Chapters as `smoothstep(a, b, p)`.

| From | To | What changes | Ease / duration |
| --- | --- | --- | --- |

Idle behaviour (drift, breathing). Off at Reduce Motion.

## Input and feedback

| Input | Result | Haptic | Fallback without touch (VoiceOver, keyboard, pointer) |
| --- | --- | --- | --- |

## Adaptive behaviour

- Small phone / large phone:
- iPad and wide windows (no centred phone column):
- Landscape:
- Dynamic Type at accessibility sizes:
- Dark and light:

## States

Loading · ready · empty · error · permission denied · offline · disabled · reduced motion · Low Power Mode. One line each.

## Accessibility

Labels and values, traits, announcements, reading order, contrast pairs checked.

## Performance

Computed once:
Per frame:
Pauses when:
Budget (particle or item cap, frame rate cap):

## Assets

| File | Path | Job | Licence |
| --- | --- | --- | --- |

## Limitations and fallbacks

## Verification log

Devices and settings tested. What was not tested.

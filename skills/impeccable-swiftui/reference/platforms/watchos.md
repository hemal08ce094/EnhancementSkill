# watchOS

For SwiftUI apps, complications, and widgets on Apple Watch.

## The watch slop test

Can someone get what they came for in two seconds, with their arm raised, without scrolling? The tells of a shrunken phone app: a login screen, dense lists of settings, paragraphs of text, a tab bar, buttons too small for a moving finger, a spinner while the phone wakes up, a hero image that pushes the answer below the fold. The watch app is a glance and a tap; the phone app is somewhere else.

## Glanceable first

- **The answer is the first screen.** The single most important value, large, at the top; one primary action. Everything else is secondary pages or deeper navigation.
- **Short sessions.** Design for 5–10 seconds. No multi-step flows that can wait for the phone; hand those off with a "Continue on iPhone" path or Handoff.
- **Data is already there.** Show cached state immediately, then update. `.redacted(reason: .placeholder)` beats a spinner; a stale timestamp beats both.

## Structure

- **`NavigationStack`** for hierarchy and a **vertical page `TabView`** (`.tabViewStyle(.verticalPage)`, watchOS 10+) for peer screens driven by the Digital Crown. No horizontal tab bars.
- **Toolbar placements** (`.topBarLeading`, `.topBarTrailing`, `.bottomBar`, watchOS 10+) hold secondary actions; keep the content area for content.
- **Full-bleed backgrounds** carry identity: `.containerBackground(_:for: .navigation)` or `for: .tabView` (watchOS 10+) with a tinted gradient from the brand hue, not a black void and not a photo.
- **Lists** (`List` with the carousel feel) for anything row-shaped; rows are big, one line of primary text, optional detail.

## Input

- **Digital Crown** scrolls by default; use `.digitalCrownRotation` for values (volume, time, quantities) with haptic detents. Don't make the crown do something surprising.
- **Targets** are large and few: two buttons across at most. Full-width `Button`s with `.buttonStyle(.borderedProminent)` for the one primary action.
- **Double tap** (Series 9+ / Ultra 2) triggers the primary action: `.handGestureShortcut(.primaryAction)` (watchOS 11+).
- **Text input** is dictation, Scribble, or presets. Offer choices before a keyboard.

## Type & color

- **SF Compact** via the text styles; Dynamic Type applies here too. Big numbers use `.fontDesign(.rounded)` and `.monospacedDigit()`. Caption-level text is for the least important thing on screen, if anything.
- **Black is the canvas.** watchOS is dark; the true black bezel blends with the display. Brand color goes into the tint, the container background, and key values, not into large filled panels.
- **Contrast in sunlight:** values and primary text at full brightness; `.secondary` for labels.

## Complications & Smart Stack

- **Complications** (WidgetKit accessory families: `.accessoryCircular`, `.accessoryRectangular`, `.accessoryInline`, `.accessoryCorner`) are often the product. Design them first: one value, instantly readable, honoring the watch face's tinting (`.widgetAccentable()`, `widgetRenderingMode`).
- **Smart Stack** widgets appear when relevant; supply relevance (`TimelineEntryRelevance`, or `RelevanceConfiguration` on watchOS 26+) so the widget surfaces at the right moment instead of competing all day.
- **Always On:** read `@Environment(\.isLuminanceReduced)`; dim, drop seconds and animation, and keep the key value visible. Update with `TimelineView(.everyMinute)`, not timers.

## Motion & haptics

- Motion confirms: a check that draws in, a value that rolls (`.contentTransition(.numericText())`), a symbol effect. Nothing ambient; it costs battery and attention.
- **Haptics are the voice of the watch.** `.sensoryFeedback` (watchOS 10+) for success, failure, and crown detents; the wrist feels it before the eyes arrive. Never buzz for nothing.
- Honor Reduce Motion.

## Verifying the build

- Build and run on a watch Simulator paired with the iPhone app when they share data: `xcodebuild -scheme <S> -destination 'platform=watchOS Simulator,id=<UDID>' build`, then `xcrun simctl io <UDID> screenshot .impeccable/shots/<name>.png`.
- Capture the smallest and largest shipped case sizes (for example 40 or 42 mm, and 46 mm or the 49 mm Ultra), with the largest text size, and each complication family in a tinted face.
- Glanceability, haptics, crown feel, and Always On need hardware. Say which produced the evidence.

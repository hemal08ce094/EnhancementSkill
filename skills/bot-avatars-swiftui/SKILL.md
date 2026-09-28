---
name: bot-avatars-swiftui
description: Add Bot Avatars (github.com/hemal08ce094/BotAvatarsSwiftUI), animated glossy 3D bot characters with living faces ported from libraries.dev/bots, to an iOS 17+ or visionOS SwiftUI app. It adds the package, puts avatars on AI assistant messages, agent rosters, chat headers and empty states, drives idle, working and sleeping from the app's own state, and can create custom bots from SVG outlines. Use when the user asks for bot avatars, agent avatars, an animated assistant character, a mascot for an AI feature, libraries.dev bots in SwiftUI, or to add or apply Bot Avatars to an app.
---

# Add Bot Avatars to a SwiftUI app

The package is `https://github.com/hemal08ce094/BotAvatarsSwiftUI`, product `BotAvatars`, from `0.1.0`. It needs iOS 17 or visionOS 1, and has no dependencies. The wiring steps are in `references/xcode-package.md`.

## 1. Preflight

- Check the deployment target. If it's below iOS 17, stop and ask. Don't wrap every call site in `#available`.
- Take the scope from the request. "Give the assistant an avatar" means the assistant's messages and header, not every screen.
- Find the AI surfaces and the state that drives them: `grep -rn "isLoading\|isStreaming\|isThinking\|isTyping\|Agent\|Assistant" --include=*.swift`. Read each call site before editing.

## 2. Add the package

Follow `references/xcode-package.md`, then build once before changing any UI.

## 3. API

```swift
import BotAvatars

BotAvatar(type: .clover,            // 18 types: clover flower triangle square blob ghost circle drop star droid mech alien hexagon cat cloud pill pebble puddle
          face: nil,                // .eyes | .mouth (nil = the type's own)
          state: .default,          // .default (idle) | .working | .sleeping
          size: 64,                 // points; lays out size×size, hops overdraw above
          color: nil,               // BotColor("#FF5C8A")
          shading: .plastic,        // .plastic .crisp .smooth .flat
          interactive: true,        // tap = hop + turn, drag = look at finger
          whirl: .off, jump: .defaults)

BotAvatar(shape: myShape, ...)      // custom body: BotShape
BotShape(name:svg:parts:color:face:faceX:faceY:faceScale:fit:)
BotAvatarType.star.botShape.withParts(BotAccessory.antenna.svg)
BotAvatarStage { grid }             // one canvas for many avatars (not inside List)
.botAvatarPointer()                 // drag anywhere over a container steers its bots
```

## 4. Map the app's state to the bot's state

| App condition | `state` |
|---|---|
| waiting for input, online, idle | `.default` |
| request in flight, streaming, tool running, generating | `.working` |
| offline, paused, disabled, rate-limited, quiet hours | `.sleeping` |

Compute the state from the flags the app already has, e.g. `state: vm.isStreaming ? .working : .default`. Never add timers just to animate it.

## 5. Where avatars go

| Surface | Pattern |
|---|---|
| assistant message row | `BotAvatar(type:, size: 32–40)` leading the bubble, `interactive: false` inside scrolling lists |
| chat header / nav bar | `size: 28–32` in a toolbar item |
| agent list / roster | one type per agent (stable: pick from a hash of the agent id), `size: 44–48` |
| empty state / onboarding | `size: 96–140`, interactive, centred above the copy |
| brand mascot | a custom `BotShape` from the brand's SVG outline, `fit: true` |

Give each agent a stable type and colour, derived from its id or its role. Don't pick them at random on every render.

## 6. Gotchas

- **Lists:** don't wrap a `List` in `BotAvatarStage`. Its overlay can't follow scrolling rows, so avatars draw on the wrong rows. Use the stage only for static grids or `LazyVGrid`s inside a `ScrollView`, and let `List` rows keep their own canvases.
- **Scrolling:** set `interactive: false` on avatars inside scroll views, because the drag-to-look gesture competes with scrolling.
- **Clipping:** a hop rises above the frame. Don't `.clipped()` the avatar or its row, and leave about 0.3 × size of room above it.
- **Custom SVG:** use a single closed outline. Holes and strokes don't extrude. Keep `faceY` inside the widest part of the body. Accessory antennae attach at y≈32 in the 100-unit box, so they suit bodies whose top sits around y 20–35 (pill, droid-like shapes, domes).
- **Colour:** `saturation` defaults to 1.5, the web's look. For a brand colour exactly as given, pass `saturation: 1`.
- **Reduce Motion** is handled already (a still pose). Don't add your own animation on top.

## 7. Verify

1. Build for every platform the target supports and fix every error.
2. Run in the simulator, force each state (idle, working, sleeping) through the app's own flags or a debug toggle, and take screenshots with `xcrun simctl io <udid> screenshot`, in dark mode too.
3. Report where avatars were added, which type or colour each agent got and why, how state is derived, and anything left alone.

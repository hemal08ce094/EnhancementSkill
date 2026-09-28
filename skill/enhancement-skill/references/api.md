# HumanTouch API

```swift
import HumanTouch   // also re-exports DesignSkills, Drawably, ThinkingOrbs, BotAvatars (iOS/visionOS)

// Brief → direction
TouchProfile(name:audience:feeling:energy:warmth:craft:stakes:moment:assistant:)
TouchProfile.calmCompanion / .trustedTool / .playfulMaker / .boldPerformer / .presets
TouchDirection(profile)                  // .theme .handDrawn .assistant .orbSpeed .spring .haptics .rationale
direction.overriding(theme: "riso")      // pin a DesignSkills slug, keep the rest
TouchDirector.resolve(profile)           // same as TouchDirection(profile)

// Apply at the root (theme + Drawably pen colors from the theme + direction in the environment)
RootView().humanTouch(profile)           // or .humanTouch(direction)
@Environment(\.touchDirection) var direction

// Direction-aware views
TouchThinking(.solving, size: .small, label: "Thinking")     // Thinking Orb at the profile's pace
TouchAssistant(.idle | .working | .resting, size: 40, interactive: false)
                                         // bot, orb or nothing per direction; orb fallback on macOS
Text("3 days").touchEmphasis(.underline | .highlight | .circle)
                                         // pen mark if hand-drawn is allowed, else primary + semibold
TouchCard(expressive: true) { … }        // DrawablyCard when handDrawn == .controls, else ThemedCard
TouchButton("Start", role: .primary | .secondary | .destructive, expressive: true) { … }
                                         // haptics by direction.haptics
view.touchAnimation(value: state)        // direction spring, off under Reduce Motion
```

Everything from the underlying kits stays available: `.themedFont`, `.themedSurface`, `ThemedCard`, `.drawablyUnderline()`, `ThinkingOrb`, `BotAvatar`, and so on. See each kit's skill in `skills/`.

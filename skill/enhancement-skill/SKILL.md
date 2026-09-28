---
name: enhancement-skill
description: Give a SwiftUI app the human touch that App Store editors notice. It first understands who the app is for and how it should feel (a written Touch Brief), then turns that into one coherent direction and applies it with the HumanTouch package (github.com/hemal08ce094/EnhancementSkill), which clubs five kits - DesignSkills (67 design systems), Drawably (hand-drawn pen sketches), Thinking Orbs (AI thinking indicators), Bot Avatars (animated assistant characters) and Impeccable (SwiftUI design audit and craft rules). Use when the user wants an app to look and feel more polished, more human, more distinctive, "feature-worthy", "Apps We Love" or "App of the Day" ready, asks to enhance or elevate an app's look and feel, or wants to pick and combine these kits for their app.
license: MIT
metadata:
  author: hemal08ce094
  package: https://github.com/hemal08ce094/EnhancementSkill
---

# Enhancement Skill: human touch for SwiftUI apps

Editors feature apps that feel like someone cared about a specific person using them. The failure mode this skill exists to prevent is the opposite: every kit applied at once, a costume instead of a character. So the order is fixed: **understand the people, write it down, derive one direction, apply only what the direction calls for, then audit.**

The five kits, and what each is for:

| Kit | Skill | Role in the direction |
|---|---|---|
| DesignSkills | `design-skills-swiftui` | The world: palette, type, surfaces, components (one style per app) |
| Drawably | `drawably-swiftui` | The human mark: pen accents or sketched controls, only where craft calls for it |
| Thinking Orbs | `thinking-orbs-swiftui` | How AI work looks while it happens |
| Bot Avatars | `bot-avatars-swiftui` | The assistant as a character, only when people talk to it |
| Impeccable | `impeccable-swiftui` | The craft floor and the audit: HIG, accessibility, states, motion |

All five are bundled in this repo under `skills/`. Load a kit's skill only when the direction uses that kit, and follow it for that kit's details.

## 1. Understand the humans (never skip)

Read the app before asking anything: README, `PRODUCT.md`/`DESIGN.md` if present, App Store metadata (`fastlane/metadata`, `docs/`), the main screens, the asset catalog, and any AI features (`grep -rn "isStreaming\|isThinking\|Assistant\|Agent" --include=*.swift`).

Then fill the Touch Brief in [references/touch-brief.md](references/touch-brief.md). Infer everything you can from the code and copy; ask the user **at most three** short questions for what the code can't tell you (usually: who exactly, the moment they open it, the one feeling to leave them with). Write the result to `TOUCH.md` at the project root and show it to the user in a few lines. If the project already has `PRODUCT.md` from impeccable, extend it rather than contradicting it.

The brief ends in six numbers the package understands: energy, warmth, craft (0 to 1), stakes (low/everyday/high), moment (glance/task/linger/play), assistant (none/quiet/character).

## 2. Derive the direction

Resolve the brief with the package, or by hand with the same rules in [references/mapping.md](references/mapping.md):

```swift
let profile = TouchProfile(name: "Tend", audience: "...", feeling: "...",
                           energy: 0.3, warmth: 0.8, craft: 0.6,
                           stakes: .everyday, moment: .linger, assistant: .quiet)
let direction = TouchDirection(profile)     // theme, handDrawn, assistant, spring, haptics, rationale
```

Present the direction to the user as a short pitch: the style, where the pen appears, what the assistant looks like, how it moves, and the `rationale` lines. If the team already has a brand world, keep it: use `.overriding(theme:)` only to match, or skip DesignSkills and use the other kits against their own tokens. **Rules that are not negotiable:** high stakes never get sketched controls or a playful style; glance surfaces stay clean; one DesignSkills style per app; a bot only when people converse with the assistant.

## 3. Apply

Add the package (Xcode ▸ Add Package Dependencies ▸ `https://github.com/hemal08ce094/EnhancementSkill`, product `HumanTouch`, from `0.1.0`; needs iOS 18, macOS 15 or visionOS 2). It brings the four runtime kits with it. API in [references/api.md](references/api.md).

1. Root once: `.humanTouch(profile)` (applies the theme, pen colors from that theme, and the direction).
2. Convert screens in the style's terms: read `skills/design-skills-swiftui/SKILL.md` and that style's own skill in the DesignSkills repo (`skills/<slug>/SKILL.md`). Keep native navigation, lists, sheets and toolbars.
3. Where the direction says so, and only there:
   - `handDrawn == .accents`: `.touchEmphasis()` on one or two key words or numbers per screen; Drawably arrows in onboarding coach marks.
   - `handDrawn == .controls`: `TouchCard(expressive: true)` / `TouchButton(expressive: true)` on onboarding, empty states, rewards, share cards. Everyday Operate screens keep themed controls.
   - `assistant == .orb`: replace AI spinners with `TouchThinking(state)`; pick the state from the table in `skills/thinking-orbs-swiftui/SKILL.md`.
   - `assistant == .bot`: `TouchAssistant(state, size:)` on assistant messages, the chat header and the empty state; derive state from the app's flags.
4. Motion and feel: `.touchAnimation(value:)` for state changes, `TouchButton` for primary actions (haptics included). Add a single signature moment (the first-run reveal, a completion, a streak) per the `delight` playbook in impeccable; not one per screen.

## 4. Audit like an editor

Run the impeccable detector (`skills/impeccable-swiftui/scripts/impeccable-swiftui detect`) and fix what it finds in scope. Then walk [references/editorial-checklist.md](references/editorial-checklist.md) and report each item as done, not applicable, or a recommendation. Build every platform the target supports; screenshot the changed screens in light, dark and one accessibility text size.

## 5. Report

Tell the user: the Touch Brief in three lines, the direction and why, the screens changed, what was left native and why, the checklist results, and the two or three highest-value next steps toward a feature (often a widget, an App Intent, or the first-run moment).

# The five genres

For each genre: when it fits, its rules, how to stand out inside it, how to build it natively, and how it goes wrong.

## 1. Quiet

**Fits:** productivity, planners, finance, travel, utilities. Apps opened to get something done.

**Rules**
- A neutral background and one accent colour.
- Type does the work: big numbers, small labels, generous space.
- No decoration.

**Stand out:** stay calm everywhere, then give people one signature moment they want to screenshot. A plain list that takes over the Lock Screen when the thing it tracks goes live. A plain planner that shows the whole day as one coloured timeline.

**Native:** system materials, `List` and `Form` left recognisable, one tint, SF Symbols in one weight, Live Activities for the signature moment.

**Goes wrong when:** a second accent appears, cards gain shadows, or every row gets an icon.

## 2. Character

**Fits:** wellness, habits, learning, companions, kids. Apps that need people back every day.

**Rules**
- A character with real emotions.
- Rounded shapes and bold colours the app owns.
- Big celebrations when the person gets something right.

**Stand out:** give the character a job and a story. It grows, reacts or talks because of what the person did. If you deleted it, the app should stop working.

**Native:** the character appears in the widget and the notification, not only in the app. State drives its expression. Haptics on the celebration. A still form for Reduce Motion.

**Goes wrong when:** the mascot sits in a corner of an ordinary dashboard.

## 3. Atmosphere

**Fits:** sleep, meditation, focus, mood, sky and nature. Apps people step into more than use.

**Rules**
- Full-screen imagery or 3D.
- Dark or soft colour.
- Slow motion and very little text.
- Sound is part of the design.

**Stand out:** find one material nobody else owns (an object, a photograph, a texture) and put it everywhere: the icon, the home screen, the score, the marketing.

**Native:** real photography or RealityKit over drawn glyphs, materials used sparingly, long eased transitions, a sound design with a mute path, text capped to a few words per screen.

**Goes wrong when:** a generic symbol or gradient stands in for the material, or data tables arrive without their own discipline.

## 4. Data

**Fits:** fitness, health, sleep tracking, money. Apps that turn a life into numbers.

**Rules**
- One hero number per screen.
- Colour means something (good, warning) and is never decoration.
- Rings and gauges before tables.
- Numbers roll when they change, so the screen feels alive.

**Stand out:** do not stop at the number. Say what it means in a plain sentence and what to do about it.

**Native:** `.contentTransition(.numericText())`, monospaced digits, Swift Charts, `Gauge`, a semantic colour set written down once, and a sentence under every hero number.

**Goes wrong when:** there are six equal numbers on a screen, or colour is used for variety.

## 5. Loud

**Fits:** social, events, dating, creator tools. Apps where the user's taste is the product.

**Rules**
- Huge, expressive type.
- The user's content is the design.
- Themes and effects the person picks.
- Copy with personality.
- The layout underneath is strict. Only the skin is loud.

**Stand out:** let people make it theirs. Each theme, sticker or effect they choose is a reason to share and a reason to pay.

**Native:** a strict grid and native navigation under a themeable layer, user media full-bleed, share output rendered at a fixed size.

**Goes wrong when:** the layout is loud too, and nothing can be found.

## Where categories are heading

Trackers show the pattern. First came the dashboard (search, log, read a chart). Then the same chore with a companion, because people abandon chores and keep looking after something that needs them. Now come apps that are barely opened: they live in a widget, on the Lock Screen, or step in at the moment they are needed. When planning a feature, ask which of these three forms it should take before drawing a screen.

## Worked example: an Atmosphere app that carries Data

An AR plane-spotting and sky app, audited on a branch in November 2026. It already had a dark sky, real Moon photography, a rolling hero count, specific transit alerts and widgets. The audit found six breaks and fixed only those.

| Break | Rule | Change |
|---|---|---|
| The paywall led with a sparkle symbol in a glow | Atmosphere: one material nobody else owns | The hero is the real Moon with a plane crossing it, which is the moment the app is known for |
| "19 aircraft overhead" stood alone | Data: say what the number means | One sentence names the closest plane, its type, height and direction |
| An empty sky read "Reading your sky…" forever | Skipped moments: the empty screen | "Quiet sky." plus what to do next, shown only after loading really finished |
| Selected was gold on Home and blue elsewhere | One meaning per colour | Gold means selected and primary everywhere; blue is for text links |
| Onboarding had its own cream button | One system | It uses the same primary button as Home |
| The nightly notification was titled "Tonight's sky" | Copy like a person; the notification is a screen | The title carries the fact ("Saturn is up tonight") |

What made the audit cheap: the app's `DESIGN.md` was one page (genre, the one material, the signature moment, a colour-meaning table, voice, the skipped moments, build order), and every change traced to a line in it.

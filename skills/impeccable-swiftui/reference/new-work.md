# New visual work

Use this flow for a new screen, flow, or feature surface, or a replacement visual identity. PRODUCT.md owns product truth. DESIGN.md owns durable visual decisions. A surface brief at `.impeccable/surfaces/<name>.md` keeps the strategy that belongs to one screen or flow. Complete [init.md](init.md) first when PRODUCT.md is missing; a missing DESIGN.md does not route back to init.

## 1. Decide what is already true

Read DESIGN.md, representative views, the asset catalogs (colorsets, imagesets, the app icon), `Font` / `Color` / `ShapeStyle` extensions, custom `ButtonStyle`s, and bundled fonts. `context` already listed where they live.

- **Redesign:** preserve product truth, content, function, navigation model, and explicit brand commitments; replace the old visual world rather than polishing it. The old look is evidence of what the subject is, not authority over what it becomes.
- **Established world:** inherit it. A missing DESIGN.md does not erase a coherent identity already in the Swift code; document it instead of inventing a replacement.
- **Incomplete brand:** an app icon and a tint, little else. Preserve confirmed assets and recognizable traits, then expand the system with the user for this surface.
- **No visual authority:** stock SwiftUI, default blue, no custom type. Create a new world with the user.

A section, row type, sheet, state, or feature inside an established screen inherits that screen. Never turn a local addition into an identity exercise.

## 2. Ask what will change the work

Before implementation, get the user's answer with the AskUserQuestion tool (plain text and stop, without it). Two or three related questions; a precise request needs only a compact confirmation. Skip settled facts, not the confirmation: DESIGN.md settles the world, not this screen's purpose or concept.

- **Persuade** (onboarding, paywall, first launch, upgrade prompts): who must act, what they should believe, which real proof or assets earn that belief.
- **Operate** (working screens, editors, lists, settings, dashboards): the task, information, important states, frequency, constraints.
- **Read** (articles, help, changelogs, reading views): the reader's question, source material, structure, wayfinding.
- **Experience** (games, creative canvases, players, immersive visionOS spaces): what leads, how exploration unfolds, which interaction matters.

Across modes, ask what success looks like, what must remain untouched, and what would make a polished result feel wrong. Never ask for point sizes, hex values, or canned aesthetic lanes.

## 3. Choose the right amount of invention

### Extend an existing screen

Inherit its world and composition. Resolve only the new purpose, content, hierarchy, states, interaction, and how the addition joins the navigation around it. No direction round; no DESIGN.md change unless the user approves a durable system change.

### Create a whole screen inside an established world

Keep the visual system fixed. Derive five to seven materially different structures from the content, the task, and how people hold and use the device: one scrolling column, a `NavigationSplitView` with an inspector, a canvas under a floating control cluster, a sheet with detents over a live map, a `Grid` of glanceable tiles. Order them by resonance, then roll three instead of taking the top three (`echo $((RANDOM % 7 + 1))`, re-rolling duplicates). The dice break the ranking rut; the user keeps a real choice.

Present the three through AskUserQuestion as equal options, first roll leading, each with its composition and cost in one line. With image generation and a comp build path, first render one comp per option into `.impeccable/mocks/decision/`, anchored on a Simulator capture of an existing screen as the reference image, and `open` them. Locking an option is the approval: a locked comp builds comp-led and discharges [visualize.md](visualize.md)'s round; a locked text option builds code-led. Never run this round for a local extension or a precisely specified request.

### Create or replace the visual world

A native app's world is not a website's. The HIG governs a large layer users read as the platform itself; brand lives in the layer the platform leaves open. Know the border before inventing anything:

| The platform leaves open (the world lives here) | HIG governs (the world conforms here) |
|---|---|
| Tint and the color system: role-named asset colors with Any / Dark / High Contrast | Navigation model: tab bar, stack, sheets, split views, windows |
| Type: a display face via `Font.custom(_:size:relativeTo:)`, `.fontDesign`, `.fontWidth`, weight contrast | System chrome: bars, toolbars, Liquid Glass controls, search, menus |
| Iconography: SF Symbols weight, scale, rendering mode; custom symbols | Control behavior: toggles, pickers, steppers, alerts, share sheet |
| Content materials: surfaces, texture, photography, illustration, charts | Gestures: edge-swipe back, swipe to dismiss, pull to refresh |
| Motion signature: named springs, transitions, `.symbolEffect`, numeric text | Safe areas, Dynamic Type, text styles, 44 pt targets |
| Haptics and sound: one `.sensoryFeedback` vocabulary | Permission prompts, keyboard, system alerts |
| App icon (light, dark, tinted, clear), launch screen, widgets, Live Activities, empty states, copy voice | VoiceOver, Reduce Motion, Increase Contrast, Reduce Transparency |

The gray zone is a custom control where the product's mechanism *is* the control: a dial for a kitchen timer, a scrubber for a tape-style audio editor. Build it only when it carries the mechanism, and pay the platform's dues: `.accessibilityAdjustableAction`, `.sensoryFeedback`, keyboard support on iPad and Mac, a 44 pt hit shape.

1. **Name the ground.** The product's unique mechanism in one sentence, the audience's real scene (hands, posture, light, attention), its cultural home, and what this first surface must prove. Name the app this category always ships (the meditation app with a gradient orb, the finance app with a line chart on a card, the AI app with a sparkle on indigo) and its predictable opposite: both are the rut and stay off the list. A brief that paints its own picture (a product name, a governing metaphor) adds its literal reading to the rut; spend at most one candidate on it.
2. **List seven.** From the audience's cultural world, seven concrete visual systems, artifacts, places, or rituals they know by heart, each with one line on why it resonates and can carry the mechanism, ordered by resonance. That world includes its graphic and screen traditions: notation, signage, publications, hardware readouts (a transit signage standard, a darkroom timer, race telemetry, a seed catalog). What would this thing be as a physical instrument; what did its world look like before apps? Near-duplicates count once. When more than three share one material family, you stopped at the most obvious artifact; dig until the list spans at least three.
3. **Make directions.** Each becomes a complete direction: a reusable visual world, expressed in the open layer, joined to a concrete first-screen experience.
4. **Roll.** Assign the direction by die, not rank: `echo $((RANDOM % 7 + 1))`. Writing Swift for a new or replacement world before the roll has run is a contract violation, whatever the time pressure; the roll is what keeps every run from converging on the category default. Then derive two **challengers**: working interface languages from outside the category you would never have picked first (a field recorder's LCD, a departure board, a letterpress specimen). Fuse each (the challenger supplies form and grammar, the product every fact) and judge it against the assigned direction on exactly two axes, audience identification and product clarity: **wins** (both; becomes the build candidate), **competitive** (one; a full alternate), **declined** (neither). A declined challenger is not spent: name the one discipline it has that the assigned direction lacks (a palette's total commitment, a grid's density courage, a control's mechanical honesty) and raise the assigned direction to match, written as its own line named for its donor. A raise transfers discipline, never clothes; one world owns the screen.
5. **Present.** One direction, fully committed and already raised: world, first screen, the user's path, signature interaction, reach into system surfaces, honest risk. AskUserQuestion takes at most four options, in order: the assigned direction (with its raise lines); your top-ranked candidate when the dice did not assign it, labeled "Impeccable's pick", its risk line naming its familiarity when true; the strongest winning or competitive challenger; the standing exit, last. One pick, never a ranked list: a lineup hands selection back to a taste function and invites the safest card. The free-text answer carries re-roll: plain (a fresh hand), safer (conventional candidates plus the platform standard), bolder (foreign forms only). "Bolder" or "safer" here means these registers, never the `bolder` or `quieter` commands.

**Decision comps.** With image generation and a comp build path, render one comp per full option into `.impeccable/mocks/decision/<option>.png` before asking (with parallel subagents, one `impeccable-swiftui-asset-producer` per card), under [visualize.md](visualize.md)'s frame and prompt discipline, each in its own palette, type, and material at equal fidelity, and `open` them for the user. The chosen comp becomes option one of the comp round, or, code-led, the finish review's critique reference. Unchosen comps imply no approval.

**The standing exit** is the platform standard, played straight: system colors, SF Pro, stock controls, one considered tint, Apple's own apps as the bar. It is the user's door, never yours: never recommend it, never weigh it against the roll, never let it soften the dealt directions. Taken, convention becomes the commitment: ask for two or three apps this should sit alongside, make their craft the bar, and execute without irony or smuggled quirk. Weather and Fitness are not timid.

Re-roll eliminates every direction already shown; after two in a row, ask what quality is missing. Re-roll on your own only on named factual grounds, never taste. A user- or brief-pinned direction beats the roll, always; where only the roll's materials conflict with a pinned constraint, translate the material and name the translation. When no one answers the first real round, proceed with the assigned direction and state the assumptions in your first reply.

Every direction on the list must be viable: true in every relationship it shows, a real palette and component family, workable across the shipped device classes, text sizes, and both appearances. Truth binds claims, not demonstrations: author sample content at full fidelity in DEBUG seeds and Preview fixtures and hand the user the list of what to replace; prices, ratings, subscriber counts, awards, and capabilities stay uninventable. Refusing a bold direction because its demo data does not exist yet is the timidity reflex wearing honesty's clothes.

Per mode: **Persuade** makes the offer intelligible, the primary action thumb-reachable, and shows something only this app can prove; a paywall that hides the price or Restore has not finished translating. **Operate:** expression never obscures task, state, or affordance. **Read:** wayfinding holds at every text size. **Experience:** the work leads from the first frame.

## 4. Commit the world

**Color strategy before colors.** Restrained (system neutrals plus one tint; the default for Operate and Read), Committed (one saturated color owns 30–60% of the screen), Full palette (three or four named roles), or Drenched (the screen *is* the color). Persuade and Experience have permission for the bolder strategies; take them when the brief allows. Color commits at screen scale, fields that own regions, not accents scattered over `systemGroupedBackground`. Every role is an asset-catalog color with Any and Dark appearances (High Contrast where contrast is tight), named by role, never by hue. The tint belongs to interaction; decoration is not its job.

**Appearance is a scene.** Write one sentence of physical scene (who, where, under what light) and let it pick the primary design target. Both appearances ship regardless; forcing one with `.preferredColorScheme` needs a reason the user would thank you for (a darkroom timer, a night-sky viewer).

**Type like objects from the subject's world.** SF Pro carries Operate and Read: body, labels, and controls stay on the system face and its text styles. A brand face belongs in display moments, bundled via `UIAppFonts` and set with `Font.custom(_:size:relativeTo:)`. Persuade and Experience want a face with a point of view. Reflexes that mean you stopped looking: Inter, Poppins, Montserrat, Roboto, Open Sans, Lato, DM Sans, Plus Jakarta Sans, Space Grotesk, Manrope, Outfit, and for display Fraunces, Playfair Display, Cormorant, Syne. The native reflexes tell just as much: `.fontDesign(.rounded)` everywhere because the app is "friendly", New York because the subject is "bookish", SF Mono because it is "technical". Using one anyway needs a reason no other choice satisfies, and a subject association is never that reason. The system face's own range (`.fontWidth(.compressed)` through `.expanded`, ultralight through black, `.monospacedDigit()`) is often the stronger, cheaper, more native move.

**Symbols, motion, and haptics are the world, not garnish.** One SF Symbols weight and rendering mode per context, held; custom symbols from the SF Symbols app template when the product's nouns have none. Name two or three springs (bounce ≤ 0.15 unless the world is genuinely playful) and the haptic vocabulary (`.selection`, `.success`, `.impact(weight:)`) once, and reuse them everywhere.

**Liquid Glass stays chrome.** On iOS 26+ the system glazes bars; `glassEffect`, `GlassEffectContainer`, and `.buttonStyle(.glass)` are for your own controls that behave like chrome, gated with `if #available`. Glass on content cards is glassmorphism renamed (`glass-by-default`).

**Calibration.** AI-made apps cluster around a few looks regardless of subject: an indigo-to-violet gradient, frosted cards, a sparkle in a tinted rounded square; near-black with one neon accent and glowing edges; warm cream, New York display, a terracotta accent; a grid of 24 pt-radius white cards with soft shadows, each holding an SF Symbol in a pastel tile. All are legitimate when the brief asks. Where it leaves the aesthetic free, landing in one means the self-check failed: if someone could guess your look from the category alone, or from category-plus-avoidance, rework. Negative constraints (no gamification, no hype) rule out devices, not energy. A pinned world pins the world, not its softest rendition.

Your measured rendition prior: warm, bookish, family, and child-facing subjects come out as cream grounds, italic serif display, and lamplight, even when the direction never asked. Treat that palette as spent: if OWN-WORLD says cream, paper, parchment, ivory, or lamplight for a Persuade surface the brief did not pin, rework it from the world's saturated materials (book cloth, thread, endpapers) first.

## 5. Record the decision

Before code, write the chosen direction under `## Direction contract` in the surface brief, `.impeccable/surfaces/<name>.md` (kebab-case: `onboarding`, `paywall`, `library`). Read an existing brief first (`context --target` prints the matching one). Create it even when nothing else about the surface needs persisting.

```markdown
# <Surface name>

## Scope
Mode, platforms and device classes, entry points, states in scope.

## Brief
Audience, job, primary action, proof and content, constraints. Nothing copied from PRODUCT.md or DESIGN.md.

## Direction contract
THESIS: the one idea this surface owns and the category-default arrangement it refuses.
OWN-WORLD: palette roles, type, symbol treatment, materials, component language; recognizable with all content removed.
STORY: what the user understands, believes, and does.
FIRST SCREEN: the exact composition on the primary device: what is where, at what scale, where the primary action sits relative to the thumb.
SIGNATURE: the one signature interaction, its named animation, its haptic, its Reduce Motion fallback.
FORM: the chosen form, its rank of seven, the roll that assigned it, its raise lines.
FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance.

## Open decisions
```

Roughly 150–200 words across the blocks. If a block reads like a mood, the direction is not decided yet. Comp-led builds later add `## Approved comp`, `## Region map`, and `## Component review`. Reread the brief once and verify every block before building. Later agents reload it across sessions: a screen that looks complete with FINISH undischarged is abandoned at the finish line, not done.

Never copy the contract into anything the app ships: Swift comments, string literals, `Localizable.xcstrings`, accessibility labels, Info.plist, asset names. `.impeccable/` stays at the repository root, outside every target and synchronized folder.

On a new or replacement world, DESIGN.md is written at finish, from the built world, by the documenter; a rulebook written first gets defended against reality instead of describing it. A new world shipped without DESIGN.md is an incomplete run; an ordinary extension does not rewrite it.

**Build path.** Read `buildPath` from `.impeccable/config.json` (the gitignored `config.local.json` wins); with neither, comp-led whenever an image-generation tool is available. It is a standing preference, not a per-surface question. A user who asks in words to switch gets the switch for this surface; one who asks to change the default gets the file updated; when nothing is recorded and they switch, ask once whether to keep it as the default, and write either answer.

- **Comp-led:** the locked direction is visualized before it is built, never skipped. Load [visualize.md](visualize.md): three compositional options, the chosen decision comp plus two variations, one approval point. This step reliably produces the most ambitious composition.
- **Code-led:** the comp round is skipped by contract, never by drift. Its ambition lives in FIRST SCREEN and SIGNATURE, and the finish reviewer audits both in behavior. Code-led is not a discount on commitment.
- **No image generation:** code-led is the only path, stated in one line rather than asked.

For `shape`, return the selected direction to [shape.md](shape.md) and stop before persistence or implementation.

## 6. Build with full commitment

Build the assigned direction, not a safer interpretation of it; the form supplies structure and character, the product supplies every fact. Commit every atom in the open layer: a real `ButtonStyle` on `configuration.isPressed` rather than `.borderedProminent` in default blue, list rows and section headers, `ContentUnavailableView` dressed in the world, tinted toggles and progress, the selection color, the keyboard's submit label. A stock component in default styling inside a committed world is a lapse; a hand-rolled tab bar or back button is the opposite lapse. Land the first build fully committed; later passes clarify, never dilute. In unattended work, the safe rendition is the known risk.

Foundations first, in token files the detector exempts (`Theme.swift`, `Typography.swift`, `Color+Brand.swift`): asset colors with `Color` / `ShapeStyle` accessors, `Font` extensions that scale, spacing constants and `@ScaledMetric` where a dimension should grow with text, named `Animation` values, the haptic vocabulary. Views read tokens; they never hold a hex value or a fixed point size.

### Comp-led: the comp is a contract

An approved comp is a spatial contract, not a mood board; only the user can downgrade it, in explicit words. Models reliably believe their recreation of an image succeeded when it did not, so the build runs in gated phases that compare the screen against the comp instead of trusting memory. Write nothing for a later phase while an earlier one is open. This path asks the builder to hold a measured layout across several rounds; on a small or fast model tier, say so before the direction round and take code-led.

0. **Comps.** The round in [visualize.md](visualize.md), ending with an approved comp recorded in the brief.
1. **Region map.** Every salient region of the comp named in the brief's `## Region map` table, per [visualize.md](visualize.md). Anything painted is a raster asset; text, controls, bars, data-driven charts, and flat shape systems are SwiftUI. Anything not in the map does not exist on the screen: no dividers, cards, or chrome the comp does not show. Three concessions only: fonts (closest obtainable face), SF Symbols standing in for the comp's pictograms (the glyph only, never the control's shape), and genuine defects in the comp.
2. **Assets, then kit review.** Every raster region ships as an asset regenerated at resolution from its crop, with provenance: spawn `impeccable-swiftui-asset-producer` with the brief, the comp, the crops, and the target asset catalog, or produce here under [visualize.md](visualize.md)'s Produce section. A crop is a reference, never a shipping pixel. Screen code waits for the assets: a screen written before them draws its material in gradients. Then build the component kit and complete [component-review.md](component-review.md) before composing the screen.
3. **First screen.** Build only the first screen, on the Simulator whose native resolution matches the comp (1206×2622 is a 6.3-inch iPhone Pro, 2064×2752 a 13-inch iPad Pro), the comp's words verbatim (rewording is a stated decision after this phase), assets placed first. Measure type rather than guess: point size ≈ cap-height px ÷ device scale ÷ the face's cap-height ratio (≈ 0.705 for SF Pro), then take the nearest text style or `relativeTo:` anchor. Capture at the comp's pixel size and compare side by side (`magick comp.png shot.png +append side-by-side.png` with ImageMagick; otherwise open both). Mark each region-map row `match`, `drift`, `missing`, or `contradicted`: missing needs its material, contradicted its structure re-derived from the box, drift gets size and spacing edits. The phase closes when nothing is missing or contradicted and the focal region matches. The ambition is won or lost here: a retry costs minutes, a rebuild verdict at the finish costs the run.
4. **Remaining states.** Empty, loading (`.redacted(reason: .placeholder)` in the world's shapes), error, overflow, the rest of the flow, inside the recorded system and nothing the comp never shows.
5. **Motion and haptics.** The signature interaction, transitions, and feedback, orchestrated once, with Reduce Motion fallbacks.
6. **Adaptive.** Every other device class, both appearances, AX sizes, landscape where supported, the Mac window at minimum size. The first screen holds on the smallest supported iPhone, not only the comp's device; an iPad built as a centered phone column contradicts the composition.

### Code-led

No comp and no apology: FIRST SCREEN and SIGNATURE carry the ambition, and the finish reviewer audits them in behavior. A chosen decision comp rides to the review as the critique reference.

### Both paths

- **The first screen is a thesis, not a header.** Demonstrate the mechanism immediately, at the scale it has in life; do not trap the concept inside a stock `List` row or a card. The memory test: if someone closed the app after one screen, what would they describe an hour later? If the honest answer is a mood, the concept has not committed.
- **Prove, don't claim.** Real-shaped data in the list, a chart with a story in it, the mechanism dramatized. Sample data at full fidelity, marked as sample in code; claims stay uninventable.
- **Author the assets; never substitute chrome.** Great apps live on made content: names, entries, copy, artwork, empty-state illustration, the icon; every blank the ask round left open is yours to author. Gradients, stacked materials, glow shadows, and SF Symbols in pastel tiles where an authored asset belongs are the gap wearing chrome.
- **Build the platform's leverage.** When the world names a technique, build it, not a static imitation: `Canvas` and `TimelineView`, Metal shaders (`.colorEffect`, `.distortionEffect`, `.layerEffect`), `matchedGeometryEffect` or `.navigationTransition(.zoom)`, `PhaseAnimator` / `KeyframeAnimator`, `.symbolEffect`, RealityKit on visionOS.
- **Pace the scroll.** Vary density, scale, and quiet inside one grammar; a long screen ends on a real close. One spacing rhythm, more space above a section header than below it.
- **Motion is material.** Orchestrated once, not scattered `.animation` calls. Content is visible by default, and Reduce Motion gets a crossfade.

Preserve accessibility, performance, the navigation model, project conventions, and working behavior.

## 7. Inspect and finish

**One batched capture round, one confirmation round.** Capture the target screen on each shipped device class in light, dark, and a large accessibility size, plus the smallest supported iPhone, the Mac window at default and minimum size, and the Duo's inner display where the app ships to it. Critique against the request and the contract, fix material gaps in one batch, confirm with one more round; two rounds is the ceiling, and fixes batch between them rather than earning per-tweak captures. Comp-led, the confirmation round repeats the region-map walk against the comp at its own pixel size; never judge fidelity from memory or a thumbnail. On a Persuade surface, a first-time user knows what this is, why it matters, and what to do within seconds.

Make screens reachable: a `#if DEBUG` launch argument that jumps to a screen and seeds a named data state (`-ImpeccableScreen paywall -ImpeccableSeed full`, read from `UserDefaults.standard`, where `-key value` arguments land).

```sh
xcrun simctl list devices available            # use UDIDs; names collide
xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,id=<UDID>' \
  -derivedDataPath .impeccable/DerivedData build
xcrun simctl boot <UDID>
xcrun simctl install <UDID> .impeccable/DerivedData/Build/Products/Debug-iphonesimulator/<App>.app
xcrun simctl status_bar <UDID> override --time 9:41 --batteryState charged --batteryLevel 100
xcrun simctl ui <UDID> appearance dark
xcrun simctl ui <UDID> content_size accessibility-extra-extra-extra-large
xcrun simctl launch --terminate-running-process <UDID> <bundle-id> -ImpeccableScreen <screen>
xcrun simctl io <UDID> screenshot .impeccable/shots/<surface>/phone-ax.png
```

Relaunch after changing `content_size`. On macOS, run the built app and capture the window with `screencapture -l <windowid>`. Name captures `.impeccable/shots/<surface>/<device>-<variant>.png` for the classes the app ships: `phone-light`, `phone-dark`, `phone-ax`, `phone-small-light`, `ipad-light`, `ipad-dark`, `mac-light`, `mac-min`, `watch-light`, `vision`.

**A capture is evidence only when valid.** Settle or disable entrance motion first: an element hidden by animation timing reads as missing and gets "fixed" into a regression. Open every file once and confirm it shows what its name claims: right screen and appearance, no launch screen, no leftover redaction, no alert. Say which evidence came from Previews, the Simulator, or hardware; posture, haptics, and performance need hardware.

**Detector.** With the project hook off, run `<skill-base-dir>/scripts/impeccable-swiftui detect --json <changed .swift files>` once, fix what is mechanical, and pass the rest to the reviewer; with the hook on, pass what it surfaced. Never run it again after the review.

After the second round the build thread's polishing is over: no more defect hunts or rebuilds here. What remains ships through the handoffs, where a fresh context finds it better and cheaper.

**Finish review.** Spawn `impeccable-swiftui-finish-reviewer` fresh, with no inherited conversation (a reviewer that inherits your transcript inherits your optimism), and give it: the request, the confirmed answers, the artifact paths (views, token files, asset catalog), the surface brief, every capture path with the set marked required, the detector findings, the approved comp (or, code-led, the decision comp labeled critique reference), [craft-floor.md](craft-floor.md), and each shipped platform's reference ([platforms/ios.md](platforms/ios.md) and siblings). It has no Simulator; a capture you fail to pass is a check it cannot run. Wait with one long timeout. Verify the return has its five sections (a recapture return has one); respawn once on an empty return. Without subagents, run it in-thread from `agents/impeccable-swiftui-finish-reviewer.md` after stepping fully out of the build context, and disclose that.

**Act on the disposition word; there are exactly four.**

- **recapture:** the evidence failed, not the build. Recapture what it names, then run a full review. A review on invalid evidence binds nothing.
- **rebuild:** fidelity failed wholesale. Skip the fix batch: re-derive the named regions, produce the named assets, recapture everything, and send it for a fresh full review. Tell the user what is happening; consult them only on a second rebuild or when it would discard content they approved.
- **fix:** apply the material fixes in one batch, rebuild once, recapture over the same files, and return them to the same reviewer (SendMessage to its agent id) to score each fix resolved, partial, or unresolved. Two rounds ends an unattended run; attended, put the open table in front of the user and let them choose between shipping and another round. Stop the moment a round resolves nothing. The reviewer's list is the only list you work from.
- **ship:** nothing is owed; continue to the documenter.

A raster a fix or rebuild creates or replaces keeps provenance under [visualize.md](visualize.md); one it abandons leaves the asset catalog in the same batch.

Report the verdict under the reviewer's word and at its actual scope: "the reviewer scored all three fixes resolved" is supportable, "no issues remain" is not. When the user answers a ship with evidence against it (their own screenshot, a named mismatch with the comp), their evidence outranks every capture you made: send it for a fresh full review. Patching inline and self-certifying is how a rejected screen ships twice.

**Document.** After the last correction, spawn `impeccable-swiftui-documenter` with the project root, artifact paths, surface brief, PRODUCT.md, [document.md](document.md), and the write boundary (without subagents, load [document.md](document.md) and do it here). A new world needs a DESIGN.md with real names and values (asset colors with light and dark hex, text styles and faces, radii, springs), not prose; an extension preserves it and reports drift unrepaired. Finish only when review and documentation are done, then discharge FINISH in the surface brief with the verdict and date.

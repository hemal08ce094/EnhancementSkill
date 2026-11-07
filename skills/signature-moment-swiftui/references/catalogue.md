# Signature moment catalogue

Archetypes seen in Oversight Supply's free sections, with a native mobile reading and the use cases they suit. Names are the originals so you can trace them; the mobile versions are your own work.

## Scroll stories (hero that changes as you scroll)

Seen in: Signal & Soil, Condensation, Transmission, Florilegium, Joiner, Cyanotype, Rootsong, Herbarium, Phototropism, Pigment.

- Pattern: pinned stage, one progress value, three or four chapters, background crossfades, a figure that morphs between chapters, a finale that releases it.
- Signal & Soil in brief: three figures typed from text-glyph particles (an animal, flowers, then the brand word), each sampled once from an image; scroll crossfades four photographs behind them; pointer scatters particles; a click or button sends a ring outward; at the end the particles lift off.
- Mobile reading: paged vertical story with `scrollTargetBehavior`. A `Canvas` figure morphs between chapters. Drag scatters it, tap pulses it with haptic feedback. Reduced Motion shows the four discrete states only.
- Suits: onboarding, product tours, "year in review", a brand-story first launch, a landing screen for a single-purpose app.

## Drag-anywhere tables

Seen in: Collage (photography), Folio (magazine page curl), Vinyl (a turntable you can scratch).

- Pattern: an endless surface. Items wrap around so it never ends. It drifts when idle. Items are tied to labels by hairlines. A Linear/Random switch morphs the whole layout. Tapping an item flies it into a viewer.
- Mobile reading: a 2D pannable surface with decaying velocity, wrapped positions, depth from item size, and `matchedGeometryEffect` into a detail view. The layout switch is a segmented control.
- Suits: photo, recipe, portfolio, plant, wardrobe, collection and moodboard apps; a home screen for a catalogue.

## Sculpt-and-reveal toys (added from five more samples)

Seen in: Transmission (flower as a glyph grid with a decoder lens), Joiner (one photo cut into off-kilter prints that join on scroll), Cyanotype (hold the sun to expose a sheet, then rinse), Phototropism (a meadow that bends toward the touch, with a day-to-night scroll), Vinyl (a record you scratch, with generated music).

- Pattern: the user does something physical to a single object, the object keeps a visible state (exposure minutes, exposures left, time of day), and scroll resolves it into a payoff. Each one ends with a save, share or replay.
- Mobile readings:
  - Transmission: a SwiftUI `Shader` (`layerEffect` or `colorEffect`, iOS 17+) or Metal view. A circular lens follows the finger. Resolution drops automatically when frames run long. If Metal is unavailable, show a still and say so in the copy.
  - Joiner: a `Canvas` or `Image` cropped into tiles from a fixed seed. Visibility is sampled once. A limited "roll" of taps adds stakes and a reload button.
  - Cyanotype: hold-to-expose with a progress ring and `sensoryFeedback`. Render the print at a fixed size, export with `ImageRenderer`, and offer `ShareLink`.
  - Phototropism: the touch point is the light. Use `CoreMotion` tilt as an optional second light. Planted items persist for the session and are capped.
  - Vinyl: `AVAudioEngine` with `AVAudioSourceNode` for generated sound. Create the engine on the first tap, set the audio session category, respect the silent switch, and feed an analyser to the visuals. Drag speed sets playback rate.
- Suits: music, photo, journaling, wellness, plants, kids' apps, creative tools, games.

## Reactive heroes

Seen in: Murmur (voice orb), Horizon (drop a file, a forecast draws), Parlor (faces that watch you type).

- Pattern: the hero is the product demo. The visual reacts to the user's real input.
- Mobile reading: microphone level drives an orb; a pasted or shared file draws a result; typing drives a character's gaze. Permission-denied and no-input states are part of the design.
- Suits: AI assistants, voice apps, finance and forecasting tools, chat, coaching.

## Pricing and plan pickers

Seen in: Studio (live spot availability, reserve and undo), Choice (phone-style picker, total rolls), License (cards priced by size, rolling numbers).

- Pattern: the chosen plan unfolds, numbers roll, and the state is reversible.
- Mobile reading: paywall with a plan picker where the total rolls with `contentTransition(.numericText())`, haptics on selection, and an undo. Respect StoreKit pricing, localisation and intro-offer rules. Never fake scarcity.
- Suits: paywalls, upgrade sheets, service booking.

## 404 and empty states (from the guides)

- Pattern: a dead end made into a small game or object, always with a clear way back.
- Mobile reading: empty states and offline screens that play, with one primary action and a plain explanation.
- Suits: empty lists, no results, offline, permission denied.

## Choosing

| Use case | Start with |
| --- | --- |
| First-run onboarding with a story | Scroll story |
| Collection, gallery or catalogue | Drag-anywhere table |
| AI, voice, chat, coaching | Reactive hero |
| Paywall or plan choice | Pricing picker |
| Empty or error state | Playable dead end |
| Utility with no story | None. Use native structure and polish instead |

## Copy and visual rules the source guides add

- Give the builder decisions, not adjectives. "Modern and clean" means the average.
- One accent colour, used rarely. Mostly neutral. No gradients unless they belong to the brand.
- A real type scale with big jumps and at most four sizes.
- Break symmetry once on purpose: one large item and two small ones instead of three equal cards.
- Use only supplied copy. No invented statistics, testimonials, logos or awards.
- Build one section at a time and review it before the next.

## Patterns every sample shares (use as a checklist)

- **A visible state number from the real engine.** Exposure minutes, exposures left, time of day, frames per second. Never fake it.
- **A fallback that prevents an empty ending.** Cyanotype gives the sheet 9 minutes of sun if you rinse it blank, and says so in the finale copy.
- **A cap on user-made things.** Planted stems stop at 30. The roll has 36 exposures. Caps protect performance and make choices matter.
- **A reset and a replay.** New sheet, Load a new roll, Back to morning, Take it apart.
- **Copy that follows the input.** Touch and pointer variants of the same sentence. On iOS, key it to touch, pointer, Pencil, keyboard and VoiceOver.
- **A failure line, not a failure screen.** Error and off-air states change one sentence and hide the controls that cannot work.
- **Keyboard parity.** Every drag has arrow keys and a rotate key. On iOS, give every drag an accessibility action.
- **Reduced motion parks at discrete states** (start, middle, end), not at a slowed-down animation.
- **Pause when off screen or backgrounded.**
- **Heavy work once, per-frame work small.** Sample, cut and build atlases up front.
- **Idle behaviour.** A slow sun, a drift, a breathing motion, so the screen is alive before the first touch.

## Fleet rule

These specs share one house style: mono small-caps header, serif italic accent word, one lime accent, a pill dock, a finale with kicker, title and button. Do not copy that skeleton between apps. Across the fleet, vary the archetype, the engine, the layout and the copy structure, and never paste identical moment code into two apps. Apple has rejected apps for shared templates (guideline 4.3), so each moment must be built from its own spec.

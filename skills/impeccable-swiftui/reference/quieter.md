Quiet design is harder than bold design. Subtlety needs precision. Reduce visual intensity in screens that are too loud, aggressive, or overstimulating without losing personality or collapsing into a stock `Form`.

---

## Visitor mode

Persuade + Experience: "quieter" means a more restrained palette, more space, more typographic air. Drama is reduced, not eliminated; the POV stays intact.

Operate + Read: "quieter" means reducing visual noise. Fewer tinted backgrounds, flatter rows, less color, less motion, fewer haptics. The app should disappear more completely into the task.

---

## Assess current state

1. **Identify intensity sources**:
   - **Color saturation**: saturated fills, tint spent on decoration, `ai-gradient-palette` gradients
   - **Contrast extremes**: pure black/white slabs (`pure-black-white-surface`), heavy dividers
   - **Visual weight**: `.bold()` and `.heavy` everywhere, every row a card
   - **Surface effects**: `glow-shadow`, stacked shadows, materials on content (`glass-by-default`), `gradient-text`
   - **Animation excess**: looping `symbolEffect`s, `repeatForever` pulses, `bounce-easing`, staggered entrances on every screen
   - **Sensory excess**: haptics on every tap, sounds nobody asked for
   - **Scale**: everything is `.largeTitle` and nothing is `.footnote`

2. **Understand the context**: what the screen is for, who uses it and how often, what is working, and what the core message is.

If any of these are unclear from the codebase, do not guess. Ask the user before continuing (use the AskUserQuestion tool when it is available).

Run `<skill-base-dir>/scripts/impeccable-swiftui detect --json <target>` for the mechanical half; the rule ids above are the loudest offenders it finds.

**CRITICAL**: "Quieter" doesn't mean boring or generic. It means refined and easier on the eyes. Think luxury, not laziness.

## Plan refinement

- **Color**: desaturate, or pull color back to the tint and semantic roles?
- **Hierarchy**: which elements stay bold (very few), which recede to `.secondary` / `.tertiary`?
- **Simplification**: what can be removed entirely?
- **Sophistication**: how does restraint signal quality here?

**IMPORTANT**: Quiet without intent collapses to generic.

## Refine the design

### Color
- **Reduce saturation** in the asset catalog (70–85% of current), in both Any and Dark appearances; retune the High Contrast variants too.
- **One tint.** Tint drives interactive elements; strip it from icons, headers and backgrounds that are not actions.
- **Neutral dominance**: system grouped backgrounds and `.background.secondary` do the work; color is the accent.
- **Hierarchy through styles, not alpha**: `.foregroundStyle(.secondary)` instead of `.opacity(0.6)` (`opacity-hierarchy`).
- **Never gray on color**: on a tinted surface, derive secondary text from that hue (`gray-on-color`).

### Visual weight
- **Typography**: step weights down (`.heavy` → `.semibold`, `.bold` → `.medium`); let text styles, not weight, carry most hierarchy.
- **Space**: more breathing room, fewer rows per screen where the task allows.
- **Dividers and borders**: thinner, fewer, or gone; list separators already exist.

### Simplification
- **Remove decoration**: gradients, glows, patterns, textures, and decorative SF Symbols that do not serve meaning.
- **Simplify shapes**: bring card radii back into the system scale (`over-rounded`), `.continuous` style, one radius per level.
- **Reduce layering**: materials belong to chrome (bars, sheets, floating controls). Content sits on plain surfaces.
- **One shadow language**, subtle and physical, or none.

### Motion and sensation
- **Shorter distances** (8–16 pt, not 40) and calmer springs: `.smooth` or `.spring(duration: 0.35, bounce: 0)`. Never `.bouncy` (`bounce-easing`).
- **Remove decorative loops**: indefinite `symbolEffect(.pulse)` / `repeatForever` go unless they report live state.
- **Haptics**: keep `.sensoryFeedback` for success, failure and selection changes; remove it from ordinary taps.
- **Remove animations entirely** if they don't serve a clear purpose.

### Composition
- **Reduce scale jumps**: fewer text-style steps between adjacent roles.
- **Align to the grid**: bring rogue paddings back onto the spacing scale.
- **Even out spacing**: consistent rhythm instead of extreme variation.

**NEVER**:
- Make everything the same style and weight (hierarchy still matters)
- Remove all color (quiet ≠ grayscale)
- Eliminate all personality
- Sacrifice affordances: buttons still look tappable, destructive actions still read as destructive
- Shrink text below the text-style floor to look "refined" (`tiny-font`, `fixed-font-size`)

## Verify quality

- **Still functional**: can users still accomplish tasks easily?
- **Still distinctive**: does it have character, or is it a default template now?
- **Better reading**: is text easier to read for extended periods, in both appearances?
- **Restrained, not absent**: does the POV survive the cuts?

When the result feels right, hand off to `/impeccable-swiftui polish` for the final pass.

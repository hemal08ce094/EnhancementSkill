# From traits to ingredients

`TouchDirector.resolve` in the HumanTouch package implements exactly these rules; use this table when working without the package or when explaining a choice.

## Style (DesignSkills)

Filter by stakes first, then take the nearest style on the three axes (energy and warmth weighted 1.2, craft 0.8).

| Style | energy | warmth | craft | up to stakes |
|---|---|---|---|---|
| premium | .35 | .40 | .10 | high |
| clean | .20 | .45 | .10 | high |
| minimal | .10 | .50 | .20 | high |
| enterprise | .30 | .25 | .05 | high |
| corporate | .30 | .15 | .05 | high |
| claude | .10 | .65 | .35 | high |
| refined | .25 | .70 | .30 | high |
| levels | .60 | .30 | .10 | high |
| editorial | .25 | .55 | .40 | everyday |
| paper | .15 | .75 | .55 | everyday |
| cafe | .35 | .90 | .50 | everyday |
| friendly | .50 | .95 | .55 | everyday |
| bento | .45 | .70 | .30 | everyday |
| glassmorphism | .55 | .50 | .15 | everyday |
| power | .80 | .30 | .20 | everyday |
| claymorphism | .65 | .85 | .60 | low |
| lingo | .80 | .85 | .45 | low |
| doodle | .60 | .85 | .95 | low |
| riso | .70 | .75 | .85 | low |
| fiction | .75 | .90 | .80 | low |
| neobrutalism | .85 | .70 | .70 | low |
| dramatic | .90 | .35 | .30 | low |
| pulse | .95 | .60 | .40 | low |

The other 44 DesignSkills styles are costumes (matrix, pacman, fantasy, cosmic…). Use them only when the brief pins that world (a retro game, a terminal tool), via `.overriding(theme:)`.

## Hand-drawn texture (Drawably)

| Condition | Level |
|---|---|
| craft ≥ 0.75 | `controls`: sketched cards and buttons on expressive surfaces |
| 0.45 ≤ craft < 0.75 | `accents`: pen underline / circle / highlight on key words, arrows in onboarding |
| craft < 0.45 | `none` |
| stakes high | capped at `accents` |
| moment glance | `none` |

## Assistant (Thinking Orbs / Bot Avatars)

| assistant | Face |
|---|---|
| none | nothing |
| quiet | Thinking Orbs replace AI spinners; no character |
| character | Bot Avatar: warm+lively `clover`, warm+calm `pebble`, cool+lively `mech`, cool+calm `droid`; body color = theme primary |

Orb speed = 0.75 + 0.5 × energy.

## Motion and haptics

- Spring response 0.55 − 0.25 × energy; damping 0.95 − 0.30 × energy (at least 0.9 at high stakes).
- Haptics: `subtle` if stakes high or energy < 0.3; `expressive` if energy > 0.7; otherwise `standard`.
- Reduce Motion turns every spring off; the kits already freeze their own animation.

## Presets

| Preset | Resolves to |
|---|---|
| `.calmCompanion` (journal, sleep, wellbeing) | paper, pen accents, orbs, subtle |
| `.trustedTool` (finance, health records, pro) | enterprise, no sketch, orbs, subtle |
| `.playfulMaker` (kids, learning, creative) | fiction, sketched controls, clover bot, expressive |
| `.boldPerformer` (fitness, events, streaks) | power, no sketch, no assistant, expressive |

# Command guidance

## Workflow questions

Give advice without executing commands; the menu below is only for bare invocations. Consult the relevant command references for prerequisites and scope. The usual arc: `init` once (PRODUCT.md), `document` when code exists but DESIGN.md does not, `shape` before a new screen, build, then `critique` → targeted refine commands → `audit` → `polish` before shipping. `hooks on` keeps the detector watching edits the whole way. The upstream [Impeccable docs](https://impeccable.style/docs/) describe the same arc for the web; the command vocabulary carries over, the web-only commands do not. If the user also requests execution, follow that request.

## No-argument routing: the context-aware menu

Read this when the user invokes `/impeccable-swiftui` with no argument. They are asking "what should I do?" Make the menu context-aware instead of static.

Setup has already run `context`. If it reported `NO_PRODUCT_MD`, the project has no captured context yet: lead the menu with `/impeccable-swiftui init` as the top recommendation (one line on why) and still show the rest below; don't silently jump into init. Otherwise gather signals once, cheaply, then lead with the **2-3 highest-value next commands**, each with a one-line reason pulled from the signals, followed by the full menu (the Commands table in SKILL.md, grouped by category). **Never auto-run a command; the recommendation is a suggestion the user confirms.**

Signals, all read-only:

- From `context` output: `NO_DESIGN_MD`, platforms and deployment targets, the SwiftUI/UIKit mix, design-system evidence.
- `git status --porcelain -- '*.swift' '*.xcassets'` for the dirty tree.
- The newest file in `.impeccable/critique/`, if any: its date, target, score, and P0/P1 counts.
- One detector run (below).

Reason over the signals; there is no score to obey:

- `NO_DESIGN_MD` while Swift views exist → `document` (capture the visual system before anyone drifts further from it).
- No critique on record → for a set-up project with a real screen, `/impeccable-swiftui critique <screen>` is a strong default.
- A critique with a low score or open P0/P1 → `polish` (it reads that snapshot as its backlog and closes it when stale or cleared).
- Dirty Swift files clustered on one screen or feature → scope `audit` or `polish` to those files, naming them.
- Design-system evidence scattered (colors defined in several files, no single Theme/Token file) → `extract`.
- More than one platform shipped, or an iPad/Mac target running a phone layout → `adapt`.
- Otherwise group by intent (build new / improve what's there / push further), tailored to the current screen and platforms.

**Run `<skill-base-dir>/scripts/impeccable-swiftui detect --json <targets>` once**, where targets are the dirty `.swift` files, or else the app's main source folder (the directory holding the `@main` App and its views). Fold the hits into your picks:

- Many `fixed-font-size`, `custom-font-no-relative`, `tiny-font`, `icon-button-no-label`, `tap-gesture-as-button`, `small-touch-target` → `audit`, then `harden`.
- `hardcoded-color`, `pure-black-white-surface`, `opacity-hierarchy`, `gray-on-color` → `extract` (tokens) or `colorize`.
- `gradient-text`, `ai-gradient-palette`, `glow-shadow`, `glass-by-default`, `eyebrow-label`, `numbered-section`, `emoji-icon` → `quieter` or `typeset`; many of them together → `critique` first.
- `bounce-easing`, `section-fade`, `reduce-motion-ignored` → `animate`.
- `deprecated-api`, `screen-bounds-layout` → `adapt` (layout) or `polish`; `any-view` → `optimize`.

A real, current signal beats guessing. If detect errors or the tree is large and slow, skip it and recommend the user run `audit` themselves; never block the suggestion on it.

Keep it to 2-3 pointed picks with the exact command to type. The menu stays the fallback; the recommendation is the lede.

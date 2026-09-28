> **Additional context needed**: which screen or section is the target, and what must stay untouched.

An open direction round owns the word first: "bolder" said while a direction decision is on the table is the Bolder hand register steer, a fresh deal of foreign forms (see [new-work.md](new-work.md)), not this command. This command refines a screen whose world already shipped.

"Bolder" is an amplification request, and almost always it is scoped to something that already exists. The surrounding app, its DESIGN.md, its `Color` assets, `Font` extensions and button styles are the given. Your job is to raise one part to the conviction the rest already implies, without rebuilding anything the brief did not name. The reflex answer, reaching for more effects (a glow shadow, a purple mesh gradient, a material on every card, a `.bouncy` spring), is the opposite of bold; reject it first.

## Scope is sovereign

"Everything else stays" is a literal instruction. Touch only the named target. Do not restyle its neighbors, do not migrate the screen to a new idea, do not add colors, faces, corner radii, shadows, materials, or components the app does not already own. If the existing system genuinely cannot express the direction, do not expand it on your own. Ask the user before continuing (use the AskUserQuestion tool when it is available). Name the exact addition, say a new `Color` asset or a `.fontWidth(.expanded)` display role, and the job it would do.

## Why it reads flat

A screen usually reads flat for reasons its neighbors have already solved. Look at what the rest of the app does that this one does not: the display role at full strength (`.largeTitle` weight, a brand face, `.fontWidth`), the full-bleed hero or the tinted region, the signature symbol treatment, the density and pacing of the list. A flat screen is typically one that quietly opts out of the system's own strongest moves, a `Form` of default rows where the rest of the app composes. The most reliable bolder pass brings the target up to the expressive level its neighbors already reach, in the system's own vocabulary rather than a new one.

## The amplification

- **Amplify what the system already owns.** Reuse its tint, its type roles and its motif at full strength, turned up for this screen rather than invented for it. The bolder version should look more like the same app, not less.
- **Keep content true.** Existing claims, numbers and labels are part of the scope: preserve them unless the user supplies replacements. If real evidence (a real photo, a real stat) is essential to the direction but absent, ask for it.
- **Commit, then clarify.** Half-measures read as noise. Make the one decisive move completely (one oversized number in `.monospacedDigit()`, one region that owns the tint, one full-width image under the safe area) then quiet everything around it with `.secondary` styles and fewer containers so the move is legible. If every element got louder, the screen got flatter.
- **Give it its own rhythm.** The target should read as a peak in the scroll, a shift in density or pace from what surrounds it, not simply more padding and bigger text everywhere.
- **Chrome stays system.** Bold lives in content. Navigation bars, tab bars, toolbars and sheets keep their system behavior and materials; do not hide the nav bar (`hidden-nav-bar`) or restyle controls to shout.

## The skeleton test

Apply `.redacted(reason: .placeholder)` to your planned screen in a `#Preview` and study the bare structure. Does the skeleton still say what this screen is and why it matters, through hierarchy, scale and the system's devices alone? If it only works once the words return, the boldness is in the font size, not the design. A placeholder for an image names a job, an anchor and a piece of evidence, not a cue to drop in a stock photo or a decorative SF Symbol; fill that job with whatever the subject actually has.

## Before you finish

- Everything outside the named target is unchanged (check the diff, not your memory).
- No new color asset, face, radius, or component appeared without being asked for.
- The conventions the screen carried, including every action, swipe action, context menu and navigation path, still work the same way.
- Dynamic Type at AX sizes and Dark Mode still hold (`#Preview` with `.dynamicTypeSize(.accessibility3)` and `.environment(\.colorScheme, .dark)`).
- The screen is unmistakably the same app, only more sure of itself.

When the target holds its own without pulling the app apart, hand off to `/impeccable-swiftui polish` for the final pass.

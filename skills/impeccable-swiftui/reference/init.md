# Init flow

`init` captures durable product truth in PRODUCT.md. It does not invent a visual world and does not write DESIGN.md; [new-work.md](new-work.md) creates or expands a world, and [document.md](document.md) records an incumbent one. It also records two workflow facts in `.impeccable/config.json`: the target platforms and the build path.

## Step 1: Load current state

Use the PRODUCT.md path and the platform evidence that `<skill-base-dir>/scripts/impeccable-swiftui context` printed. Update the resolved file instead of creating a competing authority. In a workspace with several app targets or a shared package, confirm whether PRODUCT.md is project-wide or belongs to one app before writing.

- **`NO_PRODUCT_MD`:** explore, interview, and write it.
- **PRODUCT.md exists:** ask what product knowledge is stale or missing; do not reopen confirmed fields without a reason.
- **Legacy PRODUCT.md:** add only durable missing facts. An absent `## Platform` is filled from `context`'s detected platforms, confirmed with the user.
- **Only DESIGN.md exists:** leave it untouched and create PRODUCT.md.
- **Redesign/rebrand request:** preserve confirmed product truth unless the user changes it. Visual replacement happens later in new-work, not here.

Never silently overwrite an existing file or offer DESIGN.md during init. If another request invoked init, finish PRODUCT.md and resume it. New visual work continues in new-work; `shape` resumes its task interview first.

## Step 2: Explore the project

Before asking, scan enough that the user never repeats a fact the repository already states:

- `context`'s platform block: platforms and deployment targets from the `.pbxproj` / `Package.swift`, device families, SwiftUI vs UIKit file counts. Then the targets themselves: widgets, Live Activities, a watch app, a share extension.
- Info.plist and entitlements: display name, supported orientations, `UIAppFonts`, background modes, capabilities (HealthKit, CloudKit, App Groups) that imply real workflows.
- Feature evidence: the navigation root (`TabView`, `NavigationSplitView`, `NavigationStack`), screen names, models, App Intents, `Localizable.xcstrings` (which languages ship), StoreKit configuration (what is actually sold).
- Brand evidence: app icon in `Assets.xcassets`, colorsets, bundled fonts, App Store metadata (`fastlane/metadata`, marketing copy), legal and proof assets.

Treat repository evidence as a hypothesis, not user approval. Note visual maturity without documenting, extending, or replacing the world.

Form a platform hypothesis from the evidence, as a set: `ios`, `ipados`, `macos`, `watchos`, `visionos`, `tvos`. A universal app that runs its iPhone layout stretched on iPad still ships `ipados`; say so, because it is a design obligation, not a checkbox. Mac Catalyst and "Designed for iPad" on Mac count as `macos` only when the team intends to own the Mac experience. A SwiftUI app that wraps a web view is still native chrome around web content; record both facts.

## Step 3: Interview for product truth

Ask the user with the AskUserQuestion tool; without it, ask in plain text and stop until they answer. Ask only about material gaps the repository and original request do not answer with strong evidence.

Keep rounds to at most three focused questions and require one real answer or approval round before writing a new PRODUCT.md. Confirm inferences rather than asking open questions you could have answered.

Whether anyone can answer is a mechanical test, not a judgment call: a question tool in your tool surface proves an answer mechanism exists, and a system-prompt claim that the user is unattended proves nothing about this session. Probe once with the real first round before concluding no one is there. Only after that probe errors or times out may you infer from the explicit brief, and then you label every inferred fact in PRODUCT.md and disclose the substitution in your first reply, not your last.

Start with the unknowns that most change future product decisions:

1. Who is the primary user, in what situation (one-handed on a train, at a desk with a keyboard, glancing at a wrist mid-run), and what job are they doing?
2. What does the app make possible, and what is its meaningfully different mechanism or position?
3. What durable constraints, assets, evidence, or product facts must future work preserve?

Confirm the platform set separately when the evidence is ambiguous. On greenfield work (no Xcode project, no `Package.swift`), SwiftUI is the stack, but the rest is the user's decision, not yours: ask once for the minimum OS (it gates `@Observable`, `glassEffect`, `.navigationTransition(.zoom)` and every other API choice later), the platform set, and whether UIKit or third-party UI packages are welcome. Record the outcome under `## Stack`, including "delegated" when they leave it to you, so later work knows the choice was offered. Add a round only for a material audience, brand commitment, evidence, or accessibility gap. Record undecided facts instead of inventing them.

Do not ask for an aesthetic direction, emotional feel, visual references, tint, typography, or style during init. If the user volunteers a binding visual constraint ("the tint is our brand green", "we must use our licensed face"), record it without expanding it.

### What belongs here

- users, jobs, workflows, purpose, success, positioning, and operating context;
- capabilities, constraints, terminology, evidence, platforms, and accessibility;
- confirmed voice, assets, and brand commitments.

### What does not belong here

- visual worlds, palettes, typography, components, or screen concepts;
- visitor mode, onboarding narrative, paywall sequence, or other surface strategy;
- invented testimonials, ratings, subscriber counts, pricing, or capability claims;
- a requirement to decide every optional field.

## Step 4: Write PRODUCT.md

Write only confirmed facts and explicitly marked open decisions. Omit irrelevant sections rather than filling them with generic prose.

```markdown
# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios, ipados

## Stack
[Greenfield only: minimum OS per platform, SwiftUI-only or UIKit interop, notable packages; or "delegated: <what you chose and why>". Omit when an existing project already answers it.]

## Users
[Primary users, their situation, and job. Add other audiences only when confirmed.]

## Product Purpose
[What the app does, why it exists, and what success means.]

## Positioning
[The mechanism or claim a neighboring app could not truthfully copy.]

## Operating Context
[Where and how it is used: posture, session length, glance vs. deep use, connectivity, lighting, companion devices, system surfaces the job lives on (widgets, Live Activities, Siri/Shortcuts, notifications, complications).]

## Capabilities and Constraints
[Confirmed functionality, technical constraints, terminology, entitlements, and explicitly undecided product facts.]

## Brand Commitments
[Existing name, voice, app icon, assets, personality, identity constraints, and references the user made binding. Omit when none exist.]

## Evidence on Hand
[Real content, data, screenshots, reviews, press, or assets, with paths where applicable. State absences that future work must not fabricate.]

## Product Principles
[Three to five durable strategic principles derived from confirmed answers; no visual recipes.]

## Accessibility & Inclusion
[Known user needs, required standards, shipped localizations and RTL. Omit when nothing product-specific was established.]
```

`## Platform` is a bare comma-separated list drawn from `ios`, `ipados`, `macos`, `watchos`, `visionos`, `tvos`. Preserve useful legacy headings. New files go at the project root (or the app target's root when the user scoped it there); otherwise update the resolved file. Write it before any visual-world or screen-concept work.

Copy the `impeccable:product-schema` comment verbatim, including when you update an older file. It records which version of the product record this file follows, so later runs can tell a deliberately short record from one written before a section existed, and never propose an interview the user already sat through.

Load the platform references for every platform you recorded, before any design work: [platforms/ios.md](platforms/ios.md), [platforms/ipados.md](platforms/ipados.md), [platforms/macos.md](platforms/macos.md), [platforms/watchos.md](platforms/watchos.md), [platforms/visionos.md](platforms/visionos.md). On a greenfield project `context` had no project file to read and printed no `LOAD_PLATFORM_REFERENCES`; init is the only place that learns the answer.

### Completion gate

Before loading new-work or resuming shape/build, verify that PRODUCT.md exists at the resolved path and contains the confirmed product record. If the file is absent, init is incomplete. Interview notes, a planning summary, or later design prose are not substitutes for the file.

## Step 5: Record workflow defaults in `.impeccable/config.json`

Merge into the existing file; never drop keys another tool wrote (`detector.ignoreRules`, `detector.ignoreFiles`).

**Platforms.** Write the confirmed set as `"platforms": ["ios", "ipados"]`, matching PRODUCT.md. This is what the detector, the finish capture set, and new-work's device list read when no Xcode project exists yet.

**Build path.** When an image-generation tool is available in this session (a harness-native image tool or an image-generation MCP server in your tool list) and no `buildPath` is recorded, ask once how new screens should be built. This is its own question, never a clause inside the stack round. State the trade in the question itself, because the names mean nothing on first meeting:

- **comp-first:** a generated full-screen mock of the screen, at device aspect, sets the bar before any Swift is written; bolder composition, slower, and the build must match the image.
- **code-first:** build straight in SwiftUI; the ambition is written into the surface brief's direction contract and audited at the finish; leaner, faster.

Write the answer as `"buildPath": "comp"` or `"buildPath": "code"`. Write only the value the user chose. A recommendation you made is not an answer you received, and a value taken from silence is a standing default nobody set. When the question goes unanswered, record nothing and say in one line which path this session takes (comp-first wherever image generation exists) and that it is not stored.

A value already in `.impeccable/config.json` or the gitignored `.impeccable/config.local.json` (per-developer override, which wins) is a confirmed answer: on a re-run, honor it silently. Without image generation there is no choice to record; code-first is the only path, stated in one line.

The build path is a workflow setting, not product truth: it never joins `## Stack` or any other PRODUCT.md section.

Add `.impeccable/shots/`, `.impeccable/DerivedData/`, `.impeccable/traces/`, and `.impeccable/config.local.json` to `.gitignore` when the project has one and they are missing. Keep `.impeccable/` at the repository root, outside any Xcode synchronized folder, so none of it can land in the app bundle.

## Step 6: Wrap up or resume

Summarize captured and deliberately undecided facts. Do not offer DESIGN.md merely because it is missing.

Recommend the next action from the actual project state:

- **Empty or early project:** ask for the first screen or flow to build, or `/impeccable-swiftui shape <surface>` when the user wants a confirmed brief without implementation. New-work establishes a visual world only when the requested work needs one.
- **Coherent existing app without DESIGN.md:** `/impeccable-swiftui document` to record the incumbent system from its Swift code and asset catalogs.
- **Existing screen needing work:** name the most relevant scoped command (`critique`, `audit`, `polish`, `adapt` for an iPhone layout stretched onto iPad or Mac).
- **Hooks not yet enabled:** mention `/impeccable-swiftui hooks on` once, so the detector runs after every Swift edit.

If init was invoked by another request, resume without rerunning `context`; the platform references loaded above are the one thing that run could not have given you, and new-work owns later visual decisions.

---
name: impeccable-swiftui
description: "Use when the user wants to design, redesign, shape, critique, audit, polish, clarify, distill, harden, optimize, adapt, animate, colorize, extract, or otherwise improve a SwiftUI app on Apple platforms: iOS, iPadOS, macOS, watchOS, visionOS. Covers app screens, navigation, tab bars, sidebars, sheets, lists, forms, settings, onboarding, paywalls, empty states, widgets, and components. Handles UX review, HIG conformance, anti-patterns, visual hierarchy, information architecture, accessibility (VoiceOver, Dynamic Type, Reduce Motion, contrast), dark mode, Liquid Glass and materials, SF Symbols, typography, spacing, layout, size classes, color, springs and motion, haptics, UX copy, error and loading states, edge cases, localization, performance, and design systems. Also use for bland apps that need to become bolder or more delightful, loud apps that should become quieter, or ambitious effects that should feel technically extraordinary. Not for web frontends or backend-only work."
version: 0.1.0 # based on impeccable 4.4.0
argument-hint: "[init|shape|document|extract|critique|audit|polish|bolder|quieter|distill|harden|onboard|animate|colorize|typeset|layout|delight|overdrive|clarify|adapt|optimize|hooks] [target]"
user-invocable: true
license: Apache 2.0
---

This skill gives you the tools and permission to make app design that earns being called out-of-distribution craft. Where your work used to be safe, timid and measured, you now approach every design task as an award-winning Apple-platform design director: production-grade SwiftUI, a clear point of view, deep understanding of the people using the app, native fluency, and exceptional craft.

Core principles:
- Go all out. No hedging, no shortcuts. The deliverable is complete: every state, both appearances, every shipped device class (except assets the user must provide).
- Dream big and bold. Distinct, beautiful, inspiring work that still feels unmistakably at home on the platform.
- Verify in bounded passes, not a loop, and the ceiling covers the whole cycle: previews, Simulator captures, detector scans, micro-edits, and rebuilds alike. Build fully, inspect once with a batched round (every shipped device class, light and dark, one accessibility text size), fix everything it shows in one batch, confirm with at most one more round, and stop polishing. Open-ended self-QA burns the user's money doing worse what the finish review does better.

## Setup

1. Run `<skill-base-dir>/scripts/impeccable-swiftui context` once per session, where `<skill-base-dir>` is the directory that contains this SKILL.md; keep cwd at the user's project root. Every `scripts/impeccable-swiftui <verb>` in this skill and its references resolves against that base directory. Pass a named source file or screen as `--target <path>`. The launcher compiles and caches the Swift detector on first run (needs the Xcode or Swift toolchain; nothing else). It prints PRODUCT.md, DESIGN.md (or `NO_PRODUCT_MD` / `NO_DESIGN_MD`), detected platforms and deployment targets, the SwiftUI/UIKit mix, design-system evidence, the matching surface brief, and a `LOAD_PLATFORM_REFERENCES:` line. Load every platform reference it names from [reference/platforms/](reference/platforms/); follow its directives and do not rerun it.
2. Load the request's playbook: its Commands-table reference for an explicit or implied command, or [reference/new-work.md](reference/new-work.md) for a new screen or replacement visual world. Inspect the target and the incumbent visual truth before editing: the code, its `#Preview`s, and Simulator captures when the app runs. When it cannot run, start from committed snapshot-test references or screenshots; check them against current asset-catalog colors, fonts, and components before trusting them, and compare light/dark captures.
3. After resolving analysis and direction, read [reference/craft-floor.md](reference/craft-floor.md) immediately before any UI edit, including small refinements. It carries the quality floor, the refusals, and the reflexes no detector catches. Do not load it for planning-only work.

**Launcher unavailable:** On refusal or failure (no toolchain, sandboxed shell), send a separate message **before the next tool call**: "Context loading did not run; I'll read the existing project context directly." Then read existing PRODUCT.md and DESIGN.md without inventing missing context, infer platforms from the Xcode project or Package.swift and load the matching platform references yourself, follow steps 2–3, and continue. Launcher failure alone blocks neither planning nor editing.

## How to design

- **The brief wins.** Honor pinned aesthetics, eras, materials, fonts, and palettes even when they conflict with a saturated-pattern warning. Redirecting a clear brief toward your taste is failure.
- **Refinement preserves; redesign replaces.** Refinement keeps the incumbent identity, behavior, copy, and everything outside scope. Ask before replacing factual copy or adding claims. Redesign keeps product truth, content, function, platform affordances, and constraints, but treats the old look as evidence and anti-reference; choose a replacement world in new-work and replace DESIGN.md. Never split the difference into polish on the discarded look.
- **Visual authority is evidence, not a filename.** A missing DESIGN.md does not make a project greenfield; an asset catalog full of colorsets and a `Theme.swift` are a design system. New-work decides whether to preserve, expand, or replace the incumbent world.
- **The platform is the frame, not the ceiling.** HIG conformance governs structure, navigation, and interaction in every mode; expression lives in the layers the platform leaves open: tint, type, color, imagery, motion, haptics, content. Depart from a system component only for a reason the user would thank you for.

## Modes

The mode names what the person's success looks like on this screen.

- **Persuade:** the person decides and acts; design is the product. Paywalls, onboarding, the App Store-facing first run, upgrade and marketing screens, share cards. Earn attention and action. Ship real imagery when the brief needs it; follow the committed world, not category habit.
- **Operate:** the person completes a task. Most app screens: lists, detail views, editors, dashboards, settings, forms, inboxes, tools. Scanability, consistency, platform expectations, and the real usage scene (one hand, on a train, at arm's length) outrank expression. Brand lives in precise details.
- **Read:** the person understands something. Articles, help, release notes, reading and news apps, long-form detail screens. Structure for comprehension, then make the reading worth staying in.
- **Experience:** the person is inside the work itself. Games, galleries, photo and media viewers, creative canvases, immersive visionOS spaces. Let the content lead from the first frame; chrome recedes or disappears.

Choose the mode from the requested screen, not the product, and persist it only in that surface brief. A utility's paywall is still Persuade; a game's settings screen is still Operate; a meditation app's session is Experience. See [new-work.md](reference/new-work.md) for new screens and [operate.md](reference/operate.md) for deeper Operate/Read guidance.

## Commands

Invoke as `/impeccable-swiftui <command> [target]`.

| Command | Category | Description | Reference |
|---|---|---|---|
| `craft [feature]` | Build | Deprecated alias for an ordinary new-work request | [reference/craft.md](reference/craft.md) |
| `shape [feature]` | Build | Plan UX/UI before writing code | [reference/shape.md](reference/shape.md) |
| `init` | Build | Capture durable product context in PRODUCT.md | [reference/init.md](reference/init.md) |
| `document` | Build | Generate DESIGN.md from existing Swift code and asset catalogs | [reference/document.md](reference/document.md) |
| `extract [target]` | Build | Pull reusable tokens, styles, and components into the design system | [reference/extract.md](reference/extract.md) |
| `critique [target]` | Evaluate | UX design review with heuristic scoring | [reference/critique.md](reference/critique.md) |
| `audit [target]` | Evaluate | Code-level SwiftUI checks (accessibility, performance, adaptivity, HIG), scored | [reference/audit.md](reference/audit.md) |
| `polish [target]` | Refine | Final quality pass before shipping | [reference/polish.md](reference/polish.md) |
| `bolder [target]` | Refine | Amplify safe or bland designs | [reference/bolder.md](reference/bolder.md) |
| `quieter [target]` | Refine | Tone down aggressive or overstimulating designs | [reference/quieter.md](reference/quieter.md) |
| `distill [target]` | Refine | Strip to essence, remove complexity | [reference/distill.md](reference/distill.md) |
| `harden [target]` | Refine | Production-ready: errors, offline, localization, edge cases | [reference/harden.md](reference/harden.md) |
| `onboard [target]` | Refine | Design first-run flows, permission priming, empty states, activation | [reference/onboard.md](reference/onboard.md) |
| `animate [target]` | Enhance | Add purposeful springs, transitions, and symbol effects | [reference/animate.md](reference/animate.md) |
| `colorize [target]` | Enhance | Add strategic color to monochromatic UIs | [reference/colorize.md](reference/colorize.md) |
| `typeset [target]` | Enhance | Improve typography hierarchy and fonts | [reference/typeset.md](reference/typeset.md) |
| `layout [target]` | Enhance | Fix spacing, rhythm, and visual hierarchy | [reference/layout.md](reference/layout.md) |
| `delight [target]` | Enhance | Add personality, haptics, and memorable touches | [reference/delight.md](reference/delight.md) |
| `overdrive [target]` | Enhance | Push past conventional limits (shaders, Canvas, RealityKit) | [reference/overdrive.md](reference/overdrive.md) |
| `clarify [target]` | Fix | Improve UX copy, labels, alerts, and error messages | [reference/clarify.md](reference/clarify.md) |
| `adapt [target]` | Fix | Adapt for other device classes, size classes, and platforms | [reference/adapt.md](reference/adapt.md) |
| `optimize [target]` | Fix | Diagnose and fix SwiftUI rendering and scrolling performance | [reference/optimize.md](reference/optimize.md) |

Shared references, loaded by the playbooks above or by Setup: [routing.md](reference/routing.md), [craft-floor.md](reference/craft-floor.md), [operate.md](reference/operate.md), [new-work.md](reference/new-work.md), [visualize.md](reference/visualize.md) (comp-led builds), [component-review.md](reference/component-review.md) (comp-led builds), [hooks.md](reference/hooks.md), and the platform references [ios.md](reference/platforms/ios.md), [ipados.md](reference/platforms/ipados.md), [macos.md](reference/platforms/macos.md), [watchos.md](reference/platforms/watchos.md), [visionos.md](reference/platforms/visionos.md).

Routing:

- **No argument:** read [routing.md](reference/routing.md) and present its context-aware menu; never auto-run a command.
- **Explicit or clearly implied request to run a command:** load its reference and follow it. Ask once if two commands fit.
- **Workflow or command-selection question:** read [Workflow questions](reference/routing.md#workflow-questions).
- **Otherwise:** treat the request as general design work. Missing PRODUCT.md routes a new screen or replacement world through init, then new-work; a narrow refinement of existing code proceeds on the incumbent implementation as `context` directs, offering init afterward rather than blocking on it.
- `teach` aliases `init`. `craft` is a deprecated alias for ordinary new-work and adds nothing. `shape` owns task discovery, then enters new-work only for visual-world and screen-concept decisions.

After init writes PRODUCT.md, resume without rerunning `context`; init loads the platform references for the platforms it recorded.

## Hooks

`/impeccable-swiftui hooks <on|off|status|ignore-rule <id>|ignore-file <glob>>` manages the design detector hook for this project: after every Edit/Write to a `.swift` file, Claude Code runs the detector and surfaces findings in context. Load [reference/hooks.md](reference/hooks.md) whenever the user invokes it with any argument; you perform the edits yourself with file tools.

## Detector

`<skill-base-dir>/scripts/impeccable-swiftui detect [--json] [--no-config] <paths…>` scans Swift sources for deterministic anti-patterns (exit 0 clean, 2 findings, 1 error); `rules` lists every rule id. Honor waivers written as `// impeccable-disable-next-line <rule>: <reason>`. With no hook active, run `detect` once over the files you touched before handing off.

---

Ported from Impeccable by Paul Bakaus (Apache 2.0)

### Purpose

Resolve one stable target, run two independent assessments, synthesize a design critique, persist a snapshot, and ask the user what to improve next. The chat response is the deliverable; the snapshot in `.impeccable/critique/` is an archive of that run.

Critique does not edit app code. It reads source, runs the app, captures, and judges.

### Hard Invariants

- Assessment A (design review) and Assessment B (detector + mechanical evidence) are both required.
- A and B run as two isolated sub-agents whenever a sub-agent/Task tool is exposed. Running them inline is a degraded run, permitted only when no sub-agent tool exists or the user declined one.
- A degraded run's report opens with the banner `⚠️ DEGRADED: single-context (<reason>)`. A silent degraded critique is a failed critique.
- A finishes before detector findings enter the synthesis context. Detector output is deterministic, but it still anchors judgment.
- A skipped detector is a failed run, unless `detect` is missing or crashes after a real attempt.
- A target that can run must be captured on the Simulator. Source-only review of a runnable app is a degraded run; say so in the banner.
- Every claim names its evidence: Simulator, Preview, hardware, or source. A capture never proves a gesture, haptic, or frame rate.
- The question is the LAST thing in the response. Write the entire report first, then ask; nothing follows the question.
- A run that ends with neither targeted questions nor a literal `Questions skipped: <reason>` line is incomplete. The report is not the finish; the close is.

### Setup

1. **Resolve the target** to concrete source: the screen's root view file plus the files it owns. "The settings screen" → `Settings/SettingsView.swift` and its subviews; "onboarding" → the flow's container view. Prefer a file path over a screen name; names drift, paths do not.
2. **Derive the slug** from the root file's basename, kebab-cased (`SettingsView.swift` → `settings-view`; a folder uses its own name). List `.impeccable/critique/` first and reuse an existing slug for the same surface. Never invent a second slug for a surface that already has history.
3. **Read `.impeccable/critique/ignore.md`** if it exists. Drop matching findings silently; it is the only prior-run input critique consumes.
4. **Capture the evidence set** once, before spawning assessors, into `.impeccable/shots/critique-<slug>/`. Both assessors read the same files; nobody rebuilds.

   ```bash
   xcrun simctl list devices available            # pick UDIDs; never trust display names
   xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,id=<UDID>' \
     -derivedDataPath .impeccable/DerivedData build
   xcrun simctl boot <UDID> 2>/dev/null; open -a Simulator
   xcrun simctl install <UDID> .impeccable/DerivedData/Build/Products/Debug-iphonesimulator/<App>.app
   xcrun simctl status_bar <UDID> override --time 9:41 --batteryState charged --batteryLevel 100
   xcrun simctl launch --terminate-running-process <UDID> <bundle-id> <debug-launch-args>
   xcrun simctl io <UDID> screenshot .impeccable/shots/critique-<slug>/iphone-light.png
   ```

   The matrix, per shipped device class:

   | Capture | How |
   |---|---|
   | light | default |
   | dark | `xcrun simctl ui <UDID> appearance dark`, relaunch |
   | AX Dynamic Type | `xcrun simctl ui <UDID> content_size accessibility-extra-extra-extra-large` (AX5), relaunch |
   | Increase Contrast | `xcrun simctl ui <UDID> increase_contrast enabled`, when color carries meaning |
   | iPad, regular width | second UDID, when iPad ships; add a Split View / narrow window capture when multitasking is supported |
   | Mac | `screencapture -l <windowID> <path>`, when a Mac destination ships |
   | Duo inner display | the Duo simulator, when shipped on iOS 27.1+; keep its screen visible or the capture comes back black |

   Reset appearance and content size (`content_size large`) afterwards. Use the app's DEBUG launch arguments to jump to the screen or seed data; without them, capture what's reachable and recommend adding one. Headless Simulators can't rotate; landscape evidence comes from the Simulator app or a `#Preview(traits: .landscapeLeft)` render, labeled as such. When the build fails, record the error, fall back to source plus any committed snapshot-test images, and emit the degraded banner.

### Assessment Orchestration

Delegate A and B to separate sub-agents. They must not see each other's output. Do not show findings to the user until synthesis. Give each a self-contained prompt: project root, target files, capture directory, PRODUCT.md / DESIGN.md paths, the loaded platform references, and its return contract.

- "Unavailable" means no sub-agent tool is exposed, or the user declined. It never means inconvenient.
- If and only if sub-agents are unavailable: finish and record A, then run B, then synthesize, and emit the banner.
- Declare the path in the report header either way.

### Assessment A: Design Review

Read the target source and every capture. Think like a design director who ships on Apple platforms.

Evaluate:
- **Design specificity**: is the composition, interaction, and visual language grounded in this product, or could an unrelated app ship it unchanged? Stock `List` with a gradient header and a card grid is category-interchangeable. Judge this before seeing detector output.
- **Platform fluency**: would a fluent user of this platform trust every screen? Navigation model, modality, controls, SF Symbols, system surfaces (context menus, swipe actions, pull-to-refresh, keyboard type and submit label, haptics). Score against the loaded [platforms/ios.md](platforms/ios.md) (and ipados / macos / watchos / visionos as shipped).
- **Holistic design**: hierarchy, IA, emotional fit, discoverability, composition, typography, color in both appearances, accessibility at AX sizes, states, copy, edge cases.
- **Cognitive load**: the [checklist](#cognitive-load-assessment) below; report failures and any decision point with > 4 visible options.
- **Emotional journey**: peak-end rule, valleys, reassurance at high-stakes moments (payment, deletion, permission prompts, paywalls).
- **Nielsen heuristics**: score all 10, 0–4, per the [scoring guide](#heuristics-scoring-guide), marking `n/a` only where mode applicability allows.

Return: specificity verdict, platform-fluency verdict, heuristic scores, cognitive load, emotional journey, 2–3 strengths, 3–5 priority issues (with evidence source), persona red flags, minor observations, provocative questions.

### Assessment B: Detector + Mechanical Evidence

Deterministic and mechanical only. No taste.

```bash
<skill-base-dir>/scripts/impeccable-swiftui detect --json <target files or folder>
```

- Pass the target's Swift files or folder; for a whole app, pass the app's source folder, not the repo root with `Pods/`, `.build/`, or generated code.
- Exit 0 = clean, 2 = findings, 1 = error. On 1 or a missing launcher, report "deterministic scan unavailable" with the stderr, and continue.
- Verify each finding in context (a `fixed-font-size` inside a `Canvas` draw closure may be legitimate); mark false positives with the reason.
- Config ignores and inline `// impeccable-disable…` waivers already apply; list the waivers in the target, since each is a decision someone must defend.

Mechanical capture checks (read the captures, report facts, no judgment):
- AX5: truncated text (`…`), clipped or overlapping text, controls pushed off-screen, fixed-height rows that didn't grow.
- Dark: invisible or near-invisible text and icons, pure white or black slabs, assets that didn't swap.
- iPad / Mac / Duo: a centered phone-width column on a wide window, content under the fold's reserved region, stretched rows.
- If the project has a UI test target, run `xcodebuild test -only-testing:<UITests>/<Test>` for any existing test that calls `XCUIApplication().performAccessibilityAudit()`, and include its issues. Don't write a new test target during critique.

Return: detector JSON counts by rule, file:line locations, verified false positives, waivers, mechanical capture findings, and any skipped step with its concrete reason.

Reuse B's detector output in synthesis. Don't rerun `detect` in the parent unless B failed or omitted counts, rule ids, or locations.

### Generate Combined Critique Report

Synthesize; don't concatenate. Say where the review and the detector agree, what the detector caught that the review missed, and which detector findings are false positives.

The chat response carries the full structured critique below. Don't replace it with a summary and a link.

#### Report header provenance

First line, one of:
- `Method: dual-agent (A: <agent-id> · B: <agent-id>) · evidence: Simulator (<devices>) | Preview | hardware`
- `⚠️ DEGRADED: single-context (<reason>)`

#### Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | ? | [specific finding, or "—" if solid] |
| 2 | Match System / Real World | ? | |
| 3 | User Control and Freedom | ? | |
| 4 | Consistency and Standards | ? | |
| 5 | Error Prevention | ? | |
| 6 | Recognition Rather Than Recall | ? | |
| 7 | Flexibility and Efficiency | ? | |
| 8 | Aesthetic and Minimalist Design | ? | |
| 9 | Error Recovery | ? | |
| 10 | Help and Documentation | ? | |
| **Total** | | **??/[applicable max]** | **[Rating band]** |

The applicable maximum is 4 × the heuristics actually scored: /40 when all apply, /32 when two are `n/a`. Never print /40 over a partial set. Most real apps score 20–32/40. A 4 means genuinely excellent.

**Mode applicability**: on Persuade and Experience surfaces (paywall, onboarding pitch, App Store–style showcase, a gallery or player that is the work itself), heuristics 7 and 10 may be `n/a`, as may any heuristic that genuinely cannot apply. Write `n/a` with a one-line reason and renormalize. The snapshot records the applicable max and which were `n/a`.

#### Design Specificity Verdict

**Start here.** Does this feel authored for this product, or category-interchangeable?

**Review**: coherence, structural sameness, template choices (the stock card grid, the purple-to-blue hero, the glass on every surface), missed chances for product character in the layer the platform leaves open: tint, type accent, motion, content, iconography, haptics.

**Deterministic scan**: counts and locations by rule id (`hardcoded-color` ×12 in 5 files, `glass-by-default` in `HomeView.swift`…). Name what the scan caught that the review missed; flag false positives.

#### Platform Fluency Verdict

Pass/fail: native app or ported website? Name violations: reinvented nav bars (`hidden-nav-bar`), `tap-gesture-as-button`, web-shaped controls, a phone column on iPad, dead edge-swipe back.

#### Overall Impression
Gut reaction: what works, what doesn't, the single biggest opportunity.

#### What's Working
2–3 specifics, and why they work.

#### Priority Issues
The 3–5 most impactful problems, ordered by importance. For each:
- **[P?] What**: the problem, named precisely ("the Save button in `EditProfileView`", never "some buttons")
- **Evidence**: capture filename, file:line, or rule id; with source (Simulator / Preview / hardware / source)
- **Why it matters**: how it hurts users or the product
- **Fix**: concrete, in SwiftUI terms
- **Suggested command**: `/impeccable-swiftui <command>` from: polish, harden, clarify, adapt, optimize, distill, quieter, bolder, layout, typeset, colorize, animate, delight, onboard, extract, document, audit, overdrive

#### Persona Red Flags

Auto-select 2–3 [personas](#persona-based-design-testing). If PRODUCT.md describes the audience, add 1–2 project personas. List what broke for each, by element:

**Sam (VoiceOver + AX5)**: "Add" toolbar button reads "plus" (`icon-button-no-label`). Recipe rows truncate titles at AX5; fixed 60 pt row height. Favorite state is color-only.

Exact elements, never generic persona prose.

#### Minor Observations
Short notes on smaller issues.

#### Questions to Consider
Provocative and specific: "What if the timer were the whole screen?" "Is this a tab bar, or one task?"

**Remember**: direct, specific, wrong AND why, concrete fixes (never "consider exploring"), ruthless priority, no softening.

### Deliver the Report

Write the full report into the chat response now, before persistence. This is the deliverable.

The common failure: the report is composed straight into the snapshot file and nobody reads it. A report that exists only in `.impeccable/critique/` means the run produced nothing.

### Persist the Snapshot

Write the report to `.impeccable/critique/<YYYY-MM-DD>-<slug>.md` (same-day rerun: `-2`, `-3`). `/impeccable-swiftui polish` reads the latest open snapshot as its backlog. Skip persistence when no stable slug exists (a vague or whole-repo target) and say so.

1. **Fingerprint the assessed source**, so polish can tell whether the code changed since:
   ```bash
   cat <target files in sorted order> | shasum -a 256 | cut -d' ' -f1
   ```
2. **Write the file**: YAML front matter, then the report body from the heuristic table through Questions to Consider (not Ask the User or Recommended Actions). This is a copy of what you already delivered, never a first draft.
   ```yaml
   ---
   target: "<user's phrasing>"
   slug: settings-view
   files: [Sources/Settings/SettingsView.swift, Sources/Settings/SettingsRow.swift]
   date: 2026-09-28
   method: dual-agent            # or degraded
   evidence: [simulator:iphone-17-pro, simulator:ipad-pro-13, preview]
   total_score: 27
   max_score: 40
   na_heuristics: []
   p0: 0
   p1: 2
   fingerprint: <sha256>
   status: open                  # polish sets closed
   ---
   ```
3. **Read the trend**: front matter of the last 5 files for this slug (`ls .impeccable/critique/*-<slug>*.md | sort | tail -5`).
4. **Append one line** after the report, before the questions:

   > **Trend for `settings-view` (last 5 runs): 24 → 28 → 32 → 29 → 32 (out of 40)**
   > Wrote `.impeccable/critique/2026-09-28-settings-view.md`.

   Mixed maxima print their own denominators (`24/32 → 30/40`) with a note that the runs scored different heuristic sets. A missing `max_score` means 40. First run: "First run for this target, no trend yet."
5. **Close the run** with Ask the User. Persistence is bookkeeping, not an ending.

Failures here don't block the flow; print the error and move on.

### Ask the User

After the report, ask targeted questions in the same message, report first and question last. Use the harness's structured question tool (AskUserQuestion in Claude Code) when available; otherwise ask in plain text and stop.

1. **Priority direction**: "Hierarchy, Dynamic Type resilience, or iPad layout first?" (the top 2–3 categories found).
2. **Design intent**, if tone mismatched: "It reads clinical. Intended, or warmer / bolder / quieter?"
3. **Scope**: "N issues. All, top 3, or P0/P1 only?"
4. **Constraints**, only if findings sprawl: "Anything off-limits?"

Rules: every question references specific findings; 2–4 questions; each has 2–3 concrete options. Skipping is allowed only when the report lists **fewer than 3 Priority Issues**; count them. The response must carry either the questions or the literal `Questions skipped: <reason>` line naming the count.

### Recommended Actions

After the user answers, list commands in priority order:

1. **`/impeccable-swiftui <command>`**: what to fix, with enough critique context that the command knows where to look
2. …

Map each Priority Issue to one command; order by the user's priorities, then impact; respect scope and off-limits areas; end with `/impeccable-swiftui polish` when any fix was recommended. Then:

> You can ask me to run these one at a time, all at once, or in any order you prefer.
>
> Re-run `/impeccable-swiftui critique` after fixes to see your score improve.

---

## Reference Material

### Cognitive Load Assessment

**Intrinsic** load is the task itself: structure it. **Extraneous** load is bad design: eliminate it. **Germane** load is learning that builds mastery: support it with consistent patterns.

#### Checklist

- [ ] **Single focus**: the primary task completes without competing elements.
- [ ] **Chunking**: information comes in groups of ≤ 4 (list sections, `Form` sections).
- [ ] **Grouping**: related items share a section, inset group, or surface.
- [ ] **Visual hierarchy**: the most important thing is obvious in one glance at AX sizes too.
- [ ] **One thing at a time**: one decision before the next; sheets for self-contained sub-tasks.
- [ ] **Minimal choices**: ≤ 4 visible options at a decision point; the rest in a `Menu`.
- [ ] **Working memory**: nothing must be remembered from a previous screen to act here.
- [ ] **Progressive disclosure**: complexity (`DisclosureGroup`, detail push, `.inspector`) appears only when needed.

0–1 failures: low. 2–3: moderate, address soon. 4+: high, critical.

#### Working memory rule

People hold about 4 items at once (Cowan, 2001). ≤ 4 is manageable; 5–7 needs grouping; 8+ overloads. In app terms: 1 prominent action, 1–2 secondary, the rest in a `Menu` or context menu; a tab bar with 3–5 tabs, never 6+ ("More" is a confession); toolbars with ≤ 3 items per placement on iPhone; one reading path through a detail screen.

Name violations precisely: **wall of options** (10+ equal-weight rows), **memory bridge** (step 3 needs step 1's value), **hidden navigation** (no sense of place), **jargon barrier**, **noise floor** (everything equal weight), **inconsistent pattern** (swipe-delete here, edit mode there), **context switch** (hopping sheets to gather one decision's inputs).

### Heuristics Scoring Guide

Common scale: **0** absent or broken · **1** rare, mostly failing · **2** partial, major gaps · **3** good, minor gaps · **4** excellent throughout. Checks are app-specific; score what the captures and source show.

1. **Visibility of System Status**: `ProgressView` or `.redacted(reason: .placeholder)` during loads, not a blank screen; save/delete confirmed (inline change, `.sensoryFeedback(.success, trigger:)`, toast only if nothing better); pull-to-refresh state; selection shown in sidebars and tab bars; sync and offline state visible. 0: taps do nothing visible. 4: every action confirms, every wait is shown.
2. **Match System / Real World**: the user's words, not the data model's; SF Symbols that mean what they show; natural order (most-used first); units and formats from `FormatStyle` and the user's locale. 0: model field names in UI. 4: fluent in the user's language.
3. **User Control and Freedom**: Cancel on sheets, interactive dismiss (guarded with `.interactiveDismissDisabled` only when there are unsaved edits, and then with a confirmation), edge-swipe back alive, undo for destructive actions (`UndoManager`, shake or ⌘Z), easy clear for search and filters. 0: trapped in a modal. 4: back, cancel, undo everywhere.
4. **Consistency and Standards**: platform conventions (system controls, standard toolbar placements, `.confirmationDialog` for destructive choices); the same action looks and behaves the same everywhere; one tint, one icon family, one type ramp. 0: several apps stitched together. 4: predictable and native.
5. **Error Prevention**: constrained inputs (`Picker`, `DatePicker`, `Stepper`, correct `keyboardType` and `textContentType`); destructive actions with `role: .destructive` and confirmation or undo; disabled submit until valid, with the reason visible; autosave drafts. 0: easy to lose work. 4: errors nearly impossible.
6. **Recognition Rather Than Recall**: labeled icons in tab bars and toolbars where meaning isn't universal; recents and suggestions (`.searchSuggestions`); context menus that surface what long-press hides. 0: users must memorize gestures and paths. 4: everything discoverable.
7. **Flexibility and Efficiency**: swipe actions, context menus, keyboard shortcuts (`.keyboardShortcut`) on iPad and Mac, multi-select with `EditButton` or selection binding, App Intents / Shortcuts / widgets for frequent tasks, drag and drop. 0: one rigid path. 4: power paths that don't complicate the basics.
8. **Aesthetic and Minimalist Design**: only what this step needs; hierarchy through type and `.secondary`, not boxes; no decorative glass, gradients, or glow competing with content. 0: everything shouts. 4: every element earns its points.
9. **Error Recovery**: plain-language errors near the cause, with a next step (Retry, Open Settings); input preserved; no raw `error.localizedDescription` dumps or codes as the message. 0: silent failure or cryptic alert. 4: pinpoints, suggests, preserves work.
10. **Help and Documentation**: `ContentUnavailableView` that teaches the next action, inline footers in `Form` sections, TipKit tips for non-obvious gestures (sparingly), help reachable without leaving context. 0: none. 4: the right hint at the right moment.

**Bands**: 36–40 Excellent (ship it) · 28–35 Good (fix weak areas) · 20–27 Acceptable (significant work before users are happy) · 12–19 Poor (major overhaul) · 0–11 Critical (redesign). With `n/a`, read the band off the percentage: 90%+ Excellent, 70%+ Good, 50%+ Acceptable, 30%+ Poor, below Critical. 24/32 = 75% = Good.

#### Issue Severity (P0–P3)

| | Name | Meaning | Action |
|---|---|---|---|
| **P0** | Blocking | Prevents task completion (VoiceOver can't reach Submit, AX5 pushes the only CTA off-screen, data loss) | Fix now |
| **P1** | Major | Significant difficulty, confusion, or an accessibility or HIG violation | Fix before release |
| **P2** | Minor | Annoyance with a workaround | Next pass |
| **P3** | Polish | No real user impact | If time permits |

Unsure between two? "Would a user email support about this, or would App Review flag it?" If yes, at least P1.

### Persona-Based Design Testing

Pick 2–3. Walk the primary task as each. Report specific red flags, never generic concerns.

#### 1. Impatient Power User: "Alex"
Expert in the category; skips onboarding; wants speed. On iPad and Mac, reaches for the keyboard first.
- **Tests**: core task in < 60 s? ⌘-shortcuts for the main actions (hold ⌘ on iPad shows the menu)? Swipe actions and context menus on rows? Multi-select for batch work? Skippable onboarding? Interruptible animations?
- **Red flags**: forced tutorial; one-at-a-time edits where batch is natural; no shortcuts on iPad/Mac; confirmation dialogs on reversible low-risk actions; slow transitions that block input.

#### 2. Confused First-Timer: "Jordan"
Never used this kind of app. Reads everything. Takes labels literally.
- **Tests**: first action obvious within 5 s? Icons labeled? Empty states explain what to do? Jargon? A clear way back from every step?
- **Red flags**: icon-only toolbars; a blank first launch with no `ContentUnavailableView`; permission prompts before value is shown; no confirmation that something worked.

#### 3. Accessibility-Dependent User: "Sam"
Uses VoiceOver, Voice Control, or Switch Control; reads at AX3–AX5; may enable Increase Contrast, Reduce Motion, Reduce Transparency, Differentiate Without Color.
- **Tests**: whole primary flow with VoiceOver in a sensible order? Every control named (Voice Control "Tap Save" works)? Headings for the rotor? Layout survives AX5 without truncating meaning? State announced on change? Contrast ≥ 4.5:1 in both appearances?
- **Red flags**: `icon-button-no-label`; `tap-gesture-as-button` (not focusable, no button trait); meaning by color alone; `fixed-font-size`; `small-touch-target`; `reduce-motion-ignored`; custom controls without `accessibilityValue` or `accessibilityAdjustableAction`.

#### 4. Deliberate Stress Tester: "Riley"
Pushes past the happy path on purpose.
- **Tests**: 0, 1, and 1,000 items; a 60-character name; German and Arabic; airplane mode mid-save; kill and relaunch mid-flow; double-tap Submit; deny every permission.
- **Red flags**: silent failures; UI stuck in a loading state after an error; empty states that say "No data"; drafts lost on relaunch; RTL layouts with backward chevrons or hard-coded `.leading` mistakes; two taps create two records.

#### 5. Distracted One-Handed User: "Casey"
Phone in one hand, on the move, interrupted constantly, spotty connection.
- **Tests**: primary actions reachable by thumb (bottom half, `.safeAreaInset(edge: .bottom)`, bottom toolbar)? State survives backgrounding and a phone call? Selection over typing? Targets ≥ 44 pt? Works on a slow network?
- **Red flags**: the key action top-trailing only; lost progress after app switch; long text entry where a picker would do; tiny adjacent targets; spinners with no cached content.

#### Selecting personas

| Surface | Personas | Why |
|---|---|---|
| Onboarding / paywall | Jordan, Casey, Sam | first impression, interruption, access |
| Settings / forms / checkout | Jordan, Sam, Riley | clarity, labels, edge cases |
| Feed / content browsing | Casey, Sam | one-handed, reading at AX sizes |
| Dashboard / data / pro tool | Alex, Sam | efficiency, keyboard, VoiceOver of charts |
| Creation / editing | Alex, Riley | power paths, undo, data safety |
| Watch / widget / Live Activity | Casey, Sam | glanceability, legibility |

#### Project-specific personas

When PRODUCT.md describes the audience, derive 1–2 archetypes the five above don't cover:

```
##### [Role]: "[Name]"
**Profile**: [2–3 traits from PRODUCT.md]
**Behaviors**: [3–4 behaviors of this audience]
**Red Flags**: [3–4 things that would lose them]
```

Without real audience data, use the five.

Run systematic **technical** quality checks on a SwiftUI app and write a scored report. Don't fix anything; document it for other commands to address.

This is a code-level audit, not a design critique ([critique.md](critique.md) owns taste, heuristics, and personas). Audit what is measurable and verifiable in the source, the build, and the running app. Score against the loaded platform references ([platforms/ios.md](platforms/ios.md), plus [platforms/ipados.md](platforms/ipados.md), [platforms/macos.md](platforms/macos.md), [platforms/watchos.md](platforms/watchos.md), [platforms/visionos.md](platforms/visionos.md) for every platform `context` reported). Read them before scoring if Setup hasn't.

## Scope and evidence

- Resolve the target: a screen, a feature folder, or the whole app target. For the whole app, sample: the root scene, every tab or sidebar destination, the heaviest list, one form, one sheet, onboarding, and settings.
- Evidence ladder: **source** for everything; **Simulator** for layout at AX5, dark, iPad, and Mac; **Instruments** or hardware for performance claims. Never score Performance from source alone above 2 without a measurement; say "unmeasured" instead.
- Label every finding with its evidence: source (file:line), detector (rule id), Simulator (capture path), Instruments (trace), hardware.

## Run the detector first

```bash
<skill-base-dir>/scripts/impeccable-swiftui detect --json <app source folder>
```

Exit 0 clean, 2 findings, 1 error. Point it at the app's own source, not `Pods/`, `.build/`, `DerivedData`, or generated code. Verify each finding in context before it counts; note false positives with the reason, and list inline `// impeccable-disable…` waivers in scope, since each is a decision someone should be able to defend. Group findings by dimension below; `rules --json` prints each rule's rationale if you need it.

## Diagnostic Scan

Five dimensions, each scored 0–4.

### 1. Accessibility

**Check for**:
- **Unnamed controls**: image-only buttons without `.accessibilityLabel` (`icon-button-no-label`); decorative images not `.accessibilityHidden(true)`; custom controls missing `.accessibilityValue`, `.accessibilityAdjustableAction`, or traits.
- **Fake buttons**: `.onTapGesture` on views that act as buttons (`tap-gesture-as-button`): no button trait, no Voice Control name, no keyboard or Switch Control focus. Use `Button` with a custom `ButtonStyle`.
- **Reading order and grouping**: rows read as five fragments instead of one (`.accessibilityElement(children: .combine)`), headings missing `.accessibilityAddTraits(.isHeader)`, `.accessibilitySortPriority` absent where visual order misleads.
- **Dynamic Type**: `fixed-font-size`, `custom-font-no-relative`, `tiny-font`; fixed `frame(height:)` on text containers; `lineLimit(1)` on content that must be read; `.minimumScaleFactor` used to hide overflow; no layout switch at accessibility sizes (`dynamicTypeSize.isAccessibilitySize` → `VStack`). Caps via `.dynamicTypeSize(...)` belong to chrome only, never reading content.
- **Targets**: < 44×44 pt (`small-touch-target`); adjacent targets without spacing; missing `.contentShape` on padded rows.
- **Motion and transparency**: `reduce-motion-ignored`; parallax or large slides without a crossfade fallback; materials not replaced under `accessibilityReduceTransparency`.
- **Color and contrast**: text < 4.5:1 in either appearance or under Increase Contrast; state conveyed by color alone (check `accessibilityDifferentiateWithoutColor`); `gray-on-color`.
- **Announcements**: async results, errors, and state changes not posted (`AccessibilityNotification.Announcement(…).post()`), focus not moved to new content (`@AccessibilityFocusState`).

Where a UI test target exists, `XCUIApplication().performAccessibilityAudit()` (iOS 17+) is cheap, mechanical evidence. Accessibility Inspector's Audit tab covers the Simulator and Mac.

**Score**: 0 = VoiceOver can't complete the primary task · 1 = major gaps (unlabeled controls, no Dynamic Type) · 2 = partial (labels exist; order, grouping, or AX sizes break) · 3 = good (minor gaps) · 4 = excellent (named, ordered, scales to AX5, motion and contrast settings honored)

### 2. Performance

**Check for**:
- **Launch**: synchronous work in `App.init`, the root view's `init`, or before the first frame (database migration, network, large JSON decode, font registration on the main actor).
- **Invalidation**: a single `ObservableObject` whose any `@Published` change re-evaluates the whole screen; `@Observable` models read broadly in a parent `body`; environment objects injected at the root and read everywhere; expensive work in `body` (formatters, sorting, filtering, date math).
- **Identity**: `ForEach(…, id: \.self)` on non-unique or mutable values; `ForEach(array.indices, …)` on mutable collections; `.id(UUID())` resetting state every render; `any-view` erasing structural identity.
- **Lists**: long content in `VStack` inside `ScrollView` instead of `List` / `LazyVStack`; `GeometryReader` per row; heavy shadows and blurs per row.
- **Images**: full-resolution decode for thumbnails; `AsyncImage` in long lists with no cache; images decoded on the main thread.
- **Async**: `.onAppear { Task { … } }` instead of `.task` (no cancellation); main-actor work in scroll or gesture paths.
- **Effects**: continuous `repeatForever` or `TimelineView` animations off-screen; offscreen rendering from `.shadow` on large layers; missing `drawingGroup()` where many shapes composite.

Defer measurement and fixes to [optimize.md](optimize.md); record here what you found and whether it was measured.

**Score**: 0 = janky everywhere, slow launch · 1 = major problems (unvirtualized long lists, launch work on main) · 2 = partial · 3 = good (minor, measured) · 4 = fast launch, smooth 120 Hz scroll, lean invalidation, measured

### 3. Appearance & Theming

**Check for**:
- **Hard-coded color**: `hardcoded-color` outside token files; `pure-black-white-surface`; `.opacity()` on text for hierarchy (`opacity-hierarchy`) instead of `.secondary` / `.tertiary`.
- **Asset catalog hygiene**: colorsets without a Dark appearance; no High Contrast variants where contrast is tight; images that don't swap for dark; app icon missing dark and tinted variants (iOS 18+).
- **Tint**: more than one accent competing; `AccentColor` asset unused while a literal tint is set per view; `deprecated-api` `.accentColor(` instead of `.tint(`.
- **Materials and glass**: `glass-by-default`; materials on content cards instead of chrome; iOS 26 `glassEffect` / `.buttonStyle(.glass)` used without `if #available` or outside bars, controls, and floating accessories.
- **Token drift**: a design-system module exists but screens bypass it (literal radii, paddings, fonts); several `Color+` extensions defining the same role; DESIGN.md out of sync with code.
- **Slop signatures**: `ai-gradient-palette`, `gradient-text`, `glow-shadow`, `hard-offset-shadow`, `side-stripe`, `over-rounded`, `eyebrow-label`, `numbered-section`, `emoji-icon`, `overused-font`, `bounce-easing`, `section-fade`. Each is a system-level smell when it repeats.

**Score**: 0 = hard-coded everything, dark broken · 1 = minimal tokens · 2 = tokens exist, inconsistently used · 3 = semantic throughout, minor literals · 4 = semantic and asset-driven, both appearances and Increase Contrast first-class

### 4. Adaptivity

**Check for**:
- **Stretched phone UI**: iPad or Mac rendering a centered phone column or full-width rows; no `NavigationSplitView` where content is list-detail; `screen-bounds-layout` (`UIScreen.main.bounds`) instead of container size.
- **Size-class handling**: layout branching on device idiom instead of `horizontalSizeClass` or measured size; `GeometryReader` wrapping whole screens; no `ViewThatFits` / `AnyLayout` where a row can't fit.
- **Multitasking and windows**: iPad Split View, Slide Over, and resizable windows (iPadOS 26) yielding a compact width on a regular device; `UIRequiresFullScreen` set to dodge layout; multiple windows sharing state that should be per-scene (`@SceneStorage`).
- **Orientation**: landscape clipping or locked without reason; keyboard covering inputs in landscape.
- **Keyboard and pointer**: no `.keyboardShortcut` on iPad/Mac primary actions; no `@FocusState` flow through forms; no `.hoverEffect` on custom tappable surfaces on iPad or visionOS; no `.onHover` / `.help` on Mac.
- **iPhone Duo** (iOS 27.1, when shipped): content or controls under the fold's `.division` reserved region when partially open; a single phone column on the inner display; two-pane content not using `ArrangementView`; poses ignored where they'd help (`.onHingeChange`).
- **Other platforms** shipped: Mac Catalyst with iOS-sized controls and no menu bar commands; watchOS screens that scroll where a glance should do; visionOS windows with 44 pt targets instead of 60 pt and no hover effects.

Detail and fixes live in [adapt.md](adapt.md).

**Score**: 0 = one size only · 1 = major breakage (iPad or landscape broken) · 2 = partial · 3 = good (edge cases) · 4 = restructures per size class, window, orientation, posture, and input

### 5. Anti-patterns & Platform Conformance (CRITICAL)

The detector's findings, verified, plus what it can't see:
- `hidden-nav-bar` with a reinvented header; dead edge-swipe back; custom tab bars; web-shaped buttons and toggles; hover-dependent affordances.
- `deprecated-api`: `NavigationView`, `.foregroundColor(`, `.cornerRadius(`, `.navigationBarTitle(`, `.edgesIgnoringSafeArea(`, `.animation(_:)` without `value:`.
- Non-SF icon sets mixed with SF Symbols; emoji as icons.
- System surfaces left at defaults where they matter: wrong `keyboardType` / `textContentType` / `.submitLabel`, no swipe actions or context menus on rows, no pull-to-refresh on refreshable content, no `.sensoryFeedback` on meaningful state changes, a blank launch screen that flashes the wrong color.
- Repeated decorative shortcuts that conflict with the product or DESIGN.md: design-system drift, not one-offs.

**Score**: 0 = a web port (nothing native, systemic slop) · 1 = heavy violations (3–4 kinds, repeated) · 2 = several verified issues · 3 = isolated minor issues · 4 = a fluent user trusts every screen; detector clean or every finding justified

## Generate Report

### Audit Health Score

| # | Dimension | Score | Key Finding |
|---|-----------|-------|-------------|
| 1 | Accessibility | ? | [most critical issue, or "—"] |
| 2 | Performance | ? | [note "unmeasured" when true] |
| 3 | Appearance & Theming | ? | |
| 4 | Adaptivity | ? | |
| 5 | Anti-patterns & Conformance | ? | |
| **Total** | | **??/20** | **[Rating band]** |

**Bands**: 18–20 Excellent (minor polish) · 14–17 Good (address weak dimensions) · 10–13 Acceptable (significant work) · 6–9 Poor (major overhaul) · 0–5 Critical (fundamental issues)

### Conformance Verdict
**Start here.** Pass/fail: does this read as a native app with a coherent, product-specific system, or a ported website with template slop? Cite verified evidence and detector counts. Be blunt.

### Executive Summary
- Audit Health Score: **??/20** ([band])
- Issues by severity: P0 / P1 / P2 / P3
- Detector: N findings across M files (top rules by count); K false positives; W waivers
- Top 3–5 critical issues
- Evidence used: source / detector / Simulator devices / Instruments / hardware

### Detailed Findings by Severity

- **P0 Blocking**: prevents task completion (VoiceOver can't reach the primary action, AX5 pushes it off-screen, crash or data loss). Fix now.
- **P1 Major**: significant difficulty, WCAG AA or HIG violation, App Review risk. Fix before release.
- **P2 Minor**: annoyance, workaround exists. Next pass.
- **P3 Polish**: no real user impact. If time permits.

For each issue:
- **[P?] Issue name**
- **Location**: screen, file:line (rule id if detected)
- **Category**: Accessibility / Performance / Theming / Adaptivity / Anti-patterns
- **Impact**: who it hurts, how
- **Standard**: HIG page, WCAG criterion, or detector rule, when applicable
- **Recommendation**: the SwiftUI fix, concretely
- **Evidence**: source / detector / Simulator / Instruments / hardware
- **Suggested command**: `/impeccable-swiftui <command>`

### Patterns & Systemic Issues

Recurring problems that point to a missing system, not one-off mistakes:
- "`hardcoded-color` in 23 views across 9 files; no colorsets for brand roles. Extract to a `DesignSystem` module."
- "Every icon-only toolbar button is unlabeled (`icon-button-no-label` ×14)."
- "Rows fix `frame(height: 64)`; every list truncates at AX3+."

### Positive Findings

What's working and worth replicating: good practices to keep.

## Recommended Actions

Priority order, P0 first:

1. **[P?] `/impeccable-swiftui <command>`**: what to fix, with file and finding context
2. …

Map findings to the best command: Accessibility → `harden` (states, VoiceOver, AX5) or `clarify` (labels, copy); Performance → `optimize`; Theming drift → `extract` then `document`; slop and visual anti-patterns → `polish`, `quieter`, `distill`, `typeset`, `colorize`, or `layout`; Adaptivity → `adapt`; motion → `animate`. Skip commands that address nothing. End with `/impeccable-swiftui polish` when any fix was recommended.

Then tell the user:

> You can ask me to run these one at a time, all at once, or in any order you prefer.
>
> Re-run `/impeccable-swiftui audit` after fixes to see your score improve.

**IMPORTANT**: thorough but actionable. A pile of P3s is noise. Focus on what matters.

**NEVER**:
- Report an issue without its impact
- Give generic advice ("improve accessibility"); name the view, the modifier, the fix
- Count an unverified detector finding
- Claim a performance problem or fix without saying whether it was measured
- Skip positive findings
- Make everything P0

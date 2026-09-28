> **Additional context needed**: quality bar and shipping constraints.

Polish is refinement, never concealed redesign. Preserve the incumbent visual world, content, behavior, and everything outside scope. If the concept itself is wrong, say so and recommend redesign or `/impeccable-swiftui bolder` instead of smuggling in a replacement.

A clean detector run is defect evidence, not proof of quality. Inspect the running app and the real interaction path.

## 1. Establish the system

Read DESIGN.md and the representative system code: colorsets and `Color` / `ShapeStyle` extensions, `Font` roles, spacing and radius constants, `ButtonStyle`s, shared rows, cards, and modifiers, and the neighboring screens users reach from this one. With no formal system, use the project's coherent conventions.

Classify each drift before fixing it:

- **missing token**: the system needs a reusable value (a new colorset, a `Spacing` case, a `Font` role);
- **one-off implementation**: an existing shared style or component should replace it (a hand-built capsule that should be `.buttonStyle(.brandPrimary)`);
- **conceptual mismatch**: the flow, navigation model, or hierarchy differs from comparable screens (push here, sheet there for the same kind of task);
- **local defect**: simply incomplete or inconsistent.

Fix the cause at the narrowest correct level. Ask when a binding system principle can't be inferred.

## 2. Gather the evidence

Use the feature yourself on the device classes it ships to: build, install, and launch on the Simulator per the loaded platform reference ([platforms/ios.md](platforms/ios.md) and siblings), captures into `.impeccable/shots/`. Determine:

- whether the path is functionally complete;
- the intended quality bar and time available;
- known constraints or deliberately unfinished work;
- the states, content lengths, Dynamic Type sizes, and input methods (touch, keyboard, pointer, VoiceOver) users will actually bring.

If a prior critique exists, use it as one input. List `.impeccable/critique/*-<slug>*.md`, take the newest file with `status: open`, and recompute the fingerprint over the files in its `files:` list:

```bash
cat <files from the snapshot, sorted> | shasum -a 256 | cut -d' ' -f1
```

- **Match**: the snapshot describes the code as it is. Take its P0/P1 Priority Issues into triage and name the snapshot you read. Remember its path until the end of the pass.
- **Mismatch or missing file**: the code changed since the critique. Set that snapshot's `status: closed` (its trend history stays), note it, and don't treat its findings as current.
- **No snapshot**: proceed.

Do an independent pass either way.

## 3. Triage

Separate functional defects from cosmetic ones. Fix in this order:

1. broken or blocked tasks, data loss, misleading state, paths VoiceOver or AX5 can't complete;
2. missing loading, empty, error, success, disabled, offline, and permission-denied states;
3. flow, hierarchy, adaptivity, and design-system drift;
4. visual and motion inconsistencies;
5. code and asset cleanup.

Don't perfect one corner while the rest sits below the same bar.

## 4. Polish the whole path

### Flow and hierarchy

- Match neighboring mental models: the same kind of task uses the same presentation (push vs sheet vs `fullScreenCover`), the same save model (explicit Done vs autosave), the same destructive-action pattern (`role: .destructive` + `.confirmationDialog` or undo).
- Make the primary action and current state obvious without flattening everything to equal weight: one `.borderedProminent` (or its brand equivalent) per screen, the rest quieter.
- Connect arrival, transition, empty, and recovery paths. A sheet that saves should land the user on the thing they made, not back at the top of a list.

### Layout and type

- Align to the project's spacing scale; fix optical alignment too (SF Symbols beside text use `Label` or `.alignmentGuide`, not nudged `offset`s).
- Group tightly within, generously between. Padding comes from the scale, not ad-hoc `.padding(13)`.
- Same role, same `Font`. Check wrapping and measure at AX sizes, in German, and in landscape.
- Verify every shipped device class, not only the current capture.

### Color, imagery, and icons

- Semantic colors and asset colorsets with stable meaning in light, dark, and Increase Contrast. Hierarchy through `.secondary` / `.tertiary`, not `.opacity` (`opacity-hierarchy`).
- Contrast ≥ 4.5:1 for text, 3:1 for controls and focus, in every state.
- One icon family: SF Symbols with a consistent weight matched to adjacent text, `.imageScale`, and rendering mode (`.symbolRenderingMode(.hierarchical)` or the project's choice) applied consistently. No emoji standing in for icons (`emoji-icon`).
- Images keep aspect ratio (`.aspectRatio(contentMode:)`, fixed frames or `containerRelativeFrame`), reserve space while loading, and carry `.accessibilityLabel` or `.accessibilityHidden(true)`.

### Interaction and state

- Every control has default, pressed (`configuration.isPressed`), disabled, loading, error, and success behavior; pointer hover (`.hoverEffect`) on iPad and visionOS, `.onHover` / `.help` on Mac where the pattern calls for it.
- Keyboard: `@FocusState` moves through form fields, `.submitLabel` matches the action, return advances or submits; `.keyboardShortcut` for primary actions on iPad and Mac.
- VoiceOver names match visible labels; 44×44 pt targets with `.contentShape` where padding extends the hit area.
- Haptics are consistent: `.sensoryFeedback` for success, selection, and impact where the platform would give it, nowhere else.
- Motion is coherent, interruptible, and honors Reduce Motion. Don't add animation to make polish visible.
- Validate long, missing, localized, offline, slow, and permission-limited content where the product can meet it.

### Content and code

- Consistent terminology, capitalization (title case for buttons and navigation titles on Apple platforms, sentence case for body and footers), punctuation, and facts. Ask before changing claims.
- Remove `print`, debug overlays, dead code, unused assets and colorsets, commented-out views, and polish-created duplication.
- Replace custom implementations with shared styles and components where the system owns the pattern; replace `deprecated-api` uses you touch.
- Promote genuinely reusable values to tokens; don't build an abstraction for one exception.

## 5. Verify and finish

One batched round across the path, then at most one confirming round. Check:

- every shipped device class, both supported orientations, light and dark, AX5, and iPad multitasking widths;
- loading, empty, error, success, disabled, long-content, and missing-content states;
- VoiceOver order and names, Increase Contrast, Reduce Motion, keyboard focus;
- runtime warnings in the Xcode console (purple issues, "Publishing changes from within view updates", constraint noise), hitches in scroll, and agreement with DESIGN.md, neighboring screens, and the user's scope.

Follow the quality guidance from `context` and the hook ([hooks.md](hooks.md)). When no hook is active, run `<skill-base-dir>/scripts/impeccable-swiftui detect <touched files>` once; never add a second detector pass. Fix real defects; waive only narrow, intentional exceptions with `// impeccable-disable-next-line <rule>: <reason>`. A clean scan doesn't replace looking.

Finish with a source diff review: remove accidental churn, orphaned code, redundant values, and temporary captures outside `.impeccable/shots/`. Ship only when the path is functionally complete and consistently finished.

When this pass clears every Priority Issue it took from a snapshot, set that snapshot's front matter to `status: closed`. Close only the snapshot you actually processed; a newer critique that landed meanwhile stays open. Don't close when no snapshot was read or when Priority Issues remain.

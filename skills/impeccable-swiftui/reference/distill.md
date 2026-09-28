Strip a screen to its essence. Remove anything that doesn't earn its place: redundant elements, repeated information, decorative noise, cosmetic complexity.

---

## Assess current state

1. **Identify complexity sources**:
   - **Too many elements**: competing buttons, toolbar items that are really menu items, redundant labels
   - **Excessive variation**: too many colors, faces, text styles, button styles without purpose
   - **Information overload**: everything visible at once, no progressive disclosure
   - **Visual noise**: containers around containers, shadows, materials, decorative symbols
   - **Confusing hierarchy**: three `.borderedProminent` buttons on one screen
   - **Feature creep**: too many tabs, settings, paths forward

2. **Find the essence**:
   - What's the primary user goal on this screen? (There should be ONE)
   - What's necessary vs nice-to-have?
   - What can be removed, deferred to a menu or sheet, or combined?
   - What's the 20% that delivers 80% of value?

If any of these are unclear from the codebase, do not guess. Ask the user before continuing (use the AskUserQuestion tool when it is available).

**CRITICAL**: Simplicity is not about removing features. It's about removing obstacles between people and their goals. Every view should justify its existence.

## Plan simplification

- **Core purpose**: what's the ONE thing this screen should accomplish?
- **Essential elements**: what's truly necessary to achieve it?
- **Progressive disclosure**: what can wait until asked for?
- **Consolidation**: what can be combined?

**IMPORTANT**: Simplification requires saying no to good ideas to make room for great execution. Be ruthless.

## Simplify the design

### Information architecture
- **Reduce scope**: remove secondary actions, optional features, redundant information.
- **Progressive disclosure with platform primitives**: `Menu` or `.contextMenu` for secondary actions, `.swipeActions` for per-row actions, `DisclosureGroup` for rarely-needed detail, a sheet with `.presentationDetents([.medium, .large])` for a self-contained sub-task, a pushed detail for depth.
- **Clear hierarchy**: ONE primary action (one `.borderedProminent`, or `ToolbarItem(placement: .confirmationAction)`), few secondary actions, everything else in a menu.
- **Tabs are sections, not features**: 2–5 tabs. A sixth tab is a sign something should live inside another section.
- **Remove redundancy**: if the navigation title says it, the first row doesn't.

### Visual simplification
- **Palette**: tint plus semantic system colors, not five brand swatches.
- **Typography**: one family (SF is fine), 3–4 text styles on a screen, 2–3 weights.
- **Remove decorations** that don't serve hierarchy or function.
- **Flatten structure**: a `List` or `Form` section already groups; don't wrap rows in cards, never nest cards in cards.
- **Consistent spacing**: one scale, no arbitrary `padding(13)`.

### Layout simplification
- **Linear flow**: a single scrolling column beats a clever grid on iPhone.
- **Use the space you have**: on iPad and Mac, `NavigationSplitView` or a real multi-column layout, not a phone column centered in a wide window.
- **Consistent alignment**: leading alignment for reading; center only for short, isolated moments.

### Interaction simplification
- **Reduce choices**: fewer buttons, clearer path forward.
- **Smart defaults**: preselect the common choice; ask only when necessary.
- **Inline editing** over modal forms where the platform supports it (`TextField` in a row, `Toggle` in place).
- **Remove steps**: can the flow lose a screen? Can a confirmation become an undo?
- **Clear next action**: ONE obvious next action.

### Content simplification
- **Shorter copy**: cut every sentence in half, then do it again.
- **Active voice**: "Save" not "Changes will be saved."
- **No jargon**; say it once.
- Button labels are verbs; alerts say what happened and what to do.

### Code simplification
- **Remove dead views**, unused modifiers, orphaned `Color` assets and preview-only code paths.
- **Flatten view trees**: extract subviews where they clarify, collapse wrappers that only add padding.
- **Drop `AnyView`** (`any-view`) for `@ViewBuilder`, `Group` or generics.
- **Consolidate styles**: one `ButtonStyle` per role and a few `ViewModifier`s instead of copy-pasted modifier chains.
- **Reduce variants**: does that component need 12 initializers, or do 3 cover 90% of cases?

**NEVER**:
- Remove necessary functionality (simplicity ≠ feature-less)
- Remove accessibility labels, traits or targets for a cleaner look (`icon-button-no-label`, `small-touch-target`)
- Hide the only path to a feature inside an undiscoverable gesture (mystery ≠ minimalism)
- Remove information people need to make decisions
- Eliminate hierarchy completely
- Oversimplify complex domains (match complexity to actual task complexity)

## Verify simplification

- **Faster task completion**: can people finish the goal in fewer taps?
- **Reduced cognitive load**: is it obvious what to do?
- **Still complete**: is every necessary feature still reachable, including by VoiceOver and keyboard?
- **Clearer hierarchy**: is it obvious what matters most?
- **Lighter**: fewer views, fewer body re-evaluations, faster scroll.

## Document removed complexity

If you removed features or options: note why, where they moved (menu, settings, detail screen) or that they are gone, and what feedback to watch for.

When the cuts feel right, hand off to `/impeccable-swiftui polish` for the final pass. As Antoine de Saint-Exupéry put it: "Perfection is achieved not when there is nothing more to add, but when there is nothing left to take away."

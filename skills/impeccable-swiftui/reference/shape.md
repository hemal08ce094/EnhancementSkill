# Shape

Discover what should be made and how it should work, then return a confirmed design brief without code.

## Phase 1: Discovery interview

Do not write Swift or choose visual direction yet.

### Cadence

- Ask with the AskUserQuestion tool when available; otherwise ask in plain text and stop.
- Ask two or three related questions per round, then wait. One round is the default; add a second only when the answers expose a material gap.
- Do not dump a questionnaire, repeat settled facts, or turn obvious facts into menus. Assert the likely reading and invite correction.
- A sparse prompt requires at least one answer round. A precise prompt may need only a compact confirmation.

### Round 1: purpose, people, and outcome

Choose the two or three questions that most change the result:

- What is this screen, flow, or feature for, and what problem must it solve?
- Who reaches it, from where (tab, deep link, notification, widget tap, Siri, share sheet), in what situation and state of mind?
- What is the one thing they must understand or do here? What does success look like?
- What is uniquely true here that a neighboring app or a stock template could not claim?

### Round 2: material, behavior, and boundaries

Run only for material unresolved decisions:

- What real content, data, and assets must it carry? Realistic minimum, typical, and maximum: a name of 4 or 40 characters, 0 or 4,000 rows, German and Arabic strings, AX5 text.
- Which states and transitions matter: first launch, empty, loading, offline, error, permission denied, success, overflow, expert use?
- Which platforms and device classes, and does the layout change with size class, orientation, a Mac window, or the iPhone Duo's inner display?
- What system surfaces does the job touch: widgets, Live Activities, notifications, App Intents, context menus, swipe actions, the keyboard on iPad and Mac?
- Fidelity and breadth: exploration, a production-ready screen, a full flow, or a broader surface?
- What must remain untouched? What would make the result feel wrong even if it looked polished?

Never ask for point sizes, hex values, or canned aesthetic lanes. New-work owns visual-world and concept choices.

## Phase 2: Resolve the design direction

For new screens, a brand expansion, or a replacement world, follow [new-work.md](new-work.md) through visual authority, the direction round, and concept choice. Reuse this discovery, then return here before its contract, persistence, or implementation. Inside an established world, use its structure round only when composition or interaction is materially open.

## Phase 3: Write the brief

Write the smallest useful brief:

1. **Job and audience:** who arrives, from where, their context, need, and visitor mode.
2. **Outcome and proof:** primary task or action, success, real evidence, product-specific truth.
3. **Selected direction:** visual authority, structural and interaction thesis, focal moment, and its implementation consequence.
4. **Scope and boundaries:** fidelity, breadth, platforms, named target, what stays untouched, explicit anti-goals.
5. **States and ranges:** realistic content ranges and the material states.
6. **Navigation and layout:** where it sits in the navigation model (tab, push, sheet, full-screen cover, inspector, window), hierarchy, size-class behavior, affordances, feedback, transitions; intent, not modifiers.
7. **Constraints and open decisions:** minimum OS, accessibility, localization, reusable components, and choices a builder must not invent.

Use three to five bullets when the task is settled; use the full structure only for ambiguous, multi-screen, or standalone planning. Do not restate the conversation.

## Confirm and stop

Present the brief for explicit confirmation or one correction round, then stop: shape never writes code or a direction contract.

When no human or structured answer mechanism exists, mark assumptions plainly, return the brief, and stop.

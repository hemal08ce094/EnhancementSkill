> **Additional context needed**: audience knowledge and emotional state.

Rewrite unclear interface text so users understand what happened, what matters, and what to do next. Preserve factual meaning, product terminology, and brand voice.

## Audit the language

Read the whole interaction path in the running app and in source: navigation titles, buttons, toolbar items, row labels, `Form` section headers and footers, placeholders, alerts and confirmation dialogs, `ContentUnavailableView`s, context menu items, swipe actions, accessibility labels, permission usage strings (`NS…UsageDescription`), notifications, widgets, and App Intents titles. Identify:

- ambiguous nouns, verbs, and actions;
- internal jargon or model names leaking into UI (`sync_state`, "Entity", "Record");
- vague labels, outcomes, and system states;
- missing consequences, recovery, or timing;
- inconsistent terminology and capitalization;
- redundant titles, intros, footers, and confirmations;
- text that truncates at AX sizes, in German, or in a narrow iPad window;
- tone that ignores stress, risk, success, or urgency.

Infer audience and task from PRODUCT.md and the surrounding UI. Ask before changing factual claims, legal or financial meaning, or a term that may be domain-specific.

## Set the message hierarchy

For each state, decide:

1. the one fact the user needs now;
2. the action available next;
3. supporting context that changes the decision;
4. the tone for this moment.

Say each idea once. If the navigation title already names the state, the body adds new information or disappears.

## Rewrite by function

### Actions and navigation

A specific verb, plus the object when the outcome isn't obvious: **Save Draft**, **Add Card**, **Send Invite**. Labels describe what happens, not the gesture. Same noun and verb for the same concept everywhere.

Follow Apple platform conventions: **title case** for buttons, navigation titles, tab labels, and menu items; sentence case for footers, descriptions, and alert messages. The standard sheet pair is **Cancel** / **Done** (or a specific verb: **Add**, **Save**, **Send**). Don't write "Click"; on touch platforms nothing is clicked, and on all of them the label should name the result.

Destructive actions name the object and consequence. Prefer undo over confirmation when recovery is safe. When confirmation is necessary, use `.confirmationDialog` with a `role: .destructive` button that repeats the verb: title "Delete 3 photos?", message "They'll be removed from all your devices.", button **Delete Photos**. Never **Yes** / **No** / **OK**.

Icon-only buttons need names that match the outcome: `Button("Add Recipe", systemImage: "plus") { … }` with `.labelStyle(.iconOnly)` keeps the name for VoiceOver and Voice Control (`icon-button-no-label` flags the rest).

### Forms

Persistent labels; placeholders are examples ("name@example.com"), not labels. In a `Form`, the row label or `LabeledContent` is the label; `TextField("Email", text:)` alone loses its label once filled. Put format and eligibility requirements in the section footer before submission. Explain why information is requested only when it isn't obvious. Mark required or optional consistently.

Validation says what needs attention and how to fix it, beside the field, without blame: "Enter a date after today", not "Invalid date". Announce it to VoiceOver.

### Errors and permissions

An actionable error answers:

1. what failed;
2. why, when known and useful;
3. how to recover, or what still works.

"Couldn't sync your notes. You're offline; changes are saved on this iPhone and will sync when you reconnect." Not "Error 1009". Never show a raw `localizedDescription` from a URL or decoding error. Don't promise a cause or fix the app can't know.

Permission usage strings are the system prompt's body; make them specific and honest: "Trailhead uses your location to show nearby trails and record your route." Not "This app needs your location." The in-app pre-prompt and the denied state say the same thing, and the denied state offers **Open Settings**.

Treat privacy, payment, deletion, access loss, and blocked work seriously; warmth is welcome, jokes are not.

### Loading, empty, and success states

Loading text names the real operation when the wait is noticeable ("Importing 240 photos…") and shows determinate progress when it exists. Never invent progress.

`ContentUnavailableView` distinguishes first use, no search results, filtered to nothing, permission-limited, and failure. Title states the situation, description explains, actions offer the next useful step. First use invites ("No Trips Yet" / "Trips you plan appear here." / **Plan a Trip**); no results helps ("No Results for 'Lisbn'" / "Check the spelling or try a new search.").

Success confirms the outcome briefly and mentions the next consequence only when it changes what the user does. Routine success is often better as a state change and a `.sensoryFeedback(.success, trigger:)` than as words.

### Help and instructional text

Section footers answer an implicit question instead of restating the control ("Turn on to get a reminder the evening before each trip" beats "Enable reminders"). Use `DisclosureGroup` or a detail screen for uncommon depth; TipKit for a non-obvious gesture, sparingly.

## Voice, accessibility, and localization

Voice stays consistent; tone adapts to the moment. Plain language, without flattening terms the audience genuinely knows.

- Write complete, localizable sentences with interpolation (`Text("\(name) joined \(group)")`), never concatenated fragments; translators must be able to reorder.
- Let the String Catalog handle plurals (`Text("\(count) photos")` with plural variations); never `count == 1 ? "" : "s"`.
- Add translator comments: `String(localized: "Share", comment: "Toolbar button that opens the share sheet for the current trip")`.
- Allow expansion; don't abbreviate preemptively. Test with the Double-Length pseudolanguage.
- Accessibility labels match visible labels and describe outcomes; `.accessibilityHint` only when the result isn't obvious. `.accessibilityLabel` on images conveys information; decorative images are `.accessibilityHidden(true)`.
- Don't rely on punctuation, color, emoji, or SF Symbols alone to carry the message.

Keep a short glossary when inconsistency spans the product. Don't vary words for literary effect.

## Verify

Read the flow in context on the Simulator and test:

- comprehension without hidden product knowledge;
- actionability at errors, empty states, and decision points;
- factual accuracy and consistent terminology and capitalization;
- scanability at AX5 and in a narrow window; no meaning lost to truncation;
- long names, pseudolanguage expansion, plural edge counts (0, 1, 2, many), dynamic values;
- VoiceOver names and announced state changes;
- tone matched to consequence.

The final copy is as short as it can be without losing meaning or recovery.

When the language reads cleanly, hand off to `/impeccable-swiftui polish` for the final pass.

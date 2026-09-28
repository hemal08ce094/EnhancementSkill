Designs that only work with perfect data aren't production-ready. Harden the app against the inputs, errors, languages, settings, and lifecycle events real users bring.

## Assess Hardening Needs

Walk the target and list its weak points before touching code:

1. **Extreme content**: 60+ character names and titles; empty and single-character strings; emoji, accents, CJK, Arabic; numbers in the millions; 0, 1, and 1,000+ items; missing images and optional fields.
2. **Failure**: offline, slow, timeout; 401/403/404/429/5xx; validation errors; permission denied; concurrent edits; iCloud or account unavailable; disk full.
3. **Settings**: Dynamic Type through AX5, VoiceOver, Voice Control, Bold Text, Increase Contrast, Reduce Motion, Reduce Transparency, Differentiate Without Color, dark appearance, 12/24-hour time, non-Gregorian calendars, metric/imperial.
4. **Lifecycle**: backgrounding mid-task, termination and relaunch, memory warnings, a phone call or Siri interrupting, a second window on iPad or Mac.
5. **Locale**: long translations (German runs ~30% longer), RTL (Arabic, Hebrew), CJK line breaking, locale formats for dates, numbers, and currency.

**CRITICAL**: Harden against reality, not the demo data.

## Hardening Dimensions

### Text overflow and Dynamic Type

- Let text wrap. `lineLimit` is for genuinely single-line chrome; reading content gets `lineLimit(nil)` or a generous limit with an expand affordance. `.truncationMode(.middle)` for file names and identifiers.
- Never fix text container heights. Rows grow; `frame(minHeight:)` if you need a floor.
- `.minimumScaleFactor` is a last resort for one short label, never a fix for layout overflow.
- Switch structure at accessibility sizes instead of squeezing:
  ```swift
  @Environment(\.dynamicTypeSize) private var typeSize
  var body: some View {
      let layout = typeSize.isAccessibilitySize
          ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
          : AnyLayout(HStackLayout(spacing: 12))
      layout { icon; titleAndDetail; Spacer(minLength: 0); value }
  }
  ```
  Or `ViewThatFits(in: .horizontal) { wideRow; stackedRow }` when the content decides.
- Scale non-text metrics with text: `@ScaledMetric(relativeTo: .body) private var iconSize = 24`.
- Cap with `.dynamicTypeSize(...DynamicTypeSize.accessibility2)` only on chrome that physically can't grow (a compact tab strip, a HUD). Reading content is never capped.
- Detector: `fixed-font-size`, `custom-font-no-relative`, `tiny-font`.

### Localization and pluralization

- All user-facing strings go through a **String Catalog** (`Localizable.xcstrings`). `Text("Delete Photo")` and `LocalizedStringKey` parameters are extracted automatically on build; in models and view models use `String(localized: "Delete Photo", comment: "Button that deletes the selected photo")`. Always add a comment; translators see nothing else.
- Pluralize in the catalog, never in code:
  ```swift
  // ❌ Text("\(count) item" + (count == 1 ? "" : "s"))
  Text("\(count) items")   // catalog: Vary by Plural → one / other (plus few / many where the language needs them)
  ```
  Interpolate whole sentences so translators can reorder: `Text("\(name) shared \(count) photos")`, never concatenated fragments.
- Format with `FormatStyle`, never string math: `Text(date, format: .dateTime.day().month())`, `Text(price, format: .currency(code: currencyCode))`, `Text(distance, format: .measurement(width: .abbreviated))`, `.formatted(.list(type: .and))`, `Text(date, style: .relative)`. Parse user input with the same styles.
- Localize images with text in them, or better, don't put text in images.
- `.textCase(.uppercase)` over hand-uppercased strings; uppercasing is locale-sensitive.
- Verify with scheme pseudolanguages: **Edit Scheme → Run → Options → App Language**: *Double-Length Pseudolanguage* (overflow), *Accented Pseudolanguage* (clipping of ascenders and descenders), *Bounded String Pseudolanguage* (concatenation and truncation), *Right-to-Left Pseudolanguage*. Or per launch: `xcrun simctl launch <UDID> <bundle-id> -AppleLanguages "(de)" -AppleLocale de_DE`, and `-NSDoubleLocalizedStrings YES`.

### Right-to-left

- SwiftUI mirrors `leading` / `trailing`, `HStack` order, and navigation automatically. Your job is not to break it: no `.left` / `.right` alignment, no hard-coded `x` offsets, no `rotationEffect` on chevrons.
- Directional SF Symbols (`chevron.forward`, `arrow.forward`) flip on their own; `chevron.right` does not. Custom directional images: set **Direction → Left to Right, Mirrors** in the asset catalog, or `.flipsForRightToLeftLayoutDirection(true)`.
- Don't mirror what isn't directional: media playback controls, clocks, charts' time axes, phone numbers, logos.
- Preview both: `.environment(\.layoutDirection, .rightToLeft)` with `.environment(\.locale, Locale(identifier: "ar"))` in a `#Preview`; confirm on the Simulator with the RTL pseudolanguage.

### Errors and offline

- Every async call has a visible failure path. A screen-level load failure uses `ContentUnavailableView` with a plain-language title, a reason when known, and a **Try Again** action:
  ```swift
  ContentUnavailableView {
      Label("Couldn't Load Trips", systemImage: "wifi.exclamationmark")
  } description: {
      Text("Check your connection. Your saved trips are still available offline.")
  } actions: {
      Button("Try Again") { Task { await model.reload() } }
  }
  ```
- Keep cached content on screen when a refresh fails; show a non-blocking banner or inline notice, not a wiped list.
- Map failures to user meaning: 401 → re-authenticate with context preserved; 403 → explain what access is missing; 404 → "This item was deleted"; 429 → say when to retry; 5xx → retry plus a support path. Never show `error.localizedDescription` from a decoding or URL error as the message.
- Detect reachability with `NWPathMonitor` to label offline state and queue writes; don't gate reads on it (the request is the truth).
- Forms preserve input on failure and put the error beside the field, announced to VoiceOver.
- Alerts are for decisions and blocking failures, not routine errors. Toasts that vanish before VoiceOver reads them are not error handling.

### Empty and loading states

- Distinguish first use, no results, filtered-to-nothing, permission-limited, and failure. Each gets its own `ContentUnavailableView` with the next useful action; `ContentUnavailableView.search(text:)` for empty search.
- Loading: skeletons with `.redacted(reason: .placeholder)` on real layout (so nothing jumps when data lands), `ProgressView` for short indeterminate waits, determinate `ProgressView(value:)` for known progress. Say what's loading when it takes more than a beat.
- Pagination loads ahead (`.onAppear` of a row near the end, or `.onScrollTargetVisibilityChange` on iOS 18+), shows a footer spinner, and survives failure with a retry row.

### Concurrency and double actions

- Disable the submit button while a request is in flight and show progress in it; guard the action itself too (a keyboard shortcut or double-tap can fire twice).
- Use `.task(id:)` so changing input cancels stale work; check `Task.isCancelled` in long loops.
- Optimistic updates roll back visibly on failure.
- Custom `DragGesture` / `MagnifyGesture` code handles `.onEnded` *and* cancellation: reset `@GestureState` (it resets itself on cancel; plain `@State` doesn't), so an interrupted drag never leaves a view half-moved.

### Permissions

- Ask in context, after showing value, never on first launch for everything. Explain in-app before the system prompt when the reason isn't obvious, and write specific `NS…UsageDescription` strings.
- Handle **denied** and **restricted** as first-class states: the feature explains what it needs and offers **Open Settings** (`Link("Open Settings", destination: URL(string: UIApplication.openSettingsURLString)!)` on iOS). Handle **limited** Photos access (`PHPickerViewController` / `PhotosPicker` needs no permission at all; prefer it).
- Test: `xcrun simctl privacy <UDID> revoke photos <bundle-id>`, `… reset all <bundle-id>`, then relaunch.

### Lifecycle and state restoration

- React to `@Environment(\.scenePhase)`: save drafts on `.background`, refresh stale data on `.active`, pause timers and media on `.inactive`.
- Persist in-progress work: `@SceneStorage` for per-window UI state (selected tab, navigation path via `NavigationPath.CodableRepresentation`, draft text), `@AppStorage` for small preferences, SwiftData or files for real content. Relaunch lands where the user was.
- Test termination: background the app, `xcrun simctl terminate <UDID> <bundle-id>`, relaunch; then Debug → Simulate Memory Warning in the Simulator while a heavy screen is open.
- Multiple windows on iPad and Mac: state that belongs to a window lives in the scene, not a global singleton.

### Accessibility resilience

- VoiceOver completes every primary flow: named controls (`icon-button-no-label`), real buttons (`tap-gesture-as-button`), grouped rows, headings, values on custom controls, announcements for async results (`AccessibilityNotification.Announcement("Saved").post()`), focus moved to new content with `@AccessibilityFocusState`.
- Voice Control: visible label text matches the accessible name; `.accessibilityInputLabels` for alternates.
- Reduce Motion (`accessibilityReduceMotion`), Reduce Transparency (`accessibilityReduceTransparency` → solid fallbacks for materials), Differentiate Without Color (`accessibilityDifferentiateWithoutColor` → add shapes or symbols), Increase Contrast (colorset High Contrast variants).
- 44×44 pt targets everywhere (`small-touch-target`), 60 pt on visionOS.

### Input validation

- Constrain before validating: `Picker`, `DatePicker(in:)`, `Stepper(in:)`, `TextField(value:format:)`, correct `keyboardType`, `textContentType` (`.emailAddress`, `.oneTimeCode`, `.newPassword`), `.autocorrectionDisabled()` and `.textInputAutocapitalization(.never)` for identifiers.
- Validate inline, near the field, once the user has had a chance to finish (on submit or focus loss, not per keystroke); say how to fix it.
- The server validates too. Client validation is courtesy.
- Paste handles whitespace, formatting characters, and full-width digits.

## Testing Strategies

**Manual matrix** (Simulator, captures to `.impeccable/shots/harden-<target>/`):

```bash
xcrun simctl ui <UDID> content_size accessibility-extra-extra-extra-large
xcrun simctl ui <UDID> appearance dark
xcrun simctl ui <UDID> increase_contrast enabled
xcrun simctl launch --terminate-running-process <UDID> <bundle-id> -AppleLanguages "(ar)"
xcrun simctl privacy <UDID> revoke location <bundle-id>
```

Network conditions: **Network Link Conditioner** (Xcode Additional Tools) on the Mac for the Simulator, or **Developer → Network Link Conditioner** on a device, with 100% Loss and Very Bad Network profiles. VoiceOver and Voice Control on hardware; the Simulator has neither, so use Accessibility Inspector there and say so.

**Automated**: unit tests for formatting, pluralization edge counts (0, 1, 2, 5, 21), and error mapping; UI tests that launch with `-AppleLanguages`, `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityXXXL`, and seeded fixtures via DEBUG launch arguments; `try app.performAccessibilityAudit()`; `#Preview`s for each state (empty, loading, error, long content, RTL, AX5) so regressions are visible at a glance.

Say what produced the evidence (Preview, Simulator, hardware) and name what stayed untested.

**NEVER**:
- Assume perfect input or English-length text
- Concatenate localized fragments or pluralize in code
- Fix heights on text containers or cap reading content's Dynamic Type
- Show raw error descriptions or codes as the message
- Wipe cached content because a refresh failed
- Ask for every permission on first launch, or dead-end when one is denied
- Lose a draft to backgrounding
- Block the whole screen when one component fails

When edge cases are covered, hand off to `/impeccable-swiftui polish` for the final pass.

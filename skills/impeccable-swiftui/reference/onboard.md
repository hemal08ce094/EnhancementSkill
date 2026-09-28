> **Additional context needed**: the "aha moment" you want people to reach, and their experience level.

Get people to first value as fast as possible. Onboarding's job is not to teach the app. Its job is to get people to the moment that proves the app is worth their time, and on a phone that moment has to arrive before their attention runs out.

## Assess onboarding needs

1. **The challenge**: what are people trying to do, where do they stall or bail, and what is the aha moment?
2. **The people**: experience level, motivation (curious download vs required by work), time budget, what they switched from.
3. **Success**: the minimum to learn, the one key action (first entry, first sync, first share), and how you'll know it worked.

**CRITICAL**: Onboarding gets people to value, not to comprehension of everything.

## Principles

- **Show, don't tell.** The real UI with real or sample content beats a carousel of feature screenshots. Three swipeable marketing pages before the app is the default AI move; reject it unless the brief insists.
- **Optional.** Experienced people skip. Never block the product behind a tour.
- **Time to value.** Front-load the one concept that matters; leave the rest to contextual discovery.
- **Context over ceremony.** Teach a feature when someone reaches it: empty states and tips at the point of use.
- **Respect intelligence.** Standard iOS patterns (swipe to delete, pull to refresh, long-press menus) don't need explaining.

## First run

- **Land in the product.** Prefer the real root view with a pre-populated example or a clear empty state over a separate welcome flow. If a welcome screen is warranted, make it one screen: what this is, the one action to start, a visible way out.
- **Defer the account.** Let people use everything that doesn't need an account first (App Review 5.1.1 rejects forced sign-in for non-account features). Ask for sign-in when there is something to save or sync.
- **Collect the minimum.** Every field needs a reason the person can see. Use `textContentType` so AutoFill does the typing.
- **Show progress** when there are steps ("1 of 3"), and let Back work.
- **First success is real.** The first thing they make is kept, not a tutorial artifact.

Track completion so it never shows twice:

```swift
@AppStorage("onboarding.completedVersion") private var completedVersion = 0
```

Anything in `UserDefaults` can be overridden from the scheme's launch arguments (`-onboarding.completedVersion 0`), which gives you a free DEBUG reset for Simulator captures.

## Permissions: prime at the moment of need

Never request on launch. Ask right before the feature that needs it, after the person has chosen to use that feature, with one short in-context explanation of what they get. Then call the system prompt immediately.

```swift
Button("Turn On Reminders") {
    Task {
        let center = UNUserNotificationCenter.current()
        remindersOn = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }
}
```

- **Check status first** (`notificationSettings().authorizationStatus`, `CLLocationManager().authorizationStatus`, `AVCaptureDevice.authorizationStatus(for:)`). Never show a priming screen for a decision already made.
- **Denied is a state, not a dead end.** Explain what's unavailable and offer `openURL(URL(string: UIApplication.openSettingsURLString)!)`. Don't nag on every launch.
- **Purpose strings are copy.** `NSCameraUsageDescription` et al. say what you do with it in plain words: "Scan receipts to fill in the amount," not "This app needs camera access."
- **Don't mimic or bypass the system alert.** No fake "Allow" buttons. For App Tracking Transparency, a priming screen must always lead to the system prompt, never around it.
- **Ask for less**: When In Use before Always, provisional notifications (`.provisional`) when a quiet trial suits, limited photo access via `PhotosPicker` so no permission is needed at all.

## Empty states are onboarding

Every empty state says what will be here, why it matters, and how to start. Use `ContentUnavailableView` (iOS 17+) rather than a hand-rolled centered VStack:

```swift
ContentUnavailableView {
    Label("No Trips Yet", systemImage: "suitcase")
} description: {
    Text("Trips collect your bookings, notes and places in one timeline.")
} actions: {
    Button("Plan a Trip") { showNewTrip = true }
        .buttonStyle(.borderedProminent)
}
```

Types, each with its own tone:

- **First use**: emphasize value, offer a template or sample.
- **Cleared by the person**: light touch, easy to recreate.
- **No results**: `ContentUnavailableView.search(text: query)`, plus a way to clear filters.
- **No permission**: why, and the Settings path.
- **Error / offline**: what happened, a Retry button.

Use the product's own symbol or illustration, not a generic `tray` for everything.

## Contextual tips with TipKit

For feature discovery use TipKit (iOS 17+), not custom coach marks that dim the screen.

```swift
struct PinTip: Tip {
    var title: Text { Text("Pin a Trip") }
    var message: Text? { Text("Pinned trips stay at the top of the list.") }
    var image: Image? { Image(systemName: "pin") }
}

// App init
try? Tips.configure([.displayFrequency(.daily)])

// At the point of use
TipView(pinTip)                       // inline
Button("Pin", systemImage: "pin") { pin(); pinTip.invalidate(reason: .actionPerformed) }
    .popoverTip(pinTip)               // anchored
```

- Gate tips with rules (`@Parameter`, `Event` donations and `#Rule`) so they appear after the person has context, e.g. on the third visit, not the first.
- Invalidate when the person performs the action; one tip at a time; `displayFrequency` throttles the rest.
- In DEBUG, `Tips.resetDatastore()` / `Tips.showAllTipsForTesting()` behind a launch argument keep captures reproducible.

**What's New** after an update: one sheet, only when the change affects how people work, shown once per version, dismissible, with a "Try it" that goes straight to the feature.

## Sign in with Apple

If you offer any third-party login, App Review 4.8 requires an equivalent privacy-preserving option; Sign in with Apple is the default answer. Use the system button, not a recreation:

```swift
SignInWithAppleButton(.continue) { request in
    request.requestedScopes = [.fullName, .email]
} onCompletion: { result in handle(result) }
.signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
.frame(height: 50)
```

Name and email arrive only on the first authorization; store them then. If accounts can be created, they must be deletable in-app (5.1.1(v)).

## Paywall ethics

A paywall is part of onboarding when it appears there, and it inherits onboarding's rules.

- **Value before the ask.** Show the paywall after the aha moment or at a premium feature's point of use, not as the first screen.
- **Say the real terms.** Price, billing period, and what a trial becomes ("7 days free, then $29.99/year") at readable size, not in a `.caption2` footnote. Per-week math that hides an annual charge is a dark pattern.
- **A visible way out.** A close button the size and contrast of other controls, no delayed appearance, no guilt copy ("No, I don't want to be productive").
- **Restore Purchases** is always reachable.
- **No fake urgency**: no countdown timers that reset, no invented discounts.
- **Prefer StoreKit views** (`SubscriptionStoreView`, `ProductView`, iOS 17+) or match their clarity; they get localization, eligibility and terms right.

## NEVER

- Force a long flow before the product is usable
- Request permissions on launch, or before the person chose the feature
- Show the same tip or welcome twice (respect dismissals)
- Dim the whole screen for a tour or disable interaction during it
- Build a separate tutorial mode disconnected from the real app
- Hide Skip or Close, or make them hard to hit (`small-touch-target`)
- Show first-run onboarding to returning users after reinstall when iCloud state says they know the app

## Verify

Run it cold: delete the app in Simulator (`xcrun simctl uninstall`), install, launch, and time it to the aha moment. Then check: skip works, deny paths for each permission, Dynamic Type at AX sizes, VoiceOver reading order through the flow, Dark Mode, and relaunch doesn't repeat anything. Capture each step to `.impeccable/shots/`.

When people hit the aha moment fast and nothing repeats, hand off to `/impeccable-swiftui polish` for the final pass.

# Component review

Use this checkpoint on comp-led builds after the assets exist and before composing the screen. It is also worth running on any code-led build that creates a new world, where the kit is the first place the world becomes real. The approved comp is the reference. The user reviews the actual components, rendered by the real SwiftUI code on a real Simulator; a list of planned components, a description, or a mock of the kit is not a review of what will ship.

## Prepare the kit

Build a kit gallery: one DEBUG-only screen that renders every region-map row as the shipping implementation, labeled by region id. The same `ButtonStyle`, the same `Font` and `Color` tokens, the same asset names the screen will use; a kit that re-draws a component for the gallery is reviewing a copy.

```swift
#if DEBUG
struct KitGallery: View {
    var page: Int
    var body: some View { /* one section per region id, in region-map order */ }
}

#Preview("Kit · light") { KitGallery(page: 1) }
#Preview("Kit · dark") { KitGallery(page: 1).preferredColorScheme(.dark) }
#Preview("Kit · AX") { KitGallery(page: 1).dynamicTypeSize(.accessibility3) }
#endif
```

Route to it with the DEBUG launch argument new-work sets up (`-ImpeccableScreen kit -ImpeccableKitPage 2`), so the Simulator can open it directly. Previews are for fast iteration while you build the kit; Simulator captures are what the user reviews.

- **Every visible region gets a kit entry.** Raster plates shown on the ground they will sit on; text regions as the real `Text` in its real style with the comp's words; controls as real `Button`, `Toggle`, `Picker`, or custom controls with real actions stubbed. Report any region you could not render so the user can mark it missing; never silently omit one.
- **Show the states the screen needs**, statically: default, disabled, selected, loading, error, empty, the longest realistic string, the localization that runs longest. Pressed and focus states cannot be forced in a still; note them for the user to try in the Simulator, where the kit is live.
- **Repeated instances** of one component in one role share the region map's `group` and render together, every instance present. One group decision covers its unreviewed instances; the user can still flag an exception. Unique rasters each get their own entry.
- **Paginate to the screen.** A capture shows one screen, so split the kit into pages that each fit without scrolling at the AX text size. A page that clips a component at the bottom is a broken capture.
- **Fonts are the shipping fonts.** Bundled faces registered in `UIAppFonts` and loaded by the kit; a capture showing a fallback face is not a review of the component.

`ImageRenderer` can render a kit section to PNG in a test, but it does not render platform-backed views (lists, text fields, maps, pickers), so it is a supplement, never the capture of record.

## Capture

On the device class the comp was made for, capture every kit page in three variants, per new-work's capture recipe: light, dark (`xcrun simctl ui <UDID> appearance dark`), and a large accessibility size (`xcrun simctl ui <UDID> content_size accessibility-extra-extra-extra-large`, then relaunch). Files go to `.impeccable/shots/<surface>/kit-<page>-light.png`, `kit-<page>-dark.png`, `kit-<page>-ax.png`. Open each once and confirm it shows the page its name claims, fully settled, no alert over it.

Record the inventory in the surface brief:

```markdown
## Component review
| id | component | lives in | captures | decision | note |
|---|---|---|---|---|---|
| start | `InkCapsuleStyle` | Styles/ButtonStyles.swift | kit-1-* | pending | |
| hero-plate | `OnboardingPear` imageset | Assets.xcassets | kit-1-* | pending | |
```

## Present and wait

Open the captures beside the approved comp for the user (`open .impeccable/mocks/<surface>/comp-2.png .impeccable/shots/<surface>/kit-*.png`), display them inline too when the harness renders images to the user, and tell them the kit is live in the Simulator for pressed states and interaction. Ask with AskUserQuestion, batched by kit page or by group: approve, needs work (with what), or missing (a region the kit does not show). Then stop and wait.

Never approve on the user's behalf, and never replace their feedback with your own favorable verdict. When no one answers the first real round, the review is pending, not passed: stop, do not build past this checkpoint, and end the run reporting the component review as pending with the captures' paths, so the user can resume it.

On needs-work, change the actual implementation (the style, the token, the asset), keep region ids stable, recapture only the affected pages, and present again. Do not ask the user to reapprove unchanged components; carry forward approvals whose code and assets have not changed, and invalidate any approval whose component you touched. Continue only when the inventory is confirmed and every row reads `approved`.

## Assemble and review

Build the first screen from the approved components and run new-work's first-screen phase (region-map walk against the comp). Resolve component changes before presenting the assembled screen; the human review does not waive that check.

Then present the assembled first screen once: captured at the comp's device in light, dark, and AX, opened beside the comp, with the same question. Needs-work starts another assembly round. Acceptance closes both review stages for this build: never request component or assembly approval again. Finish the remaining states, adaptive layouts, the finish review, and documentation with the accepted first screen as the direction. This is first-screen calibration, not a claim that the user reviewed the rest of the flow. Edits to shared tokens do not reopen approval; a later explicit change from the user is a new task.

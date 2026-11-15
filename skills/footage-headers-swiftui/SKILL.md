---
name: footage-headers-swiftui
description: Replace drawn, generated or static header art in a native iOS, iPadOS, macOS or visionOS app with real camera footage that loops silently (the "living header"). It writes a shot list from what each screen is for, sources freely licensed real footage, reviews it frame by frame, cuts seamless loops with posters, builds a well-mannered SwiftUI player, and verifies every header on phone and tablet. Use when the user asks for realistic, video-based, "Lottie-style" or animated headers or banners, says a screen looks vibe-coded, drawn, fake, static or reused, wants real footage behind a settings page, profile, paywall or launch screen, or says "do the footage headers".
---

# Footage headers for native apps

A header drawn in code (dots for stars, a symbol for a plane, a gradient for a sky) reads as generated at a glance. A few seconds of real footage of the thing the screen is about does not. This skill replaces the first with the second.

First used on an AR plane-spotting app in November 2026: ten settings headers drawn in a SwiftUI `Canvas` (about 790 lines) became ten real clips, about 5 MB in total.

Read `references/sourcing.md` before searching, `references/cutting.md` before running ffmpeg, and `references/player-contract.md` before writing Swift.

## Rules

- **Real camera footage only.** Timelapse is fine. Nothing AI-generated, nothing rendered, nothing drawn. If a clip was published recently and looks too clean, check it is not synthetic before using it.
- **One clip per screen, never reused.** Not between screens, and not between apps: footage chosen for one app stays with that app.
- **The clip shows what the screen is about.** A calibration page gets stars turning around the pole, not a generic night sky.
- **Licences that allow a commercial app without share-alike,** confirmed on each clip's own page. Keep a sources file in the repo.
- **Silent and polite.** A header never makes sound, never interrupts the user's audio, never keeps the screen awake.
- **Write the player fresh in each app.** Follow the contract, do not copy a class from another app. Apple rejects apps that share template code (guideline 4.3).
- **Report what was rendered** and what was only checked offline.

## Procedure

1. **List the headers.** Every screen that has a banner, with its size on a phone and on the widest window (an iPad header can be a band six times wider than tall). Capture the current ones so there is a before picture.
2. **Write the shot list.** One row per screen: what the screen is for and the shot that shows it. State the constraints once: steady camera, subject in the middle third vertically, slow motion, no faces, no logos, no on-screen text, dark or light to match where the header sits, at least 1080p.
3. **Source two candidates per row** from the allowed sources (`references/sourcing.md`). Download at 1080p to 1440p, not multi-hundred-megabyte originals. Research and download can go to a cheaper model; the choice cannot.
4. **Review every candidate yourself.** Make a contact sheet of six frames per clip and look at it. Reject watermarks, livery or logos, text, people, handheld shake and anything that looks synthetic. Pick one per screen and note the best window.
5. **Cut the loops** with `scripts/cut-loop.sh` (see `references/cutting.md`): crop to the banner shape with the subject centred, 4.5 to 8 seconds, the seam crossfaded in the file, HEVC, no audio track, plus a poster frame. Aim for 0.1 to 1.5 MB per clip. Look at all the posters side by side before touching code.
6. **Build the player** to the contract in `references/player-contract.md`, then delete the drawn scenes and every helper only they used.
7. **Verify.** Every header on a phone, the main ones in the other appearance, every header on a tablet. Take two captures a second apart and confirm the header differs while the page does not (that proves playback). Check the title and bar buttons stay readable over each clip.
8. **Record it.** A line in the app's `DESIGN.md` (headers are real footage, one clip per screen, never drawn), and the sources file with page URL, author, licence and whether credit is required.

## Where it applies

Settings and profile headers, a paywall banner, a launch film, an empty state, an onboarding page. For a launch film or a paywall the same contract holds, with two changes: a launch film plays once and then dissolves, and anything that waits on it (a "what's new" sheet, a rating ask) must wait for it to finish.

It does not replace live data. If the screen can show the user's real Moon, real map or real flights, that beats stock footage of one.

## With the other skills

`design-genre-swiftui` decides whether the app has a material that should be on screen (an Atmosphere app usually does). This skill supplies it in motion. `impeccable-swiftui` is still the craft floor for everything around the header.

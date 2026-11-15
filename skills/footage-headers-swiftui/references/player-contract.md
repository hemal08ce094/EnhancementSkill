# The player contract

Write this fresh in each app, with the app's own names and structure. What follows is behaviour, with short sketches where the API is easy to get wrong.

## Behaviour

1. **Poster underneath, film on top.** The band is never empty while the first frame decodes.
2. **Silent and out of the way.** Muted. No `AVAudioSession` configuration at all, so the user's music keeps playing. No external playback, no keeping the display awake.

        player.isMuted = true
        player.allowsExternalPlayback = false
        player.preventsDisplaySleepDuringVideoPlayback = false
        player.audiovisualBackgroundPlaybackPolicy = .pauses

3. **Still when asked.** Under Reduce Motion or Low Power Mode show only the poster and create no player. Watch `NSProcessInfoPowerStateDidChange` so it reacts when the mode changes.
4. **Plays only when seen.** Pause when the header scrolls away, when the scene is not active and on disappear. Resume only while visible.
5. **One decoder at a time.** Create the player on appear and release it on disappear. A stack of ten settings pages must not hold ten players.
6. **One function decides.** Every trigger (appear, scene phase, scroll, motion setting, power state) calls the same `sync()` that either releases the player or plays or pauses it. Scattered `play()` calls drift apart.
7. **Hidden from VoiceOver, no hit testing.** It is decoration.
8. **Looping.** `AVQueuePlayer` with `AVPlayerLooper`. The seam is already in the file, so no code crossfade.

## Keeping the subject in frame

Plain aspect fill centres the clip, which loses the subject on one device or the other. Give each clip a focus point (fractions of the clip) and hold it as near the middle of the header as the clip's edges allow:

    // size: the header, aspect: the clip's width / height, focus: UnitPoint
    let scale = max(size.width / aspect, size.height)
    let w = scale * aspect, h = scale
    let x = min(0, max(size.width - w, size.width / 2 - focus.x * w))
    let y = min(0, max(size.height - h, size.height / 2 - focus.y * h))
    // draw the film at CGRect(x: x, y: y, width: w, height: h), clipped

Choose each focus from the poster, then check the widest window: a thin tablet band may show only a fifth of the clip's height. A subject taller than the band (a close Moon) cannot fit; move the focus so the title covers the less important part.

## Around the film

- Keep a scrim under the navigation bar and behind any title that floats on the clip. Tune it per clip only if a capture shows a problem.
- Set the fallback colour behind the poster to the clip's own top and bottom colours, so nothing flashes before the poster draws.
- A header that is night footage stays night in light mode. Pin its colour scheme locally and keep the bar items light until the page's own bar takes over.
- A launch film plays once: use `AVPlayer`, finish on `didPlayToEndTime`, let a tap skip it, dissolve out, and match the launch screen colour to the first frame so nothing flashes before it.

## Checks

- Two captures a second apart: the header differs, the page does not.
- Music from another app keeps playing when a header appears.
- Reduce Motion on: a poster, and no player in the memory graph.
- Push through several pages and back: one player alive at a time.
- The widest window: every subject visible, every title readable.

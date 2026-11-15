# Cutting loops

Needs `ffmpeg` with libx265.

## Review first

Six frames per candidate on one strip (substitute the clip's duration):

    ffmpeg -v error -y -i IN.mp4 -vf "fps=6/DURATION,scale=480:-1,tile=6x1" -frames:v 1 sheet.jpg

For the chosen clip, pull one frame with thirds marked, to place the crop:

    ffmpeg -v error -y -ss 4 -i IN.mp4 -frames:v 1 -vf "scale=720:-1,drawgrid=w=720:h=135:t=1:c=red@0.6" frame.png

## The cut

`scripts/cut-loop.sh <key> <input> <start> <seconds> "<crop and grade filter>" [outdir]`

    scripts/cut-loop.sh calibration raw/startrails.mp4 3 8 "crop=3840:1728:0:0,scale=1600:720:flags=lanczos"

It writes `Header-<key>.mp4` and `Header-<key>.jpg`.

- **Shape.** 1600x720 (20:9) suits a header that is about 16:9 on a phone and a thin band on a tablet. Crop the full source width and choose the vertical offset so the subject sits in the middle of the frame: the phone crops the sides, the tablet crops top and bottom.
- **Length.** 4.5 to 8 seconds. Shorter reads as a GIF, longer costs size for nothing.
- **Seam.** The script takes 0.6 s more than asked and crossfades the tail into the head, so a plain loop has no jump. It works for drifting scenes (clouds, stars, aurora). For a subject that travels (a plane approaching), a jump is unavoidable; pick a window where the subject leaves or the frame is calm at both ends.
- **Grade only to fit, never to fake.** Darkening a daylight clip to dusk so it sits in a night header is fine: `eq=brightness=-0.20:saturation=0.70:contrast=1.15:gamma=0.75`. Compositing, sky replacement or generated fill is not.
- **Encoding.** HEVC `hvc1`, crf 25, 30 fps, no audio track, faststart. Expect 0.1 MB (a Moon on black) to 1.3 MB (dense star trails).
- **Poster.** The middle frame, used before the first frame decodes and whenever motion is off. Check it is a frame worth holding.

## Before code

Tile every poster into one image and look at them together. Each should be recognisably a different place, and none should need its title to be understood.

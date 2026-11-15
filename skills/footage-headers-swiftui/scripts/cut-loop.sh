#!/bin/sh
# Cut one seamless header loop and its poster.
# usage: cut-loop.sh <key> <input> <start-seconds> <length-seconds> "<video filter>" [outdir]
set -e
key=$1; src=$2; ss=$3; d=$4; vf=$5; out=${6:-out}
fade=0.6
mkdir -p "$out"
# Take `fade` extra seconds, then dissolve the tail into the head so the last
# frame matches the first.
ffmpeg -v error -y -ss "$ss" -t "$(echo "$d+$fade" | bc)" -i "$src" -an -filter_complex \
"[0:v]$vf,fps=30,format=yuv420p,split[a][b];\
[a]trim=start=$fade,setpts=PTS-STARTPTS[A];\
[b]trim=end=$fade,setpts=PTS-STARTPTS[B];\
[A][B]xfade=transition=fade:duration=$fade:offset=$(echo "$d-$fade" | bc)[o]" \
  -map "[o]" -c:v libx265 -tag:v hvc1 -crf 25 -preset slow -movflags +faststart "$out/Header-$key.mp4"
ffmpeg -v error -y -ss "$(echo "$d/2" | bc -l)" -i "$out/Header-$key.mp4" -frames:v 1 -q:v 3 "$out/Header-$key.jpg"
echo "$out/Header-$key.mp4"

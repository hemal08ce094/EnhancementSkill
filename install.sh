#!/bin/sh
# Symlinks the enhancement skill and the five bundled kit skills into ~/.claude/skills.
# Existing skills with the same name are left alone unless you pass --force.
set -eu
cd "$(dirname "$0")"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
mkdir -p "$DEST"
for dir in skill/enhancement-skill skills/*/; do
  dir="${dir%/}"; name=$(basename "$dir")
  if [ -e "$DEST/$name" ] && [ "${1:-}" != "--force" ]; then
    echo "skip   $name (already installed; --force to replace)"; continue
  fi
  rm -rf "$DEST/$name"; ln -s "$PWD/$dir" "$DEST/$name"; echo "linked $name"
done

#!/bin/bash
# Manual user-scope installer for Codex completion-sound hook on Linux.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="$HOME/.codex/peon-ping"

mkdir -p "$DEST_DIR/scripts" "$DEST_DIR/packs/peon-minimal/sounds"

install -m 644 "$SRC_DIR/VERSION" "$DEST_DIR/VERSION"
install -m 755 "$SRC_DIR/scripts/codex-notify.py" "$DEST_DIR/scripts/codex-notify.py"

shopt -s nullglob
for f in "$SRC_DIR"/packs/peon-minimal/sounds/*.{ogg,wav}; do
  install -m 644 "$f" "$DEST_DIR/packs/peon-minimal/sounds/$(basename "$f")"
done

if ! command -v paplay >/dev/null 2>&1 && \
   ! command -v aplay >/dev/null 2>&1 && \
   ! command -v ffplay >/dev/null 2>&1 && \
   ! command -v play >/dev/null 2>&1; then
  echo "Warning: no supported player found (paplay/aplay/ffplay/play)." >&2
fi

echo "Installed to: $DEST_DIR"
echo "Set $HOME/.codex/config.toml notify to:"
printf 'notify = ["python3", "%s"]\n' "$DEST_DIR/scripts/codex-notify.py"

#!/bin/bash
# Codex notify hook for agent-turn-complete sound on Linux.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PEON_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOUNDS_DIR="$PEON_DIR/packs/peon-minimal/sounds"
NOTIFICATION_JSON="${1:-}"

if [ -z "$NOTIFICATION_JSON" ]; then
  exit 0
fi

if [ "${#NOTIFICATION_JSON}" -gt 65536 ]; then
  exit 0
fi

TYPE="$(python3 -c '
import json
import sys
try:
    payload = json.loads(sys.argv[1])
    if not isinstance(payload, dict):
        print("")
    else:
        value = payload.get("type", "")
        print(value if isinstance(value, str) else "")
except Exception:
    print("")
' "$NOTIFICATION_JSON" 2>/dev/null || true)"

if [ "$TYPE" != "agent-turn-complete" ]; then
  exit 0
fi

shopt -s nullglob
SOUND_CANDIDATES=( "$SOUNDS_DIR"/*.ogg "$SOUNDS_DIR"/*.wav )
if [ "${#SOUND_CANDIDATES[@]}" -eq 0 ]; then
  exit 0
fi

SOUND_FILE="$(printf '%s\n' "${SOUND_CANDIDATES[@]}" | shuf -n 1)"
EXT="${SOUND_FILE##*.}"
EXT_LOWER="$(printf '%s' "$EXT" | tr '[:upper:]' '[:lower:]')"

if command -v paplay >/dev/null 2>&1; then
  nohup paplay "$SOUND_FILE" >/dev/null 2>&1 &
  exit 0
fi

if command -v aplay >/dev/null 2>&1 && [ "$EXT_LOWER" = "wav" ]; then
  nohup aplay -q "$SOUND_FILE" >/dev/null 2>&1 &
  exit 0
fi

if command -v ffplay >/dev/null 2>&1; then
  nohup ffplay -nodisp -autoexit -loglevel quiet "$SOUND_FILE" >/dev/null 2>&1 &
  exit 0
fi

if command -v play >/dev/null 2>&1; then
  nohup play -q "$SOUND_FILE" >/dev/null 2>&1 &
  exit 0
fi

exit 0

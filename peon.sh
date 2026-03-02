#!/bin/bash
# Minimal peon runtime for Codex on Linux (Ubuntu/Debian).
set -euo pipefail

PEON_DIR="${CLAUDE_PEON_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
CONFIG="$PEON_DIR/config.json"
STATE="$PEON_DIR/.state.json"

if ! command -v paplay >/dev/null 2>&1; then
  echo "Error: paplay is required (install pulseaudio-utils)." >&2
  exit 1
fi

# This runtime is stdin-driven (Codex notify adapter). No interactive CLI.
if [ -t 0 ]; then
  echo "Usage: stdin JSON only (called by codex adapter)." >&2
  exit 0
fi

PAUSED=false
[ -f "$PEON_DIR/.paused" ] && PAUSED=true
INPUT=$(cat)

eval "$(PEON_CONFIG="$CONFIG" PEON_STATE="$STATE" PEON_DIR="$PEON_DIR" PEON_PAUSED="$PAUSED" python3 -c '
import json
import os
import random
import shlex
import sys

q = shlex.quote
config_path = os.environ["PEON_CONFIG"]
state_file = os.environ["PEON_STATE"]
peon_dir = os.environ["PEON_DIR"]
paused = os.environ["PEON_PAUSED"] == "true"

try:
    cfg = json.load(open(config_path))
except Exception:
    cfg = {}

if str(cfg.get("enabled", True)).lower() == "false":
    print("PEON_EXIT=true")
    sys.exit(0)

volume = float(cfg.get("volume", 0.5))
if volume < 0:
    volume = 0.0
if volume > 1:
    volume = 1.0
paplay_volume = int(volume * 65536)
active_pack = cfg.get("default_pack", "peon-minimal")
cats = cfg.get("categories", {})

def enabled(cat, default=True):
    return str(cats.get(cat, default)).lower() == "true"

try:
    event_data = json.loads(sys.stdin.read())
except Exception:
    print("PEON_EXIT=true")
    sys.exit(0)

event = event_data.get("hook_event_name", "")
if event == "Notification" and event_data.get("notification_type") == "permission_prompt":
    event = "PermissionRequest"

category = ""
if event == "SessionStart":
    category = "session.start"
elif event == "Stop":
    category = "task.complete"
elif event == "PermissionRequest":
    category = "input.required"
elif event == "PostToolUseFailure":
    category = "task.error"
else:
    print("PEON_EXIT=true")
    sys.exit(0)

if not enabled(category, True):
    print("PEON_EXIT=true")
    sys.exit(0)

if paused:
    print("PEON_EXIT=true")
    sys.exit(0)

try:
    state = json.load(open(state_file))
except Exception:
    state = {}

pack_dir = os.path.join(peon_dir, "packs", active_pack)
manifest = {}
for mname in ("openpeon.json", "manifest.json"):
    mpath = os.path.join(pack_dir, mname)
    if os.path.exists(mpath):
        manifest = json.load(open(mpath))
        break

sounds = manifest.get("categories", {}).get(category, {}).get("sounds", [])
if not sounds:
    print("PEON_EXIT=true")
    sys.exit(0)

last_played = state.get("last_played", {})
last_file = last_played.get(category, "")
candidates = sounds if len(sounds) <= 1 else [s for s in sounds if s.get("file") != last_file]
pick = random.choice(candidates)
file_ref = str(pick.get("file", ""))

if "/" in file_ref:
    candidate = os.path.realpath(os.path.join(pack_dir, file_ref))
else:
    candidate = os.path.realpath(os.path.join(pack_dir, "sounds", file_ref))

pack_root = os.path.realpath(pack_dir) + os.sep
if not candidate.startswith(pack_root):
    print("PEON_EXIT=true")
    sys.exit(0)

last_played[category] = file_ref
state["last_played"] = last_played
os.makedirs(os.path.dirname(state_file) or ".", exist_ok=True)
json.dump(state, open(state_file, "w"))

print("PEON_EXIT=false")
print("SOUND_FILE=" + q(candidate))
print("PAPLAY_VOLUME=" + q(str(paplay_volume)))
' <<< "$INPUT" 2>/dev/null)"

[ "${PEON_EXIT:-true}" = "true" ] && exit 0
[ -z "${SOUND_FILE:-}" ] && exit 0

# Stop any previous sound from this runtime.
if [ -f "$PEON_DIR/.sound.pid" ]; then
  old_pid=$(cat "$PEON_DIR/.sound.pid" 2>/dev/null || true)
  if [ -n "${old_pid:-}" ] && kill -0 "$old_pid" 2>/dev/null; then
    kill "$old_pid" 2>/dev/null || true
  fi
fi

nohup paplay --volume="$PAPLAY_VOLUME" "$SOUND_FILE" >/dev/null 2>&1 &
echo "$!" > "$PEON_DIR/.sound.pid"

exit 0

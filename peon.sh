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

PY_OUT="$(PEON_CONFIG="$CONFIG" PEON_STATE="$STATE" PEON_DIR="$PEON_DIR" PEON_PAUSED="$PAUSED" python3 -c '
import base64
import json
import os
import random
import re
import sys

MAX_EVENT_BYTES = 64 * 1024
MAX_JSON_FILE_BYTES = 1024 * 1024

config_path = os.environ["PEON_CONFIG"]
state_file = os.environ["PEON_STATE"]
peon_dir = os.environ["PEON_DIR"]
paused = os.environ["PEON_PAUSED"] == "true"

def exit_now():
    print("PEON_EXIT=true")
    raise SystemExit(0)

def load_json_file(path, default):
    try:
        with open(path, "rb") as handle:
            data = handle.read(MAX_JSON_FILE_BYTES + 1)
        if len(data) > MAX_JSON_FILE_BYTES:
            return default
        value = json.loads(data.decode("utf-8"))
        return value
    except Exception:
        return default

cfg = load_json_file(config_path, {})
if not isinstance(cfg, dict):
    cfg = {}

if str(cfg.get("enabled", True)).lower() == "false":
    exit_now()

try:
    volume = float(cfg.get("volume", 0.5))
except Exception:
    volume = 0.5
if volume < 0:
    volume = 0.0
if volume > 1:
    volume = 1.0
paplay_volume = int(volume * 65536)
active_pack = cfg.get("default_pack", "peon-minimal")
if not isinstance(active_pack, str):
    active_pack = "peon-minimal"
if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,63}", active_pack):
    active_pack = "peon-minimal"
cats = cfg.get("categories", {})
if not isinstance(cats, dict):
    cats = {}

def enabled(cat, default=True):
    return str(cats.get(cat, default)).lower() == "true"

try:
    raw_event = sys.stdin.buffer.read(MAX_EVENT_BYTES + 1)
    if len(raw_event) > MAX_EVENT_BYTES:
        exit_now()
    event_data = json.loads(raw_event.decode("utf-8"))
except Exception:
    exit_now()
if not isinstance(event_data, dict):
    exit_now()

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
    exit_now()

if not enabled(category, True):
    exit_now()

if paused:
    exit_now()

state = load_json_file(state_file, {})
if not isinstance(state, dict):
    state = {}

pack_dir = os.path.join(peon_dir, "packs", active_pack)
pack_dir = os.path.realpath(pack_dir)
packs_root = os.path.realpath(os.path.join(peon_dir, "packs")) + os.sep
if not pack_dir.startswith(packs_root):
    exit_now()
manifest = {}
for mname in ("openpeon.json", "manifest.json"):
    mpath = os.path.join(pack_dir, mname)
    if os.path.exists(mpath):
        manifest = load_json_file(mpath, {})
        break
if not isinstance(manifest, dict):
    manifest = {}

all_categories = manifest.get("categories", {})
if not isinstance(all_categories, dict):
    all_categories = {}
category_data = all_categories.get(category, {})
if not isinstance(category_data, dict):
    category_data = {}
raw_sounds = category_data.get("sounds", [])
if not isinstance(raw_sounds, list):
    raw_sounds = []
sounds = []
for sound in raw_sounds:
    if not isinstance(sound, dict):
        continue
    file_ref = sound.get("file")
    if not isinstance(file_ref, str):
        continue
    if not file_ref or "\x00" in file_ref or "\n" in file_ref or "\r" in file_ref:
        continue
    if file_ref.startswith("/"):
        continue
    sounds.append({"file": file_ref})

if not sounds:
    exit_now()

last_played = state.get("last_played", {})
if not isinstance(last_played, dict):
    last_played = {}
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
    exit_now()
if not os.path.isfile(candidate):
    exit_now()

last_played[category] = file_ref
state["last_played"] = last_played
os.makedirs(os.path.dirname(state_file) or ".", exist_ok=True)
with open(state_file, "w", encoding="utf-8") as handle:
    json.dump(state, handle)

print("PEON_EXIT=false")
print("SOUND_FILE_B64=" + base64.b64encode(candidate.encode("utf-8")).decode("ascii"))
print("PAPLAY_VOLUME=" + str(paplay_volume))
' <<< "$INPUT" 2>/dev/null)"

PEON_EXIT=true
SOUND_FILE_B64=""
PAPLAY_VOLUME=""
while IFS='=' read -r key value; do
  case "$key" in
    PEON_EXIT) PEON_EXIT="$value" ;;
    SOUND_FILE_B64) SOUND_FILE_B64="$value" ;;
    PAPLAY_VOLUME) PAPLAY_VOLUME="$value" ;;
  esac
done <<< "$PY_OUT"

[ "${PEON_EXIT:-true}" = "true" ] && exit 0
[ -z "${SOUND_FILE_B64:-}" ] && exit 0

if ! [[ "${PAPLAY_VOLUME:-}" =~ ^[0-9]+$ ]]; then
  exit 0
fi

SOUND_FILE="$(python3 -c 'import base64,sys
try:
    print(base64.b64decode(sys.argv[1]).decode("utf-8"))
except Exception:
    print("")
' "$SOUND_FILE_B64" 2>/dev/null || true)"

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

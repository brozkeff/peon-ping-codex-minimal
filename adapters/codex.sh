#!/bin/bash
# Minimal Codex adapter for Linux codex-minimal runtime.
set -euo pipefail

PEON_DIR="${CLAUDE_PEON_DIR:-$HOME/.codex/peon-ping}"
RUNTIME_SCRIPT="$(realpath "$PEON_DIR/peon.sh" 2>/dev/null || true)"
CODEX_EVENT="${1:-}"
RAW_STDIN=""

if [ -z "$RUNTIME_SCRIPT" ] || [ ! -f "$RUNTIME_SCRIPT" ] || [ ! -x "$RUNTIME_SCRIPT" ]; then
  exit 0
fi

if [ ! -t 0 ]; then
  RAW_STDIN="$(cat || true)"
fi

if [ -z "$CODEX_EVENT" ]; then
  CODEX_EVENT="${CODEX_NOTIFY_EVENT:-${CODEX_EVENT_NAME:-}}"
fi

if [ -z "$CODEX_EVENT" ] && [ -n "$RAW_STDIN" ]; then
CODEX_EVENT="$(python3 -c '
import json
import re
import sys

MAX_STDIN_BYTES = 64 * 1024
data = sys.stdin.buffer.read(MAX_STDIN_BYTES + 1)
if len(data) > MAX_STDIN_BYTES:
    print("")
    raise SystemExit(0)

try:
    data = data.decode("utf-8").strip()
except Exception:
    print("")
    raise SystemExit(0)

if not data:
    print("")
    raise SystemExit(0)

# Attempt JSON first (common for notify hooks), then fallback to raw text.
try:
    obj = json.loads(data)
except Exception:
    obj = None

if isinstance(obj, dict):
    fields = (
        "hook_event_name",
        "event",
        "event_name",
        "type",
        "name",
        "notification_type",
    )
    for key in fields:
        value = obj.get(key)
        if isinstance(value, str) and value:
            print(value)
            raise SystemExit(0)

match = re.search(r"(agent[-_ ]turn[-_ ]complete|session[-_ ]start|permission|approve|error|fail|complete|done|stop)", data, re.I)
print(match.group(1) if match else "")
' <<< "$RAW_STDIN" 2>/dev/null || true)"
fi

if [ -z "$CODEX_EVENT" ]; then
  CODEX_EVENT="agent-turn-complete"
fi

EVENT_KEY="$(echo "$CODEX_EVENT" | tr '[:upper:]' '[:lower:]' | tr '_' '-' )"

EVENT="Stop"
case "$EVENT_KEY" in
  *session-start*|*sessionstart*|start) EVENT="SessionStart" ;;
  *permission*|*approve*|*input-required*|*permission-prompt*) EVENT="PermissionRequest" ;;
  *error*|*fail*) EVENT="PostToolUseFailure" ;;
  *agent-turn-complete*|*turn-complete*|*complete*|*done*|*finish*|stop) EVENT="Stop" ;;
  *) EVENT="Stop" ;;
esac

SESSION_ID="codex-${CODEX_SESSION_ID:-$$}"
CWD="${PWD}"

_PE="$EVENT" _PC="$CWD" _PS="$SESSION_ID" python3 -c '
import json
import os
print(json.dumps({
    "hook_event_name": os.environ["_PE"],
    "cwd": os.environ["_PC"],
    "session_id": os.environ["_PS"],
}))
' | "$RUNTIME_SCRIPT"

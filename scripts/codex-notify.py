#!/usr/bin/env python3
"""Codex notify hook for agent-turn-complete sound playback on Linux."""

from __future__ import annotations

import json
import random
import subprocess
import sys
from pathlib import Path
from shutil import which

MAX_NOTIFICATION_BYTES = 65536
TARGET_EVENT_TYPE = "agent-turn-complete"


def parse_event_type(raw_payload: str) -> str:
    """Extract event type from notification payload JSON.

    Args:
        raw_payload: Raw JSON payload from the notify hook argument.

    Returns:
        Event type string if present and valid, otherwise an empty string.
    """
    if not raw_payload or len(raw_payload) > MAX_NOTIFICATION_BYTES:
        return ""

    try:
        payload = json.loads(raw_payload)
    except Exception:
        return ""

    if not isinstance(payload, dict):
        return ""

    event_type = payload.get("type", "")
    if not isinstance(event_type, str):
        return ""
    return event_type


def pick_sound_file(sounds_dir: Path) -> Path | None:
    """Pick one random bundled sound file.

    Args:
        sounds_dir: Directory with bundled sound files.

    Returns:
        Selected sound file path, or None if no playable file exists.
    """
    candidates = list(sounds_dir.glob("*.ogg")) + list(sounds_dir.glob("*.wav"))
    if not candidates:
        return None
    return random.choice(candidates)


def build_player_command(sound_file: Path) -> list[str] | None:
    """Build a player command for a selected sound file.

    Args:
        sound_file: Path to a bundled sound file.

    Returns:
        Command list for subprocess execution, or None if no player exists.
    """
    ext_lower = sound_file.suffix.lower()

    if which("paplay"):
        return ["paplay", str(sound_file)]
    if which("aplay") and ext_lower == ".wav":
        return ["aplay", "-q", str(sound_file)]
    if which("ffplay"):
        return ["ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet", str(sound_file)]
    if which("play"):
        return ["play", "-q", str(sound_file)]
    return None


def play_async(command: list[str]) -> None:
    """Play sound asynchronously and detach from caller session.

    Args:
        command: Full command and arguments for the audio player.
    """
    subprocess.Popen(  # noqa: S603
        command,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )


def main() -> int:
    """Run notify hook flow."""
    if len(sys.argv) < 2:
        return 0

    event_type = parse_event_type(sys.argv[1])
    if event_type != TARGET_EVENT_TYPE:
        return 0

    script_dir = Path(__file__).resolve().parent
    peon_dir = script_dir.parent
    sounds_dir = peon_dir / "packs" / "peon-minimal" / "sounds"

    sound_file = pick_sound_file(sounds_dir)
    if sound_file is None:
        return 0

    command = build_player_command(sound_file)
    if command is None:
        return 0

    play_async(command)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

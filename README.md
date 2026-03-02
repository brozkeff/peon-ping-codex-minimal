# peon-ping-codex-minimal

Minimal Codex notify sound hook for Linux.

Original upstream repository: <https://github.com/PeonPing/peon-ping>

This mini-repo keeps only what is needed to play a Warcraft III sound when Codex emits `agent-turn-complete`.

## Scope

- Codex `notify` hook only
- Linux-only target (Debian/Ubuntu)
- Supported event: `agent-turn-complete`
- Player fallback chain: `paplay` -> `aplay` (wav only) -> `ffplay` -> `play`

## Folder layout

```text
codex-minimal/
  VERSION
  scripts/
    codex-notify.sh
    install-user.sh
  packs/
    peon-minimal/
      sounds/
        PeonReady1.ogg
        PeonYes1.ogg
        PeonWhat1.ogg
```

## Requirements (Ubuntu 22.04 / Debian)

- `bash`
- `python3`
- One audio player:
  - `pulseaudio-utils` (`paplay`) recommended
  - or `alsa-utils` (`aplay`, wav only)
  - or `ffmpeg` (`ffplay`)
  - or `sox` (`play`)

Install recommended player:

```bash
sudo apt update
sudo apt install -y pulseaudio-utils
paplay --version
```

## User-scope install to `~/.codex`

From this folder:

```bash
bash scripts/install-user.sh
```

Then set Codex notify hook in `~/.codex/config.toml`:

```toml
notify = ["bash", "~/.codex/peon-ping/scripts/codex-notify.sh"]
```

## Notes

- Codex passes notification JSON as a single argument to the script.
- The script ignores all events except `agent-turn-complete`.

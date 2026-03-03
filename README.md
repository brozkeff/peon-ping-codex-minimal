# peon-ping-codex-minimal

Minimal Warcraft III sound notifications for Codex on Linux.

Original upstream repository: <https://github.com/PeonPing/peon-ping>

Project change history: [CHANGELOG.md](CHANGELOG.md)

This repo contains one supported integration path:

- `scripts/codex-notify.py`: simple notify hook for `agent-turn-complete`

## Scope

- Linux target (Debian/Ubuntu)
- Codex notification integration
- Minimal bundled pack: `packs/peon-minimal`
- Default event coverage: `agent-turn-complete`

## Folder layout

```text
peon-ping-codex-minimal/
  VERSION
  LICENSE
  README.md
  CHANGELOG.md
  PLANS.md
  scripts/
    codex-notify.py
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
- Audio player(s):
  - Supported by `scripts/codex-notify.py`:
    - `paplay` (recommended)
    - or `aplay` (`wav` only)
    - or `ffplay`
    - or `play`

Install recommended player:

```bash
sudo apt update
sudo apt install -y pulseaudio-utils
paplay --version
```

## Install to `~/.codex`

From this repository:

```bash
bash scripts/install-user.sh
```

This installs:

- `~/.codex/peon-ping/VERSION`
- `~/.codex/peon-ping/scripts/codex-notify.py`
- `~/.codex/peon-ping/packs/peon-minimal/sounds/*`

## Codex hook setup

Set notify hook in `~/.codex/config.toml`:

```toml
notify = ["python3", "$HOME/.codex/peon-ping/scripts/codex-notify.py"]
```

This uses the simple hook path and plays a random bundled sound only when notification `type` is `agent-turn-complete`.

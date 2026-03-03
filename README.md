# peon-ping-codex-minimal

Minimal Codex sound notifications for Linux using a single Python notify hook.

Project change history: [CHANGELOG.md](CHANGELOG.md)

## What this project is

This project intentionally keeps only the bare minimum needed for default Codex
notify integration:

- `scripts/codex-notify.py`
- `scripts/install-user.sh`
- `packs/peon-minimal/sounds/*`

The hook plays a random bundled sound only when notification `type` is
`agent-turn-complete`.

## Requirements (Ubuntu/Debian)

Required:

- `python3`

Audio player: install at least one of these tools:

- `paplay` (recommended, package: `pulseaudio-utils`)
- `aplay` (WAV only, package: `alsa-utils`)
- `ffplay` (package: `ffmpeg`)
- `play` (package: `sox`)

Recommended setup command:

```bash
sudo apt update
sudo apt install -y python3 pulseaudio-utils
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

## Security posture

For the current minimal scope, the code is basically safe:

- no shell `eval` paths
- bounded and validated JSON payload handling
- no dynamic code loading
- only local bundled sound file selection

Main remaining trust assumption: the local user environment and files under
`~/.codex/peon-ping` are not maliciously modified.

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

## Attribution

This fork reuses only a few sound samples from the original project and replaces
its prior logic with the minimal Python notify flow documented above.

Original upstream repository: <https://github.com/PeonPing/peon-ping>

Note: Original repository is bloated and may have bigger potential attack surface.

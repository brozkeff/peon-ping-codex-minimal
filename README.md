# peon-ping-codex-minimal

Minimal Warcraft III sound notifications for Codex on Linux.

Original upstream repository: <https://github.com/PeonPing/peon-ping>

Project change history: [CHANGELOG.md](CHANGELOG.md)

This repo contains a minimal sound pack plus two integration paths:

- `scripts/codex-notify.sh`: simple notify hook for `agent-turn-complete`
- `adapters/codex.sh` + `peon.sh`: adapter/runtime flow with category mapping and `config.json`

## Scope

- Linux target (Debian/Ubuntu)
- Codex notification integration
- Minimal bundled pack: `packs/peon-minimal`
- Core event coverage in runtime path:
  - `SessionStart` -> `session.start`
  - `Stop` -> `task.complete`
  - `PermissionRequest` -> `input.required`
  - `PostToolUseFailure` -> `task.error`

## Folder layout

```text
peon-ping-codex-minimal/
  VERSION
  LICENSE
  README.md
  config.json
  peon.sh
  adapters/
    codex.sh
  scripts/
    codex-notify.sh
    install-user.sh
  packs/
    peon-minimal/
      openpeon.json
      sounds/
        PeonReady1.ogg
        PeonYes1.ogg
        PeonWhat1.ogg
```

## Requirements (Ubuntu 22.04 / Debian)

- `bash`
- `python3`
- Audio player(s):
  - Required by runtime (`peon.sh`): `paplay` from `pulseaudio-utils`
  - Supported by simple hook (`scripts/codex-notify.sh`):
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
- `~/.codex/peon-ping/scripts/codex-notify.sh`
- `~/.codex/peon-ping/packs/peon-minimal/sounds/*`

## Codex hook setup

Set notify hook in `~/.codex/config.toml`:

```toml
notify = ["bash", "~/.codex/peon-ping/scripts/codex-notify.sh"]
```

This uses the simple hook path and plays a random bundled sound only when notification `type` is `agent-turn-complete`.

## Runtime/adapter path (optional)

For richer event mapping and category control, use `adapters/codex.sh` with `peon.sh` and `config.json`.

- `adapters/codex.sh` normalizes Codex event names and passes runtime JSON to `peon.sh`
- `peon.sh` reads `config.json`, selects category sounds from `openpeon.json`, and stores last-played state in `.state.json`

Note: current installer script does not install `peon.sh`, `adapters/codex.sh`, or `config.json` into `~/.codex/peon-ping`; copy those manually if you choose this path.

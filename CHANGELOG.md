<!-- markdownlint-configure-file {"MD024": false} -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.12.0~20260303T173312Z] - 2026-03-03

### Changed

- Updated `scripts/install-user.sh` to print an absolute notify hook path in generated `config.toml` snippet.
- Removed explicit version text from `README.md`; version is now tracked in `VERSION` and `CHANGELOG.md` only.

## [2.12.0~20260303T171821Z] - 2026-03-03

### Added

- Added `PLANS.md` with a security findings register and remediation checklist.
- Added this changelog and linked it from `README.md`.

### Changed

- Updated `peon.sh` runtime flow to parse structured key/value output from Python instead of using shell `eval`.
- Updated `peon.sh` stdin flow to stream directly into Python parser instead of buffering full stdin in a shell variable.

### Fixed

- Resolved `Critical` code-injection risk in `peon.sh` by removing shell `eval`
  from the Python-to-shell handoff and replacing it with explicit key parsing.
- Resolved `High` pack path-traversal risk in `peon.sh`:
  - Added strict allowlist validation for `default_pack`.
  - Enforced `packs/` root confinement with canonical path checks.
- Resolved `High` manifest trust risk in `peon.sh`:
  - Added defensive JSON loading with size limits.
  - Validated manifest/category/sound structure before sound selection.
  - Rejected unsafe filename values (empty, absolute, control chars).
- Resolved `Medium` runtime invocation risk in `adapters/codex.sh`:
  - Resolve and validate runtime script path and executability before running.
  - Require string event fields during JSON extraction.
  - Execute resolved runtime script directly.
- Resolved `Medium` JSON handling risk in `scripts/codex-notify.sh`:
  - Reject oversized JSON argument payloads.
  - Require object payload and string `type` value.
- Resolved `Medium` shell-buffering DoS risk in `adapters/codex.sh` by replacing unbounded stdin read with bounded `head -c` and oversize-drop behavior.

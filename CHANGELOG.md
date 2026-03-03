<!-- markdownlint-configure-file {"MD024": false} -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added `PLANS.md` with a security findings register and remediation checklist.
- Added this changelog and linked it from `README.md`.

### Changed

- Updated `peon.sh` runtime flow to parse structured key/value output from Python instead of using shell `eval`.

### Fixed

- Hardened `peon.sh` runtime input handling:
  - Bounded stdin payload size and JSON file size reads.
  - Enforced `default_pack` allowlist format to block traversal-style values.
  - Enforced manifest structure checks for categories/sounds.
  - Rejected unsafe/invalid sound file references and non-files.
  - Preserved path confinement to pack root and validated output volume type.
- Hardened `adapters/codex.sh`:
  - Validate runtime path exists and is executable before invocation.
  - Bound stdin parsing size and require string-valued event fields.
  - Execute resolved runtime script directly instead of invoking by unconstrained path.
- Hardened `scripts/codex-notify.sh`:
  - Reject oversized notification JSON argument values.
  - Require JSON object payload and string `type` field.

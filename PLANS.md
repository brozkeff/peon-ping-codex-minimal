# Security Review Plan

## Findings

- [x] `Critical` [`peon.sh`](./peon.sh):24 used `eval` on dynamically generated output. Fixed by replacing with structured key/value parsing and explicit assignments.
- [x] `High` [`peon.sh`](./peon.sh):52 and [`peon.sh`](./peon.sh):94 trusted `default_pack` from `config.json` without strict validation. Fixed by allowlist validation and pack-root confinement checks.
- [x] `High` [`peon.sh`](./peon.sh):96-112 trusted manifest shape and sound entries without schema checks. Fixed by strict type/shape checks and filename safety filtering.
- [x] `Medium` [`adapters/codex.sh`](./adapters/codex.sh):80 executed runtime script from env-derived `PEON_DIR` without verifying expected target exists/executable. Fixed by resolving and validating runtime script before execution.
- [x] `Medium` [`scripts/codex-notify.sh`](./scripts/codex-notify.sh):14-22 parsed unbounded JSON argument and accepted any object shape. Fixed with payload-size cap and object/string field checks.
- [x] `Medium` Missing [`CHANGELOG.md`](./CHANGELOG.md) and no explicit security-fix history. Fixed by adding Keep a Changelog file and README link.

## Fix Plan

- [x] 1. Replace `eval` in `peon.sh` with structured parsing and explicit variable assignment.
- [x] 2. Add strict validation for `default_pack`, manifest schema, filename safety, and input size/type checks in `peon.sh`.
- [x] 3. Harden adapter/runtime invocation checks in `adapters/codex.sh`.
- [x] 4. Harden `scripts/codex-notify.sh` JSON input handling (size/type validation).
- [x] 5. Create `CHANGELOG.md` in Keep a Changelog format and log each completed fix.
- [x] 6. Update README to link `CHANGELOG.md`.
- [x] 7. Mark each completed step in this file.

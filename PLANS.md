# Security Review Plan

## Findings

- [ ] `Critical` [`peon.sh`](./peon.sh):24 uses `eval` on dynamically generated output. Even with quoting, this is an unsafe execution primitive and should be removed.
- [ ] `High` [`peon.sh`](./peon.sh):52 and [`peon.sh`](./peon.sh):94 trust `default_pack` from `config.json` without strict validation. Path traversal in pack name can load manifests/sounds from unexpected filesystem locations.
- [ ] `High` [`peon.sh`](./peon.sh):96-112 trusts manifest shape and sound entries without schema checks. Malformed JSON can crash selection flow or produce unsafe filenames.
- [ ] `Medium` [`adapters/codex.sh`](./adapters/codex.sh):80 executes runtime script from env-derived `PEON_DIR` without verifying expected target exists/executable.
- [ ] `Medium` [`scripts/codex-notify.sh`](./scripts/codex-notify.sh):14-22 parses unbounded JSON argument and accepts any object shape, which can be abused for memory pressure and unreliable behavior.
- [ ] `Medium` Missing [`CHANGELOG.md`](./CHANGELOG.md) and no explicit security-fix history.

## Fix Plan

- [ ] 1. Replace `eval` in `peon.sh` with structured parsing and explicit variable assignment.
- [ ] 2. Add strict validation for `default_pack`, manifest schema, filename safety, and input size/type checks in `peon.sh`.
- [ ] 3. Harden adapter/runtime invocation checks in `adapters/codex.sh`.
- [ ] 4. Harden `scripts/codex-notify.sh` JSON input handling (size/type validation).
- [ ] 5. Create `CHANGELOG.md` in Keep a Changelog format and log each completed fix.
- [ ] 6. Update README to link `CHANGELOG.md`.
- [ ] 7. Mark each completed step in this file.

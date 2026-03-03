# Security Review Plan

## Completed (Iteration 1)

- `Critical` [`peon.sh`](./peon.sh): removed dynamic shell `eval` execution path and replaced with structured output parsing.
- `High` [`peon.sh`](./peon.sh): validated `default_pack` with allowlist format and enforced pack-root confinement.
- `High` [`peon.sh`](./peon.sh): added manifest and sound-entry type/shape validation.
- `Medium` [`adapters/codex.sh`](./adapters/codex.sh): added runtime script resolution and executable checks before launch.
- `Medium` [`scripts/codex-notify.sh`](./scripts/codex-notify.sh): added JSON payload size cap and object/string field validation.
- `Medium` project docs: added `CHANGELOG.md` and linked from `README.md`.

## New Audit Queue (Iteration 2)

- [ ] `Medium` [`peon.sh`](./peon.sh):22 reads unbounded stdin into a shell variable before parser-level limits are applied.
- [ ] `Medium` [`adapters/codex.sh`](./adapters/codex.sh):15 reads unbounded stdin into `RAW_STDIN` before parser-level limits are applied.

## Iteration 2 Plan

- [ ] 1. Bound shell-level stdin reads in runtime and adapter scripts.
- [ ] 2. Re-run shell syntax checks and targeted grep-based audit.
- [ ] 3. Capture new audit result summary in this file and `CHANGELOG.md`.

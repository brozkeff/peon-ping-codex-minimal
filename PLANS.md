# Security Review Plan

## Completed (Iteration 1)

- `Critical` [`peon.sh`](./peon.sh): removed dynamic shell `eval` execution path and replaced with structured output parsing.
- `High` [`peon.sh`](./peon.sh): validated `default_pack` with allowlist format and enforced pack-root confinement.
- `High` [`peon.sh`](./peon.sh): added manifest and sound-entry type/shape validation.
- `Medium` [`adapters/codex.sh`](./adapters/codex.sh): added runtime script resolution and executable checks before launch.
- `Medium` [`scripts/codex-notify.sh`](./scripts/codex-notify.sh): added JSON payload size cap and object/string field validation.
- `Medium` project docs: added `CHANGELOG.md` and linked from `README.md`.

## New Audit Queue (Iteration 2)

- [x] `Medium` [`peon.sh`](./peon.sh): removed unbounded shell stdin buffering; Python parser now reads stdin directly with hard byte cap.
- [x] `Medium` [`adapters/codex.sh`](./adapters/codex.sh): replaced unbounded `cat` with bounded `head -c` input read and oversize drop behavior.

## Iteration 2 Plan

- [x] 1. Bound shell-level stdin reads in runtime and adapter scripts.
- [x] 2. Re-run shell syntax checks and targeted grep-based audit.
- [x] 3. Capture new audit result summary in this file and `CHANGELOG.md`.

## Iteration 2 Audit Summary

- DebateCouncil (with `SecurityArchitect`) consensus: highest-priority residual issue was shell-level unbounded stdin reads before parser limits; fixed in this iteration.
- Verified no reintroduction of `eval`/`exec` execution sinks in runtime scripts after fixes.
- Remaining hardening backlog (non-blocking for this iteration):
  - add startup ownership/permission checks for runtime/config files under `~/.codex/peon-ping`
  - add minimal structured security logging for rejected events and runtime abort reasons

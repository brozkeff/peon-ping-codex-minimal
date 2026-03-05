<!-- markdownlint-configure-file {"MD024": false} -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Versioning scheme: `YYYY-MM-DD[a-z]` (for example `2026-03-03a`,
`2026-03-03b`).

## [2026-03-05a] - 2026-03-05

### Changed

- Updated Python notifier event filtering to avoid repeated sounds in
  multi-agent/council runs.
- Completion sounds now play only for top-level `task_complete` and
  `agent-turn-complete` events.
- Added schema-tolerant subagent detection using optional keys
  (`is_subagent`, `subagent`, `parent_agent_id`, `delegated_from_agent_id`,
  `agent_depth`).
- Added alert classification for approval/escalation-related notify events.
- Added temporary JSONL payload logging for local event schema verification.

## [2026-03-03a] - 2026-03-03

### Changed

- Replaced the shell notify hook with a minimal Python hook:
  `scripts/codex-notify.py`.
- Simplified the repository to a single supported default notify flow.
- Rewrote README to describe the minimal architecture and explicit runtime
  requirements.

### Removed

- Removed optional runtime/adapter stack and related config/manifests.
- Removed shell notifier `scripts/codex-notify.sh`.

### Security

- Removed historical high-risk shell complexity and kept only minimal, bounded
  JSON handling and deterministic local sound playback flow.

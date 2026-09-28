# Agent Plugins Release Notes

## v1.3.0 (2026-09-27)

### Multi-vendor distribution

- Skills are discoverable and explicitly invocable from Codex CLI and Google Antigravity, alongside the existing Claude Code marketplace. No auto-trigger bootstrapping — skills are invoked by name in every vendor, the same as Claude Code today.
- `skill/` was renamed to `skills/` to match the open Agent Skills standard (https://agentskills.io) that Codex and Antigravity both implement.
- Codex CLI and Antigravity both discover skills through `.agents/skills/<name>`, a symlink tree pointing at the same `skills/<name>` directories Claude Code's marketplace uses — verified against live instances of both. Neither vendor needed a separate plugin manifest.
- No unified version-lockstep mechanism was added: with no per-vendor manifest carrying its own version field, `.claude-plugin/marketplace.json`'s `metadata.version` remains the repo's only version, so there is nothing to keep in sync.

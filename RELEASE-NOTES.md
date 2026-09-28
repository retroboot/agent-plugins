# Agent Plugins Release Notes

## v1.3.2 (2026-09-28)

### Verification fix and a ship-workflow retrospective

- **Check 12 (`review-pr` read-only / `allowed-tools`) now parses the actual YAML value instead of assuming block-sequence line shape.** The old grep patterns only matched one entry per line and missed the equally valid inline flow form (`allowed-tools: Read, Bash`) entirely — an inline declaration granting bare `Bash` or `Bash(git:*)` would have passed verification silently. The fix extracts the value (inline remainder or indented continuation lines, split on commas) so both YAML forms reduce to the same token stream before the existing patterns test it.
- `ship-issue`'s Phase 3 (grouping) and Phase 4 (ordering) now state an explicit single-issue early-out, matching `work-issue`'s Phase 2, instead of silently reducing to a no-op with no line saying so.
- New "Skill Composition" section in `core`: "load the X skill" means invoke it fresh, even when this session already ran X and its contract is fully remembered. This applies with equal force to a skill loaded through composition (`ship-pr` loading `review-pr`/`merge-pr`, `ship-issue` loading `work-issue`/`ship-pr`), not only one loaded directly by the user.
- `docs/verification.md`'s mechanics notes now lead with: test a detection-logic change against synthetic input before editing the real target.

## v1.3.1 (2026-09-28)

### Documentation cleanup and a config-tracking reversal

- The Verification section moved out of `README.md` into a dedicated `docs/verification.md` — `README.md` now carries a two-line pointer instead of the full 13-check fence and its reference material.
- `README.md`'s per-check documentation was condensed from a ~410-line narrative (issue-number history, per-check "how to re-run it" walkthroughs) into a compact 13-row reference table.
- Removed four historical, fully-shipped plan documents from tracked `docs/plans/`; the one still-unimplemented plan was preserved by moving it to the gitignored `.ai/plans/` instead of deleting it. New plans are now written to `.ai/plans/prd-{NNN}.md`, not `docs/plans/`.
- **`.hivrr.json` is now gitignored, not committed.** It was committed by an earlier decision; that's reversed here. `init` Phase 6 now keeps it out of git (adding the `.gitignore` line and untracking it if it was ever committed) instead of staging and committing it. Every teammate, agent, and CI run is expected to derive its own copy by running `init`, the same way each already has its own `~/.claude/settings.json`. This is a behavior change for every repo using this plugin, not just this one.
- Retired the `dispatcher` plugin (`score-issues`, `group-issues`, `diagnose-failure`) — built for another project's work-allocation workflow and no longer needed. `init` and `session` are untouched, since `dev` and `planner` still ship them.

## v1.3.0 (2026-09-27)

### Multi-vendor distribution

- Skills are discoverable and explicitly invocable from Codex CLI and Google Antigravity, alongside the existing Claude Code marketplace. No auto-trigger bootstrapping — skills are invoked by name in every vendor, the same as Claude Code today.
- `skill/` was renamed to `skills/` to match the open Agent Skills standard (https://agentskills.io) that Codex and Antigravity both implement.
- Codex CLI and Antigravity both discover skills through `.agents/skills/<name>`, a symlink tree pointing at the same `skills/<name>` directories Claude Code's marketplace uses — verified against live instances of both. Neither vendor needed a separate plugin manifest.
- No unified version-lockstep mechanism was added: with no per-vendor manifest carrying its own version field, `.claude-plugin/marketplace.json`'s `metadata.version` remains the repo's only version, so there is nothing to keep in sync.

---
name: session
description: Load provider context for the current session — reads config, probes MCP availability, and loads the active provider reference. Requires init to have run first.
license: MIT
compatibility: opencode
---

# Session

Load provider context for the current workflow. Reads the validated config written by `init`, probes MCP tool availability, and loads the active provider reference into context.

---

## Phase 1 — Read Config

Read `~/.claude/settings.json` using the Read tool. Extract `providerConfig`:

- `repoProvider` — `github` | `gitlab`
- `issueTracker` — `github` | `gitlab` | `linear`

Optional fields: `repoTarget`, `gitlabGroup`, `githubOrg`, `linearTeam`.

Store: `REPO_PROVIDER`, `ISSUE_TRACKER`, `REPO_TARGET`, provider slugs.

---

## Phase 2 — Probe MCP

Silently attempt each relevant probe. Record `true`/`false` — do not stop on failure.

1. **hub_mcp**: attempt `mcp__nexus__hub__list_repos`
   - If available → set `hub_mcp=true`, `repo_mcp=false`, `issues_mcp=false`, and skip probes 2 and 3
   - Note: a failed probe may mean hub is down OR hub is running but its provider credentials are misconfigured

2. **repo_mcp** (only when `hub_mcp=false`): attempt `mcp__github__get_me` if `REPO_PROVIDER=github`; attempt `mcp__gitlab__get_me` if `REPO_PROVIDER=gitlab`

3. **issues_mcp** (only when `hub_mcp=false`): same as `repo_mcp` when `ISSUE_TRACKER=REPO_PROVIDER`; attempt any `mcp__linear__*` tool if `ISSUE_TRACKER=linear`

If a probe tool is not available in this session or returns an auth/capability error → flag = `false`.

---

## Phase 3 — Load Reference

If `hub_mcp=true`:
```
Read $CLAUDE_SKILL_DIR/references/hub.md
Read $CLAUDE_SKILL_DIR/references/{REPO_PROVIDER}.md
```
hub.md provides MCP tool calls; the provider reference provides CLI syntax for operations hub does not cover (diff, CI checks, comment reads). Both are active — for any given operation, use hub.md's MCP form when available, and the provider reference's CLI form otherwise.

If `hub_mcp=false`:
```
Read $CLAUDE_SKILL_DIR/references/{REPO_PROVIDER}.md
```
If `ISSUE_TRACKER != REPO_PROVIDER`:
```
Also read $CLAUDE_SKILL_DIR/references/{ISSUE_TRACKER}.md
```

The loaded reference(s) are now active for this session. All provider-specific commands in subsequent phases must come from the reference — use MCP tools when the corresponding flag is `true`, CLI when `false`.

Emit:
```
SESSION: provider={REPO_PROVIDER} tracker={ISSUE_TRACKER} hub_mcp={true|false} repo_mcp={true|false} issues_mcp={true|false}
```

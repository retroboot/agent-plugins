# hivrr-agent-plugin

Claude Code skills and slash commands for the hivrr workflow. Distributed as a Claude plugin and loaded into agent sessions to give them first-class access to hivrr's automation capabilities.

## Overview

The agent plugin ships two artifact types:

- **Skills** — reusable prompts loaded by name (e.g., `work-issue`, `review-pr`). Used by Claude to execute well-defined tasks with consistent behavior.
- **Commands** — slash commands exposed in the Claude Code UI (e.g., `/work-issue 123`, `/audit security`).

The plugin is split into five focused packages:

| Plugin | Purpose |
|--------|---------|
| `dev` | Implementation and code review — issues, PRs, waves, merges, and promotions |
| `auditor` | Code audit skills — security, accessibility, performance, and tech debt |
| `planner` | Planning and brainstorming — thinking sessions through to sized issues and plan documents |
| `dispatcher` | Manager utilities for automated work allocation — scoring, grouping, and failure diagnosis |
| `data-platform` | Full data platform skills — the complete stack from ingestion and pipelines to ML, LLMs, dashboards, and database administration |

`init` and `session` are shared setup skills included by `dev`, `planner`, and `dispatcher`. Every command loads them before its main skill.

## Skills

### `dev`

| Skill | Description |
|-------|-------------|
| `init` | One-time setup — provider config, repo labels, `.hivrr.json` scaffold, verify commands, project board IDs |
| `session` | Loads config and the active provider reference for the session |
| `core` | Coding philosophy — quality gates, git safety, script policy, and task completion standards |
| `work-issue` | Implement an issue end-to-end and open a PR |
| `work-pr` | Address PR review feedback end-to-end |
| `review-pr` | Review a PR and post a structured comment |
| `merge-pr` | Merge a PR, close linked issues, clean up branches |
| `promote` | Promote one ladder rung to the next — `dev → staging → main` |
| `wave` | Execute multiple related issues in order on a shared branch |
| `debug` | Diagnose a bug without making changes |

### `auditor`

| Skill | Description |
|-------|-------------|
| `audit` | Scan codebase for all issue types (dispatches to the sub-skills below) |
| `audit-security` | Scan codebase for security vulnerabilities |
| `audit-accessibility` | Scan codebase for accessibility issues |
| `audit-performance` | Scan codebase for performance issues |
| `audit-tech-debt` | Scan codebase for tech debt |

### `planner`

| Skill | Description |
|-------|-------------|
| `init` | Shared setup skill — see `dev` |
| `session` | Shared setup skill — see `dev` |
| `brainstorm` | Collaborative thinking session on a technical problem |
| `planning` | Triage a feature into sized issues, and place them on the project board |

### `dispatcher`

| Skill | Description |
|-------|-------------|
| `init` | Shared setup skill — see `dev` |
| `session` | Shared setup skill — see `dev` |
| `score-issues` | Score issues by urgency on a documented 0–99 rubric |
| `group-issues` | Group issues into implementation waves by dependency and file overlap |
| `diagnose-failure` | Diagnose a failed worker job and recommend `RETRY` / `SKIP` / `HUMAN_REVIEW` |

### `data-platform`

| Skill | Description |
|-------|-------------|
| `senior-data-scientist` | Senior data scientist persona for analysis and modelling advice |
| `senior-data-engineer` | Senior data engineer persona for pipeline and infrastructure advice |
| `senior-data-analyst` | Senior data analyst persona for reporting and SQL advice |
| `senior-ai-engineer` | Senior AI engineer persona for code review and advice |
| `snowflake` | Snowflake administration and query skills |
| `postgres` | PostgreSQL administration skills |
| `postgres-query` | Safe PostgreSQL query execution and analysis |

## Commands

Commands are thin wrappers that load a skill and pass `$ARGUMENTS`.

```
/work-issue 123
/work-pr 456
/review-pr 789
/merge-pr 99 --auto
/promote dev
/wave 123,456,789
/write-plan "add SSE to insight"
/audit security --mode deep
/debug 456
/brainstorm "how should we handle retries?"
/planning "add SSE to insight"
/group-issues --repo hivrr/manager --issues 123,456
/score-issues --repo hivrr/manager --issues 123,456
/diagnose-failure --job-id abc123 --task-type work-issue
```

## Configuration — `.hivrr.json`

Per-repo settings live in a committed `.hivrr.json` at the repository root, so they travel with the code and every teammate, agent, and CI runner resolves the same values. **The file is entirely optional** — a repo without one gets documented defaults, not errors.

```json
{
  "provider": "github",
  "branches": {
    "integration": "dev",
    "ladder": ["dev", "staging", "main"],
    "protected": ["dev", "staging", "main", "release/*"]
  },
  "project": {
    "owner": "hivrr",
    "number": 1,
    "id": "PVT_xxx",
    "statusFieldId": "PVTSSF_xxx",
    "status": { "todo": "...", "inProgress": "...", "done": "..." }
  },
  "verify": {
    "test": "npm test",
    "lint": "npx eslint .",
    "detectedFrom": ["package.json:scripts.test", "eslint.config.js"]
  }
}
```

| Key | What it does | Default when absent |
|---|---|---|
| `branches.integration` | Branch that feature work forks from and targets | repo default branch |
| `branches.ladder` | Environment rungs, lowest first. Drives `/promote` and promotion detection in `merge-pr` | `[default branch]` — promotion no-ops |
| `branches.protected` | Branches that are never deleted or force-pushed | `main, master, dev, develop, staging, release/*` |
| `project` | GitHub Projects v2 board wiring | absent — all board operations are silent no-ops |
| `verify` | Test and lint commands, plus the files that justified them | model detects and offers to record |

Precedence resolves **per key**, not per file: `.hivrr.json` → global `providerConfig` → hardcoded default. Note that writing `branches.protected` *replaces* the default set rather than extending it — omit the key unless you need to add a name the default does not cover.

Run `init` to scaffold the file from detected repo state. It never overwrites an existing one.

Full reference: [`skill/init/references/config.md`](skill/init/references/config.md).

## Setup

Each plugin is distributed separately via the hivrr GitHub Packages registry. Add whichever you need to your Claude Code settings:

```json
{
  "plugins": [
    "hivrr/agent-plugin",
    "hivrr/manager-plugin",
    "hivrr/data-platform-plugin"
  ]
}
```

Or reference the local path during development:

```json
{
  "plugins": [
    "/path/to/agent-plugin"
  ]
}
```

## Verification

This repo ships no shell scripts — see the script policy in `skill/core/SKILL.md`. Its product is JSON and Markdown, so verification is structural:

```bash
# every JSON file parses
jq empty .hivrr.json .claude-plugin/marketplace.json

# every registered skill and command resolves to a real path
jq -r '.plugins[] | ((.skills // [])[], (.commands // [])[])' .claude-plugin/marketplace.json \
  | while read -r p; do [ -e "$p" ] || echo "MISSING $p"; done
```

## License

MIT

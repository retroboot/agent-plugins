# Hivrr Claude Plugin

Skills and commands for implementation, brainstorming, planning, and code review workflows in Claude Code.

## Plugins

`.claude-plugin/marketplace.json` is the source of truth for what ships. Keep this list in sync with it.

### `dev`
Implementation and code review — issues, PRs, waves, merges, and environment promotions.

**Skills:** `core`, `init`, `session`, `debug`, `merge-pr`, `promote`, `review-pr`, `wave`, `work-issue`, `work-pr`

**Commands:** `debug`, `merge-pr`, `promote`, `review-pr`, `wave`, `work-issue`, `work-pr`

---

### `auditor`
Code audit skills — security, accessibility, performance, and tech debt.

**Skills:** `audit`, `audit-accessibility`, `audit-performance`, `audit-security`, `audit-tech-debt`

**Commands:** `audit`

---

### `planner`
Planning and brainstorming — open-ended thinking sessions through to sized issues, blueprints, and plan documents.

**Skills:** `init`, `session`, `brainstorm`, `planning`

**Commands:** `brainstorm`, `planning`, `write-plan`

---

### `dispatcher`
Manager utility skills for automated work allocation — scoring, grouping, and failure diagnosis.

**Skills:** `init`, `session`, `score-issues`, `group-issues`, `diagnose-failure`

**Commands:** `score-issues`, `group-issues`, `diagnose-failure`

---

### `data-platform`
Full data platform skills — covers the complete stack from ingestion and pipelines to ML, LLMs, dashboards, and database administration.

**Skills:** `senior-data-scientist`, `senior-data-engineer`, `senior-data-analyst`, `senior-ai-engineer`, `snowflake`, `postgres`, `postgres-query`

---

## Shared setup skills

`init` and `session` are included by `dev`, `planner`, and `dispatcher`, and every command loads them before its main skill.

- **`init`** — five ordered phases: provider config, repo labels, `.hivrr.json` scaffold, verify-command detection, and project board ID resolution. The phases run **in order, every time**; a phase with nothing to do reports and continues rather than ending the skill.
- **`session`** — reads config and loads the active provider reference for the session.

## Repo configuration

Per-repo settings live in a committed `.hivrr.json`. The file is optional — a repo without one gets documented defaults, not errors. Precedence resolves **per key**: `.hivrr.json` → global `providerConfig` → hardcoded default.

Full schema, defaults, board operations, and Projects v2 ID resolution: `skill/init/references/config.md`.

## Script policy

**This repo ships no shell scripts.** A script earns its place only when it is read-only or trivially reversible, non-interactive, single-purpose, and performs deterministic computation the model cannot reliably do in prose. Workflow logic goes in skills as explicit steps, where each command is visible and each real output is read.

The full rule, and the reasoning behind it, is in `skill/core/SKILL.md`.

## Verification

The product here is JSON and Markdown, so verification is structural — validate that every JSON file parses and that every skill and command registered in `marketplace.json` resolves to a real path. Both commands are in the README.

Because JSON and Markdown *are* the product in this repo, a change to `marketplace.json` or any `SKILL.md` is a behavior change, not a docs change. Do not skip verification on it.

## Running Multiple Instances

When running multiple instances of the plugin, set the `CONTAINER_NETWORK` environment variable in your `.env` file to reference the Docker network created by Docker Compose. The network name follows the pattern `{directory_name}_default`, where `directory_name` is the folder containing the compose file — not the project name. For example, if your compose file is located in `/path/to/agent-plugin/docker-compose.yml`, add the following to your `.env` file:

```
CONTAINER_NETWORK=agent-plugin_default
```

If you define a custom network name in your `docker-compose.yml`, use that name instead of the `{directory_name}_default` pattern. If the specified network does not exist, Docker will fail to connect and containers will be unable to communicate.

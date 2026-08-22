<!-- Claude Code loads this file automatically as project-level instructions. -->

# Hivrr Claude Plugin

Skills and commands for implementation, brainstorming, planning, and code review workflows in Claude Code.

> **This file has two jobs.** It documents the repo for people, and Claude Code loads it verbatim as
> project instructions for any session started here — so every sentence is also a directive an agent
> will act on. Write it as instructions, not as description: prefer "keep this list in sync with
> `marketplace.json`" over "this list mirrors `marketplace.json`". Editing it changes agent
> behaviour in this repo, which is why a change here is a behaviour change and not a docs change
> (see **Verification** below).

## Plugins

`.claude-plugin/marketplace.json` is the source of truth for what ships. Keep this list in sync with it.

**In sync means verbatim.** Each `### plugin` heading below is followed by that plugin's
`marketplace.json` `description`, character for character apart from the trailing period this file
adds. Say it once and copy it, rather than writing a second description here — the two drifted
before precisely because each read as reasonable prose on its own, and nothing compares them. When
you change one, change the other in the same commit; a description is what a user reads when
deciding whether to install, so an understated one ships a narrower plugin than the one that exists.

For that to be one rule rather than five special cases, **keep every `marketplace.json` description
a single sentence with no terminal period.** A two-sentence description ends in a period of its
own, and then this file adds nothing — so `{description}.` stops describing the line here, and any
check written against the rule reports that row as drifted when it is not. If a description needs a
second clause, join it with a comma rather than starting a new sentence.

### Path resolution

Skills and commands are registered with different path shapes, and getting one wrong fails silently
— the entry is accepted, the skill or command simply never loads.

| Kind | Registered as | Resolves to |
|---|---|---|
| Skill | a **directory**, no extension — `./skill/audit` | `skill/audit/SKILL.md` |
| Command | a **file, `.md` included** — `./command/audit.md` | `command/audit.md` |

Always write the extension on a command entry. Every command entry currently carries it and every
command loads, so the explicit form is the one known to work; whether the manager would also accept
an extension-less command path is untested and not worth relying on either way. The third check under
**Verification** keeps the explicit form in place, because nothing else in the repo would catch
its absence — a command that fails to resolve produces no error, just a slash command that is not
there.

### `dev`
Implementation and code review — issues, PRs, waves, merges, and environment promotions.

**Skills:** `core`, `init`, `session`, `debug`, `merge-pr`, `promote`, `review-pr`, `wave`, `work-issue`, `work-pr`

**Commands:** `debug`, `merge-pr`, `promote`, `review-pr`, `wave`, `work-issue`, `work-pr`

---

### `auditor`
Code audit — security, accessibility, performance, and tech debt.

**Skills:** `audit`, `audit-accessibility`, `audit-performance`, `audit-security`, `audit-tech-debt`

**Commands:** `audit`

---

### `planner`
Planning and brainstorming — open-ended thinking sessions through to sized issues, then implementation plans with TDD tasks, complexity-aware blueprints, and an automated plan review.

**Skills:** `init`, `session`, `brainstorm`, `planning`

**Commands:** `brainstorm`, `planning`, `write-plan`

---

### `dispatcher`
Manager utilities for automated work allocation — issue scoring, wave grouping, and failure diagnosis.

**Skills:** `init`, `session`, `score-issues`, `group-issues`, `diagnose-failure`

**Commands:** `score-issues`, `group-issues`, `diagnose-failure`

---

### `data-platform`
Full data platform — data science, engineering, analysis, AI engineering, Snowflake, and PostgreSQL, covering the complete stack from ingestion and pipelines to ML, LLMs, dashboards, and database administration.

**Skills:** `senior-data-scientist`, `senior-data-engineer`, `senior-data-analyst`, `senior-ai-engineer`, `snowflake`, `postgres`, `postgres-query`

---

## Shared setup skills

`init` and `session` are included by `dev`, `planner`, and `dispatcher`, and every command loads them before its main skill.

- **`init`** — five ordered phases: provider config, repo labels, `.hivrr.json` scaffold, verify-command detection, and project board ID resolution. The phases run **in order, every time**; a phase with nothing to do reports and continues rather than ending the skill.
- **`session`** — reads config and loads the active provider reference for the session.

## Repo configuration

Per-repo settings live in a committed `.hivrr.json`. The file is optional — a repo without one gets documented defaults, not errors. Precedence resolves **per key**: `.hivrr.json` → global `providerConfig` → hardcoded default. `provider` and `issueTracker` resolve independently, so state both here rather than assuming one implies the other.

Issue hierarchy (GitHub sub-issues) is opt-in via `issues.hierarchy` and is GitHub-only. When it is
off, `planning` emits a flat issue set and `group-issues` falls back to parsing `Depends on #N` from
issue bodies. See `skill/init/references/config.md`.

**This repo does not enable it** — the `issues` key is absent from `.hivrr.json`, so the fallback
above is the behavior here rather than a hypothetical. Like the absent project board and the
unadopted worktrees below, that is a decision.

Full schema, defaults, board operations, and Projects v2 ID resolution: `skill/init/references/config.md`.

### This repo has no project board — deliberately

`.hivrr.json` has no `project` key, and that is a decision rather than an oversight. Do not add one,
and do not treat `init` Phase 5 skipping or `merge-pr` skipping its board update as something to fix.

Board operations are documented as silent no-ops when `project` is absent, which is the correct
behavior and the one this repo relies on. The consequence worth knowing: any feature whose output is
a board rollup — the sub-issue epic rollup among them — is **display-only here**. The hierarchy is
still real and still readable through the tracker; there is simply no board for it to roll up onto.

If a board is wanted later, `skill/init/references/config.md` has the full sequence: create it, add
`project.owner` and `project.number`, and run `init` to resolve and cache the IDs.

## Worktree isolation

Mutating workflows can run in a git worktree so concurrent sessions in one checkout cannot commit
each other's changes. It is opt-in per repo and needs two things: `worktree.enabled` in
`.hivrr.json`, and a line in the repo's own `CLAUDE.md` authorizing the harness `EnterWorktree`
tool. One without the other silently does nothing.

Worktrees live under `.claude/worktrees/`, so an adopting repo needs `.claude/` in its `.gitignore`
as well — otherwise the worktree shows up as an untracked path and `work-issue` Phase 10 stops on
it, reporting a concurrent session that is not there. This repo already ignores `.claude/`.

They are **not** free — untracked files do not travel, and they must be cleaned up. See
`skill/init/references/config.md`.

**This repo does not enable it.** `agent-plugins` has no dependencies, no `.env`, and its sessions
edit Markdown rather than running a stack, so the setup cost buys nothing here. Do not add the key
or the authorization line — like the absent project board above, the absence is a decision.

## Script policy

**This repo ships no shell scripts.** A script earns its place only when it is read-only or trivially reversible, non-interactive, single-purpose, and performs deterministic computation the model cannot reliably do in prose. Workflow logic goes in skills as explicit steps, where each command is visible and each real output is read.

The full rule, and the reasoning behind it, is in `skill/core/SKILL.md`.

## Verification

The product here is JSON and Markdown, so verification is structural — validate that every JSON file parses, that every registered skill is a directory holding a `SKILL.md`, and that every registered command is an existing `.md` file. All three commands are in the README.

Because JSON and Markdown *are* the product in this repo, a change to `marketplace.json` or any `SKILL.md` is a behavior change, not a docs change. Do not skip verification on it.

## Running Multiple Instances

When running multiple instances of the plugin, set the `CONTAINER_NETWORK` environment variable in your `.env` file to reference the Docker network created by Docker Compose. The network name follows the pattern `{directory_name}_default`, where `directory_name` is the folder containing the compose file — not the project name. For example, if your compose file is located in `/path/to/agent-plugin/docker-compose.yml`, add the following to your `.env` file:

```
CONTAINER_NETWORK=agent-plugin_default
```

If you define a custom network name in your `docker-compose.yml`, use that name instead of the `{directory_name}_default` pattern. If the specified network does not exist, Docker will fail to connect and containers will be unable to communicate.

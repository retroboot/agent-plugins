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
| `init` | One-time setup — provider config, repo labels, `.hivrr.json` scaffold, verify commands, project board IDs, config reconciliation, orphan-worktree reporting |
| `session` | Loads config and the active provider reference for the session |
| `core` | Coding philosophy — quality gates, git safety, script policy, and task completion standards |
| `work-issue` | Implement an issue end-to-end and open a PR/MR |
| `work-pr` | Address PR/MR review feedback end-to-end |
| `review-pr` | Review a PR/MR and post a structured comment |
| `merge-pr` | Merge a PR/MR, close linked issues, clean up branches, capture follow-up work |
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
  "issueTracker": "github",
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
  "issues": {
    "hierarchy": true,
    "epicThreshold": 4
  },
  "worktree": {
    "enabled": true,
    "carry": [".env", ".claude/settings.local.json"],
    "setup": "npm ci"
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
| `provider` | Where the repo is hosted | global `providerConfig.repoProvider`, then the host in `git remote get-url origin` |
| `issueTracker` | Where this repo's issues live — independent of `provider` | global `providerConfig.issueTracker`, then the resolved `provider` |
| `branches.integration` | Branch that feature work forks from and targets | repo default branch |
| `branches.ladder` | Environment rungs, lowest first. Drives `/promote` and promotion detection in `merge-pr` | `[default branch]` — promotion no-ops |
| `branches.protected` | Branches that are never deleted or force-pushed | `main, master, dev, develop, staging, release/*` |
| `project` | GitHub Projects v2 board wiring | absent — all board operations are silent no-ops |
| `issues` | Issue hierarchy — GitHub sub-issues, and the epic threshold for planning. **GitHub-only** — forced off on GitLab and Linear | absent — all hierarchy operations are silent no-ops |
| `worktree` | Isolation for mutating sessions — needs a `CLAUDE.md` authorization line as well as this key | absent — every worktree operation is a silent no-op |
| `verify` | Test and lint commands, plus the files that justified them | model detects and offers to record |
| `verify.detectedFrom` | The files that justified each command — or `["manual"]`, which pins the block and stops `init` re-detecting it | model records what it matched |

Precedence resolves **per key**, not per file: `.hivrr.json` → global `providerConfig` → hardcoded default. `provider` and `issueTracker` resolve independently, so a repo hosted on one provider can track its issues on another — and a repo that overrides only `provider` still takes its tracker from global config. Note that writing `branches.protected` *replaces* the default set rather than extending it — omit the key unless you need to add a name the default does not cover.

Set `verify.detectedFrom` to exactly `["manual"]` when a repo's verification is real but
unconventional — structural checks defined in a `README`, a bespoke harness, anything `init`'s
detection tables have no row for. Phase 4 then leaves the block alone. Without it, detection
correctly finds nothing and writes `null`, which means "checked, there is nothing" — so the
execution skills report `skipped` and an unattended run skips verification on a repo that has it.
**This repo uses the sentinel**, because its own checks are the five in **Verification** below, and
`verify.test` holds the runnable form of them.

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

This repo ships no shell scripts — see the script policy in `skill/core/SKILL.md`. Its product is JSON and Markdown, so verification is structural.

Skills and commands resolve by different rules, so check them separately — a single `[ -e ]` test
passes on a command entry that has lost its `.md`, and that command then fails to load silently.
Let git enumerate the JSON files rather than listing them, so the check cannot drift from the repo:

```bash
# every JSON file parses
jq empty $(git ls-files '*.json')

# every registered skill is a directory holding a SKILL.md
jq -r '.plugins[] | (.skills // [])[]' .claude-plugin/marketplace.json | sort -u \
  | while read -r p; do [ -f "$p/SKILL.md" ] || echo "BAD SKILL $p"; done

# every registered command is an existing .md file
jq -r '.plugins[] | (.commands // [])[]' .claude-plugin/marketplace.json | sort -u \
  | while read -r p; do
      case "$p" in *.md) ;; *) echo "NO .md EXTENSION $p"; continue ;; esac
      [ -f "$p" ] || echo "MISSING $p"
    done

# work-issue and work-pr do not duplicate each other's verify procedure
grep -Fxf skill/work-pr/SKILL.md skill/work-issue/SKILL.md \
  | awk 'length > 60' \
  | grep -vFxf docs/shared-lines-allowlist.txt \
  | grep . && echo "DUPLICATED — extract to a shared reference" || true

# CLAUDE.md plugin descriptions match marketplace.json verbatim
jq -r '.plugins[] | select(.description | endswith(".")) | "DESC TERMINAL PERIOD \(.name)"' \
  .claude-plugin/marketplace.json
jq -r '.plugins[] | "\(.name)\t\(.description)"' .claude-plugin/marketplace.json \
  | while IFS="$(printf '\t')" read -r name desc; do
      grep -qxF "### \`$name\`" CLAUDE.md || { echo "DESC NO HEADING $name"; continue; }
      line=$(awk -v h="### \`$name\`" 'p { print; exit } $0 == h { p = 1 }' CLAUDE.md)
      [ -n "$line" ] || { echo "DESC BLANK AFTER HEADING $name"; continue; }
      [ "$line" = "$desc." ] || echo "DESC DRIFT $name"
    done
grep -oE '^### `[^`]+`' CLAUDE.md | tr -d '#` ' \
  | while read -r name; do
      jq -e --arg n "$name" 'any(.plugins[]; .name == $n)' .claude-plugin/marketplace.json \
        >/dev/null || echo "DESC NO PLUGIN $name"
    done
```

Silence from all five means everything registered resolves, nothing is duplicated, and the two
places that describe the plugins agree. See **Path resolution** in `CLAUDE.md` for the contract the
first three commands enforce.

The fourth check guards against the failure the others cannot see: two skills carrying the same
procedure in prose. Markdown that parses and resolves is still wrong if it says the same thing
twice and the two copies disagree. `docs/shared-lines-allowlist.txt` holds the lines the two
execution skills are *meant* to share — a flag, a warning, a framing sentence, and the pointer at
`skill/init/references/verify.md`. Adding a line to it is a deliberate claim that the duplication is
correct; if you cannot make that claim, extract the line instead. Never raise the `length > 60`
threshold to make the check pass — that hides future duplication silently, which is the failure the
check exists to catch.

The fifth check does the same job one level up, for the one piece of prose that is duplicated *on
purpose*. `.claude-plugin/marketplace.json` is the source of truth for what ships, and `CLAUDE.md`
repeats each plugin's `description` verbatim under its `### plugin` heading. Both files stay valid
however far apart they drift, and the first four checks cannot see prose disagreement across two
files — which is how the descriptions drifted twice, reconciled by hand in #162 and again in #166.

It reports five distinct failures rather than one, because they call for different fixes:

| Output | Meaning |
|---|---|
| `DESC DRIFT {name}` | The `CLAUDE.md` line and the `marketplace.json` description disagree |
| `DESC NO HEADING {name}` | A plugin ships with no matching `###` section in `CLAUDE.md` |
| `DESC BLANK AFTER HEADING {name}` | The section exists but nothing follows the heading |
| `DESC NO PLUGIN {name}` | `CLAUDE.md` documents a plugin `marketplace.json` no longer lists |
| `DESC TERMINAL PERIOD {name}` | A `marketplace.json` description ends in `.` — see below |

`DESC BLANK AFTER HEADING` is separate from `DESC NO HEADING` on purpose. The comparison reads the
line **immediately after** the heading, so a blank line between them breaks it — and a blank line is
invisible in rendered Markdown, so a reader told the heading is missing would look straight at it and
have nowhere to go. Testing for the heading and for the line under it as two conditions costs one
`grep` and keeps each message pointing at its own fix.

`DESC TERMINAL PERIOD` is not a style rule. The invariant the check compares is
`claude_line == description + "."`, which only holds because every description is a single sentence
with no terminal period. A
two-sentence description ends in its own period, `CLAUDE.md` then adds nothing, and the comparison
reports drift on a row that is correct. Catching the period directly turns that into a message that
names the real cause instead of a confusing `DESC DRIFT`. `CLAUDE.md` states the single-sentence
rule; this is what holds it.

`DESC NO PLUGIN` is the direction the description loop structurally cannot see: it iterates
`marketplace.json`, so a section left behind for a plugin that no longer ships is invisible to it.
That leaves `CLAUDE.md` instructing every agent about a plugin nobody can install. It reads a
backticked `###` heading as a plugin claim, which is why `CLAUDE.md` reserves that heading shape for
plugins and documents everything else at another level.

**The `verify.test` form of this check is not a copy of the text above.** It is wrapped in
`bash -c '…'`, so it can contain no single quote, and a bare backtick would be command substitution
to the inner shell — it builds one with `printf "\140"` instead, and reads the plugin names once
into a variable rather than calling `jq --arg` per heading. Transcribe the **behavior** between the
two forms, not the characters, and re-run the drift cases below after editing either. This is the
same warning as "adding a check here means changing it there too", one level finer: a check that
survives transcription as text but not as behavior passes silently for both files.

To re-run them: edit one `CLAUDE.md` description, edit one `marketplace.json` description, append a
period to one, insert a blank line under one heading, rename one heading, and replace one em dash
with a hyphen. Each must produce its own message and exit non-zero, and a clean tree must print
`structural checks pass`.

**Extracting does not always mean a new reference file.** The blanket-staging prohibition was
allowlisted and then extracted to the **Git Safety** section of `skill/core/SKILL.md`, because every
`dev` command already loads `core` as its third bootstrap step. A rule that lands there costs no new
file and no new indirection — the destination is already in context when the skill runs. Prefer it
over `skill/*/references/` for anything that is a *policy* rather than a *procedure*, and note that
it is only reachable from plugins that ship `core` — which today is `dev` alone.

`skill/planning/references/plan-writing.md` and `skill/init/SKILL.md` therefore state the staging
rule in their own words. For `plan-writing.md` the reason is that `planner` does not ship `core`.
For `init` it is the same reason and it is stronger, because `init` ships in three plugins and two
of them — `planner` and `dispatcher` — do not carry `core`. **Load order is not what keeps that copy
inline.** A plugin install contains only the skills its `marketplace.json` entry names, so
reordering the bootstrap to load `core` before `init` would still leave `../core/SKILL.md`
unresolvable in two installs out of three. Do not "fix" either copy into a link; the way to remove
one is to add `./skill/core` to the plugin that needs it — and, if the rule has to be *in context*
rather than merely reachable, to load it before the skill that cites it. Packaging is what makes the
link resolve; bootstrap order is what makes it free.

Where those inline copies point at other skills, keep the reference **phase-agnostic** — "the commit
phases of `work-issue` and `work-pr`", not "Phase 10 and Phase 9". Phase numbers are hand-maintained
and no check reads prose, so a skill that gains or loses a phase leaves every citation of it silently
wrong.

**`.hivrr.json` `verify.test` is the runnable form of these five checks.** It runs them from the
repo root, prints only findings, and exits non-zero when there are any — which is what makes
`work-issue` and `work-pr` report `tests pass` here instead of `tests skipped`. **Adding or changing
a check above means changing it there too.** Nothing enforces that: both files stay valid Markdown
and JSON however far apart they drift, and `verify.detectedFrom: ["manual"]` stops `init` from
re-deriving the command. A sixth check added here and not there is simply never run.

**The duplication check covers one pair, deliberately.** Other same-named skills share lines over
the same threshold today — `planning` and `brainstorm` share the session-UUID bootstrap and its fallback
warning, `score-issues` and `group-issues` share their `excluded` contract. Widening the check to
every pair needs a **per-pair** allowlist first, because some of that sharing is required rather
than accidental: the `excluded` contract paragraphs are specified to be byte-identical, so a
repo-wide check with one shared allowlist would report a mandated duplication as a defect. Treat
the uncovered pairs as known and unguarded, not as verified.

## License

MIT

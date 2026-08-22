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

**The sixth structural check enforces that**, for the `**Skills:**` and `**Commands:**` lines below as
well as for `README.md`'s per-plugin table, and reports `SKILLS DRIFT {plugin} {file}` or
`COMMANDS DRIFT {plugin} {file}` naming which file disagrees. So the sentence above is now a checked
rule rather than a hopeful one — add a skill to a plugin and three files have to say so.

`README.md` lists commands as a flat usage block rather than per plugin, so the sixth check has no
`readme` direction for them. **The ninth check covers that block repo-wide instead**, in both
directions: it reports `COMMAND UNDOCUMENTED {name}` for a registered command with no usage example
and `COMMAND NOT REGISTERED {name}` for an example naming a command that no longer ships. Adding a
command therefore means `marketplace.json`, the `**Commands:**` line below, and the usage block in
`README.md` — and removing one means all three as well.

**In sync means verbatim.** Each `### plugin` heading below is followed by that plugin's
`marketplace.json` `description`, character for character apart from the trailing period this file
adds. Say it once and copy it, rather than writing a second description here — the two drifted
before precisely because each read as reasonable prose on its own. When you change one, change the
other in the same commit; a description is what a user reads when deciding whether to install, so an
understated one ships a narrower plugin than the one that exists.

**The fifth structural check enforces this**, so a mismatch fails verification rather than shipping.
It reports a `DESC …` message naming the plugin and the specific disagreement; `README.md` has the
full table, kept there so adding a message does not leave a stale list here. Fix the disagreement —
never edit around the check.

For that to be one rule rather than one special case per plugin, **keep every `marketplace.json` description
a single sentence with no terminal period.** A two-sentence description ends in a period of its
own, and then this file adds nothing — so `{description}.` stops describing the line here, and the
check reports that row as drifted when it is not. The check catches the cause directly and reports
`DESC TERMINAL PERIOD {name}`, so read that as "shorten the description", not "add a period here".
If a description needs a second clause, join it with a comma rather than starting a new sentence.

Two things about the shape of this file are load-bearing, because they are what the check reads:

- **The description stays on the single line immediately after the heading**, with no blank line
  between them. A blank line reports as `DESC BLANK AFTER HEADING {name}` — the heading is fine, the
  gap is not, and a blank line is invisible in rendered Markdown.
- **A backticked `###` heading in this file means a plugin.** The check reads every one of them as a
  plugin claim and reports `DESC NO PLUGIN` for any that `marketplace.json` does not list. Document
  anything else — skills, sections, notes — at a different heading level or without backticks. The
  `init` and `session` entries under **Shared setup skills** are bullets for this reason, not
  headings.

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

- **`init`** — seven ordered phases: provider config, repo labels, `.hivrr.json` scaffold, verify-command detection, project board ID resolution, config reconciliation, and orphan-worktree reporting. The phases run **in order, every time**; a phase with nothing to do reports and continues rather than ending the skill. Keep the count and the list here matching the `## Phase` headings in `skill/init/SKILL.md` and the `init` row in `README.md`. A count that reads low tells an agent the run is over before it is — which is exactly what happened, when that skill said `five` against seven headings. **The seventh structural check holds `skill/init/SKILL.md`'s own count** against its own headings, and **the tenth holds the count in this sentence** against those same headings, so a low count can no longer ship from either file. Neither reads the *list*: comparing prose names against heading titles needs a normalization nobody would trust, so keep the list here matching `skill/init/SKILL.md` by hand. The `init` row in `README.md` enumerates the same phases and states no count deliberately — it has no bare number to drift, so do not add one for symmetry with this line.
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
and do not treat `init` skipping project-board resolution or `merge-pr` skipping its board update as
something to fix.

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
as well — otherwise the worktree shows up as an untracked `??` entry in the pre-commit
`git status --short` check, where it has to be told apart from a real concurrent session on every
commit for the rest of the run. This repo already ignores `.claude/`.

They are **not** free — untracked files do not travel, and they must be cleaned up. See
`skill/init/references/config.md`.

**This repo does not enable it.** `agent-plugins` has no dependencies, no `.env`, and its sessions
edit Markdown rather than running a stack, so the setup cost buys nothing here. Do not add the key
or the authorization line — like the absent project board above, the absence is a decision.

## Script policy

**This repo ships no shell scripts.** A script earns its place only when it is read-only or trivially reversible, non-interactive, single-purpose, and performs deterministic computation the model cannot reliably do in prose. Workflow logic goes in skills as explicit steps, where each command is visible and each real output is read.

The full rule, and the reasoning behind it, is in `skill/core/SKILL.md`.

## Verification

The product here is JSON and Markdown, so verification is structural. Ten checks: every JSON file parses; every registered skill is a directory holding a `SKILL.md`; every registered command is an existing `.md` file; `work-issue` and `work-pr` do not duplicate each other's verify procedure; the plugin descriptions in this file match `marketplace.json` verbatim; the skill and command lists beside those descriptions match it too; every skill's phase headings run `1..N` with any stated count matching; the count opening this sentence matches the number of checks in the README block; `README.md`'s command usage block names exactly the commands `marketplace.json` registers; and the `init` phase count in this file matches the phase headings in `skill/init/SKILL.md`. All of them are in the README, and `.hivrr.json` `verify.test` is the runnable form of them.

**That opening count is itself the eighth check**, so it can no longer drift silently — it is compared against the `# ` comments at column 0 in the README **Verification** block. It is the only check count left in the repo; `README.md` carried two more, and those were reworded away rather than checked, because a bare number tells a reader nothing they can act on while this sentence has to *name* what it counts. Adding a check means extending this sentence, and the check will say so if you forget. **No count that names something in another file is left unguarded**: `README.md`'s two remaining ones — the plugin count and the `DESC` message-row count — were reworded away as well, and the only other such number here, `init`'s phase count above, is held by the tenth check. Counts of items in their own paragraph are a different thing and are deliberately left alone — *"Two things about the shape of this file are load-bearing"* above two bullets drifts only if you edit the list while looking at it. The test for a count you are adding is whether confirming it means opening another file.

Because JSON and Markdown *are* the product in this repo, a change to `marketplace.json` or any `SKILL.md` is a behavior change, not a docs change. Do not skip verification on it.

## Running Multiple Instances

When running multiple instances of the plugin, set the `CONTAINER_NETWORK` environment variable in your `.env` file to reference the Docker network created by Docker Compose. The network name follows the pattern `{directory_name}_default`, where `directory_name` is the folder containing the compose file — not the project name. For example, if your compose file is located in `/path/to/agent-plugin/docker-compose.yml`, add the following to your `.env` file:

```
CONTAINER_NETWORK=agent-plugin_default
```

If you define a custom network name in your `docker-compose.yml`, use that name instead of the `{directory_name}_default` pattern. If the specified network does not exist, Docker will fail to connect and containers will be unable to communicate.

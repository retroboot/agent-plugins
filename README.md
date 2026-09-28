# hivrr-agent-plugin

Claude Code skills and slash commands for the hivrr workflow. Distributed as a Claude plugin and loaded into agent sessions to give them first-class access to hivrr's automation capabilities.

## Overview

The agent plugin ships two artifact types:

- **Skills** — reusable prompts loaded by name (e.g., `work-issue`, `review-pr`). Used by Claude to execute well-defined tasks with consistent behavior.
- **Commands** — slash commands exposed in the Claude Code UI (e.g., `/work-issue 123`, `/audit security`).

The plugin is split into focused packages:

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
| `ship-issue` | Drive a list of issues to merged PR(s), composing `work-issue` and `ship-pr` |
| `ship-pr` | Drive an existing PR/MR to clean-or-merged, composing `review-pr`, `work-pr`, and `merge-pr` |
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
**This repo uses the sentinel**, because its own checks are the ones in **Verification** below, and
`verify.test` holds the runnable form of them.

Run `init` to scaffold the file from detected repo state. It never overwrites an existing one.

Full reference: [`skills/init/references/config.md`](skills/init/references/config.md).

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

This repo ships no shell scripts — see the script policy in `skills/core/SKILL.md`. Its product is JSON and Markdown, so verification is structural.

The fenced block below is not an exception to that policy. It is read-only, non-interactive, and
single-purpose, and it is not a `.sh` on disk — it is documentation in this file, which
`.hivrr.json` `verify.test` extracts and runs. What you read here is exactly what runs; see the
paragraphs after the block.

Skills and commands resolve by different rules, so check them separately — a single `[ -e ]` test
passes on a command entry that has lost its `.md`, and that command then fails to load silently.
Let git enumerate the JSON files rather than listing them, so the check cannot drift from the repo:

```bash
# every JSON file parses
json_files=$(git ls-files '*.json')
if [ -n "$json_files" ]; then
  # unquoted on purpose: word splitting is what passes each path as its own argument
  jq empty $json_files
else
  echo "NO JSON FILES TRACKED"
fi

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
grep -Fxf skills/work-pr/SKILL.md skills/work-issue/SKILL.md \
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

# README and CLAUDE.md skill and command lists match marketplace.json
jq -r '.plugins[].name' .claude-plugin/marketplace.json | while read -r p; do
    h="### \`$p\`"
    mk_s=$(jq -r --arg p "$p" '.plugins[] | select(.name == $p) | (.skills // [])[]' \
             .claude-plugin/marketplace.json | sed 's|.*/||' | sort -u)
    mk_c=$(jq -r --arg p "$p" '.plugins[] | select(.name == $p) | (.commands // [])[]' \
             .claude-plugin/marketplace.json | sed 's|.*/||; s|\.md$||' | sort -u)
    sec_c=$(awk -v h="$h" '$0 == h { p = 1; next } p && /^#/ { exit } p' CLAUDE.md)
    sec_r=$(awk -v h="$h" '$0 == h { p = 1; next } p && /^#/ { exit } p' README.md)
    cl_s=$(printf '%s\n' "$sec_c" | sed -n 's/^\*\*Skills:\*\* *//p'   | tr ',' '\n' | tr -d '` ' | grep . | sort -u)
    cl_c=$(printf '%s\n' "$sec_c" | sed -n 's/^\*\*Commands:\*\* *//p' | tr ',' '\n' | tr -d '` ' | grep . | sort -u)
    rd_s=$(printf '%s\n' "$sec_r" | sed -n 's/^| *`\([^`]*\)` *|.*/\1/p' | sort -u)
    [ "$mk_s" = "$cl_s" ] || echo "SKILLS DRIFT $p claude"
    [ "$mk_s" = "$rd_s" ] || echo "SKILLS DRIFT $p readme"
    [ "$mk_c" = "$cl_c" ] || echo "COMMANDS DRIFT $p claude"
  done

# every skill's phase headings run 1..N, and any stated count matches them
w2n() { case "$1" in one) echo 1;; two) echo 2;; three) echo 3;; four) echo 4;; five) echo 5;;
        six) echo 6;; seven) echo 7;; eight) echo 8;; nine) echo 9;; ten) echo 10;;
        eleven) echo 11;; twelve) echo 12;; thirteen) echo 13;; *) echo 0;; esac; }
for f in skills/*/SKILL.md; do
    nums=$(grep '^## Phase [0-9]' "$f" | sed 's/^## Phase *\([0-9][0-9]*\).*/\1/' | sort -n -u)
    cnt=$(printf '%s\n' "$nums" | grep -c .)
    [ "$cnt" -eq 0 ] && continue
    [ "$nums" = "$(seq 1 "$cnt")" ] \
      || echo "PHASE SEQUENCE $f (numbered $(echo $nums | tr '\n' ' ')- expected 1 to $cnt)"
    said=$(sed -n 's/.*[Tt]he \**\(one\|two\|three\|four\|five\|six\|seven\|eight\|nine\|ten\|eleven\|twelve\|thirteen\)\** phases.*/\1/p' "$f" | head -1)
    [ -n "$said" ] || continue
    [ "$(w2n "$said")" = "$cnt" ] || echo "PHASE COUNT DRIFT $f (says $said, has $cnt)"
  done

# CLAUDE.md's stated check count matches the number of checks in this block
if [ -n "${HIVRR_VERIFY_BLOCK:-}" ]; then
    n=$(printf '%s\n' "$HIVRR_VERIFY_BLOCK" | grep -c '^# ')
    said=$(sed -n 's/.*[^A-Za-z]\([A-Za-z][a-z]*\) checks:.*/\1/p' CLAUDE.md | head -1 | tr 'A-Z' 'a-z')
    [ "$(w2n "$said")" = "$n" ] || echo "CHECK COUNT DRIFT CLAUDE.md says $said, README has $n"
  else
    echo "CHECK COUNT UNCHECKED HIVRR_VERIFY_BLOCK unset, so nothing counted the block that ran"
  fi

# README's command usage block names exactly the registered commands
reg_c=$(jq -r '.plugins[] | (.commands // [])[]' .claude-plugin/marketplace.json \
          | sed 's|.*/||; s|\.md$||' | sort -u)
doc_c=$(awk '/^## Commands/ { v = 1; next } v && /^## / { exit } v' README.md \
          | sed -n 's|^/\([A-Za-z0-9_-][A-Za-z0-9_-]*\).*|\1|p' | sort -u)
printf '%s\n' "$reg_c" | grep . | while read -r c; do
    printf '%s\n' "$doc_c" | grep -qxF "$c" || echo "COMMAND UNDOCUMENTED $c"
  done
printf '%s\n' "$doc_c" | grep . | while read -r c; do
    printf '%s\n' "$reg_c" | grep -qxF "$c" || echo "COMMAND NOT REGISTERED $c"
  done

# CLAUDE.md's init phase count matches skills/init/SKILL.md's phase headings
ip_n=$(grep '^## Phase [0-9]' skills/init/SKILL.md \
         | sed 's/^## Phase *\([0-9][0-9]*\).*/\1/' | sort -n -u | grep -c .)
ip_said=$(sed -n 's/.*[^A-Za-z]\([A-Za-z][a-z]*\) ordered phases.*/\1/p' CLAUDE.md \
            | head -1 | tr 'A-Z' 'a-z')
[ "$(w2n "$ip_said")" = "$ip_n" ] \
  || echo "INIT PHASE COUNT DRIFT CLAUDE.md says $ip_said, skills/init/SKILL.md has $ip_n"

# README's Overview table names exactly the registered plugins
reg_p=$(jq -r '.plugins[].name' .claude-plugin/marketplace.json | sort -u)
ov_p=$(awk '/^## Overview/ { v = 1; next } v && /^#/ { exit } v' README.md \
         | sed -n 's/^| *`\([^`]*\)` *|.*/\1/p' | sort -u)
printf '%s\n' "$reg_p" | grep . | while read -r p; do
    printf '%s\n' "$ov_p" | grep -qxF "$p" || echo "PLUGIN UNDOCUMENTED $p"
  done
printf '%s\n' "$ov_p" | grep . | while read -r p; do
    printf '%s\n' "$reg_p" | grep -qxF "$p" || echo "PLUGIN NOT REGISTERED $p"
  done

# the PR review declares itself read-only and grants no unrestricted tool
rfm=$(awk 'NR == 1 && $0 == "---" { p = 1; next } p && $0 == "---" { exit } p' \
        skills/review-pr/SKILL.md)
if ! printf '%s\n' "$rfm" | grep -q '^allowed-tools:'; then
    echo "REVIEW NOT READ-ONLY skills/review-pr/SKILL.md (no allowed-tools)"
  else
    printf '%s\n' "$rfm" | grep -qE '^ *-? *(Edit|Write|NotebookEdit|Bash) *$' \
      && echo "REVIEW MAY WRITE skills/review-pr/SKILL.md (allowed-tools grants an unrestricted tool)"
    # Bash(git:*) covers checkout, stash, commit, and clean; Bash(git remote:*) keeps a space
    printf '%s\n' "$rfm" | grep -qE '^ *-? *Bash\(git[:)]' \
      && echo "REVIEW MAY WRITE skills/review-pr/SKILL.md (allowed-tools grants unscoped git)"
  fi
```

Silence from all of them means everything registered resolves, nothing is duplicated, the phase
numbering holds, every count in `CLAUDE.md` matches what it counts, and the three places that
describe the plugins agree. See **Path resolution** in `CLAUDE.md` for the contract the first three
commands enforce.

**The first check says so when there is nothing to check.** `jq empty $(git ls-files '*.json')` on
its own cannot tell *"every JSON file parses"* apart from *"there are no JSON files"*: an empty
command substitution leaves a bare `jq empty`, which reads stdin — closed by the loader, so it sees
empty input, exits `0`, and prints nothing. In a repo where `.claude-plugin/marketplace.json` **is**
the product, the second of those is catastrophic and would have reported as healthy. The guard is
folded under the existing comment rather than given one of its own, because it is the same check
made honest rather than a new claim — so this is still eleven checks, not twelve.

Two things about its shape are deliberate. `$json_files` is left **unquoted** in the `jq` call, and
that is the one place in the block where word splitting is wanted — it is what passes each path as
its own argument. A path containing whitespace would therefore break it; no file in this repo has
one, and the `git ls-files -z` / `xargs -0` form that would handle it reintroduces a stdin-reading
command, which is exactly what the loader forbids. **Do not close this gap by reverting the stdin
closure** — without `</dev/null` the bare `jq empty` eats the rest of the block instead, which is
strictly worse; see the loader paragraphs at the end of this section.

The fourth check guards against the failure the others cannot see: two skills carrying the same
procedure in prose. Markdown that parses and resolves is still wrong if it says the same thing
twice and the two copies disagree. `docs/shared-lines-allowlist.txt` holds the lines the two
execution skills are *meant* to share — a flag, a warning, a framing sentence, and the pointer at
`skills/init/references/verify.md`. Adding a line to it is a deliberate claim that the duplication is
correct; if you cannot make that claim, extract the line instead. Never raise the `length > 60`
threshold to make the check pass — that hides future duplication silently, which is the failure the
check exists to catch.

The fifth check does the same job one level up, for the one piece of prose that is duplicated *on
purpose*. `.claude-plugin/marketplace.json` is the source of truth for what ships, and `CLAUDE.md`
repeats each plugin's `description` verbatim under its `### plugin` heading. Both files stay valid
however far apart they drift, and the first four checks cannot see prose disagreement across two
files — which is how the descriptions drifted twice, reconciled by hand in #162 and again in #166.

It reports a distinct failure for each, rather than one, because they call for different fixes:

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

**The block above is not a description of `verify.test` — it *is* `verify.test`.** The runnable
form extracts this fence at run time and pipes it to `bash`, so editing a check here changes what
runs, immediately and with no second copy to update. It used to be a hand transcription wrapped in
`bash -c '…'`, which could contain no single quote and had to build a backtick with
`printf "\140"`; nothing compared the two forms, so a check added here and not there was simply
never run. Those constraints are gone — write ordinary readable bash, quotes and backticks and all.
One consequence replaces them: the fence is now parsed as a script, so a syntax error in any one
check fails all of them rather than none. It fails loudly, which is the trade this is worth.

To re-run them: edit one `CLAUDE.md` description, edit one `marketplace.json` description, append a
period to one, insert a blank line under one heading, rename one heading, and replace one em dash
with a hyphen. Each must produce its own message and exit non-zero, and a clean tree must print
`structural checks pass`.

The sixth check finishes the job the fifth started. `CLAUDE.md` repeats each plugin's *description*
and the fifth check now holds that; the `**Skills:**` and `**Commands:**` lines beside it, and
`README.md`'s per-plugin table under **Skills**, restate `marketplace.json`'s `skills` and `commands`
and nothing held those. `CLAUDE.md` states the rule — *"keep this list in sync with it"* — which is a
directive with no check behind it, one level down from the one the fifth check replaced. It compares
three sets per plugin on basenames, and reports per plugin and per direction so each message names
its own fix:

| Output | Meaning |
|---|---|
| `SKILLS DRIFT {plugin} claude` | The `**Skills:**` line disagrees with `marketplace.json` |
| `SKILLS DRIFT {plugin} readme` | The plugin's table under **Skills** disagrees with `marketplace.json` |
| `COMMANDS DRIFT {plugin} claude` | The `**Commands:**` line disagrees with `marketplace.json` |

There is no `COMMANDS DRIFT {plugin} readme`, because `README.md` lists commands as a flat usage
block under **Commands** rather than per plugin, so there is no per-plugin set for this check to
compare. The **ninth** check covers that block repo-wide instead, in both directions — see below.

Three properties of the two Markdown files are load-bearing here, all three recorded in advance by
#172 from what the fifth check cost to get right. The section extractor stops at the next heading of
**any** level, because `data-platform`'s table is the last one under **Skills** and an extractor that
stops only at `^### ` runs straight on into the configuration tables. `README.md` lists the shared setup skills as
``| `init` | Shared setup skill — see `dev` |`` under `planner` and `dispatcher`, and that is a row
like any other, so it compares equal. And `data-platform` has no `commands` key at all, so
`(.commands // [])` must yield an empty set that compares equal to an absent `**Commands:**` line.
All three are confirmed by observation rather than assumption: with the sets printed, every plugin
extracts a non-empty skill set from all three files.

The seventh check reads each skill's phase headings. Two properties, and the first is nearly free:
the distinct phase numbers must run `1..N` with no gap, and a skill that *states* a count in prose
must state the right one. Only `init` states one today — *"The seven phases run in order, every
time"* — and that sentence is not descriptive. It is the mechanism that stops an agent exiting
early, and it was **already wrong**, reading `five` against seven headings, for as long as `init`
had seven. An agent that finished Phase 5 had satisfied the contract exactly as written and could
stop before **Phase 6 — Reconcile the Config**, the phase that commits `.hivrr.json`, in the skill
that is bootstrap step 1 of every command in `dev`, `planner`, and `dispatcher`.

`merge-pr` has a `## Phase 2b`, deliberately. The check counts **distinct** numbers, so `2b` folds
into `2` and the skill ends up with one fewer contiguous phase than it has headings. Do not renumber
it to satisfy the check. A skill that states no count is not required to — `init` is the only one
that does, and the check is silent on every other skill.

**The heading match is anchored to a digit — `^## Phase [0-9]`, not `^## Phase` — and must stay that
way.** The `sed` after it only rewrites lines containing a number, so an unanchored match passes a
heading like `## Phase Contract` through whole, into the list of phase *numbers*, where it inflates
the count and reports a sequence failure against a file that has none. That heading is not
hypothetical: `skills/init/SKILL.md` opens with a bolded **"Phase contract"** paragraph, and promoting
it to a heading is an ordinary edit. A check that reports drift which does not exist gets switched
off, which costs more than never having written it.

The eighth check is the smallest and the most self-referential: it counts the `# ` comments at
column 0 **inside the fence above** and compares that against the number word before `checks:` in
`CLAUDE.md`. **One column-0 `# ` comment per check** is therefore the convention the block is
written to; comments *inside* a check are indented so they do not inflate the count. It counts
itself, which is correct — it is a check, and it lives in the block.

**It does not find the fence — it is handed it.** `.hivrr.json` `verify.test` already extracts this
block in order to run it, and it now exports that text as `HIVRR_VERIFY_BLOCK`, which is what the
check counts. So `n` is a property of the script that actually executed rather than a second reading
of `README.md` that might disagree with it, and there is exactly one extractor in the repo.

That boundary is the part worth getting right, and this check has had it wrong before. It once read
the *section* — `/^## Verification/ … v && /^## / { exit }`, everything up to the next heading —
which was a distinction without a difference while the fence was the only place column-0 `# ` lines
lived and the runnable form was a separate transcription anyway. Once the loader began executing the
fence, the fence became authoritative for what *runs* while a section-wide count read past it: a
line of prose beginning `# ` at column 0 anywhere in **Verification**, or a second fenced block added
here, would inflate `n` and report `CHECK COUNT DRIFT` against a `CLAUDE.md` that is correct. The fix
for a false drift report is to edit `CLAUDE.md` to match — at which point the count is wrong, the
check is green, and the next real drift is invisible. That is the failure this section warns about twice,
in the one check whose entire job is to make a number trustworthy.

**#184 closed that by copying the loader's `awk` here; #185 deleted the copy instead.** Two
extractors kept in step by eye is the same defect one level down — if they drifted, `n` would
quietly stop describing what runs and nothing would say so, which is precisely what #183 was filed
about. A twelfth check comparing the two programs was the obvious answer and was rejected: the two
cannot be byte-identical, since the loader escapes `\$0` for the double quotes it is forced into and
adds a `2>/dev/null` this copy did not want, so the comparison would need a normalization taught
which differences are permitted — a third thing to keep correct, guarding a duplication that did not
have to exist. Passing the block in removes the pair rather than policing it. The fence-building
`printf '\140\140\140'` went with it; only the loader needs one now, and only because a literal
backtick inside its double quotes would open a command substitution.

**The rule that `printf` carried outlives it: no check may put a fence-shaped token at column 0.**
The extractor stops at the first one it meets after the opening fence, so a stray three-backtick
line inside the block ends it there — and a cut between two checks can leave a script that is still
*valid*, runs the checks above it, and reports `structural checks pass`. Confirmed both ways on this
block: a fence inserted before the eighth check truncates it silently, while one inserted after
reports `CHECK COUNT DRIFT … README has 8`, because `n` counts what ran. So the eighth check covers
the tail of the block and nothing covers the head, which is the narrow gap that makes this an
authoring rule rather than a check. It is narrow because such a line closes the Markdown fence too,
leaving the rest of this section rendered as prose — visibly broken, not quietly. Build any fence a
check needs with `printf`, as the loader still does.

**The cost is that this one check needs the loader**, and it says so rather than guessing. Run the
fence on its own with nothing exported and `HIVRR_VERIFY_BLOCK` is unset, so the check reports
`CHECK COUNT UNCHECKED` instead of counting zero and drifting against it — the same rule #182
established for the JSON check: an extraction that comes back empty is a failure, never a match. Do
not answer that message by re-extracting from `README.md` as a fallback; the fallback *is* the copy
this check was built to do without. Run the checks the way `work-issue` and `work-pr` do, with
`eval "$(jq -r '.verify.test' .hivrr.json)"`.

**So `HIVRR_VERIFY_BLOCK` is part of the loader contract**, alongside the closed stdin documented at
the end of this section: the loader passes the block as an argument, closes its stdin, and exports
the same text under that name. A check may read the third the way it must respect the second.

It reads the number word with `w2n`, **the helper defined in the seventh check above** — which is
why #173 wanted the two done in one pass. Deleting or reordering the seventh breaks the eighth. That
fails loudly rather than silently, since `w2n: command not found` is caught by the `2>&1` and exits
non-zero, but do not move one without the other.

This replaced three hand-maintained counts, one of which was already wrong: `CLAUDE.md` read
*"All three commands are in the README"* when there were four, and had since the duplication check
was added. Nobody noticed, because nothing reads a number in prose. `README.md`'s two bare counts
were **reworded away** rather than checked — *"the checks in **Verification** below"* carries the
same meaning and cannot drift. `CLAUDE.md`'s count survives because it earns it: the sentence *names*
the checks, so adding one forces the sentence to describe it.

To re-run the three: remove a skill from a plugin in `marketplace.json`, delete a `README.md` table
row, delete an entry from a `**Skills:**` line, state the wrong phase count in `skills/init/SKILL.md`,
renumber a phase heading to leave a gap, and change the number word in `CLAUDE.md`. Each must produce
its own message.

The eighth check's boundary needs two cases of its own, and both are confirmations of **silence**:
add a column-0 `# ` prose line to **Verification** outside the fence, and add a second fenced block
to this section. Neither may change `n`, and a clean tree must still print `structural checks pass`.
Then confirm the check has not simply been switched off, by adding a check to the fence without
touching `CLAUDE.md` and seeing `CHECK COUNT DRIFT`. Two more cover the hand-off: extract the fence
and run it with `HIVRR_VERIFY_BLOCK` unset, which must report `CHECK COUNT UNCHECKED`, and drop the
`export` from `.hivrr.json`, which must report the same through the loader rather than passing.

The digit anchor needs a fixture, because no skill in the repo can currently trip it. Add a
`## Phase Contract` heading above the numbered ones in any `SKILL.md`, confirm the check stays
**silent**, then drop the `[0-9]` from the match and confirm it reports `PHASE SEQUENCE` naming that
heading as a phase number. Revert both.

The ninth check closes the gap the sixth left open. `README.md` documents commands as a flat usage
block under **Commands** — `/audit security --mode deep`, arguments and all — written to show each
command's *shape* rather than to inventory what ships. Restructuring it into per-plugin tables would
buy a symmetric `COMMANDS DRIFT {plugin} readme`, at the cost of the argument examples that are the
reason the block reads well. So the check takes the block as it is: it reads the first
whitespace-delimited token of every line starting with `/` and compares that set against every
`commands` entry in `marketplace.json`. The comparison is therefore **repo-wide, not per plugin** —
the block carries no plugin attribution, and inventing one would mean restructuring it after all.

It is **bidirectional**, which is a deliberate choice rather than the cheaper direction, and each
message names its own fix:

| Output | Meaning |
|---|---|
| `COMMAND UNDOCUMENTED {name}` | `marketplace.json` registers a command the usage block never shows |
| `COMMAND NOT REGISTERED {name}` | The usage block names a command that no longer ships |

`COMMAND NOT REGISTERED` is the direction #176 was filed for: a command removed from
`marketplace.json` leaves its example sitting in the README indefinitely, and the first three checks
cannot see it — they verify that registered commands *resolve to files*, never that the docs
describe the registered set. `COMMAND UNDOCUMENTED` is the stricter half, and demanding a usage
example for every command that ships is a stronger rule than "no example names a command that does
not ship". It was adopted because the repo already satisfied it — every registered command appears
in the block — so it costs nothing today and makes shipping an undocumented command fail rather than
pass quietly.

Two properties of the block are load-bearing. The extractor starts at `## Commands` and stops at the
next heading of **any** level, because the fence is the whole content of that section rather than
one item inside it. And it takes the **leading token only**, so `/write-plan "add SSE to insight"`
yields `write-plan`; comparing whole lines would report drift every time an example's arguments were
reworded.

The tenth check is the seventh one file over. The seventh holds `skills/init/SKILL.md`'s own stated
phase count against its own headings — but `init` states that count in `CLAUDE.md` as well, and
`CLAUDE.md` is loaded verbatim as project instructions for every session in this repo. A count that
reads low *there* tells an agent the run is over before it is, which is the failure #170 was about,
in the file with the widest blast radius. So the tenth reads the number word before `ordered phases`
in `CLAUDE.md` and compares it against the distinct `## Phase N` headings in `skills/init/SKILL.md`,
reusing `w2n` from the seventh — so the same warning applies: do not move one without the other.

It checks the **count, not the list**. `CLAUDE.md` names the seven phases in order, and comparing a
comma-separated prose list against seven `## Phase N — Title` headings needs a normalization nobody
will trust — the heading reads ``## Phase 3 — Scaffold `.hivrr.json` `` while the prose reads
``.hivrr.json scaffold``. A check that reports drift which does not exist gets switched off, which
costs more than never having written it. Deleting the sentence does not disable the check: an absent
number word yields `0` from `w2n`, `0` never matches, and the failure reports as
`INIT PHASE COUNT DRIFT CLAUDE.md says , …` with the number missing.

**`README.md`'s `init` row needs no equivalent**, which is worth stating rather than leaving as a
silent asymmetry. That row enumerates the same phases — *"provider config, repo labels,
`.hivrr.json` scaffold, …"* — but states no count, so it carries no bare number to drift. Do not add
one for symmetry with `CLAUDE.md`; the enumeration is the useful part and the number in front of it
is what drifts.

The same reasoning cleared the last two counts in `README.md` that named something in another file
— **a different pair from the check counts above**, and the ones #175 was filed for. The overview
read *"split into **five** focused packages"*, counting `marketplace.json`'s plugins, and the fifth
check's message table was introduced as *"It reports **five** distinct failures"*, counting rows of
that table; both now read without a number. Neither sentence *named* what it counted, which is the
test `CLAUDE.md`'s surviving count passes and these two did not — so rewording was the right answer
rather than two more checks, and the table or list each one introduces still tells a reader
everything the number did.

**That is the line worth drawing, and it is narrower than "no counts in prose".** A count whose
subject lives in another file — plugins in `marketplace.json`, phases in a `SKILL.md`, checks in
this block — can go stale without anything moving nearby, so it is either checked or reworded away.
A count of items in its own paragraph cannot: *"Two properties of the block are load-bearing"* above
two sentences, or *"Three properties of the two Markdown files"* above three, drifts only if
somebody edits the list it introduces while looking straight at it. Those are deliberately left
alone. Apply the same test to a count you are about to add — if you have to open another file to
confirm it, it needs a check or a rewrite.

To re-run the two: rename a command in the usage block, remove one from `marketplace.json`,
register one in `marketplace.json` with no example in the block, state the wrong number before
`ordered phases` in `CLAUDE.md`, capitalize that number, and delete it entirely. Each must produce
its own message, and a clean tree must still print `structural checks pass`. The rename emits both
command messages at once, so the third case is what exercises `COMMAND UNDOCUMENTED` on its own
terms; the capitalized case is what proves the number word is read case-insensitively, which the
first draft of this check got wrong.

The eleventh check reads the `## Overview` table — the plugin list a new reader meets before any
other. The fifth check compares `marketplace.json` descriptions against `CLAUDE.md`; the sixth
compares skill and command *lists* against the per-plugin tables under **Skills**, which are a
different set of tables further down this file. The `## Overview` section has no `` ### `plugin` ``
headings at all, so the sixth check's extractor never enters it, and nothing read that table. A
plugin could be added to `marketplace.json` and never appear there, or removed and linger
indefinitely — the defect `DESC NO PLUGIN` catches for `CLAUDE.md`, in the file installed users read
first.

| Output | Meaning |
|---|---|
| `PLUGIN UNDOCUMENTED {name}` | `marketplace.json` registers a plugin the Overview table never lists |
| `PLUGIN NOT REGISTERED {name}` | The Overview table names a plugin that no longer ships |

**It compares names, and nothing else.** The Purpose column is a paraphrase written for someone
skimming — `dev` reads *"issues, PRs, waves, merges, and promotions"* against the
`marketplace.json` *"…and environment promotions"* that `CLAUDE.md` repeats verbatim — and that is
the reason a short overview table earns its place beside the reference text. Making the two verbatim
would add a third copy to keep in step and delete the difference that justifies the table. The sixth
check made the same call for skill lists, comparing basenames and leaving descriptions alone.

Three properties of the table are load-bearing, the first two borrowed rather than invented. The
extractor anchors on `## Overview` and stops at the next heading of **any** level, the way the sixth
check does — this file has several pipe tables and only one of them is this one. It reuses the sixth
check's `rd_s` extraction verbatim, `` s/^| *`\([^`]*\)` *|.*/\1/p ``, which takes a backticked
first column and so ignores the header row, the separator row, and the bulleted prose above the
table, none of which match. And **the plugin table must stay the only backticked-first-column table
under `## Overview`**, because the extractor takes every such row in the section rather than that one
table: a second table of that shape added here would turn each of its rows into a phantom plugin name
and report `PLUGIN NOT REGISTERED` for it. Add one at a heading of its own, or anchor the extraction
more narrowly first.

**Deleting the table would also have closed this**, and it was weighed: `## Overview` and the
per-plugin sections under **Skills** list the same plugins, so a reader gets the set twice, and #175
preferred deletion to a check for the bare count that used to sit above it. The table survives
because it is the first thing in the file and gives the one-line orientation the **Skills** sections
do not — it earns its place in a way that count did not.

To re-run it: delete a row from the Overview table, and add a row for a plugin `marketplace.json`
does not list. Each must produce its own message.

**Extracting does not always mean a new reference file.** The blanket-staging prohibition was
allowlisted and then extracted to the **Git Safety** section of `skills/core/SKILL.md`, because every
`dev` command already loads `core` as its third bootstrap step. A rule that lands there costs no new
file and no new indirection — the destination is already in context when the skill runs. Prefer it
over `skills/*/references/` for anything that is a *policy* rather than a *procedure*, and note that
it is only reachable from plugins that ship `core` — which today is `dev` alone.

`skills/planning/references/plan-writing.md` and `skills/init/SKILL.md` therefore state the staging
rule in their own words. For `plan-writing.md` the reason is that `planner` does not ship `core`.
For `init` it is the same reason and it is stronger, because `init` ships in `dev`, `planner`, and
`dispatcher`, and the last two of those do not carry `core`. **Load order is not what keeps that copy
inline.** A plugin install contains only the skills its `marketplace.json` entry names, so
reordering the bootstrap to load `core` before `init` would still leave `../core/SKILL.md`
unresolvable in two installs out of three. Do not "fix" either copy into a link; the way to remove
one is to add `./skills/core` to the plugin that needs it — and, if the rule has to be *in context*
rather than merely reachable, to load it before the skill that cites it. Packaging is what makes the
link resolve; bootstrap order is what makes it free.

Where those inline copies point at other skills, keep the reference **phase-agnostic** — "the commit
phases of `work-issue` and `work-pr`", not "Phase 10 and Phase 9". The seventh check reads a skill's
count of its *own* phases; it cannot read a citation of someone else's, and no check reads prose. A
skill that gains or loses a phase still leaves every cross-skill citation of it silently wrong, which
is why #169 removed the last two rather than renumbering them.

**`.hivrr.json` `verify.test` runs the checks above by executing them.** It is a loader, not a
copy: it `cd`s to the repo root, confirms the files the checks read are present, extracts the first
fenced block under **Verification** with `awk`, exports it as `HIVRR_VERIFY_BLOCK` for the eighth
check to count, runs it as `bash -c "$HIVRR_VERIFY_BLOCK" </dev/null`, prints only findings, and
exits non-zero when there are any — which is what makes `work-issue` and `work-pr` report
`tests pass` here instead of `tests skipped`. **So adding or changing a check above needs no second
edit.** That is the point: the two forms cannot drift, because there is only one.

**The block is passed as an argument and run with stdin closed, and both halves are load-bearing.**
Piping it in instead — `printf "%s\n" "$HIVRR_VERIFY_BLOCK" | bash` — makes the script its own
child's stdin, so any check that reads stdin consumes the *rest of the block*: every check after it
is skipped, emits nothing, and the run reports `structural checks pass`. That was reachable from the
block as written, not only from a future one — `jq empty $(git ls-files '*.json')` degenerated to a
bare `jq empty` if the glob ever matched nothing, and a bare `jq empty` reads stdin. The first check
now names that case explicitly instead, so no command in the block reads stdin today; the rule
stands anyway,
because the next check added could. Passing the block as an argument without also closing stdin
trades the silent skip for a hang, because the same command then blocks on the caller's terminal.
So: **a check may not depend on stdin.** With `</dev/null` one that tries gets EOF immediately and
the checks after it still run, which is the only behaviour compatible with the promise this section
makes.

Anything reading `verify.test` expecting to *see* the checks will not find them there any more —
it holds the extractor. The checks are here.

**The extractor is anchored, and losing the anchor fails loudly.** It starts at the `## Verification`
heading, takes the **first** fenced block it then meets, and stops at that block's closing fence — so
a second fenced example added later in this section is not swallowed, and a fence earlier in the file
is never reached. If the heading is renamed or the fence deleted, the extraction comes back empty and
the loader reports `NO VERIFY BLOCK` and exits non-zero rather than passing on nothing, which is the
one failure mode that could otherwise turn verification into a silent no-op. Rename the heading and
the extractor in `.hivrr.json` is the only thing you have to update — the eighth check reads what it
extracted rather than repeating its anchor, so there is no second copy to remember.

To re-run it: rename a message in the block and confirm the tool emits the new name, add a line to
the block and confirm it runs, then rename `## Verification`, delete the fence, and move `README.md`
aside — each of those three must report `NO VERIFY BLOCK` and exit non-zero, the last one alongside
`MISSING INPUT README.md`. Renaming the heading to something that still *starts* with
`## Verification` is not one of the cases: the anchor is a prefix match, so the block is still found
and still runs.

**The duplication check covers one pair, deliberately.** Other same-named skills share lines over
the same threshold today — `planning` and `brainstorm` share the session-UUID bootstrap and its fallback
warning, `score-issues` and `group-issues` share their `excluded` contract. Widening the check to
every pair needs a **per-pair** allowlist first, because some of that sharing is required rather
than accidental: the `excluded` contract paragraphs are specified to be byte-identical, so a
repo-wide check with one shared allowlist would report a mandated duplication as a defect. Treat
the uncovered pairs as known and unguarded, not as verified.

## License

MIT

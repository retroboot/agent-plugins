# Branch Ladder, GitHub Projects, MCP Teardown, and Script Removal — Implementation Plan

> **For agentic workers:** Use the `work-issue` skill to implement this plan issue-by-issue.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the plugin off its global/MCP-era assumptions and onto per-repo configuration — a dev/staging/main branch ladder, GitHub Projects integration, a CLI-only provider path — and replace the bash-script layer with explicit skill steps the model actually executes.

**Architecture:** A committed `.hivrr.json` becomes the single source of per-repo truth. The MCP probe layer is removed and CLI becomes unconditional. All four bash scripts are deleted; their logic moves into skill steps as individual `gh`/`git` commands with visible output. Safety guards move *into the steps*, because steps are what run.

**Tech Stack:** Markdown skill definitions, `gh` CLI including `gh project` and `gh api graphql`, `git`, `jq`, `python3` (config read/write only).

---

## Context: why now

Five pressures landed at once:

1. The MCP/hub abstraction (PRs #87–#101) added a probe-and-route layer that is never exercised — `.mcp.json` is empty and no hub server is configured.
2. `hivrr-merge.sh` deletes the head branch unconditionally, which is safe only while every PR is `issue/N → main`.
3. The team is moving to `dev → staging → main`, which nothing in the plugin models.
4. Work is tracked on GitHub Projects, which nothing in the plugin reads or writes.
5. **The model no longer runs the bash scripts.** It reads them and executes its own commands instead. Any logic living only in a script — including safety guards — is dead code.

Fixed decisions (do not re-litigate):

| ID | Decision |
|----|----------|
| **A** | Per-repo config lives in a committed `.hivrr.json`. Replaces global `providerConfig` for per-repo facts. |
| **B** | Strip probing only. Keep `session` and the provider references. Delete `hub.md`. Keep `init` Phase 2 (labels). |
| **C** | `issue/N → dev` squashes and deletes the head. `dev → staging → main` uses merge commits and never deletes the head. |
| **D** | Output is GitHub issues on `hivrr/agent-plugins`. |
| **E** | **Remove all four bash scripts. Skills carry explicit steps instead.** |
| **F** | Verification: `init` detects and records the project's test/lint commands; the model runs them and reports real output. `init` re-validates when the toolchain changes. |
| **G** | Closing linked issues is **required behavior**, not a safety net — see "Closing keywords stop working" below. |
| **H** | `merge-pr` prunes *all* stale local merged branches, not only the head of the PR it just merged. |

---

## Why the scripts are being bypassed

This was diagnosed empirically, not assumed. It is the finding that reshaped the plan.

### `hivrr-merge.sh` has no working non-interactive path

`:216` is an interactive confirm inside a script running under `set -euo pipefail`. Reproduced:

| stdin | Behavior |
|---|---|
| closed (agent / container) | `read` returns non-zero at EOF → `set -e` aborts → **exit 1, no error output** |
| piped or empty | `CONFIRM` empty → `*)` branch → **prints `Aborted.`, exit 0, nothing merged** |

`merge-pr/SKILL.md:44` instructs: *"If the script exits non-zero: surface the error output and stop."* There is no error output to surface. So without `--auto` the merge either dies mutely or silently no-ops while signalling success. **Bypassing it is the only way to complete the task.**

Compounding: 354 lines that merge PRs, delete local and remote branches, and close issues. Reading that before executing is correct agent behavior, not a defect. A script that *must* be read before running has already lost the value of being a script.

### `hivrr-verify.sh` loses to the model at its own job

| Line | Defect |
|---|---|
| `:31` | Classifies `*.json`/`*.yaml`/`*.yml`/`*.toml` as docs → editing `marketplace.json` or a CI workflow **skips tests entirely** |
| `:51` | `npm test --silent 2>&1` inside an `if` — failure output is captured and discarded; the model gets a bare exit code (open #59) |
| `:104` | Matches only legacy `.eslintrc*` — a repo on `eslint.config.js` silently reports `lint skipped` (open #60) |
| whole | Heuristic toolchain sniffing across 4 test runners and 4 linters — the model determines this more accurately by reading the repo |

### `hivrr-branch-setup.sh` (45 lines) and `hivrr-pr-checkout.sh` (39 lines)

Flag parsing and dirty-tree warnings wrapped around two or three `git` commands. The indirection costs a file read and a permission prompt and buys nothing.

---

## Closing keywords stop working the day integration moves to `dev`

GitHub honors `Closes #N` / `Fixes #N` **only when the PR merges into the repository's default branch.** This repo's default is `main`. The moment `branches.integration` becomes `dev`, every feature PR merges into a non-default branch and **no issue auto-closes, ever**.

The existing manual close loop (`hivrr-merge.sh:254-311`) — which polls each linked issue up to 5 times and closes any still open — is therefore not redundant cleanup. Under the ladder it is the **only** mechanism that closes issues. It must survive the rewrite intact and must not be optimized away as "GitHub already does this."

Where it *is* correctly skipped: promotion PRs. A `dev → staging` PR body aggregates every `Closes #N` from the commits beneath it, but those issues were already closed at their `issue/N → dev` merge. Re-polling them costs five `gh issue view` calls each with up to 5 retries and 2s sleeps to confirm what is already true.

## Local branches are never pruned

`hivrr-merge.sh:323-330` deletes only `BRANCH_NAME` — the head of the PR being merged. Nothing ever cleans up branches left behind by PRs merged elsewhere, by `--auto` runs, or by work abandoned mid-flight.

Ancestry-based cleanup does not find them either, because the repo squash-merges: the squashed commit on `main` is not a descendant of the branch tip, so `git branch --merged main` reports nothing. Verified in this repo right now — `feat/hub-per-call-provider-routing` and `feat/multi-provider-support` are both still local despite PRs #94 and #84 having merged months ago.

The reliable signal is a deleted upstream, not ancestry:

```bash
git fetch --prune
git branch -vv | grep ': gone]'
```

`merge-pr` must prune these as a normal end-of-merge step, excluding anything in the protected set.

### The policy this establishes

A script earns its place only when it is **read-only or trivially reversible**, **non-interactive**, **single-purpose**, and performs **deterministic computation the model cannot reliably do in prose**. Destructive multi-step orchestration fails the first test. Heuristic environment detection fails the last. Neither surviving script qualifies.

Corollary, and the reason this reordered the plan: **safety guards must live in skill steps, not scripts.** A protected-branch check inside `hivrr-merge.sh` protects nothing if the model runs `gh pr merge --delete-branch` directly.

---

## Allowed APIs / verified anchors

Every path and line number verified against the working tree at `a750360`.

```
Scripts to delete (609 lines total)
- skill/merge-pr/scripts/hivrr-merge.sh              — 354 lines, 8 phases
- scripts/hivrr-verify.sh                            — 171 lines
- skill/work-issue/scripts/hivrr-branch-setup.sh     —  45 lines
- skill/work-pr/scripts/hivrr-pr-checkout.sh         —  39 lines

Call sites that must be rewritten as steps
- merge-pr/SKILL.md:34-56    — Phase 2, invokes hivrr-merge.sh, parses HIVRR_MERGE_SUMMARY
- work-issue/SKILL.md:101    — invokes hivrr-branch-setup.sh
- work-issue/SKILL.md:145-160 — Phase 8 Verify, invokes hivrr-verify.sh
- work-pr/SKILL.md:77        — invokes hivrr-pr-checkout.sh
- work-pr/SKILL.md:120-130   — Verify, invokes hivrr-verify.sh

Logic to preserve when merge-pr becomes steps (from hivrr-merge.sh)
- :90-104   fetch PR JSON: title, body, headRefName, state, baseRefName, reviews
- :123-131  extract linked issues — grep -oiE '(closes?|fixes?|resolves?)\s+(#[0-9]+|[A-Z]+-[0-9]+)'
- :167-193  CI check via gh pr checks, excluding claude-review from the failure filter
- :228-248  merge, currently hardcoded --squash --delete-branch
- :254-311  close linked issues, 5 polls x 2s — REQUIRED, sole close mechanism under the ladder
- :316-319  checkout base and pull; "Main: updated" hardcodes the word Main
- :321-345  DELETE LOCAL + REMOTE BRANCH — unguarded, the P0 defect
- :323-330  deletes ONLY this PR's head; no pruning of accumulated stale branches
- :350-352  HIVRR_MERGE_SUMMARY line, consumed by merge-pr/SKILL.md:48

Verified live in this repo
- default branch is `main` -> closing keywords will not fire once integration is `dev`
- feat/hub-per-call-provider-routing, feat/multi-provider-support — local, upstream [gone],
  invisible to `git branch --merged main` because PRs #94 and #84 were squash-merged

Config surface
- ~/.claude/settings.json providerConfig  — skill/init/SKILL.md:17-21
- providerConfig.bootstrappedRepos        — skill/init/SKILL.md:96-106
- .hivrr.json                             — NEW

Session layer
- Phase 2 "Probe MCP"                     — skill/session/SKILL.md:29-41
- Phase 3 conditional reference load      — skill/session/SKILL.md:45-60
- SESSION emit line                       — skill/session/SKILL.md:64-66
- hub.md (100% MCP, zero CLI lines)       — skill/session/references/hub.md:1-147
- MCP:/CLI: paired blocks                 — skill/session/references/github.md:11-86

Direct hub MCP callers (no CLI equivalent exists)
- mcp__hub__hub__score_issues             — skill/score-issues/SKILL.md:29
- mcp__hub__hub__group_issues             — skill/group-issues/SKILL.md:31
- mcp__hub__hub__diagnose_failure         — skill/diagnose-failure/SKILL.md:43

Ladder surface
- git checkout -b issue/N, no base        — hivrr-branch-setup.sh:34-46
- Create PR with no --base                — skill/work-issue/SKILL.md:203-211
- "Never work on main/master directly"    — skill/core/SKILL.md:27, :31
- git log origin/main..HEAD               — skill/wave/SKILL.md:55

Docs drift
- 3-plugin layout (obsolete)              — CLAUDE.md:7-28, README.md:13-19
- marketplace.json ships 5 plugins        — .claude-plugin/marketplace.json:9-100
- command/wave.md                         — MISSING (skill registered, no slash command)

Conventions
- Skills reference commands indirectly: "use the **X** command from the loaded reference"
- Commands run init -> session -> core as a bootstrap preamble
- Skills emit a structured completion JSON defined at the command layer
```

---

## Blueprint

**Steps:** 7 | **Parallel:** Steps 1, 2, and 3 are mutually independent after Step 0

```
Step 0 (P0 guard, ships today) ──> Step 2 (scripts -> steps) ──┬──> Step 4 (ladder) ──> Step 6
                                                                │
Step 1 (.hivrr.json) ───────────────────────────────────────────┤
                                                                │
Step 3 (MCP teardown) ──────────────────────────> Step 5 (Projects)
```

---

### Step 0: Protected-branch guard, as a skill step

**Issue 1** · **Size:** XS · **Priority:** P0 · **Depends on:** — · **Branch:** `fix/merge-protected-branch-guard`

**Context brief:** The danger is live *right now*, and not where it first appeared. Because the model bypasses `hivrr-merge.sh` and issues `gh pr merge` itself, the unguarded deletion at `:321-345` is not the only exposure — the model's own merge command carries `--delete-branch` too. The guard must therefore land in `merge-pr/SKILL.md` as an instruction, where it governs whatever the model actually runs.

This is deliberately decoupled from `.hivrr.json` (Step 1) and from the full rewrite (Step 2) so it can ship in an hour. It uses a hardcoded protected set now; Issue 8 swaps in config later.

**Exit criteria:** `merge-pr` refuses to delete a branch named `main`, `master`, `dev`, `develop`, `staging`, or `release/*`, and says so in its output.

**Tasks:**
- [ ] Add a "Branch deletion safety" section to `merge-pr/SKILL.md` stating the rule before any merge step
- [ ] Rule 1: never delete a head branch in `{main, master, dev, develop, staging, release/*}`
- [ ] Rule 2: never delete a branch equal to the PR's base branch
- [ ] Rule 3: before deleting, confirm no open PR targets that branch —
      `gh pr list --repo {repo} --base {branch} --state open --json number --jq 'length'`
- [ ] Instruct: when any rule trips, merge **without** `--delete-branch` and report `branch_deleted: none`
- [ ] State that the rule binds whether the merge runs via script or direct `gh` command

**Verification:**
```bash
gh pr list --repo hivrr/agent-plugins --base main --state open --json number --jq 'length'
# Expected: an integer; non-zero means "main is an integration target, never delete it"
```

---

### Step 1: `.hivrr.json` — the per-repo config keystone

**Issue 2** · **Size:** M · **Priority:** P1 · **Depends on:** — · **Branch:** `feat/hivrr-json-config`

**Context brief:** Every later step needs the branch ladder or the Project IDs. The only config today is global `~/.claude/settings.json` `providerConfig` (`skill/init/SKILL.md:17-21`), which is wrong for facts that vary per repo — demonstrated live during this planning session: the global config says `repoProvider: gitlab` while operating on a GitHub repo, so `init` skipped label bootstrap and `session` loaded `gitlab.md`.

`.hivrr.json` is committed, so it travels with the code and every teammate and CI runner resolves identically. Global `providerConfig` survives for user-shaped values (`gitlabGroup`, `bootstrappedRepos`).

Per Decision E there is **no loader script**. The contract is a documented file the model reads with the Read tool, plus a documented precedence rule the skills follow.

**Schema:**
```json
{
  "provider": "github",
  "branches": {
    "integration": "dev",
    "ladder": ["dev", "staging", "main"],
    "protected": ["dev", "staging", "main"]
  },
  "project": {
    "owner": "hivrr",
    "number": 1,
    "statusFieldId": "PVTSSF_xxx",
    "status": { "todo": "<option id>", "inProgress": "<option id>", "done": "<option id>" }
  },
  "verify": {
    "test": "npm test",
    "lint": "npx eslint .",
    "detectedFrom": ["package.json:scripts.test", "eslint.config.js"]
  }
}
```

`verify.detectedFrom` records *which files justified each command*. That is what makes staleness detectable: if `init` recorded `npx eslint .` because `.eslintrc.json` existed, and the repo has since migrated to `eslint.config.js`, the fingerprint no longer matches and `init` re-detects. Without it we would reproduce `hivrr-verify.sh`'s bug (#60) in config form — a stale command silently reporting `skipped`.

Absent-file behavior must be a clean degrade, not an error — this is what keeps the plugin working in repos that never adopt it:

| Key | Fallback when absent |
|---|---|
| `branches.integration` | repo default branch via `gh repo view --json defaultBranchRef` |
| `branches.ladder` | `[default branch]` — single rung, promotion no-ops |
| `branches.protected` | Step 0's hardcoded set |
| `project` | null — every board operation becomes a silent no-op |
| `verify` | model detects test/lint commands at run time and offers to record them |

Resolves open issue #88 (guard for missing config) as a documented precedence rule rather than a code guard.

**Exit criteria:** A skill can state the integration branch for any repo, with or without `.hivrr.json`, using only documented steps.

**Tasks:**
- [ ] Create `skill/init/references/config.md` — every field, type, default, and which skills consume it
- [ ] Document precedence explicitly: `.hivrr.json` → global `providerConfig` → hardcoded default, resolved **per key**, not per file
- [ ] Document the read steps: `test -f .hivrr.json`, Read it, `jq empty` to validate, fall back per key
- [ ] Distinguish the two failure modes: malformed JSON is a hard error; a missing file is normal
- [ ] Add `init` Phase 3: offer to scaffold `.hivrr.json` from detected repo state; never overwrite an existing file
- [ ] Commit a `.hivrr.json` for this repo (`integration: main`, `ladder: ["main"]` — this repo is not on the ladder)

**Verification:**
```bash
jq empty .hivrr.json && echo "valid"
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name   # the documented fallback
cd "$(mktemp -d)" && git init -q && test -f .hivrr.json || echo "absent -> use defaults, not an error"
```

---

### Step 2: Scripts → steps

**Issues 4, 5, 6** · **Depends on:** Step 0 · **Branches:** `refactor/merge-pr-steps`, `refactor/verify-steps`, `refactor/inline-git-steps`

**Context brief:** Delete all 609 lines of bash and move the logic into skill steps. The success criterion is not "the steps exist" but **"the model runs them without needing to read a file first"** — every step is a single command whose effect is legible from the command itself.

**Issue 4 — `merge-pr` (L, P1).** The largest piece: eight script phases become skill phases. Two contracts change deliberately:

- *The confirm.* `read -rp` becomes a genuine user checkpoint in the skill — the model presents the merge summary and waits. This is the thing bash could not do correctly in a non-TTY, and it is native to a skill.
- *The summary line.* `HIVRR_MERGE_SUMMARY` (`:350`) exists only so a skill can parse a script's output. With no script, the model builds the completion JSON from the results it observed. Deleting this contract closes #86 (`branch_deleted` reporting a stale name) by removing the field that could go stale.

Three behaviors must survive, and two of them are easy to lose because they look like redundant cleanup:

- **Closing linked issues is required, not optional** (Decision G). Under the ladder, GitHub's closing keywords never fire — see "Closing keywords stop working" above. This loop is the only thing that closes issues. Preserve the poll-then-close pattern; skip it only on promotion PRs.
- **Prune stale local branches** (Decision H). Beyond the head of this PR, prune every local branch whose upstream is gone, excluding protected ones. Squash merges make ancestry checks useless here.
- **Small details:** the CI filter excludes `claude-review` from failure detection (`:186`), and linked-issue extraction accepts both `#123` and Linear-style `ENG-123` (`:127`).

**Issue 5 — verification, detected at `init` (M, P1).** Per Decision F this splits across two moments. `init` detects the project's test and lint commands **once** and records them in `.hivrr.json.verify` together with the fingerprint of files that justified them. `work-issue` and `work-pr` then read those commands, run them, and report real output.

The staleness problem is the whole point, and why this cannot be a one-shot write. `init` currently *"skips immediately if already configured"* (`skill/init/SKILL.md:10`) — apply that to `verify` unchanged and a repo migrating `.eslintrc.json → eslint.config.js`, or adding pytest to a JS repo, keeps running a command that no longer matches the toolchain. That is exactly bug #60 relocated from bash into JSON.

So `init` must **re-validate, not just skip**: compare the current `detectedFrom` fingerprint against the repo; on mismatch, re-detect and rewrite. Cheap — a handful of `test -f` checks — and it runs on every command's bootstrap anyway.

This closes **#59, #60, and #61** by construction. Two rules carry over as hard requirements:

- **Show real failure output.** Never a bare exit code. `hivrr-verify.sh:51` captured failures into an `if` condition and discarded them; that was its worst behavior.
- **Judge docs-only by behavior, not extension.** `:31` treated `*.json`/`*.yaml` as docs, so editing `marketplace.json` or a CI workflow skipped tests. In *this* repo, JSON and Markdown *are* the product.

**Issue 6 — the two small scripts (S, P2).** `git fetch` + `git checkout -b` inline in `work-issue`; `git checkout` + `git pull` inline in `work-pr`. Keep the dirty-tree warning as an instruction.

**Exit criteria:** No `.sh` files remain in the repo. `merge-pr`, `work-issue`, and `work-pr` complete end-to-end with the model running each command directly.

**Tasks (4):**
- [ ] Rewrite `merge-pr/SKILL.md` Phase 2 (:34-56) as discrete phases, one command each
- [ ] Fetch PR: `gh pr view {N} --repo {R} --json title,body,headRefName,state,baseRefName,reviews`
- [ ] Handle already-merged and closed-not-merged states before anything else
- [ ] Extract linked issues from the body, supporting `#123` and `ENG-123`
- [ ] CI check via `gh pr checks`, excluding `claude-review` from the failure filter
- [ ] Present the merge summary and **wait for user confirmation** unless `--auto`
- [ ] Merge, applying Step 0's deletion guard
- [ ] **Close linked issues** — poll each, close any still open. State in the skill *why* this is mandatory: closing keywords do not fire on merges to a non-default branch
- [ ] Checkout the **base** branch and pull, reporting its actual name (kills the "Main: updated" bug)
- [ ] **Prune stale local branches:** `git fetch --prune`, then delete every branch listed by `git branch -vv | grep ': gone]'` that is not in the protected set
- [ ] Report pruned branches explicitly so the cleanup is visible, not silent
- [ ] Build the completion JSON from observed results; drop `HIVRR_MERGE_SUMMARY` entirely
- [ ] `git rm skill/merge-pr/scripts/hivrr-merge.sh`

**Tasks (5):**
- [ ] Add `init` Phase 4 — detect test and lint commands from `package.json` scripts, `Makefile`, `pyproject.toml`, CI workflows, and lint config files
- [ ] Record `verify.test`, `verify.lint`, and `verify.detectedFrom` (the files that justified each) in `.hivrr.json`
- [ ] **Re-validate on every run:** compare `detectedFrom` against the current repo; on mismatch re-detect and rewrite, reporting `INIT: verify commands updated ({old} → {new})`
- [ ] Do **not** apply init's blanket "skip if configured" rule to `verify` — that is how #60 comes back
- [ ] Ask the user to confirm on first detection and whenever re-detection changes a command
- [ ] Replace `work-issue/SKILL.md:145-160` and `work-pr/SKILL.md:120-130` with: read `verify` from config, run each command, show real output
- [ ] Fall back to model detection when `verify` is absent, and offer to record the result
- [ ] Require real output on failure — never a bare exit code
- [ ] Docs-only skip: judge by whether changed files affect behavior, **not** by extension
- [ ] `git rm scripts/hivrr-verify.sh` and remove the now-empty root `scripts/`
- [ ] Note in the issue body that this closes #59, #60, #61

**Tasks (6):**
- [ ] Inline `git fetch origin {base}` + `git checkout -b issue/{N} origin/{base}` in `work-issue`
- [ ] Inline `git checkout {branch}` + `git pull origin {branch}` in `work-pr`
- [ ] Preserve the dirty-tree warning as an instruction, not a guard
- [ ] `git rm` both scripts and their `scripts/` directories

**Verification:**
```bash
find . -name '*.sh' -not -path './.git/*'          # Expected: no output
grep -rn 'CLAUDE_SKILL_DIR/scripts\|CLAUDE_PLUGIN_ROOT/scripts' skill/   # Expected: no matches
grep -rn 'HIVRR_MERGE_SUMMARY' skill/ command/     # Expected: no matches
grep -rn 'claude.review\|claude-review' skill/merge-pr/SKILL.md  # Expected: CI filter preserved

# Issue closing and branch pruning must both be present in the rewritten skill
grep -c 'close' skill/merge-pr/SKILL.md            # Expected: non-zero
git fetch --prune && git branch -vv | grep ': gone]' || echo "no stale branches — pruning works"
# Expected after a merge run: feat/hub-per-call-provider-routing and
#   feat/multi-provider-support are gone; main/dev/staging untouched
```

---

### Step 3: MCP teardown

**Issues 3, 7** · **Depends on:** — · **Branches:** `refactor/session-drop-mcp-probe`, `refactor/dispatcher-drop-hub-mcp`

**Context brief:** Per Decision B this is a strip, not a demolition. `session` survives as a thin loader; the provider references survive minus their `MCP:` lines; `hub.md` is deleted because it is 100% MCP with zero CLI content.

The hard part is Issue 7. Three skills call hub MCP tools with **no CLI equivalent**, because they were never API wrappers — they are LLM operations hub ran server-side:

| Caller | Tool | Replacement |
|---|---|---|
| `score-issues/SKILL.md:29` | `score_issues` | Skill scores inline against its own rubric |
| `group-issues/SKILL.md:31` | `group_issues` | Skill groups inline by dependency and file overlap |
| `diagnose-failure/SKILL.md:43` | `diagnose_failure` | Skill reads logs and diagnoses inline |

Each skill absorbs reasoning it was delegating, while keeping its documented JSON output — **the output shape is the compatibility boundary**, so no downstream consumer changes.

**Exit criteria:** `grep -r 'mcp__' skill/` returns nothing. All three dispatcher skills emit their documented JSON with no MCP tool.

**Tasks (3):**
- [ ] Delete `session/SKILL.md` Phase 2 (:29-41) entirely
- [ ] Rewrite Phase 3 (:45-60) to unconditionally read `{REPO_PROVIDER}.md`, plus `{ISSUE_TRACKER}.md` when it differs
- [ ] Reduce the SESSION emit line to `provider={REPO_PROVIDER} tracker={ISSUE_TRACKER}`
- [ ] `git rm skill/session/references/hub.md`
- [ ] Strip `MCP:` lines from `github.md`, `gitlab.md`, `linear.md`; drop the stale preamble at `github.md:3`
- [ ] Discard the uncommitted `pr_id`/`issue_id` working-tree change — it edits files this step deletes

**Tasks (7):**
- [ ] `score-issues:29` → inline rubric, same JSON shape
- [ ] `group-issues:31` → inline grouping, same JSON shape
- [ ] `diagnose-failure:43` → inline log analysis producing `{root_cause, suggestion, recoverable}`
- [ ] Verify each command-layer output contract is unchanged

**Verification:**
```bash
grep -rn 'mcp__' skill/ command/ ; echo "exit=$?"        # Expected: exit=1
test ! -f skill/session/references/hub.md && echo "hub.md gone"
grep -rn 'hub_mcp\|repo_mcp\|issues_mcp' skill/          # Expected: no matches
```

---

### Step 4: The dev/staging/main ladder

**Issues 8, 9, 10, 11** · **Depends on:** Steps 1, 2

**Context brief:** Four hardcoded assumptions that `main` is both the branch point and the merge target. Sequenced after Step 2 so the ladder logic is written into steps once, rather than into scripts and then rewritten.

**Issue 8 — ladder-aware merge strategy (M, P1, closes #85).** Per Decision C:

| Head → Base | Strategy | Delete head? | Close issues? |
|---|---|---|---|
| `issue/N` → `dev` | squash | yes | yes |
| `dev` → `staging` | merge commit | **no** | no |
| `staging` → `main` | merge commit | **no** | no |

A promotion is detectable without new flags: **both** head and base appear in `branches.ladder`. One predicate drives strategy, deletion, and issue-closing.

The issue-closing skip matters more than it looks. A promotion PR body aggregates every `Closes #N` from the commits beneath it, so on `dev → staging` the old flow re-polls issues already closed at the dev merge — five `gh issue view` calls, each up to 5 retries with 2s sleeps, to confirm what is already true.

**Issue 9 — branch from the integration branch (M, P1).** `git checkout -b issue/N` from whatever HEAD happens to be means that if the last task left you on `staging`, the new branch forks from `staging` and its PR carries unrelated commits. Fetch and branch explicitly. The resume path must **not** reset — returning to an existing issue branch has to preserve local commits.

**Issue 10 — PR base (S, P1).** `work-issue` Phase 11 (:203-211) creates a PR with no `--base`, so `gh` silently targets the repo default branch. On a ladder repo where default is `main`, every feature PR aims at production.

**Issue 11 — generalize `main` (XS, P2).** `core/SKILL.md:27,31` says "main/master", under-describing the protected set. `wave/SKILL.md:55` hardcodes `git log origin/main..HEAD`.

**Exit criteria:** With `integration: dev`, `/work-issue N` branches from `origin/dev` and opens a PR targeting `dev` from any starting HEAD; `dev → staging` merges with a merge commit and keeps `dev`.

**Tasks:**
- [ ] Derive merge strategy from the ladder; expose `--strategy squash|merge|rebase` as manual override (#85)
- [ ] Define the promotion predicate: head and base both in `branches.ladder`
- [ ] Upgrade Step 0's hardcoded protected set to read `branches.protected`
- [ ] Skip issue-closing on promotions; report `Issues: skipped (promotion PR)`
- [ ] Include strategy and promotion status in the confirm summary
- [ ] `work-issue`: `git fetch origin {integration}` then `git checkout -b issue/{N} origin/{integration}`
- [ ] `work-issue`: leave the existing-branch resume path alone — no reset
- [ ] `work-issue` Phase 11: pass `--base {integration}` explicitly
- [ ] `core/SKILL.md:27,31`: generalize to the protected set, keeping main/master as the default example
- [ ] `wave/SKILL.md:55`: use the configured integration branch

**Verification:**
```bash
git checkout staging
git fetch origin dev && git checkout -b issue/999 origin/dev
git merge-base --is-ancestor origin/dev HEAD && echo "correctly forked from dev"
git checkout - && git branch -D issue/999
```

---

### Step 5: GitHub Projects integration

**Issues 13, 14, 15, 16** · **Depends on:** Steps 1, 3

**Context brief:** Nothing in the repo touches Projects today. Projects v2 is GraphQL-only for field mutations — editing an item needs the project ID, item ID, *field* ID, and for single-select fields the *option* ID. These are opaque strings (`PVTSSF_…`), so they are resolved once and cached in `.hivrr.json.project`, never looked up per call.

Issue 13 is the enabling work and the only piece with real API risk. 14, 15, 16 are thin once IDs exist. Issue 16 depends on Issue 7 as well — those skills are being rewritten in Step 3, and touching them concurrently would conflict.

**Exit criteria:** A planned issue lands on the board as Todo, moves to In Progress when work starts, reaches Done on merge — and in a repo with no `project` config, every one of those is a silent no-op.

**Tasks:**
- [ ] Document the `gh api graphql` queries that resolve status field and option IDs (steps, not a script)
- [ ] Cache resolved IDs in `.hivrr.json.project`; re-resolve only when absent or explicitly requested
- [ ] Handle: no project configured, missing `read:project` scope, renamed Status options
- [ ] `planning` Phase 10 (:421-429): `gh project item-add` per created issue, status Todo
- [ ] `work-issue`: set In Progress after branch creation
- [ ] `merge-pr`: set Done after merge, skipped on promotion PRs
- [ ] `score-issues`/`group-issues`: read board status, exclude In Progress and Done
- [ ] Every board call warns and continues on failure — never aborts the workflow

**Verification:**
```bash
gh api graphql -f query='{viewer{projectsV2(first:5){nodes{id title number}}}}'
jq .project .hivrr.json          # Expected: statusFieldId + three option IDs
jq 'del(.project)' .hivrr.json | sponge .hivrr.json
# Expected: work-issue still completes, logs "project not configured — skipping board update"
```

---

### Step 6: Promotion, docs, and cleanup

**Issues 12, 17, 18** · **Depends on:** Steps 1, 2, 4

**Context brief:** With the ladder configured and merge strategy correct, promotion is thin orchestration: pick the next rung, open the PR, verify CI, merge with the right strategy.

Issue 17 clears accumulated drift and encodes the script policy so this does not recur. `CLAUDE.md:7-28` and `README.md:13-19` both describe a 3-plugin layout (`hivrr`, `manager`, `data-platform`) that has not existed since #87 — `marketplace.json` ships five, and `init`/`session` are undocumented. `wave` is registered in the `dev` plugin and CLAUDE.md advertises `/wave`, but `command/wave.md` does not exist, so the slash command silently fails to resolve. Partially addresses #37.

Issue 18 is bookkeeping: eight open issues die with the layers removed.

| Issue | Why it closes |
|---|---|
| #59, #60, #61 | `hivrr-verify.sh` deleted (Issue 5) |
| #86 | `HIVRR_MERGE_SUMMARY` and its `branch_deleted` field deleted (Issue 4) |
| #91, #95, #100, #102 | hub/MCP layer deleted (Issue 3) |

#85 closes via Issue 8. #88 is resolved by Issue 2's precedence rules.

**Exit criteria:** `/promote dev` opens and merges `dev → staging` with a merge commit. Docs match `marketplace.json`. `/wave` resolves.

**Tasks (12):**
- [ ] `skill/promote/SKILL.md`: resolve current rung → next rung from `branches.ladder`
- [ ] Refuse to promote when the source is behind its upstream, or the target has unmerged hotfixes
- [ ] Generate a PR body summarizing promoted commits (`git log {target}..{source}`)
- [ ] Reuse `merge-pr`'s steps with merge-commit strategy; do not duplicate merge logic
- [ ] `command/promote.md`; register skill and command in `marketplace.json` under `dev`

**Tasks (17):**
- [ ] Rewrite the CLAUDE.md plugin inventory to the 5-plugin layout, including `init` and `session`
- [ ] Rewrite README.md's table and per-plugin skill lists to match
- [ ] Create `command/wave.md` following the `command/work-issue.md` bootstrap pattern
- [ ] Register `./command/wave.md` in `marketplace.json` under `dev`
- [ ] Document `.hivrr.json` in README with a worked example
- [ ] Add the script policy to `core/SKILL.md`: prefer explicit steps; a script must be read-only, non-interactive, single-purpose, and deterministic to earn its place

**Tasks (18):**
- [ ] Close #59, #60, #61, #86, #91, #95, #100, #102 with a comment naming the PR that made each moot

**Verification:**
```bash
jq -r '.plugins[].name' .claude-plugin/marketplace.json   # Expected: dev auditor planner dispatcher data-platform
for c in $(jq -r '.plugins[].commands[]' .claude-plugin/marketplace.json); do test -f "$c" || echo "MISSING: $c"; done
grep -ciE '`hivrr`|`manager`' CLAUDE.md README.md         # Expected: 0
```

---

## Issue index

Created on `hivrr/agent-plugins` as #104–#121.

| Issue | Title | Size | Pri | Depends on |
|---|-------|------|-----|-----------|
| **#104** | fix(merge-pr): never delete protected or long-lived branches | XS | **P0** | — |
| #105 | feat(config): `.hivrr.json` schema + precedence contract | M | P1 | — |
| #106 | refactor(session): remove MCP probing, delete `hub.md`, strip `MCP:` lines | M | P1 | — |
| #107 | refactor(merge-pr): replace `hivrr-merge.sh` with explicit skill steps | L | P1 | #104 |
| #108 | refactor(verify): `init` detects and records test/lint commands | M | P1 | #105 |
| #109 | refactor(work-issue,work-pr): inline branch-setup and pr-checkout | S | P2 | — |
| #110 | refactor(dispatcher): replace hub MCP calls with inline reasoning | M | P2 | #106 |
| #111 | feat(merge-pr): ladder-aware merge strategy and promotion detection | M | P1 | #105, #107 |
| #112 | feat(work-issue): branch from the configured integration branch | M | P1 | #105, #109 |
| #113 | feat(work-issue): target the integration branch when creating PRs | S | P1 | #105, #112 |
| #114 | fix(core,wave): generalize hardcoded `main` to the protected set | XS | P2 | #105 |
| #115 | feat(promote): promotion skill + command for dev/staging/main | L | P2 | #105, #107, #111 |
| #116 | feat(config): resolve GitHub Project v2 field and option IDs | M | P2 | #105 |
| #117 | feat(planning): add created issues to the project board | S | P2 | #105, #116 |
| #118 | feat(work-issue,merge-pr): project status transitions | M | P2 | #116 |
| #119 | feat(dispatcher): read board state in score/group-issues | M | P3 | #110, #116 |
| #120 | docs: refresh plugin inventory, add `/wave`, encode script policy | S | P2 | — |
| #121 | chore: close issues made moot by MCP and script removal | XS | P3 | #106, #107, #108 |

```
#104 ──> #107 ──┬──> #111 ──> #115
                │
#105 ───────────┼──> #112 ──> #113
                ├──> #114
                ├──> #108
                └──> #116 ──┬──> #117
                            ├──> #118
                            └──> #119
                                  ↑
#106 ──> #110 ──────────────────┘

#109, #120 — independent
#121 — last (needs #106, #107, #108 merged)
```

**Closed by this work:** #85 (via #111), #86 (via #107), #88 (via #105), #59/#60/#61 (via #108), #91/#95/#100/#102 (via #106), #93 (verified already clean), #37 partially (via #120).

## Risks

| Risk | Mitigation |
|---|---|
| Steps drift where a script was deterministic | Every step is a single command with verifiable output; the skill states expected results |
| `merge-pr` rewrite loses edge cases from 354 lines | Anchors section enumerates the logic to preserve; the `claude-review` CI filter and Linear issue refs are the two easy misses |
| **Issue-closing dropped as "GitHub does this already"** | It does not, on a non-default base. The skill must carry the reason inline so no future edit removes it as redundant |
| **Branch pruning deletes something wanted** | Prune only on `[gone]` upstream — a signal that the remote branch was deliberately deleted — never on ancestry, and always excluding the protected set |
| Recorded `verify` commands go stale | `detectedFrom` fingerprint re-checked on every bootstrap; mismatch forces re-detection |
| The confirm checkpoint blocks unattended runs | `--auto` remains and is now the *only* interactive path removed — the script never had a working one |
| Projects v2 option IDs change on a column rename | Re-resolve on demand; unknown status is a warning, not a failure |
| `.hivrr.json` absent in most repos | Every consumer degrades to documented defaults, verified explicitly per step |
| Repos not on a ladder break | `ladder: [default]` is the fallback; promotion no-ops on a single-rung ladder |

## Out of scope

Open issues left for separate triage: #74–#79 (postgres docs), #81/#82 (`planning --plan-only` bugs), #72, #65, #34, #36, #30, #93 (already clean — verified no guard patterns remain), #97.

---
name: work-issue
description: Work an issue end-to-end — fetch, implement, test, commit, PR/MR
license: MIT
compatibility: opencode
---

# Work Issue Workflow

You are a workflow driver. Your job is to take an issue from input to merged PR without stopping unless you genuinely need the user's input. Work with momentum — keep moving through the phases, communicate progress clearly, and only pause at marked checkpoints.

Before starting: read this entire skill, then create a focused todo list, then execute.

---

## Bootstrap

Run in order before Phase 1 — there is no command wrapper to run them (see Phase 12):
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates, git safety, and task completion standards

---

## Straight-through execution

This skill runs start to finish in one pass. There is no session file, no phase 0, and no
question/answer protocol — an earlier version had all three, and they were removed deliberately
(PR #63), not lost. If you are looking for where the skill hands a question back and waits, there
isn't one: that absence is the design.

What replaces it is narrower on purpose: Phase 4's one clarifying question and Phase 9's checkpoint
both sit *before* implementation, so they catch "is this bigger than it looks" — not a product
decision that only surfaces mid-implementation. That is a known and accepted trade-off. When you hit
such a decision, do not invent a protocol to escalate it: follow Phase 7's blocker rules.

---

## Pack mode

**Skip this section when no issue carries a marker;** without one, every **Pack slice
(conditional)** block below is skipped and each phase runs exactly as written. A marker line
(`Plan: docs/plans/<slug> · Slice: <N>`) makes the issue one slice of a plan pack. When Phase 2 or 3
finds a line starting `Plan: `, read [`references/pack-mode.md`](references/pack-mode.md) in full;
its **The contract** governs the whole run (the pack's README rules win over this skill, and the
pack over the issue body), and each pack block below names the section of that file it needs.

---

## Phase 1 — Parse the Input

The input will be one of these forms:
- A single issue number: `123`
- Multiple numbers or a range: `123, 456`, `123 456`, or `123-126`
- A GitHub URL
- A Linear identifier: `PROJ-123`
- Any of the above followed by `: some context` for inline hints
- An optional `--auto` flag to skip the user approval checkpoint

Extract:
- `issue_numbers` — the list of issue numbers/identifiers to work on
- `inline_context` — any text after `:` in the input
- `auto_mode` — true if `--auto` is present

Display: `Input: {issue_numbers} | auto: {auto_mode}`

---

## Phase 2 — Route Multiple Issues

**Skip this phase if there is only one issue.**

For multiple issues, decide how to execute them before doing anything else.

**Group by relationship:** Scan each issue's title and body for mentioned file paths and labels. Issues that share mentioned files, share labels, or reference the same origin PR belong in the same group and will share a branch. Issues with no relationship to the others form their own single-issue group.

**Order within each group:** Sort the issues in this sequence: structural or rename changes first,
then type definitions, then new features, then bug fixes, and documentation last.

**Choose a strategy:**
- **Unified** — one shared wave branch per group: use when all issues in a group are simple or medium complexity and the group has 5 or fewer issues. The `wave` skill handles execution.
- **Sequential** — a separate `issue/{N}` branch per issue, processed one at a time: use when any issue is complex, groups are completely unrelated, or the provider is Linear (Linear does not support wave branching).

**Pack slices (conditional).** Skip this when no issue in the list carries a marker. This phase
already scans the issue bodies; fetch them now with the **Get issue** command if you have not. When
a body has a line starting `Plan: `, read [`references/pack-mode.md`](references/pack-mode.md) now
and apply its **Detect a pack marker**. When any issue carries a marker, the strategy is `sequential`
whatever the rules above say: a slice is one issue, one branch and one PR, and `wave` never runs a
slice.

Store: `wave_strategy` ("unified" or "sequential"), `wave_groups` (the ordered groups of issue numbers).

Display: `Route: {count} issues | strategy: {wave_strategy} | groups: {group_count}`

---

## Phase 3 — Get Repo and Issue Context

Do these together:

**Repo info:** Run `git remote get-url origin` and parse the owner and repo name. Check the current branch with `git branch --show-current`. Store `repo_owner`, `repo_name`, `current_branch`.

**Issue details:** Use the **Get issue** command from the loaded reference (or the linear reference if `ISSUE_TRACKER=linear`). Get the title, body, labels, and any linked issues. If fetching fails, continue with whatever you have — don't stop.

Store everything you learn about the issues as `issue_data`.

**Check for hierarchy (conditional).** Skip this when `issues.hierarchy` is disabled or absent.
When it is enabled, follow [`references/hierarchy.md`](references/hierarchy.md) for each issue now.
An issue with open sub-issues is an epic: it displays `Epic: …`, then stops and asks which children
to work — or, under `--auto`, substitutes the open children and re-runs Phase 2's routing. A failed
query warns and continues.

Display: `Fetched: {count} issue(s) from {repo_owner}/{repo_name}`

### Pack slices (conditional)

**Skip this section when no line of any issue body starts with `Plan: `.** Say nothing and continue.
A body that mentions a plan mid-sentence, such as `Plan: TBD` inside a paragraph, has no such line.

Otherwise read [`references/pack-mode.md`](references/pack-mode.md) in full, if Phase 2 has not
already, and run its **Detect a pack marker** and then **Load the pack** for each issue before
Phase 4. Both can stop the run before any branch exists, with the exact messages that file gives.

---

## Phase 4 — Assess Complexity

Look at what you know about the issue(s) and classify:

- **Simple**: small scope, clear requirements, likely a single file or doc change, labels like `docs`, `chore`, `typo`, body under 500 characters, no linked issues
- **Medium**: clear requirements, a few files, well-understood problem
- **Complex**: unclear requirements, many files, architectural decisions needed, multiple linked issues

For multiple issues, assess each one and use the highest classification to drive planning decisions.

If `--auto` is set and you're unsure, default to `medium` and continue.
If `--auto` is not set and you're genuinely unsure, ask the user one focused question.

**Pack slice (conditional).** Skip this when the issue carries no marker. Do not classify and do not
ask: map the README's Size row. S is `simple`, M is `medium` and L is `complex`. A Change is always
S, and an XL pack never reaches here because it is split into child packs. Phase 6 always runs in
pack mode, whatever the complexity, because it holds the preflight. Display
`Complexity: {simple|medium|complex} (pack size {S|M|L})` in place of the line below.

Display: `Complexity: {simple|medium|complex}`

---

## Phase 5 — Create a Working Branch

**Unified wave strategy:**
Skip this phase — the `wave` skill creates and manages its own branch, and its own worktree, in its Step 2. `work-issue` loads it in Phase 7.

Display: `Branch: wave skill will create`

**Single issue or sequential strategy:**

For a pack slice on a Linear issue, `issue/{number}` in this phase and later is `issue/{identifier}`
(`issue/ENG-123`), as **Detect a pack marker** in `references/pack-mode.md` says.

### Enter a worktree (conditional)

Read `worktree` from `.hivrr.json`. **Skip this entire section** when `worktree.enabled` is absent
or false — the session works in the current checkout exactly as before.

When it is true, follow [`references/worktree.md`](references/worktree.md) now, before creating
the branch, with `{branch}` = `issue/{number}`. It checks the `CLAUDE.md` authorization (warning and
continuing without a worktree when it is missing), re-enters an existing worktree for `{branch}` or
creates one, and only on creation re-points it to `origin/{integration}`, carries untracked files
and runs setup. Then continue with **Create the branch** below, inside the worktree.

### Create the branch

Determine the **integration branch** — the branch feature work forks from. Read `branches.integration`
from `.hivrr.json`; see [`config.md`](../init/references/config.md) for the read steps and per-key
precedence.

When the file or the key is absent, fall back to the repository default branch,
`gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`. If that fails too (no remote,
or the provider is not GitHub), fall back to the branch `origin/HEAD` points at, then to `main`.

Store it as `{integration}`. Branching from the current HEAD is not acceptable: if the previous task
left you on `staging`, an issue branch forked from there carries unrelated commits into its PR.

Check whether the working tree is dirty with `git status --porcelain`. If it reports anything, display `WARNING: Working tree has uncommitted changes — continuing anyway` and continue. This is a warning, not a guard — do not stash, reset, or discard the changes.

Check whether the issue branch already exists — **locally and on the remote**. Checking only local refs is not enough: on a fresh clone, a recreated container, or work resumed from another machine, `issue/{number}` exists on `origin` but not in `refs/heads`. Branching from the base in that situation produces a local branch with none of the remote's commits, and the push in Phase 11 fails as a non-fast-forward after all the implementation work is done.

```bash
git fetch origin
git show-ref --verify --quiet refs/heads/issue/{number}   # exit 0 = exists locally
git ls-remote --exit-code --heads origin issue/{number}    # exit 0 = exists on origin
```

Then take exactly one of these three paths:

- **Local branch exists** (resume) — switch to it: `git checkout issue/{number}`
- **Remote only** (resume from elsewhere) — track the remote branch:
  `git checkout -b issue/{number} origin/issue/{number}`
- **Neither exists** (new work) — fetch the integration branch and fork from it:
  `git fetch origin {integration}`, then `git checkout -b issue/{number} origin/{integration}`

On both resume paths, do **not** reset, rebase, or force-update the branch. Commits from an earlier run must survive. In particular, do not "re-base onto the integration branch" to make a resumed branch match the new base — that discards or rewrites work.

If any command fails, surface the error and stop.

Display: `Branch: issue/{number} ({new | resumed local | resumed from origin}, base: {integration})`

### Move the board card to In Progress

Work has now started, and this skill is the only thing that knows it. Read `project` from `.hivrr.json` and set each issue's Status to In Progress.

**When `project` is absent, skip this silently.** See **Board operations** in [`config.md`](../init/references/config.md) for the commands and the shared rules.

For each issue in the group: (1) resolve its item ID; (2) if it is not on the board, add it with `item-add` and resolve again — a planned issue may have been created before the board existed; (3) set Status to In Progress using `project.statusFieldId` and `project.status.inProgress`.

**Warn and continue on any failure.** A board that cannot be reached must never stop the branch from being created or the work from starting.

Display: `Board: {n} issue(s) → In Progress` or nothing when unconfigured

---

## Phase 6 — Plan (medium and complex only)

**Pack slice (conditional).** Skip this block when the issue carries no marker. In pack mode this
phase runs at every complexity, `simple` included, because preflight cannot be skipped: follow
**Plan the slice (Phase 6)** in [`references/pack-mode.md`](references/pack-mode.md) — preflight,
the resumed-after-a-block check, and the slice as the plan. A preflight difference that touches the
slice's **Contracts**, or a block still unanswered, is a stop: take **Pack mode — Blocked path**.
Display `Plan: pack slice {slice_number}` in place of `Plan: ready`, and skip the rest of this phase.

For **simple** tasks: skip this phase, go straight to implementing.

For **medium and complex** tasks: before touching any code, write out your implementation plan. Include what you're going to change and why, the approach you'll take, any risks or tradeoffs worth noting, and how you'll verify it works.

For **complex** tasks: look at the existing architecture before committing to an approach. Follow existing patterns — one consistent pattern well-applied beats a new pattern.

Display: `Plan: ready`

---

## Phase 7 — Implement

**Unified wave strategy (multiple related issues):**
Load the `wave` skill. Pass it the ordered issue list, the fetched issue data, and `auto_mode`. The wave skill creates the shared branch, implements each issue in sequence, handles resume if the branch already exists, and returns a per-issue summary. When it returns, continue to Phase 8 with the combined results.

**Single issue or sequential strategy:**
Write the code directly. Follow these principles:
- **Verify before editing**: See [File Verification in the core skill](../core/SKILL.md#file-verification).
- Follow existing patterns in the codebase — explore before writing
- Make the smallest change that satisfies the requirements
- Handle errors explicitly — don't let things fail silently
- Write or update tests alongside the code, not after

If you hit a blocker that cannot be resolved by reading the codebase:
- Style, naming, missing tests → decide autonomously using existing conventions
- Contradictory acceptance criteria or missing external credentials → surface the blocker clearly and stop; leave the branch intact

**Pack slice (conditional).** Skip this when the issue carries no marker. These join the blocker
rules above as hard stops:

- every bullet under the slice's **Stop conditions**;
- README rule 6: the PRD, an ADR, `design.md` or another slice turns out to be wrong in a way that
  changes a contract.

When one triggers, do not work around it and do not ask, with or without `--auto`: take **Pack mode
— Blocked path**. A plan that is wrong without changing a contract is a deviation: record it and
continue. Never edit the pack's plan files to match what you built.

For sequential multi-issue, process each issue fully through Phase 11 (Create PR) before starting the next one.

When done, display: `Implement: complete | files changed: {count}`

---

## Phase 8 — Verify

Follow [`verify.md`](../init/references/verify.md) — it has the command resolution, the
run-and-show-real-output rule, the skip criteria, and the reporting format.

**Review your own changes** once the commands have run:
- Do the changes actually satisfy the acceptance criteria from the issue(s)?
- Is there anything obviously wrong, missing, or broken?
- Fix what you find.

**Pack slice (conditional).** Skip this when the issue carries no marker. Also run every command in
the slice's **Verify** and show its real output, then collect a proof for every acceptance ID and
example row as **Proofs (Phase 8)** in [`references/pack-mode.md`](references/pack-mode.md) defines
them. An ID without a proof means the slice is not done: go back to Phase 7. If it cannot hold
without changing a contract, that is a stop under Phase 7's rules.

---

## Phase 9 — Review Checkpoint

**Skip this phase if `--auto` is set.**

Show the user a summary: files changed (list them), test results, lint results, and any unresolved
issues.

Ask: "Ready to commit and create a PR?" with options:
- Commit and create PR
- Show full diff (`git diff --stat`)
- Abort (leave changes on branch for manual review)

Wait for their response before continuing.

---

## Phase 10 — Commit

Follow [**Staging**](../core/SKILL.md#staging) in the `core` skill — it has the prohibition on
blanket staging, the explicit `git add`, and the `git status --short` check that must come back
clean before you commit.

What `core` leaves to this skill is the file list. Build it from what you actually changed:

- **Wave runs:** use the per-issue file lists recorded in Step 3 of the `wave` skill.
- **Single-issue runs:** use the files you edited, plus any you created.

**Pack slice (conditional).** Skip this when the issue carries no marker. Before staging, write the
pack files that **Pack files (Phase 10)** in [`references/pack-mode.md`](references/pack-mode.md)
lists — the progress file, README Status, and on the last slice only the Retro — then add each one
you wrote to the list by name.

Write a conventional commit message:
- Format: `{type}({scope}): {description}`
- Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
- Include issue references in the body: `Closes #{number}` for each issue (GitHub/GitLab) or the Linear identifier (e.g. `ENG-123`) if `ISSUE_TRACKER=linear`

Commit the message through a file, never `-m`: follow [**Commit**](../core/SKILL.md#commit) in `core`.

Display: `Commit: {message}`

---

## Phase 11 — Create PR/MR

Push the branch: `git push -u origin {branch_name}`

Use the **Create PR** command from the loaded reference with:
- **Base: `--base {integration}`, passed explicitly.** Resolve `{integration}` the same way Phase 5 does — `branches.integration` from `.hivrr.json`, falling back to the repo default branch. Omitting `--base` makes `gh` silently target the repository default branch, so on a ladder repo where the default is `main`, **every feature PR would aim at production.** Pass it even when the two happen to be the same value; a PR that targets the right branch by coincidence breaks the moment the default changes.
- Title: the issue title for a single issue, or a clear group summary for wave
- Body: what was done, why, how to test it, and a `Closes #N` line for every issue in the group (use Linear identifiers like `ENG-123` if `ISSUE_TRACKER=linear`)
- Link it to all relevant issues

**When the base is not the repository default branch**, GitHub will not honor the `Closes #N` keywords on merge. That is expected — `merge-pr` closes them explicitly where it closes linked issues. Keep the lines in the body regardless; they are what `merge-pr` parses.

Display: `PR: {url} (base: {integration})`

---

## Phase 12 — Done

**Pack slice (conditional).** Skip this when the issue carries no marker. A slice that reached this
phase emits the JSON below unchanged. A slice that stopped emits the same keys with
`status: "BLOCKED"`, from **Pack mode — Blocked path**; `BLOCKED` is the only other status value.

### Emit the result

There is no command here to defer to — `command/work-issue.md` has been retired. Emit this JSON as
your entire final response — no markdown, no preamble, no trailing text:

```json
{
  "status": "WORKFLOW COMPLETE",
  "pr": {pr_number},
  "pr_url": "{url}",
  "branch": "{branch_name}",
  "issues": [issue_numbers]
}
```

---

## Pack mode — Blocked path

**Skip this section when the issue carries no marker;** legacy blockers stop as Phase 7 and Error
Handling describe. Take this path when a stop condition triggers in Phase 6 or Phase 7, with or
without `--auto`: follow the five steps of **Blocked path** in
[`references/pack-mode.md`](references/pack-mode.md). In short: skip Phases 8, 9 and 11; write the
progress file with Status `blocked`, PR `none (no PR is opened)` and **Blocked on**, leaving README
Status and the Retro alone; commit the partial work with it in one `wip:` commit (`Refs`, not
`Closes`); push; open no PR, and emit the Phase 12 JSON with `"status": "BLOCKED"`, `"pr": null`
and `"pr_url": null`. Under the sequential strategy, no later issue starts.

---

## Error Handling

If any phase fails:
- Leave the branch intact so the user can inspect it manually
- Display what went wrong clearly
- Don't silently swallow errors
- Don't retry indefinitely — 3 attempts max on any single fix

**Pack slice (conditional).** Skip this when the issue carries no marker. A stop condition is not a
failure to retry: take **Pack mode — Blocked path**, which ends with `status: "BLOCKED"` and opens
no PR. `ship-issue` records that value as `stuck` and stops its run.

---
name: work-issue
description: Work an issue end-to-end — fetch, implement, test, commit, PR/MR
license: MIT
compatibility: opencode
---

# Work Issue Workflow

You are a workflow driver. Your job is to take an issue from input to merged PR without stopping unless you genuinely need the user's input. Work with momentum — keep moving through the phases, communicate progress clearly, and only pause at marked checkpoints.

Before starting: read this entire skill, then create a focused todo list, then execute.

This skill no longer ships a command wrapper — `command/work-issue.md` has been retired now that
every target coder supports invoking a skill directly. The bootstrap chain that command used to run
lives here instead.

---

## Bootstrap

Run in order before Phase 1:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates, git safety, and task completion standards

---

## Straight-through execution

This skill runs start to finish in one pass. There is no session file, no phase 0, and no
question/answer protocol — an earlier version had all three, and they were removed deliberately
(PR #63), not lost. If you are looking for where the skill hands a question back and waits, there
isn't one: that absence is the design.

What replaces it is narrower on purpose. Phase 4 asks a single clarifying question when complexity
is genuinely ambiguous and `--auto` is off, and defaults to `medium` when it is on. Phase 9 is the
one checkpoint before anything is committed, and `--auto` skips it. Both sit *before*
implementation, so they catch "is this bigger than it looks" — they do not catch a product decision
that only surfaces mid-implementation.

That is a known and accepted trade-off. When you hit such a decision, do not invent a protocol to
escalate it. Follow Phase 7: decide autonomously from existing conventions where the choice is
style, naming, or test shape, and stop with the branch intact only when the requirements genuinely
contradict each other or an external credential is missing.

---

## Pack mode

**Skip this section when no issue carries a marker** (Phase 3, **Detect a pack marker**). Every
pack-mode block below opens the same way, and without a marker each phase runs exactly as written.

A marker makes the issue one slice of a plan pack, a committed folder `docs/plans/<slug>/`. The pack
is self-describing: its README's **How to execute this pack** rules are the contract for the run,
and everything this skill needs comes from the pack and the repository. Never read another plugin's
files to interpret a pack. Where the executed pack's own README rules differ from what this skill
says, follow the README: a pack is executed under the rules it was planned against.

The pack wins over the issue body, which is only a summary of the slice; issue comments still
override scope. Throughout the run, keep notes for the progress file: deviations (plan said /
reality / why / contract affected), decisions the plan left open, and discoveries for the next slice
or the retro.

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

**Order within each group:** Sort the issues in this sequence:
1. Structural or rename changes first
2. Type definitions
3. New features
4. Bug fixes
5. Documentation last

**Choose a strategy:**
- **Unified** — one shared wave branch per group: use when all issues in a group are simple or medium complexity and the group has 5 or fewer issues. The `wave` skill handles execution.
- **Sequential** — a separate `issue/{N}` branch per issue, processed one at a time: use when any issue is complex, groups are completely unrelated, or the provider is Linear (Linear does not support wave branching).

**Pack slices (conditional).** Skip this when no issue in the list carries a marker (Phase 3,
**Detect a pack marker**). This phase already scans the issue bodies; fetch them now with the **Get
issue** command if you have not. When any issue carries a marker, the strategy is `sequential`
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

**Check for hierarchy.** When `issues.hierarchy` is enabled, run the **Read hierarchy** command
from the loaded reference for each issue and keep all three fields it returns — they answer
different questions:

- `subIssuesSummary.total` — *is this an epic?*
- `subIssues.nodes[].state` — *which children are still open?* The summary cannot answer this; it
  carries counts, not per-child state.
- `subIssues.nodes[].number` — *which children to name and, under `--auto`, to substitute.*

`subIssues` is capped at 100. Compare `totalCount` against the number of nodes returned, and if
they differ, say the child list is partial rather than substituting a truncated set.

Skip this entirely when `issues.hierarchy` is disabled or absent; if the query fails, warn and
continue treating every issue as workable — losing the check degrades the run, aborting destroys it.

If an issue has `subIssuesSummary.total > 0` with at least one child still open, it is an epic.
Implementing it directly produces one oversized PR that closes a container rather than its
contents. Display:

`Epic: #{number} has {open}/{total} open sub-issues — work those instead: {child_numbers}`

Then stop and ask which children to work, unless `--auto` is set. Under `--auto`, substitute the
**open children** for the epic in `issue_numbers` and continue — do not abort, and do not
implement the epic. Substituting several children for one issue can change the routing decision
made in Phase 2, so re-run that routing on the new list before continuing.

An epic whose children are all closed is workable as an ordinary issue; it is likely a
documentation or wrap-up task.

Display: `Fetched: {count} issue(s) from {repo_owner}/{repo_name}`

### Detect a pack marker

**Skip this section when no line of any issue body starts with `Plan: `.** Say nothing and continue.
A body that mentions a plan mid-sentence, such as `Plan: TBD` inside a paragraph, has no such line.

For each issue, look at the lines that start with `Plan: `. Matching is case-sensitive.

- **Marker.** The first line that starts with `Plan: docs/plans/`, in the form
  `Plan: docs/plans/<slug> · Slice: <N>`. The separator may be `·` or `|`. Store `pack_slug` and
  `slice_number` for that issue. If no `Slice: <N>` can be read from the line, stop:
  `marker on #{number} names no slice — fix the issue body`.
- **Not a marker.** A `Plan: ` line that is not a `docs/plans/` path, such as `Plan: docs/plan/x`.
  Display `unrecognised Plan: line — legacy mode` and treat that issue as having no marker.

### Load the pack

**Skip this section when no issue carries a marker.** For each issue that does:

1. Resolve `{integration}` now, by the rule Phase 5 uses (`branches.integration`, then the
   repository default branch, then `origin/HEAD`, then `main`). Phase 5 reuses this value.
2. Run `git fetch origin {integration}`.
3. Read the README with `git show origin/{integration}:docs/plans/{pack_slug}/README.md`. If it is
   not there, stop: `pack docs/plans/{pack_slug} is not on {integration}; merge its PR first`.
4. Read the files in the README's **Read order** the same way. For a directory entry, such as
   `decisions/` or `progress/`, list it with
   `git ls-tree --name-only origin/{integration} docs/plans/{pack_slug}/{dir}/` and read each file.
   An entry that does not exist yet, such as `progress/` before the first slice, is skipped.
5. Find the slice: the `## Slice {slice_number}` section of `plan.md`. A pack with no `plan.md`
   (size S) has one slice, `Slice: 1`, which is the README's **Slice** section. If the slice is not
   there, stop: `pack docs/plans/{pack_slug} has no Slice {slice_number}`.

Read from `origin/{integration}`, never the working copy: that is what the branch will fork from.
These stops come before any branch exists, so there is nothing to commit; report them as Error
Handling says.

Hold `pack_context` for the issue: the README's **How to execute this pack** rules and Size, the
slice section, the text of every criterion it lists and the example rows under them, and any
Discoveries other slices' progress files address to this one.

Display: `Pack: docs/plans/{pack_slug} · Slice {slice_number} (from origin/{integration})`

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
S, and an XL pack never reaches here because it is split into child packs. Display
`Complexity: {simple|medium|complex} (pack size {S|M|L})` in place of the line below.

Display: `Complexity: {simple|medium|complex}`

---

## Phase 5 — Create a Working Branch

**Unified wave strategy:**
Skip this phase — the `wave` skill creates and manages its own branch, and its own worktree, in its Step 2. `work-issue` loads it in Phase 7.

Display: `Branch: wave skill will create`

**Single issue or sequential strategy:**

### Enter a worktree (conditional)

Read `worktree` from `.hivrr.json`. **Skip this entire section** when `worktree.enabled` is absent
or false — the session works in the current checkout exactly as before.

`{branch}` below is `issue/{number}` here, and `wave/{min}-{max}-{count}` when `wave` Step 2 follows
this section. Nothing else differs between the two callers.

Before entering, confirm the repo's `CLAUDE.md` authorizes it (see **Adopting worktrees** in
[`config.md`](../init/references/config.md)). If the config key is set but the authorization line is
absent, warn once and continue **without** a worktree:

`Worktree: enabled in .hivrr.json but not authorized in CLAUDE.md — continuing in the current checkout`

**Check for an existing worktree first.** Git refuses to check one branch out in two worktrees —
`fatal: '{branch}' is already used by worktree at '…'` — so a resumed run must re-enter its own
rather than create a second. This is a hard error, not a degraded path, which is why the check comes
before the create:

```bash
git worktree list --porcelain
```

- **An entry already holds `{branch}`** — re-enter it with `EnterWorktree` using its `path`, then go
  straight to the branch logic below. Skip the re-point, the carry, and the setup: all three ran on
  creation.
- **No entry holds it** — create one with `EnterWorktree` named `{branch}`, then continue with the
  three steps below.

**Re-point the branch — on creation only.** Skip this when you re-entered an existing worktree
above. That branch already carries the earlier session's commits, and `checkout -B` would reset it
to `origin/{integration}` and discard them — the same rule the resume paths below state in full.

On creation, `EnterWorktree` forks per `worktree.baseRef`, whose default (`fresh`) forks from
`origin/<default-branch>` — the wrong rung on a ladder repo, since `branches.integration` is `dev`
and the default branch is `main`. This is the same class of defect
[`github.md`](../session/references/github.md) already warns about for `gh pr create --base`.
Re-point from inside the worktree rather than depending on a global setting every adopter would have
to change:

```bash
git fetch origin {integration}
git checkout -B {branch} origin/{integration}
```

Resolve `{integration}` exactly as the branch logic below does.

**Carry untracked files — on creation only.** A worktree receives tracked files only. For each path
in `worktree.carry`, copy it from the original checkout into the worktree — symlink it instead when
it is a large directory such as `node_modules`. A path that does not exist in the source is a
**warning**, not an error: a repo without a `.env` is normal.

**Run setup — on creation only.** If `worktree.setup` is non-null, run it once inside the worktree.
A non-zero exit is a **warning**: report the command and its exit code and continue. A worktree with
missing dependencies is recoverable by hand; aborting loses the session.

Display: `Worktree: {path} | branch: {branch} | carried: {n} | setup: ok | skipped | failed`

Determine the **integration branch** — the branch feature work forks from. Read `branches.integration`
from `.hivrr.json`; see [`config.md`](../init/references/config.md) for the read steps and per-key
precedence.

When the file or the key is absent, fall back to the repository default branch:

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

If that fails too (no remote, or the provider is not GitHub), fall back to the branch `origin/HEAD`
points at, then to `main`.

Store it as `{integration}`. Branching from the current HEAD is not acceptable: if the previous task
left you on `staging`, an issue branch forked from there carries unrelated commits into its PR.

Check whether the working tree is dirty:

```bash
git status --porcelain
```

If it reports anything, display `WARNING: Working tree has uncommitted changes — continuing anyway` and continue. This is a warning, not a guard — do not stash, reset, or discard the changes.

Check whether the issue branch already exists — **locally and on the remote**. Checking only local refs is not enough: on a fresh clone, a recreated container, or work resumed from another machine, `issue/{number}` exists on `origin` but not in `refs/heads`. Branching from the base in that situation produces a local branch with none of the remote's commits, and the push in Phase 11 fails as a non-fast-forward after all the implementation work is done.

```bash
git fetch origin
git show-ref --verify --quiet refs/heads/issue/{number}   # exit 0 = exists locally
git ls-remote --exit-code --heads origin issue/{number}    # exit 0 = exists on origin
```

Then take exactly one of these three paths:

**Local branch exists** (resume) — switch to it:

```bash
git checkout issue/{number}
```

**Remote only** (resume from elsewhere) — track the remote branch:

```bash
git checkout -b issue/{number} origin/issue/{number}
```

**Neither exists** (new work) — fetch the integration branch and fork from it:

```bash
git fetch origin {integration}
git checkout -b issue/{number} origin/{integration}
```

On both resume paths, do **not** reset, rebase, or force-update the branch. Commits from an earlier run must survive. In particular, do not "re-base onto the integration branch" to make a resumed branch match the new base — that discards or rewrites work.

If any command fails, surface the error and stop.

Display: `Branch: issue/{number} ({new | resumed local | resumed from origin}, base: {integration})`

### Move the board card to In Progress

Work has now started, and this skill is the only thing that knows it. Read `project` from `.hivrr.json` and set each issue's Status to In Progress.

**When `project` is absent, skip this silently.** See **Board operations** in [`config.md`](../init/references/config.md) for the commands and the shared rules.

For each issue in the group:

1. Resolve its item ID
2. If it is not on the board, add it with `item-add` and resolve again — a planned issue may have been created before the board existed
3. Set Status to In Progress using `project.statusFieldId` and `project.status.inProgress`

**Warn and continue on any failure.** A board that cannot be reached must never stop the branch from being created or the work from starting.

Display: `Board: {n} issue(s) → In Progress` or nothing when unconfigured

---

## Phase 6 — Plan (medium and complex only)

**Pack slice (conditional).** Skip this block when the issue carries no marker. In pack mode this
phase runs at every complexity, `simple` included, because preflight cannot be skipped:

1. **Preflight** (README rule 2), against the branch's working tree, which now exists. Check every
   path and symbol `context.md` cites that this slice touches, plus those the slice itself cites,
   and record each as holds or differs. A difference is a deviation. A difference that touches the
   slice's **Contracts** is a stop: take **Pack mode — Blocked path**.
2. **Resumed after a block.** If the branch already holds this slice's progress file with Status
   `blocked`, read its **Blocked on** first. Unless the issue comments or the pack on
   `origin/{integration}` now answer the question, the stop still holds: take the blocked path
   again without further work. When it is answered, record the answer as a decision and continue.
3. **The slice is the plan.** Its Outcome, Acceptance, Contracts, Stop conditions and Verify are
   mandatory. Pattern to follow, Suggested path and Files are guidance: you may leave them if every
   mandatory item still holds, and record why as a deviation. Write no separate plan.

Display `Plan: pack slice {slice_number}` in place of `Plan: ready`, and skip the rest of this phase.

For **simple** tasks: skip this phase, go straight to implementing.

For **medium and complex** tasks: before touching any code, write out your implementation plan. Include:
- What you're going to change and why
- The approach you'll take
- Any risks or tradeoffs worth noting
- How you'll verify it works

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
the slice's **Verify** and show its real output. Then collect a proof, to be written in Phase 10,
for each of these:

- every acceptance ID the slice lists, PRD criteria (`S-NN.k`) and slice-local ones (`N.k`) alike;
- every example row in `prd.md` **Rules and examples** whose ID extends one of those criteria
  (`S-NN.k.eN` under `S-NN.k`). A criterion the slice limits ("for X only") limits its rows too.

A proof is a test that names the ID or, where the repo has no test runner, a verification step at
the level the design's **Test strategy** gives the row: a structural check or grep, or a recorded
dry run that reads the changed files against the row's Given and names the phase, file and line
that produce its Then. An ID without a proof means the slice is not done: go back to Phase 7. If it
cannot hold without changing a contract, that is a stop under Phase 7's rules.

---

## Phase 9 — Review Checkpoint

**Skip this phase if `--auto` is set.**

Show the user a summary:
- Files changed (list them)
- Test results
- Lint results
- Any unresolved issues

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
pack files below, then add each one you wrote to the list by name.

1. **The progress file,** `docs/plans/{pack_slug}/progress/slice-NN.md` (`NN` is `slice_number`
   zero-padded to two digits). Its sections and their order come from the executed pack's README
   rule 7, never from any other source. Status `done`, the issue, PR `this PR` (the PR is opened in
   Phase 11 and is found from the branch), the executor model if known, and the date. Then the
   Phase 6 preflight, the Phase 8 proofs with one row per criterion ID and example ID, and the
   deviations, decisions and discoveries noted since Phase 6. Omit **Blocked on**.
2. **README Status.** If it is `published`, set it to `executing`.
3. **Last slice.** Read `progress/slice-NN.md` with `git show origin/{integration}:…` for every
   other slice listed in `plan.md`. If all of them say `done`, this is the last slice; at size S
   there is no other slice, so the single slice is always the last. Any other slice whose file is
   missing or says `in-progress` or `blocked` means this is not the last slice, whatever its number:
   write no Retro. For the last slice, replace the README's **Retro** placeholder with a Retro that
   compares `cold-read.md` with the deviations recorded across every progress file, this one
   included: what the cold read predicted, and what really diverged. Then set README Status `done`.

Write a conventional commit message:
- Format: `{type}({scope}): {description}`
- Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
- Include issue references in the body: `Closes #{number}` for each issue (GitHub/GitLab) or the Linear identifier (e.g. `ENG-123`) if `ISSUE_TRACKER=linear`

Commit with: `git commit -m "{message}"`

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

**Skip this section when the issue carries no marker.** Legacy blockers stop as Phase 7 and Error
Handling describe.

Take this path when a stop condition triggers in Phase 6 or Phase 7, with or without `--auto`:

1. Skip Phases 8, 9 and 11.
2. Write the progress file as Phase 10 describes, with Status `blocked`, everything shown so far,
   and what is partial. Fill in **Blocked on**: the question, and the stop condition that triggered
   (quote the slice's bullet, or name the README rule). Leave README Status and the Retro alone.
3. Stage the partial work and the progress file by name, following **Staging** in `core`, and make
   one commit: `wip: slice {slice_number} {what it does} (blocked)`, with the question and the
   progress file's path in the body, then `Refs #{number}`. Not `Closes`: nothing is ready to close.
   The state now survives a new session or machine.
4. Push the branch: `git push -u origin {branch_name}`.
5. Open no PR. Display `Blocked: slice {slice_number} — {question}`, then emit the Phase 12 JSON
   with `"status": "BLOCKED"`, `"pr": null` and `"pr_url": null`. The keys are unchanged. Under
   the sequential strategy, no later issue starts.

A rerun resumes this branch through Phase 5, and Phase 6 checks whether the question is answered.

---

## Error Handling

If any phase fails:
- Leave the branch intact so the user can inspect it manually
- Display what went wrong clearly
- Don't silently swallow errors
- Don't retry indefinitely — 3 attempts max on any single fix

**Pack slice (conditional).** Skip this when the issue carries no marker. A stop condition is not a
failure to retry: take **Pack mode — Blocked path**, which ends with `status: "BLOCKED"`. A caller
such as `ship-issue` treats that as stuck and opens no PR for it.

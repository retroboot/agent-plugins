---
name: merge-pr
description: Merge a PR or MR, close linked issues, clean up branches, capture follow-up work
license: MIT
compatibility: opencode
---

# Merge PR/MR Workflow

You are a workflow driver. Your job is to take an approved PR or MR through merge, cleanup, and follow-up capture cleanly and completely. Work with momentum — keep moving through the phases and only pause at the marked confirmation checkpoint.

Before starting: read this entire skill, then create a focused todo list, then execute.

You run each command yourself and read its output. There is no merge script — every step below is a command you issue directly, so nothing is hidden from you and nothing depends on a subprocess having a TTY.

This skill no longer ships a command wrapper — `command/merge-pr.md` has been retired now that every
target coder supports invoking a skill directly. The bootstrap chain that command used to run lives
here instead.

---

## Bootstrap

Run in order before Phase 1:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates and git safety

---

## Phase 1 — Parse the Input

The input will be one of these forms:
- A PR/MR number: `99`
- A GitHub PR URL: `https://github.com/owner/repo/pull/99`
- A GitLab MR URL: `https://gitlab.com/group/project/-/merge_requests/99`
- Either of the above with an optional `--auto` flag

Extract:
- `pr_number` — the PR number to merge
- `auto_mode` — true if `--auto` is present
- `strategy_override` — the value of `--strategy squash|merge|rebase` if present, otherwise none

Get the repo: run `git remote get-url origin` and parse the owner and repo name into `repo_slug` (format: `owner/repo`). For GitLab API calls you also need `repo_encoded` — `repo_slug` with `/` replaced by `%2F`.

Display: `Input: PR/MR #{pr_number} | auto: {auto_mode}`

---

## Branch Deletion Safety

**This binds every merge in this skill**, however the merge is performed. Read it before performing any merge step.

Deleting a branch is not cleanup when the branch is long-lived — it destroys an environment. A `dev → staging` promotion merged with `--delete-branch` deletes `dev` both locally and on the remote.

Before deleting a head branch, check all three rules. **If any rule trips, do not delete.**

**Rule 1 — Protected names.** Never delete a head branch in the protected set.

Read `branches.protected` from `.hivrr.json`; see [`config.md`](../init/references/config.md) for the read steps and per-key precedence. When the file or the key is absent, the set defaults to:

```
main, master, dev, develop, staging, release/*
```

Entries may use a trailing `*` wildcard — `release/*` matches any branch whose name starts with `release/`.

**Rule 2 — The base branch.** Never delete a branch equal to the PR's base branch (`baseRefName` / `target_branch`).

**Rule 3 — Branches other PRs target.** Before deleting, confirm no open PR targets the branch:

```bash
# GitHub
gh pr list --repo {repo_slug} --base {head_branch} --state open --json number --jq 'length'

# GitLab
glab api "projects/{repo_encoded}/merge_requests?state=opened&target_branch={head_branch}" --jq 'length'
```

A result greater than `0` means other work is stacked on this branch. Do not delete it.

**If the query itself fails**, treat that as a trip, not a pass. An unevaluable safety rule is not a satisfied one — keep the branch and report that the check could not run.

**When any rule trips:**

- Merge **without** `--delete-branch` (GitHub) or **without** `--remove-source-branch` (GitLab)
- Do not run `git branch -d`/`-D` or `git push origin --delete` against that branch either
- Report `branch_deleted: none` in the completion output
- State which rule tripped, so the skip is visible rather than silent

**When no rule trips:** delete the head branch normally. Feature branches (`issue/N`, `feat/*`, `wave/*`) are unaffected by these rules and continue to be cleaned up.

---

## Phase 2 — Fetch the PR/MR

**GitHub:**
```bash
gh pr view {pr_number} --repo {repo_slug} --json title,body,headRefName,state,baseRefName,reviews
```

**GitLab:**
```bash
glab api projects/{repo_encoded}/merge_requests/{pr_number}
```

Extract `pr_title`, `pr_body`, `head_branch`, `base_branch`, and `pr_state`. GitLab uses `source_branch`/`target_branch`/`description` and lowercase states — normalize `opened → OPEN`, `merged → MERGED`, `closed → CLOSED` so the rest of this skill reads the same either way.

**Handle terminal states before anything else:**

| State | Action |
|---|---|
| `MERGED` | Already merged. Set `already_merged = true`, skip Phases 4–6, and go straight to Phase 7 cleanup. |
| `CLOSED` | Closed without merging. **Stop.** Report that a closed PR cannot be merged. Do not reopen it. |
| `OPEN` | Continue. |

Then count reviews requesting changes — `reviews[].state == "CHANGES_REQUESTED"` on GitHub, `reviewers[].state == "requested_changes"` on GitLab. If any exist, warn but do not stop; the confirmation checkpoint in Phase 5 is where the user decides.

Display: `PR/MR #{pr_number}: "{pr_title}" | state: {pr_state} | {head_branch} → {base_branch}`

---

## Phase 2b — Classify the Merge

Under a dev/staging/main ladder the right merge behavior depends on which rungs are involved. One predicate drives strategy, deletion, and issue-closing — no new flags are needed to detect it.

Read `branches.ladder` from `.hivrr.json`, defaulting to `[default branch]` when absent.

**The promotion predicate: `head_branch` and `base_branch` are BOTH in `branches.ladder`.**

| Head → Base | Promotion? | Strategy | Delete head? | Close issues? |
|---|---|---|---|---|
| `issue/N` → `dev` | no | squash | yes | **yes** |
| `dev` → `staging` | yes | merge commit | no | no |
| `staging` → `main` | yes | merge commit | no | no |

**Derive the strategy:**

- Promotion → **merge commit**. Squashing a promotion would collapse every feature commit on the rung into one, destroying the history that makes the ladder auditable.
- Not a promotion → **squash**.

**`--strategy squash|merge|rebase` overrides the derived value.** When `strategy_override` is set, use it and report that it was overridden — an override that applies silently is indistinguishable from a wrong default.

Deletion is still governed by Branch Deletion Safety. On a promotion both rungs are normally in `branches.protected`, so Rule 1 already prevents deleting the head; the promotion predicate does not replace those rules, it agrees with them.

**Issue-closing on promotions is skipped.** A promotion PR body aggregates every `Closes #N` from the commits beneath it. Those issues were already closed when their `issue/N → dev` PR merged, so re-polling costs a `gh issue view` per issue — each with the Phase 7 retry — to confirm what is already true.

This is the **only** case where skipping is correct. On a feature merge the close loop is mandatory, because closing keywords do not fire on a non-default base.

Store `is_promotion` and `strategy`.

Display: `Merge: {promotion | feature} | strategy: {strategy}{ (overridden)}`

---

## Phase 3 — Extract Linked Issues

Scan `pr_title` and `pr_body` for closing keywords followed by an issue reference. Accept **both** reference forms:

- `#123` — GitHub/GitLab numeric
- `ENG-123` — Linear-style, pattern `[A-Z]+-[0-9]+`

Keywords: `close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, `resolved` — case-insensitive. Deduplicate the results.

Store as `linked_issues`.

Display: `Linked issues: {list | none}`

---

## Phase 4 — Check CI

Skip this phase when `already_merged` is true.

**GitHub:**
```bash
gh pr checks {pr_number} --repo {repo_slug}
```

`gh pr checks` exits non-zero when no checks are configured. Read the output before treating a non-zero exit as an error — text matching `no checks` means "nothing to verify", which is not a failure.

**Exclude `claude-review` from failure detection.** That check is advisory and routinely reports non-success on PRs that are fine to merge; treating it as blocking would wedge every merge. Match its name case-insensitively against both `claude-review` and `claude review`.

A check counts as **failed** when its state is one of `fail`, `failure`, `timed_out`, `cancelled`, `startup_failure`, `action_required`.

A check counts as **unfinished** when its state is `pending`, `queued`, or `in_progress`.

**GitLab:**
```bash
glab api projects/{repo_encoded}/merge_requests/{pr_number}/pipelines | jq -r '.[0].status // "none"'
```

`success` and `none` pass. `failed` and `canceled` are **failed**. `running` and `pending` are **unfinished**.

**Both failed and unfinished block the merge**, and the rule is identical across providers — merging on a pipeline that has not finished defeats the point of checking it. Applying this to only one provider would let the same PR state merge on GitHub and block on GitLab.

**Report them differently**, because they call for different actions — one needs a fix, the other needs a wait:

- Failed → `CI: {n} failing — {names}`. Stop.
- Unfinished → `CI: {n} still running — {names}`. Stop, and say that re-running the command once CI settles will proceed.

Display when clear: `CI: {all checks passed | no checks configured}`

---

## Phase 5 — Confirm

Skip this phase when `auto_mode` is true or `already_merged` is true.

Present the merge summary and **wait for the user's answer**:

```
--- Merge Summary ---
  PR:      #{pr_number} — {pr_title}
  Merge:   {head_branch} → {base_branch}
  Type:    feature | promotion ({head_branch} → {base_branch} on the ladder)
  Method:  {strategy}{ (overridden via --strategy)}
  Branch:  {head_branch} will be deleted | will NOT be deleted ({rule that tripped})
  Issues:  {linked_issues} will be closed | none | skipped (promotion PR)
  CI:      {ci_result}
```

Ask whether to proceed. Anything other than an affirmative answer stops the workflow with nothing merged.

This is a genuine checkpoint, not a formality — it is the last point at which a wrong PR number costs nothing.

---

## Phase 6 — Merge

Skip this phase when `already_merged` is true.

Evaluate the Branch Deletion Safety rules against `head_branch` first, then merge using the `strategy` from Phase 2b.

Map `strategy` to the provider flag:

| `strategy` | GitHub | GitLab |
|---|---|---|
| `squash` | `--squash` | `--squash` |
| `merge` | `--merge` | *(no flag — a merge commit is `glab mr merge`'s default)* |
| `rebase` | `--rebase` | `--rebase` |

**GitHub — no rule tripped:**
```bash
gh pr merge {pr_number} --repo {repo_slug} {strategy_flag} --delete-branch
```

**GitHub — a rule tripped:**
```bash
gh pr merge {pr_number} --repo {repo_slug} {strategy_flag}
```

**GitLab — no rule tripped:**
```bash
glab mr merge {pr_number} --repo {repo_slug} {strategy_flag} --remove-source-branch
```

**GitLab — a rule tripped:**
```bash
glab mr merge {pr_number} --repo {repo_slug} {strategy_flag}
```

If the merge command fails, re-check the PR state before concluding anything — `--delete-branch` can fail on an already-deleted branch *after* the merge itself succeeded, which looks like a failed merge but is not:

```bash
# GitHub
gh pr view {pr_number} --repo {repo_slug} --json state --jq '.state'

# GitLab
glab api projects/{repo_encoded}/merge_requests/{pr_number} --jq '.state'
```

`MERGED` (GitHub) or `merged` (GitLab) means the merge landed and only the deletion failed; continue. Anything else means the merge genuinely failed — report the error and stop.

Record `remote_branch_deleted` (true only when the merge command deleted it) and `branch_deleted` (`{head_branch}` or `none` plus the rule that tripped).

Display: `Merged: PR/MR #{pr_number} → {base_branch} ({strategy})`

---

## Phase 7 — Close Linked Issues

**Skip this phase entirely when `is_promotion` is true** — the closing loop, the parent-closing step, and the board update below. Report `Issues: skipped (promotion PR) | Board: unchanged` and continue to Phase 8. Those issues closed and were marked Done at their feature merge; see Phase 2b for why re-checking them is pure cost.

For every other merge:

**This loop is required, not cleanup. Do not remove it as redundant.**

GitHub honors `Closes #N` in a PR body **only when the PR merges into the repository's default branch**. Once integration moves to `dev`, closing keywords never fire on their own, and this loop becomes the sole mechanism that closes anything. It looks redundant on a repo whose default branch is also its integration branch — that is exactly the situation in which deleting it causes silent damage later.

For each reference in `linked_issues`:

**Linear identifier** (`[A-Z]+-[0-9]+`):
```bash
linear issue update {ID} --state Done
```

**Numeric, GitHub:** check the state first, since a merge into the default branch may already have closed it.
```bash
gh issue view {N} --repo {repo_slug} --json state --jq '.state'
gh issue close {N} --repo {repo_slug}      # only if still OPEN
```

**Numeric, GitLab:**
```bash
glab api projects/{repo_encoded}/issues/{N} --jq '.state'
glab issue close {N} --repo {repo_slug}    # only if still "opened"
```

Auto-close is not instantaneous. If an issue still reads open immediately after the merge, wait ~2 seconds and check **once** more, then close it manually if it is still open. Two checks total — that covers GitHub's auto-close latency and bounds the wait at a couple of seconds. Closing an issue that was about to auto-close is harmless; the second read just keeps the reported count honest.

A failure to close one issue is a warning, not a stop. Continue to the next and report which ones failed.

Collect the references actually closed into `issues_closed`.

Display: `Issues: {count} verified, {count} closed | none`

### Close the parent when its last child closes

GitHub does not do this — a parent whose children are all closed reports `percentCompleted: 100`
and stays `OPEN`. Nothing acts on the rollup, so if this skill does not close the parent, nothing
will.

Skip this entirely when `issues.hierarchy` is disabled or absent. The phase-level skip above
already covers `is_promotion`, so do not re-check it here.

For each reference in `issues_closed`:

1. Read its `parent` using the **Read hierarchy** command from the loaded reference. No parent —
   which is the common case — means nothing to do.
2. Read the parent's `subIssuesSummary` — **after** the children above were closed, never before.
   `completed` reflects state at query time, so a summary read taken before the closing loop reports
   the parent as unsatisfied for every child including the last, and no parent is ever closed. Close
   the parent with the **Close** command **only** when `completed == total` and `total > 0`.
3. Deduplicate by parent **before** step 2, not after. Several children of one epic closing in a
   single merge must produce one close attempt, not one per child — and deduplicating after the
   summary read would still issue one query per child.

A parent that is already closed needs no action. A parent with open children is left open —
**never** close a parent with unfinished children, and never reopen one.

Then mark the closed parent Done on the board using the same rules as its children: if the parent
is not on the board, warn and skip rather than adding it at merge time.

Every step here warns and continues. A failure to close a parent must not affect the merge, which
has already happened.

Collect closed parents into `parents_closed` and include them in the Phase 11 completion JSON.

Display: `Parents closed: {list}` or nothing when none qualified.

### Move the board cards to Done

Reached only on a non-promotion merge — the phase-level skip above already covers promotions, so do not re-check `is_promotion` here.

**Skip silently when `project` is absent from `.hivrr.json`.** See **Board operations** in [`config.md`](../init/references/config.md) for the commands and the shared rules.

For each issue in `linked_issues`:

1. Resolve its item ID
2. If it is not on the board, warn and skip it — do not add an issue to the board at merge time just to immediately mark it Done, which would manufacture a card for work the board never tracked
3. Set Status to Done using `project.statusFieldId` and `project.status.done`

**Warn and continue on any failure.** The merge has already landed; a board error cannot be allowed to make a completed merge look failed.

Display: `Board: {n} issue(s) → Done`, or nothing when unconfigured

---

## Phase 8 — Return to the Base Branch

Switch to the branch this PR actually merged into and update it. **Report its real name** — it is not always `main`:

```bash
git checkout {base_branch}
git pull origin {base_branch}
```

Display: `{base_branch}: updated`

---

## Phase 9 — Clean Up Branches

**Step 1 — This PR's head branch.**

Skip entirely if a deletion rule tripped in Phase 6.

**Worktree cleanup runs before branch deletion — the order is enforced by git, not chosen.**

Skip this sub-step entirely when `worktree` is absent from `.hivrr.json`, and when the merged PR is
a promotion (`is_promotion` true) — promotion branches are long-lived rungs and never have
worktrees.

Check whether a worktree holds the head branch:

```bash
git worktree list --porcelain
```

When one does, work in this order. Skipping a step makes the next one fail:

1. **Leave it.** If this session is inside that worktree, exit with `ExitWorktree` using
   `action: "remove"`. A session cannot remove the worktree it is standing in.

2. **Remove it.** For a worktree this session did not create:

   ```bash
   git worktree remove {path}
   ```

   This **refuses when the worktree has uncommitted or untracked files**:

   ```
   fatal: '{path}' contains modified or untracked files, use --force to delete it
   ```

   That refusal is a safety feature. **Stop and ask** — report the path and what is uncommitted, and
   force only on an explicit answer. Never pass `--force` automatically: the PR merged, so anything
   still uncommitted there is work that never reached it.

3. **Prune.** A worktree whose directory was deleted by hand leaves a `prunable` entry that keeps
   blocking branch deletion:

   ```bash
   git worktree prune
   ```

4. **Then delete the branch,** applying the existing `branches.protected` rules unchanged.

Attempting deletion before this sequence produces:

```
error: cannot delete branch '{branch}' used by worktree at '{path}'
```

Every step warns and continues on failure. The PR has already merged; cleanup failing must not be
reported as a failed merge. Report what was left behind so it can be cleaned by hand.

Display: `Worktree: removed {path}` | `Worktree: left in place — uncommitted work` | nothing when none.

Then delete the branch:

```bash
git show-ref --verify --quiet refs/heads/{head_branch}   # exists locally?
git branch -D {head_branch}
```

If `remote_branch_deleted` is false, delete the remote branch too:

```bash
git ls-remote --heads origin {head_branch}
git push origin --delete {head_branch}
```

**Step 2 — Prune stale local branches.**

Nothing else cleans these up, so they accumulate indefinitely. Note that **ancestry checks do not work here**: this repo squash-merges, so a merged branch shares no commit with the base and `git branch --merged` finds nothing. Use the remote's view instead.

```bash
git fetch --prune
git branch -vv | grep ': gone]'
```

**`: gone]` means the remote ref disappeared — not that the work landed.** A PR closed without merging, a branch someone deleted on the remote, and a force-pushed rename all produce this same signature. Since `git branch -d` is useless here (squash merges leave no shared ancestry, so it refuses on every branch), git's own safety check is unavailable and has to be replaced rather than dropped.

For each candidate, in order:

**1 — Is it protected?** Check the name against the Rule 1 set individually. Never pipe the list straight into a delete. Protected → keep.

**2 — Is it held by a worktree?** Skipped, along with the rest of this phase's worktree handling,
when `worktree` is absent from `.hivrr.json`. A branch checked out in any worktree cannot be
deleted, and the worktree may belong to a live session that is still working:

```bash
git worktree list --porcelain
```

Held → **keep it** and report as `kept: {branch} (held by worktree at {path})`. Never remove a
worktree this skill did not create in order to delete a branch; the head branch handled in Step 1 is
the only worktree this phase acts on.

**This must come before check 3, which deletes.** Check 3 is not a filter — its positive branch runs
`git branch -D`, so a worktree check placed after it never prevents anything: the delete has already
failed with `cannot delete branch … used by worktree`. It is also purely local, so running it first
skips a network call on every held branch. Step 1 already orders the worktree work ahead of its
delete; this keeps the two steps consistent.

**3 — Did it actually merge?**

```bash
# GitHub
gh pr list --repo {repo_slug} --head {branch} --state merged --json number --jq 'length'

# GitLab
glab api "projects/{repo_encoded}/merge_requests?state=merged&source_branch={branch}" --jq 'length'
```

If the query fails, keep the branch — the same rule as Rule 3. A check that could not run is not a check that passed.

- Greater than `0` → the work landed. Delete it:
  ```bash
  git branch -D {branch}
  ```
- `0` → the work did **not** land. **Keep the branch** and report it with its unmerged commit count, so the user can decide rather than discovering the loss later:
  ```bash
  git log origin/{base_branch}..{branch} --oneline | wc -l
  ```

Report skipped branches as `kept: {branch} ({n} unmerged commits)`.

**Step 3 — Report what happened.** Cleanup must be visible, not silent:

```
Cleanup: head {deleted | kept — {rule}} | pruned: {branch names | none}
```

---

## Phase 10 — Capture Follow-up Work

After merge, collect any unaddressed PR/MR feedback that should become future issues. This prevents good suggestions from being lost.

Use the **PR conversation thread** command from the loaded reference to fetch the main discussion thread.

Use the **Latest commit timestamp** command from the loaded reference. Only consider comments whose `created_at` is after that timestamp — these are the most recent round of feedback posted since the last push.

Look for:
- Suggestions that were acknowledged but deferred ("will do in a follow-up")
- Ideas that weren't addressed in the PR/MR
- TODO or FIXME comments added during the review
- Any feedback that doesn't have a clear resolution in the thread

**If `--auto` is set:** Create an issue for every unaddressed suggestion automatically using the **Create issue** command from the loaded reference. Load the label reference from `$CLAUDE_SKILL_DIR/../init/references/labels.md` and use it to select appropriate labels — label critical ones `P1` and optional ones `P2`. The philosophy: capture everything now, triage during implementation.

**If `--auto` is not set:** List the unaddressed suggestions and ask which ones to create issues for.

**If there is no unaddressed feedback:** display "Follow-up: nothing to capture" and skip issue creation.

For each issue created:
- Title: a clear, actionable summary of the suggestion
- Body: context from the PR/MR comment, link back to the PR/MR

Display: `Follow-up: {count} issues created {issue_numbers.join(', ') || ''}`

---

## Phase 11 — Done

Build the completion JSON from what you observed while running the phases above — `pr_number`, `issues_closed` and `parents_closed` from Phase 7, `branch_deleted` from Phase 6, and the follow-up issue numbers from Phase 10.

There is no command here to defer to — `command/merge-pr.md` has been retired. Emit this JSON as
your entire final response — no markdown, no preamble, no trailing text:

```json
{
  "status": "WORKFLOW COMPLETE",
  "pr": {pr_number},
  "issues_closed": [issue_numbers],
  "parents_closed": [issue_numbers],
  "branch_deleted": "{branch_name}",
  "followup_issues": [issue_numbers]
}
```

`branch_deleted` is `"none"` when a branch-deletion safety rule prevented the delete.

Include `parents_closed` as an array, empty when none qualified or when `issues.hierarchy` is off. Omitting the key on a hierarchy-enabled repo is indistinguishable from the operation having failed.

---

## Error Handling

- A closed-but-not-merged PR is a hard stop — never reopen it to force a merge
- Failing CI is a hard stop, `claude-review` excepted
- A failed issue close is a warning; finish the remaining issues and report which failed
- A failed branch delete is a warning; the merge already landed
- Never treat a `--delete-branch` failure as a failed merge without re-checking the PR state first

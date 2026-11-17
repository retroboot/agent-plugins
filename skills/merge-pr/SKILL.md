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

Deleting a branch is not cleanup when the branch is long-lived — it destroys an environment. A `dev → staging` promotion merged with `--delete-branch` deletes `dev` both locally and on the remote. Before deleting a head branch, check all three rules. **If any rule trips, do not delete.**

**Rule 1 — Protected names.** Never delete a head branch in the protected set. Read `branches.protected` from `.hivrr.json`; see [`config.md`](../init/references/config.md) for the read steps and per-key precedence. When the file or the key is absent, the set defaults to `main, master, dev, develop, staging, release/*`. Entries may use a trailing `*` wildcard — `release/*` matches any branch whose name starts with `release/`.

**Rule 2 — The base branch.** Never delete a branch equal to the PR's base branch (`baseRefName` / `target_branch`).

**Rule 3 — Branches other PRs target.** Before deleting, confirm no open PR targets the branch:

```bash
# GitHub
gh pr list --repo {repo_slug} --base {head_branch} --state open --json number --jq 'length'

# GitLab
glab api "projects/{repo_encoded}/merge_requests?state=opened&target_branch={head_branch}" --jq 'length'
```

A result greater than `0` means other work is stacked on this branch. Do not delete it. **If the query itself fails**, treat that as a trip, not a pass. An unevaluable safety rule is not a satisfied one — keep the branch and report that the check could not run.

**When any rule trips:**

- Merge **without** `--delete-branch` (GitHub) or **without** `--remove-source-branch` (GitLab)
- Do not run `git branch -d`/`-D` or `git push origin --delete` against that branch either
- Report `branch_deleted: none` in the completion output
- State which rule tripped, so the skip is visible rather than silent

**When no rule trips:** delete the head branch normally. Feature branches (`issue/N`, `feat/*`, `wave/*`) are unaffected by these rules and continue to be cleaned up.

---

## Phase 2 — Fetch the PR/MR

```bash
# GitHub
gh pr view {pr_number} --repo {repo_slug} --json title,body,headRefName,state,baseRefName,reviews

# GitLab
glab api projects/{repo_encoded}/merge_requests/{pr_number}
```

Extract `pr_title`, `pr_body`, `head_branch`, `base_branch`, and `pr_state`. GitLab uses `source_branch`/`target_branch`/`description` and lowercase states — normalize `opened → OPEN`, `merged → MERGED`, `closed → CLOSED` so the rest of this skill reads the same either way.

**Handle terminal states before anything else:**

| State | Action |
|---|---|
| `MERGED` | Already merged. Set `already_merged = true`, skip Phases 4–6, and go straight to Phase 7 cleanup. Phase 9 then evaluates Branch Deletion Safety itself. |
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

**Issue-closing on promotions is skipped.** A promotion PR body aggregates every `Closes #N` from the commits beneath it. Those issues were already closed when their `issue/N → dev` PR merged, so re-polling costs a `gh issue view` per issue — each with the Phase 7 retry — to confirm what is already true. This is the **only** case where skipping is correct. On a feature merge the close loop is mandatory, because closing keywords do not fire on a non-default base.

Store `is_promotion` and `strategy`.

Display: `Merge: {promotion | feature} | strategy: {strategy}{ (overridden)}`

---

## Phase 3 — Extract Linked Issues

Scan `pr_title` and `pr_body` for closing keywords followed by an issue reference. Accept **both** reference forms:

- `#123` — GitHub/GitLab numeric
- `ENG-123` — Linear-style, pattern `[A-Z]+-[0-9]+`

Keywords: `close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, `resolved` — case-insensitive. Deduplicate the results. Store as `linked_issues`.

Display: `Linked issues: {list | none}`

---

## Phase 4 — Check CI

Skip this phase when `already_merged` is true.

Run the **Check CI** command from the loaded reference — on GitLab, all three of its calls, in
order — and read their output. It sorts every check or job into **passed**, **failed**,
**unfinished** or **manual** (GitLab adds **unknown** when no jobs came back), and the reference
says how each provider's states map onto them. Read job-level state, never just the
pipeline's: a GitLab pipeline reports `success` while a manual job with `allow_failure: true` sits
unplayed, and that is how `sign-bundles` was once skipped and unsigned bundles merged.

**No checks configured passes.** On GitHub, `gh pr checks` exits non-zero when there are none. Read
the output before treating a non-zero exit as an error — text matching `no checks` means "nothing to
verify", which is not a failure. On GitLab, the first call prints `none` when the MR has no pipeline.

**Exclude `claude-review` from every class.** That check is advisory and routinely reports
non-success on PRs that are fine to merge; treating it as blocking would wedge every merge. Match
its name case-insensitively against both `claude-review` and `claude review`, on both providers.
The exclusion is by name, so it cannot clear GitLab's `(pipeline)` row: a pipeline that failed only
because a `claude-review` job did still stops, as it did before job-level checks. Giving that job
`allow_failure: true` in the project's CI config is the fix.

**Optional manual jobs pass, out loud.** A `manual` job whose name is listed in `.hivrr.json`
`ci.optionalManualJobs` does not block — see [`config.md`](../init/references/config.md). Name it in
the clear line below so the skipped job is never silent. The list matches job names only; it never
clears a `(pipeline)` row, because a pipeline whose own status is `manual` is blocked, and its later
stages have not run.

**Failed, unfinished, manual and unknown all block the merge**, and the rule is identical across providers —
merging on a pipeline that has not finished defeats the point of checking it, and a job nobody
played has not finished. GitHub has no manual jobs; its nearest equivalent, a job waiting on an
environment approval, reads as unfinished. Applying any of this to only one provider would let the
same PR state merge on one host and block on the other. `--auto` changes none of it: this skill
never plays a job or approves a deployment itself.

**Report them differently**, because they call for different actions — one needs a fix, one a wait,
one a person, one a look at the fetch:

- Failed → `CI: {n} failing — {names}`. Stop.
- Unfinished → `CI: {n} still running — {names}`. Stop, and say that re-running the command once CI
  settles will proceed. A check waiting on an environment approval settles only when someone
  approves it — say so when a pending check's description says it is waiting.
- Manual → `CI: {n} waiting on a manual job — {names}`. Stop, and say: play the job and re-run once
  it finishes, or, if the job is genuinely optional, add its name to `ci.optionalManualJobs`.
- Unknown → `CI: no jobs returned for pipeline {PIPELINE_ID} — nothing was checked`. Stop, and show
  any error the jobs call printed. It is a failed fetch, not a pipeline that is still running.
- Any Check CI call that exits non-zero, or prints an error on stderr, is a failed fetch too: stop
  with `CI: could not read the pipeline — {error}`. Silence from a failed call is never a pass.
- A GitHub check that stays `pending` long after the rest finished may be a `STARTUP_FAILURE`,
  which `gh` buckets as pending — say so rather than only telling the user to wait.

When more than one class is present, print a line for each, then stop once.

Display when clear: `CI: {all checks passed | no checks configured}`, followed by
`; optional manual job(s) not played — {names}` when any were.

Why every unplayed manual job blocks, not only those whose pipeline reports `manual`: **`ci`** in
[`config.md`](../init/references/config.md).

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

Ask whether to proceed. Anything other than an affirmative answer stops the workflow with nothing merged. This is a genuine checkpoint, not a formality — it is the last point at which a wrong PR number costs nothing.

---

## Phase 6 — Merge

Skip this phase when `already_merged` is true.

Evaluate the Branch Deletion Safety rules against `head_branch` first, then merge using the `strategy` from Phase 2b, mapped to the provider flag:

| `strategy` | GitHub | GitLab |
|---|---|---|
| `squash` | `--squash` | `--squash` |
| `merge` | `--merge` | *(no flag — a merge commit is `glab mr merge`'s default)* |
| `rebase` | `--rebase` | `--rebase` |

Pass the deletion flag only when **no** rule tripped — when one did, run the same command without it:

```bash
# GitHub — drop --delete-branch when a rule tripped
gh pr merge {pr_number} --repo {repo_slug} {strategy_flag} --delete-branch

# GitLab — drop --remove-source-branch when a rule tripped
glab mr merge {pr_number} --repo {repo_slug} {strategy_flag} --remove-source-branch
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

For every other merge, **this loop is required, not cleanup. Do not remove it as redundant.** GitHub honors `Closes #N` in a PR body **only when the PR merges into the repository's default branch**. Once integration moves to `dev`, closing keywords never fire on their own, and this loop becomes the sole mechanism that closes anything. It looks redundant on a repo whose default branch is also its integration branch — that is exactly the situation in which deleting it causes silent damage later.

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

**Only when `issues.hierarchy` is enabled** — when it is disabled or absent, skip this and `parents_closed` is `[]`. The phase-level skip above already covers `is_promotion`. GitHub never closes a parent whose children are all closed, so this skill must: **after** the loop above has finished, read and follow `$CLAUDE_SKILL_DIR/references/hierarchy.md`. Its gates: deduplicate parents first, read each parent's `subIssuesSummary` only after its children closed, and close it only when `completed == total` and `total > 0` — **never** close a parent with open children, and never reopen one. Every step warns and continues. Collect `parents_closed`.

Display: `Parents closed: {list}` or nothing when none qualified.

### Move the board cards to Done

**Only when `project` is present in `.hivrr.json`** — skip silently when it is absent. The phase-level skip above already covers promotions. Read and follow `$CLAUDE_SKILL_DIR/references/board.md` for each issue in `linked_issues` and each closed parent. Its gate: an issue not on the board is warned about and skipped, never added at merge time. Warn and continue on any failure — a board error must not make a completed merge look failed.

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

The full commands and reasons for this phase are in `$CLAUDE_SKILL_DIR/references/cleanup.md`; each step below says which section to read and when. Every step warns and continues on failure: the PR has already merged, so cleanup failing must not be reported as a failed merge. Report what was left behind so it can be cleaned by hand.

**Step 1 — This PR's head branch.** Skip entirely if a deletion rule tripped. If Phase 6 was skipped (`already_merged`), evaluate the Branch Deletion Safety rules against `{head_branch}` here first (`remote_branch_deleted` is false, as no merge command ran): when one trips, keep the local and the remote branch, record `branch_deleted: none` and report which rule tripped.

**Worktree first — only when `worktree` is present in `.hivrr.json` and `is_promotion` is false.** Run `git worktree list --porcelain`. When an entry holds `{head_branch}`, **read and follow cleanup.md § Remove the head branch's worktree before deleting anything** — git refuses to delete a branch a worktree holds. Its one stop: if `git worktree remove` refuses because of modified or untracked files, **stop and ask**, and never pass `--force` without an explicit answer.

Then delete the branch:

```bash
git show-ref --verify --quiet refs/heads/{head_branch}   # exists locally?
git branch -D {head_branch}
# only if remote_branch_deleted is false — the remote branch too:
git ls-remote --heads origin {head_branch}
git push origin --delete {head_branch}
```

**Step 2 — Prune stale local branches.** Always runs: **read and follow cleanup.md § Prune stale local branches.** It lists `: gone]` branches — the remote ref disappeared, **not** proof the work landed — and checks each one individually, in this order, never piping the list into a delete: protected (the Rule 1 set) → keep; held by a worktree (checked only when `worktree` is present) → keep, `kept: {branch} (held by worktree at {path})`; a merged PR for the branch → `git branch -D`; no merged PR, or a query that failed → keep, `kept: {branch} ({n} unmerged commits)`.

**Step 3 — Report what happened.** Cleanup must be visible, not silent:

```
Cleanup: head {deleted | kept — {rule}} | pruned: {branch names | none}
```

---

## Phase 10 — Capture Follow-up Work

Always runs: **read and follow `$CLAUDE_SKILL_DIR/references/followup.md`.** It fetches the thread with the **PR conversation thread** command, keeps only comments newer than the **Latest commit timestamp**, and looks for feedback with no clear resolution. Under `--auto` it creates an issue for every unaddressed suggestion (labelled `P1` critical, `P2` optional); without `--auto` it lists them and asks which to create; with none it displays "Follow-up: nothing to capture".

Display: `Follow-up: {count} issues created {issue_numbers.join(', ') || ''}`

---

## Phase 11 — Done

Build the completion JSON from what you observed while running the phases above — `pr_number`, `issues_closed` and `parents_closed` from Phase 7, `branch_deleted` from Phase 6 (Phase 9 when `already_merged`), and the follow-up issue numbers from Phase 10.

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

`branch_deleted` is `"none"` when a branch-deletion safety rule prevented the delete. Include `parents_closed` as an array, empty when none qualified or when `issues.hierarchy` is off. Omitting the key on a hierarchy-enabled repo is indistinguishable from the operation having failed.

---

## Error Handling

- A closed-but-not-merged PR is a hard stop — never reopen it to force a merge
- CI that is failing, still running, or waiting on an unplayed manual job is a hard stop —
  `claude-review` excepted, and manual jobs listed in `ci.optionalManualJobs` reported, not blocking
- A failed issue close is a warning; finish the remaining issues and report which failed
- A failed branch delete is a warning; the merge already landed
- Never treat a `--delete-branch` failure as a failed merge without re-checking the PR state first

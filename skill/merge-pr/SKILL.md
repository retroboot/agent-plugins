---
name: merge-pr
description: Merge a PR or MR, close linked issues, clean up branches, capture follow-up work
license: MIT
compatibility: opencode
---

# Merge PR/MR Workflow

You are a workflow driver. Your job is to take an approved PR or MR through merge, cleanup, and follow-up capture cleanly and completely. Work with momentum — keep moving through the phases and only pause at the marked confirmation checkpoint.

Before starting: read this entire skill, then create a focused todo list, then execute.

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

Get the repo: run `git remote get-url origin` and parse the owner and repo name into `repo_slug` (format: `owner/repo`).

Display: `Input: PR/MR #{pr_number} | auto: {auto_mode}`

---

## Branch Deletion Safety

**This binds every merge in this skill**, whether the merge runs via a script, via `gh pr merge`, via `glab mr merge`, or by any other means. Read it before performing any merge step.

Deleting a branch is not cleanup when the branch is long-lived — it destroys an environment. A `dev → staging` promotion merged with `--delete-branch` deletes `dev` both locally and on the remote.

Before deleting a head branch, check all three rules. **If any rule trips, do not delete.**

**Rule 1 — Protected names.** Never delete a head branch in this set:

```
main, master, dev, develop, staging, release/*
```

`release/*` matches any branch whose name starts with `release/`.

**Rule 2 — The base branch.** Never delete a branch equal to the PR's base branch (`baseRefName`).

**Rule 3 — Branches other PRs target.** Before deleting, confirm no open PR targets the branch:

```bash
gh pr list --repo {repo_slug} --base {head_branch} --state open --json number --jq 'length'
```

A result greater than `0` means other work is stacked on this branch. Do not delete it.

**When any rule trips:**

- Merge **without** `--delete-branch` (GitHub) or **without** `--remove-source-branch` (GitLab)
- Do not run `git branch -d`/`-D` or `git push origin --delete` against that branch either
- Report `branch_deleted: none` in the completion output
- State which rule tripped, so the skip is visible rather than silent

**When no rule trips:** delete the head branch normally. Feature branches (`issue/N`, `feat/*`, `wave/*`) are unaffected by these rules and continue to be cleaned up.

---

## Phase 2 — Run hivrr-merge.sh

Invoke the merge script, passing the values extracted in Phase 2:

```
bash "${CLAUDE_SKILL_DIR}/scripts/hivrr-merge.sh" \
  --pr {pr_number} \
  --repo {repo_slug} \
  --provider {REPO_PROVIDER} \
  --issue-tracker {ISSUE_TRACKER} \
  [--auto]
```

Include `--auto` only when `auto_mode` is true.

**Before invoking it:** evaluate the Branch Deletion Safety rules above against this PR's head branch. The script deletes the head branch unconditionally — it has no guard. If any rule trips, **do not use the script**. Perform the merge directly with the provider's **Merge PR** command minus its delete flag, then continue from Phase 3.

**If the script exits non-zero:** surface the error output and stop. Do not proceed to Phase 4.

**On success:** the script prints a structured summary line before exiting:

```
HIVRR_MERGE_SUMMARY pr={pr_number} issues_closed={comma_list|none} branch_deleted={branch_name}
```

Parse this line to extract `merged_pr`, `issues_closed` (list of numbers, may be empty), and `branch_deleted`. These values populate the Phase 5 completion JSON.

---

## Phase 3 — Capture Follow-up Work

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

## Phase 4 — Done

Emit the completion JSON as defined in the command's Output section.

---

## Error Handling

- If the script exits non-zero: surface the error and stop — do not proceed to Phase 4
- If follow-up issue creation fails: warn and list the suggestions so the user can create them manually

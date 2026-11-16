---
name: wave
description: Execute multiple related issues in order on a single shared branch
license: MIT
compatibility: opencode
---

# Wave Execution

You implement a group of related issues in sequence on one shared branch. The caller (work-issue) handles verification, review, commit, and PR after you finish.

You receive:
- The ordered list of issue numbers to implement
- The fetched data for each issue (title, body, labels)
- `auto_mode` — whether to skip confirmation prompts

`command/wave.md` has been retired now that every target coder supports invoking a skill directly.
That command's own bootstrap (`init`, `session`, `core`) and its completion JSON were never this
skill's own — the command loaded `work-issue` with the unified wave strategy, and `work-issue`
handled both. Retiring the command changes nothing here: call `work-issue` with a related, small
group of issue numbers to reach this skill, per its own [`## Bootstrap`](../work-issue/SKILL.md) and
[`## Phase 12 — Done`](../work-issue/SKILL.md), whose output shape is the same
`{status, pr, pr_url, branch, issues}` `command/wave.md` used to document.

---

## Step 1 — Determine the Branch Name

Name the branch using the smallest and largest issue numbers in the group, plus the count:

```
wave/{min_issue}-{max_issue}-{count}
```

Examples:
- Issues 123, 124, 125 → `wave/123-125-3`
- Issues 123, 127, 131 → `wave/123-131-3`
- Issues 123 only → `wave/123-123-1`

---

## Step 2 — Create or Resume the Branch

First resolve the **integration branch** — `branches.integration` from `.hivrr.json`, falling back to
the repository default branch when the file or key is absent. Everything below compares against and
forks from that branch, not from `main`. On a ladder repo the integration branch is `dev`, and
assuming `main` there produces a wave summary listing commits that are already merged.

Store it as `{integration}`.

**Worktree (conditional).** Read `worktree` from `.hivrr.json`. When `worktree.enabled` is true
**and** the repo's `CLAUDE.md` authorizes it, run this wave inside a worktree named
`wave/{min}-{max}-{count}` — the same name as the branch. When the key is absent or false, skip this
paragraph entirely and use the branch logic below unchanged.

Follow [`work-issue/references/worktree.md`](../work-issue/references/worktree.md) with
`{branch}` = `wave/{min}-{max}-{count}`. That file is written against `{branch}` for this reason;
everything in it — the existing-worktree check, the create-only re-point, carry, and setup — applies
unchanged. The config key set without the `CLAUDE.md` authorization warns once and continues in the
current checkout; it never fails the wave.

The resume logic below is unchanged and runs **after** entry. Scanning
`git log origin/{integration}..HEAD` inside the worktree yields the same answer as in the main
checkout, because it is the same branch.

Check whether this branch already exists:

```
git ls-remote --heads origin wave/{min}-{max}-{count}
```

**If the branch does not exist:** Fork it from the integration branch rather than from whatever HEAD
happens to be — a wave started while sitting on another task's branch would otherwise carry that
task's commits into its PR:
```
git fetch origin {integration}
git checkout -b wave/{min}-{max}-{count} origin/{integration}
```

**If the branch already exists** (resume case): Switch to it:
```
git checkout wave/{min}-{max}-{count}
git pull origin wave/{min}-{max}-{count}
```

Then check which issues were already implemented by scanning the git log:
```
git log origin/{integration}..HEAD --format="%s %b"
```

Look for issue references (`#123`, `Closes #123`, etc.) in the commit messages. Any issue numbers from your group that appear in the log are already done — mark them as complete and skip them in Step 3.

Display: `Branch: {branch_name} | resuming: {skipped_count} issues already done`

---

## Step 3 — Implement Issues in Order

For each issue in the ordered list (skipping any already completed from Step 2):

**Display:** `Implementing #{number}: {title}`

**Read the requirements:** Look at the issue body. Extract:
- What needs to change
- Acceptance criteria (checkbox items if present)
- Any specific files mentioned

**Implement the changes:**
- Follow existing patterns in the codebase — explore before writing
- Make the smallest change that satisfies this issue's requirements
- Handle errors explicitly

**After implementing:** Run `git diff --name-only` and note the files changed for this issue. Store them in your running implementation record.

**On success:** Proceed to the next issue.

**On failure:** If the failure is critical (git errors, missing data, merge conflict you can't resolve) — stop here and report partial results. If the failure is recoverable (a single file edit failed, a nice-to-have enhancement couldn't apply) — note the warning and continue to the next issue.

---

## Step 4 — Return Results to Caller

When all issues are processed, report back:

```
Wave complete: {completed_count}/{total_count} issues implemented
Branch: {branch_name}
Issues done: {list of completed issue numbers}
Files changed: {total count}

Per-issue summary:
  #{number}: {title} — {files_changed_count} files — {complete|partial|skipped}
  ...
```

If any issues failed or were partial, note them clearly so the caller can decide whether to proceed or abort.

---

## What This Skill Does NOT Do

- Does not run tests
- Does not run lint or type checks
- Does not commit
- Does not create a PR

The work-issue skill handles all of that once, for the entire group together.

---

## Error Handling

- **Git branch errors**: report and stop — don't attempt to implement on a broken branch state
- **Issue data missing**: skip that issue, note it as unimplemented, continue with the rest
- **Merge conflict**: if auto-resolvable, resolve it; if not, stop and report which issue caused it
- **Partial group**: if some issues complete before a critical failure, return what completed — the caller decides whether to commit partial work or discard

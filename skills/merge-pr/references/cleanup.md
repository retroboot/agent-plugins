# Branch cleanup detail

The full procedure behind `merge-pr` Phase 9 (**Clean Up Branches**). `SKILL.md` Phase 9 keeps every
gate and says when to read each section here:

- **Remove the head branch's worktree** — Step 1, only when `worktree` is present in `.hivrr.json`,
  the merge is not a promotion, and a worktree holds the head branch.
- **Prune stale local branches** — Step 2, on every run.

Deletion here is still bound by **Branch Deletion Safety** in `SKILL.md`: the Rule 1 protected set
is the one this file means by "protected", and if a rule tripped, Step 1 does not run. On the already-merged path, where
Phase 6 is skipped, `SKILL.md` Step 1 evaluates the rules itself before deleting anything.

Every step in this file warns and continues on failure. The PR has already merged; cleanup failing
must not be reported as a failed merge. Report what was left behind so it can be cleaned by hand.

---

## Remove the head branch's worktree

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

   ```text
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

4. **Then delete the branch,** applying the existing `branches.protected` rules unchanged — the
   delete commands in `SKILL.md` Phase 9 Step 1.

Attempting deletion before this sequence produces:

```text
error: cannot delete branch '{branch}' used by worktree at '{path}'
```

Every step warns and continues on failure. The PR has already merged; cleanup failing must not be
reported as a failed merge. Report what was left behind so it can be cleaned by hand.

Display: `Worktree: removed {path}` | `Worktree: left in place — uncommitted work` | nothing when none.

---

## Prune stale local branches

Nothing else cleans these up, so they accumulate indefinitely. Note that **ancestry checks do not
work here**: this repo squash-merges, so a merged branch shares no commit with the base and
`git branch --merged` finds nothing. Use the remote's view instead.

```bash
git fetch --prune
git branch -vv | grep ': gone]'
```

**`: gone]` means the remote ref disappeared — not that the work landed.** A PR closed without
merging, a branch someone deleted on the remote, and a force-pushed rename all produce this same
signature. Since `git branch -d` is useless here (squash merges leave no shared ancestry, so it
refuses on every branch), git's own safety check is unavailable and has to be replaced rather than
dropped.

For each candidate, in order:

**1 — Is it protected?** Check the name against the Rule 1 set individually. Never pipe the list
straight into a delete. Protected → keep.

**2 — Is it held by a worktree?** Skipped, along with the rest of Phase 9's worktree handling,
when `worktree` is absent from `.hivrr.json`. A branch checked out in any worktree cannot be
deleted, and the worktree may belong to a live session that is still working:

```bash
git worktree list --porcelain
```

Held → **keep it** and report as `kept: {branch} (held by worktree at {path})`. Never remove a
worktree this skill did not create in order to delete a branch; the head branch handled in Step 1 is
the only worktree Phase 9 acts on.

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

If the query fails, keep the branch — the same rule as Rule 3. A check that could not run is not a
check that passed.

- Greater than `0` → the work landed. Delete it:
  ```bash
  git branch -D {branch}
  ```
- `0` → the work did **not** land. **Keep the branch** and report it with its unmerged commit count,
  so the user can decide rather than discovering the loss later:
  ```bash
  git log origin/{base_branch}..{branch} --oneline | wc -l
  ```

Report skipped branches as `kept: {branch} ({n} unmerged commits)`.

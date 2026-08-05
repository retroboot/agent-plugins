---
name: promote
description: Promote one ladder rung to the next — open the PR, verify CI, merge with a merge commit
license: MIT
compatibility: opencode
---

# Promote

You move a branch up the environment ladder: `dev → staging → main`. This is thin orchestration over the steps `merge-pr` already defines — resolve the next rung, open a PR, verify it is safe, and merge it as a promotion.

**Do not duplicate merge logic.** Phases 4 and 5 hand off to `merge-pr`, which owns branch-deletion safety, CI checking, strategy derivation, and cleanup. This skill's job is deciding *what* to promote and refusing when it is unsafe.

Before starting: read this entire skill, then create a focused todo list, then execute.

---

## Phase 1 — Resolve the Rungs

Parse the input:

- A source branch name: `dev`
- Nothing — default the source to `branches.integration`
- An optional `--auto` flag to skip the confirmation checkpoint

Read `branches.ladder` from `.hivrr.json`; see [`config.md`](../init/references/config.md) for the read steps and per-key precedence. When absent it defaults to `[default branch]`.

Find `{source}` in the ladder. The rung after it is `{target}`.

**Stop with a clear message, not an error, when:**

| Condition | Message |
|---|---|
| The ladder has one rung | `Promote: single-rung ladder ({rung}) — nothing to promote to.` |
| `{source}` is the last rung | `Promote: {source} is the top of the ladder — nothing above it.` |
| `{source}` is not in the ladder | `Promote: {source} is not a ladder rung. Ladder: {ladder}.` |

These are normal outcomes on a repo that has not adopted a ladder. Exit cleanly.

Display: `Promote: {source} → {target}`

---

## Phase 2 — Refuse When Unsafe

Fetch first so every comparison below is against the real remote state:

```bash
git fetch origin {source} {target}
```

**Check 1 — Is the source behind its own upstream?**

```bash
git rev-list --count origin/{source}..{source}   # local ahead of remote
git rev-list --count {source}..origin/{source}   # local behind remote
```

If the local branch is behind `origin/{source}`, **refuse.** Promoting a stale local view ships less than the rung actually contains. Report the gap and tell the user to pull.

**Check 2 — Does the target have commits the source does not?**

```bash
git log origin/{source}..origin/{target} --oneline
```

Any output means the target has work the source lacks — almost always a hotfix applied directly to `staging` or `main`. **Refuse, and list the commits.**

This matters because the merge would appear to succeed while leaving those commits unrepresented in every lower rung. The next promotion from `{source}` then silently reverts them. Report them rather than overwriting:

```
Promote: refused — {target} has {n} commit(s) not in {source}:
  {sha} {subject}
  ...
Back-merge {target} into {source} first, then promote.
```

**Check 3 — Is there anything to promote?**

```bash
git log origin/{target}..origin/{source} --oneline
```

Empty means the rungs are identical. Report `Promote: {target} is already up to date with {source}.` and exit cleanly — this is a no-op, not a failure.

**Check 4 — Is a promotion PR already open?**

```bash
gh pr list --repo {repo_slug} --head {source} --base {target} --state open --json number,url
```

If one exists, do not open a second. Continue from Phase 4 with the existing PR number.

Display: `Checks: {n} commit(s) to promote | target clean`

---

## Phase 3 — Open the Promotion PR

Build the body from what is actually being promoted:

```bash
git log origin/{target}..origin/{source} --oneline
```

```
## Promoting {source} → {target}

{n} commits:

- {sha} {subject}
- ...
```

**Do not include `Closes #N` lines.** The commits beneath a promotion carry their own closing keywords, and those issues closed at their feature merge. Restating them here would make the PR body claim credit for closures it did not perform.

Create the PR with the **Create PR** command from the loaded reference, passing `--base {target}` explicitly:

```bash
gh pr create --repo {repo_slug} --head {source} --base {target} --title "promote: {source} → {target}" --body "{body}"
```

Display: `PR: {url}`

---

## Phase 4 — Confirm

Skip when `--auto` is set.

Show the summary and wait:

```
--- Promotion Summary ---
  Ladder:   {ladder}
  Promote:  {source} → {target}
  Commits:  {n}
  Method:   merge commit
  Branch:   {source} will NOT be deleted
  PR:       {url}
```

---

## Phase 5 — Merge via `merge-pr`

Load the `merge-pr` skill and run it against the PR from Phase 3, passing `--auto` through.

`merge-pr` detects this as a promotion on its own — Phase 2b's predicate is that head and base are both in `branches.ladder`, which is true by construction here. It therefore:

- merges with a **merge commit** rather than a squash
- keeps `{source}`, via Branch Deletion Safety Rule 1 and Rule 2
- skips the issue-closing loop

**Never pass `--strategy squash`** and never delete the source branch by hand. `{source}` is a live environment; the next promotion cycle starts from it.

Display: `Promoted: {source} → {target} (merge commit) | {source} intact`

---

## Phase 6 — Done

Emit the completion JSON as defined in the command's Output section.

---

## Error Handling

- Every refusal in Phase 2 leaves the repo untouched — report why and stop
- A refusal is not a failure: an up-to-date target and a single-rung ladder are both normal
- If `merge-pr` reports the source branch as deleted, that is a bug in the deletion guard — report it loudly rather than treating the promotion as successful

---
name: promote
description: Promote one ladder rung to the next (dev to staging to main) — open the PR/MR, verify CI, merge with a merge commit
license: MIT
compatibility: opencode
---

# Promote

You move a branch up the environment ladder: `dev → staging → main`. This is thin orchestration over the steps `merge-pr` already defines — resolve the next rung, open a PR, verify it is safe, and merge it as a promotion.

**Do not duplicate merge logic.** Phases 4 and 5 hand off to `merge-pr`, which owns branch-deletion safety, CI checking, strategy derivation, and cleanup. This skill's job is deciding *what* to promote and refusing when it is unsafe.

Before starting: read this entire skill, then create a focused todo list, then execute.

This skill no longer ships a command wrapper — `command/promote.md` has been retired now that every
target coder supports invoking a skill directly. The bootstrap chain that command used to run lives
here instead.

---

## Bootstrap

Run in order before Phase 1:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates and git safety

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

**Check 1 — Has the local source diverged from its upstream?**

First, does a local `{source}` branch even exist?

```bash
git show-ref --verify --quiet refs/heads/{source}
```

**If it does not, skip this check entirely.** Not having `dev` checked out locally is the normal state for someone who only ever promotes it, and with no local branch there is no divergence to worry about — the promotion is purely between remote refs. Do not refuse, and do not create the branch.

If it does exist, check **both** directions in one command:

```bash
git rev-list --left-right --count origin/{source}...{source}   # behind<TAB>ahead
```

A promotion PR merges `origin/{source}` into `origin/{target}` — the **remote** branches. The local working copy is not part of what ships, which is what makes each direction matter for a different reason:

- **Behind** (`origin/{source}` has commits the local branch lacks) → **refuse.** Nothing is lost, but the local view disagrees with what will actually be promoted, so the commit list in the Phase 4 summary would understate the promotion. Tell the user to pull.

- **Ahead** (the local branch has commits `origin/{source}` lacks) → **refuse.** This is the case that loses work: unpushed commits are not on the remote branch, so they are **not promoted**, while the user sees "promoted" and reasonably assumes their work shipped. Tell the user to push first.

Report the counts in both cases so the gap is concrete:

```
Promote: refused — {source} has diverged from origin/{source} ({behind} behind, {ahead} ahead).
{Pull before promoting. | Push before promoting — {ahead} local commit(s) would not be promoted.}
```

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

Create the PR with the **Create PR** command from the loaded reference, passing `--base {target}` explicitly.
Commit subjects carry backticks, so the body goes through a file: write it outside the checkout with
a single-quoted heredoc, as the reference's **Bodies always go through a file** says. Use the
`HIVRR_BODY_7f3a` delimiter shown, never `EOF`; if the body holds a line equal to it, choose another.

```bash
file=$(mktemp)
cat > "$file" <<'HIVRR_BODY_7f3a'
{body}
HIVRR_BODY_7f3a
gh pr create --repo {repo_slug} --head {source} --base {target} --title "promote: {source} → {target}" --body-file "$file"
rm -f "$file"
```

Display: `PR: {url}`

---

## Phase 4 — Confirm

Skip when `--auto` is set.

This is the **only** checkpoint in the promotion workflow — Phase 5 suppresses `merge-pr`'s own confirmation. Show the summary and wait:

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

Load the `merge-pr` skill and run it against the PR from Phase 3, **always passing `--auto`** — regardless of whether `--auto` was passed to `promote`.

Phase 4 owns the checkpoint for this workflow. Its summary already shows the rungs, the commit count, the strategy, and the branch disposition, which is everything `merge-pr`'s own summary would restate. Letting both prompt would ask the user to answer twice for one decision.

`merge-pr` detects this as a promotion on its own — Phase 2b's predicate is that head and base are both in `branches.ladder`, which is true by construction here. It therefore:

- merges with a **merge commit** rather than a squash
- keeps `{source}`, via Branch Deletion Safety Rule 1 and Rule 2
- skips the issue-closing loop

**Never pass `--strategy squash`** and never delete the source branch by hand. `{source}` is a live environment; the next promotion cycle starts from it.

Display: `Promoted: {source} → {target} (merge commit) | {source} intact`

---

## Phase 6 — Done

There is no command here to defer to — `command/promote.md` has been retired. Emit this JSON as
your entire final response — no markdown, no preamble, no trailing text:

```json
{
  "status": "WORKFLOW COMPLETE",
  "source": "{source_branch}",
  "target": "{target_branch}",
  "pr": {pr_number},
  "commits_promoted": {n},
  "merged": true
}
```

When promotion is a no-op or was refused, emit the same shape with `"merged": false` and a
`"reason"` field naming the condition.

---

## Error Handling

- Every refusal in Phase 2 leaves the repo untouched — report why and stop
- A refusal is not a failure: an up-to-date target and a single-rung ladder are both normal
- If `merge-pr` reports the source branch as deleted, that is a bug in the deletion guard — report it loudly rather than treating the promotion as successful

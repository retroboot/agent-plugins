# Enter a worktree

Read this file only when `worktree.enabled` in `.agent-plugins.json` is true. Two skills send you here, at
the point where they are about to create their branch:

- `work-issue` Phase 5, **Enter a worktree (conditional)**, with `{branch}` = `issue/{number}`.
- `wave` Step 2, with `{branch}` = `wave/{min}-{max}-{count}`.

Nothing else differs between the two callers. When `worktree.enabled` is absent or false, none of
this applies — the session works in the current checkout exactly as before.

When this file is done, return to the caller's branch logic: in `work-issue`, Phase 5's
**Create the branch**; in `wave`, the resume logic after its worktree paragraph.

## Authorization

Before entering, confirm the repo's `CLAUDE.md` authorizes it (see **Adopting worktrees** in
[`config.md`](../../init/references/config.md)). If the config key is set but the authorization line is
absent, warn once and continue **without** a worktree:

`Worktree: enabled in .agent-plugins.json but not authorized in CLAUDE.md — continuing in the current checkout`

## Existing worktree, or a new one

**Check for an existing worktree first.** Git refuses to check one branch out in two worktrees —
`fatal: '{branch}' is already used by worktree at '…'` — so a resumed run must re-enter its own
rather than create a second. This is a hard error, not a degraded path, which is why the check comes
before the create:

```bash
git worktree list --porcelain
```

- **An entry already holds `{branch}`** — re-enter it with `EnterWorktree` using its `path`, then go
  straight to the caller's branch logic. Skip the re-point, the carry, and the setup: all three ran on
  creation.
- **No entry holds it** — create one with `EnterWorktree` named `{branch}`, then continue with the
  three steps below.

## On creation only

**Re-point the branch — on creation only.** Skip this when you re-entered an existing worktree
above. That branch already carries the earlier session's commits, and `checkout -B` would reset it
to `origin/{integration}` and discard them — the same rule the resume paths in `work-issue` Phase 5
state in full.

On creation, `EnterWorktree` forks per `worktree.baseRef`, whose default (`fresh`) forks from
`origin/<default-branch>` — the wrong rung on a ladder repo, since `branches.integration` is `dev`
and the default branch is `main`. This is the same class of defect
[`github.md`](../../session/references/github.md) already warns about for `gh pr create --base`.
Re-point from inside the worktree rather than depending on a global setting every adopter would have
to change.

**Check origin for `{branch}` first.** A new worktree does not mean new work: the branch may already
exist on origin and not locally — a slice blocked and pushed from another machine, or work resumed
in a fresh clone. Re-pointing that branch to `origin/{integration}` throws its commits away, and the
caller's branch logic then sees a local `{branch}`, takes its resume path, and builds on the
integration branch instead; the later push is rejected as non-fast-forward, or the earlier commits
silently drop out of the PR.

```bash
git fetch origin {integration}
git ls-remote --exit-code --heads origin {branch}    # exit 0 = exists on origin, 2 = it does not
```

Then take exactly one of these two paths:

- **Exit 0 — on origin** (resume) — fetch the branch itself, since the fetch above updated only
  `origin/{integration}`, and re-point to it:
  `git fetch origin {branch}`, then `git checkout -B {branch} origin/{branch}`
- **Exit 2 — not on origin** (new work) — re-point to the integration branch:
  `git checkout -B {branch} origin/{integration}`

Any other exit code means `ls-remote` itself failed (no network, no access): surface the error and
stop rather than guess, because guessing "new work" is exactly the reset this check exists to
prevent.

Resolve `{integration}` exactly as `work-issue` Phase 5's **Create the branch** does
(`branches.integration`, then the repository default branch, then `origin/HEAD`, then `main`).

**Carry untracked files — on creation only.** A worktree receives tracked files only. For each path
in `worktree.carry`, copy it from the original checkout into the worktree — symlink it instead when
it is a large directory such as `node_modules`. A path that does not exist in the source is a
**warning**, not an error: a repo without a `.env` is normal.

**Run setup — on creation only.** If `worktree.setup` is non-null, run it once inside the worktree.
A non-zero exit is a **warning**: report the command and its exit code and continue. A worktree with
missing dependencies is recoverable by hand; aborting loses the session.

Display: `Worktree: {path} | branch: {branch} (from origin/{branch} | origin/{integration}) | carried: {n} | setup: ok | skipped | failed`

# Reader tree and guard

Moved here unchanged from `SKILL.md` Phase 3. Phase 3 uses it for every reader, and the review
panel (`panel.md`) for each pass, as `skills/planning/references/roles/dispatch.md` says.

**Build the reader's tree.** The reader never reads this checkout: uncommitted files and commits on
this branch that `{integration}` lacks are context the pack does not hold, and an executor will not
have them. It reads a detached worktree of `{base}`, outside the checkout, holding the pack and
nothing else that is uncommitted. In every mode but Record only, the pack is copied in from the
working copy, since it is usually uncommitted work in progress; in Record only the reader sees the
pack as `{base}` has it. A dirty checkout is therefore not a stop. In Record only, Phase 2 has
already built this round's tree; use it and skip to the guard below.

Shell variables do not survive from one command to the next, so print the path and write it
into every later command as `{tree}`, the way `{path}` is written. First clear trees an earlier,
interrupted run left registered, and list any that remain; report each one to the developer and
leave it in place:

```bash
git worktree prune
git worktree list --porcelain | grep '^worktree .*/cold-read\.'
mktemp -d "${TMPDIR:-/tmp}/cold-read.XXXXXX"
```

Then, with `{tree}` the path just printed:

```bash
git worktree add --detach "{tree}" {base}
tree="{tree}"; rm -rf "${tree:?}/{path}" && mkdir -p "$tree/{path}" && cp -R {path}/. "$tree/{path}/"
```

Skip the second line in Record only. The tree is new for every round, so it carries the last
round's fixes. Whatever path leaves this phase — a recorded round, a void one, an incomplete
report — remove it first with `git worktree remove --force "{tree}"`; the fixes in Phase 5 go to
this checkout, never to the tree.

Frontmatter `allowed-tools` does not scope a spawned subagent, so when no read-only type exists the
prompt's "change nothing" line is the only guard. Run this before and after every read, from the
checkout, and compare the two outputs; they must be identical:

```bash
find {path} -type f -exec cksum {} + | sort -k3
(cd "{tree}" || exit 1; find {path} -type f -exec cksum {} + | sort -k3; git status --porcelain --untracked-files=all)
```

It covers the pack in the checkout and anything the reader could write in its tree; a missing
tree fails it. A
difference means the reader changed something: the round is void. Say which files changed, remove
the tree, and go to Phase 7.

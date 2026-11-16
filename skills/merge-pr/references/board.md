# Move the board cards to Done

`merge-pr` Phase 7 sends you here **only when `project` is present in `.hivrr.json`**, after its
closing loop (and the parent-closing step, when `issues.hierarchy` is on). When `project` is absent,
skip this silently — board operations are no-ops then.

Reached only on a non-promotion merge — the phase-level skip in `SKILL.md` Phase 7 already covers
promotions, so do not re-check `is_promotion` here.

See **Board operations** in [`config.md`](../../init/references/config.md) for the commands and the
shared rules.

For each issue in `linked_issues`:

1. Resolve its item ID
2. If it is not on the board, warn and skip it — do not add an issue to the board at merge time just
   to immediately mark it Done, which would manufacture a card for work the board never tracked
3. Set Status to Done using `project.statusFieldId` and `project.status.done`

Each parent in `parents_closed` ([`hierarchy.md`](hierarchy.md)) is marked Done by the same steps —
not on the board means warn and skip, never add it.

**Warn and continue on any failure.** The merge has already landed; a board error cannot be allowed
to make a completed merge look failed.

Display: `Board: {n} issue(s) → Done`, or nothing when unconfigured

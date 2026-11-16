# Close the parent when its last child closes

`merge-pr` Phase 7 sends you here **only when `issues.hierarchy` is enabled**, after its closing
loop has finished and `issues_closed` is collected. When `issues.hierarchy` is disabled or absent,
none of this runs. The phase-level skip in `SKILL.md` Phase 7 already covers `is_promotion`, so do
not re-check it here.

GitHub does not do this — a parent whose children are all closed reports `percentCompleted: 100`
and stays `OPEN`. Nothing acts on the rollup, so if this skill does not close the parent, nothing
will.

For each reference in `issues_closed`:

1. Read its `parent` using the **Read hierarchy** command from the loaded provider reference (`github.md`). No parent —
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

Do not mark parents Done here. [`board.md`](board.md), which runs after this step when `project` is
present, marks each parent in `parents_closed` Done by the same rules as its children: not on the
board means warn and skip, never add.

Every step here warns and continues. A failure to close a parent must not affect the merge, which
has already happened.

Collect closed parents into `parents_closed` and include them in the Phase 11 completion JSON.

Display: `Parents closed: {list}` or nothing when none qualified.

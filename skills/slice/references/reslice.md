# Re-slice: revising an existing plan.md

`slice`'s **Re-slice** mode (`SKILL.md` Phase 1). Read it before Phase 2 of any Re-slice, and of a
Slice at `specified` when `plan.md` already exists.

`plan.md` was approved before, and the plan or the route changed since (for example a re-route, or
a cold-read finding). Work through every phase as in Slice, against the `plan.md` already there:

- Never delete it or rewrite it wholesale. Revise it slice by slice, and the traceability table and
  graph with them. Issues are not published yet, so slices may be renumbered.
- For each revised slice, add one line to the README **Open questions**:
  `Revised by slice on {date}: plan.md — Slice {N}, {reason}. Awaiting approval at the next checkpoint.`
  On approval at Phase 5, remove those lines; write "None." if the list is then empty. A stop
  leaves them in place.
- Status is not changed by this run (Phase 6).

Slice at `specified` follows the same revision rules when `plan.md` already exists (an earlier
stopped run), and still sets Status on approval.

## The Planner's `{current}`

In a Re-slice the Planner redrafts `plan.md` (`roles/dispatch.md` **Drafting frame**). Before its
dispatch, record the **reason**: the developer's request, or the cold-read finding that asked for
it, naming the slices it touches. Write `{current}` as a file in a temporary directory of its own,
outside the tree (`mktemp -d`): the reason on its first line, then the current `plan.md` verbatim.
Add it to the Planner's prompt as one line after the Pack line, `Current plan: {current}`.

The Planner returns the whole file with only the slices the reason names revised. A draft that
changes any other slice's text is incomplete (`dispatch.md` **Draft completeness check**): compare
each unnamed slice's section with `{current}`. Remove the directory once Phase 4 has written the
draft.

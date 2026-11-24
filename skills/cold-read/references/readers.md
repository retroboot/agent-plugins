# Parallel readers

How cold-read Phase 3 splits a round's slices among readers, dispatches them, checks each report and
merges them. The prompt, the reader model and the tree procedure are unchanged: Phase 3 gives the
first two, `tree.md` the third. Each reader is new, sees only its own group's slices, and never sees
another reader's report.

## Grouping

The slices are those Phase 1 **Slices to assign** lists, in plan order.

- **The first round of this run** reads every slice. A later run of this skill starts the same
  way: its fixes may predate a re-slice, so no slice is assumed read.
- **A later round** reads only the slices the last round's fixes touched. A slice is touched when
  a fix edited its `## Slice N` section of `plan.md`, or a file its **Files** list names. A slice
  no fix touched is not read again.

**Work out the touched set in Phase 5**, before **Next round, or stop** sends the run back to
Phase 3, from the round's `{diff}` (`panel.md` **Re-check**, **Snapshot**), and before that file is
removed: a slice is touched when a `plan.md` hunk falls inside its `## Slice N` section, or a hunk is
in a file its **Files** list names. Then add each slice whose section the Editor pass's own fixes
edit. Write the set down as `Touched: Slice 2, Slice 6` (or `Touched: none`) and carry that line
into Phase 3; nothing else carries over.

Split those slices into groups of at most 3, in plan order: the first three, the next three, and
the rest. Seven slices make groups 1–3, 4–6 and 7; a size-S pack's one slice makes one group.

**One reader on the whole pack** when there is nothing to group: a pack with no slices (a Spike, an
XL parent, a pack not sliced yet), or a later round whose fixes touched no slice. Its prompt leaves
the slice line out, as Phase 3 says.

Letter the groups `a`, `b`, `c` … in plan order, afresh each round. A round with one reader still
calls it `a`.

## Dispatch

1. **Build every tree first**, one per reader, each as `tree.md` says: one `mktemp -d` per reader,
   then each `git worktree add` and copy, and the guard's first run for each tree, all before any
   dispatch. In Record only, reader `a` uses the tree Phase 2 built; each other reader gets a new
   tree of `{base}`, with the copy line skipped as `tree.md` says.
2. **Dispatch every reader in one step**: one message holding one subagent call per group, so they
   run at once. Each gets the Phase 3 prompt exactly, with its own tree as `{tree}` and its own
   group as `{slices}`; nothing else differs between them.
3. **Run the guard after each read**, against that reader's tree. A difference in any tree voids
   the round, as `tree.md` says: name the reader and the files that changed, remove every tree,
   record the panel's findings (`panel.md` **No reader runs**) and go to Phase 7.

## Check each report

Check each report on its own, against the Phase 3 test: all five sections and at least 8
citations. One reader's citations never count toward another's minimum.

A short report: dispatch one more new reader for that group alone, in that reader's tree, with the
same prompt; the round's other reports wait. A second short report for the same group stops the run:
say `Reader {letter} ({slices}) gave two incomplete reports.`, discard the round's other reports
unrecorded, record the panel's findings (`panel.md` **No reader runs**) and go to Phase 7, which
reports `COLD READ STOPPED`.

Remove every tree once the round's reports are complete, or on any path out of Phase 3.

## Merge

Merge the complete reports into one set of items for Phase 4. Each item keeps its reader's letter
in its Id: question `n` of reader `a` is `aQ{n}`, contradiction `n` of reader `b` is `bC{n}`. Two
readers asking the same thing stay two items; Phase 4 classes each, and one Resolution may answer
both by naming the other's Id.

Display one line per reader:
`Round {N}, reader {letter} ({slices}): {model} — {q} questions ({b} blocking), {c} contradictions, {k} citations checked`.

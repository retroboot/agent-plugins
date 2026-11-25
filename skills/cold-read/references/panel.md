# Review panel

Read this from `SKILL.md` Phase 2, **Review panel**, after the Author Checks. The panel is the
specialists who check the pack before any cold reader sees it, so readers spend their attention on
what only a cold reader can find. Each specialist is a role, defined once in a role card under
`$CLAUDE_SKILL_DIR/../planning/references/roles/`; how to dispatch one is that folder's
`dispatch.md`. Read `dispatch.md` in full before the pass.

## Panel pass

Run once per run, after the Author Checks and before the first reader, in every mode.

1. **The roles.** List `$CLAUDE_SKILL_DIR/../planning/references/roles/`. Every file in it except
   `dispatch.md` is a role card. Read each card's `## Kind`: the panel dispatches every card whose
   kind is `review`, each on its own card, and skips every `draft` or `research` card silently.
   For a card with no `## Kind`, or any other value, say
   `Card {file} states no kind; not dispatched.` and go on without it.
2. **The tree.** Build one tree for the pass as `dispatch.md` **Tree and guard** says, and run the
   guard before dispatching.
3. **Dispatch.** Send one prompt per card, built by `dispatch.md` **Prompt frame** and
   **Model resolution**, all in one step: one message holding every dispatch, so they run at once.
   With no subagent tool, follow `dispatch.md` **No subagent tool** instead.
4. **Guard and completeness.** When every report is in, run the guard again. A difference voids
   the pass: say which files changed, remove the tree (in Record only, Phase 2's tree too), and go
   to Phase 7 with `COLD READ STOPPED`. When an earlier pass of this run fixed any finding (a void
   re-check), first record those findings as **No reader runs** says. Otherwise check each report
   as `dispatch.md` **Completeness check** says, re-dispatching a role alone in a new tree when its report is
   incomplete. Then remove the tree.
5. **Triage** every finding as `dispatch.md` **Triage** says.
6. **Ask** every developer-only finding of the pass, the Trust reviewer's blocking Questionnaire
   rows included, as one **Developer batch** (below), before any fix.
7. **Fix** each blocking finding the author can fix now, and each answered one, by the rules of
   Phase 5 **Fix the pack**, so the pack the readers see already holds the fix. Take the
   **Snapshot** below first. A deferred item is **held**.
8. **Re-check** the fixes as the section below says, before any reader is dispatched.

Display: `Panel: {role} {model} — {f} findings ({b} blocking){, …} | fixed {x}, held {h}`.

## Developer batch

Every developer-only item reaches the developer in **one message**: at most one batch before the
first reader (the panel pass's), and one per reader round. Nothing is asked twice: an item the
developer deferred stays unanswered for the rest of the run. A batch with no items sends no message.

- **Collect**, before the first reader: every finding of the panel pass that triage marked
  developer-only, and every Questionnaire row marked blocking, from all its roles. For a reader
  round: every developer-only item the round's readers raised; every developer-only finding a
  re-check held for this batch (**Re-check**); and the **Sibling scan**'s findings that triage
  marks developer-only, with its Questionnaire rows marked blocking. Never an item already deferred:
  a reader item asking what a deferred item asks is that item, recorded with its Id, still **Not
  answered**.
  Merge duplicates: two roles asking the same thing are one item, listed with both Ids.
- **Send** one message listing each item with its Id, the role's or reader's wording, the file and
  section, and the options the pack leaves open. Then wait for the answer; do not fix, dispatch or
  send a second message in the meantime.
- **Partial answer.** Each answered item is resolved as Phase 5 **Developer-only first** says, its
  Resolution recording the answer and date. Each item left unanswered stays blocking: after a panel
  pass it is **held** and the readers are still dispatched, and the run ends `COLD READ BLOCKED`
  after that round; after a reader round, the run goes to Phase 6 as today.

## Sibling scan

When a reader round's Phase 4 marks any **reader** item developer-only, dispatch the Trust reviewer
once for the round, before the batch and before any fix, in a new tree under the guard as **Panel pass**
steps 2 to 5 say. `{seed}` is a file outside the tree, in a temporary directory of its own, holding
each such item's Id, file and section, and its text verbatim; add it to the prompt as `dispatch.md`
**Prompt frame** says. Triage its findings as **Panel pass** step 5 says, renumber them as **Ids**
below says, and add the developer-only ones and its blocking Questionnaire rows to the round's
batch. They are recorded in the round that triggered the scan, the one Phase 5 is writing. A round
whose readers raised no developer-only item, other than one already deferred, has no sibling scan.

## Re-check

Every fix is checked by someone other than its author. A re-check is a pass: one new tree, the
guard before and after, the dispatches in one step, and each report checked for completeness, all
as **Panel pass** steps 2 to 5 say.

**Snapshot.** Before the first fix of a pass or a reader round, copy the pack to a new temporary
directory outside the checkout and outside any tree (`mktemp -d`, then `cp -R {path}/. "{snap}/"`).
After the fixes, write `{diff}` in a second new temporary directory of its own, with
`diff -ru "{snap}" {path} > "{diff}"`. Each re-check takes a new snapshot before its own fixes.
Remove the snapshot and the `{diff}` directory once that re-check's guard has run.

**Who is dispatched.** The Editor, with `{diff}` added to its prompt as `dispatch.md` **Prompt
frame** says, plus each role whose finding a fix answered, on the fixed pack. Apart from the
Editor, a role with no fixed finding is not dispatched; a fix that answers only an author finding
or a reader item dispatches the Editor alone. With no fixes, there is no re-check.

**After the panel pass: at most two re-checks** in a run, before the first reader (ADR-004).
Triage the re-check's findings as **Panel pass** step 5 says. A fixed finding the role does not
report again is checked. One it reports again, and every new blocking finding, is fixed and
re-checked while the cap allows. **Make no fix after the second re-check**, since no re-check is
left to check it: a fixed finding it reports again is **held** (fixed → held), and a new blocking
finding it reports stays open, unfixed. Both count as Blocking for the round, the readers are
dispatched anyway, and Phase 5 fixes them after the round. A held finding is never re-checked
again in this run.

**Developer-only findings of a re-check.** A developer-only finding a re-check reports, new or
reported again, is not asked before the readers: that would be a second message. It is **held**,
counts as Blocking for the round, and goes in the first reader round's **Developer batch**. One the
developer already deferred stays unanswered.

**After a reader round: one Editor pass.** Phase 5 **Next round, or stop** runs it when it sends
the run back to Phase 3: the Editor alone checks that round's `{diff}` before the next reader. It
is outside ADR-004's cap and bounded by the cap of 3 rounds. Fix what it finds; a blocking finding
not fixed counts as Blocking in the next round. When the run stops instead, there is no Editor pass.

**Ids.** Every role numbers its findings from `P{letter}1`, so the Facilitator renumbers the
findings of each re-check and sibling scan: one that matches an earlier finding keeps that
finding's Id, which is how a finding "reported again" is told apart; any other takes the next free
`P{letter}{n}` Id in the run. Re-check findings are recorded with the pass's findings, in the round
that follows. The summary line names each re-check pass, its roles and its findings.

Display: `Re-check {k}: {roles} — {f} findings ({b} blocking) | checked {c}, held {h}`.

## Recording panel findings

Panel findings go in the Questions table of the round that follows the pass, beside the author
findings, with Ids `P{letter}{n}` (`PF1`, `PF2` …; re-check and sibling scan findings renumbered
as **Ids** says) and the checklist item in the Gap. Each is classed as an author finding is in Phase 4:

- **Fixed** before the readers were dispatched: it does not block the round, since the reader saw
  the fixed pack. Its Resolution says what changed.
- **Held** (developer-only, or a deferred answer): it counts as Blocking for the round, even if
  Phase 5 fixes it, because no reader has seen the fix. The readers are still dispatched, and the
  run ends `COLD READ BLOCKED` after that round when the developer defers it.
- **Record only** mode: every panel finding is held and counts as Blocking; its fix is written as
  `Proposed: …` in its Resolution, as for author findings.

The round's summary paragraph gains one line for the pass: each role, its model as recorded, its
findings and how many were blocking, any `Sibling scan: Trust {model} — {f} findings ({b} blocking)`
line, `Trust: no outside inputs.` when the Trust reviewer's
Questionnaire is empty, plus `Panel run by the Facilitator: not independent.` or any
`Panel: {role} gave no complete report; not reviewed by {role}.` line the pass produced.

**No reader runs.** When the run stops before this run recorded a round (a void re-check before
the first reader, no subagent for the readers, or a Phase 3 stop after a reader was dispatched: a
void round or two incomplete reports), there is no round for the findings to go in. Write them in
the closing `## Result` of `cold-read.md`, under `### Panel without a reader`, in the Questions
table form and the shape `result.md` gives. When the file does not exist, write it
from the template first and add its README **Read order** entry as Phase 5 **Write the round** does
(in Record only, as a `Proposed:` line in the Result). The fixes stay in the pack. When the stop
comes after this run recorded a round, the panel's findings are already in its first round: add
nothing.

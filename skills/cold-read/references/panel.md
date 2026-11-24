# Review panel

Read this from `SKILL.md` Phase 2, **Review panel**, after the Author Checks. The panel is the
specialists who check the pack before any cold reader sees it, so readers spend their attention on
what only a cold reader can find. Each specialist is a role, defined once in a role card under
`$CLAUDE_SKILL_DIR/../planning/references/roles/`; how to dispatch one is that folder's
`dispatch.md`. Read `dispatch.md` in full before the pass.

## Panel pass

Run once per run, after the Author Checks and before the first reader, in every mode.

1. **The roles.** List `$CLAUDE_SKILL_DIR/../planning/references/roles/`. Every file in it except
   `dispatch.md` is a role card; the panel dispatches every card it finds, each on its own card.
2. **The tree.** Build one tree for the pass as `dispatch.md` **Tree and guard** says, and run the
   guard before dispatching.
3. **Dispatch.** Send one prompt per card, built by `dispatch.md` **Prompt frame** and
   **Model resolution**, all in one step: one message holding every dispatch, so they run at once.
   With no subagent tool, follow `dispatch.md` **No subagent tool** instead.
4. **Guard and completeness.** When every report is in, run the guard again. A difference voids
   the pass: say which files changed, remove the tree (in Record only, Phase 2's tree too), and go
   to Phase 7 with `COLD READ STOPPED`. Otherwise check each report as `dispatch.md`
   **Completeness check** says, re-dispatching a role alone in a new tree when its report is
   incomplete. Then remove the tree.
5. **Triage** every finding as `dispatch.md` **Triage** says.
6. **Fix** each blocking finding the author can fix now, by the rules of Phase 5 **Fix the pack**,
   so the pack the readers see already holds the fix. Take the **Snapshot** below first. A
   developer-only finding is held, as a developer-only author finding is in Phase 2, and asked in
   Phase 5 **Developer-only first**.
7. **Re-check** the fixes as the section below says, before any reader is dispatched.

Display: `Panel: {role} {model} — {f} findings ({b} blocking){, …} | fixed {x}, held {h}`.

## Re-check

Every fix is checked by someone other than its author. A re-check is a pass: one new tree, the
guard before and after, the dispatches in one step, and each report checked for completeness, all
as **Panel pass** steps 2 to 5 say.

**Snapshot.** Before the first fix of a pass or a reader round, copy the pack to a new temporary
directory outside the checkout and outside any tree (`mktemp -d`, then `cp -R {path}/. "{snap}/"`).
After the fixes, write `{diff}`, a file beside the snapshot, with `diff -ru "{snap}" {path}`. Each
re-check takes a new snapshot before its own fixes.

**Who is dispatched.** The Editor, with `{diff}` added to its prompt as `dispatch.md` **Prompt
frame** says, plus each role whose finding a fix answered, on the fixed pack. A role with no fixed
finding is not dispatched, and neither is any role on a fix that answers only an author finding or
a reader item. With no fixes, there is no re-check.

**After the panel pass: at most two re-checks** in a run, before the first reader (ADR-004).
Triage the re-check's findings as **Panel pass** step 5 says. A fixed finding the role does not
report again is checked. One it reports again, and every new blocking finding, is fixed and
re-checked while the cap allows. After the second re-check, every finding still blocking is
**held**: recorded so, counted as Blocking for the round, and the readers are dispatched anyway.
A held finding is never re-checked again in this run.

**After a reader round: one Editor pass.** When Phase 5 **Next round, or stop** will send the run
back to Phase 3, the Editor alone checks that round's `{diff}` before the next reader. It is outside
ADR-004's cap and bounded by the cap of 3 rounds. Fix what it finds; a blocking finding not fixed
is held in the next round. When the run is about to stop, skip it.

Re-check findings take the next free `P{letter}{n}` Id in the run and are recorded with the pass's
findings, in the round that follows. The summary line names each re-check pass, its roles and its
findings.

Display: `Re-check {k}: {roles} — {f} findings ({b} blocking) | checked {c}, held {h}`.

## Recording panel findings

Panel findings go in the Questions table of the round that follows the pass, beside the author
findings, with Ids `P{letter}{n}` as the role gave them (`PF1`, `PF2` …) and the checklist item in
the Gap. Each is classed as an author finding is in Phase 4:

- **Fixed** before the readers were dispatched: it does not block the round, since the reader saw
  the fixed pack. Its Resolution says what changed.
- **Held** (developer-only, or a deferred answer): it counts as Blocking for the round, even if
  Phase 5 fixes it, because no reader has seen the fix. The readers are still dispatched, and the
  run ends `COLD READ BLOCKED` after that round when the developer defers it.
- **Record only** mode: every panel finding is held and counts as Blocking; its fix is written as
  `Proposed: …` in its Resolution, as for author findings.

The round's summary paragraph gains one line for the pass: each role, its model as recorded, its
findings and how many were blocking, plus `Panel run by the Facilitator: not independent.` or any
`Panel: {role} gave no complete report; not reviewed by {role}.` line the pass produced.

**No reader runs.** When the run stops before a round is recorded (no subagent for the readers,
or a Phase 3 stop after a reader was dispatched: a void round or two incomplete reports), there is
no round for the findings to go in. Write them in the closing `## Result` of `cold-read.md`, under
`### Panel without a reader`, in the Questions table form. When the file does not exist, write it
from the template first and add its README **Read order** entry as Phase 5 **Write the round** does
(in Record only, as a `Proposed:` line in the Result). The fixes stay in the pack.

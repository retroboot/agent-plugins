# Gate procedure

How `spec` and `slice` check a drafted file before the checkpoint that shows it. A **gate** is one
step of reviewing roles, dispatched by the Facilitator after the stage's file is written. Every
role in it runs as `roles/dispatch.md` says, the review side: **Model resolution**, **Prompt frame**,
**Tree and guard**, **Completeness check** and **Triage**. Read `dispatch.md` in full before a gate.

| Gate | Run by | Roles |
|---|---|---|
| Context | `spec` Phase 2, after `context.md` is written | Fact-checker |
| Acceptance | `spec` Phase 3, after `prd.md` (or the size S Slice) is written | Fact-checker and Trust reviewer, one step |
| Slice | `slice` Phase 4, after the Self-check | Test engineer and Editor, one step |

The design stage has no gate. A stage the route skips dispatches nothing.

## Gate pass

1. **Tree.** Build one tree from `{base}` (`dispatch.md` **Base**, resolved once per run) as
   **Tree and guard** says, and run the guard.
2. **Dispatch.** One review-frame prompt per role of the gate, all in one message, so they run at
   once. With no subagent tool, follow `dispatch.md` **No subagent tool**.
3. **Guard and completeness.** When every report is in, run the guard again. A difference voids the
   gate: say which files changed, remove the tree, and the skill stops `{SKILL} STOPPED` with Status
   unchanged and the files on disk. Otherwise check each report as **Completeness check** says,
   re-dispatching a role alone, once, in a new tree. A dispatch the tool ends with an error or no
   report, or one the developer interrupts, is an incomplete report; there is no time limit. A
   second incomplete report: say `Gate: {role} gave no complete report; not reviewed by {role}.`
   and go on without it. Remove the tree.
4. **Triage** every finding as **Triage** says, then renumber it (**Ids**).
5. **Fix**, then go to **Re-check**.

**Ids.** Each role numbers its findings `P{letter}1`, `P{letter}2` …, as the review frame says. The
Facilitator renumbers every gate finding `G{letter}{n}` (`GF1`, `GT1`, `GV1`, `GE1`), never `P…`,
which `cold-read` gives the panel. Numbering continues from the highest `G{letter}` Id in the
README **Open questions** `Deferred at …` lines and in `handoff.md`. A re-check finding that
matches an earlier one keeps its Id. A finding that matches a deferred item names that item's Id
and is not raised again: it is neither fixed nor asked. A Trust reviewer's Questionnaire row takes
its finding's `G` Id.

**Fix.** Fix each blocking finding you can, in a file the skill may edit: `spec` any spec file,
`slice` only `plan.md`. Take the **Snapshot** in `$CLAUDE_SKILL_DIR/../cold-read/references/panel.md`
first. A fix that needs a file the skill may not edit is **held**, and so is every developer-only
finding. In `slice`, the Phase 4 Self-check runs again on the fixed `plan.md` before the re-check; a
failure is fixed once, then held. A non-blocking finding is fixed when cheap; otherwise it is
counted in the gate's **Display** line and listed under it at the checkpoint, never asked.

## Re-check

One per gate (ADR-006). With no fixes, there is none. Write
`{diff}` as panel.md **Snapshot** says, then dispatch each role with a fixed finding once more,
with `{diff}` added to its prompt, in one step, in a new tree, under the guard and completeness
check of **Gate pass** steps 1 to 3.

- A fixed finding the role does not report again is **checked**.
- A fixed finding it reports again, and a new blocking finding, is **held**, never fixed again in
  this gate.
- A new non-blocking finding is listed at the checkpoint under the gate's **Display** line, not
  fixed.

Remove the snapshot and the `{diff}` directory once the re-check's guard has run.

## Held

Every item below waits for the next checkpoint's **Checkpoint batch**:

- developer-only findings, and blocking Questionnaire rows;
- findings held by **Fix** or by the **Re-check**;
- `false` probes;
- each drafter's blocking or developer-only open points (`dispatch.md` **Draft completeness check**).

The Scout's and the Analyst's open points and the context gate's held items wait for the
acceptance checkpoint; the Architect's for the design checkpoint; the Planner's and the slice
gate's for the slice checkpoint. **Nothing is asked between stages:** a gate sends the developer no
message. Until its checkpoint, each held item is in `handoff.md` (**Handoff**).

## Checkpoint batch

The checkpoint that shows a stage's file sends every item held for it in **one message**: the
checkpoint's own content, then each item with its Id, the role's wording, the file and section,
and the options the pack leaves open, then the checkpoint's question. Two roles asking the same
thing are one item, listing both Ids. A deferred item is never asked again. With no items, the
checkpoint is shown as before.

**Answer.** Write each answer into the file it concerns, with the date. An answer that chooses
between options is a developer-stated choice, so `spec` Phase 5 records it as an `accepted` ADR.
`slice` never edits a spec file: at the slice checkpoint, an answer that needs the prd, the design
or an ADR changed is written to `handoff.md` as a **Spec pending** entry (**Handoff**), and `slice`
stops with `Stopped: {Id} needs a spec change — next: planning {path} revise spec.`

**Deferral.** A deferred item becomes one README **Open questions** line, replacing "None.":
`Deferred at the {acceptance | design | slice} checkpoint on {date}: {Id} — {question}.` At the
acceptance and design checkpoints a deferral does not withhold Approve, since the panel and the cold
read meet the item again; a blocking item neither answered nor deferred does. At the slice
checkpoint a deferred **blocking** item withholds Approve: offer change or stop, and a stop says
`Stopped: {Id} unanswered — next: planning {path} revise spec.`

## Display

After the pass, one line for the gate:
`Gate {stage}: {role} {model} — {f} findings ({b} blocking){, …} | fixed {x}, held {h}`. After the
re-check: `Gate {stage} re-check: {roles} — {f} findings | checked {c}, held {h}`. The checkpoint
repeats each gate's lines as its summary (ADR-007), with the non-blocking findings listed under
them.

## Handoff

`{path}/handoff.md` holds the work in flight between runs (ADR-008), written from
`$CLAUDE_SKILL_DIR/../planning/references/templates/handoff.md`. It exists only while an entry is
pending, and it is never the place for an answer, a fix or a deferral, which go into their files.

- **Gate pending: {file}**, for `context.md`, `prd.md`, `design.md` and `plan.md` alike. Write it
  in the step that writes the stage's file, and update it as the gate runs: the drafting line,
  every trust and fallback line (**Base**, Facilitator and `not reviewed` lines), each held item as
  `Id | Question | Options | Blocking`, and `Fix not re-checked` from the first fix until the
  re-check's guard has run.
- **The checkpoint that shows the file removes its entry**, after the answers are written and the
  deferrals are Open questions lines. Delete `handoff.md` when its last entry goes. A stop at the
  checkpoint leaves the entry.
- **Resume.** A run that finds a Gate pending entry for a file dispatches no drafter for it: it
  re-runs only that file's gate, on the file as it stands, keeping the entry's Ids and held items,
  and the re-run is the check of any `Fix not re-checked`. For `design.md`, which has no gate, it
  goes straight to the design checkpoint with the entry's lines and open points.
- **Spec pending: {Id}**, written by a `slice` spec-change stop (**Answer**): the item's Id, its
  file and section, the answer and the date. `planning` Resume reads `handoff.md` before the README
  pending lines and resumes this entry at Phase 4, Specify, passing the answer as `spec`'s request.
  `spec` removes the entry when the checkpoint that shows the revised file approves.
- `planning` refuses Approve and Publish while `handoff.md` exists, and its Resume takes a Gate
  pending entry to the phase that owns the file, whatever the Status, so the refusal has a way out.

# Planning team — role gates in spec and slice

| | |
|---|---|
| **Status** | done |
| **Type** | Feature |
| **Size** | M — 5 slices |
| **Modifiers** | none |
| **Issues** | #270–#274 (Slices 1–5) |
| **Owner** | retroboot |
| **Opened** | 2026-11-24 |

## Brief

Child 2 of the XL parent [`../planning-team/README.md`](../planning-team/README.md), which states
the problem: one author agent writes every pack file in one context and has to remember every
check, so problems surface late, one per cold-read round. Child 1
([`../planning-team-review/`](../planning-team-review/README.md), done) added the role card format,
the dispatch and triage contract, and the review panel (Fact-checker, Editor, Test engineer, Trust
reviewer) that checks a finished pack before the cold read.

The outcome wanted is that `spec` and `slice` catch problems in the stage that creates them, by
staffing each stage with role subagents instead of one author:

- A **Scout** writes `context.md`, and the **Fact-checker** gates it before anything is built on it.
- An **Analyst**, an **Architect** and a **Planner** draft the prd, the design and the slices.
- The prd's **assumption probes** (its "how to validate" column) are run before the design is
  written, as measuring first did for hyalOS core.
- The **Trust reviewer**'s questionnaire goes out as one batch at the acceptance checkpoint, not
  one question per cold-read round.
- The **Test engineer** and **Editor** check the slice draft before the slice checkpoint.

Scope: the `planner` plugin's `spec` and `slice` skills, new role cards under
`skills/planning/references/roles/` in child 1's card format, and the templates they write. The
review panel, the cold read and the `planning` wrapper's roster by route are out of scope (children
1 and 4), apart from the panel dispatching `review` cards only, the Fact-checker's F7, and
`planning` reading the transient `handoff.md`, resuming from it and refusing Approve and Publish
while it exists (ADR-004, ADR-005, ADR-008). Depends on child 1.

Child 1's Retro carries three lessons into this pack: dry runs walk any rule that crosses phases
live, through every phase it crosses; every computed value states when it is made and from what;
and each slice's **Depends on** is checked against every artifact it uses.

## Route

- **Feature:** adds role subagents (Scout, Analyst, Architect, Planner) and stage gates to `spec`
  and `slice`; the pack contract stays, the behaviour that produces it changes.
- **M:** 5 slices: the drafting contract and the Scout; the Fact-checker gate on `context.md` and
  the checkpoint batch; the Analyst, the acceptance gate and the assumption probes; the Architect;
  the Planner with the Test engineer and Editor gate. `spec` and `slice` are near the 400-line cap, so
  procedure goes to `references/`, as child 1 did for `cold-read`.
- **No modifiers:** Markdown skills only; no UI, data, runtime or public API.

## Read order

1. This file, including **How to execute this pack** below
2. [`prd.md`](prd.md): problem, goals, non-goals, stories and acceptance criteria
3. [`context.md`](context.md): what exists today, with file citations, conventions and glossary
4. [`decisions/`](decisions/): the decisions and the options rejected
5. [`design.md`](design.md): architecture, contracts and modifier sections
6. [`plan.md`](plan.md): the slices, their order and acceptance criteria per slice
7. `progress/`: one file per slice once execution starts
8. [`cold-read.md`](cold-read.md): results of the cold-read review of this pack

## How to execute this pack

These rules are the same in every pack. They live here so an executor needs nothing but this
folder and the repository.

1. **Work one slice at a time.** A slice is one issue and one PR. Its issue body carries a line
   `Plan: docs/plans/planning-team-spec · Slice: N`.
2. **Preflight before editing.** Confirm that every path and symbol `context.md` cites, and that
   your slice touches, still exists as described. Record anything that differs in your slice's
   progress file as a deviation. If the difference touches your slice's **Contracts**, stop.
3. **Mandatory beats guide.** In `plan.md`, every slice's **Outcome**, **Acceptance**,
   **Contracts**, **Stop conditions** and **Verify** are mandatory. **Pattern to follow**,
   **Suggested path** and **Files** are guidance. You may leave the suggested path if every
   mandatory item still holds. Record why in your progress file.
4. **Trace acceptance.** Every acceptance criterion ID in your slice (for example `S-04.2`), and
   every example row under it in the PRD's **Rules and examples** (for example `S-04.3.e1`), must be
   shown to hold. Use a test that names the ID or, where the repo has no test runner, a verification
   step recorded against the ID in your progress file. Follow the levels in the design's **Test
   strategy**.
5. **Stop conditions are hard stops.** When one triggers, stop, leave the branch intact, write the
   blocking question into your progress file with status `blocked`, and report. Do not work around it.
6. **Do not silently edit the plan.** If the PRD, an ADR, `design.md` or another slice turns out to
   be wrong, record it as a deviation. If it changes a contract, that is a stop.
7. **Write your progress file** at `progress/slice-NN.md` (`NN` is the slice number, zero-padded)
   and commit it in the same PR as the slice. Give it these sections, in order:
   - **Header:** Status (`in-progress`, `blocked` or `done`), Issue, PR, Executor model if known,
     Date.
   - **Preflight:** each citation checked, and whether it holds.
   - **Acceptance:** each criterion ID and example ID, and how it was shown.
   - **Deviations:** a table of plan said / reality / why / contract affected (y/n).
   - **Decisions:** choices the plan left open.
   - **Discoveries:** what the next slice or the retro should know.
   - **Blocked on:** only when blocked; the question and the stop condition that triggered.

   If this README's Status is `published`, change it to `executing` in the same commit.
8. **Close the pack when you finish the last slice.** If every other slice's progress file says
   `done`, add a **Retro** section to this README in the same PR and set **Status** to `done`.

## Open questions

None.

## Retro

| Cold read predicted | What diverged | Slice | Lesson for the next pack |
|---|---|---|---|
| Pass after 3 rounds: the pack was complete | Every slice PR's review found a route branch the pack never named: size S with a prd (3), a drafter for an existing file in a re-route (4), the Re-slice exception to that rule (5) | 3, 4, 5 | Adopt cold-read proposal F9: read every route branch of each phase a slice changes |
| Gates continue `G` Ids from Deferred lines and `handoff.md` | A non-blocking Id from a first pass, never held, was reused by a resumed pass | 2, 3 | Number from every Id a pass reported, not only the held or deferred ones |
| `spec` and `slice` had room for a pointer per step (A, `wc -l` at most 385) | `spec` ended at 398 and `slice` at 398, the latter only after moving Re-slice out (R2) | 1 to 5 | Move reference text out before adding pointers, not when the budget runs out |
| Seeds would be applied per dry run | One live dispatch served several seeds in Slices 4 and 5, and the drafters' own open points caught fixture defects nobody seeded | 3, 4, 5 | Plan seeds per dispatch, and treat a drafter's open points on a fixture as findings |
| S-06.4.e1: the Spec pending approval leaves no `handoff.md` | The slice stop's `Gate pending: plan.md` entry keeps the file until the next slice checkpoint | 5 | Write examples about a shared file against every entry it can hold |

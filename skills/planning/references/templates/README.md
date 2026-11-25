# <Title>

| | |
|---|---|
| **Status** | <discovered \| routed \| specified \| sliced \| reviewed \| approved \| published \| executing \| done> |
| **Type** | <Change \| Bug \| Spike \| Feature \| Refactor \| Migration \| Greenfield \| Rewrite> |
| **Size** | <S \| M \| L \| XL> — <n> slices |
| **Modifiers** | <none, or a comma-separated list> |
| **Issues** | not yet published |
| **Owner** | <git config user.name> |
| **Opened** | <YYYY-MM-DD> |

## Brief

_Guidance: the problem, the outcome wanted and the scope, in a few short paragraphs. A reader who
stops here should know what this work is for._

## Ruled out

_Brainstorm only. Guidance: each option considered and dropped, with the reason. Delete this section
if the Discover step was skipped._

## Key insights

_Brainstorm only. Guidance: what the discovery conversation learned that changes the plan. Delete
this section if the Discover step was skipped._

## Child packs

_XL parent only; delete otherwise. Guidance: one row per child pack, in execution order. A child
closed without planning keeps its row, marked as `pack-format.md` §3 says._

| Order | Pack | Covers | Depends on |
|---|---|---|---|
| 1 | `docs/plans/<slug>-<part>` | <scope> | none |

## Question

_Spike only; delete otherwise. Guidance: the single question the spike answers, and its timebox.
The outcome is written as an ADR, then the pack is re-routed._

- **Question:** <what must be learned>
- **Timebox:** <hours or days>

## Repro and root cause

_Bug only; delete otherwise. Guidance: exact steps to reproduce, expected versus actual, and the
root cause, folding in the `debug` report if one was run._

## Slice

_Size S only; delete at M and larger, where `plan.md` holds the slices. `spec` writes this section.
It is the pack's single slice, and its issue carries `Slice: 1`._

Issue: # · Depends on: none

### Outcome

_Guidance: one or two sentences describing the observable result._

### Acceptance

_Guidance: criteria `1.k`, written as rules and examples. Each rule has an examples table of at
least 2 rows, including at least one edge or failure case. A When shared by every row may sit in
the column header._

- **1.1** <rule>

| ID | Given | When | Then |
|---|---|---|---|
| 1.1.e1 | <state> | <action> | <result> |
| 1.1.e2 | <edge or failure state> | <action> | <result> |

**Failure note:** _Guidance: one line naming the main failure and what the user sees._

### Contracts

_Guidance: interfaces this slice creates or changes, as tables (name, inputs, outputs, errors,
invariants). Write "None new." when there are none._

### Stop conditions

- Stop if a contract this slice depends on has drifted from `context.md` (preflight).
- _Guidance: add one "Stop if …" bullet per situation the executor must not improvise through._

### Verify

_Guidance: exact commands in a `bash` fence, each with its expected output, then the dry-run
scenarios for behavioural criteria._

### Pattern to follow

_Guide. Guidance: `path:line` of existing work to imitate._

### Suggested path

Default route. You may deviate if every mandatory item still holds; record why.

1. _Guidance: ordered steps._

### Files

_Guide. Guidance: expected create, modify and delete list._

## Route

- **<Type>:** _<one-line reason>_
- **<Size>:** _<one-line reason>_
- **<Modifiers, or "No modifiers">:** _<one-line reason>_

## Read order

_Guidance: whichever skill adds a file to the pack also adds it here. Keep this order._

1. This file, including **How to execute this pack** below
2. [`prd.md`](prd.md): problem, goals, non-goals, stories and acceptance criteria
3. [`context.md`](context.md): what exists today, with file citations, conventions and glossary
4. [`decisions/`](decisions/): the decisions and the options rejected
5. [`design.md`](design.md): architecture, contracts and modifier sections
6. [`inventory.md`](inventory.md): usage sites, or behaviour inventory and parity
7. [`ux.md`](ux.md): screens, flow, wireframes and states
8. [`plan.md`](plan.md): the slices, their order and acceptance criteria per slice
9. `progress/`: one file per slice once execution starts
10. [`cold-read.md`](cold-read.md): results of the cold-read review of this pack

## How to execute this pack

These rules are the same in every pack. They live here so an executor needs nothing but this
folder and the repository.

1. **Work one slice at a time.** A slice is one issue and one PR. Its issue body carries a line
   `Plan: docs/plans/<slug> · Slice: N`.
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

_Guidance: anything still undecided, and every section revised by a re-route until the developer
approves it. Write "None." when empty._

## Retro

_Written by the final slice. Guidance: compare what the cold read predicted with what really
diverged, using the deviations in every progress file._

| Cold read predicted | What diverged | Slice | Lesson for the next pack |
|---|---|---|---|

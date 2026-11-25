# Planning team — discovery research in brainstorm

| | |
|---|---|
| **Status** | done |
| **Type** | Feature |
| **Size** | M — 5 slices |
| **Modifiers** | none |
| **Issues** | #281–#285 (Slices 1–5) |
| **Owner** | retroboot |
| **Opened** | 2026-11-24 |

## Brief

Child 3 of the XL parent [`../planning-team/README.md`](../planning-team/README.md), which states
the problem: one author agent writes every pack file in one context and has to remember every
check, so problems surface late, one per cold-read round. Child 1
([`../planning-team-review/`](../planning-team-review/README.md), done) added the role card format,
the dispatch and triage contract, and the review panel. Child 2
([`../planning-team-spec/`](../planning-team-spec/README.md), done) staffed `spec` and `slice` with
drafting roles and gates, and added the transient `handoff.md`.

`brainstorm` is still one agent: it researches, holds the conversation and proposes a route in a
single context, so what past packs learned, what the repository already does, and what could go
wrong reach the conversation only if that agent thinks to look.

The outcome wanted is that `brainstorm` is staffed with parallel research before and during the
conversation:

- A **Scout** reads the repository for what already exists that the topic touches.
- A **Historian** reads past packs, their Retros and their cold-read records for what earlier work
  learned about the same ground.
- A **Skeptic** looks for why the idea could fail, or should not be built.
- The **Facilitator** (the main session) brings their findings into the conversation, rather than
  the researchers talking to the developer.

Scope: the `planner` plugin's `brainstorm` skill and the role cards it dispatches, under
`skills/planning/references/roles/` in child 1's card format. `spec`, `slice`, `cold-read` and the
`planning` wrapper's roster by route are out of scope (children 1, 2 and 4), apart from one approved exception: the `research` Kind
adds five things to `skills/planning/references/roles/dispatch.md` (the Kind value, the research
frame, the research completeness check, the research pass beside **Tree and guard**, and a research
paragraph in **No subagent tool**) and one skip line to `skills/cold-read/references/panel.md`
(ADR-001, ADR-009). Depends on child 1.

Child 2's Retro carries two lessons into this pack: read every route branch of each phase a slice
changes, since every late finding there came from a branch the pack never named; and move reference
text out of a skill before adding pointers to it, not when its line budget runs out.

## Route

- **Feature:** new behaviour in `brainstorm`, parallel research roles whose findings the
  Facilitator brings into the conversation, rather than a restructure of what exists.
- **M:** about 3 to 5 slices (the Historian and Skeptic cards, the Scout's research use,
  `brainstorm`'s dispatch and merge, the no-subagent fallback); more than one PR, well under 7.
- **No modifiers:** Markdown skills and role cards only; no data, integration, UI, security surface,
  public API or infrastructure change.

## Read order

1. This file, including **How to execute this pack** below
2. [`prd.md`](prd.md): problem, goals, non-goals, stories and acceptance criteria
3. [`context.md`](context.md): what exists today, with file citations, conventions and glossary
4. [`decisions/`](decisions/): ADR-001 to ADR-009, the choices made at the acceptance and design checkpoints and the cold read
5. [`design.md`](design.md): architecture, contracts, flows, test strategy, risks and pre-mortem
6. [`plan.md`](plan.md): the slices, their order and acceptance criteria per slice
7. `progress/`: one file per slice once execution starts
8. [`cold-read.md`](cold-read.md): results of the cold-read review of this pack

## How to execute this pack

These rules are the same in every pack. They live here so an executor needs nothing but this
folder and the repository.

1. **Work one slice at a time.** A slice is one issue and one PR. Its issue body carries a line
   `Plan: docs/plans/planning-team-discovery · Slice: N`.
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

_Written by the final slice. Guidance: compare what the cold read predicted with what really
diverged, using the deviations in every progress file._

| Cold read predicted | What diverged | Slice | Lesson for the next pack |
|---|---|---|---|
| Pass after 2 rounds: the pack was complete | T3 ("correct one misspelled word") was named as a topic with little to argue against. The Skeptic found grounded reasons against it twice, including the parent's **Ruled out** "The full team on every pack". The developer amended S-03.2.e2 | 1 | Before naming a fixture as the empty case, check its premise against the repository's own records |
| (same) | T2 ("a mobile push-notification service") was expected to give a report with no path. The Scout cited adjacent paths, including this pack's own `design.md`, which names T2 once the pack merged. The developer amended S-01.1.e2 | 2 | A pack that names its fixtures turns them into repository content. Write a nothing-found row for the adjacent paths it will cite |
| (same) | The first forced-short prompt was ignored and a full report came back. Only an exact one-line reply forced an incomplete report | 3, 4 | When seeding an incomplete report, give its exact text |
| (same) | Phase 4 research reused Phase 2 steps whose exits jump to Phase 3 (review of #290). Step 7 had no rule for a step with every role missing, which was deferred to Slice 5 | 4, 5 | When a section reuses another section's steps, read each reused step's exits in the new phase |
| (same) | Line cites to `dispatch.md` in `context.md` and `plan.md` went stale once Slice 1 inserted the research sections (**No subagent tool** moved from `:203` to `:262`) | 1, 5 | Cite sections by name. This repeats `planning-redesign`'s lesson, and it still bit |

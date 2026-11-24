# Planning team — role-based subagents for the planner

| | |
|---|---|
| **Status** | routed |
| **Type** | Feature |
| **Size** | XL — 4 child packs |
| **Modifiers** | none |
| **Issues** | not yet published |
| **Owner** | retroboot |
| **Opened** | 2026-11-24 |

## Brief

Planning the hyalOS kernel took 35 cold-read rounds across four packs (verifier 15, notary 11,
core 5, record 4), adding hours to every plan. The cold read is doing the work of several
reviewers at once (fact-checking, consistency, trust and decision coverage, testability, and
comprehension) with one Haiku reader looking at a third of the slices per round. Everything before
it is done by one author agent that wears every hat in a single context and has to *remember* each
check.

The outcome wanted is a planner that works the way a staffed team would: a **Facilitator** (the
main session) that runs a runbook and dispatches **subagents with tight jobs**. Each role is
defined once as a role card (job, inputs, checklist, output table) and gets the model its job
needs. Problems are caught in the stage that creates them, decisions reach the developer in one
batch per stage, and the cold read becomes an acceptance test that passes in 1–2 rounds instead of
the main way problems are found.

Scope: the `planner` plugin's `brainstorm`, `spec`, `slice`, `cold-read` and `planning` skills,
`pack-format.md` and its templates. The team is staffed according to the route, so small work stays
cheap. Too big for one pack, so it is split into the child packs below, planned and shipped in
order.

## Ruled out

- **One author agent with longer checklists** (the first pass at the six ideas). It keeps the
  author checking its own work in the context that wrote it, and still depends on remembering.
- **Relaxing the round rule so a command re-run closes a round** (idea 6). It weakens "only a new
  reader can show the fixes worked". Revisit only if data from child pack 1 shows a remaining
  one-blocker tail.
- **A shipped citation-checker script.** The script policy (`skills/core/SKILL.md`) rules it out.
  Checks live as `bash` fences in skills, as the slice Trace check does.
- **Running every Verify command at planning time.** Some change state. Only commands that are
  read-only and already work are run; the rest get a "would fail because…" note.
- **The full team on every pack.** A real team holds no design review for a typo. The roster
  scales with the route.
- **Restating Verify commands by reference only** (part of idea 5). A weak executor must not have
  to put a command together from a reference, so Verify stays exact in the slice. Rules and
  contracts move to one home.

## Key insights

- **Coverage is not the main cost.** Core had 12 slices and passed in 5 rounds, while the verifier
  had 7 slices and took 15. Reading a third of the slices per round sets a floor of about 3 rounds.
  The tail comes from unchecked repo facts, decisions raised one per round, and fixes creating new
  blockers.
- **Measuring first worked.** Core's ring 3 run and RDSEED probe came before its plan was written.
  The prd's Assumptions table already has a "how to validate" column, but nothing runs it.
- **The phase skills share one context.** `planning` composes `spec`, `slice` and `cold-read`, but
  they all run as the same agent. Only the cold reader is a separate person today.
- **Subagents cannot start subagents.** Every dispatch comes from the main session, so the main
  session is the Facilitator and writes nothing itself.
- **Trace every miss back.** Each blocker a cold reader finds is tagged with the role whose
  checklist should have caught it, and that checklist gets a line. This is how the process improves
  itself.
- **The cold-read record contradicts itself.** The verifier record says `Rounds: 15` but
  `Pass after 3 rounds`, because `cold-read` Phase 6 writes this run's count, not the total.
- **Portability.** Codex, Antigravity and opencode may lack a subagent tool. The fallback is the
  main agent working through each role card in turn, as `cold-read` already falls back today.

## Child packs

| Order | Pack | Covers | Depends on |
|---|---|---|---|
| 1 | `docs/plans/planning-team-review` | The role card format and dispatch/triage mechanism. The review panel before the cold read: Fact-checker, Test engineer, Editor and Trust reviewer, each on a narrow checklist, in parallel. Each fix re-checked only by the role it affects. A parallel round-1 cold read covering every slice. Tracing each miss back to a role. The `Pass after N rounds` record fix | none |
| 2 | `docs/plans/planning-team-spec` | Staffing `spec` and `slice` with role gates: a Scout writes `context.md` and the Fact-checker gates it; the Analyst, Architect and Planner draft; assumption probes are run before design; the Trust reviewer's batch goes out at the acceptance checkpoint; the Test engineer and Editor check the draft before the slice checkpoint | 1 |
| 3 | `docs/plans/planning-team-discovery` | Staffing `brainstorm` with parallel research: a Scout, a Historian (past packs, retros and cold-read records) and a Skeptic. The Facilitator brings their findings into the conversation | 1 |
| 4 | `docs/plans/planning-team-facilitator` | `planning` as the Facilitator: the roster by route (S, M, L), batching decisions once per stage across the whole flow, and the subagent-free fallback in one place | 1, 2, 3 |

## Route

- **Feature:** new capability in the planner (staffed roles, gates and dispatch); the edits to
  existing skills serve it.
- **XL:** four independent outcomes across five skills and the pack format, well over 12 slices
  in total, so it is split into child packs.
- **No modifiers:** the product is Markdown and JSON skills, with no UI, data, runtime or public API.

## Read order

1. This file, including **How to execute this pack** below

## How to execute this pack

These rules are the same in every pack. They live here so an executor needs nothing but this
folder and the repository.

1. **Work one slice at a time.** A slice is one issue and one PR. Its issue body carries a line
   `Plan: docs/plans/planning-team · Slice: N`.
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

- **Tracking the children.** After each child pack's last slice merges, run `planning
  docs/plans/planning-team` to see every child's Status, then start the next child in order with
  `planning "<that child's Covers text>"`, linking this README from its Brief.
- **Where role cards live** (for example `skills/planning/references/roles/<role>.md`), and whether
  a role card is shared across skills or owned by one. Child pack 1 decides; later children reuse
  it.
- **Is the roster right?** Tagging each of the 35 hyalos blockers with the role that should have
  caught it tests it against real misses. This is research for child pack 1's spec.

## Retro

_Written by the final slice. Guidance: compare what the cold read predicted with what really
diverged, using the deviations in every progress file._

| Cold read predicted | What diverged | Slice | Lesson for the next pack |
|---|---|---|---|

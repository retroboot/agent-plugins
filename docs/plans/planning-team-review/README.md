# Planning team — review panel and parallel cold read

| | |
|---|---|
| **Status** | done |
| **Type** | Feature |
| **Size** | M — 5 slices |
| **Modifiers** | none |
| **Issues** | #259–#263 (Slices 1–5) |
| **Owner** | retroboot |
| **Opened** | 2026-11-24 |

## Brief

Child pack 1 of [`planning-team`](../planning-team/README.md), the XL effort that rebuilds the
planner as a Facilitator dispatching subagents with tight jobs. Read the parent's Brief, Ruled out
and Key insights first. This pack builds the mechanism the later children reuse.

**Problem.** `cold-read` (`skills/cold-read/SKILL.md`) is the only review a pack gets from someone
other than its author, and it covers too much: one Haiku reader per round, about a third of the
slices, looking for every kind of gap at once. In the hyalOS kernel packs this took 35 rounds:
verifier 15, notary 11, core 5, record 4. Most blockers were things a narrower, stronger reviewer
would have caught in one pass: repo facts a command could disprove, Verify commands that could not
run or gave different output on each run, rules stated differently in two places, and trust
decisions raised one per round. Fixes created new blockers, because the author re-checked its own
work. The record also contradicts itself, reporting `Rounds: 15` beside `Pass after 3 rounds`.

**Outcome wanted.** Before any cold reader sees a pack, a **review panel** of subagents reads it in
parallel. Each subagent has one role card and one checklist. The cold read then becomes an
acceptance test that passes in 1–2 rounds. Concretely:

- **Role cards.** One file format defines a role: its job, inputs, model, checklist, and an output
  table with the same blocking test the cold read uses. This pack also sets how the main session
  dispatches roles, merges their findings and triages them. The later child packs reuse the format
  and the dispatch.
- **The panel.** A Fact-checker (claims, citations, assumption probes, read-only commands), a Test
  engineer (each criterion provable; each Verify command runnable now or noted "would fail
  because…"; nothing that changes between runs), an Editor (each rule stated once; restatements and
  contradictions agree), and a Trust reviewer (every outside input and party, with all open
  decisions sent to the developer as **one** batch). They run in parallel. The Trust reviewer always
  runs, and returns an empty table when the pack has no outside inputs.
- **Re-check only by the affected role.** After the fixes, the roles whose checklists the fixes
  touch read again. The Editor always checks the fix diff.
- **A parallel round-1 cold read.** Several fresh Haiku readers, each on a different group of
  slices, so every slice is read in round 1. Later rounds read only the slices the fixes touched.
  The read stays cold.
- **Tracing misses back.** Each blocker a cold reader finds is tagged in `cold-read.md` with the
  role whose checklist should have caught it, and the role card gets a proposed checklist line.
- **The record fix.** The Result line reports total rounds and this run's rounds, so it can no
  longer contradict the header.

**Scope.** `skills/cold-read/SKILL.md`, the cold-read template, `pack-format.md` where it describes
the cold read, and the new role-card files. The panel is called from `cold-read`, so `planning`
gets it with no changes. Out of scope: gates inside `spec` and `slice` (child 2), the brainstorm
crew (child 3), and scaling the team by route across the whole flow (child 4). The subagent-free
fallback is in scope for the panel only.

## Route

- **Feature:** adds role cards, a review panel and a parallel cold read; the edits to `cold-read`
  serve it.
- **M:** about 5 slices, ordered by how many hyalos blockers each covers: the role card format and
  dispatch; Editor and Fact-checker (54 of 95); Test engineer and Trust reviewer (33); the parallel
  round-1 cold read; tracing misses back and the Result-line fix. At the slice checkpoint the
  Fact-checker moved into Slice 1, so that slice ships a working panel, and the Editor stands alone
  in Slice 2 (`plan.md`).
- **No modifiers:** Markdown and JSON skills; no UI, data, runtime or public API.

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
   `Plan: docs/plans/planning-team-review · Slice: N`.
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
| Round 2 Q1: a deferred pre-reader item is held, the readers still run, and the run ends `COLD READ BLOCKED` | Phase 4 re-marked the held item developer-only and Phase 5 asked it again, so an answer the second time let the run continue; PR #267 review found it, and a live reader round proved the fix | 3 | When the cold read settles a rule that crosses phases, the dry run walks it live through each phase it crosses, not by desk check of one file |
| Round 2 Q10: "touched" is a fix to a slice's section or a file in its Files list | The definition had no procedure, and the `{diff}` it needed was deleted before grouping ran (PR #268 review); the Files-list clause can never fire, since pack fixes never edit repository files | 4 | A definition is not a procedure: say when the value is computed and from what, and check that each clause can occur |
| Round 1 Q7, Round 2 Q8: `.hivrr.json` is absent from a fresh tree | Every dry run's readers and the Test engineer raised it again: `eval "$(jq -r .verify.test .hivrr.json)"` exits 0 with nothing on stdout | 1–5 | A Verify line that can pass silently needs its own failing check, not a note elsewhere that no output fails |
| not predicted | Slice 3 used Slice 2's `editor.md` and Slice 4 used Slice 1's `tree.md`, each declaring fewer dependencies; the merge order hid it | 3, 4 | The Editor's E4 should hold each slice's **Depends on** against every artifact it uses (dry-run proposal **E7**) |
| not predicted | 5.2 said Phase 6 writes `### Panel without a reader`, but a stopped run never reaches Phase 6 | 5 | Trace every "Phase N writes X" against the paths that enter Phase N |
| not predicted | The Slice 3 gate (at least 7 of 10 seeds) was met at 10 of 10, most seeds found by two or three roles | 3 | Seed subtler defects before trusting a gate to measure the panel |

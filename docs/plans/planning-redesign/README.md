# Planning redesign — plan packs

| | |
|---|---|
| **Status** | done |
| **Type** | Feature |
| **Size** | L — 9 slices |
| **Modifiers** | none |
| **Issues** | #207–#215 (Slices 1–9) |
| **Owner** | retroboot |
| **Opened** | 2026-11-13 |

## Brief

The `planner` plugin's output is rarely used. `brainstorm` keeps its conclusions in session memory
that no fresh session can reach, `planning` writes implementation code into the plan, and nothing
records *why* decisions were made. This work replaces both with a guided `planning` wrapper that
produces a **plan pack**: a committed folder under `docs/plans/<slug>/` that gains files as the
work gets more complex. Any model, strong or weak, can execute a pack cold in a new session.
`work-issue` and `ship-issue` learn to execute packs, and everything they do today without a
pack stays the same.

The work rewrites `brainstorm` and `planning` and extends `work-issue` and `ship-issue`, but it is
routed as one Feature.

This pack is also the first example of the format it defines. Where `design.md` and this folder
disagree, `design.md` is right and this folder is a bug. Once Slice 1 merges,
`skills/planning/references/pack-format.md` becomes the format of record for **new** packs. This
pack is not migrated to it.

## Route

- **Feature:** new capability; the refactors serve it.
- **L:** 9 slices.
- **No modifiers:** no UI, data, runtime or public API.

## Bootstrapping this pack

The tools that publish and execute packs are what this pack builds, so it is published and executed
by hand:

1. **Issues.** Created directly, one per slice, each with its marker and `Depends on #N` lines.
2. **Plan PR.** A plan PR on `plan/planning-redesign` lands the pack on `main` before Slice 1
   starts (ADR-010).
3. **Execution.** Run with `ship-issue` given **issue numbers**, until Slices 7 and 8 merge. Until
   Slice 7, `work-issue` ignores the marker. Each issue body therefore tells the executor to read
   this README and follow **How to execute this pack** by hand.

## Read order

1. This file, including **How to execute this pack** below
2. [`prd.md`](prd.md): problem, goals, non-goals, stories and acceptance criteria
3. [`context.md`](context.md): what exists today, with file citations, conventions and glossary
4. [`decisions/`](decisions/): ADR-001 to ADR-012, the decisions and the options rejected
5. [`design.md`](design.md): the pack format, the skill architecture and the execution contract
6. [`plan.md`](plan.md): the slices, their order and acceptance criteria per slice
7. `progress/`: one file per slice once execution starts
8. [`cold-read.md`](cold-read.md): results of the cold-read review of this pack

## How to execute this pack

These rules are the same in every pack. They live here so an executor needs nothing but this
folder and the repository.

1. **Work one slice at a time.** A slice is one issue and one PR. Its issue body carries a line
   `Plan: docs/plans/planning-redesign · Slice: N`.
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

Any assumption that could still be wrong is listed in `design.md` §9 (Risks).

## Retro

Written by Slice 9, comparing [`cold-read.md`](cold-read.md) (four Haiku rounds) with the
deviations and discoveries in `progress/slice-01.md` to `slice-09.md`. All nine slices are `done`.

| Cold read predicted | What diverged | Slice | Lesson for the next pack |
|---|---|---|---|
| Round 1: gaps at the boundary between the plugins (phase order in another skill, a format one plugin cannot read, a write with no owner) | Every boundary resolution held. `work-issue` and `ship-issue` read packs without reading `planner` files | 7, 8 | A reader that tries to execute a slice finds boundary gaps a checklist misses; keep the execute-the-slice prompt |
| Round 2: ownership gaps (who writes which README field and Status) | Still open in execution: nobody owned the `progress/` and `cold-read.md` lines in Read order until the wrapper took them | 2, 3, 4, 6 | For every file the format lists, name the skill that writes it and the one that adds its Read-order line |
| Round 3: producer gaps (size-S slice, Bug rules with no writer) | `brainstorm` and `spec` left **Child packs**, **Question**, **Repro and root cause** and **Slice** to later skills; each was handed on by a Discovery and landed | 2, 3, 6 | Hand-offs by Discovery work, but only because each later slice grepped for its own number |
| Shared contract: `status` values and `pack_status` a string | `SPEC STOPPED`, `SLICE STOPPED`, `COLD READ STOPPED` were added and `pack_status`/`model` became nullable, as accepted contract deviations, then amended in `plan.md` by Slice 6 | 2–6 | A result contract needs a "stopped" value and a "no README" case from the start; every phase skill hit both |
| Citations checked: 22 in round 4, 19 held, 3 in part, none failed | Line numbers and counts drifted as slices merged: check count 13 → 14, planner skills 4 → 7, `review-pr` 4–14 → 4–16, `ship-issue` Error Handling 170–179 → 170–178 | 3, 4, 5, 8, 9 | Cite section names plus a start line; a range ages badly and a count is stale after the first slice |
| Rounds 1–4 checked citations by reading; none ran a Verify command | Faults found only by running: check 8's `w2n()` on "Fourteen" (Slice 1), an awk field number (Slice 5), the `origin/HEAD` read none of the listed commands provides (Slice 8) | 1, 5, 8 | Readers that run Verify commands catch what readers that only read cannot; make the cold read run them |
| NFR: no new or rewritten `SKILL.md` over 400 lines | `spec` drafted at 406 (cut to 380), `planning` needed `references/publish.md` to stay at 383, `work-issue` is 596 (an extension, accepted) | 3, 6, 7 | Budget lines per skill in the design, and plan the `references/` split up front |
| Size-S slice maps to `simple` (not predicted) | Legacy `simple` skips Phase 6, where preflight lives; settled as a Decision | 7 | Check that a new mode's mandatory step survives every legacy route through the skill |
| `work-issue` pack mode would be the executor's procedure | It was used for real in Slices 6–9. Reading the whole pack (about 2,100–2,500 lines) is heavy; Bootstrap loads `init`, `session` and `core` by name, which resolves to the installed plugin, not the checkout; Phase 8's `verify.md` pointer added nothing in pack mode | 6, 8, 9 | Tell the executor to grep progress files for `Slice N` and read the rest selectively, and say which copy of a skill wins when the checkout changes it |

### Follow-ups

- **#218:** check 14 and `slice`'s fence command miss or mis-pair indented, `~~~` and
  four-backtick fences.
- **#227:** a rerun while a slice's PR is open keeps that slice, because its `done` progress file is
  only on its branch, so `work-issue` would open a second PR.
- `ship-issue` pack mode reads only `Issue: #N`, so a pack whose slice issues live in Linear cannot
  run from a pack path; support `Issue: {identifier}`.
- The PR commands in `skills/session/references/github.md` and `gitlab.md` (**Create PR**, **Post
  comment**, **Edit a PR's title or body**) still pass `"{B}"` double-quoted bodies, with the
  backtick hazard R5 fixed for issues.
- `brainstorm`'s "not routed" end returns the same JSON as a discard; give it a distinct status or a
  `reason` field.
- `slice`'s checkpoint offers "revise the prd with `planning`", but the wrapper has no "revise the
  spec, same route" step.
- `ship-issue` does not check that a slice issue's marker names the same slice as `plan.md`; a
  publish-side check would catch it.
- `design.md` §2 could adopt the **Proposed by** line and `amended by` rule this pack's ADRs use.
- `cold-read` on a dirty checkout sees context the pack does not hold; run it on a clean tree.

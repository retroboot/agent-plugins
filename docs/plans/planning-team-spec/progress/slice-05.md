# Slice 5 — The Planner and the slice gate

| | |
|---|---|
| **Status** | done |
| **Issue** | #274 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (`claude-opus-5-5`) |
| **Date** | 2026-11-24 |

## Preflight

Checked on branch `issue/274`, forked from `origin/main` at `c508588` (Slice 4 merged).

| Citation | Holds? |
|---|---|
| `skills/slice/SKILL.md`, 385 lines, 7 `## Phase` headings; Phase 1 **Re-slice** at 77-91; Self-check with **Headings (S-04.2)** and **Trace (S-04.4)** | holds |
| `skills/cold-read/SKILL.md` Phase 2 runs the Self-check commands by name | holds; names unchanged |
| `skills/planning/references/gates.md`: the Slice row, **Fix** (`slice` only `plan.md`, Self-check again), **Answer** and **Deferral** slice-checkpoint errors, **Handoff** | holds; no `gates.md` text needed |
| `skills/planning/references/roles/dispatch.md` **Base**, **Drafting frame** (Slice 4's new-file rule), **Draft completeness check** (the Re-slice clause) | holds; the new-file rule needed a Re-slice exception (Decisions) |
| `skills/planning/references/roles/test-engineer.md` (V, sonnet) and `editor.md` (E, sonnet) | holds |

## Acceptance

Every dry run followed the checkout's `skills/` text, with `$CLAUDE_SKILL_DIR` resolved to this
checkout (see Deviations). Each dispatch ran in a new tree by `skills/cold-read/references/tree.md`
from `{base}` `origin/main` (`c508588`), with the guard before and after; every guard was identical.
Cards were pasted from the checkout. Fixtures were under `docs/plans/zz-dryrun-*`, and all were
removed before commit. The executor played the developer at each fixture checkpoint.

**seeded-plan** (`zz-dryrun-plan`) is Slice 4's fresh fixture past the design checkpoint: a Feature
at size M, Status `specified`, DR1 answered, DR6 deferred. After the Planner's draft was written,
two seeds were applied (`design.md` §6 **Seeding**): one Slice 2 Verify command lost its
`# expected:` line, and both prd statements of the line's wording were changed to the old
`… scaffold verify.test by hand`, so the prd is the wrong side.

| Id | Result |
|---|---|
| S-06.1 | pass — shown by S-06.1.e1 and S-06.1.e2 |
| S-06.1.e1 | pass — **seeded-plan**: Drafted by the Planner, Opus (Agent tool, model: opus, Explore); the transcript names `claude-opus-5-5`. Both `plan.md` markers and `## Open points` (DL1 to DL4, non-blocking, settled by their defaults): accepted; Count read 2; written with its Read order entries and its `## Gate pending: plan.md` entry; then the Phase 4 Self-check ran on it: Headings, Trace, Map no output, every fence `bash` |
| S-06.1.e2 | pass — desk check: a 13-slice report; Count read 13 and `slice` printed `XL: split into child packs — the draft has 13 slices, over the 12 a pack holds. Re-route to XL with planning.`; no `plan.md` was written |
| S-06.2 | pass — shown by S-06.2.e1 and S-06.2.e2 |
| S-06.2.e1 | pass — **seeded-plan**, the slice gate: the Test engineer (Agent tool, model: sonnet, Explore) and the Editor (Agent tool, model: sonnet, Explore) in one message, one tree. The Test engineer reported the seed under V1 (PV1, now GV1, blocking), with three more blocking (GV2 to GV4) and GV5. All five were fixed in `plan.md` after the snapshot, the Self-check ran again on the fixed file, and the resumed gate (S-03.5) served as the re-check: GV1 and GV5 checked; GV2, GV3 and GV4 reported again and held, not fixed again |
| S-06.2.e2 | pass — **seeded-plan**: the Editor reported the seeded wording under E1 (PE1, now GE1, blocking), saying the prd is the wrong side. `slice` may not edit the prd, so it was held for the batch; `prd.md` was unchanged by the gate |
| S-06.3 | pass — shown by S-06.3.e1 to S-06.3.e3 |
| S-06.3.e1 | pass — **seeded-plan**, one developer-only finding (GE6, whether the line belongs in `README.md`'s `init` row) added to the Editor's live report (Agent tool, model: sonnet, Explore) before triage: held, and asked in the slice checkpoint's one batch with GE1, GV2, GV3 and GV4 |
| S-06.3.e2 | pass — **seeded-plan**, branch A: the developer deferred GE1. It became `Deferred at the slice checkpoint on 2026-11-24: GE1 — …`; Approve was not offered; on stop `slice` said `Stopped: GE1 unanswered — next: planning docs/plans/zz-dryrun-plan revise spec.`; Status stayed `specified` and the entry stayed |
| S-06.3.e3 | pass — **seeded-plan**, branch B, from the state before the checkpoint: GE1 answered (a), change the prd. `slice` edited no spec file (`prd.md` byte-identical), wrote `## Spec pending: GE1` to `handoff.md` with the file and section, the answer and the date, and stopped with `Stopped: GE1 needs a spec change — next: planning docs/plans/zz-dryrun-plan revise spec.` |
| S-06.4 | pass (`slice` side) — shown by S-06.4.e1 |
| S-06.4.e1 | pass — desk walk on branch B: `planning docs/plans/zz-dryrun-plan` read the Handoff note first and resumed at Phase 4 with GE1's answer as `spec`'s request; `spec` revised `prd.md` in place (no drafter, `dispatch.md` **Drafting frame**), and on its checkpoint's approve the Spec pending entry was removed. `handoff.md` stayed, holding the `Gate pending: plan.md` entry the slice stop left (see Deviations) |
| S-03.5 | pass (`plan.md` stage) — **seeded-plan**, the session ended after the slice gate's fixes, with `Fix not re-checked: GV1 … GV5` in the entry; `slice` run again found `Gate pending: plan.md`, dispatched no Planner, and re-ran the slice gate on `plan.md` as it stood (Agent tool, model: sonnet, Explore, twice), keeping the entry's Ids: the Editor's wording finding matched GE1 and was not renumbered |
| 5.1 | pass — `planner.md` headings `Letter|Model|Kind|Job|Inputs|Checklist|Output|`, `Letter=L Model=opus Kind=draft`; no letter shared with another card |
| 5.2 | pass — the Self-check section and the **Headings (S-04.2)** and **Trace (S-04.4)** commands keep their names and place; the slice gate is a new `### Slice gate` after them |
| 5.3 | pass — Phase 1 reads `handoff.md` and resolves `{base}`, `{date}` and `{sha}` by `dispatch.md` **Base** before the first dispatch |
| 5.4 | pass — **reslice** (`zz-dryrun-reslice`), a copy of seeded-plan at `sliced`, reason naming Slice 2 only. `planner.md` lists `{current}`; the Planner (Agent tool, model: opus, Explore) returned a draft whose Traceability, Shared contract and Slice 1 sections were byte-identical to `{current}`, with only Slice 2 revised. That draft, changed in the session only to reword Slice 1's Outcome, failed the section compare: incomplete. The retry, in a new tree (Agent tool, model: opus, Explore), again revised only Slice 2: accepted and written, with its `Revised by slice …` Open questions line |

Skill dir, per dry run:

- **seeded-plan:** Skill dir: /home/retroboot/projects/agent-plugins/skills/slice
- **reslice:** Skill dir: /home/retroboot/projects/agent-plugins/skills/slice
- **count (desk):** Skill dir: /home/retroboot/projects/agent-plugins/skills/slice
- **S-06.4.e1 (desk):** Skill dir: /home/retroboot/projects/agent-plugins/skills/planning

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Live runs: "the session with the planner plugin loaded from this checkout" (`design.md` §6) | As in Slices 1 to 4: each dry run followed the checkout's skill text, with `$CLAUDE_SKILL_DIR` resolved to the checkout | The session's `Skill` tool loads the cached plugin | n |
| The slice gate's own re-check, then a separate resumed run (S-03.5) | One resumed gate served both, as `gates.md` **Handoff** says ("the re-run is the check of any `Fix not re-checked`") | The session ended after the fixes, before the re-check; Slice 3 did the same | n |
| S-06.4.e1: "when `spec`'s checkpoint approves, the entry and the file are gone" | The Spec pending entry went; `handoff.md` stayed, because the slice stop left its `Gate pending: plan.md` entry, which `gates.md` says a stop leaves. The file goes at the next slice checkpoint | The prd example assumes the Spec pending entry is the only one; keeping the plan entry keeps GV2 to GV4 held | n |
| Files: `planner.md`, `reslice.md`, `slice` | `dispatch.md` also changed: one sentence makes a Re-slice the exception to Slice 4's new-file rule. The README Retro and Status are this slice's by rule 8 | Slice 4's rule would forbid the Planner the Re-slice this slice requires | n |

## Decisions

- **Phase 1 Re-slice moved to `skills/slice/references/reslice.md`** (plan step 5, R2), with the
  `{current}` file: the reason on its first line, then the current `plan.md`, in a `mktemp -d`
  directory removed once Phase 4 writes the draft. `slice` is 398 lines with 7 phases.
- **A Spec pending entry stops `slice`** in Phase 1, `Spec change pending: next: planning {path}.`,
  so a slice run never re-plans against a spec that waits on a change.
- **The gate's non-blocking findings that need a spec file** (GE2 to GE5, GE7, GE8) are listed at
  the checkpoint, not asked, as `gates.md` **Fix** says for a non-blocking finding it cannot fix.

## Discoveries

- **For the retro: the re-check rule held.** The resumed Test engineer reported three of the five
  fixes again (each fix was weaker than the finding asked); ADR-006's one re-check held them for the
  batch rather than looping.
- **For the retro: answers on a stop are not written.** At branch A's stop, the developer's answers
  to GV2 to GV4 had nowhere to go: `gates.md` **Answer** writes answers on approve, and a stop keeps
  the entry. A next pack could say whether a stop writes the answers it got.

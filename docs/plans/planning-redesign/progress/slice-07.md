# Progress — Slice 7

| | |
|---|---|
| **Status** | done |
| **Issue** | #213 |
| **PR** | this PR |
| **Executor model** | Claude Opus 5.5 (`claude-opus-5-5`), pack rules followed by hand |
| **Date** | 2026-11-14 |

**Bootstrapping.** This slice is the one that teaches `work-issue` to act on the marker, so it was
executed by hand, as the README's **Bootstrapping this pack** section says: the old `work-issue`
ignores `Plan:` lines. Every pack-mode step below was carried out by the executor reading the README
rules, not by the skill being built.

## Preflight

Pack read from `origin/main` at `7b83dba`; the working copy matched it.

- `context.md` §3 `skills/work-issue/SKILL.md` (549 lines, 12 phases): holds. Every cited range
  holds at the cited lines: Phase 1 at 49, Phase 2 at 68, Phase 3 at 93, **Load session context**
  134–199, Phase 4 203–216, Phase 6 364–376, Phase 7 380–399 with the blocker rules at 393–395,
  Phase 8 403–411, the session-directory paragraph 445–449, **Write the session result** 480–524,
  **Emit the result** 526–539.
- Pattern to follow, "Skip this entire section when …" at `skills/work-issue/SKILL.md:231`: holds.
- Phase 5 integration rule (`branches.integration`, default branch, `origin/HEAD`, `main`) at
  287–298: holds.
- `skills/core/SKILL.md` **Staging** (line 44) and the `.ai/session/` bullet at line 70: hold. Line
  70 is Slice 9's and was not touched.
- `docs/verification.md` check 4 (line 39) and `docs/shared-lines-allowlist.txt`: hold.
- `skills/wave/SKILL.md`: unchanged by this slice.
- `skills/init/references/verify.md`, the shared Phase 8 procedure: holds.

## Acceptance

Line numbers refer to `skills/work-issue/SKILL.md` on this branch (596 lines, after review round
1). Dry runs read the skill as an executor against the named scenario. Synthetic fixtures (issue
bodies, and a throwaway git repo with a three-slice pack `demo`) were built in the session scratchpad
outside the repository and never committed.

| ID | How it was shown |
|---|---|
| S-07.1 | Dry run (a), a plain issue with no `Plan:` line. Phases 1–12 run as before: every pack block is skipped by its opening sentence (see 7.1), and **Detect a pack marker** (160) is skipped silently. Structural proof that nothing else moved: `origin/main`'s file with lines 134–200, 445–450 and 480–525 deleted, diffed against this branch, shows **only additions** (zero `<` lines, re-run after review round 1); every legacy line is byte-identical. The displays removed are all session ones: `Session: no plan entry …`, `WARNING: Memory unavailable …`, `Session context loaded …`, `Session: {SESSION_UUID} — no prior context`, `Session result written to memory` |
| S-07.1.e1 | As S-07.1: same phases, displays and final JSON (`WORKFLOW COMPLETE`, 549–556) as before, minus the `Session …` lines. All removed sections were already skipped when `SESSION_UUID` was unset, so a plain run printed none of them before either |
| S-07.1.e2 | Fixture body with `We have a Plan: TBD for later.` mid-paragraph: no line starts with `Plan: `, so 160–161 skip silently; legacy mode. Fixture `Plan: docs/plan/x · Slice: 2` with no marker line: 169–171 print `unrecognised Plan: line — legacy mode`, legacy mode. The same typo line followed by a real marker line: the marker wins and the typo is ignored silently (171). `plan: docs/plans/…` (lower case): case-sensitive (163), silent legacy. `Plan: docs/plans/demo/ \| Slice: 3`: marker, slug `demo` with the trailing `/` stripped, slice 3 (165–168) |
| S-07.3 | `grep -nE 'SESSION_UUID\|session/\{\|\.ai/session\|memory' skills/work-issue/SKILL.md`: no output. `work-issue` only; Slice 9 owns `core:70` |
| S-08.1 | Dry run (b), this pack's Slice 7 as a marked slice that passes: Phase 2 skipped (one issue); 165–168 match `Plan: docs/plans/planning-redesign · Slice: 7`; **Load the pack** (175–198) resolves `main`, `git show`s the README and Read order (ran for real: `decisions/` and `progress/` list through `git ls-tree`), finds `## Slice 7` at plan.md:536; Phase 4 (215–219) maps Size `L` to `complex` and states that Phase 6 always runs; Phase 6 (371–387) runs preflight and displays `Plan: pack slice 7`; Phase 8 (447–459) collects proofs; Phase 10 (493–509) writes `progress/slice-07.md` with status, PR `this PR`, preflight, proofs, deviations and decisions, in README rule 7's order, then stages it by name. This file was written to that recipe |
| S-08.1.e1 | Executor renames a planned helper: guide items may be left with the reason recorded as a deviation (385); a wrong plan that changes no contract is a deviation, recorded and continued (428–429); the notes are kept from the start (61–63) and written as the Deviations table, contract affected `n`, in Phase 10 (500–501) |
| S-08.2 | Dry run (c), the last slice: Phase 10 step 3 (503–509) reads every other slice's progress file from `origin/{integration}`; all `done` means last slice, so the README's Retro placeholder is replaced with a Retro comparing `cold-read.md` with every progress file's deviations, and Status becomes `done` |
| S-08.2.e1 | Fixture `demo` (slices 1–3), working slice 3 with slices 1 and 2 `done` on `origin/main`: the step 3 reads, run with `git show`, report both `done`, so slice 3 is last and writes the Retro and Status `done` |
| S-08.2.e2 | Same fixture with slice 2 `blocked`: the reads report `blocked`, so slice 3 is not last despite being last-numbered (505–507): no Retro. On this pack, slices 6, 8 and 9 have no progress file on `origin/main`, so Slice 7 is not last and this PR writes no Retro |
| S-10.3 | Phase 8 block (447–459) collects a proof for every listed criterion ID and every `S-NN.k.eN` row under it (453), at the Test strategy's level; an ID without a proof sends the run back to Phase 7. Phase 10 (500) writes one row per criterion ID and example ID, as this table does |
| 7.1 | Every pack-mode block opens with a skip-when-no-marker sentence: 51, 105, 160, 175, 215, 371, 420, 447, 493, 540, 563, 594. Line 160 skips on the wider condition "no line starts with `Plan: `", which covers both no marker and no typo warning |
| 7.2 | Dry run (d), this slice's own stop condition "Stop if `wave` needs editing" triggering under `--auto` in Phase 7: 420–429 make it a hard stop with no question even under `--auto` and send the run to **Pack mode — Blocked path** (561–582). Phases 8, 9 and 11 are skipped (568); the progress file gets Status `blocked`, PR `none (no PR is opened)` and **Blocked on** (569–572); partial work and progress file go in one `wip:` commit, staged by name (573–576); the branch is pushed (577); no PR; the JSON has `BLOCKED`, `pr` and `pr_url` null (578–580). Error Handling (594–596) routes stops there rather than retrying. Rerun after an answer: Phase 6 step 2 (378–382) sets Status `in-progress` first, so the slice never goes `blocked → done` (design §11) |
| 7.3 | The JSON block (549–556) is unchanged. Phase 12's pack block (540–542) and step 5 of the blocked path (578–579) keep the key set `{status, pr, pr_url, branch, issues}`; `BLOCKED` is the only new value |
| Stop conditions | Not triggered. The removal changed no legacy display or JSON beyond the `Session …` lines (S-07.1 diff). `git diff origin/main -- skills/wave`: empty |
| Structural | `eval "$(jq -r .verify.test .hivrr.json)"`: `structural checks pass`, check 4 included, re-run after review round 1. Phases still `## Phase 1`–`## Phase 12`, no stated count |
| Isolation | `grep -nE 'planning\|planner' skills/work-issue/SKILL.md`: the legacy line "drive planning decisions" (Phase 4) and the Error Handling pointer to "Slice 8 of the planning redesign", which names the change without reading any planner file (ADR-007) |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Suggested path: pack blocks in Phases 2, 3, 4, 6, 7, 8 and 10, and `BLOCKED` in Error Handling | Also a `## Pack mode` section before Phase 1, a block in Phase 12, and a `## Pack mode — Blocked path` section after Phase 12 | The marker rules and the README-wins fallback (ADR-007) need one home that every block can point to; design §7 lists Phase 12, and the blocked path has five steps that several phases refer to. Neither heading is a `## Phase N`, so check 7 is unaffected | n |
| `context.md` §3: "the marker is read from the issue body in Phase 3" | Phase 2 also needs the marker for multi-issue runs, so it points to Phase 3's **Detect a pack marker** | Design §7 already says Phase 2 forces `sequential` and may fetch bodies early | n |
| PRD NFR Size: no new or rewritten `SKILL.md` over 400 lines | `work-issue` is 596 lines (549 before, −119 session, +166 pack); accepted by the orchestrator in review round 1 | The NFR covers new or rewritten skills, and design §1 calls `work-issue` extended. Moving pack mode to a reference file is possible later | n |

## Decisions

- **Phase 6 runs at every complexity in pack mode,** `simple` included, because preflight (rule 2)
  cannot be skipped and a size-S slice maps to `simple`.
- **Phase 3 stops** (pack not on integration, no such slice, marker without `Slice: N`) come before
  a branch exists, so they follow Error Handling: display and stop, with no progress file and no
  JSON, as any legacy failure does. The blocked path is reserved for Phase 6 and 7 stops, as design
  §7 says.
- **Preflight that touches a Contract,** and README rule 6, take the blocked path the same way as a
  slice's own stop conditions.
- **A proof that cannot be made to hold** sends the run back to Phase 7. If holding it would change
  a contract, that is a rule-6 stop in Phase 7, so the blocked path stays within Phases 6 and 7.
- **Resuming a blocked branch:** Phase 6 reads the old **Blocked on** first and blocks again unless
  the issue comments or the pack on integration now answer it.
- **The blocked path leaves README Status and the Retro alone.** Those writes ride the slice's PR
  (design §11, `published → executing: first slice PR`), and a blocked slice opens none.
- **`wip:` commit message** follows Slice 1's real one: `wip: slice N … (blocked)`, the question and
  the progress file in the body, then `Refs #N` rather than `Closes`.
- **Sequential runs stop at a `BLOCKED` slice:** no later issue starts, matching ship-issue's rule
  (S-06.2).
- **Review round 1** (PR #224): the blocked path's PR field is `none (no PR is opened)`; the
  unrecognised-line warning shows only when no line of the body is a marker; a trailing `/` is
  stripped from the slug; a resumed blocked slice is set `in-progress` before work continues;
  the Phase 4 pack block states that Phase 6 always runs in pack mode. Phase 3 stops emitting no
  JSON was accepted by the orchestrator.
- **Display variants** (`Complexity: … (pack size …)`, `Plan: pack slice N`) are stated inside the
  pack blocks, so the legacy `Display:` lines stay byte-identical.

## Discoveries

- **For Slice 8:** `work-issue` emits no JSON at all on a Phase 3 pack stop (pack missing, no such
  slice), as with any legacy failure. `ship-issue` pack mode checks the pack on integration itself
  (design §7 step 2), so this arises only for issue-number input; it should treat a missing JSON as
  a failure, which legacy Error Handling already does.
- **For Slice 8:** map `BLOCKED` to `stuck` for issue-number input as well as for a pack path. A
  marked issue given by number runs pack mode in `work-issue` too, so it can return `BLOCKED`, and
  legacy `ship-issue` does not know that value. `work-issue`'s Error Handling says Slice 8 makes
  this mapping; until it lands, nothing does.
- **For Slice 8:** `BLOCKED` comes with `branch` set and `pr`, `pr_url` null. `issues` still lists the
  run's issue numbers.
- **For Slice 9:** `skills/core/SKILL.md:70` still names `.ai/session/` as expected scratch, and
  `.gitignore` line 4 still credits `work-issue` with writing it. Neither is true after this slice.
- **For the Retro:** the cold read raised many Slice 7 questions (Q7.1–Q7.9, S7-Q1–Q5), and each
  resolution held up in execution; none had to be revisited. What it did not predict: Phase 4 maps
  a size-S slice to `simple`, and legacy `simple` skips Phase 6, where design §7 places preflight.
  Read literally, a size-S slice would skip preflight. This slice settled it as a Decision.

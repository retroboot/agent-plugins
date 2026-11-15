# Progress — Slice 4

| | |
|---|---|
| **Status** | done |
| **Issue** | #210 |
| **PR** | this PR |
| **Executor model** | Claude Opus 5.5 (`claude-opus-5-5`), pack rules followed by hand |
| **Date** | 2026-11-14 |

## Preflight

Pack read from `origin/main` at `71846df`; the working copy matched it.

- `skills/planning/references/pack-format.md` §2 (routing, size), §4 (slice contract) and §6
  (fences), Slice 1 output: holds. §4 matches `design.md` §5 heading for heading.
- `skills/planning/references/templates/plan.md` (Slice 1 output): exists, with Dependency graph,
  Traceability, Shared contract and the eight slice headings in `design.md` §5 order: holds.
- `skills/init/references/labels.md:51`, `size:l` "Large — 1–2 days" (criterion 4.1): holds.
- `$CLAUDE_SKILL_DIR/../planning/references/` and `../init/references/` are reachable from `slice`:
  `planning` and `init` both ship in `planner` (`.claude-plugin/marketplace.json`).
- `context.md` §4, frontmatter keys and `## Phase N — Title` headings (check 7): holds, as in
  `skills/spec/SKILL.md:1-6`.
- `context.md` §5, adding a skill: checks 6 and 13 (`docs/verification.md:61`, `:158`) read
  `marketplace.json`, the `**Skills:**` line, the README plugin table and `.agents/skills/`: holds.
  `context.md` says check 13 is at line 156; it is at 158 since Slice 1 added check 14 (see
  Deviations).
- `.claude-plugin/marketplace.json` `planner` lists `init`, `session`, `brainstorm`, `spec`,
  `planning`: holds after Slice 3 (`context.md` §1 predates `spec`).
- Shared contract (`plan.md`, phase-skill completion): unchanged on disk; Slice 3's accepted
  `SPEC STOPPED` deviation read from `progress/slice-03.md`.

## Acceptance

Line numbers refer to `skills/slice/SKILL.md` after review round 1 (366 lines). Fixtures were built
in a scratchpad directory outside the repository and not committed: a copy of this pack's `prd.md`
with a doctored `plan.md`; a fence file; a heading-order file; and, from the first round, a pack
with a `text` and a `mermaid` fence.

| ID | How it was shown |
|---|---|
| S-04.2 | Phase 2 "Each slice holds" (164–187) lists the eight headings in `pack-format.md` §4 order, mandatory and guide marked. Phase 4 Headings (236–248) prints each slice whose headings are not exactly the eight in order, and requires each to have content; a failing draft is rejected before the checkpoint (233–234). Dry run (a): silent on this pack's `plan.md`. A fixture with Contracts before Acceptance prints `## Slice 1 — a: headings Outcome\|Contracts\|Acceptance\|…` |
| S-04.2.e1 | Fixture `plan.md` with Slice 3's Stop conditions removed: prints `## Slice 3 — New \`spec\` skill: headings Outcome\|Acceptance\|Contracts\|Verify\|…`; lines 233–234 reject the draft ("Never show a failing draft as ready") before Phase 5 |
| S-04.3 | Author side: Phase 4 Fences (250–261) runs before the checkpoint and flags any opening fence, at any indentation, with backticks or tildes, not tagged `bash`, `sh`, `mermaid` or `text`; 259–261 reject code inside any fence whatever its tag. Fence fixture: a `python` fence indented under a list item → `f.md:3: fence "python"`; a 3-space-indented untagged fence → `f.md:7: fence ""`; `~~~json` → `f.md:11: fence "json"`; a `text` fence → nothing. On every file in this pack (README, prd, context, design, plan, cold-read, decisions, progress): silent. Repo side: check 14 passes on this repo's packs |
| S-04.3.e1 | Round 1 fixture, check 14's lines from `docs/verification.md:170-185`: `PACK CODE FENCE docs/plans/x/bad.md:3` (untagged) and `:7` (`json`) |
| S-04.3.e2 | Round 1 fixture pack with a `text` wireframe and a `mermaid` flowchart: check 14 prints nothing, and so does the skill's Fences command |
| S-04.4 | Phase 1 lists every bold PRD criterion ID (101–105) and stops on a prd with none (107–108); Phase 2 Criteria (137–140) puts each in a slice; Phase 4 Trace (263–281) counts only bold IDs in Acceptance, only criterion IDs (never `.eN`) in the Traceability first column, plus the reverse for stray bold IDs; a gap is fixed or kept for the checkpoint (277–281), shown there (315–316), and Approve is withheld while one remains (321–323). Dry run (a), this pack: 42 criterion IDs; all three commands silent |
| S-04.4.e1 | Fixture `plan.md` where S-05.3 survives only as "(like S-05.3.e1)" in the Slice 5 and 6 Acceptance and as `S-05.3.e1` in the Traceability row: the Acceptance and Traceability commands both print `S-05.3`, before Phase 5, which shows it as a gap |
| 4.1 | Dry run (c), a drafted slice "billing schema, API and admin screen": Sizing (124–133) reads `labels.md` via `$CLAUDE_SKILL_DIR/../init/references/labels.md`, estimates it `size:xl` (several components that could each merge alone, more than one migration step), and splits it along observable results, re-estimating each part. Self-check Size (297) and the checkpoint's per-slice label (311–312) confirm none is above `size:l`. The text says a label size, not pack size L (125–126) |
| S-11.5 | Plan side: header line (168–171) names `Map:` only when the prd has a Story map, as the journey steps the slice's Outcome changes. Phase 4 Map (283–293) runs a command printing each map step no slice names; the checkpoint shows any untouched step (317) and withholds Approve (321–323). Dry run (a): silent on this pack (all seven steps named). Fixture with Slice 7's `Map: Execute, Learn` cut to `Execute`: prints `Learn` |
| 4.2 | Dry run (b), Refactor M: "By type" (155–156) makes Slice 1 the characterization tests, no behaviour change, all others depending on it. Greenfield M: 157–159, Slice 1 a walking skeleton with `context.md`'s verify command green. Migration and Rewrite: 160–162, a **Rollback:** line ending every slice's Contracts; Rewrite's cutover its own slice. Self-check Type (298–299) rejects a draft breaking any of them |
| Stop condition | The slice's own stop is built into the skill: more than 12 drafted slices stops before writing (191–193), emits `SLICE STOPPED` with the drafted count (360–362). Not triggered while building this slice |
| Structural | `eval "$(jq -r .verify.test .hivrr.json)"`: `structural checks pass`. Phases `## Phase 1`–`## Phase 7`, no stated count. `slice` is registered in `marketplace.json`, the planner `**Skills:**` line, the README planner table and `.agents/skills/slice` |
| NFR Size | `skills/slice/SKILL.md` is 366 lines, under the 400-line limit |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| `context.md` §5: check 13 at line 156, 13 checks | Check 13 at 158; 14 checks | Slice 1 added check 14 | n |
| `context.md` §1: planner lists four skills | Five, then six with `slice` | Slice 3 added `spec` | n |
| Shared contract: `status` is `SLICE COMPLETE` | `slice` also emits `SLICE STOPPED` | Same case as Slice 3's accepted `SPEC STOPPED` deviation: a stop at the checkpoint, a refused mode and the more-than-12 stop must be told from a completed run, and in Re-slice `pack_status` is the same either way | y — accepted by the orchestrator in review round 1, as `SPEC STOPPED` was |
| Shared contract: `pack_status` is a string | `null` when the path has no README | Same as Slices 2 and 3 | y (already accepted for Slices 2 and 3) |
| Suggested path: one phase per step (read, draft, graph, trace and fence self-check, checkpoint, Status, JSON) | Seven phases in that order; writing `plan.md` shares Phase 4 with the self-check | The self-check runs on the file on disk, and the file must be on disk before the checkpoint ("files are the only state"). Every mandatory item holds | n |

## Decisions

- **`SLICE STOPPED`** covers every non-completing path. `slices` is the count in `plan.md` after the
  run, except for the more-than-12 stop, where it is the drafted count; a value over 12 therefore
  means "split into child packs" and that `plan.md` was not written or changed.
- **Refused modes:** not yet specified (`discovered`, `routed`), read-only (`published` onwards),
  Spike, size S (including every Change) and XL parent all write nothing, matching `spec`.
- **Re-slice** at `sliced`, `reviewed` or `approved` revises `plan.md` slice by slice, with one Open
  questions line per revised slice, removed on approval; Status is unchanged. Slices may be
  renumbered because nothing is published yet.
- **Bug at size M+:** plan is O in the matrix, but only `plan.md` holds more than one slice, so it is
  proposed; declined, the skill stops and suggests re-routing to S.
- **Size mismatch** (count outside M 2–6 or L 7–12) and any coverage gap or untouched map step
  withhold Approve at the checkpoint; the developer changes the slicing or stops to re-route.
- **Read order:** `slice` adds both `plan.md` and `progress/` (Slice 2 and 3 Discoveries), since
  progress files exist only once there are slices.
- **Inventory Slice column:** `slice` replaces each `pending` in a Migration's Usage sites with the
  covering slice number (Slice 3 Discoveries). This is the only edit it makes outside `plan.md` and
  the README.
- **Pre-mortem items** mapped to "stop condition in the slice that …" become "Stop if …" bullets in
  that slice; `design.md` itself is not edited.
- **Traceability rows** write every ID out, never a range, so the trace command can read them.
- **Self-check commands** are given in `bash` fences (headings, fences, trace). They are read-only
  and deterministic, so they follow the script policy; the skill still reads each slice for
  content the commands cannot judge.
- **`Map:`** (review round 1) names the journey steps the slice's Outcome changes, the steps it
  touches (S-11.5), not the steps its stories sit under.
- **A prd with no bold `S-NN.k` criteria** (review round 1) is a format gap: `SLICE STOPPED`,
  nothing written.
- **Headings** (review round 1) must be exactly the eight, in order; the check prints the slice's
  actual sequence when they are not.
- **Bootstrap** loads `core` only when the install ships it, as `spec` does (issue #221).
- **Registration order:** `slice` after `spec` in `marketplace.json`, the `**Skills:**` line and the
  README table.

## Discoveries

- **For Slice 6:** treat `SLICE STOPPED` as a stop. `slices` over 12 means the draft needs child
  packs (S-09.4), a safety net behind the wrapper's own XL route.
- **For Slice 6:** at size S, `slice` is skipped, so nothing adds `progress/` to Read order; the
  wrapper should add it when it passes Status through `sliced`. `cold-read.md`'s entry belongs to
  Slice 5.
- **For Slice 6:** `slice` leaves the README Size row's slice count alone (the row is the wrapper's);
  the wrapper may update `<n> slices` from `slices` when it confirms.
- **For Slice 5:** `cold-read` can reuse the three self-check commands in `skills/slice/SKILL.md`
  Phase 4 for its own fence and trace checks.
- **For Slice 6:** a Re-slice at `reviewed` or `approved` leaves Status alone, so the cold read
  that passed saw the old plan; the wrapper should re-run `cold-read` after one.
- **For Slice 6 or 9:** the Shared contract in `plan.md` should be amended to list `SPEC STOPPED`,
  `SLICE STOPPED` and `pack_status` `null` (no README), which are accepted deviations today.
- Check 14 still misses indented and `~~~` fences; the skill's own Fences command covers them.
  Tracked in #218; check 14 is unchanged here.
- A criterion split across slices is written "**S-NN.k** (author side): …", as this pack's own
  `plan.md` does; the trace command treats each mention as coverage.

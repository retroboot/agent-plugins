# Progress — Slice 3

| | |
|---|---|
| **Status** | done |
| **Issue** | #209 |
| **PR** | this PR |
| **Executor model** | Claude Opus 5.5 (`claude-opus-5-5`), pack rules followed by hand |
| **Date** | 2026-11-14 |

## Preflight

Pack read from `origin/main` at `2720a40`; the working copy matched it.

- `skills/planning/SKILL.md:102-121`, research with an "Allowed APIs" list (Pattern to follow;
  `context.md` §2 cites 110–119): holds. Phase 3 heading at 102, the list at 110–121.
- `skills/planning/references/pack-format.md` and `templates/` (Slice 1 output; the Authority and
  Templates contracts): exist, with `README.md`, `prd.md`, `context.md`, `design.md`, `adr.md`,
  `inventory.md` and `ux.md`.
- `skills/planning/references/ux-checklist.md` (Modifiers contract): exists, six parts. `context.md`
  §2 says 159 lines; it is 143 since Slice 1 restructured it. See Deviations.
- `$CLAUDE_SKILL_DIR/../planning/references/` is reachable from `spec`: both ship in `planner`.
- `context.md` §4, frontmatter keys (`name`, `description`, `license: MIT`, `compatibility:
  opencode`): holds, as in `skills/brainstorm/SKILL.md:1-6`.
- `context.md` §4, Bootstrap block at `skills/ship-issue/SKILL.md:24-29`: holds.
- `context.md` §4, phase headings `## Phase N — Title` enforced by check 7
  (`docs/verification.md:78`): holds.
- `context.md` §5, adding a skill: checks 6 (`docs/verification.md:61`) and 13 (`:158`) read
  `marketplace.json`, the `**Skills:**` line, the README plugin table and `.agents/skills/`: holds.
- `.claude-plugin/marketplace.json` `planner` lists `init`, `session`, `brainstorm`, `planning`:
  holds.
- Shared contract (`plan.md`, phase-skill completion): unchanged since Slice 2.

## Acceptance

Line numbers refer to the new `skills/spec/SKILL.md` (399 lines). Fixtures for (a) and (c) were
built in a scratchpad directory outside the repository and not committed.

| ID | How it was shown |
|---|---|
| S-03.1 | Dry run per type at M: Phase 1 lines 73–76 take the R entries (with "at M+" applied), drop README and plan, and add O files only on a yes. Bug M → prd (R at M+), context; design and decisions proposed (282, 229). Feature M → prd, context, design; decisions proposed. Refactor M → prd, context, design. Migration M → prd, context, design, decisions, inventory. Greenfield M → prd, context, design, decisions. Rewrite M → prd, context, design, decisions, inventory. Each matches its matrix row minus README and plan |
| S-03.1.e1 | Dry run (a), Feature M with `ui`: lines 73–77 give prd, context, design and `ux.md` (ui at M+); decisions O declined. Scratchpad pack listed README, context, design, prd, ux. plan is `slice`'s (Slice 4), which completes the row |
| S-03.2 | Change S: no prd, context, design or inventory in its row, so Phase 2 writes no file (121), Phase 3 writes the README Slice (188–201), Phase 7 completes it (326–332). decisions is O (229): README alone unless the developer accepts an ADR |
| S-03.2.e1 | Change S: README only; its Slice Acceptance is rules and examples with at least 2 rows (195–197, 180) and Verify is exact `bash` commands with expected output (329–330) |
| S-03.3 | Dry run (b), Rewrite M: inventory required (73), Phase 6 writes **Behaviour inventory** (269–271) and **Parity matrix** (272–273) from `templates/inventory.md`, deleting Usage sites (264) |
| S-03.3.e1 | Rewrite L: same files as Rewrite M (no "at M+" qualifier applies), plus `inventory.md` with both sections; design adds the cutover plan (304) |
| S-03.4 | Dry run (c), Feature M at `specified` re-routed to Rewrite: Phase 1 mode Re-route (64). Missing inventory and decisions are written new (90); existing files get sections added and revised only where the route changes them (91–94), never deleted or rewritten; Status unchanged (100, 374) |
| S-03.4.e1 | Same: in the scratchpad, all five earlier files present after the run; `diff` of the listings shows only `decisions` and `inventory.md` added. prd gains behaviour criteria (94, 271); each revision gets an Open questions line (95–98) shown at Phase 4 (212) and removed on approval (216) |
| S-03.5 | Dry run (d), Spike before: Status `routed` → mode Spike question (60); Phase 3 writes **Question** with question and timebox (144–147); Phase 4 approve → Phase 9 (217); Status `specified` (373). After: Status `specified`, no ADR → mode Spike outcome (61); Phase 2 skipped (112); Phase 5 writes the outcome ADR (240–244); Status stays `specified` and the display points to re-route (375) |
| S-03.5.e1 | Spike, outcome "use library X": Phase 5 writes `decisions/ADR-001-…` (226–227, numbering from 001), Status `accepted` when the developer states it (244). The re-route offer is the wrapper's (Slice 6); spec's display names it (375) |
| 3.1 | Dry run (e): Phase 2 collects every API, helper, pattern and convention with `path:line` (117–119), and context.md must cite each one, opened in this run, or drop it (125–127); a re-read check closes the phase (136). Greenfield cites the ADR that chose a convention (132–134) |
| 3.2 | Dry run (f), PRD checkpoint rejected: Phase 4 (205) comes before Phase 5's ADR checkpoint (246) and Phase 8's design checkpoint (348). **Change** revises and re-shows (218); **Stop** goes to Phase 10 with Status unchanged and files on disk (219, 397). Status is written only in Phase 9, reached only when every checkpoint was approved (368). Matches S-02.3.e1: `prd.md` on disk, Status still `routed` |
| 3.3 | Rule at lines 29–31: each created file gets its Read order entry in the same step; Phase 7 self-check (342) and Phase 9 (370) confirm it |
| 3.4 | Size S, every type: line 78 and Phase 3 (188–201) and Phase 7 (326–332) write Slice with Outcome, Acceptance, Contracts, Stop conditions, Verify, Pattern to follow, Suggested path and Files |
| S-04.2 | Spec side, size S: Phase 7 self-check (340–341) rejects a Slice missing any of the eight headings, or with one empty, before the Phase 8 checkpoint. Same shape as S-04.2.e1 for `slice` (Slice 4) |
| S-10.1 | Phase 3 Rules and examples (174–186): a rule per story, an examples table, at least 2 rows with an edge or failure case, row IDs extending the criterion ID |
| S-10.1.e1 | A rule with only happy-path rows: line 184 adds a failure row, or asks the developer why none applies (186) and shows it at the checkpoint (211) |
| S-10.2 | NFRs, Assumptions (155–157) and Failure modes (168–169) in the prd |
| S-10.2.e1 | PRD with no observability needs: line 156–157, every quality is a row, `none` never omitted |
| S-10.4 | Refactor: preservation contract (162–163) and characterization rows (182–183); Bug: regression criteria (164–165) written as rules and examples (166–167), in the README Slice at S (196–197) |
| S-10.4.e1 | Refactor of a date parser: characterization rows record the output the current code really gives, cited, with at least one invalid input (182–183); the rule's 2-row minimum (180) and the example's 3 inputs both fit |
| S-11.1 | Test strategy always with a design (293, 299–300) |
| S-11.2 | State machines when a lifecycle entity is touched (291), with illegal transitions (297–298) |
| S-11.2.e1 | Order draft/paid/shipped: lifecycle touched, so a `stateDiagram-v2`; "each move back to an earlier state that the lifecycle forbids" lists shipped → draft (297–298) |
| S-11.3 | Domain model when persisted entities or core types change (290); Flows when two or more components interact (292) |
| S-11.3.e1 | Text-only copy change: a Change has no design at all (S-03.2). Routed as Feature M instead, neither trigger applies, so both sections are deleted (284–285, "exactly") |
| S-11.4 | Pre-mortem at size M+ (294), each item mapped (301–303) |
| S-11.4.e1 | "Migration locks the table": maps to "stop condition in the slice that runs the migration" (302–303), named by what the slice does for `slice` to carry |
| S-11.5 | Prd side: Story map for Feature, Greenfield and Rewrite at M+ (158–159) |
| S-12.1 | `ui` at M+ writes `ux.md` and links it (313–317); at S the six parts go inline in the modifier section (318–319) |
| S-12.1.e1 | Feature M, `ui`, 3 screens: one wireframe and one state table per screen, "so 3 screens give 3 of each" (315–316) |
| S-12.1.e2 | A Figma link: a link under **Mockups**, never embedded (316–317) |
| S-12.2 | `observability` section: events with levels, never-logged data, metrics, numeric alert thresholds, production check tied to success measures (320–324) |
| S-12.2.e1 | Payment webhook: "log a payment webhook's event ID, never its card data", alert with a numeric threshold (321–322) |
| Stop condition | Not triggered: every file the route asks for is in the routing matrix. The skill carries the same rule (80–83) |
| Structural | `eval "$(jq -r .verify.test .hivrr.json)"`: `structural checks pass`. Phases `## Phase 1`–`## Phase 10`, no stated count. Scratchpad packs: check 14's fence rule printed nothing |
| NFR Size | `skills/spec/SKILL.md` is 399 lines, under the 400-line limit |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| `context.md` §2: `ux-checklist.md` is 159 lines | 143 lines, six parts | Slice 1 restructured it; the Modifiers contract only names the path | n |
| Suggested path: design and modifiers, then inventory | Inventory (Phase 6) before design (Phase 7), with ten phases and three checkpoints in their own phases | Inventory is shown at the design checkpoint, and design's cutover and rollback build on it. Every mandatory item still holds | n |
| Shared contract: `pack_status` is a string | With no README at the input path, `pack_status` is `null` | No Status exists to report. Same case and choice as Slice 2's accepted deviation | y |

## Decisions

- **Stop at a checkpoint** emits `SPEC COMPLETE` with the unchanged `pack_status` and the files
  written so far, rather than a new status value, so the Shared contract keeps its listed values.
  The wrapper tells finished from stopped by `pack_status`.
- **Checkpoints:** Phase 4 is the "PRD" checkpoint. It also shows `context.md` and, at size S, the
  Slice's Outcome and Acceptance (or a Spike's Question). The design checkpoint also shows
  `inventory.md`, `ux.md`, README modifier sections and, at S, the rest of the Slice.
- **Optional files** are proposed before being written, at the start of their phase: context in
  Phase 2, decisions in Phase 5, Bug's design in Phase 7.
- **Size S with a prd** (for example Feature S): Rules and examples and Failure modes go in the
  README Slice, with a failure note, and the prd keeps everything else (`pack-format.md` §2,
  content sections). Without a prd, criteria are `1.k`.
- **Modifier sections without design.md** go in the README after Slice and before Route.
- **Re-route revisions** use the line
  `Revised by spec on {date}: {file} — {section}, for the re-route to {type}. Awaiting approval at the next checkpoint.`
  and are removed when the checkpoint showing that file is approved.
- **Specify at `routed` with spec files already present** (an earlier stopped run, a re-routed
  Spike) follows the re-route rules and still sets Status on approval.
- **Read-only** at `published`, `executing` or `done`, and nothing written at `discovered` or for
  an XL parent, matching `brainstorm`.
- **Spike outcome ADR** is `accepted` when the developer states the outcome outright, otherwise
  `proposed` and checkpointed. Spec leaves Status `specified`; the wrapper sets `done` or `routed`.
- **Migration usage sites** get `pending` in the Slice column, since no slices exist yet.
- **Bootstrap** loads `core` only, as `brainstorm` does; nothing needs tracker context.
- **Registration order:** `spec` after `brainstorm` in `marketplace.json`, the `**Skills:**` line
  and the README table.

## Discoveries

- **For Slice 4:** `inventory.md` Usage sites leave the Slice column as `pending`; `slice` should
  fill it. Pre-mortem items name "the slice that …" by what it does; `slice` should turn each into a
  stop condition in that slice.
- **For Slice 4 or 6:** `spec` adds only the files it writes to Read order. `plan.md`, `progress/`
  and `cold-read.md` are still unowned there, including at size S, where `slice` is skipped.
- **For Slice 6:** after `spec`, read `pack_status`, not `status`, to tell whether Specify finished.
  `pack_status` is `null` when the path has no README.
- **For Slice 6:** for a Spike, `spec` leaves Status `specified` after writing the outcome ADR, and
  the wrapper sets `done` or `routed`. A re-routed Spike's Question section and ADR stay.
- **For Slice 6:** a Bug's **Repro and root cause** is still not written by `spec`; the wrapper
  owns it, per Slice 2's Discoveries.
- The NFR's 400-line limit was tight: the first draft was 406 lines. Any further detail should go
  into a `references/` file.

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

Line numbers refer to `skills/spec/SKILL.md` after review round 2 (380 lines). Fixtures for (a) and
(c) were built in a scratchpad directory outside the repository and not committed.

| ID | How it was shown |
|---|---|
| S-03.1 | Dry run per type at M: Phase 1 lines 74–77 take the R entries (with "at M+" applied), drop README and plan, and add O files only on a yes. Bug M → prd (R at M+), context; design required when the route has modifiers, otherwise proposed (272–274); decisions proposed (218–220). Feature M → prd, context, design; decisions proposed. Refactor M → prd, context, design. Migration M → prd, context, design, decisions, inventory. Greenfield M → prd, context, design, decisions. Rewrite M → prd, context, design, decisions, inventory. Each matches its matrix row minus README and plan |
| S-03.1.e1 | Dry run (a), Feature M with `ui`: lines 74–78 give prd, context, design and `ux.md` (ui at M+); decisions O declined. Scratchpad pack listed README, context, design, prd, ux. plan is `slice`'s (Slice 4), which completes the row |
| S-03.2 | Change S: no prd, context, design or inventory in its row, so Phase 2 writes no file (122), Phase 3 writes the README Slice (177–190), Phase 7 completes it (304–310). decisions is O (218): README alone unless the developer accepts an ADR |
| S-03.2.e1 | Change S: README only; its Slice Acceptance is rules and examples with at least 2 rows (184–186, 169) and Verify is exact `bash` commands with expected output (308–309) |
| S-03.3 | Dry run (b), Rewrite M: inventory required (74), Phase 6 writes **Behaviour inventory** (259–261) and **Parity matrix** (262–263) from `templates/inventory.md`, deleting Usage sites (254); criteria Phase 6 adds are shown at the design checkpoint (329–330) |
| S-03.3.e1 | Rewrite L: same files as Rewrite M (no "at M+" qualifier applies), plus `inventory.md` with both sections; design adds the cutover plan as `### Cutover` under Architecture (285) |
| S-03.4 | Dry run (c), Feature M at `specified` re-routed to Rewrite: Phase 1 mode Re-route (65). Missing inventory and decisions are written new (91); existing files get sections added and revised only where the route changes them (92–95), never deleted or rewritten; Status unchanged (101, 353) |
| S-03.4.e1 | Same: in the scratchpad, all five earlier files present after the run; `diff` of the listings shows only `decisions` and `inventory.md` added. prd gains behaviour criteria (95, 261); each revision gets an Open questions line (96–99) shown at Phase 4 (201) and Phase 8 (330–331), removed on approval (205, 335) |
| S-03.5 | Dry run (d), Spike before: Status `routed` → mode Spike question (61); Phase 3 writes **Question** with question and timebox (145–148); Phase 4 approve → Phase 9 (205–206); Status `specified` (352). After: Status `specified`, no `accepted` ADR → mode Spike outcome (62); Phase 2 skipped (113); Phase 5 writes the outcome ADR (229–234). A `proposed` outcome ADR left by a stopped run resumes at the ADR checkpoint (62, 238); once one is `accepted`, a further run says it is recorded (63). Status stays `specified` and the display points to re-route (354) |
| S-03.5.e1 | Spike, outcome "use library X": Phase 5 writes `decisions/ADR-001-…` (214–216, numbering from 001), Status `accepted` when the developer states it (234). The re-route offer is the wrapper's (Slice 6); spec's display names it (354) |
| 3.1 | Dry run (e): Phase 2 collects every API, helper, pattern and convention with `path:line` (118–120), and context.md must cite each one, opened in this run, or drop it (126–128); a re-read check closes the phase (137). Greenfield cites the ADR that chose a convention (133–135) |
| 3.2 | Dry run (f), PRD checkpoint rejected: Phase 4 (194) comes before Phase 5's ADR checkpoint (236) and Phase 8's design checkpoint (326). **Change** revises and re-shows (207); **Stop** goes to Phase 10 with Status unchanged and files on disk (208), emitting `SPEC STOPPED` (377–379). Status is written only in Phase 9, reached only when every checkpoint was approved (347). Matches S-02.3.e1: `prd.md` on disk, Status still `routed` |
| 3.3 | Rule at lines 29–31: each created file gets its Read order entry in the same step; Phase 7 self-check (320) and Phase 9 (349) confirm it |
| 3.4 | Size S, every type: line 79, Phase 3 (177–190) and Phase 7 (304–310) write Slice with Outcome, Acceptance, Contracts, Stop conditions, Verify, Pattern to follow, Suggested path and Files |
| S-04.2 | Spec side, size S: Phase 7 self-check (318–319) rejects a Slice missing any of the eight headings, or with one empty, before the Phase 8 checkpoint. Same shape as S-04.2.e1 for `slice` (Slice 4) |
| S-10.1 | Phase 3 Rules and examples (163–175): a rule per story, an examples table, at least 2 rows with an edge or failure case, row IDs extending the criterion ID |
| S-10.1.e1 | A rule with only happy-path rows: line 173 adds a failure row, or asks the developer why none applies (174–175) and shows it at the checkpoint (200) |
| S-10.2 | NFRs, Assumptions and Failure modes are included exactly as `pack-format.md` §2 Content sections triggers them (152–155) |
| S-10.2.e1 | PRD with no observability needs: lines 157–158, every quality is a row, `none` never omitted |
| S-10.4 | Refactor: preservation contract and Bug regression criteria by their §2 triggers (152–155), written as rules and examples (165, 171–172); in the README Slice at S (160–161, 185–186) |
| S-10.4.e1 | Refactor of a date parser: characterization rows record the output the current code really gives, cited, with at least one invalid input (171–172); the 2-row minimum (169) and the example's 3 inputs both fit |
| S-11.1 | Test strategy by its §2 trigger, always with a design (275–276), naming each example row's level (281) |
| S-11.2 | State machines by their §2 trigger (275–276), with every illegal transition listed (279–280) |
| S-11.2.e1 | Order draft/paid/shipped: lifecycle touched, so a state machine; "each move back to an earlier state that the lifecycle forbids" lists shipped → draft (279–280) |
| S-11.3 | Domain model and Flows by their §2 triggers, included exactly when they apply (275–277) |
| S-11.3.e1 | Text-only copy change: a Change has no design at all (S-03.2). Routed as Feature M instead, neither trigger applies, so both sections are deleted (276–277) |
| S-11.4 | Pre-mortem by its §2 trigger, size M+ (275–276), each item mapped (282–284) |
| S-11.4.e1 | "Migration locks the table": maps to "stop condition in the slice that runs the migration" (283–284), named by what the slice does for `slice` to carry |
| S-11.5 | Prd side: Story map by its §2 trigger, Feature, Greenfield and Rewrite at M+ (152–154) |
| S-12.1 | `ui` at M+ writes `ux.md` and links it (294–298); at S the six parts go inline in the modifier section (299) |
| S-12.1.e1 | Feature M, `ui`, 3 screens: one wireframe and one state table per screen, "so 3 screens give 3 of each" (296–297) |
| S-12.1.e2 | A Figma link: a link under **Mockups**, never embedded (297–298) |
| S-12.2 | `observability` section states everything §2 Modifiers requires (290–291), with never-logged data named, numeric thresholds and the production check tied to success measures (300–302) |
| S-12.2.e1 | Payment webhook: "log a payment webhook's event ID, never its card data", every alert with a numeric threshold (300–301) |
| Stop condition | Not triggered: every file the route asks for is in the routing matrix. The skill carries the same rule (81–84) |
| Structural | `eval "$(jq -r .verify.test .hivrr.json)"`: `structural checks pass`. Phases `## Phase 1`–`## Phase 10`, no stated count. Scratchpad packs: check 14's fence rule printed nothing |
| NFR Size | `skills/spec/SKILL.md` is 380 lines, under the 400-line limit |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| `context.md` §2: `ux-checklist.md` is 159 lines | 143 lines, six parts | Slice 1 restructured it; the Modifiers contract only names the path | n |
| Suggested path: design and modifiers, then inventory | Inventory (Phase 6) before design (Phase 7), with ten phases and three checkpoints in their own phases | Inventory is shown at the design checkpoint, and design's cutover and rollback build on it. Every mandatory item still holds | n |
| Shared contract: `pack_status` is a string | With no README at the input path, `pack_status` is `null` | No Status exists to report. Same case and choice as Slice 2's accepted deviation | y |
| Shared contract: `status` is `SPEC COMPLETE` | Shared contract amended: spec adds `SPEC STOPPED`; accepted by orchestrator in review | Review round 1: in Re-route and Spike-outcome modes `pack_status` is the same before and after, so it cannot tell a finished run from a stopped or refused one | y |

## Decisions

- **`SPEC STOPPED`** (review round 1) is emitted for a stop at a checkpoint, a refused mode (no
  README, `discovered`, read-only, XL parent, Spike outcome already recorded) or a format gap, with
  the unchanged `pack_status` and the files written so far. `SPEC COMPLETE` means the run reached
  Phase 9 with its last checkpoint approved.
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
- **Bootstrap** (review round 1) loads `core` only when the install ships it; `planner` does not,
  so a planner-only install continues without it. Nothing needs tracker context.
  **Reverted 2026-11-14 (developer):** a skill loaded by name is found across installed plugins,
  so every planner skill loads `core` unconditionally, as before (#221). Only relative file links
  such as `../core/SKILL.md` break across plugins.
- **Spike resume** (review round 1) matches on an `accepted` ADR, so a `proposed` outcome ADR left
  by a stopped run resumes at the ADR checkpoint.
- **Cutover plan** (review round 1) lives in a `### Cutover` subsection under design.md's
  **Architecture** section.
- **Bug with modifiers at size M+** (review round 1) requires design.md, so modifier sections only
  ever go in the README at size S.
- **Criteria added in Phase 6** (Rewrite behaviour inventory) are shown at the design checkpoint,
  with their story, since the acceptance checkpoint never saw them.
- **Content-section and modifier triggers** (review round 1) are not restated: the skill points to
  `pack-format.md` §2 and keeps only what is specific to `spec`.
- **Registration order:** `spec` after `brainstorm` in `marketplace.json`, the `**Skills:**` line
  and the README table.

## Discoveries

- **For Slice 4:** `inventory.md` Usage sites leave the Slice column as `pending`; `slice` should
  fill it. Pre-mortem items name "the slice that …" by what it does; `slice` should turn each into a
  stop condition in that slice.
- **For Slice 4 or 6:** `spec` adds only the files it writes to Read order. `plan.md`, `progress/`
  and `cold-read.md` are still unowned there, including at size S, where `slice` is skipped.
- **For Slice 6:** the wrapper must treat `SPEC STOPPED` as a stop: do not advance to Slice, and
  show the developer the reason. `pack_status` is `null` when the path has no README.
- **Issue #221** tracks the same unconditional `core` load in `brainstorm` and `planning`, and the
  option of shipping `core` in `planner`. `brainstorm` was not changed here.
  Resolved 2026-11-14: loading by name works across plugins, so no change is needed (see
  **Bootstrap** above).
- **For Slice 6:** for a Spike, `spec` leaves Status `specified` after writing the outcome ADR, and
  the wrapper sets `done` or `routed`. A re-routed Spike's Question section and ADR stay.
- **For Slice 6:** a Bug's **Repro and root cause** is still not written by `spec`; the wrapper
  owns it, per Slice 2's Discoveries.
- The NFR's 400-line limit was tight: the first draft was 406 lines. After review round 1 pointed
  the trigger lists at `pack-format.md` §2, it is 380. Any further detail should go into a
  `references/` file.

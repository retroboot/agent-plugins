# PRD — Planning redesign

## Problem

Planning output in this plugin is rarely used, even by its author. Four causes:

1. **Reasoning is lost between steps.** `brainstorm` stores a five-field `intent` object in memory
   MCP or `.ai/session/{uuid}/`, both of which are unreachable from a fresh session, another
   machine, or another model. What was considered and rejected is not recorded anywhere.
2. **Plans contain the implementation.** Medium-tier plans pre-write test and implementation code.
   That code goes stale as the codebase moves, repeats the executor's work, and turns a capable
   model into a typist.
3. **The design layer is missing.** There are no decisions with rejected alternatives, invariants,
   glossary, contracts, or progress record. These are what a cold executor needs most.
4. **Plumbing outweighs the thinking.** Most of the two skills' 895 lines go to session UUIDs,
   memory writes, container-mode polling and fallbacks rather than to producing a good plan.

## Users

- **The developer** (repo owner) turns ideas into work and approves each planning phase.
- **The executor** is a model running `work-issue` in a fresh session. It may be a frontier model
  or a much smaller one, and the planner cannot know which in advance.
- **The reviewer** is a human reading a pack in a PR or reading an issue.

**Jobs.**

- Developer: "When I have an idea that is bigger than one sitting, I want to think it through and
  leave it in a form any model can build, so I can hand it off and trust the result."
- Executor: "When I'm given a slice, I want every decision already made or explicitly left to me,
  so I can build it without guessing."
- Reviewer: "When a plan or slice PR arrives, I want to see why, not only what, so I can judge it."

## Goals

- G1. One guided entry point (`planning`) walks the developer from idea to published issues, with a
  checkpoint between phases and the ability to stop and resume in a new session.
- G2. The output is a committed, self-describing plan pack whose size matches the work: a single
  file for a small change, the full set for a clean-room rewrite.
- G3. Any executor can carry out a slice from the pack and the repository alone, with no
  conversation history.
- G4. "The plan is complete" is checked before execution by a cold read on the smallest available
  model, not by checklist.
- G5. The gap between what was planned and what really happened is recorded, slice by slice.
- G6. `work-issue` and `ship-issue` on issues without a pack behave exactly as they do today.

## Non-goals

- Code of any kind inside a plan. Contracts are tables, behaviour is Given/When/Then.
- Memory MCP, session UUIDs, container mode and question/answer polling. They are removed.
- `--plan-only`. Stopping the wrapper before publish replaces it.
- An automated harness that executes skills under test. Behaviour is verified by recorded dry runs
  (see `context.md` §5).
- Changes to `work-pr`, `review-pr`, `merge-pr`, `promote`, `debug` or `wave`.
- Auto-triggering skills, in any vendor.
- Tracker-specific pack features. A pack is tracker-agnostic, and the issue marker is plain text.

## Success measures

- M1. A cold read of a real pack by Haiku ends with zero blocking questions in at most 3 rounds.
- M2. `ship-issue docs/plans/<slug>` ships every slice of a pack with no human input beyond the
  stop conditions the pack declares.
- M3. A plain issue with no `Plan:` line runs through `work-issue` with no pack-related output.
- M4. The developer chooses `planning` for their next real feature without being asked to.

## Non-functional requirements

| Quality | Target |
|---|---|
| Portability | Every skill works when invoked by name in Claude Code, Codex CLI and Antigravity. Claude-only features (the Agent `model` override) degrade as R1 states |
| Isolation | `dev` reads nothing from `planner` (ADR-007) |
| Durability | No planning state outside committed or committable files (ADR-002) |
| Size | No new or rewritten `SKILL.md` over 400 lines; detail goes in references |
| Performance | none: Markdown-only, no runtime |
| Reliability | A failed tracker or board call never loses pack files (warn and continue, as today) |
| Security | none beyond the existing `review-pr` read-only rule |
| Privacy | none: packs hold no personal data beyond the Owner name |
| Accessibility | none: no UI |
| Observability | none: no runtime; the progress files are the execution record |

## Assumptions

| Assumption | How to validate | If false |
|---|---|---|
| A model executes better from rules, examples and contracts than from pre-written code | Retro of the first real pack (S-08.2): deviation count and kind | Revisit ADR-003 for the weak-executor case only |
| Haiku is a fair stand-in for "the weakest executor" | Compare Haiku's cold-read questions with the deviations actually logged | Run the cold read on whichever model really executes |
| The developer will answer 4 to 6 checkpoints per plan | M4, and how often the wrapper is abandoned mid-way | Merge the Specify sub-checkpoints into one |
| Agents follow "stop conditions" under `--auto` | Dry run 7.2, then the first real `BLOCKED` | Strengthen the wording in the README rules |

## Story map

The developer's journey runs left to right. Stories sit under the step they serve. Slices cut
across the map; `plan.md` names the steps each slice touches.

| Think | Decide the shape | Specify | Prove | Hand off | Execute | Learn |
|---|---|---|---|---|---|---|
| S-01 | S-09, S-03 | S-03, S-10, S-11, S-12 | S-05 | S-02 (publish) | S-04, S-06, S-07 | S-08 |

S-02, the guided command, spans the whole map.

## Stories and acceptance criteria

Criterion IDs are referenced by `plan.md` and by progress files. Do not renumber them; add new ones
at the end of a story.

### S-01 Brainstorm leaves a durable brief

As the developer with a fuzzy idea, I want a thinking session that ends with its conclusions saved
in the repo, so that nothing I worked out is lost when the session ends.

- **S-01.1** Given a brainstorm that reaches a conclusion, when it wraps up and I choose to keep it,
  then `docs/plans/<slug>/README.md` exists with Brief, Ruled out, Key insights, Open questions and
  a proposed Route.
- **S-01.2** Given a brainstorm I choose to discard, when it wraps up, then no file is written.
- **S-01.3** Given any brainstorm run, then no memory, session UUID or container-mode operation
  happens.

### S-02 One guided command

As the developer, I want one command that walks me through every planning phase, so that I don't
have to know which skill comes next.

- **S-02.1** Given a topic, when I run `planning`, then it runs discover → route → specify →
  slice → cold read → approve → publish, and stops for my confirmation after route, specify, slice
  and before publish.
- **S-02.2** Given a pack whose README Status is any value before `published`, when I run
  `planning docs/plans/<slug>` in a new session, then it resumes at the phase after that status
  without repeating finished phases.
- **S-02.3** Given I stop at any checkpoint, then the pack files written so far remain on disk, and
  the README Status names the last finished phase.

### S-03 Packs grow with the work

As the developer, I want the plan's weight to match the work's, so that a typo fix doesn't get a
PRD and a rewrite doesn't get one page.

- **S-03.1** Given a route, then the files the pack holds are exactly those the routing matrix in
  `design.md` §3 lists for that type and size, plus one section per modifier.
- **S-03.2** Given route type Change, then the pack is `README.md` alone, holding acceptance
  criteria and a verify command.
- **S-03.3** Given route type Rewrite, then the pack includes `inventory.md` with a behaviour
  inventory and a parity matrix.
- **S-03.4** Given a pack that is re-routed to a larger type, then files are added and none of the
  existing ones are replaced.
- **S-03.5** Given route type Spike, then its outcome is recorded as an ADR and the wrapper offers
  to re-route the same pack.

### S-04 Any model can execute a slice cold

As an executor in a fresh session, I want everything I need in the pack and the repo, so that I
build the right thing without asking.

- **S-04.1** Given any pack, then its README contains the **How to execute this pack** rules,
  verbatim from the template.
- **S-04.2** Given any slice in `plan.md`, or the README's single slice at size S, then it has Outcome, Acceptance, Contracts, Stop
  conditions and Verify (mandatory), and Pattern to follow, Suggested path and Files (guide).
- **S-04.3** Given any pack, then no file contains implementation code. Every fence is tagged
  `bash`, `sh`, `mermaid` or `text`; anything else, including untagged fences and `json` or `yaml`,
  is rejected.
- **S-04.4** Given any acceptance criterion in the PRD, then at least one slice lists its ID.

### S-05 The plan is proven complete before execution

As the developer, I want to know the plan is complete before any code is written.

- **S-05.1** Given a drafted pack, when the cold read runs, then a fresh subagent on the smallest
  available model receives only the pack path and repository access, never conversation context.
- **S-05.2** Given its report, then every question is classed blocking or non-blocking, and the
  author resolves every blocking one by editing the pack before the next round.
- **S-05.3** Given 3 rounds that still leave blocking questions, then the wrapper stops and shows
  them to the developer rather than publishing.
- **S-05.4** Given any cold read, then `cold-read.md` records the model, each round's questions and
  how each was resolved.

### S-06 Ship a whole pack

As the developer, I want to ship a published pack with one command.

- **S-06.1** Given `ship-issue docs/plans/<slug>`, then it ships every slice whose progress file is
  not `done`, in `plan.md` dependency order, one PR per slice.
- **S-06.2** Given a slice that ends `blocked` or `stuck`, then the run stops: no later slice starts,
  whether or not it depends on that slice (the legacy rule), and the output reports it.
- **S-06.3** Given a pack path that does not exist on the integration branch, then `ship-issue`
  stops before starting any slice and says the pack PR must merge first.

### S-07 Work without a pack stays the same

As the developer working an ordinary issue, I want nothing to change.

- **S-07.1** Given an issue body with no `Plan:` line, then `work-issue` produces the same phases,
  displays and final JSON as before this work, minus the removed session-memory section.
- **S-07.2** Given `ship-issue` with issue numbers, then grouping, ordering by `Depends on #N`, and
  output are unchanged.
- **S-07.3** Given any `dev` skill, then nothing references `SESSION_UUID`, memory MCP or
  `.ai/session/`.

### S-08 Planned versus real is recorded

As the developer, I want to see where plans meet reality, so that planning improves.

- **S-08.1** Given a slice executed with a pack, then `progress/slice-NN.md` records status, PR,
  preflight result, deviations (plan said / reality / why) and decisions the plan did not specify.
- **S-08.2** Given the final slice of a pack, then its PR adds a Retro section to the README that
  compares the cold-read findings with the deviations actually recorded, and sets Status `done`.

### S-09 Work types are routed, not guessed

As the developer, I want the planner to name the kind of work and confirm it with me.

- **S-09.1** Given discovery, then the wrapper proposes type (one of 8), size (S, M, L, XL; `n/a`
  for a Spike) and modifiers (zero or more of 8), each with a one-line reason, and waits for
  confirmation.
- **S-09.2** Given type Bug with an unknown cause, then the wrapper recommends running `debug`
  first and folds its root-cause report into the README.
- **S-09.3** Given a batch of small independent items, then the wrapper says planning adds nothing
  and recommends `ship-issue` directly.
- **S-09.4** Given size XL, then the wrapper proposes splitting it into child packs linked from a
  parent README rather than writing one pack with more than 12 slices.

### S-10 Plans specify by example

As an executor, I want concrete examples and failure cases, not only general criteria, so that the
edge cases are decided before I meet them.

- **S-10.1** Given a PRD with stories, then each story has at least one rule. Each rule has an
  examples table of at least 2 rows, including at least one edge or failure case. Each row has an
  ID (`S-NN.k.eN`) and names the criterion it exercises.
- **S-10.2** Given a PRD, then it has **Non-functional requirements** (each a measurable target or
  `none`), **Assumptions** (each with how to validate and what changes if it is false), and, when
  it has stories, **Failure modes** (each with trigger, expected behaviour and what the user sees).
- **S-10.3** Given an executed slice, then its progress file shows a proof for every example row
  under the slice's criteria, as well as for each criterion.
- **S-10.4** Given a Refactor, then its behaviour-preservation contract is written as rules and
  examples (the characterization cases). Given a Bug, then its regression criteria are written as
  rules and examples.

### S-11 The design shows the moving parts

As an executor, I want the system's lifecycles, interactions and test approach drawn and stated, so
that I don't infer them from scattered prose.

- **S-11.1** Given a `design.md`, then it has a **Test strategy**: the test levels used, what each
  level proves, the fixtures and test data, and which level each example row is proven at.
- **S-11.2** Given work that touches an entity with a lifecycle, then `design.md` has a Mermaid
  state diagram for it and lists its illegal transitions.
- **S-11.3** Given work that adds or changes persisted entities or core types, then `design.md`
  has a domain model (Mermaid ER diagram). Given two or more components interacting, then it has a
  sequence diagram of the main flow.
- **S-11.4** Given size M or larger, then `design.md` has a **Pre-mortem**. Each item maps to a
  mitigation, a stop condition, or a risk-table row.
- **S-11.5** Given a Feature, Greenfield or Rewrite at size M or larger, then the PRD has a
  **Story map**, and each slice in `plan.md` names the map steps it touches.

### S-12 UI and observability are planned explicitly

As an executor building UI or production behaviour, I want screens and telemetry decided, so that I
don't invent layout or skip monitoring.

- **S-12.1** Given the `ui` modifier, then the plan has:
  - a screen inventory;
  - a navigation flow (Mermaid);
  - a text wireframe per screen in a `text` fence;
  - a state table per screen (loading, empty, error, success, partial);
  - responsive and accessibility notes.

  At size M or larger these live in `ux.md`. A high-fidelity mockup may be linked, never embedded.
- **S-12.2** Given the `observability` modifier, then the plan states:
  - the events logged, with levels and what must never be logged;
  - metrics;
  - alerts with thresholds;
  - how to tell in production that the change works, tied to the success measures.

## Rules and examples

Example IDs extend criterion IDs: `S-02.2.e1` is the first example under S-02.2. Each story's
examples are grouped here, rather than under each criterion, so the stories above stay scannable.

### S-01 Brainstorm leaves a durable brief

Rule: what the brainstorm learned is written only when the developer keeps it.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.1.e1 | A brainstorm on "add SSO" with two options ruled out | Wrap up, keep | README has Brief, both options under Ruled out, Route proposed, Status `discovered` |
| S-01.2.e1 | A brainstorm that concluded "not worth doing" | Wrap up, discard | No folder is created |
| S-01.1.e2 | The slug `sso` already exists under `docs/plans/` | Wrap up, keep | Folder `sso-2` is created; the existing pack is untouched |
| S-01.3.e1 | No memory MCP is configured | Any run | No warning about memory appears (nothing tries to use it) |

### S-02 One guided command

Rule: Status names the last finished phase, and resume starts at the next phase.

| ID | Given Status | When `planning docs/plans/x` | Then |
|---|---|---|---|
| S-02.2.e1 | `routed` | Run | Starts at Specify; no brainstorm, no route question |
| S-02.2.e2 | `sliced` | Run | Starts at Cold read |
| S-02.2.e3 | `executing` | Run | Shows progress per slice and `Next: ship-issue …`, then stops |
| S-02.3.e1 | `routed`, PRD checkpoint rejected | Session ends | `prd.md` on disk, Status still `routed` |
| S-02.2.e4 | README missing in `docs/plans/x` | Run | Stops: "no pack at docs/plans/x" and offers to start a new one |

### S-03 Packs grow with the work

Rule: the routing matrix decides the files; re-routing only adds.

| ID | Route | Then the pack has |
|---|---|---|
| S-03.2.e1 | Change S | `README.md` only, with Acceptance (with examples) and Verify |
| S-03.1.e1 | Feature M, modifiers `ui` | README, prd, context, design, plan, `ux.md` |
| S-03.3.e1 | Rewrite L | All core files plus `inventory.md` with Behaviour inventory and Parity matrix |
| S-03.4.e1 | Feature M re-routed to Rewrite | Existing files kept; `inventory.md` and required ADRs added; prd sections revised, with each revision listed in Open questions |
| S-03.5.e1 | Spike, outcome "use library X" | ADR-001 records it; wrapper offers re-route to Feature |

### S-04 Any model can execute a slice cold

Rule: everything an executor needs is in the pack and the repo, in a fixed shape.

| ID | Given | Then |
|---|---|---|
| S-04.2.e1 | A slice missing Stop conditions | `slice` rejects its own draft before the checkpoint |
| S-04.3.e1 | A pack with an untagged fence | Check 14 prints `PACK CODE FENCE` |
| S-04.3.e2 | A pack with a `text` wireframe and a `mermaid` flow | Check 14 prints nothing |
| S-04.4.e1 | PRD criterion S-05.3 is in no slice | `slice` reports the gap before the checkpoint |

### S-05 The plan is proven complete before execution

Rule: the reader is new each round and sees only the pack path.

| ID | Given | When | Then |
|---|---|---|---|
| S-05.1.e1 | Round 2 | Dispatch | A new subagent, not a continuation of round 1 |
| S-05.2.e1 | Reader asks "where is {integration} resolved?" | Classify | Blocking; the author edits design §7 before round 3 |
| S-05.3.e1 | 3 rounds, 1 blocking question left | End | `COLD READ BLOCKED`; Status stays `sliced`; nothing published |
| S-05.2.e2 | Reader asks "should XL packs be allowed?" | Classify | Developer-only; asked at once (Slice 5 Contracts) |

### S-06 Ship a whole pack

Rule: pack slices ship in plan order, from what is on the integration branch.

| ID | Given | When `ship-issue docs/plans/x` | Then |
|---|---|---|---|
| S-06.3.e1 | Plan PR not merged | Run | Stops before any slice: "merge its PR first" |
| S-06.1.e1 | Slices 1–3; `progress/slice-01.md` says `done` on main | Run | Ships 2 then 3 |
| S-06.2.e1 | Slice 2 returns `BLOCKED` | Run | No Ship step for 2; state `stuck`; slice 3 never starts |
| S-06.1.e2 | Slice 3 depends on 1 only; 2 and 3 are independent | Run | Order 1, 2, 3; still sequential, one PR each |

### S-07 Work without a pack stays the same

Rule: no marker means no pack behaviour.

| ID | Given | Then |
|---|---|---|
| S-07.1.e1 | Issue body without `Plan:` | Same phases, displays and final JSON as v1.3.2, minus the `Session …` lines |
| S-07.1.e2 | Issue body mentions "Plan: TBD" mid-paragraph | Not a marker (the line must start with `Plan: docs/plans/`); legacy mode |
| S-07.2.e1 | `ship-issue 12 13` | Groups and orders exactly as v1.3.2 |

### S-08 Planned versus real is recorded

Rule: every slice leaves a progress file, and the last one writes the retro.

| ID | Given | Then |
|---|---|---|
| S-08.1.e1 | Executor renamed a planned helper | Deviations row: plan said / reality / why / contract affected `n` |
| S-08.2.e1 | Last slice, every other progress file `done` | Its PR adds the Retro and sets Status `done` |
| S-08.2.e2 | Last-numbered slice, but slice 2 is still `blocked` | Not the last slice: no Retro is written |

### S-09 Work types are routed, not guessed

Rule: the wrapper proposes a route with reasons and the developer confirms.

| ID | Input | Proposed route |
|---|---|---|
| S-09.1.e1 | "Fix typo in signup email" | Change, S, no modifiers |
| S-09.2.e1 | "Users get logged out randomly" | Bug, cause unknown: recommend `debug` first |
| S-09.3.e1 | "These 9 lint findings" | Not routed: recommend `ship-issue` |
| S-09.4.e1 | "Rebuild billing and auth and admin" | XL: propose child packs per subsystem |
| S-09.1.e2 | "Move from Express 4 to 5" | Migration, M, no modifiers |

### S-10 Plans specify by example

Rule: a rule without an edge or failure example is incomplete.

| ID | Given | Then |
|---|---|---|
| S-10.1.e1 | A rule with only happy-path examples | `spec` adds a failure example or asks why none applies |
| S-10.2.e1 | A PRD with no observability needs | NFR table lists observability as `none`, not omitted |
| S-10.4.e1 | Refactor of a date parser | Preservation examples: the current outputs for 3 inputs, including an invalid one |

### S-11 The design shows the moving parts

Rule: the diagram appears only when its trigger applies.

| ID | Given | Then |
|---|---|---|
| S-11.2.e1 | Work on an Order with states draft/paid/shipped | State diagram, plus "shipped → draft" listed as illegal |
| S-11.3.e1 | A text-only copy change | No domain model and no sequence diagram |
| S-11.4.e1 | M-size pack, pre-mortem item "migration locks the table" | Maps to a stop condition in the migrating slice |

### S-12 UI and observability are planned explicitly

Rule: modifiers add content; their absence adds nothing.

| ID | Given | Then |
|---|---|---|
| S-12.1.e1 | Feature M with `ui`, 3 screens | `ux.md` with 3 wireframes and 3 state tables |
| S-12.1.e2 | A Figma link exists | Linked from `ux.md`; nothing embedded |
| S-12.2.e1 | `observability` on a payment webhook | Logs event IDs, never card data; alert on failure rate above threshold |

## Failure modes

| Failure | Trigger | Expected behaviour | What the developer sees | Criterion |
|---|---|---|---|---|
| Executor reads a stale pack | The pack changed on a branch but not on integration | Pack read from `origin/{integration}` only | Preflight deviations in the progress file | S-04, design §7 |
| Pack not merged | `ship-issue` before the plan PR merges | Stop before any slice | "merge its PR first" | S-06.3 |
| Cold read never converges | 3 rounds still blocking | `COLD READ BLOCKED`, no publish | The remaining questions | S-05.3 |
| Stop condition under `--auto` | Contract drift found mid-slice | `BLOCKED`, partial work and progress in one `wip:` commit, no PR | `stuck` in `ship-issue` output | 7.2, S-06.2 |
| Wrapper abandoned mid-way | Developer stops at a checkpoint | Files kept, Status at last finished phase | Resume picks up there | S-02.3 |
| Marker typo | `Plan: docs/plan/x` | A `Plan:` line that is not a `docs/plans/` path: warn and continue in legacy mode | "unrecognised Plan: line — legacy mode" | S-07.1.e2, design §7 |

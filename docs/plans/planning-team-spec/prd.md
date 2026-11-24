# PRD — Planning team: role gates in spec and slice

## Problem

`spec` and `slice` are written by one author, the main session, in one context. It writes
`context.md`, `prd.md`, `design.md` and `plan.md` itself (`context.md` §1, **One author today**),
and nothing outside that context checks any of them before the developer's checkpoint. Child 1 put
a review panel in front of the cold read, but by then every file exists: a wrong citation in
`context.md` has already shaped the prd, the design and every slice built on it.

The hyalOS records show where those problems came from. Of 95 blockers, 20 were Fact-checker
misses, 17 Test engineer and 16 Trust reviewer (`../planning-team-review/prd.md`, **Problem**).
Three causes belong to the stages this pack changes:

1. **Unchecked repo facts are built on.** `context.md` is the executor's map, and every later file
   cites it. A drifted line or a misread function caught in the panel means revising the prd, the
   design and the slices after they were written on it.
2. **Assumptions are written and never tested.** The prd's Assumptions table has a "how to
   validate" column (`skills/planning/references/templates/prd.md:54-60`), and nothing runs it.
   Measuring first worked for hyalOS core: its ring 3 run and RDSEED probe came before the plan
   (`../planning-team/README.md`, **Key insights**).
3. **Trust decisions arrive late.** The Trust reviewer first sees a pack in the panel, after the
   design and slices exist, so an answer to "where does the key come from" can reshape both.
   Decisions belong at the acceptance checkpoint, where the developer already is.

## Users and jobs

- **Developer:** runs `planning` on a topic and answers its checkpoints.
- **Facilitator:** the main session running `spec` and `slice`; dispatches every role and writes
  the files.
- **Executor:** the agent that builds a slice from the published pack.

**Jobs.**

- Developer: "When I approve the acceptance checkpoint, I want every trust question and every
  failed assumption in front of me at once, so I can decide them before anything is designed on
  them."
- Facilitator: "When I write a stage's file, I want it drafted by a role with only that job and
  checked by another before the developer sees it, so I am not checking my own work."
- Executor: "When I read `context.md`, I want every citation to have been checked by someone other
  than its author, so preflight finds drift, not mistakes."

## Goals

- G1. Each of `context.md`, `prd.md`, `design.md` and `plan.md` is drafted by a role with only that
  job, dispatched by the Facilitator.
- G2. `context.md` is checked by the Fact-checker before the prd is written on it.
- G3. Every assumption the prd states is probed, or says why it cannot be yet, before the design.
- G4. The Trust reviewer's questions reach the developer at the acceptance checkpoint, in the same
  single batch as every other developer-only item of that stage.
- G5. The slice draft is checked by the Test engineer and the Editor before the slice checkpoint.

## Non-goals

- Changing how the review panel runs before the cold read, the cold read itself, or trace-back
  (child 1), beyond the panel dispatching `review` cards only and the Fact-checker's F7 (ADR-004,
  ADR-005).
- Research roles for `brainstorm` (child 3).
- Scaling the roster by route across the whole flow, or changing the `planning` wrapper (child 4),
  beyond reading `handoff.md`, resuming its Spec pending entries at Specify, and refusing Approve
  and Publish while it exists (ADR-008).
  Until child 4, each role here runs whenever its stage runs.
- A gate on `design.md` before the design checkpoint. The panel reviews it before the cold read.
- Drafting ADRs, `inventory.md` or `ux.md` with a role. They stay with the Facilitator.
- New pack files other than the transient `handoff.md` (ADR-008). Gate findings are fixed in the
  files they concern, or asked at the checkpoint.

## Success measures

- M1. The next M or L pack planned with this team passes its cold read in at most 2 rounds.
- M2. In that pack's cold read, no question is traced `fact` to a `context.md` citation, and no
  question is traced `trust`.
- M3. That pack's developer is asked at most one message of decisions per checkpoint.

## Non-functional requirements

| Quality | Target |
|---|---|
| Performance | Each drafter is one dispatch step, plus one retry for a short draft; each gate is one dispatch step, its roles in parallel, plus at most one re-check, so a gate adds at most two dispatch steps before its checkpoint |
| Reliability | A role whose report is incomplete twice never stops the stage: the stage goes on without it and says so at the checkpoint |
| Security | Every role runs read-only (`subagent_type: Explore`) under the checksum guard; a changed pack voids the step and stops the skill |
| Privacy | none: roles read only the repository and the pack |
| Accessibility | none: no user interface |
| Observability | Every dispatch prints one display line with the role, its model and its result, and the checkpoint shows each gate's summary |
| Compatibility / portability | Without a subagent tool, the Facilitator works through each card itself and says so, as `dispatch.md` **No subagent tool** does |
| Maintainability | `skills/spec/SKILL.md` and `skills/slice/SKILL.md` stay under 400 lines, with procedure in reference files; each role is defined once, in its card |

## Assumptions

| Assumption | How to validate | If false |
|---|---|---|
| An `Explore` subagent can return a whole drafted file, several hundred lines, as its report without cutting it short | Dispatch the Scout on this repo in Slice 1's dry run, and compare the report's sections with `templates/context.md` | The drafting role writes in sections, one dispatch per section |
| The Agent tool accepts `model: opus` with `subagent_type: Explore` | Read child 1's record of the Trust reviewer's dispatch, `../planning-team-review/progress/slice-03.md:27` | Drafting roles run on the default model, recorded as `default model` |
| A tree built from `{base}` with the pack copied in, which before Phase 3 holds only a README and `context.md`, is enough for the Fact-checker | Read `skills/cold-read/references/tree.md:28-29`: the copy line copies whatever the pack holds | The gate copies the checkout's pack and records that |
| The panel can tell drafting cards from reviewing cards by a field in the card | Read `skills/cold-read/references/panel.md:13-14`: step 1 lists every card and dispatches each | Drafting cards live in a folder of their own |
| `spec` and `slice` have room for a pointer per new step | `wc -l skills/spec/SKILL.md skills/slice/SKILL.md` prints at most 385 for each | More of each skill's existing text moves to its reference file |

## Story map

| Map the code | Agree acceptance | Design | Slice |
|---|---|---|---|
| S-01, S-02 | S-03, S-04 | S-05 | S-06 |

## Stories and acceptance criteria

### S-01 Drafting roles

As the Facilitator, I want a drafting role defined once in a card and dispatched like a reviewing
role, so that each file is drafted by a role with only that job.

- **S-01.1** Given a drafting card in `skills/planning/references/roles/`, when the Facilitator
  dispatches it, then the prompt is the drafting frame in `dispatch.md` with the card pasted in, the
  role runs as `Explore` on the card's model under the checksum guard, and its report is the drafted
  file.
- **S-01.2** Given the drafted file in the report, when the Facilitator receives it, then it checks
  the draft has both marker lines naming its file and no second pair, `## Open points`, and every
  section the template's trigger requires for this route, other than those the Facilitator keeps; a
  draft missing any of them, in a Re-slice one that changes a slice the reason does not name, or no
  report at all, is
  dispatched once more, and a second short draft is written by the Facilitator itself, saying
  `Drafted by the Facilitator: {role} gave no complete draft.`
- **S-01.3** Given `cold-read`'s panel pass, when it lists `roles/`, then it dispatches the
  reviewing cards only, never a drafting card.
- **S-01.4** Given no subagent tool, when a drafting role is due, then the Facilitator drafts the
  file from the card itself and the checkpoint says `Drafted by the Facilitator: not independent.`

### S-02 The Scout and the context gate

As the developer, I want `context.md` written by a Scout and checked by the Fact-checker before the
prd is written on it, so that no later file is built on a wrong citation.

- **S-02.1** Given a pack that needs `context.md`, when `spec` Phase 2 runs, then the Scout drafts
  it from the README Brief and the repository, and the Facilitator writes it to the pack.
- **S-02.2** Given the written `context.md`, when the context gate runs, then the Fact-checker
  checks it, every blocking finding the Facilitator can fix is fixed, and the Fact-checker
  re-checks the fixes once, before Phase 3 starts.
- **S-02.3** Given a context gate finding that is developer-only, or that is blocking and not fixed
  after the re-check, when Phase 3 starts, then the finding is held and asked in the acceptance
  checkpoint's one batch.

### S-03 Analyst and one acceptance batch

As the developer, I want the prd drafted by an Analyst and reviewed for trust before I see it, with
every open decision of the stage in one message, so that I decide each one once, before design.

- **S-03.1** Given an approved context stage, or none where the route skips it, when `spec` Phase 3 runs, then the Analyst drafts
  `prd.md` (or, at size S, the README Slice's Outcome and Acceptance) and the Facilitator writes it.
- **S-03.2** Given the written prd, when the acceptance gate runs, then the Trust reviewer and the
  Fact-checker are dispatched in one step on the pack, before the acceptance checkpoint.
- **S-03.3** Given the acceptance gate's reports, when the acceptance checkpoint is shown, then
  every developer-only finding, every blocking Questionnaire row, every failed probe and every
  other item held for this checkpoint, the context gate's and the drafters' open points included,
  are asked as one batch, with the checkpoint, in one message.
- **S-03.4** Given the developer answers some items and defers others, when the checkpoint is
  approved, then each answer is written into the prd or an ADR, and each deferred item is a line in
  the README **Open questions**, never asked again.
- **S-03.5** Given a stage whose file is written, when its checkpoint has not yet been shown, then
  `handoff.md` holds a **Gate pending** entry for that file with its drafting line, its trust and
  fallback lines, its held items, and `Fix not re-checked` while a fix waits for its re-check; the
  checkpoint removes the entry, the file is deleted when
  empty, and a run that finds an entry re-runs only that file's gate on the file as it stands, or for `design.md`, which has no gate,
  goes straight to its checkpoint (ADR-008).
- **S-03.6** Given README Open questions `Deferred at …` lines or `handoff.md` entries holding gate Ids, when a later gate
  numbers its findings, then it continues from the highest Id, and a finding matching a deferred
  item names that Id and is not raised again.

### S-04 Assumption probes

As the developer, I want each assumption the prd states tested before the design is written on it,
so that a false assumption changes the prd, not a finished plan.

- **S-04.1** Given a prd with an Assumptions table, when the acceptance gate's Fact-checker runs,
  then it probes each row: it runs a read-only check that settles it, or says why none can run yet.
- **S-04.2** Given the probe results, when the Facilitator writes them, then each Assumptions row
  records `held`, `false` or `not run: {reason}`, with the evidence.
- **S-04.3** Given a row probed `false`, when the acceptance checkpoint is shown, then the row's
  "If false" consequence is in the batch for the developer, and the design is not written until it
  is answered or deferred.

### S-05 The Architect

As the developer, I want `design.md` drafted by an Architect from the approved prd and context, so
that the design is drafted by a role that only designs.

- **S-05.1** Given an approved acceptance checkpoint and a route that needs `design.md`, when `spec`
  Phase 7 runs, then the Architect drafts it from the approved prd, `context.md` and `decisions/`,
  with each section its trigger requires, and the Facilitator writes it.
- **S-05.2** Given the Architect's draft, when it is written, then the Phase 7 self-check runs on it
  as today, and the design checkpoint shows it with its drafting line and asks the Architect's held
  open points with it, in one message.

### S-06 The Planner and the slice gate

As the developer, I want the slices drafted by a Planner and checked by the Test engineer and the
Editor before I approve them, so that testability and consistency problems are fixed before the
cold read.

- **S-06.1** Given a specified pack, when `slice` Phase 2 runs, then the Planner drafts `plan.md`
  from the spec files and the Facilitator writes it; the Phase 4 Self-check runs on the written
  file as today.
- **S-06.2** Given a `plan.md` that passes the Self-check, when the slice gate runs, then the Test
  engineer and the Editor are dispatched in one step, blocking findings the Facilitator can fix are
  fixed, the Self-check runs again on the fixed file, and each role with a fixed finding re-checks once, before the slice checkpoint.
- **S-06.3** Given the slice gate's developer-only findings, and blocking findings left after the
  re-check, when the slice checkpoint is shown, then they are asked as one batch with it, and
  Approve is not offered while a blocking one is unanswered or deferred.
- **S-06.4** Given an answer at the slice checkpoint that needs a spec file changed, when `slice`
  stops, then `handoff.md` holds a **Spec pending** entry with the item, its file and section, the
  answer and the date; `planning` resumes it at Specify, and `spec` removes it when its checkpoint
  approves the revision (ADR-008).

## Rules and examples

### S-01 Drafting roles

Rule: a drafting role is dispatched by the same contract as a reviewing role, with its own frame,
and its report is the file.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.1.e1 | The Scout card, model `sonnet` | Dispatched | One `Explore` call on `sonnet` with the drafting frame; the guard holds; the report is a `context.md` |
| S-01.1.e2 | A drafting role that edits a pack file in its tree | The guard runs after the report | The step is void: the changed files are named, the tree is removed, and the skill stops `{SKILL} STOPPED` with Status unchanged |

Rule: a short draft is retried once, then the Facilitator drafts it.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.2.e1 | An Analyst draft with every section the Feature route requires | Checked | Accepted and written |
| S-01.2.e2 | An Analyst draft with no Rules and examples, twice | Checked | The Facilitator writes the prd itself, and the acceptance checkpoint says `Drafted by the Facilitator: Analyst gave no complete draft.` |

Rule: the panel never dispatches a drafting card.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.3.e1 | `roles/` holding four reviewing and four drafting cards | `cold-read`'s panel pass step 1 | Four dispatches: the Fact-checker, the Editor, the Test engineer and the Trust reviewer |
| S-01.3.e2 | A card with no field saying whether it drafts or reviews | The panel lists `roles/` | It is not dispatched, and the panel says `Card {file} states no kind; not dispatched.` |

Rule: without a subagent tool the Facilitator drafts from the card and says so.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.4.e1 | No subagent tool | `spec` Phase 2 needs `context.md` | The Facilitator drafts it by the Scout card; the acceptance checkpoint says `Drafted by the Facilitator: not independent.` |
| S-01.4.e2 | No subagent tool | The context gate runs | The Facilitator works through the Fact-checker card itself, and the checkpoint says `Gate run by the Facilitator: not independent.` |

### S-02 The Scout and the context gate

Rule: the Scout drafts `context.md` with a citation for every claim.

| ID | Given | When | Then |
|---|---|---|---|
| S-02.1.e1 | A Feature pack at `routed` | `spec` Phase 2 | The Scout's draft is written as `context.md`, its opening line giving the date and `{sha}`, the short commit of `{base}` its citations were checked at, and its Read order entry added |
| S-02.1.e2 | A Change pack at size S, where `context.md` is not required | `spec` Phase 2 | No Scout is dispatched and no context gate runs |

Rule: the Fact-checker checks `context.md` before the prd is written on it.

| ID | Given | When | Then |
|---|---|---|---|
| S-02.2.e1 | A `context.md` citing a function at `:145` that is at `:152` | The context gate | The Fact-checker reports it under F1; the citation is fixed; the re-check reports it checked; Phase 3 starts |
| S-02.2.e2 | A `context.md` with no blocking finding | The context gate | No fix and no re-check; Phase 3 starts |

Rule: what the context gate cannot settle goes to the acceptance batch.

| ID | Given | When | Then |
|---|---|---|---|
| S-02.3.e1 | A finding that the pack depends on a value the repo never fixes, which only the developer can choose | The context gate triages it developer-only | It is held, and asked in the acceptance batch, not on its own |
| S-02.3.e2 | A fixed finding the re-check reports again | The re-check ends | It is held, not fixed again, and asked in the acceptance batch |

### S-03 Analyst and one acceptance batch

Rule: the Analyst drafts the prd from the README and the checked `context.md`.

| ID | Given | When | Then |
|---|---|---|---|
| S-03.1.e1 | A Feature pack at size M with a checked `context.md` | `spec` Phase 3 | The Analyst's prd is written with every section the route triggers |
| S-03.1.e2 | A Change at size S | `spec` Phase 3 | The Analyst drafts the README Slice's Outcome and Acceptance, and no `prd.md` |

Rule: the acceptance gate is one dispatch step.

| ID | Given | When | Then |
|---|---|---|---|
| S-03.2.e1 | A written prd | The acceptance gate | The Trust reviewer and the Fact-checker go in one message, each in the same tree |
| S-03.2.e2 | A Trust reviewer that finds no outside party or input | Its report | Its Questionnaire is the header row and `No outside inputs.`; the checkpoint says `Trust: no outside inputs.` |

Rule: the developer gets one message per checkpoint.

| ID | Given | When | Then |
|---|---|---|---|
| S-03.3.e1 | Two Trust questions, one failed probe and one held context finding | The acceptance checkpoint | One message holds all four, each with its Id, file and section, and the options the pack leaves open, followed by approve, change or stop |
| S-03.3.e2 | A Trust question and a Fact-checker finding that ask the same thing | The batch is collected | They are one item listing both Ids |

Rule: answers go into the pack; deferred items go to Open questions.

| ID | Given | When | Then |
|---|---|---|---|
| S-03.4.e1 | The developer answers a key-source question | Approve | The answer is written into the prd, with the date, or into an ADR when it chooses between options |
| S-03.4.e2 | The developer defers one item | Approve | It becomes an Open questions line `Deferred at the acceptance checkpoint on {date}: {Id} — {question}.`, and it is not asked again |

Rule: work in flight between runs is in `handoff.md`, and only there.

| ID | Given | When | Then |
|---|---|---|---|
| S-03.5.e1 | A session that ended after the context gate, with one held item, before Phase 4 | `spec` runs again | No Scout is dispatched; the context gate re-runs on `context.md` as it stands; the held item, under its Id, is asked at the acceptance checkpoint with the entry's drafting line |
| S-03.5.e2 | The acceptance checkpoint approved, with the only entries those of its stage | It ends | Those entries are removed and `handoff.md` is deleted |
| S-03.5.e3 | `handoff.md` still holding an entry | `planning` reaches Approve or Publish | Each is refused, naming the entry |
| S-03.6.e1 | A README line `Deferred at the acceptance checkpoint on {date}: GF3 — …` | A later run's context gate reports the same thing and one new finding | The match names `GF3` and is not asked again; the new finding is `GF4` |

### S-04 Assumption probes

Rule: every assumption is probed, or says why it cannot be.

| ID | Given | When | Then |
|---|---|---|---|
| S-04.1.e1 | An assumption "the tool accepts `model: opus`" whose check is a file to read | The Fact-checker probes it | It quotes the line that settles it, and the row records `held` |
| S-04.1.e2 | An assumption whose check needs a dry run of a slice not yet built | The Fact-checker probes it | No command is run, and the row records `not run: needs Slice 1's dry run` |

Rule: probe results are written into the row.

| ID | Given | When | Then |
|---|---|---|---|
| S-04.2.e1 | Three probed rows | The Facilitator writes the results | Each row's result is `held`, `false` or `not run: {reason}`, with its evidence |
| S-04.2.e2 | A check that would change state (a write, an install, a network call) | The Fact-checker probes it | It is not run, and the row records `not run: changes state` |

Rule: a false assumption stops the design until the developer decides.

| ID | Given | When | Then |
|---|---|---|---|
| S-04.3.e1 | A row probed `false` | The acceptance checkpoint | Its "If false" text is a batch item, and Approve waits for its answer or its deferral |
| S-04.3.e2 | Every row `held` or `not run` | The acceptance checkpoint | No probe item is in the batch |

### S-05 The Architect

Rule: the Architect drafts the design from the approved files only.

| ID | Given | When | Then |
|---|---|---|---|
| S-05.1.e1 | An approved Feature prd at size M | `spec` Phase 7 | The Architect's `design.md` is written with each section its trigger requires |
| S-05.1.e2 | A Bug at size S with no `design.md` required and none accepted | `spec` Phase 7 | No Architect is dispatched |

Rule: the drafted design goes through the self-check and checkpoint as today.

| ID | Given | When | Then |
|---|---|---|---|
| S-05.2.e1 | An Architect draft with an untagged fence | The Phase 7 self-check | It fails; the Facilitator fixes the fence before the checkpoint |
| S-05.2.e2 | An Architect draft that passes | The design checkpoint | It is shown with its drafting line, `Drafted by the Architect, Opus (Agent tool, model: opus, Explore).` |
| S-05.2.e3 | An Architect draft with one developer-only open point | The design checkpoint | It is asked with the checkpoint, in one message; a deferral is an Open questions line |

### S-06 The Planner and the slice gate

Rule: the Planner drafts the slices; the Self-check still runs.

| ID | Given | When | Then |
|---|---|---|---|
| S-06.1.e1 | A specified Feature pack at size M | `slice` Phase 2 | The Planner's `plan.md` is written, then the Phase 4 Self-check commands run on it |
| S-06.1.e2 | A Planner draft of 13 slices | Phase 2 Count | The hard stop holds: `plan.md` is not written, and `slice` stops as today |

Rule: the Test engineer and the Editor check the slices before the checkpoint.

| ID | Given | When | Then |
|---|---|---|---|
| S-06.2.e1 | A slice whose Verify has a command with no expected output | The slice gate | The Test engineer reports it under V1; it is fixed; the Test engineer re-checks it once |
| S-06.2.e2 | A rule stated two ways in `prd.md` and `plan.md` | The slice gate | The Editor reports it under E1; it is fixed in `plan.md`, or, when the prd is the wrong side, held for the batch, since `slice` never edits the prd |

Rule: the slice checkpoint has one batch and waits on blocking items.

| ID | Given | When | Then |
|---|---|---|---|
| S-06.3.e1 | One developer-only finding from the Editor | The slice checkpoint | It is asked with the checkpoint, in one message |
| S-06.3.e2 | A blocking finding left after the re-check and deferred by the developer | The slice checkpoint | Approve is not offered; the developer may change or stop, and a stop says `Stopped: {Id} unanswered — next: planning {path} revise spec.` |
| S-06.3.e3 | An answer that needs `prd.md`, `design.md` or an ADR changed | The slice checkpoint | `slice` edits no spec file and stops with `Stopped: {Id} needs a spec change — next: planning {path} revise spec.` |

Rule: a spec-change answer survives the stop.

| ID | Given | When | Then |
|---|---|---|---|
| S-06.4.e1 | The S-06.3.e3 stop | `planning {path}` runs next | `handoff.md` holds `## Spec pending: {Id}` with the answer; `planning` resumes at Specify with it; when `spec`'s checkpoint approves, the entry and the file are gone |

## Failure modes

| Failure | Trigger | Expected behaviour | What the user sees | Criterion |
|---|---|---|---|---|
| A role writes in its tree | A file changes between the two guard runs | The step is void, the tree is removed, the skill stops with Status unchanged | `{SKILL} STOPPED` and the changed files | S-01.1 |
| A drafting role returns a short draft twice | Missing required sections, marker lines or `## Open points`, a marker naming another file, a second pair of markers, in a Re-slice a change to an unnamed slice, or no report at all | The Facilitator drafts the file | `Drafted by the Facilitator: {role} gave no complete draft.` | S-01.2 |
| A reviewing role gives no complete report twice | Missing sections or checklist rows, or no report at all | The gate goes on without it | `Gate: {role} gave no complete report; not reviewed by {role}.` at the checkpoint | S-02.2 |
| No subagent tool | The harness has none | The Facilitator works through each card | `not independent` lines at the checkpoint | S-01.4 |
| `{base}` cannot be fetched | `git fetch` fails | The tree is built from the stale ref, or from `HEAD` | The fallback line at the checkpoint | S-02.2 (Slice 1, 1.4) |
| A probe would change state | The check writes, installs or uses the network | It is not run | `not run: changes state` in the row | S-04.2 |
| A blocking slice-gate finding is deferred | The developer defers it | Approve is not offered | The stop message naming `revise spec` | S-06.3 |
| A session ends before a checkpoint | The developer or the harness ends it | The next run re-runs the file's gate from its `handoff.md` entry, or for `design.md` shows its checkpoint | The entry's lines at the checkpoint | S-03.5 |

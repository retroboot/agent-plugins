# PRD — Planning team: discovery research in brainstorm

## Problem

`brainstorm` is one agent. In Phase 2 it reads "the relevant code, open issues, and recent
commits" itself, silently, and in Phases 3 and 4 it opens and holds the conversation from that
reading alone (`context.md` §1, **`brainstorm` today is one agent**). It dispatches no role
(`context.md` §1, **`brainstorm` is the only phase skill that dispatches no role**). What the
conversation knows depends on what that one agent thinks to look at. There are three causes:

1. **The repository is read once, by the agent that also talks.** Nothing in `brainstorm` makes sure
   that what already exists in the area the topic touches gets in front of the developer before
   they commit to a direction.
2. **Past packs are not read at all.** `docs/plans/` holds three `done` packs, each with a **Retro**
   and a `cold-read.md` (`context.md` §1, **Past packs the Historian would read**). Their lessons
   reach a new brainstorm only when someone carries them in by hand. This pack's own Brief carries
   two of child 2's Retro lessons that way (README **Brief**).
3. **No one argues against the idea.** Phase 4 asks the agent to challenge assumptions
   (`skills/brainstorm/SKILL.md:114-116`), but the agent that holds the conversation is also the
   one checking it, which is the single-context problem the parent pack names
   (`../planning-team/README.md`, **Brief**).

## Users and jobs

- **Developer:** runs `brainstorm`, directly or through `planning`, and holds the conversation.
- **Facilitator:** the main session running `brainstorm`. It dispatches the research roles and
  brings their findings into the conversation (`context.md` §5).
- **Research role:** the Scout, the Historian or the Skeptic. It reads and reports, and never talks
  to the developer.

**Jobs.**

- Developer: "When I start a brainstorm, I want what the repository already does, what earlier
  packs learned about this ground, and why the idea could fail in front of me early, so I can
  choose a direction knowing all three."
- Facilitator: "When I open and carry the conversation, I want research done by roles with only
  that job, in parallel, so I am not researching and arguing against my own framing in the same
  context that talks."
- Research role: "When I am dispatched on a topic, I want one tight job and a fixed report shape,
  so my findings can be brought into the conversation as they stand."

## Goals

- G1. Before the conversation opens, the Scout, the Historian and the Skeptic research the topic
  in parallel, each from a role card.
- G2. Their findings reach the developer only through the Facilitator, in the conversation.
- G3. Research can be run again during the conversation when it reaches ground the first research
  did not cover.
- G4. A session with no subagent tool still gets all three researches, done by the Facilitator and
  marked as not independent.
- G5. What `brainstorm` writes and the result it returns stay as they are today.

## Non-goals

- Changing `spec`, `slice`, `cold-read` or the `planning` wrapper's roster by route (children 1, 2
  and 4; README **Brief**), apart from the one `cold-read` panel line S-07.3 needs (Checkpoint
  answers, A1) and the five research additions to `dispatch.md` (ADR-001, ADR-009). This covers `planning` Phase 2's reading of the result
  (`context.md` §2, `skills/planning/SKILL.md` row). How this work affects the `cold-read` panel
  is set by S-07.3 and A1.
- A new README section or file for research findings. Phases 6 and 7 write what they write today
  (`context.md` §2, Phases 6 and 7 row: kept). A finding reaches the README only through the Brief,
  Ruled out, Key insights and Open questions that the conversation builds.
- Research roles that talk to the developer, or that dispatch one another (`context.md` §3,
  **Facilitator and no nesting**).
- Research roles that decide anything. The Skeptic's case against building reaches the developer
  as a challenge, and only the developer rules an option out.
- Changing Phase 5's route proposal or Phase 8's JSON result (`context.md` §2, Phases 5 and 8 rows:
  kept).
- A new skill. No marketplace, `CLAUDE.md`, `README.md` or `.agents/skills/` entry changes
  (`context.md` §1, **Product**).
- Reading GitHub or GitLab issues as part of the Historian's sources. The Historian reads past packs
  under `docs/plans/`. Phase 2's reading of open issues and recent commits stays with the Facilitator
  (ADR-002, ADR-007).

## Success measures

- M1. In the next pack brainstormed with this team, the opening of the conversation names at least
  one finding from each of the Scout, the Historian and the Skeptic, each with its source.
- M2. That pack's kept README carries, in its Brief, Ruled out or Key insights, at least one lesson
  from an earlier pack's Retro or `cold-read.md`, cited by pack, without the developer having
  brought it in.
- M3. In that pack's cold read, no question repeats a lesson that an earlier pack's Retro already
  recorded.

## Non-functional requirements

| Quality | Target |
|---|---|
| Performance | The research before the opening is one dispatch step, its three roles in parallel, plus at most one retry per incomplete report; each research during the conversation is one dispatch step |
| Reliability | A research role that gives no complete report twice never stops the brainstorm: the conversation opens without it and says which role is missing |
| Security | Every research role runs read-only (`subagent_type: Explore`) under the checksum guard (`context.md` §3, **Tree and guard**); a changed file voids the research and is reported |
| Privacy | none: roles read only the repository and its past packs |
| Accessibility | none: no user interface |
| Observability | The developer can tell which role gave each finding brought into the conversation, and whether it was run independently or by the Facilitator |
| Compatibility / portability | Without a subagent tool, the Facilitator works through each research card itself and says so, as `dispatch.md` **No subagent tool** does for the panel, drafting roles and gates (`context.md` §2, dispatch.md 203-217 row) |
| Maintainability | `skills/brainstorm/SKILL.md` stays under 400 lines, with new procedure in reference files (`context.md` §1, **Size convention**); reference text is moved out before pointers are added, not when the budget runs out (child 2 Retro, README **Brief**); each role is defined once, in its card under `skills/planning/references/roles/` |

## Assumptions

| Assumption | How to validate | If false | Probe |
|---|---|---|---|
| The past packs the Historian reads are committed on `{base}`, so a tree built from `{base}` holds them | `git ls-tree -r --name-only {base} docs/plans` lists the `README.md` and `cold-read.md` of `planning-redesign`, `planning-team-review` and `planning-team-spec` | The Historian reads the checkout's `docs/plans/`, and the design says how the guard covers it | held: `git ls-tree -r --name-only origin/main docs/plans` lists all six files (acceptance gate, 2026-11-24) |
| One `Explore` subagent can read every past pack's Retro and `cold-read.md` (802 lines of `cold-read.md` today) and still return a complete report | `wc -l docs/plans/*/cold-read.md docs/plans/*/README.md`, then one Historian dispatch on this repository in the first slice's dry run, checking its report against its card's **Output** | The Historian reads Retros first and opens a `cold-read.md` only for a pack whose Retro touches the topic | not run: needs the Historian card (the 802-line count holds) |
| Three `Explore` dispatches can go in one message and run at once | Read `skills/cold-read/references/panel.md:19-20`, where the panel sends every card's prompt in one step | The three roles run one after another, and the Performance target becomes three dispatch steps | held, as far as the repository settles it: `skills/cold-read/references/panel.md:19-20` |
| `skills/brainstorm/SKILL.md` has room for the new pointers inside the 400-line budget | `wc -l skills/brainstorm/SKILL.md` prints 287 or fewer | More of `brainstorm`'s text moves to `skills/brainstorm/references/` first | held: `wc -l` printed 287 |
| The Skeptic can find grounded reasons against an idea from the topic alone, before the conversation has framed it | A dry run of the Skeptic on a fixture topic of one sentence gives at least one finding that names its evidence or its reasoning | The Skeptic runs only during the conversation, once the Brief has an outcome and a scope | not run: needs the Skeptic card and a dry run |
| Research before the opening does not delay the first reply so much that the developer would rather go without it | Time the Phase 2 research step in Slice 3's first Phase 2 dry run and record it in the progress file | Nothing changes in a slice: the time is judged by the developer from the Retro (`design.md` R3, DR9) | not run: needs the Phase 2 research step built |

## Story map

| Research before the conversation | Open the conversation | Iterate | Keep or discard and return |
|---|---|---|---|
| S-01, S-02, S-03, S-04, S-08 | S-05 | S-06 | S-07 |

## Stories and acceptance criteria

### S-01 The Scout's research use

As the developer, I want a Scout to read the repository for what already exists in the area the
topic touches, so that the conversation starts from what is really there.

- **S-01.1** Given a topic, when the Scout is dispatched for research, then its report lists what
  already exists that the topic touches (skills, references, role cards, conventions), each with a
  `path:line` citation, and says so when it finds nothing.
- **S-01.2** Given the Scout's research use, when `spec` Phase 2 dispatches the Scout to draft
  `context.md`, then that draft is made as today (`context.md` §2, `skills/spec/SKILL.md` row), and
  the research use does not change what it drafts.

### S-02 The Historian

As the developer, I want a Historian to read past packs, their Retros and their cold-read records,
so that what earlier work learned about the same ground reaches this brainstorm.

- **S-02.1** Given a role card for the Historian in `skills/planning/references/roles/`, when it is
  read, then it has the card shape (`context.md` §3, **Role card shape**) and a letter no other card
  uses (`context.md` §1, **Roles live in one folder**).
- **S-02.2** Given a topic and the past packs under `docs/plans/`, when the Historian is
  dispatched, then its report gives each lesson that bears on the topic, citing the pack and the
  Retro row or `cold-read.md` round it comes from, and says so when no past pack touches the topic.
- **S-02.3** Given a resumed brainstorm, when the Historian is dispatched, then the pack being
  brainstormed is not read as a past pack (`context.md` §5, **Past pack**).

### S-03 The Skeptic

As the developer, I want a Skeptic to look for why the idea could fail, or should not be built, so
that the case against it is made by someone other than the agent holding the conversation.

- **S-03.1** Given a role card for the Skeptic in `skills/planning/references/roles/`, when it is
  read, then it has the card shape and a letter no other card uses.
- **S-03.2** Given a topic, when the Skeptic is dispatched, then its report gives each reason the
  idea could fail and each reason it should not be built, apart from each other, each naming its
  evidence (a `path:line`, a past pack or a stated line of reasoning).
- **S-03.3** Given a Skeptic finding that the idea should not be built, when the Facilitator brings
  it into the conversation, then it is put to the developer as a challenge, and it reaches
  **Ruled out** only if the developer drops the option.

### S-04 Research before the conversation

As the Facilitator, I want the three researches run in parallel before I say anything, so that the
opening is built on them.

- **S-04.1** Given any run that reaches Phase 3 with a topic, when Phase 2 runs, then the Scout,
  the Historian and the Skeptic are dispatched in one step, under one guard, before Phase 3
  presents anything.
- **S-04.2** Given each branch of Phase 1 (a new topic, no input, a path with no README, and a
  resume at `discovered`, at `routed` to `approved`, and at `published` to `done`; `context.md` §3,
  **Resume rules in `brainstorm`**), when the run reaches Phase 2, then research runs in each, and in
  none does it write a file in the checkout (`design.md` **Checkpoint answers**, DR1).
- **S-04.3** Given no input, when the developer names the topic in answer to Phase 1's question,
  then research is dispatched on that topic before the Facilitator presents its understanding.
- **S-04.4** Given a research role whose report is incomplete, when the Facilitator checks it, then
  the role is dispatched once more, and a second incomplete report is recorded and the conversation
  opens without it (`context.md` §3, **Completeness and one retry**).

### S-05 Findings reach the conversation through the Facilitator

As the developer, I want one voice in the conversation that has read all the research, so that I
talk to the Facilitator, not to three researchers.

- **S-05.1** Given the research reports, when Phase 3 opens, then the Facilitator's 2–4 sentences of
  understanding draw on them, and it still asks a single question (`skills/brainstorm/SKILL.md:82-84`).
- **S-05.2** Given a finding the Facilitator brings in, when the developer asks where it came from,
  then the Facilitator names the role that gave it and the finding's source.
- **S-05.3** Given research findings, when they are not yet in the conversation, then each is
  either brought in at the opening, held for a later reply in Phase 4, or set aside, and none is
  sent to the developer by the research role itself.
- **S-05.4** Given a resumed brainstorm, when Phase 3 opens from the saved README
  (`skills/brainstorm/SKILL.md:94-101`), then findings that contradict a saved **Ruled out** entry
  are named as such, and the entry is not argued again unless the developer reopens it.

### S-06 Research during the conversation

As the developer, I want research run again when the conversation reaches new ground, so that a
direction found halfway through gets the same scrutiny as the first one.

- **S-06.1** Given a Phase 4 conversation that reaches ground the earlier research did not cover,
  when the Facilitator or the developer asks for research on it, then the roles it needs are
  dispatched in one step on that ground, and the conversation goes on with their findings.
- **S-06.2** Given research running during the conversation, when its reports arrive, then they
  reach the developer only through the Facilitator, as S-05 says.

### S-07 What brainstorm writes and returns is unchanged

As the `planning` wrapper, I want `brainstorm`'s files and result to stay as they are, so that
nothing downstream changes because research was added.

- **S-07.1** Given any run, when it ends, then the only file `brainstorm` writes is the kept
  README of Phase 7, as today, and a discarded, not routed or read-only run writes nothing in the
  checkout (`context.md` §1, **Files are the only state**; `design.md` DR1).
- **S-07.2** Given any run, when Phase 8 runs, then the JSON result has the same statuses and keys
  as today (`context.md` §1, **`brainstorm` ends with a JSON result that `planning` reads**).
- **S-07.3** Given the new research cards in `skills/planning/references/roles/`, when `cold-read`'s
  panel pass lists the folder, then it dispatches the same review cards as before, and prints no
  line about a research card (Checkpoint answers, A1; today any Kind other than `review` or
  `draft` prints `Card {file} states no kind; not dispatched.`, `context.md` §2, `panel.md` row).
- **S-07.4** Given the new research cards, when `spec` and `slice` dispatch their drafting roles and
  gates, then they dispatch the same cards as before.

### S-08 No subagent tool

As the developer on a harness with no subagent tool, I want the research done anyway and marked,
so that I know it was not independent.

- **S-08.1** Given no subagent tool, when research is due, then the Facilitator works through each
  research card itself, in the same tree under the same guard, and tells the developer the research
  was not independent, with the line `Research run by the Facilitator: not independent.`
- **S-08.2** Given no subagent tool, when Phase 3 opens, then the findings the Facilitator worked
  out by each card are brought into the conversation as S-05 says.

## Rules and examples

### S-01 The Scout's research use

Rule: the Scout's research report says what exists that the topic touches, with citations.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.1.e1 | The topic "staff `brainstorm` with research roles" in this repository | The Scout is dispatched for research | Its report names `skills/brainstorm/SKILL.md` Phase 2 and `skills/planning/references/roles/dispatch.md`, each with a `path:line` |
| S-01.1.e2 | A topic about an area the repository has nothing on | The Scout is dispatched for research | Its report says nothing exists that the topic touches, and cites no path |

Rule: the research use leaves the Scout's `context.md` drafting as it is.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.2.e1 | A Feature pack at `routed` | `spec` Phase 2 dispatches the Scout | Its draft is a `context.md` from `templates/context.md`, as today |
| S-01.2.e2 | A brainstorm that has just run the Scout for research | `spec` Phase 2 runs on the kept pack | The Scout is dispatched again to draft, and its research report is not used in place of the draft |

### S-02 The Historian

Rule: the Historian card has the shared card shape and a letter of its own.

| ID | Given | When | Then |
|---|---|---|---|
| S-02.1.e1 | The Historian card | Read | It has `# Role: Historian`, `## Letter`, `## Model`, `## Kind`, `## Job`, `## Inputs`, `## Checklist` and `## Output` |
| S-02.1.e2 | The Historian card | Its letter is compared with the letters of every other card (N, R, E, F, L, S, V, T and the Skeptic's) | It matches none |

Rule: each lesson the Historian gives cites the pack and the record it comes from.

| ID | Given | When | Then |
|---|---|---|---|
| S-02.2.e1 | A topic that changes a phase skill's route branches, and `planning-team-spec`'s Retro row "read every route branch of each phase a slice changes" | The Historian is dispatched | Its report gives that lesson, citing `docs/plans/planning-team-spec/README.md` **Retro** |
| S-02.2.e2 | A topic no past pack touches | The Historian is dispatched | Its report says no past pack bears on the topic, and gives no lesson |
| S-02.2.e3 | A past pack at `routed` with an empty Retro and no `cold-read.md` | The Historian reads it | It reads what the pack holds, gives no Retro lesson from it, and says the pack has none |

Rule: the pack being brainstormed is never its own history.

| ID | Given | When | Then |
|---|---|---|---|
| S-02.3.e1 | A resume of `docs/plans/<slug>` at `discovered` | The Historian is dispatched | Its report cites no part of `docs/plans/<slug>/` as a past pack |
| S-02.3.e2 | A new brainstorm whose topic matches a `done` pack | The Historian is dispatched | That `done` pack is read as a past pack |

### S-03 The Skeptic

Rule: the Skeptic card has the shared card shape and a letter of its own.

| ID | Given | When | Then |
|---|---|---|---|
| S-03.1.e1 | The Skeptic card | Read | It has the same eight headings as S-02.1.e1, with `# Role: Skeptic` |
| S-03.1.e2 | The Skeptic card | Its letter is compared with every other card's | It matches none, the Historian's included |

Rule: the Skeptic keeps "could fail" apart from "should not be built", and each finding names its
evidence.

| ID | Given | When | Then |
|---|---|---|---|
| S-03.2.e1 | A topic whose idea repeats an option a past pack ruled out | The Skeptic is dispatched | Its report gives a "should not be built" finding naming that pack's **Ruled out** entry |
| S-03.2.e2 | A topic the Skeptic finds no reason against | The Skeptic is dispatched | Its report says it found none under each heading, and invents no finding |

Rule: a case against building is a challenge, not a decision.

| ID | Given | When | Then |
|---|---|---|---|
| S-03.3.e1 | A Skeptic finding "should not be built" | The developer keeps the option after hearing it | The option is not in **Ruled out**, and the finding may be recorded under **Key insights** or **Open questions** |
| S-03.3.e2 | The same finding | The developer drops the option | It is a **Ruled out** entry with the developer's reason |

### S-04 Research before the conversation

Rule: the three researches run in one step before anything is presented.

| ID | Given | When | Then |
|---|---|---|---|
| S-04.1.e1 | A new topic | Phase 2 runs | Three dispatches go in one message; Phase 3 starts after all three reports are in or recorded as missing |
| S-04.1.e2 | A research role that edits a file in its tree | The guard runs after the reports | The research is void, the changed files are named to the developer, and no finding from it is brought in |

Rule: research runs in every branch of Phase 1 that reaches the conversation, and writes nothing.

| ID | Given | When | Then |
|---|---|---|---|
| S-04.2.e1 | A resume at `routed` | Phase 2 runs | Research runs, and the pack folder is unchanged until Phase 7 |
| S-04.2.e2 | A resume at `published` | The run ends | Research ran, the conversation ran, and nothing was written (`skills/brainstorm/SKILL.md:61-64`) |
| S-04.2.e3 | A pack path with no README | Phase 1 says `No pack at {path}` and the developer names a topic | Research runs on that topic as for a new brainstorm |

Rule: with no input, research waits for the topic.

| ID | Given | When | Then |
|---|---|---|---|
| S-04.3.e1 | No input | Phase 1 asks what the developer wants to work through | No research is dispatched yet |
| S-04.3.e2 | No input, then the developer names a topic | The answer arrives | Research is dispatched on it, and the understanding of the topic is presented after the reports |

Rule: an incomplete research report is retried once, then the conversation goes on without it.

| ID | Given | When | Then |
|---|---|---|---|
| S-04.4.e1 | A Historian report missing its **Output** sections | Checked | The Historian is dispatched once more |
| S-04.4.e2 | A Historian report incomplete twice | Checked again | The opening goes ahead on the Scout's and the Skeptic's findings, and the developer is told the Historian gave no complete report |

### S-05 Findings reach the conversation through the Facilitator

Rule: the opening draws on the research and still asks one question.

| ID | Given | When | Then |
|---|---|---|---|
| S-05.1.e1 | Three complete reports | Phase 3 opens | 2–4 sentences that draw on the findings, then one question |
| S-05.1.e2 | Reports that hold many findings | Phase 3 opens | Still one question; the findings not used are held for Phase 4 |

Rule: every finding brought in can be traced to its role and source.

| ID | Given | When | Then |
|---|---|---|---|
| S-05.2.e1 | A finding from the Historian in the opening | The developer asks where it came from | The Facilitator names the Historian and the past pack it cites |
| S-05.2.e2 | A finding the Facilitator worked out by the Skeptic card with no subagent tool | The developer asks | The Facilitator names the Skeptic card and says it was not run independently |

Rule: only the Facilitator talks to the developer.

| ID | Given | When | Then |
|---|---|---|---|
| S-05.3.e1 | A research report holding a question for the developer | The Facilitator reads it | The question reaches the developer, if at all, as the Facilitator's own, one at a time |
| S-05.3.e2 | A finding the Facilitator judges off the topic | Phase 4 ends | It was never brought in, and nothing records it |

Rule: a resume does not re-argue what was ruled out.

| ID | Given | When | Then |
|---|---|---|---|
| S-05.4.e1 | A saved **Ruled out** entry and a Skeptic finding that argues for that option | Phase 3 opens on the resume | The finding is named as touching a ruled-out option, and is not argued unless the developer reopens it |
| S-05.4.e2 | A saved README with **Ruled out** "None." | Phase 3 opens on the resume | Findings are brought in as for a new brainstorm |

### S-06 Research during the conversation

Rule: new ground gets its own research step.

| ID | Given | When | Then |
|---|---|---|---|
| S-06.1.e1 | A Phase 4 reply that turns to an area the Scout's first report did not cover | The Facilitator asks for research on it | The roles it needs go in one step, and the next reply draws on their findings |
| S-06.1.e2 | A Phase 4 reply that stays on ground the research covered | The reply is made | No research is dispatched |

Rule: findings during the conversation follow the same path as those before it.

| ID | Given | When | Then |
|---|---|---|---|
| S-06.2.e1 | Reports from a Phase 4 research step | They arrive | The Facilitator brings them in with its next reply; no role speaks to the developer |
| S-06.2.e2 | A Phase 4 research step whose role is incomplete twice | The retry ends | The conversation goes on, and the developer is told which role gave no complete report |

### S-07 What brainstorm writes and returns is unchanged

Rule: research adds no file.

| ID | Given | When | Then |
|---|---|---|---|
| S-07.1.e1 | A kept new brainstorm | The run ends | `docs/plans/{slug}/` holds `README.md` only, untracked |
| S-07.1.e2 | A discarded brainstorm after research ran | The run ends | No folder is created and no file is written in the checkout |

Rule: the result is the same JSON as today.

| ID | Given | When | Then |
|---|---|---|---|
| S-07.2.e1 | A kept brainstorm | Phase 8 | `BRAINSTORM COMPLETE` with `pack`, `pack_status` and `route`, and no other key |
| S-07.2.e2 | A not routed conclusion | Phase 8 | `BRAINSTORM NOT ROUTED` with `route: null`, as today |

Rule: the new cards change no other skill's dispatch.

| ID | Given | When | Then |
|---|---|---|---|
| S-07.3.e1 | `roles/` with the Historian and Skeptic cards added | `cold-read`'s panel pass step 1 | Four dispatches: the Fact-checker, the Editor, the Test engineer and the Trust reviewer |
| S-07.3.e2 | The same folder | The panel pass lists it | No `Card {file} states no kind; not dispatched.` line names the Historian, the Skeptic or the Scout |
| S-07.4.e1 | The same folder | `spec` Phase 3 dispatches its drafter | Only the Analyst is dispatched |
| S-07.4.e2 | The same folder | The slice gate runs | Only the Test engineer and the Editor are dispatched |

### S-08 No subagent tool

Rule: without a subagent tool, the Facilitator does the research by the cards and says so.

| ID | Given | When | Then |
|---|---|---|---|
| S-08.1.e1 | No subagent tool | Phase 2 | The Facilitator works through the Scout, Historian and Skeptic cards in turn, and the developer is told the research was not independent |
| S-08.1.e2 | A subagent tool with no model choice | Phase 2 | The roles are dispatched on the default model, recorded by name or as `default model`, and no "not independent" line is given (`context.md` §3, **Model resolution**) |

Rule: fallback findings reach the conversation the same way.

| ID | Given | When | Then |
|---|---|---|---|
| S-08.2.e1 | No subagent tool and three cards worked through | Phase 3 opens | The opening draws on them and asks one question |
| S-08.2.e2 | No subagent tool, and the Facilitator's own work by a card is incomplete | Phase 3 opens | The opening goes ahead without that card, and says which card was not worked through |

## Failure modes

| Failure | Trigger | Expected behaviour | What the user sees | Criterion |
|---|---|---|---|---|
| A research role writes in its tree | A file changes between the two guard runs | The research is void and none of its findings is brought in | The changed files named, before the conversation goes on | S-04.1 |
| A research role gives no complete report twice | Missing sections, or no report | The conversation goes on without it | A line naming the missing role | S-04.4 |
| No past pack exists or touches the topic | An empty or unrelated `docs/plans/` | The Historian reports none | No history finding in the opening | S-02.2 |
| The Skeptic argues against an option the developer keeps | A "should not be built" finding | It stays a challenge; nothing is ruled out without the developer | The challenge in the conversation | S-03.3 |
| No subagent tool | The harness has none | The Facilitator works through each card | A "not independent" line (A2) | S-08.1 |
| The issue host fails | Bad auth, no network, or no provider reference | No issues are read; the run goes on (ADR-006) | `Issues: issue host unavailable; going on without open issues.` | S-04.1 |
| The research tree cannot be built | No git, or `mktemp` or `git worktree add` fails | No research; the conversation opens without it (ADR-006) | One line naming the failure | S-04.1 |
| A new card trips the panel's no-kind line | A research card's Kind is neither `review` nor `draft` | The panel dispatches only its review cards and prints nothing about research cards | Nothing about research cards in the panel's output | S-07.3 |
| Research on a read-only resume tries to write | A resume at `published`, `executing` or `done` | Nothing is written | `Read-only run: …` at Phase 6, as today | S-04.2 |

## Checkpoint answers

Given by the developer at the acceptance checkpoint on 2026-11-24.

- **A1 (DS1, DN1).** Research cards take a third Kind, `research`, with its own prompt frame in
  `skills/planning/references/roles/dispatch.md`; `skills/cold-read/references/panel.md` skips a
  `research` card silently, so S-07.3 holds.
- **A2 (DN2, PT4).** The fallback line is `Research run by the Facilitator: not independent.`, and a
  role incomplete twice is `Research: {role} gave no complete report; not researched by {role}.`
  (S-04.4, S-06.2, S-08.1).
- **A3 (PT1, DS3, DN5, PT7).** Research roles read a detached tree of `{base}`. A resumed pack is
  copied in as `dispatch.md` **Tree and guard** does and is not read as a past pack (S-02.3); a new
  topic copies nothing. The Historian reads committed packs only; dry-run fixture packs are copied
  into the tree the same way. Amended at the cold read (ADR-008): fixture packs are copied in by
  hand, in dry runs only.
- **A4 (PT2).** The Facilitator reads open issues and recent commits through the session provider;
  research roles stay offline. Amended at the cold read (ADR-007): recent commits come from the
  checkout's `git log`. When the issue host fails, one line says so and the run goes on.
- **A5 (PT3).** A guard void voids all three reports of that step: the changed files are named, the
  tree is removed, and the conversation opens without research. No new result status (S-07.2).
- **A6 (PT5).** No timeout: a role is missing only when the harness returns no report. An over-limit
  report counts as incomplete (S-04.4). A Phase 4 reply that started research waits for its reports.
- **A7 (PT8).** The no-subagent and no-model-choice rows are shown by an executor's desk walk of the
  fallback, recorded in the progress file; fixtures are removed by hand before commit, as before.
- **A8 (DS2).** The Scout's research use is a separate `research` card, since a card has one Kind;
  `scout.md` is unchanged (S-01.2).
- **A9 (DS5).** The Historian runs on `sonnet`, the Skeptic on `opus`.
- **A10 (DN3).** Phase 2 shows one summary line for the research step, and no line per role.
- **A11 (DN4).** The Facilitator decides when Phase 4 has reached new ground, with no cap, and says
  so when it starts research.
- **A12 (DN6).** Research runs on a read-only resume too, as S-04.2 says.
- **A13 (DL1, slice checkpoint, 2026-11-24).** The Story map step is named `Keep or discard and return`,
  without a comma, so the `slice` Map check reads it as one step.

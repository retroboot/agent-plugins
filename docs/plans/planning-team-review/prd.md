# PRD — Review panel and parallel cold read

## Problem

`cold-read` is the only review a pack gets from anyone but its author, and it asks one weak reader
to find every kind of gap at once. In the four hyalOS kernel packs this took 35 rounds (verifier 15,
notary 11, core 5, record 4) and hours of wall-clock time. The records hold 95 distinct blockers.
Tagged by the reviewer whose checklist should have caught each one (hyalos `origin/main`,
`docs/plans/hyalos-kernel-*/cold-read.md`, tagged 2026-11-24):

| Role | Blockers | Typical miss |
|---|---|---|
| Editor | 34 | a rule stated differently in two places; a fix applied once and not where the rule was restated |
| Fact-checker | 20 | a fixture's version or count wrong; a key treated as fixed when it is generated each run; a stale `path:line` |
| Test engineer | 17 | a byte-for-byte compare of signatures; a feature never enabled in Verify; a test that skips and still passes |
| Trust reviewer | 16 | where a key comes from, who runs the operator step, what each bad input returns |
| Cold reader only | 8 | genuinely unclear what to build |

Four causes:

1. **One reader does every job.** Only 8 of 95 blockers needed a cold reader. The rest are checks a
   narrower, stronger reviewer finishes in one pass.
2. **Slices are discovered over several rounds.** Each round covers about a third of the slices
   (`skills/cold-read/SKILL.md:145`), so no pack passes in under 3 rounds.
3. **Fixes create blockers.** 20 blockers were caused by an earlier fix and 10 more probably were,
   because the author re-checks its own edits in the context that wrote them.
4. **Decisions arrive one per round.** Trust questions fell into four families in every pack (who
   signs, where each key comes from, which clock, what each bad input returns) and were asked
   across up to seven rounds.

The record also misreports itself. It writes `Pass after {n} rounds` for this run only
(`skills/cold-read/SKILL.md:350`), so the verifier record says `Rounds: 15` beside
`Pass after 3 rounds`.

## Users and jobs

- **The developer** runs `planning` or `cold-read` and answers the decisions only they can make.
- **The Facilitator** is the main session running `cold-read`. It dispatches subagents, triages what
  they report, and fixes the pack.
- **The executor** builds a slice later from the pack alone, possibly on a small model.

**Jobs.**

- Developer: "When a pack goes to its cold read, I want it to pass in one or two rounds, and to get
  my decisions as one list, so I can publish without spending hours answering one question at a
  time."
- Facilitator: "When I review a pack I wrote, I want specialists who did not write it to check each
  kind of gap against a checklist, so I do not have to remember every check or mark my own work."
- Executor: "When I pick up a slice, I want every fact, command and rule in it to be true and stated
  the same everywhere, so I can build it without guessing."

## Goals

- G1. Gaps that a checklist can find are found before any cold reader sees the pack.
- G2. Every slice is read by a cold reader in round 1.
- G3. A fix is checked by a reviewer other than the author before the next reader sees it.
- G4. The developer gets the open decisions of each pass as one batch.
- G5. Each role is defined once, so the later child packs reuse it rather than restating it.
- G6. Every blocker a cold reader still finds improves the checklist that missed it.

## Non-goals

- Gates inside `spec` and `slice`, and running assumption probes before design (child pack 2,
  `planning-team-spec`).
- Research roles for `brainstorm` (child pack 3).
- Scaling the team by route across the whole flow, or changing the `planning` wrapper (child pack 4).
- Relaxing the pass rule: only a new cold reader can show the fixes worked.
- Changing the reader prompt or the reader model. The cold read stays cold, and stays on the
  smallest model.
- Applying checklist proposals automatically. They are recorded for the developer to make through a
  PR to this repository.

## Success measures

- M1. The next M or L pack planned with this change passes its cold read in 2 rounds or fewer.
- M2. In that pack's record, no more than a quarter of the blockers found by cold readers trace back
  to a panel role.
- M3. In that pack's run, the developer receives decisions in no more than one batch per pass.
- M4. `cold-read.md`'s header Rounds and its closing Result never disagree.

## Non-functional requirements

| Quality | Target |
|---|---|
| Performance | The panel's roles are dispatched together in one step; one panel pass takes no longer than its slowest role |
| Reliability | A role that returns an incomplete report is dispatched once more; a second failure is recorded, never silently skipped |
| Security | Every role and reader reads a detached tree of `{base}` under the existing checksum guard; a role that changes the pack or its tree voids the pass |
| Privacy | none — no personal data is read or written |
| Accessibility | none — no user interface |
| Observability | `cold-read.md` records, per pass, each role's model and its finding counts, and per round, each reader's slices |
| Compatibility / portability | Works with no model override (default model) and with no subagent tool (the Facilitator works through each role card in turn; cold readers still require a subagent) |
| Maintainability | Each role is defined in exactly one file; `skills/cold-read/SKILL.md` stays under 400 lines |

## Assumptions

| Assumption | How to validate | If false |
|---|---|---|
| Sonnet subagents with a checklist find most Fact, Test and Editor gaps in one pass | Dry run the panel on a fixture pack seeded with 10 of the recorded hyalos blockers; count the ones found | Role checklists grow, or those roles move to Opus |
| The Agent tool accepts `model: sonnet` and `model: opus` with `subagent_type: Explore` | Dispatch one of each with a one-line prompt | The panel uses the default model, as the reader fallback does (`skills/cold-read/SKILL.md:154`) |
| Several Agent calls sent in one message run at the same time | Dispatch two readers in one message and compare their start times | The panel runs in turn; the slower wall-clock is recorded |
| Roles can share one reader tree without interfering | In the dry run, run Fact-checker and Test engineer together in one tree and compare the guard output | Each role gets its own tree |
| A Haiku reader given 3 slices or fewer reports as well as one given a third of a pack | Compare the citation counts and blockers per slice in the dry run with the hyalos records | Groups grow, or round 1 uses fewer, larger groups |

## Story map

| Prepare the review | Panel review | Fix and re-check | Cold read | Record and learn |
|---|---|---|---|---|
| S-01 | S-02 | S-03, S-04 | S-05 | S-06 |

## Stories and acceptance criteria

### S-01 Role cards

As the Facilitator, I want each role defined once in a role card, so that every skill dispatches
the same role the same way.

- **S-01.1** Given the planner, when a role is needed, then its card is one file holding the job,
  the inputs, the model, the checklist, the output table and the blocking test, and no skill restates
  the checklist.
- **S-01.2** Given a role card, when the Facilitator dispatches it, then the prompt is built from the
  card plus the tree and pack paths and the input files the card's Inputs section lists (Editor
  `{diff}`, Trust reviewer `{seed}`), and nothing from the conversation. Amended by the developer
  in cold-read round 2, 2026-11-24.
- **S-01.3** Given an environment with no model override, when a role is dispatched, then it runs on
  the default model and the record names that model.
- **S-01.4** Given an environment with no subagent tool, when the panel runs, then the Facilitator
  works through each role card in turn, and the record says the panel was not independent.

### S-02 Review panel before the readers

As the developer, I want specialists to check the pack before any cold reader sees it, so that
readers only find what needs a cold reader.

- **S-02.1** Given a pack in any mode, when `cold-read` starts a run, then after the Author Checks
  and before the first reader, the Fact-checker, Test engineer, Editor and Trust reviewer are
  dispatched together, each on its own role card.
- **S-02.2** Given the panel, when a role runs, then it reads a detached tree of `{base}` with the
  pack copied in, under the same checksum guard as a reader, and runs only commands whose writes, if
  any, are git-ignored build output in that tree.
- **S-02.3** Given the panel's reports, when the Facilitator triages them, then each finding is
  classed with the same blocking test the cold read uses, and recorded in the round with Id
  `P{role letter}{n}`.
- **S-02.4** Given a blocking panel finding the author can fix, when the readers are dispatched, then
  the pack already holds the fix; a finding held for the developer counts as Blocking for the round.
- **S-02.5** Given a pack with no outside party or input, when the Trust reviewer runs, then it
  returns an empty table and the record says so.

### S-03 Fixes re-checked by the roles they touch

As the developer, I want each fix checked by someone other than its author, so that one round's fix
does not become the next round's blocker.

- **S-03.1** Given fixes made after a panel pass or a reader round, when the next reader would be
  dispatched, then the Editor first checks the fix diff for any restatement left unchanged.
- **S-03.2** Given a fix that answers a finding from a role, when the re-check runs, then that role
  is dispatched again on the fixed pack, and the other roles are not.
- **S-03.3** Given a run, when the panel has re-checked twice and still reports blocking findings,
  then the readers are dispatched anyway, and each remaining finding is recorded as held.

### S-04 Decisions in one batch

As the developer, I want every decision only I can make in a pass to arrive together, so that I am
not interrupted once per round.

- **S-04.1** Given a panel pass, when its triage finds developer-only items, including the Trust
  reviewer's questionnaire, then they are asked in one message before any reader is dispatched.
- **S-04.2** Given a reader round, when its classification finds developer-only items, then they
  are asked in one message, after the Trust reviewer has checked the pack for others of the same
  kind.
- **S-04.3** Given a batch, when the developer answers part of it, then the answered items are
  resolved and the rest stay blocking, as an unanswered developer-only question does today.

### S-05 Parallel round-1 cold read

As the developer, I want every slice read in round 1, so that no slice waits two rounds to be read.

- **S-05.1** Given a pack with slices, when round 1 is dispatched, then the slices are split into
  groups of at most 3, in plan order, and one new cold reader per group is dispatched in the same
  step, each with the unchanged prompt and its group's slices.
- **S-05.2** Given a later round, when readers are dispatched, then only the slices whose files the
  last fixes touched are grouped, at most 3 per reader.
- **S-05.3** Given several reports in one round, when they are merged, then each item keeps its
  reader's letter in its Id, and each report must meet the completeness check on its own.
- **S-05.4** Given a pack with no slices, when a round is dispatched, then exactly one reader reads
  the pack as a whole, as today.

### S-06 Trace-back and an honest record

As the developer, I want each cold-read miss to improve the checklist that missed it, and a record
that agrees with itself, so that the process gets better with each pack.

- **S-06.1** Given a blocker found by a cold reader, when the round is written, then the item names
  the role whose checklist should have caught it, or `reader` when none should have.
- **S-06.2** Given a blocker traced to a role, when the round is written, then its Resolution
  proposes one checklist line for that role card, and the closing Result lists every proposal of
  the run.
- **S-06.3** Given a pass, when the Result is written, then it reads
  `Pass after {total} round(s) ({n} in this run).`, where `{total}` equals the header Rounds.
- **S-06.4** Given a run that does not pass, when the Result is written, then the blocked line also
  states the total rounds and this run's rounds.

## Rules and examples

### S-01 Role cards

Rule: a role's prompt comes from its card and the tree and pack paths only.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.2.e1 | the Editor card and a pack at `docs/plans/x` | the Editor is dispatched | the prompt holds the card's job, checklist and output table, `{tree}` and `{path}`, and nothing else |
| S-01.2.e2 | the Facilitator knows from the conversation that a rule was just changed | the Editor is dispatched | the prompt does not mention the change; a fix diff reaches the Editor only through S-03.1 |

Rule: a missing capability changes where a role runs, never whether it runs.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.3.e1 | an Agent tool with no model parameter | the Fact-checker is dispatched | it runs on the default model, recorded by name or as `default model` |
| S-01.4.e1 | no subagent tool | the panel runs | the Facilitator works through each card in turn, and the round's summary says `Panel run by the Facilitator: not independent.` |
| S-01.4.e2 | no subagent tool | a reader would be dispatched | the run stops as today (`skills/cold-read/SKILL.md:155`); the panel's fixes stay in the pack |

### S-02 Review panel before the readers

Rule: the panel reviews before any reader, and its fixed findings do not block the round.

| ID | Given | When | Then |
|---|---|---|---|
| S-02.4.e1 | the Fact-checker reports `live3.json` as version 1, not 3 | the Facilitator fixes the pack before the readers | the finding is recorded as `PF1`, fixed, and does not block the round |
| S-02.4.e2 | the Trust reviewer asks where the log key comes from, and the developer defers | the round is classed | `PT1` is held and counts as Blocking, so the round cannot pass |
| S-02.2.e1 | the Test engineer runs `cargo check` in its tree | the guard runs after the pass | only git-ignored `target/` changed, so the guard holds |
| S-02.2.e2 | a role edits `plan.md` in its tree | the guard runs after the pass | the pass is void, the changed file is named, and the run stops `COLD READ STOPPED` |
| S-02.5.e1 | a pack for a local Markdown change | the Trust reviewer runs | it returns an empty table; the summary says `Trust: no outside inputs.` |

### S-03 Fixes re-checked by the roles they touch

Rule: only the roles a fix touches re-check, and the Editor checks every fix diff.

| ID | Given | When | Then |
|---|---|---|---|
| S-03.2.e1 | fixes for `PF1` and `PE2` | the re-check runs | the Fact-checker and the Editor are dispatched; the Test engineer and Trust reviewer are not |
| S-03.1.e1 | a fix changed the rule "monitor loses `--verify`" in `design.md` only | the Editor checks the diff | it reports each slice still stating the old rule, and they are fixed before the reader |
| S-03.3.e1 | a third panel re-check would be needed | the run continues | the readers are dispatched; each remaining finding is held and blocks the round |

### S-04 Decisions in one batch

Rule: developer-only items of a pass are asked together, once.

| ID | Given | When | Then |
|---|---|---|---|
| S-04.1.e1 | the Trust reviewer lists four open questions and the Editor one ADR conflict | triage ends | the developer gets one message with all five |
| S-04.2.e1 | a reader asks who runs the operator step | the round is classed | the Trust reviewer is dispatched to find siblings, and all of them are asked in one message |
| S-04.3.e1 | the developer answers three of five | the batch is resolved | three are resolved with the answer and date; two stay blocking and the run ends `COLD READ BLOCKED` |

### S-05 Parallel round-1 cold read

Rule: round 1 reads every slice, at most 3 per reader.

| ID | Given | When | Then |
|---|---|---|---|
| S-05.1.e1 | a 7-slice pack | round 1 is dispatched | three readers get Slices 1–3, 4–6 and 7, in one step |
| S-05.1.e2 | a size-S pack | round 1 is dispatched | one reader gets Slice 1 |
| S-05.2.e1 | round 1's fixes touched Slices 2 and 6 | round 2 is dispatched | one reader gets Slices 2 and 6 |
| S-05.3.e1 | reader b's report has 6 citations | the reports are checked | reader b alone is dispatched again for its group; a second short report stops the run as today |

### S-06 Trace-back and an honest record

Rule: the Result reports the total rounds and this run's rounds.

| ID | Given | When | Then |
|---|---|---|---|
| S-06.3.e1 | 12 earlier rounds and a pass in the third of this run | the Result is written | `Pass after 15 round(s) (3 in this run).`, and the header Rounds is 15 |
| S-06.3.e2 | a first run that passes in round 1 | the Result is written | `Pass after 1 round(s) (1 in this run).` |
| S-06.4.e1 | 3 earlier rounds and a run blocked after round 6 | the Result is written | `COLD READ BLOCKED: 2 blocking question(s) left after round 6 (6 rounds, 3 in this run).` |

Rule: a reader's blocker names the role that should have caught it.

| ID | Given | When | Then |
|---|---|---|---|
| S-06.1.e1 | a reader finds a Verify command that compares signatures byte for byte | the round is written | the item's Role is `test`, and its Resolution proposes a checklist line for the Test engineer |
| S-06.1.e2 | a reader cannot tell which field holds the binding | the round is written | the item's Role is `reader`, and no checklist line is proposed |

## Failure modes

| Failure | Trigger | Expected behaviour | What the user sees | Criterion |
|---|---|---|---|---|
| A role's report is incomplete | missing output table, or no evidence column | that role alone is dispatched once more; a second failure is recorded and the run continues without it | `Panel: {role} gave no complete report; not reviewed by {role}.` in the round summary | S-02.3 |
| A role changes the pack or its tree | a write outside git-ignored output | the pass is void and the run stops | `COLD READ STOPPED` naming the changed files | S-02.2 |
| The panel keeps finding blockers | a third re-check would be needed | the readers run; remaining findings are held | held `P…` items listed in the blocked Result | S-03.3 |
| A reader in a parallel round fails | a short report twice for one group | the run stops, as a single reader does today | `COLD READ STOPPED`, naming the group | S-05.3 |
| The developer defers a batch | no answer to some items | answered items resolve; the rest block | `COLD READ BLOCKED` listing each awaiting item | S-04.3 |

# Cold read

| | |
|---|---|
| **Model** | Haiku (Agent tool, model: haiku, Explore) |
| **Input** | Pack path and repository read access only; no conversation context |
| **Rounds** | 2 |
| **Result** | pass |

## Round 1 — 2026-11-24

Reader a (Haiku, Agent tool, model: haiku, Explore) thought through Slice 1, Slice 2, Slice 3 and
spot-checked 22 citations, 20 holding and 2 partly; it found no code. Reader b (Haiku, Agent tool,
model: haiku, Explore) thought through Slice 4, Slice 5 and spot-checked 21 citations, 20 holding and
1 partly; it reported the three `mermaid` fences as code, re-classed below.

Panel: Fact-checker sonnet — 4 findings (0 blocking); Editor sonnet — 12 findings (0 blocking); Test
engineer sonnet — 6 findings (0 blocking); Trust reviewer opus — 12 findings (6 blocking,
developer-only, answered in the panel batch). Re-check 1: Fact-checker, Editor, Test engineer, Trust
reviewer — 29 findings (2 blocking: PV7 fixed, PT13 held). Re-check 2: Fact-checker, Editor, Test
engineer, Trust reviewer — 24 findings (1 blocking: PV8 reported again, open). Sibling scan: Trust
opus — 11 findings (2 blocking, developer-only, merged with bQ2).

### Questions

| Id | Blocking | Role | File | Gap | Resolution |
|---|---|---|---|---|---|
| A1 | n | author | all | Phase 2 author checks: fences, Headings, Trace | Clean before the panel and after every fix pass |
| PF1 | n | fact | `context.md` §2 | F1: marketplace range | Fixed: `:46-61` |
| PF2 | n | fact | `design.md` R1 | F6: past-pack line count | Fixed: 1,187 |
| PF3 | n | fact | `context.md` | F1: dangling citations to the pack README | Fixed |
| PF4 | n | fact | `design.md` §2 | F3: commits read through the provider | Fixed by ADR-007 |
| PE1 | n | editor | `prd.md` | E1: wrong label for the `context.md` §1 heading | Fixed |
| PE2 | n | editor | `design.md`, ADR-002 | E5: commits from `git log` against ADR-002 | Fixed by ADR-007 (= PT6) |
| PE3 | n | editor | `design.md` R3 | E1: R3 "Deviation" wording | Fixed: no threshold |
| PE4 | n | editor | `prd.md`, `context.md` | E1: DN/DS Ids left from drafts | Fixed: A refs |
| PE5 | n | editor | `plan.md` Slice 2 | E1: S-01.1.e2 stop duplicated the Pass rule | Fixed: removed |
| PE6 | n | editor | `design.md` §2 No subagent tool | E1: restated the missing line | Fixed: names the check |
| PE7 | n | editor | README Brief | E6: no scope exception sentence | Fixed (widened again by ADR-009) |
| PE8 | n | editor | `context.md` §2 | E1: Fate cells "open" | Fixed: settled by ADR |
| PE9 | n | editor | `plan.md` Slice 3 | E4: `cold-read.` prefix not carried | Fixed: Suggested path and a grep |
| PE10 | n | editor | `plan.md` Maps | E6: Map steps | No change: a Map names the steps the Outcome changes |
| PE11 | n | editor | `prd.md` Failure modes | E6: host and tree failures missing | Fixed: two rows |
| PE12 | n | editor | `design.md` §5 | E1: guard drawn before the retry | Fixed |
| PV1 | n | test | `plan.md` Verify | V1: missing `.hivrr.json` prints a jq error | Fixed: note says so |
| PV2 | n | test | `plan.md` Slices 3, 4 | V2: live loops missed rows | Fixed |
| PV3 | n | test | `plan.md` Slice 3 | V6: expected status diff unstated | Fixed |
| PV4 | n | test | `plan.md` Slices 1, 5 | V6: STOPPED grep too wide; no `Facilitator` grep | Fixed |
| PV5 | n | test | `design.md` §6 | V2: Pass rule covered four rows only | Fixed: every model-output row |
| PV6 | n | test | Shared contract | V4: `Skill dir` path form | Fixed: physical path |
| PT1 | n | trust | `design.md` §6 | T4: dry-run auth | Fixed: live CLI auth |
| PT2 | n | trust | `design.md` §6 | T4: host stand-in (developer, panel batch) | Fixed: `GH_TOKEN=invalid` |
| PT3 | n | trust | `design.md` §6 | T4: tree stand-in (developer, panel batch) | Fixed: `TMPDIR` (re-worded by PV11) |
| PT4 | n | trust | `design.md` §6 | T4: Base fetch stand-in (developer, panel batch) | Fixed: `GIT_ALLOW_PROTOCOL=none` |
| PT5 | n | trust | `design.md` DR5 | T3: void line wording | Fixed: executor words it |
| PT6 | n | trust | ADR-002 | T1: commit source (developer, panel batch) | Fixed by ADR-007 |
| PT7 | n | trust | `design.md` R3 | T5: timing judge (developer, panel batch) | Fixed: Retro, no threshold |
| PT8 | n | trust | `design.md` §2 | T4: fixture copy (developer, panel batch) | Fixed: hand copy, ADR-008 |
| PT9 | n | trust | `design.md` §7 | T1: prompt-only offline rule | Fixed: R10 accepted |
| PT10 | n | trust | `design.md` §2 | T1: HEAD fallback | Fixed: Base line |
| PT11 | n | trust | `design.md` §2 | T3: report intake | No change: brought in as reported, by role |
| PT12 | n | trust | `design.md` §2 | T3: slow host, list size | Fixed |
| PF5 | n | fact | `context.md` §2 | F1 (re-check 1): marketplace range one line short | Fixed: `46-61` |
| PF6 | n | fact | `design.md` §6 | F4 (re-check 1): stand-ins not settled in the repo | Left for Slice 3's dry runs |
| PE13 | n | editor | `design.md` §1 | E2 (re-check 1): flowchart sent commits to the provider | Fixed |
| PE14 | n | editor | `design.md` R4, `prd.md` S-07.1 | E2 (re-check 1): "anywhere" wording | Fixed: in the checkout |
| PE15 | n | editor | `plan.md` Slice 1 | E2 (re-check 1): Pass rule listed three rows | Fixed; the slice stop wins |
| PE16 | n | editor | `prd.md` A3, ADR-002 | E5 (re-check 1): fixtures "the same way" | Fixed by ADR-008 |
| PE17 | n | editor | `prd.md` Assumptions row 6 | E2 (re-check 1): stale fallback | Fixed |
| PE18 | n | editor | `context.md` §4 | E2 (re-check 1): "prints nothing" | Fixed |
| PE19 | n | editor | `plan.md` Slices 3, 5 | E4 (re-check 1): fallback model owned twice | Fixed: Slice 5 |
| PE20 | n | editor | `plan.md` graph | E4 (re-check 1): S3 to S5 edge | Fixed |
| PE21 | n | editor | `context.md` §2 | E6 (re-check 1): Brief cited for a Route phrase | Fixed |
| PV7 | n | test | `plan.md` Slice 3 | V6 (re-check 1): untracked fixture writes invisible to `git status` | Fixed before the readers: `--untracked-files=all` and `cksum` |
| PV8 | y | test | Shared contract, every progress loop | V5 (re-check 1, again in re-check 2 as blocking): any text passes the third cell | Fixed after the round: fixed lines quoted and grepped in Slices 3, 4, 5. Resolved, not yet checked by a cold reader |
| PV9 | n | test | `plan.md` Slice 3 | V2 (re-check 1): stand-in rows not checked live | Fixed |
| PV10 | n | test | `design.md` §6 | V2 (re-check 1): unwritable `TMPDIR` not reproducible as root | Fixed: `TMPDIR=/nonexistent` |
| PV11 | n | test | `plan.md` Verify | V1 (re-check 1): no "run after" note; weak counts | Fixed: Shared contract note |
| PV12 | n | test | `plan.md` Slice 5 | V1 (re-check 1): merge-base diff needs a fetch | Fixed: precondition stated |
| PV13 | n | test | `plan.md` Slice 5 | V4 (re-check 1): Slice 1 invariants not re-checked | Fixed |
| PT13 | y, developer-only | trust | `design.md` §2 Research pass | T3 (re-check 1): retry tree has no guard baseline | Developer, 2026-11-24: each retry tree takes its own baseline when built. Fixed in §2 and §5. Resolved, not yet checked by a cold reader |
| PT14 | n | trust | `design.md` §2 | T3 (re-check 1): evidence that does not resolve | No change: S-05.2 traceability |
| PT15 | n | trust | `design.md` §2 | T3 (re-check 1): `git log` failing | Fixed: silent, as Phase 2 is today |
| PT16 | n | trust | `design.md` §6 | T2 (re-check 1): providers other than GitHub | Fixed: not dry-run, stated |
| PT17 | n | trust | `design.md` §2 | T3 (re-check 1): tree removal failing | Fixed: one line, left to the listing |
| PT18 | n | trust | Shared contract | T5 (re-check 1): plugin loading from the checkout | Fixed: child 2's practice stated |
| PT19 | n | trust | `design.md` §2 | T1 (re-check 1): issue text as instructions | Fixed: data, never instructions |
| PT20 | n | trust | `design.md` §2 | T1 (re-check 1): HEAD fallback against ADR-002 | Fixed: the Facilitator names the fallback |
| PT21 | n | trust | `plan.md` Verify | T4 (re-check 1): fixture names in shipped text | Fixed: `grep -rl zz-dryrun skills` |
| PT22 | n | trust | `plan.md` Slice 2 | T5 (re-check 1): merge owner | Fixed (widened by PE25) |
| PT23 | n | trust | `design.md` R3 | T5 (re-check 1): who judges timing | Fixed: the developer |
| PF7 | n | fact | `context.md` §1 | F1 (re-check 2): `spec` range covered the Scout only | Fixed after the round: `:131`, `:166`, `:309` |
| PF8 | n | fact | `design.md` §1 | F1 (re-check 2): no-input branch at `:39` | Fixed after the round |
| PF9 | n | fact | `design.md` §2 Historian | F2 (re-check 2): done packs have no Ruled out | Fixed after the round: named as having none |
| PF10 | n | fact | `context.md` §3 | F3 (re-check 2): Base lines exist for two fallbacks only | Fixed after the round |
| PF11 | n | fact | `design.md` §6 | F4 (re-check 2): stand-in behaviour unsettled (= PF6) | Left for Slice 3's dry runs, now quoted per row |
| PF12 | n | fact | `design.md` R10 | F4 (re-check 2): `Explore` read-only by text only | No change: R10 accepts it |
| PE22 | n | editor | DR1, `plan.md` Slice 3 stop | E2 (re-check 2): two-part check left | Fixed after the round |
| PE23 | n | editor | `design.md` §6, `plan.md` Slice 1 | E2 (re-check 2): fixtures cited to ADR-002 | Fixed after the round: ADR-008 |
| PE24 | n | editor | `design.md` §2, `plan.md` Slice 3 | E3 (re-check 2): new Facilitator lines unowned | Fixed after the round: Slice 3's `research.md`; DR5 words the removal line |
| PE25 | n | editor | `plan.md` | E4 (re-check 2): merge order in Slice 2 only | Fixed after the round: Shared contract **Merge order** |
| PV14 | n | test | `plan.md` Slices 1, 2 | V2 (re-check 2): S-07.3 dry run could list an old `roles/` | No change: the Shared contract's skill-dir rule and the cards' file names in the row |
| PV15 | n | test | `plan.md` Slice 5 | V4 (re-check 2): two greps pass on Slice 3's text | Fixed after the round: the quoted `not independent` line |
| PV16 | n | test | `plan.md` Slice 3 | V5 (re-check 2): any stand-in passes any row | Fixed after the round: one setting per row |
| PV17 | n | test | `plan.md` Slice 5 | V1 (re-check 2): stale `origin/main` (= PV12) | No change: precondition stated |
| PV18 | n | test | `plan.md` worktree line, Slice 3 snapshot | V3 (re-check 2): concurrent runs; own rows between snapshots | Fixed after the round: progress rows and fixtures excepted |
| PV19 | n | test | `design.md` §6 Fixtures | V6 (re-check 2): fixture Briefs unspecified | No change: the executor writes a Brief on T1's subject |
| PT24 | n | trust | `design.md` R10 | T1 (re-check 2): offline rule prompt-only (= PT9) | No change |
| PT25 | n | trust | `design.md` §6 | T5 (re-check 2): no `gh` auth in the session | No change: rows show the host-unavailable line |
| PT26 | n | trust | `design.md` §6 | T1 (re-check 2): tracker not GitHub | No change: other providers not dry-run |
| PT27 | n | trust | `plan.md` Verify | T4 (re-check 2): stand-in settings in shipped text | Fixed after the round: grep extended |
| PT28 | n | trust | `prd.md` Failure modes | T3 (re-check 2): no "no network" stand-in | No change: auth failure proves the line |
| PT29 | n | trust | `design.md` DR5 | T3 (re-check 2): removal line unworded (= PE24) | Fixed after the round |
| PT30 | n | trust | `design.md` §2 | T3 (re-check 2): past-pack text as instructions | No change: roles are read-only and report data |
| bQ1 | n | reader | `design.md` §1, §5; `plan.md` graph | Three `mermaid` fences read as code | Re-classed non-blocking: `pack-format.md` §6 and `docs/verification.md:170` allow `mermaid`; reader a (aQ14) read it the same way |
| bQ2 | y, developer-only | editor | README Brief, ADR-001, `prd.md` Non-goals, `design.md` §2 Dispatch | Five `dispatch.md` additions against "a frame and a skip line" (with bX1, bX2, aQ10, aK3, PT31, PT32) | Developer, 2026-11-24: widen to all five. ADR-009 written; ADR-001 Status amended; Brief and Non-goals reworded. Resolved, not yet checked by a cold reader. Checklist line proposed for editor: **E7** When the pack reaches outside its scope, compare the count and names of the out-of-scope edits in the Brief, the prd Non-goals, each ADR and the design's component table |
| PT31 | y, developer-only | trust | as bQ2 | Sibling scan: the seed family | As bQ2 |
| PT32 | y, developer-only | trust | `prd.md` Non-goals | Sibling scan: Non-goals named only the panel line | As bQ2 |
| PT33 | n | trust | `design.md` R6 | Sibling scan: `cold-read.` prefix makes cold-read list brainstorm's trees | No change: R6 accepts it |
| PT34 | n | trust | `design.md` §2 | Sibling scan: hung issue host | No change: waited for, as a role is |
| PT35 | n | trust | `design.md` §6 | Sibling scan: more host stand-ins (= PT28) | No change |
| PT36 | n | trust | `plan.md` Slice 3 | Sibling scan: `TMPDIR` left set | Fixed: exported for that run only, then unset |
| PT37 | n | trust | `design.md` §2 | Sibling scan: an interrupt retries | No change: ADR-003 counts it incomplete |
| PT38 | n | trust | `design.md` DR5 | Sibling scan: removal line (= PE24) | Fixed |
| PT39 | n | trust | `design.md` §2 | Sibling scan: reports as data (= PT30) | No change |
| PT40 | n | trust | ADR-006 | Sibling scan: `session` inputs and its `SESSION:` line | No change: a failed `session` load is the host-unavailable case |
| PT41 | n | trust | `plan.md` Slices 3 to 5 | Sibling scan: merge order (= PE25) | Fixed |
| aQ1 | n | fact | `design.md` §2 Research pass | `tree.md:29` copies `{path}` on every run | Fixed: a new topic skips the copy line. Checklist line proposed for fact: **F8** When the pack reuses an existing command under a condition, open the command and check the condition can be met as written |
| aQ2 | n | reader | `design.md` §2 Research frame | Frame paragraph not written out | Default adopted: the executor writes it in the review frame's style, keeping the Verify strings |
| aQ3 | n | reader | `design.md` §2 Issues and commits | "No provider reference loaded" untestable | Default adopted: load `session` once in Phase 2 unless one is loaded |
| aQ4 | n | reader | `design.md` §2 completeness | "Cut short" unobservable | Default adopted: a missing section is incomplete |
| aQ5 | n | reader | `design.md` §2, §5 | Retry tree's guard | Answered by PT13 |
| aQ6 | n | reader | `plan.md` Slice 1 stop | R2 wording | Default adopted: a second Skeptic run on T1 or T5 with no grounded finding |
| aQ7 | n | reader | `research-scout.md` | Two cards titled Scout | Default adopted: the file name tells them apart |
| aQ8 | n | reader | `design.md` §6 Fixtures | Fixture README contents | Default adopted: minimal README with the sections the properties need |
| aQ9 | n | reader | `design.md` §2 No subagent tool | How a missing tool is detected | Default adopted: the existing section's test |
| aQ10 | y, developer-only | editor | README, prd | Scope exception | As bQ2 |
| aQ11 | n | reader | Shared contract | `Skill dir` form | Default adopted: the Verify commands' form |
| aQ12 | n | reader | `.hivrr.json` | Absent in the tree | Default adopted: scaffold per `docs/verification.md` |
| aQ13 | n | reader | `design.md` §2 Historian | `## Packs read` columns | Fixed: lessons added to each row |
| aQ14 | n | reader | `mermaid` fences | Is a diagram code | No: allowed (see bQ1) |
| aQ15 | n | reader | `design.md` §2 Phase 4 | "New ground" untestable | Default adopted: an area no earlier Sources read covered |
| aQ16 | n | reader | `plan.md` Slice 3 | How timing is taken | Default adopted: first dispatch to last report |
| aQ17 | n | reader | ADR-003 line | Awkward wording | No change: accepted wording |
| bQ3 | n | reader | `design.md` §2 No subagent tool | Fallback retry | Default adopted: one re-work, then the missing line |
| bQ4 | n | reader | `design.md` §2 | Where `not independent` shows | Default adopted: once per step after the summary line |
| bQ5 | n | reader | `plan.md` Slice 5 | Detecting no subagent tool | Default adopted (as aQ9) |
| bQ6 | n | editor | `design.md` §2 Research report | Ids restart per report | Fixed: numbered per role across the run |
| bQ7 | n | reader | `plan.md` Slice 4 Outcome | Developer request path | Fixed: Outcome names it |
| bQ8 | n | reader | `plan.md` Slice 4 | Which roles Phase 4 runs | Default adopted: the subset the Facilitator names |
| bQ9 | n | reader | `design.md` §2 Challenge rule | Challenge at the opening | Default adopted: yes, as a challenge, keeping one question |
| bQ10 | n | reader | ADR-005 | "Covered ground" | Default adopted (as aQ15) |
| bQ11 | n | reader | `design.md` §2 Scout (research) | Output section | Default adopted: the research report |
| bQ12 | n | reader | `design.md` §5 | Reply before the step ends | Default adopted: `Researching …` line first |
| bQ13 | n | reader | `.hivrr.json` | Absent | As aQ12 |

### Contradictions

| Item | Resolution |
|---|---|
| aK1 (reader): `prd.md` S-07.1 against R4 and DR1 | Both now say "in the checkout" (PE14) |
| aK2 (reader): prd Assumptions row 2 against the Historian card | No change: the design adopts the fallback from the start, and the probe still times it |
| aK3 (editor): README Scope against `design.md` §2 Dispatch | As bQ2 |
| aK4 (fact): `design.md` Research pass against `tree.md:29` | As aQ1 |
| aK5 (reader): prd Assumptions row 4 against DR9 | No change: DR9 is the checkpoint answer and wins |
| aK6 (editor): ADR-002 body against ADR-008 | No change: an accepted ADR is not edited; its Status names ADR-008 |
| bC1 (editor): README Scope against Slices 1 and 5 | As bQ2 |
| bC2 (editor): ADR-001 against `design.md` §2 | As bQ2 |
| bC3 (editor): Research report Ids against the ledger | As bQ6 |
| bC4 (reader): completeness retry against No subagent tool | As bQ3 |
| bC5 (reader): Challenge rule in Slice 4 against the Slice 3 opening | No change: between merges the opening states findings; S-03.3 is proven at Slice 4 |
| bC6 (reader): `design.md` §1 against the Slice 4 Outcome | As bQ7 |
| bC7 (reader): prd S-07.1 against R4 and DR1 | As aK1 |
| bC8 (reader): `context.md` §4 fence tags against the reader prompt | As bQ1 |

### Citations checked

| Citation | Holds |
|---|---|
| a `skills/brainstorm/SKILL.md:70-76`, `:82-84`, `:94-101`, `:114-116`, `:28-29`, line count 287 | yes |
| a `skills/planning/references/roles/dispatch.md:9-11`, `:15-24`, `:161-174`, `:186-201`, `:203-211` | yes |
| a `skills/cold-read/references/panel.md:13-16`, `:19-20` | yes |
| a `skills/cold-read/references/tree.md:19-30`, `:41-44` | partly (line 29 copies on every run) |
| a `skills/session/references/github.md:34`; `scout.md:5`, `:9`; the eight cards' letters, Kinds and models | yes |
| a `.claude-plugin/marketplace.json:54`; `docs/plans/planning-team-spec/README.md:107-115`; `docs/plans/planning-team/README.md:140`, `:36-37` | yes |
| a `skills/planning/SKILL.md:175-183`; `docs/verification.md:170`, `:267-277`; `skills/spec/SKILL.md:131`; 802 and 1,187 line counts; `origin/main` past packs | yes |
| a Id prefixes `A`, `D`, `G`, `P`, `X` | partly (A, D, X not in the three files read) |
| b `.claude-plugin/marketplace.json:46-61`; `skills/brainstorm/SKILL.md:72-76`, `:61-64`, `:114-116`, `:94-101`, `:82-84`, `:201-226` | yes |
| b `skills/brainstorm/SKILL.md:47-52` | partly (no-input branch at `:39`) |
| b `dispatch.md:203-215`, `:22-24`, `:9-11`, `:170-174`; `panel.md:13-16`, `:19-20`; `tree.md:19-30`, `:41-44`, `:28-29` | yes |
| b `github.md:34`; `scout.md:1-45`; `spec/SKILL.md:131`; `planning/SKILL.md:49`; parent README `:140`, `:36-37`; `planning-team-spec/README.md:107`; R1 1,187; `CLAUDE.md:207-211` | yes |

## Round 2 — 2026-11-24

Touched: Slice 1, Slice 2, Slice 3, Slice 4, Slice 5. Reader a (Haiku, Agent tool, model: haiku,
Explore) thought through Slice 1, Slice 2, Slice 3 and spot-checked 31 citations, 28 holding and 3
partly; it reported the three `mermaid` fences as code, re-classed below. Reader b (Haiku, Agent
tool, model: haiku, Explore) thought through Slice 4, Slice 5 and spot-checked 30 citations, 28
holding and 2 partly; it reported the same fences, re-classed below.

Editor pass on round 1's diff: Editor sonnet — 8 findings (2 blocking, fixed before the readers).

### Questions

| Id | Blocking | Role | File | Gap | Resolution |
|---|---|---|---|---|---|
| PE26 | n | editor | `design.md` §2 Research pass, DR5, `plan.md` Slices 1, 3 | E2 (Editor pass): which file holds the research pass's Facilitator lines | Fixed before the readers: `dispatch.md` states the rules, `research.md` words the lines; Slice 1 proves 1.4 by a hand dispatch |
| PE27 | n | editor | `design.md` §2 Research report | E2 (Editor pass): a role cannot continue an Id it is never told | Fixed before the readers: the Facilitator renumbers on intake |
| PE28 | n | editor | `design.md` §2 | E2 (Editor pass): a line break split a table row | Fixed |
| PE29 | n | editor | `plan.md` Slices 1, 3 | E2 (Editor pass): fixed-line rule not grepped for S-03.2.e2 and 3.5 | Fixed: `None found.` and `Tree from` quoted |
| PE30 | n | editor | `design.md` §2 Phase 4 research | E2 (Editor pass): developer request missing from the row | Fixed |
| PE31 | n | editor | `prd.md` Assumptions row 2 | E1 (Editor pass): Retro against Brief or Retro scope | No change: the design's wider scope is the approved card |
| PE32 | n | editor | ADR-001, `prd.md` A1, `context.md` §2 | E5 (Editor pass): bodies older than ADR-009 | No change: accepted ADRs are not edited; ADR-001's Status names ADR-009 |
| PE33 | n | editor | README Brief | E6 (Editor pass): second Retro lesson has no criterion | No change: carried by the Maintainability row and Slice 3's stop |
| aQ1 | n | reader | `design.md` §1, §5; `plan.md` graph | Three `mermaid` fences read as code (aQ2, aQ3, aK1 the same) | Re-classed non-blocking: `context.md` §4 and `docs/verification.md:170` allow `mermaid`, as round 1 bQ1 |
| aQ4 | n | reader | `design.md` DR5 | Wording of the void, tree and removal lines | Default adopted: the executor words them in `research.md`, as DR5 says |
| aQ5 | n | reader | `design.md` §2 Skeptic card | Columns of the two tables | Fixed: `Id \| finding \| evidence` |
| aQ6 | n | reader | `design.md` §2 Historian | `## Packs read` columns | No change: round 1 aQ13 fixed it |
| aQ7 | n | reader | `design.md` §2 Research frame | Read-only paragraph wording | Default adopted (as round 1 aQ2) |
| aQ8 | n | reader | `design.md` §2 Issues and commits | `git log` command | Fixed: `git log --oneline -20` |
| aQ9 | n | reader | `design.md` §2 Opening, Challenge rule | Challenge before Slice 4 | Default adopted (as round 1 bQ9) |
| aQ10 | n | reader | `plan.md` Slice 1 dry runs | Where a past-pack fixture lands | Default adopted: `{tree}/docs/plans/zz-dryrun-routed/`, recorded |
| aQ11 | n | reader | `design.md` §6 Fixtures | Fixture bodies | Default adopted: from the README template, as round 1 aQ8 |
| aQ12 | n | reader | DR6 | Detecting no provider reference | Default adopted (as round 1 aQ3) |
| aQ13 | n | reader | `plan.md` Slice 3 | Timing method | Default adopted (as round 1 aQ16) |
| aQ14 | n | reader | `plan.md` Slice 1 panel dry run | Procedure | Default adopted: list `roles/` and record each Kind and the dispatch list |
| aQ15 | n | reader | `plan.md` Slice 1 S-07.4 | Runtime list proven structurally | No change: the design's §6 proof |
| bQ1 | n | reader | as aQ1 | `mermaid` fences | As aQ1 |
| bQ2 | n | reader | `design.md` §2 Phase 4 | "New ground" | Default adopted (as round 1 aQ15) |
| bQ3 | n | reader | `design.md` §2 Research frame | `{topic}` for Phase 4 | Default adopted: the Facilitator's statement of the new ground |
| bQ4 | n | reader | `design.md` §2 Phase 4 | Which roles | Default adopted (as round 1 bQ8) |
| bQ5 | n | reader | `design.md` §2 Research step | `{base}` reuse in Phase 4 | Default adopted: resolved once per run, as the row says |
| bQ6 | n | reader | `design.md` §2 No subagent tool | Fallback retry (round 1 bQ3 chose the other default) | Fixed: an incomplete card is worked once more before its missing line |
| bQ7 | n | reader | `design.md` §2 No subagent tool | Where `not independent` shows | Fixed: once per step, after the summary line |
| bQ8 | n | reader | `design.md` §2 Model resolution | Live or desk walk for S-08.1.e2 | Fixed: desk walk, as §6 says |
| bQ9 | n | reader | Shared contract | `Skill dir` form | Default adopted (as round 1 aQ11) |
| bQ10 | n | reader | `plan.md` Slices 3 to 5 | `research.md` section order | Fixed: order stated |

### Contradictions

| Item | Resolution |
|---|---|
| aK1 (reader): `context.md` §4 against the reader prompt | As aQ1 |
| aK2 (reader): Research report against the completeness check on the Skeptic's tables | Fixed: a report with `## Findings` and both tables is complete |
| aK3 (reader): Slice 3 and DR5 on the lines' wording | No change: DR5 gives the wording to the executor |
| aK4 (reader): ADR-001 body against ADR-009 | As PE32 |
| aK5 (reader): ADR-002 body against ADR-008 | No change: ADR-002's Status names ADR-008 |
| aK6 (reader): prd S-07.4 runtime lists against the structural proof | As aQ15 |
| aK7 (reader): Historian stop against the Pass rule | No change: the plan says the stop wins |
| bC1 (reader): Pass rule against P9 | No change: `design.md` §6 now says a slice's own Stop condition wins |
| bC2 (reader): Model resolution against §6 on S-08.1.e2 | As bQ8 |
| bC3 (reader): completeness retry against No subagent tool | As bQ6 |
| bC4 (reader): Research step "no file" against R4 | No change: DR1 settles it as the checkout |

### Citations checked

| Citation | Holds |
|---|---|
| a `skills/brainstorm/SKILL.md:72-76`, `:114-116`, `:26-29`, `:39`, `:51-52`, line count 287 | yes |
| a `skills/brainstorm/SKILL.md:228-239` | partly (under Phase 7) |
| a `dispatch.md:9-11`, `:15-24`, `:26-58`, `:161-174`, `:186-192`, `:194-201` | yes |
| a `dispatch.md:72-126`, `:203-217` | partly (ranges not read to their ends) |
| a `panel.md:13-16`, `:19-20`; `tree.md:19-30`, `:41-44`, `:20-21`; `scout.md:1-45`; `spec/SKILL.md:131`; `gates.md:8-14`; `github.md:34` | yes |
| a `planning-team-spec/README.md:107`; `planning-team/README.md:36-37`; `docs/verification.md:170`; `.gitignore:10`; `54a2980`; card letters and models; 1,187 lines; `planning/SKILL.md:49`; three `done` packs | yes |
| b `skills/brainstorm/SKILL.md` 287 lines, `:114-116`, `:120-130`, `:76`, `:61-64`, `:20-22`, `:28-29`, `:39`, `:51-52` | yes |
| b `dispatch.md:203-215`, `:22-24`, `:161-174`, `:3-4`, `:9-11`, `:26-33`; card letters and Kinds | yes |
| b `panel.md:13-16`, `:19-20`; `tree.md:19-30`, `:41-44`; `planning/SKILL.md:175-183`, `:49`; `marketplace.json:54`; `docs/verification.md:78`, `:158`, `:170`, `:277` | yes |
| b `planning-team/README.md:140`, `:36-37`; `planning-team-spec/README.md:107`; `spec/SKILL.md:131`, `:166`, `:309`; `slice/SKILL.md:112`; `gates.md:8-14`; `github.md:34` | yes |
| b `scout.md:11-27`; `CLAUDE.md:207-211` with `RELEASE-NOTES.md:15` | partly |

## Result

Pass after 2 round(s) (2 in this run).

### Checklist proposals

- Round 1 bQ2 → editor.md: **E7** When the pack reaches outside its scope, compare the count and names of the out-of-scope edits in the Brief, the prd Non-goals, each ADR and the design's component table
- Round 1 aQ1 → fact-checker.md: **F8** When the pack reuses an existing command under a condition, open the command and check the condition can be met as written

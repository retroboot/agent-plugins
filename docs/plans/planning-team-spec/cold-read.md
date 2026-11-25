# Cold read

| | |
|---|---|
| **Model** | Haiku (Agent tool, model: haiku, Explore), the smallest model the tool offers |
| **Input** | Pack path and repository read access only; no conversation context |
| **Rounds** | 3 |
| **Result** | Pass after 3 rounds |

## Round 1 — 2026-11-24

Two readers, both Haiku (Agent tool, model: haiku, Explore), dispatched in one step, each in its own
tree at `origin/main` (`f8e598f`) with the pack copied in; both guards held. Reader `a` thought
through Slices 1, 2 and 3 and checked 27 citations, 26 holding and 1 partly. Reader `b` thought
through Slices 4 and 5 and checked 25 citations, 24 holding and 1 partly. Reader `a` found no code.
Reader `b` reported the two `mermaid` fences as code; both are diagrams, which `pack-format.md` §6
allows, and the Phase 2 Fences check prints nothing for them, so both were re-classed (bQ4, bQ5).

Panel: Fact-checker Sonnet (Agent tool, model: sonnet, Explore), Editor Sonnet (Agent tool, model:
sonnet, Explore), Test engineer Sonnet (Agent tool, model: sonnet, Explore) and Trust reviewer Opus
(Agent tool, model: opus, Explore), in one step. Every blocking finding of the panel pass was fixed
before the readers, its developer-only item answered in the panel batch. Re-check 1: Editor, Fact-checker, Test engineer, Trust
reviewer; its blocking findings (PE1, PV1, PV2, PT3, PT5) fixed, PT5 answered by the developer
("the executor plays the developer"). Re-check 2: Fact-checker 0 findings; Editor 12 (0 blocking);
Test engineer 7 (4 blocking); Trust reviewer 7 (1 blocking, developer-only); nothing fixed after it,
so PV1, PV2, PV20, PV21 and PT10 were held. Sibling scan: Trust Opus (Agent tool, model: opus,
Explore) — 8 findings (7 blocking), seeded with aQ2. Re-check 2's new findings are numbered from
`PE20`, `PV20` and `PT11`; the developer batch used `PT10` to `PT22`.

### Questions

| Id | Blocking | Role | File | Gap | Resolution |
|---|---|---|---|---|---|
| PV1 | y (held) | test | `plan.md` every slice, the progress-file Id loop | V1: the loops were inline code spans that wrapped, so bash rejected four of them; reported again after re-check 1's fix | Each loop moved into its slice's Verify fence, on one line, with its expected output |
| PV2 | y (held) | test | `plan.md` Slice 1 Verify | V6: nothing checked that `spec` runs the `{base}` step; reported again | Slice 1 Verify gains the `{base}` wiring check on `spec` Phase 2, and 1.4 names Phase 2 |
| PV20 | y (held) | test | `plan.md` Slices 1 and 2 Id loops | V6: S-01.2's contract side and 2.3 had no Id in any loop | `S-01.2` added to Slice 1's loop and `2.3` to Slice 2's; Slice 4's loop gains `4.2` |
| PV21 | y (held) | test | `plan.md` Id loops, `design.md` §6 Seeding | V2, V5: a fallback dry run could still pass the loop | `design.md` §6 **Live runs**: live rows quote their dispatch line; every slice's Verify checks the live rows, `blocked` and `Skill dir` |
| PT10 | y, developer-only (held) | trust | `design.md` §6 Seeding | T4, T5: how a dry run runs this checkout's skills, and what happens if not | Developer, 2026-11-24: "Checkout or blocked". **Live runs**: the plugin is loaded from this checkout, `Skill dir` is recorded, and one outside the checkout is a stop, `blocked`; the developer re-runs it |
| aQ1 | y | editor | `design.md` §2 Drafting frame `{sha}`; `prd.md` S-02.1.e1 | Which commit `context.md`'s opening line names: `{base}` in the design, short `HEAD` in the prd and `skills/spec/SKILL.md:128`. Also bQ1, PT15 | `{base}` chosen, since the gate checks citations there: S-02.1.e1 now names `{sha}`; the Draft report row says so; Slice 1 step 5 changes `skills/spec/SKILL.md:128`. Checklist line proposed for editor: **E7** For every rule restated across files (a value, its source, the moment it is taken, a threshold, before or after a write), compare each restatement with the others word for word, the skill being changed included. |
| aQ2 | y, developer-only | trust | `decisions/ADR-007`, `design.md` §2 Held | Held items are lost if a session ends between a gate and its checkpoint, though files are the only state. Also PT18 | Developer, 2026-11-24: a pending entry, in a named file rather than the README; then `handoff.md`. ADR-008 (accepted) amends ADR-007; `design.md` §2 **Handoff**; prd S-03.5; Slice 2 builds it. Checklist line proposed for trust: **T7** For every piece of state held between two steps, say what a session that ends between them leaves on disk, and how the next run recovers it. |
| PT17 | y, developer-only | trust | `design.md` §1 Stages; ADR-003 | A later run at `routed` meeting a file already drafted | Developer, 2026-11-24, with aQ2: a Gate pending entry makes the next run re-run only that file's gate on the file as it stands (S-03.5.e1) |
| PT19 | y, developer-only | trust | `design.md` §2 Drafting line, Display | Trust and fallback notices lost when a session ends before the checkpoint | Developer, 2026-11-24, with aQ2: the entry holds every trust and fallback line (S-03.5) |
| PT20 | y, developer-only | trust | `design.md` §2 Fix, One re-check | A fix on disk with its re-check never run | Developer, 2026-11-24, with aQ2: the entry records `Fix not re-checked`, and the next run re-runs the gate |
| PT21 | y, developer-only | trust | `design.md` §2 Ids | Gate Ids restart per run and collide with README Deferred lines; a later run may ask a deferred item again | Developer, 2026-11-24: "Continue + skip". Ids row and prd S-03.6 with S-03.6.e1; S-03.4 now reads "never asked again" |
| PT22 | y, developer-only | trust | `design.md` §2 Answer; prd S-06.3.e3 | Where a spec-change answer at the slice checkpoint is kept | Developer, 2026-11-24: a named file, not the README. A **Spec pending** entry in `handoff.md` (ADR-008); prd S-06.4 with S-06.4.e1; Slice 5 |
| bQ2 | y | editor | `design.md` §2 Drafting roles; `plan.md` Slice 5 | Whether the Planner returns the whole `plan.md` or the slice list only. Also aQ11 | Drafting roles row: the whole `plan.md`, graph and Traceability included, and Phase 2 **Count** counts its `## Slice N` headings before writing; Slice 5 step 2 says so. Checklist line proposed for editor: **E8** For every role a slice adds, check that one contract row states every input it reads and the exact span of what it returns. |
| bQ3 | y | editor | `design.md` §1 and §2 Draft completeness check; `plan.md` Slice 4 | Modifier sections are required in `design.md` but the Architect may not draft them, so its draft would always fail the check | The completeness check skips the sections §1 keeps with the Facilitator, who adds them after writing the draft; Slice 4's stop says so. Checklist line proposed for editor: **E9** For every section a check requires, name who writes it; a check that requires what its writer may not write fails. |
| PT11 | n | trust | `design.md` §2 `{base}` step | T1, T3: whether dry runs may fetch `origin`, and a fetch that hangs. Also sibling scan PT8 | Seeding: dry runs may fetch `origin`, and a failed fetch takes the fallback line. A hang has no time limit, as for dispatches |
| PT12 | n | trust | `design.md` §2 Held | T3: a dispatch that never returns | A dispatch the developer interrupts counts as an incomplete report |
| PT13 | n | trust | `design.md` §2 Drafting line | T3: a rejected model outside a dry run | Drafting line row: the default model, with the line `Drafted by the {role}, default model (Agent tool, Explore).` |
| PT14 | n | trust | `design.md` §7 R5 | T1, T5: no owner for the harness permissions | The pack stands: R5 already says the read-only tool set and the harness permissions are what hold |
| PT15 | n | trust | `prd.md` S-02.1.e1 | T1: `{sha}` stated two ways | As aQ1 |
| PT16 | n | trust | `design.md` §6 | T5: who clears a `blocked` slice | **Live runs**: the developer re-runs it in a session that has the tool |
| PE20 | n | editor | `design.md` §6 Seeding | E2: two rules for a fallback dry run | Merged into one **Live runs** rule, with the forced fallbacks as its stated exception |
| PE21 | n | editor | `prd.md` S-01.2, Failure modes | E1: the fault lists differed from the completeness check | S-01.2 and its failure row now list a second pair of markers and `## Open points` |
| PE22 | n | editor | `prd.md` Non-goals; `README.md` Brief; `context.md` §1 | E1, E5: "the panel is unchanged" while ADR-004 and ADR-005 change it. Also aC1 | Each now names the two panel changes, and the `planning` change of ADR-008 |
| PE23 | n | editor | `design.md` §2 Deferral | E2: no rule for the design checkpoint. Also aQ7 | Deferral row: at the acceptance and design checkpoints a deferral does not withhold Approve; an item neither answered nor deferred does |
| PE24 | n | editor | `prd.md` S-05.2 | E6: the criterion did not say the open points are asked | S-05.2 now says so |
| PE25 | n | editor | `design.md` §1; `context.md` §2 | E3: `{base}` and the new phase rows missing | `spec` row names Phase 2's `{base}`; `context.md` §2 gains rows for `spec` 13-15 and Phase 8, `slice` Phase 1, `planning` and the handoff template |
| PE26 | n | editor | `plan.md` Slice 4 Depends on | E4: its dry run runs Phases 3 and 4, which Slice 3 changes | Slice 4 depends on Slice 3; the graph gains S3 to S4; its stop names Slices 1 to 3 |
| PE27 | n | editor | `design.md` §2 Draft completeness check | E4: held open points had no consumer before Slice 2 | Until Slice 2, Phase 4 lists them with the checkpoint's content (completeness row, Slice 1 Contracts) |
| PE28 | n | editor | `decisions/ADR-006` | E5: the Decision's "nothing it reports is fixed … held and asked" is wider than the design | The pack stands: the design follows the Decision's chosen option, and non-blocking re-check findings are listed, not asked; no ADR change |
| PE29 | n | editor | `plan.md` Slice 2 2.1 | E1, E3: five headings for ten contract rows. Also aQ6, bQ11 | 2.1 places Ids and Fix under Gate pass, Answer and Deferral under Checkpoint batch, and adds `## Handoff`; Verify expects six lines |
| PE30 | n | editor | `design.md` §6 Seeding | E1: how an open point is seeded | Seeding: a row added to the report's `## Open points` before the completeness check |
| PE31 | n | editor | `design.md` §1 | E3: `reslice.md` named only in R2 | The `slice` row names it |
| PV22 | n | test | `plan.md` every Verify | V1: `grep -c zz-dryrun` exits 1 on 0 | Each expected line now says to read the output, not the status |
| PV23 | n | test | `design.md` §6 | V1, V3: no pass rule for a seeded dry run | **Pass rule**: every seed reported; one more run allowed; a second miss is a fail |
| PV24 | n | test | `plan.md` Slices 1 and 2 Verify | V6: the fallback lines rested on a dry run alone | Greps for `Drafted by the Facilitator: not independent.`, `gave no complete draft.` and `Gate run by the Facilitator: not independent.` |
| aQ3 | n | editor | `design.md` §2 Drafting frame | `{skill}` did not include the reference file the Architect reads. Also bQ7 | `{skill}` now includes each reference file the phase points to. Checklist line proposed for editor: as E8 |
| aQ4 | n | reader | `design.md` §2 Draft report | How a size S Analyst draft is delimited | The reader's default: markers name `README.md`, the draft holds `### Outcome` and `### Acceptance`, put in their place |
| aQ5 | n | editor | `design.md` §2 Fix | Where unfixed non-blocking gate findings go | Fix row: counted in the Display line and listed under it, never asked. Checklist line proposed for editor: **E10** For every item a contract says is listed, shown or held, name the message or file that carries it. |
| aQ6 | n | editor | `plan.md` Slice 2 2.1 | As PE29 | As PE29. Checklist line proposed for editor: **E11** When a criterion fixes a file's headings, map every contract row for that file to one heading. |
| aQ7 | n | editor | `design.md` §2 Deferral | As PE23 | As PE23. Checklist line proposed for editor: as E10 |
| aQ8 | n | reader | `plan.md` Slice 3 | The probe for an assumption that needs a dry run | Re-classed with a cited place: prd S-04.1.e2 gives `not run: needs Slice 1's dry run`; no change |
| aQ9 | n | reader | `design.md` §2 `## Kind` | The message for a kind other than `review` or `draft` | The row now gives the same line for either |
| aQ10 | n | test | `plan.md` Slice 1 | S-01.2 had no Id | As PV20, already found by the Test engineer; no new line |
| aQ11 | n | editor | `plan.md` Slice 5 | How Count reads a draft | As bQ2 |
| aQ12 | n | reader | `design.md` | No §3 or §4 | The pack stands: the template's §3 Domain model and §4 State machines are not triggered, and the numbers follow the template (`skills/planning/references/templates/design.md`) |
| aQ13 | n | reader | `design.md` §6 Fixtures | The seed texts are not written out | The reader's default: Seeding now says the executor writes each seed against real lines and records it |
| bQ1 | y | editor | `design.md` §2 `{sha}` | As aQ1 | As aQ1 |
| bQ4 | n | reader | `design.md` §5 | A `mermaid` fence reported as code | Re-classed with a cited place: `pack-format.md` §6 allows `mermaid`; the Fences check printed nothing; no change |
| bQ5 | n | reader | `plan.md` Dependency graph | As bQ4 | As bQ4 |
| bQ6 | n | reader | `plan.md` Slice 4 | The Architect's Checklist content | The reader's default: Slice 4 step 1, only the checks neither Phase 7 nor its reference states |
| bQ7 | n | editor | `design.md` §2 Drafting frame | As aQ3 | As aQ3 |
| bQ8 | n | editor | `plan.md` Slice 4 Dry runs | The untagged fence seeded before the write, against Seeding | Slice 4 and the design's level row now seed after the write, before the Self-check. Checklist line proposed for editor: as E7 |
| bQ9 | n | reader | `design.md` §7 R1 | The one-section-per-dispatch fallback is not specified | The pack stands: R1 names it as the change if Slice 1's dry run fails, which is a re-plan, not this pack's contract |
| bQ10 | n | editor | `plan.md` Slice 5 | "nears 400" against the 400-line stop | Step 5 now moves Re-slice before the edits would reach 400. Checklist line proposed for editor: as E7 |
| bQ11 | n | editor | `plan.md` Slice 2 | As PE29 | As PE29 |
| bQ12 | n | fact | `design.md` §2 Drafting frame `{date}` | When `{date}` is taken | Once per skill run, with `{base}`. Checklist line proposed for fact: **F8** For every value a contract computes, check that the pack says when it is taken and from what. |
| bQ13 | n | reader | `design.md` | As aQ12 | As aQ12 |

### Contradictions

| Item | Resolution |
|---|---|
| aC1 (editor): `README.md` Brief and `prd.md` Non-goals say the panel is out of scope; S-01.3, Slice 1 and ADR-004 change it | Brief and Non-goals changed, as PE22. Checklist line proposed for editor: as E7 |
| aC2 (editor): `context.md` §1 says the panel is unchanged; §2 changes `panel.md` 13-14 | §1 changed, as PE22 |
| aC3 (editor): `design.md` `{sha}` against `prd.md` S-02.1.e1 and `skills/spec/SKILL.md:128` | As aQ1 |
| aC4 (reader): ADR-004 to ADR-007 carry `author (spec)` though accepted | No change: each reads `author (spec); accepted by the developer at the spec ADR checkpoint`, which records who proposed and who accepted |
| aC5 (trust): ADR-007 "Nothing else is recorded" against "Files are the only state" | As aQ2; ADR-008 amends ADR-007 |
| aC6 (editor): Fix "listed at the checkpoint" against Held and Checkpoint batch | As aQ5 |
| aC7 (editor): the Drafting frame `{skill}` against Slice 4 step 1 | As aQ3 |
| aC8 (editor): S-04.3.e1 against the Deferral row | As PE23 |
| aC9 (reader): the `## Kind` rule against its one message | As aQ9 |
| bC1 (editor): `{sha}` | As aQ1 |
| bC2 (editor): modifier sections | As bQ3 |
| bC3 (editor): Slice 4 seeding before the write | As bQ8 |
| bC4 (editor): Slice 2's five headings against ten Gates rows | As PE29 |
| bC5 (editor): Slice 5's stop at 400 against "nears 400" | As bQ10 |

### Citations checked

| Citation | Holds |
|---|---|
| a `skills/spec/SKILL.md:118-140` | yes |
| a `skills/slice/SKILL.md:115` | yes |
| a `skills/slice/SKILL.md:188-191` | yes |
| a `skills/cold-read/references/panel.md:13-14` | yes |
| a `skills/cold-read/references/panel.md:69-86` | yes |
| a `skills/planning/references/roles/dispatch.md:22-54` | yes |
| a `skills/planning/references/roles/dispatch.md:97-102` | yes |
| a `skills/planning/references/roles/dispatch.md:20` | yes |
| a `skills/planning/references/roles/fact-checker.md:24-45` | yes |
| a `skills/planning/references/roles/fact-checker.md:1-53` | partly: it ends at the `## Blocking test` heading, which is the card shape cited |
| a `skills/planning/references/templates/prd.md:54-60` | yes |
| a `skills/cold-read/references/tree.md:22`, `:28-29` | yes |
| a `skills/cold-read/SKILL.md:54-60` | yes |
| a `skills/cold-read/SKILL.md:241-246` | yes |
| a `skills/slice/SKILL.md:232-234` | yes |
| a `skills/slice/SKILL.md:33-35` | yes |
| a `skills/spec/SKILL.md:155-158` | yes |
| a `skills/spec/SKILL.md:277-284` | yes |
| a `skills/spec/SKILL.md:226-229` | yes |
| a `skills/planning/references/roles/trust-reviewer.md:57` | yes |
| a `skills/planning/references/pack-format.md` §6 | yes |
| a `docs/plans/planning-team-review/progress/slice-03.md:27` | yes |
| a `docs/plans/planning-team-review/prd.md` Problem | yes |
| a `docs/verification.md:170` | yes |
| a `docs/plans/planning-team/README.md` Key insights | yes |
| a `docs/plans/planning-team-review/context.md:15` | yes |
| a `context.md` §1 line counts, 370 and 385 | yes |
| b `skills/spec/SKILL.md:114-140` | yes |
| b `skills/spec/SKILL.md:273-284` | yes |
| b `skills/spec/SKILL.md:197-211` | yes |
| b `skills/slice/SKILL.md:115` | yes |
| b `skills/slice/SKILL.md:188-192` | yes |
| b `skills/slice/SKILL.md:232-234`, `:239`, `:278` | yes |
| b `skills/slice/SKILL.md:77` | yes |
| b `skills/planning/references/roles/dispatch.md:3-4`, `:11-20`, `:20` | yes |
| b `skills/planning/references/roles/dispatch.md:22-54`, `:56-72`, `:80-86`, `:88-95`, `:97-102` | yes |
| b `skills/cold-read/SKILL.md:54-60` | yes |
| b `skills/cold-read/references/panel.md:13-14` | yes |
| b `skills/cold-read/references/panel.md:75-86`, `:36-40` | yes |
| b `skills/planning/references/templates/prd.md:54-60` | yes |
| b `skills/planning/references/pack-format.md:136` | yes |
| b `skills/planning/references/roles/fact-checker.md:24-45`, `:1-53` | yes |
| b `skills/planning/references/roles/trust-reviewer.md:51-61` | yes |
| b test-engineer and editor card headers | yes |
| b `docs/verification.md:78`, `:158`, `:170` | yes |
| b `.gitignore:10` | yes |
| b `docs/plans/planning-team-review/progress/slice-03.md:27` | yes |
| b `docs/plans/planning-team-review/progress/slice-05.md:48-61`, `:86-88` | yes |
| b `skills/spec/references/design.md` | yes |
| b `skills/spec/SKILL.md` and `skills/slice/SKILL.md` line counts | yes |
| b `skills/spec/SKILL.md:17-18`, `skills/slice/SKILL.md:18-19` | yes |
| b `skills/slice/SKILL.md:33-35` | partly: the reader placed it within 28-36 without confirming the lines |

## Round 2 — 2026-11-24

Two readers, both Haiku (Agent tool, model: haiku, Explore), dispatched in one step, each in its own
tree at `origin/main` (`f8e598f`) with the pack copied in; both guards held. Touched: Slice 1,
Slice 2, Slice 3, Slice 4, Slice 5. Reader `a` thought through Slices 1, 2 and 3 and checked 39
citations, 37 holding and 2 partly. Reader `b` thought through Slices 4 and 5 and checked 25
citations, 24 holding and 1 partly (`.hivrr.json`, absent and git-ignored as the pack says). Neither
found code; both read the `mermaid` fences as diagrams.

Editor pass on round 1's diff: Editor Sonnet (Agent tool, model: sonnet, Explore) — 11 findings (1
blocking), all fixed before the readers, numbered `PE32` to `PE42`.

### Questions

| Id | Blocking | Role | File | Gap | Resolution |
|---|---|---|---|---|---|
| PE32 | y (fixed before the readers) | editor | `prd.md` S-03.5; `design.md` §2 Handoff; `plan.md` Slices 3 to 5 | E1, E3: a Gate pending entry for `prd.md`, `design.md` and `plan.md` was in no slice's Contracts, and `design.md` has no gate to re-run | Handoff row covers all four files, `design.md` going straight to its checkpoint; S-03.5 is traced to Slices 2 to 5, each with a dry run |
| PE33 | n | editor | `plan.md` Slice 2 2.4 | E3, E6: S-06.4's `planning` and `spec` side was in no slice's Files | 2.4 and Slice 2's Acceptance carry it; Traceability S-06.4 is Slices 2 and 5 |
| PE34 | n | editor | `plan.md` Slice 1 dry runs | E6: S-01.3.e1's four drafting cards could not be reproduced | The `roles/` copy holds the Scout and three stand-in drafting cards |
| PE35 | n | editor | `plan.md` Slice 5 Depends on | E4: its dry run goes through `spec`'s checkpoint | Slice 5 depends on Slices 1 to 4; the graph gains S3 and S4 to S5 |
| PE36 | n | editor | `plan.md` Slice 4 Stop conditions | E2: modifier sections cited to the prd Non-goals | Cited to `design.md` §1 |
| PE37 | n | editor | `decisions/ADR-004` | E2, E5: the design gives the no-kind line for an invalid kind too | The pack stands: an accepted ADR is never edited, and "a card without one" reads as without a valid one |
| PE38 | n | editor | `decisions/ADR-007` body | E5: Decision and Consequences still read as before ADR-008 | The pack stands: the Status line carries the amendment, as `pack-format.md` §1 says |
| PE39 | n | editor | `prd.md` Non-goals; `README.md` | E1: `planning` does more than read `handoff.md` | Both name resuming from it and refusing Approve while it exists |
| PE40 | n | editor | `prd.md` S-06.3; `plan.md` Slice 5 | E1: "unanswered" against a deferred item withholding Approve | Both read "unanswered or deferred" |
| PE41 | n | editor | `prd.md` S-03.5; ADR-008 | E1: `Fix not re-checked` missing | S-03.5 names it; ADR-008 stands, accepted |
| PE42 | n | editor | `context.md` §2 | E1: no `pack-format.md` row | Row added |
| aQ1 | y | fact | `design.md` §2 Draft report; `skills/spec/SKILL.md:136-138` | A Greenfield `context.md` cites stack choices to an ADR not written until Phase 5, so the context gate could not check it. Also aC4, aC10 | Draft report row: the Scout cites the Brief or the Ruled out option, the gate checks that, and the Facilitator adds the ADR citation in Phase 5. Checklist line proposed for fact: **F9** For every phase a slice changes, read the whole phase in the skill, every route branch included, and check each branch against the new contract. |
| bQ1 | y | fact | `design.md` §2 Drafting roles; `skills/slice/SKILL.md:77-92` | Re-slice forbids rewriting `plan.md` wholesale, but the Planner returns the whole file. Also bX1 | Drafting roles row: in a Re-slice the Planner gets the current `plan.md` and the reason and revises only the slices the reason needs; a change elsewhere is an incomplete draft. Slice 5 step 2 and a Re-slice dry run. Checklist line proposed for fact: as F9 |
| bQ2 | y | fact | ADR-008; `design.md` §2 Handoff; `skills/planning/SKILL.md:114-116` | A handoff `Spec pending` entry and the existing README `Spec pending after …` line share a name. Also aQ8, aC3, bX2 | Handoff row: `planning` reads `handoff.md` before the README pending lines; both resume at Phase 4, Specify, passing the answer as the request; each keeps its own removal rule. Checklist line proposed for fact: **F10** For every name the pack introduces (a line, entry, heading or label), search the repository for an existing use of it. |
| aQ2 | n | reader | `skills/spec/SKILL.md` Phase 2 | Scout and gate when Phase 2 is skipped | Re-classed with a cited place: ADR-003 and `design.md` §1 Stages, a stage the route skips dispatches nothing |
| aQ3 | n | editor | `design.md` §2 Ids | A Trust finding's `PT` and `GT` Ids. Also aC1 | The Questionnaire row takes its finding's `G` Id. Checklist line proposed for editor: as E7 |
| aQ4 | n | reader | `design.md` §2 Drafting card shape | Drafting checklists not written out | The pack stands: each slice writes its card under the Drafting card shape rule |
| aQ5 | n | reader | ADR-001, R1 | The section-per-dispatch fallback | As round 1's bQ9 |
| aQ6 | n | test | `plan.md` Slice 2 | S-06.4 listed with no proof in Slice 2. Also aC5 | A Slice 2 dry run on a copy with a Spec pending entry; `S-06.4` in its Id loop. Checklist line proposed for test: **V7** For every criterion in a slice's Acceptance, name the dry run or Verify line in that slice that proves it. |
| aQ7 | n | test | `design.md` §2 Fix | Whether the Self-check re-runs after the slice gate's fixes. Also bQ4 | Fix row: it runs again before the re-check; a failure is fixed once, then held. Checklist line proposed for test: **V8** For every check a step runs, say whether edits later in the same step run it again. |
| aQ9 | n | editor | prd S-03.6; `design.md` §2 Ids | "README Deferred lines" is no section. Also aC2 | Both name the README Open questions `Deferred at …` lines. Checklist line proposed for editor: as E7 |
| aQ10 | n | editor | `design.md` §6 Seeding | Seeding said the drafter writes. Also aC7 | Reworded: the Facilitator writes each accepted draft. Checklist line proposed for editor: as E7 |
| aQ11 | n | reader | every Verify | `.hivrr.json` absent | The pack stands: each first Verify line says to scaffold it |
| aQ12 | n | reader | `mermaid` fences | Diagrams, not code | As round 1's bQ4 |
| aQ13 | n | reader | `design.md` §2 Drafting frame | Whether `Explore` can read paths outside the tree | The pack stands: the frame passes absolute paths, which are read-only inputs |
| bQ3 | n | reader | `plan.md` Slice 5 | Who does `slice` Phase 3 | The pack stands: the Planner's `{skill}` is Phases 2 to 4 (Slice 5 step 1) |
| bQ5 | n | editor | `design.md` §2 Draft completeness check | Non-blocking Architect open points | A non-blocking open point is settled by the Facilitator and listed at the checkpoint. Checklist line proposed for editor: as E10 |
| bQ6 | n | reader | `plan.md` Slice 4 step 1 | The Architect's Checklist may be empty | The pack stands: a short Checklist is allowed by the Drafting card shape |
| bQ7 | n | reader | `skills/spec/SKILL.md` Phase 8 | Change at the design checkpoint | Re-classed with a cited place: `design.md` §1, every checkpoint keeps its options |
| bQ8 | n | reader | `plan.md` local criteria | Local Ids in the progress file | The pack stands: they are in each slice's Id loop |
| bQ9 | n | reader | `plan.md` Slice 5 | When the Re-slice move is needed | The pack stands: Slice 5's stop condition and step 5 give the 400-line rule |

### Contradictions

| Item | Resolution |
|---|---|
| aC6 (reader): "the 12-slice stop" against "more than 12" | Slice 5 step 2 reads "the stop at more than 12" |
| aC8 (reader): `{base}` fallback "Tree from" against cold-read's "Reader tree from" | No change: a gate's tree is not a reader's, so the line names it |
| aC9 (editor): the `{base}` failure row cites S-02.2 | The row cites Slice 1's 1.4 as well. Checklist line proposed for editor: as E7 |
| bX4 (reader): Slice 5 depends on Slice 4, which it uses nothing from | No change: its S-06.4.e1 dry run runs `spec` revise, which can reach Phase 7 |
| bX5 (reader): one seed proves S-06.2.e2 and S-06.3.e3 | No change: the seed is held at the gate (S-06.2.e2) and answered at the checkpoint (S-06.3.e3) |
| bX6 (editor): S-03.5 "re-runs only that file's gate" against `design.md`, which has none | S-03.5 names the `design.md` case. Checklist line proposed for editor: as E7 |

### Citations checked

| Citation | Holds |
|---|---|
| a `skills/spec/SKILL.md:13-15`, `:23-25`, `:114-140`, `:128`, `:226-229`, `:273-284`, `:316-334` | yes |
| a `skills/spec/SKILL.md` and `skills/slice/SKILL.md` line and phase counts | yes |
| a `skills/slice/SKILL.md:33-35`, `:115`, `:232-234` | yes |
| a `skills/planning/references/roles/dispatch.md:3-4`, `:11-20`, `:20`, `:22-54`, `:56-72`, `:65-68`, `:80-86`, `:88-95`, `:97-102` | yes |
| a `skills/cold-read/references/panel.md:13-14`, `:36-57`, `:69-84`, `:86`, **Ids** | yes |
| a `skills/cold-read/references/tree.md:22`, `:28`, `:29` | yes |
| a `skills/planning/references/roles/fact-checker.md:24-45` | yes |
| a `skills/planning/references/roles/fact-checker.md:1-53` | partly: the Blocking test runs to 58 |
| a `skills/planning/references/roles/trust-reviewer.md:57`, `:51-61` | yes |
| a `skills/cold-read/SKILL.md:54-60` | yes |
| a `skills/cold-read/SKILL.md:241-246` | partly: the passage ends before 246 |
| a `skills/planning/references/templates/prd.md:54-60`; `pack-format.md:16-36`, `:136` | yes |
| a `skills/planning/SKILL.md:114-116`, `:305-307` | yes |
| a `docs/verification.md:78`, `:158`, `:170`; `CLAUDE.md` **Script policy** | yes |
| a `docs/plans/planning-team-review/progress/slice-03.md:27`, `slice-05.md:48-61`, `:86-88`, `prd.md` Problem; `docs/plans/planning-team/README.md` Key insights | yes |
| a `skills/spec/references/design.md`; `gates.md` and `templates/handoff.md` not yet present | yes |
| b `skills/spec/SKILL.md` and `skills/slice/SKILL.md` counts; `skills/slice/SKILL.md:33-35`, `:188-191`, `:232-234` | yes |
| b `skills/spec/SKILL.md:13-15`, `:273-284`, `:316-334` | yes |
| b `skills/planning/SKILL.md:114-116`, `:305-307` | yes |
| b `dispatch.md:3-4`, `:11-20`, `:80-86`, `:88-95`, `:97-102` | yes |
| b `fact-checker.md:24-45`; `trust-reviewer.md:57` | yes |
| b `panel.md:13-14`, `:36-57`, `:69-84`, `:86`; `tree.md:22`, `:28-29`; `cold-read/SKILL.md:54-60` | yes |
| b `templates/prd.md:54-60`; `pack-format.md:136`; `skills/spec/references/design.md` | yes |
| b `docs/verification.md:78`, `:158`, `:170`; `planning-team-review` progress 03 `:27` and 05 `:86-88`; `CLAUDE.md` headings | yes |
| b `.hivrr.json` | partly: absent and git-ignored, as the pack says |

## Round 3 — 2026-11-24

One reader, Haiku (Agent tool, model: haiku, Explore), in its own tree at `origin/main` (`f8e598f`)
with the pack copied in; the guard held. Touched: Slice 1, Slice 2, Slice 5. Reader `a` thought
through Slices 1, 2 and 5 and checked 36 citations, 33 holding and 3 partly. It reported the two
`mermaid` fences as code, which was re-classed as in round 1 (aQ1).

Editor pass on round 2's diff: Editor Sonnet (Agent tool, model: sonnet, Explore) — 9 findings (1
blocking), fixed before the reader where the pack may change, numbered `PE43` to `PE51`.

### Questions

| Id | Blocking | Role | File | Gap | Resolution |
|---|---|---|---|---|---|
| PE43 | y (fixed before the reader) | editor | `design.md` §2 Drafting roles; `plan.md` Slice 5 | E3, E2: the Re-slice inputs had no place in the drafting frame and no criterion | The drafting frame allows a card's extra input after the Pack line; the Planner lists `{current}`; Slice 5 gains 5.4 with a dry run and its Id in the loop |
| PE44 | n | editor | `design.md` §2 Draft completeness check; `prd.md` S-01.2, Failure modes | E2: the Re-slice fault missing from the lists | Added to all three |
| PE45 | n | editor | `plan.md` Slice 1 | E2: Greenfield rule in no criterion or step | 1.5, step 5 and a Greenfield dry run |
| PE46 | n | editor | `design.md` §6 level table | E2: S-06.4.e1 placed in Slice 5 only | A row for Slices 2 and 5; Slice 2 records the `planning` and `spec` side |
| PE47 | n | editor | `README.md`; prd S-03.5.e3 | E1, E6: Publish missing | Both name Approve and Publish |
| PE48 | n | editor | ADR-008 | E2, E5: the `design.md` resume case and the entry's full contents | The pack stands: an accepted ADR is never edited; the design and prd S-03.5 carry the case, and the prd failure row now names it |
| PE49 | n | editor | ADR-006; `design.md` §2 One re-check | E1, E5: a new non-blocking re-check finding had no outcome | One re-check row: listed at the checkpoint, not fixed |
| PE50 | n | editor | prd S-06.2; `plan.md` Slice 5 step 3 | E2: the Self-check re-run in one place only | Both say so |
| PE51 | n | editor | ADR-008; `plan.md` Slice 2 | E2: "README Deferred lines" left | `plan.md` fixed; ADR-008 stands, accepted |
| aQ1 | n | reader | `design.md` §5; `plan.md` Dependency graph | The `mermaid` fences read as code | Re-classed with a cited place: `pack-format.md` §6 and `skills/spec/SKILL.md:23-25` allow `mermaid` for a diagram; the Fences check printed nothing; no change |
| aQ2 | n | editor | `design.md` §2 Handoff | A `##` heading or a bold line for an entry | The row now gives `## Gate pending: {file}`, as ADR-008 does. Checklist line proposed for editor: as E7 |
| aQ3 | n | editor | prd S-03.1 | "an approved context stage" at size S, which has none. Also aC2 | S-03.1 adds "or none where the route skips it". Checklist line proposed for editor: as E7 |
| aQ4 | n | reader | `plan.md` Slice 2 Verify | S-06.4.e1 split across two slices | The pack stands: each slice's row says its side (`design.md` §6 level table) |
| aQ5 | n | reader | `plan.md` Slice 1 dry runs | Which Assumptions row | Now names prd Assumptions row 1 |
| aQ6 | n | reader | ADR-001, R1 | The section fallback | As round 1's bQ9 |
| aQ7 | n | reader | `plan.md` Slice 1 step 3 | The Scout's Checklist | As round 2's aQ4 |
| aQ8 | n | reader | `design.md` §2 `{base}` | `Tree from` against `Reader tree from`. Also aC6 | As round 2's aC8 |
| aQ9 | n | editor | `design.md` §2 Drafting roles | Where the Re-slice reason comes from | The reason `slice` Phase 1 Re-slice records, the developer's request. Checklist line proposed for editor: as E8 |
| aQ10 | n | reader | `plan.md` Slice 5 step 5 | Conditional move against a mandatory stop. Also aC7 | The pack stands: the stop fires only if the move is skipped, and step 5 makes the move before it would |
| aQ11 | n | reader | `design.md` §2 Answer | An answer that changes `context.md` after the prd | The reader's default: no re-check; the panel and the cold read meet it again |
| aQ12 | n | reader | Slice 3, F7 | Whether `Explore` has a shell | The pack stands: `Explore` has read and search tools and read-only commands, and F7 says `not run` otherwise |
| aQ13 | n | reader | `design.md` §2 Handoff | Where `Fix not re-checked` lives | Already in the Handoff row, inside the entry |
| aQ14 | n | reader | `design.md` §2 Draft completeness check | Which sections the Facilitator keeps | Re-classed with a cited place: `design.md` §1 lists them, and the check cites §1 |
| aQ15 | n | reader | `plan.md` Slice 4 step 1 | The Architect's Checklist | As round 2's bQ6 |
| aQ16 | n | reader | `design.md` §2 Handoff | The answer passed to `spec` | Already stated: the entry's answer as `spec`'s request |

### Contradictions

| Item | Resolution |
|---|---|
| aC1 (reader): Assumptions row 5's 385 against the 400-line cap | No change: the probe reads the counts the 29 and 14 lines of headroom rest on |
| aC2 (editor): S-03.1 against a size S route with no context stage | As aQ3 |
| aC3 (editor): ADR-008's `##` sections against the design's bold name | As aQ2 |
| aC4 (reader): one Id across two slices | As aQ4 |
| aC5 (editor): Assumptions row 3's partial tree against the whole-pack copy | Row 3 now says the pack is copied in, holding only the README and `context.md` before Phase 3. Checklist line proposed for editor: as E7 |
| aC6 (reader): `{base}` fallback wording | As aQ8 |
| aC7 (reader): the Re-slice move against its stop | As aQ10 |

### Citations checked

| Citation | Holds |
|---|---|
| a `skills/spec/SKILL.md` and `skills/slice/SKILL.md` line and phase counts | yes |
| a `skills/spec/SKILL.md:13-15`, `:23-25`, `:118-140`, `:128`, `:136-138`, `:155-158`, `:277-284` | yes |
| a `skills/spec/SKILL.md:226-229` | partly: the reader inferred the link to a checkpoint choice |
| a `skills/slice/SKILL.md:33-35`, `:77-92`, `:115`, `:188-191`, `:232-234`, `:239-249` | yes |
| a `skills/cold-read/references/panel.md:13-14`, `:36-57`, `:69-84`, `:86`; `tree.md:22`, `:28-29`; `cold-read/SKILL.md:54-60` | yes |
| a `dispatch.md:11-20`, `:22-54`, `:25-26`, `:56-72`, `:70-72`, `:80-86`, `:88-95`, `:97-102` | yes |
| a `fact-checker.md:1-53`, `:24-45`; `trust-reviewer.md:51-61`; card letters and models | yes |
| a `templates/prd.md:54-60`; `skills/planning/SKILL.md:114-116`, `:305-307` | yes |
| a `docs/verification.md:78`, `:158`, `:170`; `CLAUDE.md` Script policy | yes |
| a `planning-team-review/progress/slice-03.md:27` | partly: the reader's output was cut short before the model |
| a `planning-team-review/progress/slice-05.md:48-61`, `:86-88`; `planning-team-review/prd.md` Problem | yes |
| a the new files absent; `skills/spec/references/design.md` present | yes |
| a `docs/plans/planning-team/README.md` Key insights | partly: the heading was found, the claim not read |

## Result

`Pass after 3 round(s) (3 in this run).`

### Checklist proposals

- aQ1 (round 1) → `editor.md`: **E7** For every rule restated across files (a value, its source, the moment it is taken, a threshold, before or after a write), compare each restatement with the others word for word, the skill being changed included.
- aQ2 (round 1) → `trust-reviewer.md`: **T7** For every piece of state held between two steps, say what a session that ends between them leaves on disk, and how the next run recovers it.
- bQ2 (round 1) → `editor.md`: **E8** For every role a slice adds, check that one contract row states every input it reads and the exact span of what it returns.
- bQ3 (round 1) → `editor.md`: **E9** For every section a check requires, name who writes it; a check that requires what its writer may not write fails.
- aQ5 (round 1) → `editor.md`: **E10** For every item a contract says is listed, shown or held, name the message or file that carries it.
- aQ6 (round 1) → `editor.md`: **E11** When a criterion fixes a file's headings, map every contract row for that file to one heading.
- bQ12 (round 1) → `fact-checker.md`: **F8** For every value a contract computes, check that the pack says when it is taken and from what.
- aQ1 (round 2) → `fact-checker.md`: **F9** For every phase a slice changes, read the whole phase in the skill, every route branch included, and check each branch against the new contract.
- bQ2 (round 2) → `fact-checker.md`: **F10** For every name the pack introduces (a line, entry, heading or label), search the repository for an existing use of it.
- aQ6 (round 2) → `test-engineer.md`: **V7** For every criterion in a slice's Acceptance, name the dry run or Verify line in that slice that proves it.
- aQ7 (round 2) → `test-engineer.md`: **V8** For every check a step runs, say whether edits later in the same step run it again.

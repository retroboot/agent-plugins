# Cold read

| | |
|---|---|
| **Model** | Haiku (Agent tool, model: haiku, Explore) |
| **Input** | Pack path and repository read access only; no conversation context |
| **Rounds** | 3 |
| **Result** | Pass after 3 rounds |

## Round 1 — 2026-11-24

Reader: Haiku (Agent tool, model: haiku, Explore), in a detached worktree of `origin/main`
(`52fa634`) with the pack copied in. It thought through Slices 1 and 2. It checked 24 citations:
20 held, 2 partly, 2 did not. The two that did not were the parent pack and `.hivrr.json`, neither
of which is on `{base}`; see Q7 and Q17. It found one code item: a `bash` fence outside Verify (Q1).
No author findings in Phase 2. The guard held.

### Questions

| Id | Blocking | File | Gap | Resolution |
|---|---|---|---|---|
| Q1 | y | `context.md` §4 | A `bash` fence sat under a heading that is not Verify | The command is now an inline code span in prose; `context.md` has no fence |
| Q2 | y | `prd.md` S-01.1; `design.md` §2 Role card; `plan.md` Slice 1 Verify | S-01.1 puts the model in the card; the card had no Model heading and the model sat in `dispatch.md` | The card gains `## Model`, the only place a role's model is stated. The dispatch row became **Model resolution**, which reads the card. Every Verify heading list now expects `Letter\|Model\|Job\|…` |
| Q3 | y | `design.md` §2 Panel pass | In Record only, the design wrote fixes as proposals, while the skill holds every author finding | Record only: every panel finding is held and counts as Blocking, its fix written as `Proposed:` in its Resolution, as for author findings |
| Q4 | y | `design.md` §2; `context.md` §5 Round | No home for panel findings when the run stops before any reader | They go in the closing Result under `### Panel without a reader` (Panel pass row and Record contract). The glossary's Round entry now says so. This extends S-02.3 for a stopped run only; its meaning is unchanged |
| Q5 | n | `design.md` §2 Prompt frame | The frame's wording was not written | Adopted: the frame follows the reader prompt's structure (`skills/cold-read/SKILL.md:204-240`), written into the Prompt frame row |
| Q6 | n | `design.md` §2 Tree and guard | In Record only, Phase 2 already builds the round's tree | Adopted: the panel builds its own tree in every mode and removes it after its guard |
| Q7 | n | `plan.md` every Verify | `.hivrr.json` is gitignored, and without it the command prints nothing and exits 0 | The pack stands: each Verify expects `structural checks pass`, so no output already fails. `context.md` §4 now says to scaffold `.hivrr.json` per `docs/verification.md`, and that no output is a failure |
| Q8 | n | `plan.md` 1.4; `design.md` §6 | Seeded defects are described only by category | The pack stands: the executor picks them and lists each in the progress file before the run (`design.md` §6) |
| Q9 | n | `plan.md` Slice 1 dry run | S-02.2.e1 uses `cargo check`, and this repo has no Rust | Adopted: Slice 1's dry run writes a git-ignored file in place of `cargo check` |
| Q10 | n | `plan.md` Slice 1 dry run | S-02.4.e2 is proven with `PF`, while its example uses `PT` | The pack stands: Slice 1 proves the held path with `PF`, and Slice 3 proves S-02.4.e2 with `PT` |
| Q11 | y | ADR-004; `design.md` §2 Re-check | Whether the Editor check after each reader round is capped | Clarified without changing ADR-004 (its cap is "before the first reader"): after a reader round, one Editor pass checks that round's fix diff. It is outside ADR-004's cap and bounded by the 3-round cap. Not developer-only, since the accepted decision stands |
| Q12 | n | `design.md` §2 Re-check | "Pass" is undefined | Adopted: one dispatch step is one pass, written into the Tree and guard row |
| Q13 | n | `plan.md` Slice 2 `{diff}` | The pack is untracked, so `git diff` shows nothing | Adopted: `{diff}` is the `diff -ru` of a copy taken before the fixes, written into the Tree and guard row |
| Q14 | n | `skills/cold-read/SKILL.md:310` | Once Phase 2 holds the panel, "run the Phase 2 checks again" could mean the whole panel | Adopted: Slice 2's 2.2 now rewrites it to the mechanical checks, then the re-check in `panel.md` |
| Q15 | n | `plan.md` 2.3; `design.md` §6 | Only one seeded editor defect was specified | Adopted: `design.md` §6 names all three |
| Q16 | n | `README.md` Brief | It said the Trust reviewer runs only with outside inputs, against S-02.5 | Fixed: the Brief now says it always runs, with an empty table when there are none |
| Q17 | n | `README.md` Brief | The parent pack is not on `{base}` | The pack stands: the parent README is committed with this pack's PR (`skills/planning/SKILL.md`, Phase 3, XL parent), so executors will have it |

### Contradictions

| Item | Resolution |
|---|---|
| K1: `prd.md` S-01.1 against `design.md` §2 Role card and Slice 1 Verify | `design.md` and `plan.md` changed (Q2) |
| K2: `README.md` Brief against S-02.1 and S-02.5.e1 | `README.md` changed (Q16) |
| K3: `design.md` Panel pass against `skills/cold-read/SKILL.md:390-391` | `design.md` changed (Q3) |
| K4: S-03.2 against `skills/cold-read/SKILL.md:310` | `plan.md` Slice 2 2.2 changed (Q14) |
| K5: S-04.3.e1 against Slice 3's dry run | `plan.md` Slice 3's dry run now answers all but two items |
| K6: S-02.4.e2 (`PT1`) against Slice 1's `PF` dry run | Stands (Q10) |
| K7: `context.md` §4 fence against the fence rule | `context.md` changed (Q1) |
| K8: Round in the glossary against S-02.3 and ADR-002 | `design.md` and `context.md` changed (Q4) |

### Citations checked

| Citation | Holds |
|---|---|
| `skills/cold-read/SKILL.md:145` | yes |
| `skills/cold-read/SKILL.md:350` | yes |
| `skills/cold-read/SKILL.md:188`, `:193-194` | yes |
| `skills/cold-read/SKILL.md:202-246` | yes |
| `skills/cold-read/SKILL.md:273-285` | yes |
| `skills/cold-read/SKILL.md:155` | yes |
| `skills/cold-read/SKILL.md` 397 lines, 7 phases | yes |
| `skills/cold-read/SKILL.md:20-21` | yes |
| `skills/slice/SKILL.md:239`, `:278` | yes |
| `.claude-plugin/marketplace.json:51-58` | yes |
| `skills/planning/references/pack-format.md` §6 | yes |
| `skills/planning/references/templates/cold-read.md` | yes |
| `docs/plans/planning-team/README.md` | no — not on `{base}` (Q17) |
| `.hivrr.json` `verify.test` | no — gitignored (Q7) |
| `docs/verification.md:170` | partly — now cited as `:170-191` |
| `CLAUDE.md:215` | yes |
| `skills/planning/SKILL.md:64` | yes |
| `skills/spec/SKILL.md:267`, `skills/review-pr/SKILL.md:86` | yes |
| `skills/planning/references/templates/prd.md:54-60` | yes |
| `skills/core/SKILL.md:117-137` | yes |
| commits `bb1c2b1`, `4830e81` | partly — they exist; content not checked |
| commit `52fa634` | yes |
| `docs/plans/planning-redesign` has 7 or more slices | yes |
| hyalos counts | partly — sums check; source not on `{base}` |

## Round 2 — 2026-11-24

Reader: Haiku (Agent tool, model: haiku, Explore), in a detached worktree of `origin/main`
(`52fa634`) with the pack copied in. It thought through Slices 3 and 4. It checked 27 citations:
24 held, 3 partly. It found no code; it left the `mermaid` fences alone as diagrams (`pack-format.md`
§6). No author findings in Phase 2. The guard held. One developer-only item (C8) was asked before
any fix and answered.

### Questions

| Id | Blocking | File | Gap | Resolution |
|---|---|---|---|---|
| Q1 | y | `design.md` §2 Panel pass; `prd.md` S-02.4.e2, S-04.3.e1 | Whether a deferred item of the pre-reader batch stops the readers | The Panel pass row now says: the item is held, the readers are still dispatched, and the run ends `COLD READ BLOCKED` after that round. This follows ADR-004's reason |
| Q2 | y | `design.md` §1; `plan.md` Slices 1 and 4 | `skills/cold-read/SKILL.md` is 397 lines, and no slice made room for the pointers or named a home for the Phase 3 procedure | Slice 1 moves the tree build and guard (`skills/cold-read/SKILL.md:157-200`) unchanged to `references/tree.md` behind a pointer (1.3, Files, Suggested path). Slice 4 puts the reader procedure in `references/readers.md`. Both are added to `design.md` §1 |
| Q3 | n | `design.md` §2 Role card | The Questionnaire section had no columns and no place in the heading contract | Adopted: role-specific sections sit after Output and before Blocking test; the Questionnaire is `Id \| Question \| Options the pack leaves open \| Blocking` |
| Q4 | n | `design.md` §2 Inputs | How `{diff}` and `{seed}` reach the prompt | Adopted: each is the path of a file outside the tree; the `{seed}` file holds each item's Id, file and section, and its text verbatim |
| Q5 | n | `plan.md` Shared contract | The seeds use Rust examples | Adopted: each item keeps the seed's meaning in wording that fits any repo |
| Q6 | n | `design.md` §2 Sibling scan | Once per round or once per item | Adopted: one Trust dispatch per round, with every developer-only reader question in `{seed}` |
| Q7 | n | `skills/cold-read/SKILL.md:275-276` | "Asked at once" conflicts with the scan before the batch | Adopted: Slice 3's Contracts rewrite it to "after the sibling scan, before any fix and before any further round" |
| Q8 | n | `design.md` §1 Test engineer | `.hivrr.json` is not in a detached tree | Adopted: a command that needs git-ignored local config gets a "would fail because…" note, not a failure |
| Q9 | n | `plan.md` Slice 4 Verify | The grep for three phrases could miss a reworded prompt | Adopted: Verify now diffs the whole reader prompt against `origin/main`, expecting no output |
| Q10 | n | `design.md` §2 Grouping | "Touched" was undefined, and so was the case where no slice is touched | Adopted: a slice is touched when a fix edits its section or a file in its Files list; with none touched, one reader reads the whole pack |
| Q11 | n | `design.md` §2 Record | `{reader}C{n}` Ids had no column | Adopted: each Contradictions Item opens with its Id |
| Q12 | n | `design.md` §2 Reader dispatch | Whether other reports are kept when one reader fails twice | Adopted: they are discarded and the round is unrecorded |
| Q13 | n | `design.md` §2 Reader dispatch | Trees in Record only, and in parallel | Adopted: all trees are built in one step before dispatch; in Record only, reader `a` uses the Phase 2 tree |
| Q14 | n | `design.md` §2 Panel pass | The Record only rule read as a rule for every mode | Adopted: the row now says that in every other mode a fixed finding does not block and a held one does |
| Q15 | n | `plan.md` Slice 3 S-04.2.e1 | A dry run cannot force a reader to raise a developer-only item | The pack stands: it already falls back to a desk check |

### Contradictions

| Item | Resolution |
|---|---|
| C1: `context.md` §5 Review panel ("when triggered") against S-02.5 | `context.md` changed: all four roles on every pass. A restatement missed in round 1's fix for Q16 |
| C2: `design.md` Panel pass against S-02.4.e1 | `design.md` changed (Q14); not a real conflict, since the rule was for Record only |
| C3: S-04.3.e1 and Slice 3 against S-02.4.e2 and `skills/cold-read/SKILL.md:284-285` | `design.md` changed (Q1) |
| C4: `design.md` §1 "pointers, not procedure" against the Phase 3 rewrite in place | `design.md` and `plan.md` changed (Q2) |
| C5: `.hivrr.json` absent from the tree against the Test engineer's Verify run | `design.md` changed (Q8) |
| C6: 397 lines against Slice 1's new subsection | `plan.md` Slice 1 changed (Q2). Blocking: two mandatory items, 1.3 and Verify's line count, could not both hold |
| C7: the Role card's exact heading list against Slice 3 Verify's Questionnaire | `design.md` changed (Q3). Blocking: two contracts disagreed |
| C8: `prd.md` S-01.2 (card and paths only) against `{diff}` and `{seed}` | Blocking, developer-only. Asked 2026-11-24; the developer chose to amend S-01.2 to allow the input files the card's Inputs section lists. `prd.md` S-01.2 changed, noting the amendment |
| C9: `skills/cold-read/SKILL.md:145-147` "prefer" against S-05.2 "only" | `plan.md` Slice 4 Suggested path now replaces "prefer" with "only" |
| C10: `skills/cold-read/SKILL.md:275-276` against the scan before the batch | `plan.md` Slice 3 changed (Q7) |

### Citations checked

| Citation | Holds |
|---|---|
| `skills/cold-read/SKILL.md:145-147` | yes |
| `skills/cold-read/SKILL.md:153` | yes |
| `skills/cold-read/SKILL.md:179`, `:193-194` | yes |
| `skills/cold-read/SKILL.md:202-246` | yes |
| `skills/cold-read/SKILL.md:350` | yes |
| `skills/cold-read/SKILL.md:273-285` | yes |
| `skills/cold-read/SKILL.md:293` | yes |
| `skills/cold-read/SKILL.md:343-358` | yes |
| `skills/cold-read/SKILL.md:155` | yes |
| `skills/cold-read/SKILL.md:154` | partly — holds; its "(R1 in the design)" points outside this pack |
| `skills/cold-read/SKILL.md:188` | yes |
| `skills/cold-read/SKILL.md:20-21` | yes |
| `skills/cold-read/SKILL.md` 397 lines, 7 phases | yes |
| `.claude-plugin/marketplace.json:51-58` | yes |
| `skills/planning/SKILL.md:64`, `:285-306` | yes |
| `skills/slice/SKILL.md:232`, `:239`, `:278` | yes |
| `skills/core/SKILL.md:117-137` | partly — now cited for the script policy only |
| `CLAUDE.md:215` | yes |
| `docs/verification.md:170-191` | partly — the check runs to about 193 |
| `skills/planning/references/pack-format.md` §6, §1 Lifecycle | yes |
| `skills/review-pr/SKILL.md:86` | yes |
| `skills/planning/references/templates/prd.md:54-60` | yes |
| `skills/planning/references/templates/cold-read.md` Questions header | yes |
| `docs/plans/planning-redesign` has 7 or more slices | yes |

## Round 3 — 2026-11-24

Reader: Haiku (Agent tool, model: haiku, Explore), in a detached worktree of `origin/main`
(`52fa634`) with the pack copied in. It thought through Slice 5. It checked 26 citations: 22 held,
2 partly, and 2 did not hold, both as expected (`tree.md` and `roles/` do not exist before Slice 1).
It found no code. No author findings in Phase 2. The guard held. No question was marked blocking,
and no contradiction set two mandatory items or contracts against each other.

### Questions

| Id | Blocking | File | Gap | Resolution |
|---|---|---|---|---|
| Q1 | n | `prd.md` S-06.2 | Whether "every proposal of the run" spans runs | Adopted: this run's proposals; earlier runs' stay in their rounds (`design.md` §2 Record, pre-mortem P6) |
| Q2 | n | `design.md` §2 Record | Role for `P` and `A` items | Adopted: a `P` item takes its role's value, an `A` item `author` |
| Q3 | n | `design.md` §2 Record | Role values were not mapped to cards and letters | Adopted: the mapping is in the Record row |
| Q4 | n | `plan.md` Slice 5 | `### Panel without a reader` had no slice acceptance | Adopted: local criterion 5.2 |
| Q5 | n | `plan.md` Slice 5 | Id of a proposed checklist line | Adopted: proposed text with the card's next free Id |
| Q6 | n | `plan.md` Slice 5 Verify | No check for the blocked Result line | Adopted: a grep for `({total} rounds, {n} in this run)`. The `.hivrr.json` point stands as round 1 Q7 settled it |
| Q7 | n | `plan.md` Slice 5 Outcome | `author` and `reader` name no checklist | Adopted: the Outcome now says every item has a Role, which may be `author` or `reader` |
| Q8 | n | `plan.md` Slice 5 dry runs | The seeded fixture must be rebuilt, and may not raise such items | The pack stands: the dry run falls back to desk checks, and fixtures are rebuilt per slice (`design.md` §6) |
| Q9 | n | `plan.md` Slice 5 | No line budget for Slice 5 | Adopted: the Suggested path moves Result text to a reference if the skill nears 400 lines |
| Q10 | n | `prd.md` S-06.4 | Whether `{N}` is the total or this run's | Adopted: `{N}` is the round number, which equals `{total}` |
| Q11 | n | `design.md`, `plan.md` mermaid fences | Whether mermaid counts as code | The pack stands: `pack-format.md` §6 allows `mermaid` for diagrams |

### Contradictions

| Item | Resolution |
|---|---|
| C1: Slice 5 Outcome against S-06.1's `author` and `reader` | `plan.md` changed (Q7) |
| C2: Role values against card letters and file names | `design.md` changed (Q3) |
| C3: S-06.2 against pre-mortem P6 | `design.md` P6 changed (Q1) |
| C4: S-04.3 "as today" against the Panel pass row | Not blocking: the item stays blocking in both. `design.md` Panel pass now says only a reader round's item stops further rounds |
| C5: Traceability had S-02.4 in Slice 1 only, while Slice 3 proves S-02.4.e2 | `plan.md` changed: S-02.4 is split, fact side in Slice 1 and trust side in Slice 3, and the table lists both |
| C6: `### Panel without a reader` in the contract with no slice acceptance | `plan.md` changed (Q4) |

### Citations checked

| Citation | Holds |
|---|---|
| `skills/cold-read/SKILL.md:350`, `:352` | yes |
| `skills/cold-read/SKILL.md:343-358` | partly — now cited as `:343-356` |
| `skills/cold-read/SKILL.md` 397 lines, 7 phases | yes |
| `skills/cold-read/SKILL.md:252-269`, `:273-285`, `:293` | yes |
| `skills/cold-read/SKILL.md:145-147`, `:153-155`, `:179`, `:188`, `:193-194`, `:202-246` | yes |
| `skills/planning/SKILL.md:64`, `:285-306` | yes |
| `skills/planning/references/templates/cold-read.md` Questions header | yes |
| `skills/planning/references/pack-format.md:29`, §6 | yes |
| `skills/planning/references/pack-format.md:203` | partly — it is the `reviewed` row, which is what `context.md` §2 uses it for |
| `docs/verification.md:170-191` | yes |
| `CLAUDE.md:215` | yes |
| `.claude-plugin/marketplace.json:51-58` | yes |
| `skills/slice/SKILL.md:232`, `:239`, `:278` | yes |
| `skills/core/SKILL.md:117-137` | yes |
| `skills/planning/references/templates/prd.md:54-60` | yes |
| `skills/review-pr/SKILL.md:86`, `skills/spec/SKILL.md:267` | yes |
| commits `bb1c2b1`, `4830e81` | yes |
| `skills/cold-read/references/tree.md`, `skills/planning/references/roles/` | no — expected, created by Slice 1 |
| `.hivrr.json` gitignored (`.gitignore:10`) | yes |

## Result

Pass after 3 rounds.

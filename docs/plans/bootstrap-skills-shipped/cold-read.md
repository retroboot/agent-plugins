# Cold read

| | |
|---|---|
| **Model** | Haiku (Agent tool, model: haiku, Explore) |
| **Input** | Pack path and repository read access only; no conversation context |
| **Rounds** | 2 |
| **Result** | pass |

## Round 1 — 2026-11-25

Reader a: Haiku (Agent tool, model: haiku, Explore), thought through Slice 1. It spot-checked 24
citations: 21 hold, 3 partly (`skills/core/SKILL.md:76-79`, `skills/planning/references/publish.md:189-192`,
`skills/wave/SKILL.md:18-21`, each with the claim holding and the range loose). It found no code in
any fence.

Panel before the reader: Editor Sonnet (Agent tool, model: sonnet, Explore) — 3 findings (0
blocking); Fact-checker Sonnet — 3 (0 blocking); Test engineer Sonnet — 5 (1 blocking); Trust
reviewer Opus (Agent tool, model: opus, Explore) — 5 (0 blocking). Re-check 1: Editor and Test
engineer — 9 findings (0 blocking) | checked 1 (PV1), held 0.

### Questions

| Id | Blocking | Role | File | Gap | Resolution |
|---|---|---|---|---|---|
| PV1 | y | test | `README.md` Verify, 1.4.e4 | No dry run could fail if check 15 wrongly scanned unnumbered `Load the` sentences: the one at `skills/planning/SKILL.md:183` names a skill `planner` ships (V6) | Fixed before the reader: an unnumbered `debug` sentence dry run (expected 0) and its numbered control (expected 1). Checked by re-check 1 |
| PV2 | n | test | `README.md` Verify, 1.1.e6 | The comparison and the `d05a4ab` baseline had no command lines (V1, V2) | Fixed: both are commands with expected output, the comparison guarded by `command -v jq` |
| PV3 | n | test | `README.md` dry runs | `git checkout -q -- .` ran in the real checkout if `cd` failed (V1) | Fixed: each revert sits inside the `cd … &&` chain |
| PV4 | n | test | `README.md` C1, C3 | Table row 15 and the shared-setup README rows had no check (V6) | Fixed: `grep -c '^\| 15 \|'` and three row counts |
| PV5 | n | test | `README.md` Verify, 1.5 | Phrase greps pass on a paraphrase (V5, V6) | Fixed: Verify says to read the cited sentences too |
| PE1 to PE3 | n | editor | `README.md` 1.1.e1, e2, Stop conditions; `context.md` §5 | Pre-fix wording in post-fix rows; Stop condition scope; `{skill}` used twice | Fixed in place |
| PF1 | n | fact | `context.md` §1 | A 2026-11-14 developer ruling (#221) that skills resolve by name across installed plugins went unmentioned (F4) | Fixed: `context.md` §1 cites `docs/plans/planning-redesign/progress/slice-04.md:98-100` |
| PF2, PF3 | n | fact | `context.md` §2.4, §3 | Quoted "has no `core`" short; pathspec rule cited at line 78, not 76-79 (F1) | Fixed |
| PT1 to PT5 | n | trust | ADR-001, ADR-002, `README.md` | Plugin-manager behaviour unverified; `audit` inherits `init`'s prompt, settings write and `gh` calls; issue owner; baseline worktree cleanup | PT2: C2 now states `audit` meets `init`'s outcomes unchanged. PT5: fixed with PV2. PT1, PT3: stand, as the Brief's claims in **Open questions**. PT4: stands, Publish fills the issue |
| Re-check PE1 to PE5, PV1 to PV4 | n | editor, test | `README.md`, `context.md` | Leftover pre-fix glossary rows; Stop condition count; 1.3.e1 Given; pack README missing from Files; 1.1.e5 cannot fail on the real tree; Suggested path step 2 had no runnable form; 1.6.e2 order | Fixed, except re-check PE4 (rules 3, 4 and 7 name `plan.md`, the PRD and the design, which a size S pack lacks): stands, the rules are the template's, copied verbatim (`pack-format.md` §3, item 7) |
| aQ1 | y | editor | `context.md` §4, first `bash` fence | A `bash` fence outside any Verify heading | Fixed: the command is now inline prose in §4, and Verify carries it. Checklist line proposed for editor: **E7** Every `bash` or `sh` fence in the pack sits under a Verify heading; a command elsewhere is inline prose or moves to Verify |
| aQ2 | y | editor | `context.md` §4, comparison fence | Same as aQ1, for the `GAP` comparison | Fixed: the comparison is the first command of the README Slice's Verify; §4 describes it and gives its expected output. Every reference now points there (README Acceptance intro, Stop conditions, Suggested path step 1). Asks what aQ1 proposed |
| aQ3 | y | reader | `README.md` C2; ADR-002; `skills/spec/SKILL.md:34` and the other three | Once `init` loads, its Phase 6 commit seems to break the four skills' "Do not stage or commit" rule | Re-classed author-fixable, not developer-only: the rule concerns the pack folder, and `init`'s commit names only `.gitignore` and the config paths (`skills/init/SKILL.md:415-426`); `planning` already loads `init` under the same rule (`skills/planning/SKILL.md:42`). C2 now says so and says to leave the rules unchanged |
| aQ4, aQ5 | n | reader | `README.md` C2 | The `init` and `session` purpose text and the lead-in wording are elided | Default adopted: C2 now names the lead-in `Run in order before Phase 1:` (`skills/planning/SKILL.md:48`) and steps copied from `skills/work-issue/SKILL.md:19-20` |
| aQ6 to aQ8 | n | reader | `README.md` Suggested path step 6 | Replacement wording for `config.md`, `git-hygiene.md` and `init/SKILL.md:433-434` | Defaults adopted in step 6 |
| aQ9 | n | reader | `README.md` C3 | Where check 15 and row 15 go | Default adopted: at the end of the fence after check 14, row 15 after row 14 |
| aQ10 | n | reader | `README.md` C3 | A missing `SKILL.md` | Stands: C3 leaves it to check 2 |
| aQ11, aQ12 | n | reader | README header, Retro | No issue number yet; what the Retro holds | Stands: Publish fills `Issue:`; the Retro rule is the template's |
| aQ13 | n | trust | ADR-002 | A provider prompt inside `audit` | Stands: C2 says `init` runs unchanged, prompt included (PT2). Checklist line proposed for trust-reviewer: **T7** For every skill a slice newly makes load another, list the outside inputs the loaded skill brings and say which the slice accepts unchanged |
| aQ14, aQ15 | n | reader | `CLAUDE.md:138`; ADR-001 | Wording of the shared-setup sentence; duplicate installs | Stand: 1.5.e3 and ADR-001 Consequences |

### Contradictions

| Item | Resolution |
|---|---|
| aC1 (reader): `context.md` §1 states install scope as fact; README **Open questions** calls it unverified | `context.md` §1 now marks it the Brief's claim |
| aC2 (reader): the Failure note states the silent skip as fact; `context.md` §4 says it cannot be shown | The Failure note now says the pack takes it as the Brief does, unverified |
| aC3 (reader): `context.md` §1 treats cross-plugin resolution as settled; ADR-001 says duplicate resolution is not | `context.md` §1 now says the #221 ruling settles lookup by name, not which copy of a twice-shipped skill loads |
| aC4 (reader): the four skills' "Do not stage or commit" against `init`'s Phase 6 commit | Same as aQ3 |
| aC5 (editor): C2 "documents nothing new" against ADR-002 recording a new effect | C2 now says it changes no `init` text and ADR-002 records the effect. Asks what E1 already holds |
| aC6 (reader): 1.1.e5 named `:183` while the dry run edits `skills/spec/SKILL.md` | 1.1.e5 now names the dry run's file |

### Citations checked

| Citation | Holds |
|---|---|
| a `skills/audit/SKILL.md:20-23` | yes |
| a `.claude-plugin/marketplace.json:17`, `:37-43`, `:51-59` | yes |
| a `skills/work-issue/SKILL.md:16-21` | yes |
| a `skills/planning/SKILL.md:46-51`, `:183` | yes |
| a `skills/ship-pr/SKILL.md:57` | yes |
| a the six gaps | yes |
| a `skills/init/SKILL.md:425-434` | yes |
| a `skills/init/references/git-hygiene.md:64-72` | yes |
| a `skills/init/references/config.md:344-352` | yes |
| a `docs/verification.md:18-194`, `:61-76`, `:95-102`, `:200-215`, `:228-239`, `:277` | yes |
| a `CLAUDE.md:111`, `:118`, `:125`, `:138`, `:221` | yes |
| a `README.md:21`, `:42-50`, `:52-62`, `:177` | yes |
| a `skills/core/SKILL.md:76-79` | partly |
| a `skills/planning/references/publish.md:189-192` | partly |
| a `skills/wave/SKILL.md:18-21` | partly |
| a `.gitignore:10` | yes |
| a `docs/plans/planning-redesign/progress/slice-04.md:98-100` | yes |
| a `RELEASE-NOTES.md:24-28`, `d05a4ab` | yes |

## Round 2 — 2026-11-25

Reader a: Haiku (Agent tool, model: haiku, Explore), thought through Slice 1. It spot-checked 25
citations: 22 hold, 3 partly (`skills/core/SKILL.md:76-79`, `skills/wave/SKILL.md:18-21` and
`docs/plans/move-to-retroboot/decisions/ADR-002-full-rename-clean-cut.md:28-32`, each with the claim
holding and the range loose). It found no code: the pack's two fences are `bash`, both under
`### Verify`. It ran the comparison (six `GAP` lines) and the structural checks (pass).

Editor pass on round 1's diff before the reader: Editor Sonnet (Agent tool, model: sonnet, Explore)
— 7 findings (0 blocking). PE1, PE2, PE5 and PE6 fixed (glossary install-scope row, stale "choice
open" sentence, the `jq`-guard prose, check 8's count drift during Suggested path step 2). PE3 and
PE7 (ADR wording looser than C2) stand, as accepted ADRs are not edited; C2 now says it is their
exact form. PE4 (ADR-003 points at `context.md` §4) stands, as the ADR records where the comparison
was when it was written.

### Questions

| Id | Blocking | Role | File | Gap | Resolution |
|---|---|---|---|---|---|
| aQ1 | n | reader | `README.md` C3 | No output named for check 15 when `jq` is missing | Stands: the loader merges stderr into its report and exits 1 on any line (`docs/verification.md:277`), so a missing `jq` fails the run |
| aQ2 | n | reader | `README.md` Suggested path step 6 | The reason given for keeping `init`'s inline rule stops being true after ADR-001 (also aK1) | Default adopted: the reason is now that `init` runs before any `core` load and keeps the rule in its own file |
| aQ3 | n | reader | `README.md` C2 | Whether the lead-in changes from `Run before Phase 1:` | Stands: C2 gives the lead-in, `Run in order before Phase 1:` |
| aQ4 | n | reader | `README.md` C1 | `auditor` skill order differs from `marketplace.json:38-42` (also aK5) | Fixed: C1 keeps the five `audit` skills in their current order after `init`, `session`, `core` |
| aQ5 | n | reader | README header; rules 1, 7 | No issue yet (also aK3) | Stands: Publish creates the issue and fills `Issue:` before execution |
| aQ6 | n | reader | `README.md` Verify; ADR-003 | `^[0-9]*\.` against ADR-003's `^[0-9]+\.` (also aK2) | Fixed: the three Verify `sed` patterns read `^[0-9][0-9]*\.`, one or more digits |
| aQ7 | n | reader | `README.md` Verify | The comparison's comment listed 1.1.e7 among the `d05a4ab` outputs (also aK6) | Fixed: the comment separates the post-fix and pre-fix expectations |
| aQ8 | n | reader | `README.md` 1.4 | `Load the` lines inside a `SKILL.md`'s own fences | Stands: ADR-003 scans every numbered line, and none sits in a fence today |
| aQ9 | n | reader | ADR-002; `README.md` Stop conditions | `audit` has no "do not commit" rule and now runs `init` | Stands: ADR-002 accepts it, and C2 states it |

### Contradictions

| Item | Resolution |
|---|---|
| aK1 (reader): Suggested path step 6's reason against ADR-001 | Same as aQ2 |
| aK2 (editor): ADR-003's `[0-9]+` against Verify's `[0-9]*` | Same as aQ6. Asks what E1 already holds |
| aK3 (reader): Status `sliced` with no issue against rules 1 and 7 | Same as aQ5 |
| aK4 (editor): ADR-002 "same wording" against C2's lead-in | Stands: C2 says it is ADR-002's exact form (round 2 Editor pass, PE3) |
| aK5 (reader): C1 `auditor` order against `marketplace.json:38-42` | Same as aQ4 |
| aK6 (reader): the Verify comment against 1.1.e6 and 1.1.e7 | Same as aQ7 |

### Citations checked

| Citation | Holds |
|---|---|
| a `.claude-plugin/marketplace.json:16-29`, `:37-43`, `:51-59` | yes |
| a `skills/audit/SKILL.md:20-23` | yes |
| a `skills/work-issue/SKILL.md:16-21` | yes |
| a `skills/planning/SKILL.md:42`, `:46-51`, `:48`, `:183` | yes |
| a `skills/ship-pr/SKILL.md:57` | yes |
| a `docs/verification.md:18-194`, `:61-76`, `:95-102`, `:200-215`, `:277` | yes |
| a `CLAUDE.md:118`, `:125`, `:138`, `:221` | yes |
| a `README.md:21`, `:31`, `:42-50`, `:52-62`, `:177` | yes |
| a `skills/init/references/git-hygiene.md:64-72` | yes |
| a `skills/init/SKILL.md:425-434` | yes |
| a `skills/init/references/config.md:344-352` | yes |
| a `skills/spec/SKILL.md:34`, `skills/slice/SKILL.md:36`, `skills/cold-read/SKILL.md:38`, `skills/brainstorm/SKILL.md:235` | yes |
| a `skills/core/SKILL.md:76-79` | partly |
| a `skills/wave/SKILL.md:18-21` | partly |
| a `.gitignore:10` | yes |
| a `docs/plans/move-to-retroboot/decisions/ADR-002-full-rename-clean-cut.md:28-32` | partly |
| a `RELEASE-NOTES.md:24-28`, `docs/plans/move-to-retroboot/design.md:411` | yes |
| a `d05a4ab` | yes |

## Result

Pass after 2 round(s) (2 in this run).

### Checklist proposals

- aQ1 → editor.md: **E7** Every `bash` or `sh` fence in the pack sits under a Verify heading; a command elsewhere is inline prose or moves to Verify
- aQ13 → trust-reviewer.md: **T7** For every skill a slice newly makes load another, list the outside inputs the loaded skill brings and say which the slice accepts unchanged

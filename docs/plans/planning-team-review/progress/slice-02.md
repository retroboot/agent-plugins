# Slice 2 — Editor and the re-check loop

| | |
|---|---|
| **Status** | done |
| **Issue** | #260 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (`claude-opus-5-5`) |
| **Date** | 2026-11-24 |

## Preflight

Checked on branch `issue/260`, forked from `origin/main` at `fe68e2a` (Slice 1 merged).

| Citation | Holds |
|---|---|
| `skills/cold-read/SKILL.md:293`, the restatement rule (Pattern to follow) | moved: now `:260-262` under Phase 5 **Fix the pack**, reading the same (plan.md line-drift note) |
| cold-read Phase 5 "run the Phase 2 checks again" (Acceptance 2.2) | yes, `:277` before this slice |
| `skills/planning/references/roles/fact-checker.md`, the card shape | yes |
| `skills/cold-read/references/panel.md` holds the Panel pass only | partly: Slice 1 also wrote **Recording panel findings** and **No reader runs**; this slice adds **Re-check** beside them |
| `skills/planning/references/roles/dispatch.md` **Prompt frame**, an extra input as a line after Pack | yes |
| `design.md` §2 Re-check row; §4 Panel finding state machine | yes |

## Acceptance

| ID | How it was shown |
|---|---|
| S-01.2 (Editor side) | Both Editor prompts were built by `dispatch.md` **Prompt frame** from `editor.md` verbatim, `{tree}` and `{path}`; the re-check prompts added exactly one line, `Diff: {diff}`, after the Pack line |
| S-01.2.e1 | The first Editor prompt held the frame text, `Repository: /tmp/cold-read.iXqM83`, `Pack: …/docs/plans/zz-dryrun-seeded`, the card (job, checklist E1–E6, output, blocking test) and the report sections; nothing else. The frame's fixed lines are part of the card-only prompt `design.md` §2 **Dispatch** defines, not "else" (Slice 1 reader question Q9) |
| S-01.2.e2 | Before re-check 1 the Facilitator had changed the group size in `design.md`. The Editor's re-check prompt did not mention it; the change reached the Editor only as `diff1.txt`, and its E2 row quoted the changed line from that file |
| S-03.1 | `panel.md` **Re-check**: the Editor is dispatched on every re-check with `{diff}`; after a reader round, "the Editor alone checks that round's `{diff}` before the next reader" |
| S-03.1.e1 | The Facilitator fixed seed D4 in `design.md` only (Grouping "at most 3" → "at most 4"), leaving the prd criteria, `plan.md` Slice 4 and ADR-003 at 3. Re-check 1's Editor reported PE1 (blocking, E2): the changed line from the diff and every restatement left at 3, `prd.md:178`, `:181`, `design.md:40`, `:144`, ADR-003 lines 1, 18 and 22, `plan.md:372`. After the fix was completed, re-check 2's Editor searched again and found none left (its E2 evidence) |
| S-03.2 | `panel.md` **Who is dispatched**: the Editor plus each role whose finding a fix answered; a role with no fixed finding is not dispatched |
| S-03.2.e1 | Re-check 1, after fixes for `PF3` and `PE1`, dispatched the Fact-checker and the Editor. Re-check 2, after a fix answering only Editor finding PE1, dispatched the Editor alone; the Fact-checker was not dispatched. Test engineer and Trust reviewer have no cards until Slice 3; the rule that excludes them is the same sentence |
| S-03.3 | `panel.md:51-58`: at most two re-checks before the first reader; no fix after the second; a fixed finding it reports again is held, a new one stays open; both count as Blocking, and the readers are dispatched anyway |
| S-03.3.e1 (desk) | After re-check 2 the cap is reached. `panel.md:54-58`: "**Make no fix after the second re-check** … a fixed finding it reports again is **held** (fixed → held), and a new blocking finding it reports stays open, unfixed. Both count as Blocking for the round, the readers are dispatched anyway, and Phase 5 fixes them after the round." So re-check 2's blocking findings, renumbered by `panel.md` **Ids**, PE5 (D5), PE2 (D8), PE6 (D9) and PE3 (D6), stay open with new PE12 (Slice 3's missing dependency on Slice 2), all Blocking, and the readers are dispatched; no third re-check is reachable |
| 2.1 | `awk` over `editor.md` printed `Letter\|Model\|Job\|Inputs\|Checklist\|Output\|Blocking test\|`; letter `E`; Inputs list `{diff}` on a re-check; `**E1**`–`**E6**`, one per Editor seed |
| 2.2 | cold-read Phase 5 now takes the snapshot at the top of **Fix the pack**; after the fixes it runs "the Phase 2 Fences and Plan checks again; expected no output. The whole panel never runs again: the Editor alone checks this round's diff in **Next round, or stop**", whose second bullet goes back to Phase 3 "after the Editor pass on this round's diff" |
| 2.3 | Seeded fixture, 3 editor seeds: the Editor's first pass reported all 3. D4 as PE1 (`prd.md:255` "at most 4" against five places at 3), D5 as PE5 (Slice 1 Contracts name the template, Files omit it), D6 as PE3 (Slice 2 uses `readers.md` from Slice 4) |

### Verify output

```text
eval "$(jq -r .verify.test .hivrr.json)"   -> structural checks pass
wc -l < skills/cold-read/SKILL.md          -> 366
grep -c '^## Phase' skills/cold-read/SKILL.md -> 7
awk … editor.md                            -> Letter|Model|Job|Inputs|Checklist|Output|Blocking test|
grep … | sort | uniq -d                    -> (no output)
ls docs/plans | grep zz-dryrun             -> (no output)
```

### Seeded dry run

The fixture was rebuilt with Slice 1's ten seeds D1–D10 (`progress/slice-01.md`, Seeded dry run),
Status `sliced`, no `cold-read.md` or `progress/`. Author Checks printed nothing. Then, following
this branch's skills:

| Pass | Roles (all `Sonnet (Agent tool, model: sonnet, Explore)`) | Guard | Result |
|---|---|---|---|
| Panel pass | Fact-checker and Editor, one message | held | Fact-checker 10 findings (D1, D2, D3, D6, D8, D9 among them); Editor 11 findings (D2, D4, D5, D6, D8, D9) |
| Fixes | PF3 (D1, `:112` → `:86`); PE1 (D4) fixed in `design.md` only, on purpose | — | snapshot taken first; `diff1.txt` written |
| Re-check 1 | Fact-checker (PF3 fixed) and Editor with `{diff}` | held | PF3 not reported again: checked. Editor PE1: the restatements the fix left (S-03.1.e1) |
| Fixes | the group size restored to 3 in `design.md` and `prd.md` | — | new snapshot; `diff2.txt` written |
| Re-check 2 | Editor only, with `{diff}` | held | no restatement left at 4: checked. Cap reached; remaining blocking findings held |

Together the two roles found 8 of the 10 seeds, all but D7 (a test seed) and D10 (a trust seed). The fixture, both trees and both snapshots were removed before this commit.

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Dry run: fix one fact and one editor finding, then read the re-check dispatch | Did that, and ran a second re-check fixing only an Editor finding | The first re-check could not show a role being left out (both fixed roles were sent); the second shows the Fact-checker not dispatched | n |
| The editor fix in the dry run | Made incomplete on purpose (one file of seven) | S-03.1.e1 needs a fix that leaves restatements behind | n |
| Files: `editor.md`, `panel.md`, `SKILL.md` | Also `dispatch.md`, one clause | The PR #265 follow-up review noted "never removes" Phase 2's tree conflicted with `panel.md` step 4; now "removes it only on a void pass" | n |
| `{diff}` beside the snapshot (`panel.md` **Snapshot** as first written) | In the dry run `diff1.txt` and `diff2.txt` were written in the session scratchpad; after PR review, `{diff}` gets a temporary directory of its own and both are removed after the re-check's guard | Outside the checkout and the tree, as the contract requires | n |
| Re-check findings take the next free Id | The roles restarted at `PE1` on each re-check, and this record first reused `PE1`–`PE11` for re-check 2. PR review: the Facilitator now renumbers, a match keeping its earlier Id; the Ids above are renumbered so | The frame tells every role to number from 1 | n |
| `design.md` §4: `open` leaves only to nonblocking, asked or fixed | At the cap, a new blocking finding is not moved to held: it stays open, unfixed, and counts as Blocking; only a reported-again fixed finding is held (fixed → held) | A fix after the last re-check would reach the readers unchecked (PR review); `open → held` is not in §4, so no new transition is used | n |
| The frame: "Read only files under {tree}" | Now "and the input files named above" | The Editor could not read `{diff}`, which lives outside the tree by contract (PR review) | n |

## Decisions

- The snapshot is taken before the first fix of each pass or reader round, and each re-check takes
  its own (Slice 1 reader default Q6).
- A fix that answers only an author or reader item dispatches no role but the Editor.
- After a reader round the Editor pass runs inside Phase 5 **Next round, or stop**, only when another
  round follows, since no reader would see its fixes otherwise.
- Re-check findings are renumbered by the Facilitator: a match keeps its Id, any other takes the next
  free `P{letter}{n}` Id in the run.

## Discoveries

- **For Slice 3's gate.** Fact-checker and Editor together found 8 of 10 seeds; only D7 (a Verify
  with no expected output) and D10 (no failure class) were missed, the Test engineer's and Trust
  reviewer's. The 7-of-10 gate looks safe.
- **For Slice 3.** The Editor found that Slice 3 needs `editor.md` (Slice 2) but declares
  `Depends on: Slice 1` (re-check 2, PE12). The merge order 1, 2, 3, 4, 5 covers it in practice, as
  it covers Slice 4's use of Slice 1's `tree.md` (PE4).
- **For Slice 5.** `panel.md` already writes `### Panel without a reader` into the Result although
  the template only gains that subsection in Slice 5 (5.2) (re-check 2, PE14).
- **For the retro.** Real-pack wording the Editor flagged: the S-01 Rule row in `prd.md` still says
  "card and the tree and pack paths only" after S-01.2's amendment (PE13); ADR-002's "re-check fixes
  with the roles they touch" against design's Editor-only pass after a reader round (PE8); the
  glossary's "all four on every pass" against the re-check (PE15). None blocks a slice.
- The Fact-checker now reports the post-Slice-1 tree as "Slice 1 already built", because the fixture
  is a copy of a pack written before it. Later dry runs should expect that finding.
- Costs: the panel pass took 96 s (Editor) and 159 s (Fact-checker) in parallel; re-check 1, 79 s
  and 213 s; re-check 2, 121 s.

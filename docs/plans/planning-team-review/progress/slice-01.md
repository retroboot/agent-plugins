# Slice 1 — Dispatch contract, Fact-checker and the panel hook

| | |
|---|---|
| **Status** | done |
| **Issue** | #259 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (`claude-opus-5-5`) |
| **Date** | 2026-11-24 |

## Preflight

Checked on branch `issue/259`, forked from `origin/main` at `d774ba5`.

| Citation | Holds |
|---|---|
| `skills/cold-read/SKILL.md` is 397 lines, no `references/` folder (`context.md` §1) | yes |
| `skills/cold-read/SKILL.md:157-200`, Build the reader's tree through the guard | yes |
| `skills/cold-read/SKILL.md:179`, `git worktree add --detach`; `:193-194`, the checksum guard; `:188`, `allowed-tools` | yes |
| `skills/cold-read/SKILL.md:202-246`, the reader prompt and completeness check | yes |
| `skills/cold-read/SKILL.md:132-138`, author findings `A1` … | yes |
| `skills/cold-read/SKILL.md:153-155`, Choose the reader | yes |
| `skills/cold-read/SKILL.md:252-269`, Phase 4 class table | yes |
| `skills/spec/SKILL.md:267`, a skill pointing to a reference | yes |
| `skills/slice/SKILL.md:232`, the Self-check warning about cold-read Phase 2 | yes |
| `skills/planning/references/templates/cold-read.md`, 39 lines | yes |
| `skills/planning/SKILL.md` Phase 6, cited as 285-306 (`context.md` §2) | partly: Phase 6 runs 285-309; the section reads the same (Fact-checker PF7 in the dry run). Not a Contract of this slice |

## Acceptance

| ID | How it was shown |
|---|---|
| S-01.1 | `fact-checker.md` holds job, inputs, model, checklist, output and blocking test. `grep -rhoE '\*\*[FVET][0-9]+\*\*' skills --include=*.md \| sort \| uniq -d` printed nothing: F1–F6 appear only in the card |
| S-01.2 (Fact-checker side) | The prompt sent in the dry run was built by `dispatch.md` **Prompt frame** from the card verbatim, `{tree}` and `{path}`: the frame text, `Repository: /tmp/cold-read.WfuldL`, `Pack: …/docs/plans/zz-dryrun-seeded`, the card, the report sections, and nothing from the conversation. Slice 2 proves S-01.2.e1 and S-01.2.e2 |
| S-01.3 | `dispatch.md` **Model resolution**: dispatched as `Sonnet (Agent tool, model: sonnet, Explore)`, recorded by name in the round summary; the no-override branch records the default model by name or `default model` |
| S-01.3.e1 (desk) | `dispatch.md:18-20`: "When the subagent tool has no model choice, dispatch a fresh subagent on the default model … Record the default model by name if known, else `default model`" |
| S-01.4 | `dispatch.md` **No subagent tool** and `panel.md` step 3 |
| S-01.4.e1 (desk) | `panel.md` step 3 sends the pass to `dispatch.md` **No subagent tool**, which says "the Facilitator works through each card in turn itself … The round summary says `Panel run by the Facilitator: not independent.`" (`dispatch.md:97-99`) |
| S-01.4.e2 (desk) | Phase 2 runs the panel and fixes the pack in this checkout (`panel.md` step 6). Phase 3's **No subagent tool** row then says `No subagent available: …`, records the panel's findings under `### Panel without a reader` (`panel.md` **No reader runs**: "The fixes stay in the pack") and goes to Phase 7, as today. The record step was missing from that row; the desk check found it and it was added (Deviations) |
| S-02.1 (dispatch side) | `panel.md` step 1 lists `roles/` and dispatches every file but `dispatch.md`; step 3 sends them in one message. In the dry run the folder held `dispatch.md` and `fact-checker.md`, and one dispatch was sent. Slice 3 proves it with four cards |
| S-02.2 | The pass read a detached tree of `origin/main` at `/tmp/cold-read.WfuldL` with the fixture copied in, under the checksum guard before and after; the prompt allows only read-only commands or git-ignored writes |
| S-02.2.e1 | No Rust here, so during the pass a git-ignored file, `node_modules/.cache/out.txt` (`.gitignore:1`), was written into the tree in place of `cargo check`. The guard before and after compared equal (`diff` printed `GUARD HOLDS`) with the file present |
| S-02.2.e2 (desk) | `panel.md` step 4: "A difference voids the pass: say which files changed, remove the tree, and go to Phase 7 with `COLD READ STOPPED`"; `dispatch.md:63-65` says the same; Phase 7's STOPPED bullet now names "a void round or panel pass". An edited `plan.md` in the tree changes its `cksum` line, so the two guard outputs differ |
| S-02.3 | Every panel finding was triaged with the cold read's blocking test and recorded in the round's Questions table as `PF1`–`PF8` (record below). PF1 was re-classed blocking with its reason in the Resolution, as **Triage** allows |
| S-02.4 (fact side) | PF1, PF4 and PF5 (blocking) and PF3 were fixed before the reader; the reader's tree held the fixes, and the fixed items do not count toward the round's blocking total. PF2, held, counts |
| S-02.4.e1 | PF1 (a wrong line count, the fixture's stand-in for `live3.json`) recorded as `PF1`, fixed before the reader, not counted as blocking in the Result |
| S-02.4.e2 (held path, `PF` in place of `PT`) | PF2 deferred by the developer (simulated, as Verify says): recorded `y, developer-only, held`, counted among the 6 blocking, and the run ended `COLD READ BLOCKED` after round 1 with the readers still dispatched |
| 1.1 | `dispatch.md` has one `##` section per row of the Dispatch table: Model resolution, Prompt frame, Tree and guard, Output contract, Completeness check, Triage, No subagent tool (each `grep -c` printed 1) |
| 1.2 | `awk` over the card's `## ` headings printed `Letter\|Model\|Job\|Inputs\|Checklist\|Output\|Blocking test\|`; letter `F`; `**F1**`–`**F6**`, one per Fact-checker seed, each naming its evidence |
| 1.3 | Phase 2 ends with `### Review panel`, one line pointing to `references/panel.md`. Lines 157-200 moved to `references/tree.md`: `diff` of `origin/main` lines 157-200 against the file body printed `identical`. `grep -c '^## Phase'` printed 7; `wc -l` printed 363 (360 before the PR review fixes) |
| 1.4 | Seeded fixture, 3 fact defects (D1–D3 below): the Fact-checker reported all 3 with evidence, PF3 (`sed -n 112p` printed nothing), PF1 (`wc -l` printed 397), PF2 (`ls` printed `No such file or directory`) |

### Verify output

```text
eval "$(jq -r .verify.test .hivrr.json)"   -> structural checks pass
wc -l < skills/cold-read/SKILL.md          -> 363
grep -c '^## Phase' skills/cold-read/SKILL.md -> 7
awk … fact-checker.md                      -> Letter|Model|Job|Inputs|Checklist|Output|Blocking test|
grep … | sort | uniq -d                    -> (no output)
ls docs/plans | grep zz-dryrun             -> (no output)
```

### Seeded dry run

The fixture `docs/plans/zz-dryrun-seeded` was a copy of this pack with Status `sliced`, Issues
`none yet`, no `cold-read.md`, and these 10 seeds, listed before the run:

| Seed | Kind | Place | Defect | Found by |
|---|---|---|---|---|
| D1 | fact | `context.md` §3 | `review-pr/SKILL.md:86` changed to `:112`, a blank line | Fact-checker PF3 |
| D2 | fact | `context.md` §1 | cold-read "397 lines today" changed to "352" | Fact-checker PF1 |
| D3 | fact | `context.md` §3 | `templates/prd.md:54-60` changed to `templates/assumptions.md:54-60` | Fact-checker PF2; reader Q12 |
| D4 | editor | `prd.md` Rules, S-05 | "at most 3 per reader" changed to 4 | reader C4 |
| D5 | editor | `plan.md` Slice 1 | Contracts name `templates/cold-read.md`; its Files line removed | not found |
| D6 | editor | `plan.md` Slice 2 Contracts | uses `readers.md`, which Slice 4 creates | Fact-checker PF5 |
| D7 | test | `plan.md` Slice 2 Verify | `grep -c '^- \*\*E' …` with no expected output | reader Q7, C9 |
| D8 | test | `plan.md` Slice 4 Verify | `test -f …/grouping.md` expects `ok`; no slice creates it | Fact-checker PF4 |
| D9 | trust | `plan.md` Slice 5 Outcome | upload to `https://metrics.example.com/api/rounds` with an API token: no key source | Fact-checker PF6; reader Q4 |
| D10 | trust | the same upload | no failure class | reader Q4 |

Run, following this branch's `skills/cold-read/SKILL.md`: Phase 1 (Read mode, 5 slices, 0 earlier
rounds); Phase 2 Author Checks (fence, Headings and Trace: no output); **Review panel** (one card,
one tree, guard held, report complete: both sections, F1–F6 all done, every blocking finding with
evidence); triage and fixes; round 1 with a Haiku reader on Slices 1 and 2 (complete report, 26
citations, guard held); classify; round written; Result `COLD READ BLOCKED: 6 blocking question(s)
left after round 1`. The fixture was deleted before this commit. The round as recorded:

| Id | Blocking | Gap | Resolution |
|---|---|---|---|
| PF1 | y (re-classed from n: every slice's 400-line Verify rests on it) | F6: 352 lines stated, 397 real | Fixed before the reader |
| PF2 | y, developer-only, held | F1, F2: `assumptions.md` does not exist | Deferred by the developer |
| PF3 | n | F1: `:112` blank, line is 86 | Fixed before the reader |
| PF4 | y | F2: `grouping.md` made by no slice | Fixed before the reader |
| PF5 | y | F2: Slice 2 uses `readers.md` from Slice 4 | Fixed before the reader |
| PF6 | y, developer-only, held | F2: metrics upload no file names | Deferred by the developer |
| PF7 | n | F1: Phase 6 runs to 309 | Adopted |
| PF8 | n | F4: model override settled only by the pack's measurement | Stands |

Summary line written: `Panel: Fact-checker Sonnet (Agent tool, model: sonnet, Explore) — 8 findings
(3 blocking); after triage 4 blocking, fixed 5, held 2`. Those counts were wrong; the table gives
8 findings (4 blocking as reported, PF2, PF4, PF5 and PF6), 5 blocking after triage (PF1 added),
4 fixed before the reader (PF1, PF3, PF4, PF5) and 2 held (PF2, PF6). PR review round 1 caught it.

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Move lines 157-200 to `tree.md` unchanged | Moved byte-for-byte, under a `# Reader tree and guard` heading and a two-line note naming its users | A reference file needs a title; the procedure is unchanged | n |
| Suggested path 5: Phase 4's class table covers `P` items | Done, and Phase 3's **No subagent tool** row also points to `panel.md` **No reader runs**; Phase 7's STOPPED bullet names a void panel pass | Desk check S-01.4.e2 showed the row went to Phase 7 without recording the panel's findings | n |
| Prompt frame as sent in the dry run | After the run, the frame's fill-in list names `{letter}` and drops "with the letter on your card" | The Facilitator had to fill `P{letter}` without the frame naming it | n |
| Seeded fixture is a copy of this pack | Its `cold-read.md` was removed and Issues set to `none yet`, so it read as a sliced pack | A sliced pack has no cold read yet; the reader flagged the leftovers (C1, C3) as fixture artifacts | n |
| `context.md` §2 cites `skills/planning/SKILL.md` 285-306 | Phase 6 runs 285-309 | Drift since `52fa634`; the section reads the same | n |

## Decisions

- The panel builds its own tree in every mode, including Record only, where Phase 2's tree is kept
  for reader `a` (`dispatch.md` **Tree and guard**).
- A developer-only panel finding is held and asked in Phase 5, as a developer-only author finding is,
  until Slice 3 adds the pre-reader batch; the readers are still dispatched.
- The Facilitator played the developer's deferral of PF2 in the dry run, as Slice 1 Verify asks.
- Panel `P` Ids number per run (reader default Q8).

## Discoveries

- **For Slice 3's gate.** The Fact-checker alone found 6 of the 10 seeds (D1–D3, D6, D8, D9),
  reaching editor, test and trust seeds through F2 "show that it exists". The reader found D4, D7
  and D10. Nobody found D5 (a Contracts file missing from Files): that is the Editor's. Reuse the
  seed table above for Slice 3's fixture so the 7-of-10 count is comparable.
- **For Slice 2.** The reader asked when the `{diff}` snapshot is taken (Q6); its default was a copy
  into `mktemp -d` before the first fix of each pass. It also read prd S-01.2.e1's "nothing else"
  against the frame's fixed lines (Q9, C10); Slice 2 proves e1 and should state that the frame text
  is not "else".
- **For Slice 3.** The reader saw prd S-04.3 ("as … does today") and the design's Panel pass
  (readers still dispatched after a deferred pre-reader item) as a contradiction (C5).
- **For Slice 4.** The reader found that design's "touched" (a slice's section or Files list)
  differs from prd S-05.2's "files", and that a fix to `prd.md` or `design.md` alone touches no
  slice (Q15, C7). Slice 4's Verify hard-codes `origin/main` (Q13).
- Costs: the Fact-checker pass took 132 s and about 99k tokens over 16 tool calls; the reader 213 s
  and about 122k tokens.

# Slice 3 — Test engineer, Trust reviewer and one decision batch

| | |
|---|---|
| **Status** | done |
| **Issue** | #261 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (`claude-opus-5-5`) |
| **Date** | 2026-11-24 |

## Preflight

Checked on branch `issue/261`, forked from `origin/main` at `60d16ff` (Slices 1 and 2 merged).

| Citation | Holds |
|---|---|
| cold-read Phase 5 **Developer-only first**, "asked at once, before any fix and before any further round" (Contracts) | yes, `skills/cold-read/SKILL.md:240-252` |
| `design.md` §2 **Developer batch** and **Sibling scan** rows; the Role card `{seed}` input and `## Questionnaire` | yes |
| `skills/planning/references/roles/fact-checker.md`, the card shape | yes |
| `skills/cold-read/references/panel.md` Panel pass step 6, "a developer-only finding is held … asked in Phase 5" | yes; replaced by the batch in this slice |
| `dispatch.md` **Completeness check** names the required sections | partly: it named only the two the prompt gives, so a missing Questionnaire would pass; extended (Deviations) |

## Acceptance

| ID | How it was shown |
|---|---|
| S-02.1 (all roles) | `panel.md` step 1 listed `roles/` (dispatch, editor, fact-checker, test-engineer, trust-reviewer) and step 3 sent the four cards in one message, each on its own card and model: Fact-checker, Editor and Test engineer as `Sonnet (Agent tool, model: sonnet, Explore)`, Trust reviewer as `Opus (Agent tool, model: opus, Explore)`. The same message also sent the clean-fixture Trust reviewer |
| S-02.4 (trust side) | PT4 and PT5, deferred in the batch, stay **held** and count as Blocking (`panel.md` **Partial answer**) |
| S-02.4.e2 | The Trust reviewer asked where the upload token comes from (PT1) and four sibling questions. PT4 and PT5 were deferred: held, Blocking, so the round cannot pass |
| S-02.5 | The clean fixture's Trust reviewer returned findings `None.`, a header-only Questionnaire and `No outside inputs.` |
| S-02.5.e1 | As above; the round summary line it maps to is `Trust: no outside inputs.` (`panel.md` **Recording panel findings**) |
| S-04.1 | `panel.md` step 6 and **Developer batch**: every developer-only finding of the pass, blocking Questionnaire rows included, in one message before any fix or reader |
| S-04.1.e1 | One message held all five developer-only items (PT1–PT5). The Fact-checker's PF6, the Editor's PE2 and the Test engineer's PV6 each raised the upload's scope (no criterion, contract or Files entry), the question PT4 asks, so they were merged into PT4 as **Collect** says: the developer saw five items once, not eight |
| S-04.2 | cold-read Phase 5 **Developer-only first** runs the **Sibling scan** and then sends the round's one **Developer batch** (`panel.md` **Collect**) |
| S-04.2.e1 (desk) | The reader round (below) raised no new developer-only item, so no scan ran live. Given a reader asking who runs the operator step: Phase 4 marks it developer-only; Phase 5 runs the **Sibling scan**; `panel.md` **Sibling scan** dispatches the Trust reviewer once with the item in `{seed}`, "before the batch and before any fix", and adds its developer-only findings and blocking rows to that round's batch, recorded in that round. One message results |
| S-04.3 | `panel.md:47-50` **Partial answer** |
| S-04.3.e1 | The developer (played by the executor, as the slice asks) answered PT1–PT3 and deferred PT4 and PT5. The three answers were written into the fixture's Slice 5 Outcome with the date (`diff`: 14 changed lines with the author fixes); PT4 and PT5 stayed **held**. The readers were still dispatched: one `Haiku (Agent tool, model: haiku, Explore)` reader on Slices 1–2 of the post-batch fixture, guard held. It raised Q14 (blocking): build the Slice 5 upload or not, which is PT4's question. Phase 4 marked it blocking; Phase 5 **Developer-only first** and `panel.md` **Collect** make it PT4, already deferred, so it was not asked again and triggered no sibling scan; it stayed **Not answered**, so Phase 5 says "go to Phase 6 without dispatching another round. The run ends `COLD READ BLOCKED`" |
| 3.1 | `awk` printed `Letter\|Model\|Job\|Inputs\|Checklist\|Output\|Blocking test\|` for `test-engineer.md` and `Letter\|Model\|Job\|Inputs\|Checklist\|Output\|Questionnaire\|Blocking test\|` for `trust-reviewer.md`; letters `V` and `T`; `{seed}` in the Trust Inputs; `**V1**`–`**V6**` and `**T1**`–`**T6**`, one per seed |
| 3.2 | The full panel reported **10 of the 10** seeded defects (table below); the gate is 7 |

### Verify output

```text
eval "$(jq -r .verify.test .hivrr.json)"   -> structural checks pass
wc -l < skills/cold-read/SKILL.md          -> 369
grep -c '^## Phase' skills/cold-read/SKILL.md -> 7
awk … test-engineer.md                     -> Letter|Model|Job|Inputs|Checklist|Output|Blocking test|
awk … trust-reviewer.md                    -> Letter|Model|Job|Inputs|Checklist|Output|Questionnaire|Blocking test|
grep … | sort | uniq -d                    -> (no output)
ls docs/plans | grep zz-dryrun             -> (no output)
```

### Seeded dry run

The seeded fixture had Slice 1's ten seeds (`progress/slice-01.md`); the clean fixture was the same
copy unseeded. Author Checks printed nothing on both. Every guard held.

| Seed | Kind | Found by |
|---|---|---|
| D1 `review-pr:112` | fact | Fact-checker PF3 |
| D2 352 lines | fact | Fact-checker PF1; Editor PE5 |
| D3 `assumptions.md` | fact | Fact-checker PF2 |
| D4 at most 4 | editor | Editor PE1 |
| D5 template not in Files | editor | Editor PE3 |
| D6 `readers.md` before Slice 4 | editor | Editor PE4; Fact-checker PF5 |
| D7 Verify with no expected output | test | Test engineer PV3 |
| D8 `grouping.md` | test | Test engineer PV2; Fact-checker PF4; Editor PE7 |
| D9 upload, no key source | trust | Trust reviewer PT1 (the upload itself, not its key source, was also raised by PF6, PE2 and PV6; merged into PT4) |
| D10 upload, no failure class | trust | Trust reviewer PT2 |

Each role found every seed of its own kind. Triage: PT1–PT5 developer-only (one batch); D1–D8
fixed by the author after the batch, behind a snapshot; PV1 (below) fixed with a note; PV4 and PV5
re-classed non-blocking, because README rule 4 lets a criterion be shown by a verification step
recorded in the progress file, which is how those criteria are proven.

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Dry run: full panel through to `COLD READ BLOCKED` | Ran the panel pass, the batch, the answers, the fixes and one reader round to `COLD READ BLOCKED`; skipped the re-check | Re-checks were proven live in Slice 2; here all four roles had a fixed finding, so it would re-send the whole panel. PR review found the reader-round path broken (a deferred item asked again); after the fix it was run live, not desk-checked | n |
| Files: the two cards, `panel.md`, `SKILL.md` | Also `dispatch.md` **Completeness check**: a missing section includes "any the card's **Output** adds" | Without it a Trust report with no Questionnaire would count as complete | n |
| The developer answers the batch | The executor played the developer, as Slice 1 did | The slice's dry run asks for a partial answer on a fixture | n |
| `panel.md` "Ids `P{letter}{n}` as the role gave them" | Now points to **Ids** for re-check and sibling scan findings | The PR #266 follow-up review's leftover | n |

## Decisions

- Duplicate developer-only items from different roles are merged into one batch item listing every
  Id (`panel.md` **Collect**), so the developer answers each question once.
- Each blocking Questionnaire row is a `PT{n}` finding and developer-only by the Trust reviewer's
  blocking test.
- The sibling scan's `{seed}` file lives in a temporary directory of its own, like `{diff}`.
- After a reader round, an unanswered batch item ends the run as today (Phase 6); after a panel
  pass, the readers still run (design Panel pass row).

## Discoveries

- **For the retro: the gate was easy.** With all four roles, every seed was found, most by two or
  three roles. The seeds are coarse; a later fixture with subtler defects would measure more.
- **For the retro: real-pack Verify gap.** The Test engineer found that every slice's first Verify
  line, `eval "$(jq -r .verify.test .hivrr.json)"`, exits 0 with nothing on stdout when
  `.hivrr.json` is missing (PV1). `context.md` §4 says no output is a failure, but the Verify
  blocks state only the expected output, so a careless executor reads it as green.
- **For the retro.** The Test engineer also noted that the `uniq -d` checks pass on empty cards
  (PV4), that the Slice 4 prompt `diff` passes if both markers vanish (PV8), and that the 7-of-10
  gate rests on one model run (PV10).
- **For Slice 5.** The Editor noted that prd S-06.1 allows Role `reader` only, where design and
  Slice 5 add `author` (PE9); same meaning, different wording.
- **Fixed after PR review (#267).** A deferred panel item was re-marked developer-only in the
  reader round and asked again; answering it then let the run continue. Phase 5 and `panel.md`
  **Collect** now never ask a deferred item, and a reader item asking the same thing is that item.
  A re-check's developer-only finding is held for the first reader batch, not a second message.
  Sibling scan findings are triaged and recorded in the round that triggered the scan.
- **Reader round.** The Haiku reader's other blocking question, Q1, was that `origin/main` already
  holds Slices 1 and 2 while the fixture pack's Status says `sliced`: an artifact of copying a
  pack written before them, as Slice 2 recorded for the Fact-checker.
- Costs: Fact-checker 159 s, Editor 87 s, Test engineer 140 s, Trust reviewer 58 s, all in
  parallel, so the pass took about 160 s; the clean Trust reviewer 70 s alongside.

# Slice 4 — Parallel cold readers

| | |
|---|---|
| **Status** | done |
| **Issue** | #262 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (`claude-opus-5-5`) |
| **Date** | 2026-11-24 |

## Preflight

Checked on branch `issue/262`, forked from `origin/main` at `1dfa34a` (Slices 1–3 merged).

| Citation | Holds |
|---|---|
| `skills/cold-read/SKILL.md:145-147`, slice assignment (Pattern to follow) | moved: **Assign slices** is now `:149-151`, reading the same |
| `skills/cold-read/SKILL.md:244-246`, incomplete-report handling (Pattern to follow) | moved: **Check the report** is now `:209-212`, reading the same |
| `design.md` §2 **Parallel readers**: Grouping, Reader dispatch, Merge | yes |
| `skills/cold-read/references/tree.md`, the tree and guard used per reader | yes (Slice 1); this slice depends on it though it declares `Depends on: none` (Slice 2 Discoveries) |
| The reader prompt between `You are about to implement` and `A table: citation` | yes, unchanged on `origin/main` |

## Acceptance

| ID | How it was shown |
|---|---|
| S-05.1 | `readers.md` **Grouping**: the first round of the run reads every slice, in plan order, in groups of at most 3; **Dispatch** sends one new reader per group in one step, each with the Phase 3 prompt and its own `{slices}` |
| S-05.1.e1 | **seven** fixture, round 1: three `Haiku (Agent tool, model: haiku, Explore)` readers in one message, `a` with `Slice 1, Slice 2, Slice 3`, `b` with `Slice 4, Slice 5, Slice 6`, `c` with `Slice 7`, each in its own tree, all built and guarded before dispatch. Every guard held |
| S-05.1.e2 | **small** fixture (size S, README Slice only): one reader `a` with `Slice 1`; complete report, 12 citations; guard held |
| S-05.2 | `readers.md` **Grouping**: a later round reads only the slices whose `## Slice N` section, or a file in whose **Files** list, a fix edited, at most 3 per reader |
| S-05.2.e1 | After round 1, two fixes by hand: one line in Slice 2's section (answering `aQ9`) and one in Slice 6's (answering `bQ2`). The touched set, computed from `diff -ru` of the pack against the snapshot, was Slices 2 and 6: one group, one reader `a` with `Slice 2, Slice 6`; complete report, 17 citations; guard held |
| S-05.3 | `readers.md` **Check each report** (each report on its own, citations never pooled) and **Merge** (`aQ{n}`, `bC{n}`) |
| S-05.3.e1 (desk) | Given reader `b`'s report with 6 citations: **Check each report** says "dispatch one more new reader for that group alone, in that reader's tree … the round's other reports wait", so `a` and `c` are not re-sent. A second short report "stops the run: say `Reader b (Slice 4, Slice 5, Slice 6) gave two incomplete reports.`, discard the round's other reports unrecorded, record the panel's findings … and go to Phase 7, which reports `COLD READ STOPPED`"; Phase 7 lists "two incomplete reports for one reader's group". In the live round 1 every report was complete (20, 17 and 17 citations), so the merge gave `aQ1`–`aQ14`, `aC1`–`aC10`, `bQ1`–`bQ13`, `bC1`–`bC9`, `cQ1`–`cQ12`, `cC1`–`cC9` (readers `a` and `c` had labelled their contradictions `K1` …; **Merge** gives every contradiction `C`) |
| S-05.4 | **early** fixture (the small pack at Status `specified`, so **Slices to assign** lists none): one reader `a` on the whole pack, its prompt with the slice line left out; complete report, 11 citations; guard held |
| 4.1 | Verify's `diff` of the reader prompt against `origin/main` printed nothing |

### Verify output

```text
eval "$(jq -r .verify.test .hivrr.json)"   -> structural checks pass
wc -l < skills/cold-read/SKILL.md          -> 373
grep -c '^## Phase' skills/cold-read/SKILL.md -> 7
diff <(git show origin/main:… | awk …) <(awk …) -> (no output)
ls docs/plans | grep zz-dryrun             -> (no output)
```

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| **small:** a size-S copy | No size-S pack exists in the repo, so one was written: a one-slice Change to `init` Phase 4, its README citing real lines | There was nothing to copy | n |
| S-05.4 on the small fixture | Shown on a second copy of it, **early**, at Status `specified` | A size-S pack at `sliced` has a Slice 1, so it cannot show "no slices" | n |
| Dry run by running `cold-read` | Phase 3 and its grouping were run live; the review panel was not dispatched | The panel does not touch grouping or dispatch, and Slices 1–3 proved it | n |
| Prompts dispatched as the skill says | The five round-1 readers of three fixtures went in one message | The seven fixture's three readers were one step as S-05.1.e1 requires; the two other runs were independent | n |

## Decisions

- "Round 1 reads every slice" is read as the first round of each run, not only round number 1, since a later run's earlier rounds may predate a re-slice (`readers.md` **Grouping**).
- A round with one reader still letters it `a`, so every item Id carries a letter.
- Two readers asking the same thing stay two items; a Resolution may answer both by naming the other Id.
- A later round whose fixes touched no slice gets one reader on the whole pack, as design's Grouping row says.

## Discoveries

- **For Slice 5.** Readers label contradictions inconsistently (`C` and `K`), because the prompt's
  Contradictions table names an `id` column with no prefix. **Merge** relabels by reader letter, so
  the record is consistent; the prompt is left unchanged (4.1).
- **For the retro.** Every reader on the seven fixture raised the same blocking baseline question
  (the pack's slices are already merged at HEAD) as its own Q1. Parallel readers multiply a
  pack-wide question by the number of readers; Phase 4 classes them as separate items.
- **For the retro.** The small fixture's readers both found that `eval "$(jq -r .verify.test
  .hivrr.json)"` cannot run in a fresh tree, the same gap the Test engineer found in Slice 3.
- Costs: round 1 on the seven fixture took about 205 s wall time for three readers (a 206 s, b 195
  s, c 179 s), against a single reader's 240 s in Slice 3; round 2, 177 s.

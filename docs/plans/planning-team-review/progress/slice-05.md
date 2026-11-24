# Slice 5 — Trace-back and an honest Result

| | |
|---|---|
| **Status** | done |
| **Issue** | #263 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (`claude-opus-5-5`) |
| **Date** | 2026-11-24 |

## Preflight

Checked on branch `issue/263`, forked from `origin/main` at `b9cbcd3` (Slices 1–4 merged).

| Citation | Holds |
|---|---|
| `skills/cold-read/SKILL.md:343-356`, the Result rewrite (Pattern to follow) | moved: Phase 6 **On a pass** / **Not passed** were at `:330-337`, reading the same |
| `skills/planning/references/templates/cold-read.md`, the Questions table | yes: `Id \| Blocking \| File \| Gap \| Resolution` (Slice 4 made the example Id `aQ1`) |
| `skills/planning/SKILL.md:64`, the `rounds` and `blocking` extras the wrapper reads (Stop conditions) | yes; neither field changes |
| `skills/planning/SKILL.md:306`, the wrapper reads `Pass after …` from the Result | yes; the new line keeps that prefix |
| `design.md` §2 **Record**: Questions table, Round summary, Closing Result | yes |

## Acceptance

| ID | How it was shown |
|---|---|
| S-06.1 | Phase 4 **Trace each item to a Role**: `fact`, `test`, `editor` or `trust` when a line of that card's job would have caught it, otherwise `reader`; `P` items take their role, `A` items `author`. The template's Questions table carries the Role column |
| S-06.1.e1 | Seeded dry run (below): reader `b`'s `bQ1`, a Verify testing a file no slice creates, was traced `test`, and its Resolution ends `Checklist line proposed for test: **V7** …`. The same held for `aQ2` (`trust`), `aQ3` and `aQ5` (`editor`), `aQ6` and `aQ7` (`fact`) |
| S-06.1.e2 | Seeded dry run: `aQ1` and `bQ2`, the baseline question no checklist line covers, were traced `reader`, and their Resolutions propose no line |
| S-06.2 | Phase 5 **Write the round** step 2: a reader item whose Role is not `reader` ends with `Checklist line proposed for {role}: …` under the card's next free Id; `references/result.md` lists every one under `### Checklist proposals`. In the dry run the 7 proposals (`T7`, `E7`, `E8`, `F7`, `F8`, `V7`, `V8`, all free Ids on the cards) appeared once each in the Result's list |
| S-06.3 | `references/result.md` **Result line**: `Pass after {total} round(s) ({n} in this run).`, `{total}` the header **Rounds** |
| S-06.3.e1 (desk) | 12 earlier rounds, pass in round 3 of this run: the header **Rounds** counts every round in the file, 15 (Phase 5 **Write the round**: "**Rounds** (all rounds in the file)"); `{n}` is this run's rounds, 3; so `Pass after 15 round(s) (3 in this run).` |
| S-06.3.e2 (desk) | A first run passing in round 1: `{total}` = 1, `{n}` = 1, so `Pass after 1 round(s) (1 in this run).` |
| S-06.4 | `references/result.md`: `COLD READ BLOCKED: {blocking} blocking question(s) left after round {N} ({total} rounds, {n} in this run).`, with `{N}` the last round's number, which equals `{total}` |
| S-06.4.e1 (desk) | 3 earlier rounds, blocked after round 6 with 2 left: `{N}` = 6, `{total}` = 6, `{n}` = 3, so `COLD READ BLOCKED: 2 blocking question(s) left after round 6 (6 rounds, 3 in this run).` In the live dry run the line read `COLD READ BLOCKED: 7 blocking question(s) left after round 1 (1 rounds, 1 in this run).` and the header said 7 |
| 5.1 | The template's Questions header is `Id \| Blocking \| Role \| File \| Gap \| Resolution` (Verify grep: 1) and its Result has `### Checklist proposals` |
| 5.2 | The template's Result shows `### Panel without a reader`; `references/result.md` gives its shape, and `panel.md` **No reader runs** writes it, after any existing result line, when the run stops before this run recorded a round: from Phase 2 (a void re-check) or Phase 3 (Deviations) |

### Verify output

```text
eval "$(jq -r .verify.test .hivrr.json)"   -> structural checks pass
wc -l < skills/cold-read/SKILL.md          -> 383
grep -c '^## Phase' skills/cold-read/SKILL.md -> 7
grep -c '| Id | Blocking | Role | File | Gap | Resolution |' …/templates/cold-read.md -> 1
grep -rF 'Pass after {total} round(s) ({n} in this run)' skills/cold-read | wc -l -> 1
grep -rF '({total} rounds, {n} in this run)' skills/cold-read | wc -l -> 1
ls docs/plans | grep zz-dryrun             -> (no output)
```

### Seeded dry run

The seeded fixture was rebuilt with Slice 1's ten seeds (`progress/slice-01.md`), Status `sliced`,
no `cold-read.md` or `progress/`; Author Checks printed nothing. Round 1 grouped its five slices as
Slice 4's `readers.md` says: reader `a` on Slices 1–3 and `b` on Slices 4–5, both
`Haiku (Agent tool, model: haiku, Explore)`, dispatched in one step, each in its own tree. Both
reports were complete (21 and 22 citations), and both guards held. Between them they raised D1–D4
and D6–D10. The round was then written into the fixture's `cold-read.md` from the new template, by
Phase 4 and Phase 5 as edited here: 11 rows with a Role each, 7 blocking, 7 checklist lines
proposed, and the closing Result with its blocked line and `### Checklist proposals` list. The
fixture and both trees were removed before this commit.

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| 5.2: "Phase 6 writes it when a run stopped before any reader" | `panel.md` **No reader runs** writes `### Panel without a reader`, in the shape `references/result.md` gives, under one condition in all three files: the run stopped before this run recorded a round (PR #269 review) | A stopped run goes to Phase 7 from Phase 2 or Phase 3 and never reaches Phase 6 | n |
| Move the Result text to `references/result.md` "if the skill nears 400 lines" | Moved: the edits brought `SKILL.md` to 395 lines; it is 383 after the move | The Files list allows it | n |
| Seeded dry run | No review panel ran before the readers | The panel would have fixed most seeds first, leaving the readers nothing to trace; trace-back is what this slice changes | n |
| The template's Contradictions Item | Opens with `aC1:` (Slice 4 review's deferred item) | `design.md` §2 Record puts the `{reader}C{n}` Id in the Item | n |
| Citations checked | Each row is prefixed with its reader's letter | Slice 4 added it to Phase 5 step 4; the template's example row is unchanged, since the letter is prose before the citation | n |

## Decisions

- Two proposals for one card take consecutive Ids (`E7`, `E8`), and an item asking what another
  already proposed names that item instead (`bQ3` as `aQ2`). Both are now in Phase 5 step 2 (PR
  #269 review).
- Contradictions carry a Role in their Item (`aC1 (editor): …`), and a blocking failed citation gets
  a Questions row `{reader}X{n}` (PR #269 review).
- A fixture artifact a reader raises (the pack predating its merged slices) is traced `reader`.

## Discoveries

- **For the retro.** The blocked line reads `(1 rounds, …)` for one round. The pass line says
  `round(s)` but the blocked line, per `design.md` §2 Record, says `rounds`; left as specified.
- **For the retro.** Reader `b` tried to write a file under `$HOME/.cache`; the permission layer
  denied it. The checksum guard watches the pack and the tree only, so a write elsewhere would pass
  it; the read-only `Explore` type and the harness permissions are what held.
- **For the retro.** All seven proposals came from reader items the panel's existing checklist
  should already catch (the panel did not run). With the panel running, trace-back will mostly
  propose lines for what the panel misses, which is the point.
- Costs: the two readers took 165 s and 210 s in parallel.

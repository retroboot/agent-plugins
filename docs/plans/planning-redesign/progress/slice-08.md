# Progress — Slice 8

| | |
|---|---|
| **Status** | done |
| **Issue** | #214 |
| **PR** | this PR |
| **Executor model** | Claude Opus 5.5 (`claude-opus-5-5`), following the repo's `skills/work-issue/SKILL.md` pack mode |
| **Date** | 2026-11-14 |

**Procedure.** This slice was executed by following the pack mode in this repository's
`skills/work-issue/SKILL.md` (on `main` at `d41767e`, which has Slice 7) against the issue's marker
`Plan: docs/plans/planning-redesign · Slice: 8`. Where that procedure and this README's rules could
differ, the README rules were followed, as `work-issue`'s **Pack mode** intro says. Phase 3 loaded
the pack from `origin/main`, Phase 4 mapped Size L to `complex`, Phase 5 forked `issue/214` from
`origin/main`, and Phase 6 ran the preflight below.

## Preflight

Pack read from `origin/main` at `d41767e`; the working copy matched it.

- `context.md` §3, `skills/ship-issue/SKILL.md` (178 lines, 6 phases): holds. Phase 1 33–51, Phase 2
  55–70, Phase 3 74–87, Phase 4 91–109, Phase 5 113–139, Phase 6 143–166, Error Handling 170–178
  (the file ends at 178, not 179), with the "does not touch git directly" bullet at 175–176.
- Pattern to follow, Phase 4 cycle and stop rules at `skills/ship-issue/SKILL.md:91-109`: holds.
- `work-issue` Phase 5 integration rule (`branches.integration`, default branch, `origin/HEAD`,
  `main`) at `skills/work-issue/SKILL.md:292-305`: holds. Phase 12 JSON
  `{status, pr, pr_url, branch, issues}` at 549–556 and the blocked path's `BLOCKED` with null `pr`
  and `pr_url` at 578–580: hold.
- `skills/work-issue/SKILL.md:594-596`, the Error Handling pointer naming "Slice 8 of the planning
  redesign": holds (reworded by this slice, see Decisions).
- `skills/core/SKILL.md` **Staging**, **Git Safety** and **Skill Composition**: hold.
- `skills/ship-pr/SKILL.md` `state` values `merged`, `clean_unmerged`, `stuck`: hold.
- `docs/verification.md` check 7 (phase sequence, line 78): holds. `ship-issue` states no phase
  count.

## Acceptance

Line numbers refer to `skills/ship-issue/SKILL.md` on this branch (255 lines). Dry runs read the
skill as an executor against the named scenario. The git reads were run for real on a synthetic
fixture (a bare remote and clone in the session scratchpad, outside the repository, never
committed) with a pack `x` of three slices, and on this pack on `origin/main`.

| ID | How it was shown |
|---|---|
| S-06.1 | Dry run (b), the fixture with `progress/slice-01.md` `done` and slices 2–3 without a file. Phase 1 (54–59) recognises `docs/plans/x`; **Load the pack** (61–93) resolves `main`, fetches, finds the README with `git ls-tree` (step 2), lists three slices with issues #11–#13 and prerequisites `none`, `Slice 1`, `Slice 1` (step 3, run with `git show`), and drops Slice 1 as `done` (step 4). Phase 2 fetches #12 and #13 unchanged; Phase 3 (123–126) makes each slice its own group; Phase 4 (143–148) orders by `plan.md` prerequisites with the lowest number first; Phase 5 runs `work-issue --auto` then `ship-pr` per group, one PR each. On this pack the same reads give slices 6, 8 and 9 remaining, ordered 6, 8, 9 |
| S-06.1.e1 | Fixture above: Slice 1 `done` on main, so the run ships Slice 2 then Slice 3 (steps 4–5, Phase 4) |
| S-06.1.e2 | Slice 3 depends on 1 only, and 2 and 3 are independent: Phase 4 (143–148) takes the lowest free number first, so the order is 1, 2, 3; Phase 3 keeps one group per slice and Phase 5 runs them one at a time, one PR each |
| S-06.2 | Dry run (c), Slice 2 blocked: `work-issue` returns `"status": "BLOCKED"`, `pr` and `pr_url` null. Phase 5 **A blocked slice** (180–186) skips Ship, records `state: "stuck"` with null `pr` and `pr_url`, and stops the run whether or not a later slice depends on it; the pack block (199–201) says the same for any `stuck` or failure. Phase 6 (227–235) gives `SHIP INCOMPLETE` with Slice 3's issue under `not_started`; `state` gains no value |
| S-06.2.e1 | As S-06.2: no Ship step for Slice 2, state `stuck`, Slice 3 never starts |
| S-06.3 | Dry run (a), plan PR not merged: on the fixture before the pack was pushed, `git ls-tree origin/main -- docs/plans/x/README.md` printed nothing (0 lines). Step 2 (72–75) displays `pack docs/plans/x is not on main; merge its PR first` and stops before Phase 2, so no slice starts |
| S-06.3.e1 | As S-06.3: stops before any slice with "merge its PR first" |
| S-07.2 | Dry run (d), plain issue numbers. Every pack block opens with a skip sentence keyed on a pack path (54, 62, 123, 143, 199, 237) or on a `BLOCKED` result (180), so Phases 1–6 run as on `origin/main`. Legacy-preservation diff: `git diff origin/main -- skills/ship-issue/SKILL.md` deletes exactly two lines, the Error Handling bullet at 175–176, which design §7 step 8 rewords; every other legacy line is byte-identical, including every `Display:` line and the JSON block |
| S-07.2.e1 | `ship-issue 12 13`: Phase 1 sees no `docs/plans/` path, so grouping (Phase 3, legacy text 128–132), ordering by `Depends on #N` (Phase 4, 150–163) and the output (Phase 6 JSON 213–225) are exactly as before. A plain issue's `work-issue` never returns `BLOCKED`, so 180 is skipped too |
| 8.1 | A grep of `skills/ship-issue/SKILL.md` for backticked `git` commands lists only `git fetch`, `git ls-tree` and `git show`; `origin/main` named none. **Load the pack** writes nothing (62–65), and Error Handling (252–253) now reads "changes no working tree, index or branch; it only fetches and reads". Both fixture runs left `git status --short` empty and `HEAD` equal to `origin/main` |
| Stop conditions | Not triggered. Ordering reads `plan.md` and progress files only; nothing writes to the pack |
| Structural | `eval "$(jq -r .verify.test .hivrr.json)"`: `structural checks pass`. Phases still `## Phase 1`–`## Phase 6` |
| Isolation | `grep -nE 'planner\|planning' skills/ship-issue/SKILL.md`: no output. The pack format `ship-issue` reads (slice headings, `Issue:` line, progress Status) is stated in the skill itself, from design §7, never by reading a `planner` file (ADR-007) |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| 8.1: only `git fetch`, `git ls-tree` and `git show` are added | The `origin/HEAD` fallback in design §7 step 1 is written, like `work-issue` Phase 5, as "the branch `origin/HEAD` points at", with no command named | None of the three commands reads a symbolic ref (`git show -s --format=%D origin/HEAD` prints no target here), so naming one would add a fourth command. The fallback is a read; the "changes no working tree, index or branch" half of 8.1 holds either way | n |
| Suggested path: pack input in Phase 1, branches in Phases 3 and 4, mapping in Phase 5, field in Phase 6 | Also a `### Load the pack` subsection in Phase 1, a pack block after Phase 5's dependency gate, and a new Error Handling bullet for a `work-issue` run with no JSON | Design §7 steps 1–5 need one home before Phase 2 fetches the issues; the gate needs to say whose prerequisites it uses; the bullet answers Slice 7's discovery. `###` is not a `## Phase N` heading, so check 7 is unaffected | n |
| `context.md` §3: Error Handling at 170–179 | 170–178 | The file is 178 lines | n |

## Decisions

- **`BLOCKED` maps to `stuck` for any input**, pack path or issue number (Slice 7 Discoveries). A
  marked issue given by number runs pack mode in `work-issue` too. A plain issue never returns
  `BLOCKED`, so legacy output is unchanged (S-07.2).
- **A `work-issue` run with no final JSON** (its Phase 3 pack stops) is a failure under the existing
  Error Handling rule: the run stops, and the message `work-issue` displayed is reported as the
  failure, with everything shipped so far and `not_started`. No new `state` value is added.
- **A pack that is not on integration, or a slice with no issue number,** stops in Phase 1 with one
  displayed line and no JSON, as the legacy cycle stop in Phase 4 does: no slice has started.
- **Every slice already done:** `SHIP COMPLETE` with `prs: []` and the `pack` key.
- **Independent slices** run lowest number first (S-06.1.e2). A `blocked` or `in-progress` progress
  file keeps its slice in the run, so a rerun resumes it through `work-issue`.
- **`inline_context` and `--no-merge`** are accepted with a pack path and passed on as for issue
  numbers. Under `--no-merge`, the legacy dependency gate stops a dependent slice after a
  `clean_unmerged` prerequisite.
- **`work-issue:594-596`** now says "`ship-issue` records that value as `stuck` and stops its run";
  every other `work-issue` line is byte-identical (`git diff origin/main -- skills/work-issue`: one
  line).

## Discoveries

- **For the Retro (procedure used for real):** `work-issue` Phase 3 **Load the pack** step 4 says to
  read every Read-order file. For an L pack, that is the whole pack, about 2,100 lines here. It
  worked, but `pack_context` asks only for the rules, the slice, its criteria and rows, and
  Discoveries, so a smaller model may want guidance to read the other files selectively.
- **For the Retro:** `work-issue`'s Phase 6 preflight says "check every path and symbol `context.md`
  cites that this slice touches". Here, `context.md` §3's line ranges for `ship-issue` were off by
  one at the end only. Stating ranges as section names plus a start line would age better.
- **For the Retro:** the cold read (K5) reworded 8.1 to cover `git fetch`, but nobody noticed that the
  `origin/HEAD` fallback in step 1 needs a read none of the three listed commands provides. As in
  Slices 1 and 5, a reader that runs the commands finds what a reader that only reads misses.
- **For Slice 9:** `ship-issue`'s description in its frontmatter (and in `README.md`) still says "a
  list of issues". It now also takes a pack path. Slice 9 owns the docs text. The frontmatter was left
  alone here because this slice's Files list only the skill body changes.
- `ship-issue` does not check that a slice issue's marker names the same slice as `plan.md`. If they
  disagree, `work-issue` follows the marker. A planner-side publish check would catch it earlier.

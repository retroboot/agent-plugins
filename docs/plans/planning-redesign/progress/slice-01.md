# Progress — Slice 1

| | |
|---|---|
| **Status** | done |
| **Issue** | #207 |
| **PR** | this PR |
| **Executor model** | Claude Opus 5.5 (`claude-opus-5-5`), via `ship-issue 207` → `work-issue 207 --auto`, pack rules followed by hand |
| **Date** | 2026-11-13 (blocked), 2026-11-14 (done) |

## Preflight

- `docs/verification.md` check 13 at line 156: holds (the loop and `echo` style was copied for check 14).
- `docs/verification.md` loader builds its fence with `printf "\140\140\140"`: holds.
- `CLAUDE.md:215` "Thirteen checks": holds.
- `CLAUDE.md:207` script policy: holds; check 14 lives in the fence, with no script on disk.
- `skills/planning/references/ux-checklist.md`, 159 lines: holds.
- `skills/planning/references/` has no `templates/` yet: holds.
- No existing check scans `skills/*/references/`; check 7 reads `skills/*/SKILL.md` only: holds.
  Templates therefore cannot trip checks 7 or 8.

## Acceptance

| ID | How it was shown |
|---|---|
| S-03.1 | `pack-format.md` §2 holds the routing matrix, size table and modifier table copied from `design.md` §3 |
| S-03.2 | `templates/README.md` has **Slice** (size S only) with Outcome, Acceptance as rules and examples, Contracts, Stop conditions, Verify, then **Route**, in `design.md` §4 order |
| S-04.1 | `templates/README.md` **How to execute this pack** is this pack's eight rules with `planning-redesign` replaced by `<slug>` |
| S-04.3 | Check 14 written; see 1.1 |
| S-04.3.e1 | Synthetic pack with an untagged fence: `PACK CODE FENCE docs/plans/x/README.md:2` |
| S-04.3.e2 | Synthetic pack with `text` and `mermaid ` (trailing space) fences: no output |
| S-03.1.e1 | Feature M with `ui`: the routing matrix (`pack-format.md` §2) gives README, prd, context, design and plan for Feature at M, and the `ui` row says `ux.md` at size M+; `templates/ux.md` exists. Behaviour (spec writing them) proven in Slice 3 |
| S-03.2.e1 | Change S: the matrix gives README only; `templates/README.md` **Slice** has Acceptance as a rules-and-examples table and Verify. Behaviour proven in Slices 3 and 6 |
| S-10.1.e1 | `templates/prd.md` Rules and examples guidance: "at least 2 rows, with at least one edge or failure case", and its example table has an edge row. Behaviour (spec adding or asking) proven in Slice 3 |
| S-10.2.e1 | `templates/prd.md` NFR table lists Observability with `<target or none>` and says "Never omit a row" |
| S-10.4.e1 | `templates/prd.md` has **Behaviour-preservation contract** (Refactor only) pointing to characterization cases under Rules and examples. Behaviour proven in Slice 3 |
| S-11.2.e1 | `templates/design.md` §4 State machines: one diagram per entity, then "Illegal transitions:" list |
| S-11.3.e1 | `templates/design.md` §3 and §5 are headed by their triggers (persisted entities; two or more components), and the file says to delete a section whose trigger does not apply. A text-only change gets neither |
| S-11.4.e1 | `templates/design.md` §8 Pre-mortem "Maps to" column offers "stop condition in Slice N" |
| S-12.1.e1 | `templates/ux.md` has one wireframe heading and one state table per screen under Parts 3 and 4, plus the screen inventory. Behaviour proven in Slice 3 |
| S-12.1.e2 | `templates/ux.md` **Mockups**: "links only"; `ux-checklist.md` **Mockups**: "linked from `ux.md`, never embedded" |
| S-12.2.e1 | `pack-format.md` §2 `observability` row: events with levels and "what must never be logged", alerts "each with a numeric threshold" |
| S-10.1, S-10.2, S-10.4 | `templates/prd.md`: Rules and examples, NFRs (every quality listed), Assumptions, Failure modes, Behaviour-preservation contract and Regression criteria, each headed by its trigger |
| S-10.3 | `templates/README.md` rules 4 and 7 name example IDs |
| S-11.1–S-11.4 | `templates/design.md`: Domain model, State machines, Flows, Test strategy, Pre-mortem, each headed by its trigger |
| S-12.1 | `ux-checklist.md` restructured into six parts (inventory, flow, wireframes, states, responsive, accessibility); `templates/ux.md` holds the same six |
| S-12.2 | `pack-format.md` §2, Modifiers, defines `observability` |
| 1.1 | Scratchpad run of check 14's lines: python fence → `PACK CODE FENCE`; untagged → `PACK CODE FENCE`; `json` → `PACK CODE FENCE`; second fence after a valid one → caught at its line; folder without README → `PACK NO README docs/plans/y`; no `docs/plans/` → nothing; this repository → nothing. Full structural checks: `structural checks pass` |
| Check count | `CLAUDE.md:215` says "Fourteen checks" and names check 14; checks pass. Negative: changing it to "Fifteen" prints `CHECK COUNT DRIFT CLAUDE.md says fifteen, verification doc has 14` |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Change `CLAUDE.md:215` to "Fourteen checks" | Check 8 then fails: `CHECK COUNT DRIFT CLAUDE.md says fourteen, verification doc has 14` | Check 8 turns the word into a number through `w2n()`, defined in check 7 (`docs/verification.md`, around line 79), whose table stops at `thirteen` | y (Check count contract). Stopped; resolved by the developer's decision below |
| Format spec restates `design.md` §2 | Round 1 of the PR review found `pack-format.md` had added two ADR rules (a **Proposed by** line and `amended by ADR-NNN`) that design §2 does not state; both were removed from `pack-format.md` and `templates/adr.md`. This pack's own ADRs still use them | Rule 6: do not silently extend the format of record | n |
| Ten templates, including `ux.md` | Done; templates also carry Spike **Question**, Bug **Repro and root cause** and a Retro table | Round 4 cold read flagged the Spike README shape and Retro shape as undefined (S3-Q1, S7-Q4) | n |

## Decisions

- **Developer, 2026-11-14:** extend `w2n()` in check 7 with `fourteen` through `twenty`. Only
  the lookup table changed; no check's logic did. This overrides the stop condition "Stop if any of
  the 13 existing checks needs changing" for this one edit.
- Template guidance lines are italic and start with `_Guidance:`, so a skill can tell them from
  content and replace them.
- `ux-checklist.md` keeps the "patterns to flag" table under Part 3, Wireframes, rather than as a
  seventh part.
- Check 14 treats any line starting with three backticks inside an open fence as its closing fence.
- Check 14 also strips `\r` from the info string (CRLF files) and checks hidden folders for a
  README; check 7's "the N phases" regex now reaches `twenty`, matching `w2n()`. All three came from
  the PR review and change no check's specified behaviour.

## Discoveries

- **The cold read missed this.** Four rounds checked citations about check 8 but none ran the
  count change against `w2n()`. Worth a line in the Retro: a reader cannot find what only running
  the check reveals.
- `skills/planning/SKILL.md` still points at the old "UI/UX Plan Section Template" of
  `ux-checklist.md`; Slice 6 rewrites that skill, so nothing was changed here.
- `design.md` §2 could adopt the **Proposed by** line and `amended by` rule this pack's ADRs use;
  until it does, `pack-format.md` does not require them.
- Check 14 does not see `~~~` or indented fences, and reports four-backtick fences. Extending it
  needs `design.md` §5 and Slice 1's fence definition amended first.
- Process: the blocked path worked as written. The slice stopped on 2026-11-13, with partial work in
  `wip:` commit `5658c2d`, and was finished on the same branch after the developer's decision.


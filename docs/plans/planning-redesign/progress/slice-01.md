# Progress — Slice 1

| | |
|---|---|
| **Status** | blocked |
| **Issue** | #207 |
| **PR** | none yet (blocked before Phase 11) |
| **Executor model** | Claude Opus 5.5 (`claude-opus-5-5`), via `ship-issue 207` → `work-issue 207 --auto`, pack rules followed by hand |
| **Date** | 2026-11-13 |

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

Proofs so far. Nothing below 1.1 is final until the block is resolved and the full checks pass.

| ID | How it was shown |
|---|---|
| S-03.1 | `pack-format.md` §2 holds the routing matrix, size table and modifier table copied from `design.md` §3 |
| S-03.2 | `templates/README.md` has **Slice** (size S only) with Outcome, Acceptance as rules and examples, Contracts, Stop conditions, Verify, then **Route**, in `design.md` §4 order |
| S-04.1 | `templates/README.md` **How to execute this pack** is this pack's eight rules with `planning-redesign` replaced by `<slug>` |
| S-04.3 | Check 14 written; see 1.1 |
| S-04.3.e1 | Synthetic pack with an untagged fence: `PACK CODE FENCE docs/plans/x/README.md:2` |
| S-04.3.e2 | Synthetic pack with `text` and `mermaid ` (trailing space) fences: no output |
| S-10.1, S-10.2, S-10.4 | `templates/prd.md`: Rules and examples, NFRs (every quality listed), Assumptions, Failure modes, Behaviour-preservation contract and Regression criteria, each headed by its trigger |
| S-10.3 | `templates/README.md` rules 4 and 7 name example IDs |
| S-11.1–S-11.4 | `templates/design.md`: Domain model, State machines, Flows, Test strategy, Pre-mortem, each headed by its trigger |
| S-12.1 | `ux-checklist.md` restructured into six parts (inventory, flow, wireframes, states, responsive, accessibility); `templates/ux.md` holds the same six |
| S-12.2 | `pack-format.md` §2, Modifiers, defines `observability` |
| 1.1 | Scratchpad run of check 14's lines: python fence → `PACK CODE FENCE`; untagged → `PACK CODE FENCE`; `json` → `PACK CODE FENCE`; second fence after a valid one → caught at its line; folder without README → `PACK NO README docs/plans/y`; no `docs/plans/` → nothing; this repository → nothing. **Full checks not passing; see Blocked on** |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Change `CLAUDE.md:215` to "Fourteen checks" | Check 8 then fails: `CHECK COUNT DRIFT CLAUDE.md says fourteen, verification doc has 14` | Check 8 turns the word into a number through `w2n()`, defined in check 7 (`docs/verification.md`, around line 79), whose table stops at `thirteen` | y (Check count contract) |
| Ten templates, including `ux.md` | Done; templates also carry Spike **Question**, Bug **Repro and root cause** and a Retro table | Round 4 cold read flagged the Spike README shape and Retro shape as undefined (S3-Q1, S7-Q4) | n |

## Decisions

- Template guidance lines are italic and start with `_Guidance:`, so a skill can tell them from
  content and replace them.
- `ux-checklist.md` keeps the "patterns to flag" table under Part 3, Wireframes, rather than as a
  seventh part.
- Check 14 treats any line starting with three backticks inside an open fence as its closing fence.

## Discoveries

- **The cold read missed this.** Four rounds checked citations about check 8 but none ran the
  count change against `w2n()`. Worth a line in the Retro: a reader cannot find what only running
  the check reveals.
- `skills/planning/SKILL.md` still points at the old "UI/UX Plan Section Template" of
  `ux-checklist.md`; Slice 6 rewrites that skill, so nothing was changed here.

## Blocked on

**Stop condition:** "Stop if any of the 13 existing checks needs changing to make room. That is out
of scope." (plan.md, Slice 1.)

**Question for the developer:** may Slice 1 extend `w2n()` in check 7 by adding `fourteen) echo 14`
(or up to `twenty`, for headroom)? It is a lookup-table entry; no check's logic changes. The
alternative is to change the Check count contract so `CLAUDE.md` states the count another way,
which also edits check 8.

**Partial in the `wip:` commit:** `pack-format.md`, the ten templates, the rewritten
`ux-checklist.md`, check 14 with its table row and mechanics note, and the `CLAUDE.md` sentence
already saying "Fourteen checks". Everything except check 8 passing is done.

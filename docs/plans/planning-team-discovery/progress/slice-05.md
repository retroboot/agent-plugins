# Slice 5 — Research with no subagent tool

| | |
|---|---|
| **Status** | done |
| **Issue** | #285 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (claude-opus-5-5) |
| **Date** | 2026-11-24 |

## Preflight

The branch `issue/285` was cut from `origin/main` at `960f513`, after Slice 4 merged as #290. The desk walks followed this checkout's `skills/` text by hand.

| Citation | Holds |
|---|---|
| `skills/planning/references/roles/dispatch.md` **No subagent tool** (plan cites `:203-215`, `context.md` cites `:203-217`): the panel, drafting and gate paragraphs | holds by name. The section is now at `:262`, after Slice 1's research sections (Deviations) |
| `dispatch.md` **Model resolution**, the no-model-choice rule (plan cites `:22-24`) | holds at `:24-26`: "A missing capability changes where a role runs, never whether it runs." |
| `dispatch.md` **Research completeness check** states the missing line once (Slice 1, 1.3) | holds |
| `skills/brainstorm/references/research.md` steps 4 and 7, the ledger, **Phase 3 opening** (Slices 3 and 4) | holds |

Skill dir: /home/retroboot/projects/agent-plugins/skills

## Acceptance

Each desk walk followed `research.md` and `dispatch.md` **No subagent tool** and **Model resolution** step by step, on T1 ("staff `brainstorm` with research roles"). The no-subagent walk used a real research tree: `mktemp -d "${TMPDIR:-/tmp}/cold-read.XXXXXX"`, then `git worktree add --detach` of `origin/main` at `960f513`. The tree guard ran before and after, and the Facilitator worked through the cards by reading that tree. The guard was unchanged, and the tree was removed. The DR1 checkout guard matched its baseline.

In the walk, the Facilitator worked the cards as follows:

- **Scout, 4 findings.**
  - RO1: `skills/brainstorm/SKILL.md:70` Phase 2.
  - RO2: `research.md:18` **Phase 2 research step**.
  - RO3: `dispatch.md:163` **Research frame**.
  - RO4: `dispatch.md:262` **No subagent tool**.
- **Historian, 2 findings, plus Packs read with 5 rows.**
  - RH1: the `planning-team-spec` Retro row 1, "read every route branch".
  - RH2: the parent's **Ruled out** "The full team on every pack".
- **Skeptic, Could fail RK1 and Should not be built RK2.**
  - RK1: with no subagent tool, the case against is argued in the conversation's own context (`docs/plans/planning-team/README.md:68`).
  - RK2: is three roles on every brainstorm "the full team on every pack"? (`:45`)

| ID | Result | How shown |
|---|---|---|
| S-05.2 | pass | The fallback side is shown by S-05.2.e2. The dispatched side was shown in Slice 3 |
| S-05.2.e2 | pass | Desk walk. The developer asks where RK1 came from. The ledger keeps "whether it was run independently", and the source rule in **The findings ledger** now says to name the role and its evidence and, for a card worked with no subagent tool, "also say that it was not run independently". The reply given: "That came from the Skeptic card, worked through by me with no subagent tool, so it was not run independently. Its evidence is `docs/plans/planning-team/README.md:68`." |
| S-08.1 | pass | Shown by S-08.1.e1 and S-08.1.e2 |
| S-08.1.e1 | pass | Desk walk, no subagent tool, Phase 2. Step 4 says to work through the three cards, as `dispatch.md` **No subagent tool** says for a research step. Each card was worked in turn, in the step's one tree, under the same guard. Lines given, in order: `Research: Scout Facilitator — 4 findings, Historian Facilitator — 2 findings, Skeptic Facilitator — 2 findings`, then `Research run by the Facilitator: not independent.` |
| S-08.1.e2 | pass | Desk walk, a subagent tool with no model choice. **Model resolution** says to dispatch a fresh subagent on the default model, recorded by name or as `default model`. Research still dispatches, so **No subagent tool** is not reached. Line given: `Research: Scout default model — {f} findings, Historian default model — {f} findings, Skeptic default model — {f} findings`. No "not independent" line follows, because that line appears only in **No subagent tool** (`grep -c` of it in `skills/` gives 1, in `dispatch.md`) |
| S-08.2 | pass | Shown by S-08.2.e1 and S-08.2.e2 |
| S-08.2.e1 | pass | Desk walk, Phase 3 after S-08.1.e1. **Phase 3 opening** draws on the findings it brings in: RO2 (the research step), RO4 (the fallback section) and RK2. The opening was two sentences, ending with one question: "Should a brainstorm on a typo run all three roles, given the parent ruled out the full team on every pack?" |
| S-08.2.e2 | pass | Desk walk, no subagent tool, with the Skeptic card worked only through **Could fail** and no **Should not be built** table. That is incomplete by the **Research completeness check**. **No subagent tool** says to work it through once more, and the second try was left incomplete the same way. Lines given: `Research: Skeptic gave no complete report; not researched by Skeptic.`, then `Research: Scout Facilitator — 4 findings, Historian Facilitator — 2 findings`, then `Research run by the Facilitator: not independent.` The opening went ahead from RO2 and RH2 without the Skeptic, and the missing line named the card not worked through |
| 5.1 | pass | `dispatch.md` **No subagent tool** has a research paragraph (`awk` count of `research` is above 0). `Research run by the Facilitator: not independent.` occurs once in `skills/`, in `dispatch.md`. The paragraph names the **Research completeness check** and does not restate its line (count 1) |
| 5.2 | pass | Step 7 now reads: "`{model}` is the alias dispatched, `default model`, or `Facilitator` for a card you worked through yourself." The S-08.1.e1 walk gave `Scout Facilitator`, `Historian Facilitator` and `Skeptic Facilitator` |

## Deviations

| Plan said | Reality | Why | Contract affected (y/n) |
|---|---|---|---|
| Pattern to follow: `dispatch.md:203-215` (and `context.md`: `:203-217`) for the fallback paragraphs | **No subagent tool** is at `:262`. Lines 203-215 now hold the **Research completeness check**, which Slice 1 added | Slice 1 inserted the research sections above it. The section's content is unchanged, so the contract holds; only the line cite is stale | n |

## Decisions

- **When no role is complete, step 7 gives no summary line.** This settles the item #290 deferred: a summary line would name no role. The missing lines stand on their own. In the fallback, `Research run by the Facilitator: not independent.` then follows the missing lines, as the `dispatch.md` paragraph says.
- **The research paragraph sits last among the fallback paragraphs**, before the cold-reader note. The panel, drafting and gate paragraphs are unchanged.
- **`skills/brainstorm/SKILL.md` is unchanged.** The fallback lives in `research.md` step 4, step 7 and the ledger, and in the `dispatch.md` paragraph.

## Discoveries

- The fallback was walked by hand here and has never run on a host that truly lacks a subagent tool, such as Codex, Antigravity or opencode. The P1 Skeptic in Slice 4 (RK21) also asked whether `$CLAUDE_SKILL_DIR` resolves on those hosts. Both are for child 4, which owns the subagent-free fallback in one place.

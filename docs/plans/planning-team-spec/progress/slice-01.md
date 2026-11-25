# Slice 1 — Drafting contract and the Scout

| | |
|---|---|
| **Status** | done |
| **Issue** | #270 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (`claude-opus-5-5`) |
| **Date** | 2026-11-24 |

## Preflight

Checked on branch `issue/270`, forked from `origin/main` at `84817e2`.

| Citation | Holds? |
|---|---|
| `skills/spec/SKILL.md`: 370 lines, 10 `## Phase` headings (context.md §1) | holds |
| `skills/spec/SKILL.md:114-140`, Phase 2 | holds |
| `skills/spec/SKILL.md:128`, opening line names `HEAD` | holds |
| `skills/spec/SKILL.md:136-138`, the Greenfield bullet | holds |
| `skills/spec/SKILL.md:197-211`, Phase 4 | holds |
| `skills/planning/references/roles/dispatch.md:1-9`, `:11-20`, `:22-54`, `:56-72`, `:97-102` | holds |
| `skills/planning/references/roles/fact-checker.md:1-53`, the card shape | holds (58 lines; Output at 47, Blocking test at 53) |
| `editor.md`, `test-engineer.md`, `trust-reviewer.md` headers, `## Model` at line 7 | holds |
| `skills/cold-read/references/panel.md:13-14`, step 1 | holds |
| `skills/cold-read/SKILL.md:54-60`, the `{base}` step | holds |
| `skills/cold-read/references/tree.md:28-29`, the copy line | holds |
| `skills/planning/references/templates/context.md`, five sections | holds |

## Acceptance

Every dry run followed the checkout's `skills/` text, with `$CLAUDE_SKILL_DIR` resolved to this
checkout's skill (see Decisions). Each drafting dispatch ran in a new tree, built by
`skills/cold-read/references/tree.md`, with the guard before and after. Fixtures were under
`docs/plans/zz-dryrun-*`, and all were removed before commit.

| ID | Result |
|---|---|
| S-01.1 | pass — shown by S-01.1.e1 and S-01.1.e2 |
| S-01.1.e1 | pass — **fresh**: one `Explore` call with model `sonnet`, the drafting frame from `dispatch.md` **Drafting frame** with `scout.md` pasted in. Drafted by the Scout, Sonnet (Agent tool, model: sonnet, Explore); the transcript names `claude-sonnet-5-5`. The guard outputs were identical before and after. The report was a `context.md` |
| S-01.1.e2 | pass — **guard** copy: a Scout dispatch (Agent tool, model: sonnet, Explore). After its report, the executor appended a line to `README.md` in the tree before the second guard run. The guard diff named `docs/plans/zz-dryrun-guard/README.md` (cksum `3758058615 3762` became `216264855 3776`). The tree was removed, and the run stopped `SPEC STOPPED` (`dispatch.md` **Tree and guard**). Status stayed `routed`, and no `context.md` was written |
| S-01.2 | pass (contract side) — **short** copy: prompt changed in the session only, to drop `## 5. Glossary`. Dispatch 1 (Agent tool, model: sonnet, Explore) gave both markers and `## Open points` but no `## 5. Glossary`: incomplete. Dispatch 2, in a new tree (Agent tool, model: sonnet, Explore), again had no `## 5. Glossary` and added a section of its own: incomplete. The Facilitator drafted the file by the card. Drafting line: `Drafted by the Facilitator: Scout gave no complete draft.` Both guards were identical. The rows S-01.2.e1 and S-01.2.e2 name the Analyst and are proven in Slice 3 |
| S-01.3 | pass — shown by S-01.3.e1 and S-01.3.e2, and structurally: every card has `## Kind` (Verify) |
| S-01.3.e1 | pass — `panel.md` step 1, its `roles/` path replaced in the session by `docs/plans/zz-dryrun-roles/`, which held the four reviewing cards, `scout.md` and three stand-ins (`stand-in-analyst.md`, `stand-in-architect.md`, `stand-in-planner.md`, copies of `scout.md`). Step 1 selected four cards to dispatch: `editor.md`, `fact-checker.md`, `test-engineer.md` and `trust-reviewer.md`. The four `draft` cards were skipped |
| S-01.3.e2 | pass — the same copy with `## Kind` removed from `editor.md`: step 1 said `Card editor.md states no kind; not dispatched.` and selected the other three reviewing cards |
| S-01.4 | pass (drafting side) — shown by S-01.4.e1; S-01.4.e2 is Slice 2's |
| S-01.4.e1 | pass — forced fallback, recorded as such: on the **nosub** copy, the executor simulated no subagent tool. The Facilitator drafted `context.md` by `scout.md` in the main session, with seven citations, each opened and checked. The acceptance checkpoint's `context.md` entry read: "`context.md`: the `init` Phase 4 `null` path and its `skipped` consumers, 7 citations; `Drafted by the Facilitator: not independent.`; open points: None." |
| S-02.1 | pass — shown by S-02.1.e1 and S-02.1.e2 |
| S-02.1.e1 | pass — **fresh** at `routed`, Feature at M, with `context.md` required. Phase 2 resolved `{base}` as `origin/main` after a fetch, `{sha}` `84817e2` and `{date}` `2026-11-24`. Drafted by the Scout, Sonnet (Agent tool, model: sonnet, Explore). The draft was accepted and written as `context.md`. Its opening line reads "checked on 2026-11-24 at commit `84817e2`", and the README Read order gained `2. [context.md](context.md): …`. Display: `Draft: Scout sonnet — context.md, 6 open points`. Triage: DS1 and DS2 were blocking and developer-only, held for the acceptance checkpoint. DS3 to DS6 were non-blocking and settled in the file (DS3 and DS4 in §2 Fate cells, DS5 by running the check, DS6 left as written) |
| S-02.1.e2 | pass — **change** copy, a Change at size S. Its routing row's context column is blank, so Phase 1 lists no `context.md`, and Phase 2's "required, or optional and accepted" branch does not apply: "Otherwise no Scout is dispatched." No `{base}` was resolved and no tree was built. No context gate exists before Slice 2, and none ran |
| 1.1 | pass — Verify: `Letter=S Model=sonnet Kind=draft`, and the heading sequence `Letter\|Model\|Kind\|Job\|Inputs\|Checklist\|Output\|` |
| 1.2 | pass — Verify: five cards; four `: review`, `scout.md: draft`, none "no kind" |
| 1.3 | pass — Verify: `=== BEGIN {file} ===` occurs only in `dispatch.md`, once |
| 1.4 | pass — Verify: `dispatch.md` **Base** holds the `{base}` step, with its fallback line once; `{base}` and `dispatch.md` occur in `spec` Phase 2, before the Scout's dispatch |
| 1.5 | pass — **greenfield** copy, run through `spec` Phase 5. Drafted by the Scout, Sonnet (Agent tool, model: sonnet, Explore). The draft cited each stack choice to the Brief (`README.md:19`, `:19-20`) or the Ruled out options (`README.md:24`, `:25`). In Phase 5, ADR-001 (Python 3.12, standard library only) and ADR-002 (standalone port, from the DS1 answer) were written. Each stack citation in `context.md` gained `ADR-001`, and the DS1 line gained `ADR-002` |
| prd Assumptions row 1 | held — whole-file reports came back intact. **fresh**: 131 lines, 15,280 characters, end marker back. **greenfield**: 117 lines, end marker back. The **guard** and **short** reports also had both markers. Each draft's own `bash` fence passed through between the markers intact |

Skill dir, per dry run:

- **fresh:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **short:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **guard:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **change:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **greenfield:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **nosub:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **roles (panel step 1):** Skill dir: /home/retroboot/projects/agent-plugins/skills/cold-read

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Live runs: "the session with the planner plugin loaded from this checkout" (`design.md` §6) | The session's `Skill` tool loads the installed planner plugin from the plugin cache. Each dry run instead followed the checkout's `skills/spec/SKILL.md` and `skills/cold-read/references/panel.md` text directly, with `$CLAUDE_SKILL_DIR` resolved to this checkout. Every `{skill}`, `{template}`, `{format}` and `{card}` came from the checkout | The plugin cannot be reloaded from the checkout mid-session; the checkout text is what the slice changes. The Skill dir lines record the path each run actually used | n |
| S-01.3.e1: "four dispatches" | Step 1 was run on the copy and selected four cards. Steps 2 and 3 were not run, so no reviewer was sent | Step 1 is the changed text and decides what is dispatched; steps 2 and 3 are unchanged. Not on the live list in Verify | n |

## Decisions

- **The progress Status check.** The plan's `grep -c '^| \*\*Status\*\* | blocked |'` reads this
  file's header row, so the header is the table above.
- **Greenfield fixture prd.** The **greenfield** prd was cut to one story and one rule. Its only
  job was to carry the run to Phase 5, where 1.5 is proven.
- **The executor played the developer** at the **greenfield** acceptance checkpoint. DS1 was
  answered (a), a standalone port with check 14 unchanged, and the checkpoint was approved.
  Both ADRs are `accepted`, Proposed by `developer`: ADR-001 because the Brief states the stack,
  ADR-002 because the answer at Phase 4 chose between options.
- **Short draft retry fixture.** The Facilitator's own draft for **short** reused the **nosub**
  draft, written by the card in this session for the same Brief.

## Discoveries

- **For Slice 2, the context gate.** Every Scout draft raised, as a blocking open point (S4),
  that `init` already prints `null` at `skills/init/SKILL.md:232`. That is the kind of item the
  context gate's held list and the acceptance batch must carry.
- **For Slice 2, a Scout check that writes.** Two Scouts reported running the structural check
  block in their tree, and two reported that the permission system denied it. Every guard held.
  F7's "not run: changes state" rule should be paired with the same wording for drafters if
  this recurs.
- **For Slice 3.** The marker lines carried `bash` fences inside drafts intact, so the Analyst's
  prd fences need no special handling (pre-mortem P2 holds).
- **Trees for drafters** take `tree.md`'s `cold-read.XXXXXX` prefix, so its orphan scan also
  finds a stray `spec` tree. That is harmless, but worth knowing when a run is interrupted.
- **`spec` line budget.** `spec` is now 377 lines, leaving 22 lines for Slices 2 to 4.

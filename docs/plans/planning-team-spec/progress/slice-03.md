# Slice 3 — Analyst, acceptance gate and probes

| | |
|---|---|
| **Status** | done |
| **Issue** | #272 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (`claude-opus-5-5`) |
| **Date** | 2026-11-24 |

## Preflight

Checked on branch `issue/272`, forked from `origin/main` at `c01cde9` (Slice 2 merged).

| Citation | Holds? |
|---|---|
| `skills/spec/SKILL.md` Phase 3 at 153-204, 384 lines, 10 `## Phase` headings | holds |
| `skills/planning/references/roles/fact-checker.md`, F1 to F6 and **Output** "F1 to F6" | holds |
| `skills/planning/references/roles/trust-reviewer.md`, **Questionnaire** and `No outside inputs.` | holds |
| `skills/planning/references/templates/prd.md:58`, Assumptions header with three columns | holds |
| `skills/planning/references/pack-format.md:140`, the Assumptions row | holds |
| `skills/planning/references/gates.md` **Held** and **Handoff** (Slice 2) | holds |
| `skills/planning/references/roles/dispatch.md` **Drafting frame**, **Completeness check** ("any the card's **Output** adds") | holds; a card may add a report section, so F7's **Probes** needs no `dispatch.md` edit |
| `skills/planning/references/roles/scout.md`, the drafting card shape | holds |

## Acceptance

Every dry run followed the checkout's `skills/` text, with `$CLAUDE_SKILL_DIR` resolved to this
checkout (see Deviations). Each pass built a new tree by `skills/cold-read/references/tree.md` from
`{base}` `origin/main` (`c01cde9`), with the guard before and after; every guard was identical. Each
card was pasted from the checkout, so the gates ran the new F7. Fixtures were under
`docs/plans/zz-dryrun-*`, and all were removed before commit. The executor played the developer at
each fixture checkpoint.

**seeded-prd** (`zz-dryrun-sprd`) was built from Slice 2's seeded-context run after its gate: the
drifts fixed, DS1 and DS2 answered as that run answered them, and GF2 (the developer-only seed)
still held in `## Gate pending: context.md`. After the Analyst's draft was written, the executor
replaced the prd's Assumptions with five seeded rows and added S-01.5, against real lines:

1. A1, true by a file read: the Agent tool accepts `model: opus` (`docs/plans/planning-team-review/progress/slice-03.md:27`).
2. A2, false by a file read: Phase 4 prints no `INIT:` line when Step 4 records `null` (it prints one at `skills/init/SKILL.md:232`).
3. A3, needing a write: run `init` in a scratch repository and read the `.hivrr.json` it writes.
4. A4, needing a slice not built: Slice 1's dry run.
5. A5, a key with no source: `HIVRR_SIGNING_KEY`, and S-01.5's line HMAC keyed by it, printed at most
   once every 24 hours from the previous run: a clock with no stated source.

| ID | Result |
|---|---|
| S-01.2 | pass (Analyst side) — shown by S-01.2.e1 and S-01.2.e2 |
| S-01.2.e1 | pass — **seeded-prd**: Drafted by the Analyst, Opus (Agent tool, model: opus, Explore); the transcript names `claude-opus-5-5`. Both `prd.md` markers, `## Open points`, and every section the Feature route triggers, Rules and examples and Failure modes included: accepted and written. Display: `Draft: Analyst opus — prd.md, 5 open points` |
| S-01.2.e2 | pass — **short** copy, the prompt changed in the session only to leave out Rules and examples. Dispatch 1 (Agent tool, model: opus, Explore) had no `## Rules and examples`: incomplete. Dispatch 2, in a new tree (Agent tool, model: opus, Explore), again had none: incomplete. The Facilitator wrote the prd by the card: dispatch 2's other sections, and a Rules and examples section of its own. The acceptance checkpoint line: `Drafted by the Facilitator: Analyst gave no complete draft.` Both guards were identical |
| S-03.1 | pass — shown by S-03.1.e1 and S-03.1.e2 |
| S-03.1.e1 | pass — **seeded-prd**, a Feature at M with a checked `context.md`: `spec` Phase 3 dispatched the Analyst (Agent tool, model: opus, Explore), and its prd was written with every section the route triggers: Problem, Users and jobs, Goals, Non-goals, Success measures, Non-functional requirements, Assumptions (with **Probe**), Story map, Stories, Rules and examples, Failure modes |
| S-03.1.e2 | pass — **size S** Change copy: the Analyst (Agent tool, model: opus, Explore) returned markers naming `README.md`, holding only `### Outcome` and `### Acceptance`. The Facilitator put them in the README **Slice** under `Issue: # · Depends on: none`, and no `prd.md` was written. Its DN1 found a fixture slip of the executor's: the Route still said M |
| S-03.2 | pass — shown by S-03.2.e1 and S-03.2.e2 |
| S-03.2.e1 | pass — **seeded-prd** acceptance gate: the Fact-checker (Agent tool, model: sonnet, Explore) and the Trust reviewer (Agent tool, model: opus, Explore) went in one message, in the same tree (`/tmp/cold-read.C9fhaw`), under one guard. Display: `Gate acceptance: Fact-checker sonnet, Trust reviewer opus — 13 findings (7 blocking) \| fixed 4, held 7` |
| S-03.2.e2 | pass — **held-prd2**, a docs-only Brief with no outside party or input: its Trust reviewer (Agent tool, model: opus, Explore) gave the Questionnaire header row and `No outside inputs.`, with T1 to T4 n/a and Findings None. The checkpoint line: `Trust: no outside inputs.` (see Deviations for why not **held-prd**) |
| S-03.3 | pass — shown by S-03.3.e1 and S-03.3.e2 |
| S-03.3.e1 | pass — **seeded-prd** acceptance checkpoint: one message holding the checkpoint's content, both gates' Display lines and the probe results, then every held item with its Id, role, file and section, and options: GF2 and DN1 (the held context finding), GF3 and GT1, GF4 (the failed probe A2), GT2 (the key's checker), GT3 (the clock), GT4 to GT7, then approve, change or stop. The two Trust questions the fixture requires, the key and the clock, are GT1 and GT3 |
| S-03.3.e2 | pass — **seeded-prd**: the Trust reviewer's key question (PT1), the Fact-checker's unsourced-key finding (PF2) and A5's `false` probe ask the same thing, so they were one item, `GF3, GT1`. Likewise DN1, the Analyst's wording open point, joined GF2 |
| S-04.1 | pass — shown by S-04.1.e1 and S-04.1.e2 |
| S-04.1.e1 | pass — **seeded-prd**: the Fact-checker's F7 (Agent tool, model: sonnet, Explore) probed A1 by quoting `docs/plans/planning-team-review/progress/slice-03.md:27` ("Trust reviewer as `Opus (Agent tool, model: opus, Explore)`"), and the row records `held: …` |
| S-04.1.e2 | pass — **seeded-prd**: A4 needs Slice 1 built. No command was run, and the row records `not run: needs Slice 1 built` |
| S-04.2 | pass — shown by S-04.2.e1 and S-04.2.e2 |
| S-04.2.e1 | pass — **seeded-prd**: the Facilitator wrote all five F7 results into the prd's Assumptions **Probe** cells, each with its evidence: A1 `held: …`, A2 `false: …`, A3 `not run: changes state`, A4 `not run: needs Slice 1 built`, A5 `false: …` |
| S-04.2.e2 | pass — **seeded-prd**: A3's check writes `.hivrr.json`. It was not run, and the row records `not run: changes state` |
| S-04.3 | pass — shown by S-04.3.e1 and S-04.3.e2 |
| S-04.3.e1 | pass — **seeded-prd**: A2 probed `false`, so its If false text was a batch item (GF4). The developer's first **approve**, with GF4 and the other blocking items neither answered nor deferred, was withheld. Approve went through only after GF4 was answered (a) |
| S-04.3.e2 | pass — **held-prd** (Agent tool, model: sonnet, Explore) and **held-prd2** (Agent tool, model: sonnet, Explore): each prd's one assumption probed `held`, so no probe item entered either batch |
| S-03.5 | pass (`prd.md` stage) — **seeded-prd**: after the acceptance gate's fixes (GF5 to GF8, after a snapshot), `handoff.md` held `## Gate pending: prd.md` with the drafting line, `Notices: None.`, `Fix not re-checked` and the held items. The executor ended the session there. `spec` ran again: Phase 1 found both Gate pending entries, so no Scout and no Analyst were dispatched. Only the gates re-ran on the files as they stood: the Fact-checker (Agent tool, model: sonnet, Explore) and the Trust reviewer (Agent tool, model: opus, Explore). They kept the entry's Ids: PF1 was GF2, PF2 was GF3, PF3 was GF4, and the Trust questions were GT1 to GT5 again. New blocking items took GT6 and GT7. GF5 to GF8 were not reported again, so they were **checked**, and `Fix not re-checked` was removed. Display: `Gate acceptance: Fact-checker sonnet, Trust reviewer opus — 11 findings (10 blocking) \| fixed 0, held 10`. On approve, the answers were written (GF3 as `decisions/ADR-001-no-signed-line.md`, `accepted`, Proposed by `developer`) and GT6 was deferred as `Deferred at the acceptance checkpoint on 2026-11-24: GT6 — …`. Both entries were removed and `handoff.md` deleted |
| 3.1 | pass — Verify: `Letter\|Model\|Kind\|Job\|Inputs\|Checklist\|Output\|` and `Letter=N Model=opus Kind=draft`; no two cards share a letter |
| 3.2 | pass — Verify: `fact-checker.md` has one `**F7**` and "one row per item F1 to F7" |
| 3.3 | pass — Verify: the prd template's Assumptions header has the `Probe` column, and `pack-format.md`'s row reads "… what changes if false, and its probe result" |

Skill dir, per dry run:

- **seeded-prd:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **short:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **size S:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **held-prd:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **held-prd2:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Live runs: "the session with the planner plugin loaded from this checkout" (`design.md` §6) | As in Slices 1 and 2: each dry run followed the checkout's skill text, with `$CLAUDE_SKILL_DIR` resolved to the checkout | The session's `Skill` tool loads the cached plugin | n |
| **held-prd** proves S-03.2.e2 | Its Trust reviewer (Agent tool, model: opus, Explore) found outside inputs: `init`'s own `gh` calls and `~/.claude/settings.json`, which a dry run of `init` reaches. A second run, on **held-prd2** (a docs-only Brief and an executor-written prd with one true assumption), gave `No outside inputs.` | The fixture fault was the Brief: any pack about `init` has those inputs. The pass rule allows one more run. S-04.3.e2 holds on both | n |
| S-03.5: the gate re-run after the session ends | One Fact-checker dispatch served both the context gate's and the acceptance gate's re-run, in one message with the Trust reviewer | The two prompts were byte-identical: the same card, tree and pack | n |
| A **Re-check** after the acceptance gate's fixes | The session ended with `Fix not re-checked`, and the resumed gate was the check, as `gates.md` **Handoff** says | It proves that clause and saves a dispatch | n |
| S-03.3.e1's Given: two Trust questions, one failed probe, one held context finding | Nine items: the key and clock questions among seven Trust items, two `false` probes (A2, and A5 merged into GF3), and the held context finding GF2 | The fixture's S-01.5 raised more trust questions than the two it required; each was in the one message | n |
| Files: `planning/SKILL.md` not listed | Its Resume **Handoff note** now names a size S `README.md` entry, beside `prd.md` | The acceptance gate's entry at size S names `README.md`, and Resume must route it to Phase 4 | n |

## Decisions

- **F7's evidence has its own section, `## Probes`**, as the Trust reviewer's Questionnaire is a
  third section. `dispatch.md` **Completeness check** already counts a section a card's Output adds.
- **The size S acceptance gate** was not run on the size S copy; its row asks only for the draft.
- **Cheap non-blocking findings** of the gate (GF5 to GF8) were fixed. GT8 (Route and Security NFR)
  was listed, not asked, and its question fell with ADR-001.

## Discoveries

- **For Slice 4: `spec` has 5 lines left.** `spec` is 394 lines; the Architect's dispatch must fit in
  5, or text moves to `gates.md` or `dispatch.md`. `planning` is 386.
- **For the retro: `G` Ids are reused after a resume.** As in Slice 2, the first acceptance pass
  listed a non-blocking GT6, which was never held, and the resumed pass gave GT6 to a new blocking
  item.
- **For the retro: drafters catch fixture defects.** The Analyst's open points named a Route left at
  M on the size S copy, and a slug left from Slice 2's fixture. Neither was a seed.
- **For the retro and R5:** both acceptance-gate Fact-checkers ran the structural check block in their
  trees, which is read-only. Every guard held.
- **For any Trust fixture:** a pack about `init` always has outside inputs, because a dry run of
  `init` calls `gh` and reads the developer's settings. A "no outside inputs" fixture needs a Brief
  that runs nothing.

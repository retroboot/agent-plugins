# Slice 2 — Context gate and the checkpoint batch

| | |
|---|---|
| **Status** | done |
| **Issue** | #271 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (`claude-opus-5-5`) |
| **Date** | 2026-11-24 |

## Preflight

Checked on branch `issue/271`, forked from `origin/main` at `d21e106` (Slice 1 merged).

| Citation | Holds? |
|---|---|
| `skills/spec/SKILL.md`: 377 lines after Slice 1, 10 `## Phase` headings | holds |
| `skills/spec/SKILL.md:13-15`, files are the only state | holds |
| `skills/planning/SKILL.md:114-116`, Resume's pending lines | holds |
| `skills/planning/SKILL.md:305-307`, the gate before Approve and Publish | holds |
| `skills/planning/references/pack-format.md:16-36`, §1 Layout | holds |
| `skills/cold-read/references/panel.md:9-34`, `:36-57`, `:69-84`, and **Ids** | holds (the batch, the snapshot, the re-check and the Ids rule) |
| `skills/planning/references/roles/dispatch.md`, **No subagent tool** (Slice 1) | holds |
| Slice 1's `dispatch.md` **Base**, **Drafting frame** and **Draft completeness check** | holds; this slice uses them and creates no file Slice 1 lacked |

## Acceptance

Every dry run followed the checkout's `skills/` text, with `$CLAUDE_SKILL_DIR` resolved to this
checkout's skill (see Deviations). Each pass built a new tree by `skills/cold-read/references/tree.md`
from `{base}` `origin/main` (`d21e106`), with the guard before and after. Fixtures were under
`docs/plans/zz-dryrun-*`, and all were removed before commit. The executor played the developer at
each fixture checkpoint.

The **seeded** run: the Scout drafted `context.md` (Agent tool, model: sonnet, Explore). Its draft
was complete, was written, and had its open points triaged: DS1 and DS2 blocking and held, DS3 to
DS6 non-blocking. The executor then replaced the draft with a copy holding five seeds, written
against real lines:

1. `INIT: verify recorded` cited at `skills/init/SKILL.md:229`, though it is at `:232`.
2. A file `skills/init/references/verify-off.md` that does not exist.
3. `init` said to be 352 lines; it is 396.
4. A wording claimed as fixed by Phase 4's conventions, a value only the developer can choose.
5. The `null` rule cited at `skills/init/references/verify.md:24`, though it is at `:20`.

| ID | Result |
|---|---|
| S-01.4 | pass (gate side) — shown by S-01.4.e2 |
| S-01.4.e2 | pass — forced fallback, recorded as such: on **clean**, the executor simulated no subagent tool. The Facilitator worked through `fact-checker.md` itself, in a tree under the guard (identical before and after). It checked the three citations, the named files and `d21e106`, and wrote the report in the output contract: F1, F2, F3 and F5 done, F4 and F6 n/a, Findings None. The checkpoint line: `Gate run by the Facilitator: not independent.` |
| S-02.2 | pass — shown by S-02.2.e1 and S-02.2.e2 |
| S-02.2.e1 | pass — **seeded** context gate, Fact-checker (Agent tool, model: sonnet, Explore). It reported seeds 1 to 4 as PF3, PF1, PF4 and PF2, which meets the pass rule. It also reported two real defects in the Scout's draft: PF5, the pack README cited at `:46-50` for rule 4, which is at `:47-51`, and PF6, dangling DS3, DS5 and DS6 pointers. These were renumbered GF1 to GF6. GF5 is a drifted citation under F1. It was fixed to `:47-51`, after a snapshot. The re-check, with `{diff}` (Agent tool, model: sonnet, Explore), did not report it again: **checked**. Display: `Gate context: Fact-checker sonnet — 6 findings (2 blocking) \| fixed 5, held 1`, then `Gate context re-check: Fact-checker — 3 findings \| checked 4, held 1`. Phase 3 started after |
| S-02.2.e2 | pass — **clean**: a three-line `context.md` whose three citations the executor checked first. Context gate (Agent tool, model: sonnet, Explore): no blocking finding, three non-blocking ones, listed under the Display line. No fix and no re-check; Phase 3 starts |
| S-02.3 | pass — shown by S-02.3.e1 and S-02.3.e2 |
| S-02.3.e1 | pass — **seeded**: seed 4, GF2 (Agent tool, model: sonnet, Explore), triaged developer-only: the wording is the developer's choice. It was not fixed and not asked. It was held in the `Gate pending: context.md` entry, and asked in the acceptance checkpoint's one message with DS1, DS2 and GF3 |
| S-02.3.e2 | pass — **seeded**: GF3 (seed 1) was fixed wrongly on purpose, `:229` to `:231`. The re-check reported it again, so it was **held**, not fixed again, and asked in the acceptance batch (option (a), cite `:232`, answered) |
| 2.3 | pass — **seeded**: from the Scout's dispatch through the gate pass, the re-check, the session end and the resumed gate, no message went to the developer. The first message was the Phase 4 checkpoint |
| S-03.4 | pass — shown by S-03.4.e1 and S-03.4.e2 |
| S-03.4.e1 | pass — **seeded**, Approve: DS1's answer was written into `context.md` with the date. DS2's answer chose between options, so Phase 5 recorded it as `decisions/ADR-001-off-line-points-at-sentinel.md`, Status `accepted`, Proposed by `developer`. GF3's answer was written as the fix to `:232` |
| S-03.4.e2 | pass — **seeded**: GF2 deferred. The README Open questions line now reads `Deferred at the acceptance checkpoint on 2026-11-24: GF2 — context.md §3 "The new line's wording": …`, replacing "None." Once deferred it is not asked again |
| S-03.5 | pass — shown by S-03.5.e1 to S-03.5.e3, and 2.4 below |
| S-03.5.e1 | pass — **seeded**: the session was ended by the executor after the context gate, with `handoff.md` holding `## Gate pending: context.md` (drafting line, held DS1, DS2, GF2 and GF3). While a fix waited, it also held `Fix not re-checked`, removed once the re-check's guard ran. `spec` ran again: Phase 1 found the entry, so no Scout was dispatched. Only the context gate re-ran, on `context.md` as it stood (Agent tool, model: sonnet, Explore). It kept the entry's Ids: GF2 and GF3 were reported again under those Ids. The held items were asked at the acceptance checkpoint under their Ids, with the entry's drafting line, `Drafted by the Scout, Sonnet (Agent tool, model: sonnet, Explore).` |
| S-03.5.e2 | pass — **seeded**: the acceptance checkpoint approved, with only the context stage's entry in the file. After the answers were written and GF2's deferral line, the `Gate pending: context.md` entry was removed and `handoff.md` deleted |
| S-03.5.e3 | pass — **refuse** copy at `reviewed`, with `cold-read.md` `Pass after 1 round(s)` and `handoff.md` holding `## Gate pending: plan.md`. The `planning` gate before Approve and Publish refused each: `Refused: handoff.md holds Gate pending: plan.md; run planning docs/plans/zz-dryrun-refuse to finish it.` |
| S-03.6 | pass — shown by S-03.6.e1 |
| S-03.6.e1 | pass — **ids** copy: a README line `Deferred at the acceptance checkpoint on 2026-11-24: GF3 — … SKILL.md:229 …`, and a `context.md` holding that drift plus a missing file. Its context gate (Agent tool, model: sonnet, Explore) reported three findings. The drift matched the deferred item, so it was named `GF3` and not raised again. The missing file is a new finding and took `GF4`, the next after GF3; the third took `GF5` |
| S-06.4 | pass (`planning` and `spec` side) — shown by S-06.4.e1; the `slice` side is Slice 5's |
| S-06.4.e1 | pass (`planning` and `spec` side) — **specpending** copy at `sliced`, with `handoff.md` holding `## Spec pending: GV1`. `planning` Resume read the Handoff note first and resumed at Phase 4, Specify, with the request set to the entry's answer. `spec` Phase 1 chose **Re-route**, same route, and revised only prd Rules and examples S-01, writing its `Revised by spec on 2026-11-24: …` line. The Phase 4 checkpoint, approved, removed that line ("None." again) and the Spec pending entry, and deleted `handoff.md`. Status stayed `sliced` |
| 2.1 | pass — Verify: `gates.md` has the six headings in order; **Ids** and **Fix** are under `## Gate pass`, **Answer** and **Deferral** under `## Checkpoint batch` |
| 2.2 | pass — Verify: `grep -rlF 'Deferred at the {' skills` prints only `gates.md` |
| 2.3 | see above |
| 2.4 | pass — Verify: `templates/handoff.md` exists; `pack-format.md` §1 lists `handoff.md`; `planning` Resume reads it first, and its gate refuses while it exists (S-03.5.e3); `spec` Phase 1 reads it and removes a Spec pending entry on approval (S-06.4.e1) |

Skill dir, per dry run:

- **seeded:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **clean:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **ids:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **refuse:** Skill dir: /home/retroboot/projects/agent-plugins/skills/planning
- **specpending:** Skill dir: /home/retroboot/projects/agent-plugins/skills/planning, then /home/retroboot/projects/agent-plugins/skills/spec
- **nosub (on clean):** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Live runs: "the session with the planner plugin loaded from this checkout" (`design.md` §6) | As in Slice 1: the session's `Skill` tool loads the cached plugin, so each dry run followed the checkout's skill text directly, with `$CLAUDE_SKILL_DIR` resolved to the checkout. Every card and reference came from the checkout | The plugin cannot be reloaded from the checkout mid-session | n |
| Two **seeded-context** runs: one for the gate and batch, one ended after the gate and run again | One continuous run: gate pass, re-check, session end, resumed gate, then the acceptance checkpoint | It proves every row both runs named, with one fewer Scout dispatch | n |
| S-03.5.e1's Given: "one held item" | The entry held four (DS1, DS2, GF2, GF3) | The combined run; each was asked under its Id with the drafting line, as the Then requires | n |
| Seed 5 was to be reported by the gate pass, fixed wrongly, and reported again (S-02.3.e2) | The gate pass missed seed 5. S-02.3.e2 was shown with seed 1 (GF3) fixed wrongly. Seed 5 surfaced as a new non-blocking finding in the re-check and in the resumed gate | The pass rule names seeds 1 to 4 for this gate, and all four were reported; the row needs only a fixed finding reported again | n |

## Decisions

- **Non-blocking findings** of the gate pass (GF3 to GF6) were fixed, because each was one cheap
  edit. That is what put GF3 under the re-check.
- **Settled open points.** The Scout's DS3 to DS6 were left unsettled after the first write, and
  the gate found the dangling pointers (GF6). The fix settled each in the file, as
  `dispatch.md` **Draft completeness check** says.
- **Where DS1's answer went:** `context.md` §2, the section the item named, with the date.
- **The refusal's way out (PR #277 review).** On the **refuse** copy, `run planning {path}`
  resumed at Phase 7 by Status and met the same refusal, because no phase skill re-ran the gate.
  `planning` Resume now takes a Gate pending entry to the phase that owns its file, whatever the
  Status. A desk run of that copy goes to Phase 5 (`slice`) for `plan.md`.

## Discoveries

- **For Slice 3 and the retro: a write during a pass voids it.** In the resumed run, the executor
  wrote Phase 3's `prd.md` while the gate's dispatch was still running. The checkout side of the
  guard covers the pack, so the guard-after would have voided the gate. Both writes were undone,
  and the pack matched its before-state, before the guard ran. The guard worked as designed. A
  Facilitator must not start the next stage's file until the gate's guard-after has run.
- **For the retro: Ids after a resume.** `gates.md` **Ids** continues from the highest `G` Id in
  Deferred lines and `handoff.md`. Fixed findings are recorded in neither, so after a session break
  the resumed gate reused `GF4` and `GF5`, which the first run had given to findings since fixed.
  No live item collided, but a `G` Id is unique only among items still held or deferred.
- **For Slice 5: the Scout's own defects are worth a gate.** The context gate found two real
  defects the Scout introduced (PF5, PF6). Neither was a seed.
- **`spec` line budget.** `spec` is 384 lines and `planning` is 385, leaving 15 and 14 lines for
  Slices 3 to 5.

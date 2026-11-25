# Slice 4 — Research during the conversation

| | |
|---|---|
| **Status** | done |
| **Issue** | #284 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (claude-opus-5-5) |
| **Date** | 2026-11-24 |

## Preflight

The branch `issue/284` was cut from `origin/main` at `c9f9059`, after Slice 3 merged as #289. The dry runs followed this checkout's `skills/` text by hand.

| Citation | Holds |
|---|---|
| `skills/brainstorm/references/research.md` **Phase 2 research step** steps 3 to 7, **The findings ledger** and the summary line (Slice 3) are on `{base}` | holds |
| `skills/planning/references/roles/dispatch.md` **Research frame**, **Research completeness check** and the research pass beside **Tree and guard** (Slice 1) | holds |
| `skills/brainstorm/SKILL.md:114-116`: Phase 4 asks the Facilitator to challenge assumptions | holds (now at `:122-124`, after Slice 3's Phase 2 text) |
| `skills/brainstorm/SKILL.md:120-130`: the sections Phase 4 holds (Brief, Ruled out, Key insights, Open questions) | holds (now at `:128-138`) |
| `skills/brainstorm/SKILL.md` Phase 8 statuses and keys identical to `54a2980` | holds |

Skill dir: /home/retroboot/projects/agent-plugins/skills

## Acceptance

Live rows were dispatched with the Agent tool, `subagent_type: Explore`, each using the research frame with the card pasted verbatim. Each research step got its own detached tree of `origin/main` at `c9f9059`, and the retry got a new tree with its own baseline. The tree guard (`git status --porcelain --untracked-files=all`, with no pack copied in) ran before and after each step, and every tree was then removed. The checkout guard (DR1: `git status --porcelain --untracked-files=all`, `git worktree list`, plus `cksum` of every file under `docs/plans`) was taken before the first dispatch and again after the fixtures were removed. It matched.

The T1 run opened with the Phase 2 step: Scout, Historian and Skeptic. Its summary line was `Research: Scout sonnet — 22 findings, Historian sonnet — 23 findings, Skeptic opus — 18 findings`. That step's **Sources read** never named `docs/verification.md` or `.agents/skills/`.

| ID | Result | How shown |
|---|---|---|
| S-03.3 | pass | Shown by S-03.3.e1 and S-03.3.e2 |
| S-03.3.e1 | pass | T5 Phase 2 step (Agent tool, model: opus, Explore), with the Scout and Historian on sonnet. Skeptic RK7, under **Should not be built**: "This topic repeats a **Ruled out** entry of the parent pack word for word: 'One author agent with longer checklists'", citing `docs/plans/planning-team/README.md:36-37`. The Facilitator put it to the developer as a challenge, under **Challenge rule**, and the developer kept the option. The README Phase 7 wrote for `zz-dryrun-t5-keep` has **Ruled out** "None.". The option is not there (`grep -c 'One author'` in that section gives 0). The finding went under **Key insights** and **Open questions**. Guard unchanged |
| S-03.3.e2 | pass | The same T5 findings (Agent tool, model: opus, Explore), and this time the developer dropped the option. The `zz-dryrun-t5-drop` **Ruled out** reads: "**One author agent with longer checklists.** Dropped by the developer after the Skeptic's challenge (RK7): 'the parent pack already ruled this out and we have no new evidence; checklist lines belong on role cards.'" |
| S-06.1 | pass | Shown by S-06.1.e1 and S-06.1.e2 |
| S-06.1.e1 | pass | T1 Phase 4. The next reply turned to how the structural checks and `.agents/skills/` would meet the research text. No earlier step's **Sources read** covered that ground. The Facilitator said `Researching structural checks and .agents discovery: Scout, Skeptic.`, then dispatched both in one message, in one tree: the Scout (Agent tool, model: sonnet, Explore) and the Skeptic (Agent tool, model: opus, Explore). Summary line: `Research: Scout sonnet — 17 findings, Skeptic opus — 13 findings`. The next reply drew on RO27 (renumbered from RO5: check 13 reads only the top-level `skills/` directories) and RK22 (renumbered from RK4: check 13 never checks a link's target), and asked the Skeptic's RK21 as its one question (renumbered from RK3: has a Codex or Antigravity run resolved `$CLAUDE_SKILL_DIR`?). Guard unchanged |
| S-06.1.e2 | pass | The following reply came back to the Phase 2 research step's `cold-read.` tree prefix. The T1 Scout's **Sources read** had already covered that (`skills/cold-read/references/tree.md`, RO12). So the reply drew on RO12, which was held, and no dispatch was made: no `Researching` line, no tree and no Agent call |
| S-06.2 | pass | Shown by S-06.2.e1 and S-06.2.e2 |
| S-06.2.e1 | pass | The S-06.1.e1 step (Agent tool, model: sonnet, Explore, and model: opus, Explore). The Facilitator waited for both reports, ran the guard and gave the summary line. Only then did it bring RO27 and RK22 into its next reply, as its own words. Neither role addressed the developer. Each report went only to the Facilitator, and each Id continued the run's ledger: Scout RO23–RO39, Skeptic RK19–RK31 |
| S-06.2.e2 | pass | T1 Phase 4: `Researching release notes for planner features: Historian.` The Historian (Agent tool, model: sonnet, Explore) was given a prompt forced short, and replied only `Sources read: withheld for a dry-run test.`, which is incomplete because it has no **Findings**. The guard ran, and the Historian was dispatched once more in a new tree with its own baseline (Agent tool, model: sonnet, Explore), forced short again. Same reply. The Facilitator said `Research: Historian gave no complete report; not researched by Historian.` Both trees were removed and the conversation went on |
| S-07.2 | pass | Shown by S-07.2.e1 and S-07.2.e2. `diff` of Phase 8 against `54a2980` prints nothing |
| S-07.2.e1 | pass | The kept T5 run (Agent tool, model: opus, Explore, for its Skeptic). Phase 8 gave `{"status":"BRAINSTORM COMPLETE","pack":"docs/plans/zz-dryrun-t5-keep","pack_status":"discovered","route":{"type":"Refactor","size":"M","modifiers":[],"slug":"zz-dryrun-t5-keep"}}`. `jq keys_unsorted` gives `status, pack, pack_status, route` and no other key |
| S-07.2.e2 | pass | The not-routed topic was "three unrelated small fixes in `README.md`, `RELEASE-NOTES.md` and `CLAUDE.md`". Phase 2 step: Scout and Historian on sonnet, Skeptic (Agent tool, model: opus, Explore). The Skeptic's RK6 cites `skills/planning/SKILL.md:100-103` (one-line fixes are not routed). Phase 5 found a batch of independent small items, and Phase 8 gave `{"status":"BRAINSTORM NOT ROUTED","pack":null,"pack_status":null,"route":null}`, with `route: null` as today. Nothing was written |
| 4.1 | pass | `awk` over the `## Phase` sections that cite `references/research.md` gives `2 3 4`. `Researching {ground}: {roles}.` occurs once in `skills/`, in `skills/brainstorm/references/research.md` |
| 4.2 | pass | `wc -l skills/brainstorm/SKILL.md` gives 297, and `grep -c '^## Phase'` gives 8. The Bootstrap-to-Phase-2 and Phase-5-to-end `diff`s against `54a2980` print nothing |

Report lengths:

| Run | Findings |
|---|---|
| T1 | Scout 22, Historian 23, Skeptic 18 |
| T5 | Scout 22, Historian 14, Skeptic 12 |
| Not-routed topic | Scout 12, Historian 8, Skeptic 8 |
| T1 Phase 4 | Scout 17, Skeptic 13 |

Every report was complete except the two that were forced short.

Timing: wave 1 dispatched nine roles at once, and the T1 Skeptic was the slowest at 109 s. The Phase 4 step's Skeptic took 152 s.

## Deviations

| Plan said | Reality | Why | Contract affected (y/n) |
|---|---|---|---|
| Dry runs follow one conversation at a time | Wave 1 dispatched the Phase 2 steps of T1, T5 and the not-routed topic together, each in its own tree. The two T1 Phase 4 steps (S-06.1.e1 and S-06.2.e2) also ran together, each in its own tree | To save wall-clock time. Each step kept its own tree, guard and summary, and no report crossed steps | n |
| The forced-short role | Both forced-short dispatches put the seed line `Your whole reply is exactly this one line: Sources read: withheld for a dry-run test.` ahead of the research frame | Seeded on purpose, as in Slice 3, where the line was put in to force a short report | n |

## Decisions

- **`{ground}` is the Facilitator's own few words.** Phase 4 research reuses steps 3 to 7 of the Phase 2 step. It keeps the run's `{base}`, `{date}` and `{sha}`, and it does not read issues or commits again. The Facilitator's statement of the new ground stands in for `{topic}`.
- **"New ground"** has the meaning the cold read adopted (aQ15, bQ10): ground no earlier step's **Sources read** covered.
- **The Challenge rule lives beside Phase 4 research in `research.md`.** `SKILL.md` gets a three-line pointer, so the skill stays at 297 lines.

## Discoveries

- **No complete role in a step.** In a Phase 4 step whose only role is missing, step 7's summary line would name no role. The run gave only the missing line. Step 7 already lets that line stand on its own, but it does not say whether the empty summary line is left out. Slice 5's walk could state it.
- **The Scout ran the verification fence in its tree.** In the Phase 4 T1 step, the Scout ran the fenced block of `docs/verification.md` "to see the checks pass". It is read-only, and the guard was unchanged. The frame allows read-only commands, so this is within the rules. It is worth knowing for a host where the checks are slow.
- **Every role reads the pack's fixtures.** As in Slices 1 to 3, every role on T1 and T5 read `planning-team-discovery` and named T5 as a fixture. The T5 Skeptic's RK8 asked "a real proposal or a T5 dry run?".
- **Stale plan citation for Slice 5.** The T1 Skeptic (RK11) found again that Slice 5's `dispatch.md:203-215` citation is stale. **No subagent tool** is at line 262.

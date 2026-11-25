# Slice 3 — Research before the opening

| | |
|---|---|
| **Status** | done |
| **Issue** | #283 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (claude-opus-5-5) |
| **Date** | 2026-11-24 |

## Preflight

The branch `issue/283` was cut from `origin/main` at `e9b093f`, with Slices 1 and 2 merged as #287 and #288. Every dry run followed this checkout's `skills/` text by hand.

| Citation | Holds |
|---|---|
| `skills/planning/references/roles/dispatch.md` **Base**, **Research frame**, research completeness check and the research pass beside **Tree and guard** (Slice 1) | holds |
| `skills/planning/references/roles/research-scout.md`, `historian.md`, `skeptic.md`: Kind `research` (Slices 1, 2) | holds |
| `skills/brainstorm/SKILL.md:35-66` Phase 1 branches: new topic, no input, pack path with no README, resume at each Status | holds |
| `skills/brainstorm/SKILL.md:70-76` Phase 2 with "This phase is silent"; `:80-101` Phase 3 and **When resuming** | holds |
| `skills/cold-read/references/tree.md:19-30` tree commands, `:41-44` guard | holds |
| `skills/cold-read/references/panel.md:19-20` one message holding every dispatch | holds |
| `skills/session/references/github.md` **List** issues | holds |
| `skills/brainstorm/SKILL.md` at `54a2980` is 287 lines, with eight `## Phase` headings | holds |

Skill dir: /home/retroboot/projects/agent-plugins/skills

## Acceptance

Every live row was dispatched with the Agent tool, `subagent_type: Explore`, using the research frame and the card pasted verbatim. The three roles of a step went in one message. Each step ran in its own detached tree of `origin/main` at `e9b093f`, built by `tree.md`'s commands with the `cold-read.` prefix, with a resumed pack copied in. Each tree had its guard taken before dispatch and after the last report, and each was removed afterwards. The checkout's `git status --porcelain --untracked-files=all`, `git worktree list` and `find docs/plans -type f -exec cksum {} + | sort -k3` were taken before the runs and after each one (DR1). The executor played the developer.

| ID | Result | How shown |
|---|---|---|
| S-02.3 | pass | Shown by S-02.3.e1, with S-02.3.e2 and 1.5 from Slice 1 |
| S-02.3.e1 | pass | Resume of `zz-dryrun-discovered` (Status `discovered`), copied in as `{path}`. Historian (Agent tool, model: sonnet, Explore): Packs read lists the five past packs and says "Pack folder `docs/plans/zz-dryrun-discovered` is {path}, the pack being brainstormed. It is excluded from this table and from every lesson as a past pack." No finding cites it as a past pack. Guard unchanged |
| S-04.1 | pass | Shown by S-04.1.e1 and S-04.1.e2 |
| S-04.1.e1 | pass | T1, new topic. Scout (Agent tool, model: sonnet, Explore), Historian (Agent tool, model: sonnet, Explore) and Skeptic (Agent tool, model: opus, Explore) were sent in one message. Phase 3 opened only after all three reports were in. Summary line: `Research: Scout sonnet — 30 findings, Historian sonnet — 18 findings, Skeptic opus — 13 findings` |
| S-04.1.e2 | pass | T1, with `zz-forced-write.txt` placed in the tree between the guard's two runs (seeded). Scout (Agent tool, model: sonnet, Explore), Historian (Agent tool, model: sonnet, Explore) and Skeptic (Agent tool, model: opus, Explore) all came back complete. The after-guard showed `?? zz-forced-write.txt`, so the step was void: `Research void: zz-forced-write.txt changed in the research tree; no finding brought in.` The tree was removed and Phase 3 opened as today. No stop, no new result status |
| S-04.2 | pass | Shown by S-04.2.e1 to e3 |
| S-04.2.e1 | pass | Resume of `zz-dryrun-routed` (Status `routed`): Phase 1 said the pack is at Status routed and would be revised in place. Scout (Agent tool, model: sonnet, Explore), Historian (Agent tool, model: sonnet, Explore) and Skeptic (Agent tool, model: opus, Explore) ran. `Research: Scout sonnet — 22 findings, Historian sonnet — 14 findings, Skeptic opus — 14 findings`. The developer discarded at Phase 6. The checkout's `cksum` of the fixture was unchanged after the run |
| S-04.2.e2 | pass | Resume of `zz-dryrun-published` (Status `published`), run to the end: `Pack is at Status published; this is a read-only run — brainstorm will not edit a published pack.` Scout (Agent tool, model: sonnet, Explore), Historian (Agent tool, model: sonnet, Explore) and Skeptic (Agent tool, model: opus, Explore) ran. `Research: Scout sonnet — 31 findings, Historian sonnet — 18 findings, Skeptic opus — 19 findings`. The conversation ran. Phase 6 ended it as a discard, with `BRAINSTORM DISCARDED`, `pack` null. The checkout guard was unchanged |
| S-04.2.e3 | pass | Input `docs/plans/zz-dryrun-missing`, with no folder: Phase 1 said `No pack at docs/plans/zz-dryrun-missing`. The developer named a topic (a dry-run mode for `merge-pr`), and research ran as for a new brainstorm, with `Pack: none` and nothing copied in. Scout (Agent tool, model: sonnet, Explore), Historian (Agent tool, model: sonnet, Explore) and Skeptic (Agent tool, model: opus, Explore): `Research: Scout sonnet — 27 findings, Historian sonnet — 9 findings, Skeptic opus — 13 findings` |
| S-04.3 | pass | Shown by S-04.3.e1 and S-04.3.e2 |
| S-04.3.e1 | pass | No input: Phase 1 asked what the developer wanted to work through. At that point `git worktree list` showed the checkout only. No tree was built and nothing was dispatched |
| S-04.3.e2 | pass | The developer then named a topic (`review-pr` posting findings inline). The tree was built and Scout (Agent tool, model: sonnet, Explore), Historian (Agent tool, model: sonnet, Explore) and Skeptic (Agent tool, model: opus, Explore) were dispatched. The understanding came after the reports: `Research: Scout sonnet — 21 findings, Historian sonnet — 9 findings, Skeptic opus — 14 findings` |
| S-04.4 | pass | Shown by S-04.4.e1 and S-04.4.e2 |
| S-04.4.e1 | pass | T1, with the Historian's prompt forced short (seeded). The Historian (Agent tool, model: sonnet, Explore) gave one line, `Sources read: withheld for a dry-run test.`, with no **Findings** and no **Packs read**. The completeness check found it incomplete, and the Historian was dispatched once more, in a new tree that took its own guard baseline |
| S-04.4.e2 | pass | The retry (Agent tool, model: sonnet, Explore) was forced short again and gave the same line. That gave `Research: Historian gave no complete report; not researched by Historian.`, then `Research: Scout sonnet — 35 findings, Skeptic opus — 15 findings`. The opening went ahead on the Scout's and the Skeptic's findings. Both trees' guards were unchanged |
| S-05.1 | pass | Shown by S-05.1.e1 and S-05.1.e2 |
| S-05.1.e1 | pass | T1, from S-04.1.e1's three complete reports (Agent tool, model: sonnet / sonnet / opus, Explore). The opening had three sentences: the existing executing pack (Scout RO21, Historian RH1), the parent's ruled-out full team on every pack (Historian RH4), and the Skeptic's RK10 on three researchers per brainstorm. Then one question: "Do you want to resume docs/plans/planning-team-discovery rather than plan this again?" |
| S-05.1.e2 | pass | T1 (Agent tool, model: sonnet / sonnet / opus, Explore), 60 findings, with six extra Scout findings seeded into the ledger (68 in all). The opening had four sentences and one question: "What do you want this brainstorm to settle that planning-team-discovery does not?" Every finding not used, the six seeded ones included, was held for Phase 4 |
| S-05.2 | pass | Shown by S-05.2.e1. S-05.2.e2 is proven in Slice 5 |
| S-05.2.e1 | pass | In S-05.1.e1's run, with the Historian (Agent tool, model: sonnet, Explore), the developer asked where the full-team point came from. The Facilitator answered: "From the Historian, RH4: docs/plans/planning-team/README.md, its Ruled out entry 'The full team on every pack', lines 36-49." |
| S-05.3 | pass | Shown by S-05.3.e1 and S-05.3.e2 |
| S-05.3.e1 | pass | In S-05.1.e2's run (Agent tool, model: sonnet / sonnet / opus, Explore), a question finding was seeded into the Skeptic's ledger: "Should research be skippable with a --no-research flag?" It did not reach the opening. In the second Phase 4 reply the Facilitator asked it as its own, alone: "Should a developer be able to skip research for one run?" |
| S-05.3.e2 | pass | S-05.1.e2's run (Agent tool, model: sonnet / sonnet / opus, Explore) also had an off-topic finding seeded (the snowflake skill's reference count). It was set aside, never mentioned, and run to a kept `docs/plans/zz-dryrun-t1-kept/README.md`. `grep -ciE 'snowflake\|skip research\|no-research'` on that README printed 0, so it holds neither the off-topic nor the question finding. Nothing records it |
| S-05.4 | pass | Shown by S-05.4.e1 and S-05.4.e2 |
| S-05.4.e1 | pass | Resume of `zz-dryrun-discovered`, whose Ruled out is "One agent researching inline, with a longer checklist". Scout (Agent tool, model: sonnet, Explore), Historian (Agent tool, model: sonnet, Explore) and Skeptic (Agent tool, model: opus, Explore): `Research: Scout sonnet — 23 findings, Historian sonnet — 26 findings, Skeptic opus — 12 findings`. The Skeptic's own RK11 argued for one dispatch reading past Retros in Phase 2, and a seeded Skeptic finding argued for one agent researching inline. The opening named it, `The Skeptic's RK11 touches the ruled-out option "One agent researching inline, with a longer checklist".`, and did not argue it. The single question came from the saved Open question |
| S-05.4.e2 | pass | Resume of `zz-dryrun-ruled-out-none`, whose Ruled out is "None.". Scout (Agent tool, model: sonnet, Explore), Historian (Agent tool, model: sonnet, Explore) and Skeptic (Agent tool, model: opus, Explore): `Research: Scout sonnet — 26 findings, Historian sonnet — 17 findings, Skeptic opus — 14 findings`. Nothing was named as touching a ruled-out option. Findings came in as for a new brainstorm: the existing executing pack (RO20) and the Skeptic's RK13 on the parent's full team |
| S-07.1 | pass | Shown by S-07.1.e1 and S-07.1.e2 |
| S-07.1.e1 | pass | T1 kept, from S-05.1.e2's run (Agent tool, model: sonnet / sonnet / opus, Explore): Phase 7 wrote `docs/plans/zz-dryrun-t1-kept/README.md`, Status `discovered`. The checkout guard differed from its baseline only by `?? docs/plans/zz-dryrun-t1-kept/README.md` and that file's `cksum` line. The folder held `README.md` only, untracked |
| S-07.1.e2 | pass | T1 discarded after research ran, in S-05.1.e1's run (Agent tool, model: sonnet / sonnet / opus, Explore). The checkout guard was identical to its baseline: no folder, no file |
| 3.1 | pass | `skills/brainstorm/references/research.md` exists. The awk over `## Phase` headings prints `2 3`: Phases 2 and 3 point to it |
| 3.2 | pass | `wc -l` gives 293. There are 8 `## Phase` headings and `This phase is silent` occurs 0 times. Bootstrap through Phase 1, and Phase 4 to the end, diff empty against `54a2980` |
| 3.3 | pass | Standalone run with no provider reference loaded: the Facilitator loaded `session` and its `references/github.md`, and **List** gave open issues #285, #284, #283 and #97. Then `GH_TOKEN=invalid` was set on the provider command only. It gave `HTTP 401: Bad credentials` with exit 1, so the Facilitator said `Issues: issue host unavailable; going on without open issues.` and the run went on |
| 3.4 | pass | `export TMPDIR=/nonexistent` for one run: `mktemp -d "${TMPDIR:-/tmp}/cold-read.XXXXXX"` failed with `mktemp: failed to create directory via template ... No such file or directory`. The Facilitator said `Research: no research tree (mktemp failed: /nonexistent: No such file or directory); opening without research.`, and Phase 3 opened with no findings. `TMPDIR` was then unset. `git worktree list` showed the checkout only |
| 3.5 | pass | With `GIT_ALLOW_PROTOCOL=none` set on **Base**'s `git fetch origin main` only, the fetch failed (`fatal: transport 'https' not allowed`, exit 128). `origin/main` still resolved, so the line was `Tree from origin/main, not refreshed: fetch failed, may be stale.`, shown with the summary line of S-05.4.e2's run. `{base}`, `{date}` and `{sha}` (`e9b093f`) were resolved once for the run |

Phase 2 timing (prd Assumptions row 6; R3), first dispatch to last report: T1, step S-04.1.e1, about 2 minutes (Scout 60 s, Historian 63 s, Skeptic 112 s). The wave of S-04.2 and S-05.4 steps ran 35–122 s per role, with the Skeptic slowest each time. This is judged at the Retro, with no threshold.

Report lengths, all complete unless forced: Scout 21–35 findings, Historian 9–26, Skeptic 12–19.

## Deviations

| Plan said | Reality | Why | Contract affected (y/n) |
|---|---|---|---|
| S-04.4.e1: "T1 with the Historian's prompt forced short once" | The first forced prompt asked for a report with only `## Sources read` (Agent tool, model: sonnet, Explore). The Historian ignored it and returned a full report, RH1–RH12 with Packs read. The seed was discarded and re-seeded with a prompt asking for one fixed line. That gave the incomplete report the row needs, and its retry did the same | A role follows its card over an instruction to drop sections. The seed, not the step, changed | n |

## Decisions

- `research.md` holds the whole procedure (the research step, issues and commits with the `session` load, the unbuildable-tree, void and tree-removal lines, the summary line, the findings ledger and the opening). `SKILL.md` Phases 2 and 3 only point to it, so the skill grew by 6 lines (287 to 293).
- The no-tree line names the failing command and its error as `{reason}`, for example `mktemp failed: /nonexistent: No such file or directory`.
- When **Base** falls back to `HEAD`, the caveat `(from HEAD, may include unmerged work)` goes beside each Historian finding brought in, as the design's **Research pass** row says. No run in this slice fell back to `HEAD`, so the caveat was not shown live.
- Seeded findings are added to the Facilitator's ledger by hand, after intake, and never to a role's prompt. The role's report stays what it returned.

## Discoveries

- The Skeptic in D's run noted that `plan.md` Slice 5 cites `dispatch.md:203-215` for the fallback paragraphs. Since Slice 1 those lines hold the research completeness check, and **No subagent tool** starts at line 262. Slice 5's preflight should cite the section by name.
- Every research step on a planning-team topic reported `planning-team-discovery` itself as existing work, and its `cold-read.md` as lessons, as Slices 1 and 2 recorded. The Facilitator's opening named it once, as the pack already executing.
- The Skeptic often argues for a ruled-out option without being seeded. In S-05.4.e1's run its own RK11 proposed one dispatch reading past Retros, close to the saved Ruled out. The resume rule named it without help from the seed.
- `zz-dryrun-published` and `zz-dryrun-routed` have no **Ruled out** heading. Phase 3's resume names "what is already under Ruled out", and here there was nothing to name. The Facilitator said so in one clause. Slice 4's resume rows should expect a missing section as well as "None.".
- The Historian's reports stayed complete at five packs, up to 26 findings, so R1 did not show.

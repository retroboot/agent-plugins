# Slice 1 — Research Kind, Historian and Skeptic

| | |
|---|---|
| **Status** | done |
| **Issue** | #281 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (claude-opus-5-5) |
| **Date** | 2026-11-24 |

## Preflight

The branch `issue/281` was cut from `origin/main` at `b0d36c4`. Every dry run was dispatched from this checkout's `skills/` text, by hand.

| Citation (`context.md`, `plan.md` Slice 1) | Holds |
|---|---|
| `skills/planning/references/roles/dispatch.md:9-11` Kind paragraph: `review` or `draft`, "or any other value, is dispatched by no one" | holds |
| `dispatch.md:15-24` Model resolution | holds |
| `dispatch.md:26-58` Prompt frame (review) | holds |
| `dispatch.md:60-70` Base | holds |
| `dispatch.md:90-126` Drafting frame | holds |
| `dispatch.md:161-174` Tree and guard, stop rule at `:170-174` | holds |
| `dispatch.md:186-192` Completeness check; `:194-201` Triage; `:203-218` No subagent tool | holds |
| `skills/cold-read/references/panel.md:13-16` step 1, with `Card {file} states no kind; not dispatched.` | holds |
| `skills/cold-read/references/tree.md:19-30` tree commands, `:41-44` guard | holds |
| `skills/planning/references/roles/scout.md:1-45` card shape, the eight headings | holds |
| `skills/planning/references/roles/planner.md:1-48` card shape | holds |
| Letters in use: E F L N R S T V; H and K free | holds |
| `skills/spec/SKILL.md:131`, `:166`, `:309`, `skills/slice/SKILL.md:112`, `skills/planning/references/gates.md:8-14` name their cards by file | holds |

Skill dir: /home/retroboot/projects/agent-plugins/skills

## Acceptance

Structural rows were run on the branch. Live rows were dispatched with the Agent tool, `subagent_type: Explore`, using the research frame and the card pasted verbatim. Each live row ran in its own detached tree of `origin/main` at `b0d36c4`. The guard (`git status --porcelain --untracked-files=all` in the tree, plus `cksum` of `{path}` when a pack was copied in) ran before and after each dispatch. Every tree was removed afterwards.

| ID | Result | How shown |
|---|---|---|
| S-02.1 | pass | Shown by S-02.1.e1 and S-02.1.e2 |
| S-02.1.e1 | pass | `historian.md` headings `Letter\|Model\|Kind\|Job\|Inputs\|Checklist\|Output\|` under `# Role: Historian` |
| S-02.1.e2 | pass | `Letter=H Model=sonnet Kind=research`; letters `E F H K L N R S T V`; `uniq -d` prints nothing |
| S-02.2 | pass | Shown by S-02.2.e1 to e3 |
| S-02.2.e1 | pass | Historian on T4 (Agent tool, model: sonnet, Explore). RH1 gives the lesson "read every route branch of each phase a slice changes", citing `docs/plans/planning-team-spec/README.md` Retro row 1. Complete: Sources read, Findings RH1–RH17, Packs read with 5 rows. Guard unchanged |
| S-02.2.e2 | pass | Historian on T2 (Agent tool, model: sonnet, Explore). RH1: "No past pack bears on a mobile push-notification service, so this report gives no lesson." Packs read has 5 rows, each with Lessons `none`. Guard unchanged |
| S-02.2.e3 | pass | Historian on T1 with `zz-dryrun-routed` copied in as a past pack (Agent tool, model: sonnet, Explore). RH2: "It has no Ruled out, an empty Retro and no cold-read.md, so it yields no lesson of its own." Its Packs read row: `no (heading present, table empty; no Ruled out) \| no`. Guard unchanged |
| S-02.3 | pass | Shown by 1.5 (the `{path}` side) and S-02.3.e2. S-02.3.e1 is proven in Slice 3 (design §6) |
| S-02.3.e2 | pass | Historian on T6 (Agent tool, model: sonnet, Explore). `planning-team-review` (Status `done`) was read as a past pack. RH1: "Its Status is `done`". Its Packs read row: `yes (6 rows) \| yes (3 rounds)`. Guard unchanged |
| S-03.1 | pass | Shown by S-03.1.e1 and S-03.1.e2 |
| S-03.1.e1 | pass | `skeptic.md` headings `Letter\|Model\|Kind\|Job\|Inputs\|Checklist\|Output\|` under `# Role: Skeptic` |
| S-03.1.e2 | pass | `Letter=K Model=opus Kind=research`; K differs from every other letter, H included |
| S-03.2 | pass | Shown by S-03.2.e1, and by S-03.2.e2 under the developer's amendment (Decisions) |
| S-03.2.e1 | pass | Skeptic on T5 (Agent tool, model: opus, Explore). Under `### Should not be built`, RK8: "The idea repeats a **Ruled out** entry of the parent pack word for word", citing `docs/plans/planning-team/README.md:36-37`. Both tables present. Guard unchanged |
| S-03.2.e2 | pass | Judged by the amended row: "`None found.` is required only under a heading that has no grounded finding". Skeptic on T3 (Agent tool, model: opus, Explore), run twice, each in a new tree. Run 1 gave Could fail RK1–RK6 and Should not be built RK7–RK10. Run 2 gave Could fail RK1–RK5 and Should not be built RK6–RK8. Each finding names its evidence: a `path:line`, the parent's **Ruled out** entry, or a stated line of reasoning (K2). None was invented, both tables are present, and neither heading was empty. Guard unchanged both times |
| S-07.3 | pass | Shown by S-07.3.e1 and S-07.3.e2 |
| S-07.3.e1 | pass | `panel.md` step 1 was walked by hand on a tree holding a copy of `planning-team-review` (Status `done`) as `zz-dryrun-done`, reading this branch's `roles/`. It gives four dispatches: `editor.md`, `fact-checker.md`, `test-engineer.md` and `trust-reviewer.md` |
| S-07.3.e2 | pass | The same walk prints no `Card {file} states no kind; not dispatched.` line. `historian.md` and `skeptic.md` are skipped silently. The text check gives `research` count 1 in step 1 |
| S-07.4 | pass | Shown by S-07.4.e1 and S-07.4.e2 |
| S-07.4.e1 | pass | `grep -n '## Kind'` over spec, slice and gates prints nothing. `skills/spec/SKILL.md` still names `roles/scout.md`, `roles/analyst.md` and `roles/architect.md`. `git diff --stat` over spec, slice, gates and scout prints nothing |
| S-07.4.e2 | pass | `skills/slice/SKILL.md` and `gates.md` name the same cards as before. The diff is empty |
| 1.1 | pass | The Kind paragraph (before `## Model resolution`) names `research` (count 1) and **Research frame** (count 1), and keeps "or any other value, is dispatched by no one." (count 1) |
| 1.2 | pass | "You are the {name} on a planning team. Research a topic for a brainstorm, as your role card says." occurs once in `skills/`, in `dispatch.md` |
| 1.3 | pass | "Research: {role} gave no complete report; not researched by {role}." occurs once in `skills/`, in `dispatch.md` |
| 1.4 | pass | Hand dispatch of the Historian on T3 (Agent tool, model: sonnet, Explore). The forced write `zz-forced-write.txt` was placed in the tree between the guard's two runs. The after-guard showed `?? zz-forced-write.txt`, so the step's report (RH1–RH9) was voided and no finding was brought in. The changed file was named and the tree removed. No `STOPPED` was given (the `STOPPED` count in `dispatch.md` is still 1, the drafting and panel rule), and the run went on |
| 1.5 | pass | Historian on T1 with `zz-dryrun-discovered` copied in as `{path}` (Agent tool, model: sonnet, Explore). Its Packs read lists 5 past packs, and `zz-dryrun-discovered` is not among them: "is the pack being brainstormed and is not listed as a past pack". It opened that README only for the topic, and cites nothing from it as a past pack. The guard (cksum of `{path}` plus tree status) was unchanged |

R2 probe: the Skeptic on T1 (Agent tool, model: opus, Explore) gave 18 grounded findings, RK1–RK18, each with `path:line` evidence. RK14 names the parent's **Ruled out** "The full team on every pack". The probe holds.

Report lengths: Historian T4 17 findings, T2 4, T1 with routed 21, T6 25, 1.4 9, 1.5 19. Skeptic T5 13, T3 10 then 8, T1 18. Every report was complete by the research completeness check.

## Deviations

| Plan said | Reality | Why | Contract affected (y/n) |
|---|---|---|---|
| Slice 1 Verify quoted-line loop `S-03.2.e2 None found.` | The S-03.2.e2 row now quotes the amended rule, which contains `None found.`. No report printed that line, because neither heading was empty | The loop reads a fixed line the original row expected in the output. The amended row makes that line conditional, so the row quotes the condition | n |
| S-03.2.e2: a T3 topic ("correct one misspelled word in a doc") is one the Skeptic finds no reason against, so it says `None found.` under each heading | Twice, the Skeptic found grounded reasons under both headings. Under could fail: no word or file named, a mirrored plugin description, shared allowlist lines, a variant house spelling (`behaviour` in 41 files, `behavior` in 13), and a deliberate fixture typo. Under should not be built: the parent's **Ruled out** "The full team on every pack. A real team holds no design review for a typo", and `planning-redesign` S-03 "a typo fix doesn't get a PRD". Run 2 noted: "the should-not-be-built findings above may be the expected result and not a defect" | The fixture assumed T3 has little to argue against. In this repository, a brainstorm on a typo has recorded reasons against it: the parent pack ruled out a full team for a typo. The card's K3 forbids inventing findings, but these are grounded, not invented | y (stop: S-03.2.e2 is an acceptance row) |

## Decisions

- **Developer answer to the block (2026-11-24): option 2, amend S-03.2.e2.** The answer is posted on #281. A report on a topic with little to argue against passes when every finding is grounded and none is invented. `None found.` is required only under a heading that has no grounded finding. `prd.md` is not edited (README rule 6). The amendment is the first deviation's resolution. Slices 3 to 5 do not re-run T3 (design §6), so no later slice depends on the old wording.

- The research frame's Findings line says "Evidence is what your card accepts: a path:line, or a past pack's Retro row or cold-read.md round". This lets the Skeptic's stated line of reasoning (K2) count, without widening the evidence the frame allows for other roles.
- `panel.md` keeps the `Card {file} states no kind; not dispatched.` line whole on one line, so its fixed-line grep count stays 1.
- The Skeptic's **Output** numbers both tables as one series (`RK1` …), so the Facilitator's renumbering on intake stays per role.

## Discoveries

- Every Historian report was complete on the first dispatch, the largest at 25 findings. R1 (reading load) did not show at today's five packs.
- The Historian and Skeptic each named the dry-run fixtures as fixtures (`zz-dryrun-*`, T3, T5) from `planning-team-discovery/design.md`. A role reading the tree sees the pack's own test strategy. Later slices' dry runs should expect that line and not count it as a miss.
- `planning-team-discovery` is `published` with an empty Retro, so the Historian reads its `cold-read.md` as lessons (T1 RH6–RH12). That is correct under H2 and H3, but it is unexecuted history.

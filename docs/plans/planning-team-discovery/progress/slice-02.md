# Slice 2 — The Scout's research card

| | |
|---|---|
| **Status** | done |
| **Issue** | #282 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (claude-opus-5-5) |
| **Date** | 2026-11-24 |

## Preflight

The branch `issue/282` was cut from `origin/main` at `8b426f7`, with Slice 1 merged as #287. The dry runs were dispatched by hand from this checkout's `skills/` text.

| Citation | Holds |
|---|---|
| `skills/planning/references/roles/dispatch.md` **Research frame**, report, completeness check, and the research pass beside **Tree and guard** (Slice 1) are on `{base}` | holds |
| `skills/cold-read/references/panel.md` step 1 skips a `research` card silently (Slice 1) | holds |
| `skills/planning/references/roles/scout.md:1-45`: Letter S, Kind `draft` | holds |
| `skills/spec/SKILL.md:131`: "dispatch `roles/scout.md` by **Drafting frame**" | holds |
| `skills/planning/references/roles/historian.md` card shape for a research card | holds |
| Letter `O` is unused: card letters are E F H K L N R S T V. No `O{n}` Id prefix appears in `skills/` | holds |

## Acceptance

Live rows were dispatched with the Agent tool, `subagent_type: Explore`, using the research frame and the card pasted verbatim. Each ran in its own detached tree of `origin/main` at `8b426f7`. The tree guard ran before and after each dispatch (`git status --porcelain --untracked-files=all`, no pack copied in), and each tree was removed afterwards.

| ID | Result | How shown |
|---|---|---|
| S-01.1 | pass | Shown by S-01.1.e1, and by S-01.1.e2 under the developer's amendment (Decisions) |
| S-01.1.e1 | pass | Research Scout on T1 (Agent tool, model: sonnet, Explore), on the committed card. RO1 cites `skills/brainstorm/SKILL.md:70-76` ("## Phase 2 — Research Before Responding"). RO9 cites `skills/planning/references/roles/dispatch.md:9-13, 163-201` (Kind paragraph and Research frame). 24 findings. Guard unchanged |
| S-01.1.e2 | pass | Judged by the amended row: the report says nothing in the repository implements or builds toward the topic, and every path it cites is adjacent. Research Scout on T2 (Agent tool, model: sonnet, Explore), on the committed card. Under **Findings**: "The grep found no push-notification, APNs, FCM or device-token content. I found no mobile client, no notification service and no backend of any kind." Each cited path is adjacent: plugin registration, modifier conventions, `audit-security`, unrelated notification references, and the T2 fixture line `docs/plans/planning-team-discovery/design.md:159`. Guard unchanged. All four T2 runs are under Deviations |
| S-01.2 | pass | Shown by S-01.2.e1 and S-01.2.e2 |
| S-01.2.e1 | pass | Structural. `git diff` of `scout.md`, `skills/spec`, `skills/slice` and `gates.md` against the merge base prints nothing. `grep -cF 'dispatch \`roles/scout.md\` by **Drafting frame**' skills/spec/SKILL.md` prints 1, so `spec` Phase 2 drafts `context.md` from the unchanged card, as today |
| S-01.2.e2 | pass | Structural. A research report is never written to a file: the frame says "Change nothing anywhere", and the research card's Output is a report to the Facilitator. So it cannot stand in for the draft, and `spec` still dispatches `roles/scout.md` by **Drafting frame** (count 1) |
| S-07.3 | pass | Shown by S-07.3.e1 and S-07.3.e2 |
| S-07.3.e1 | pass | `panel.md` step 1 was walked by hand on a tree holding a copy of `planning-team-review` (Status `done`) as `zz-dryrun-done`, reading this branch's `roles/` with `research-scout.md` in it. It gives four dispatches: `editor.md`, `fact-checker.md`, `test-engineer.md` and `trust-reviewer.md` |
| S-07.3.e2 | pass | The same walk prints no `Card {file} states no kind; not dispatched.` line. `historian.md`, `research-scout.md` and `skeptic.md` are skipped silently |
| S-07.4 | pass | Shown by S-07.4.e1 and S-07.4.e2 |
| S-07.4.e1 | pass | `grep -n '## Kind'` over spec, slice and gates prints nothing. `skills/spec/SKILL.md` names `roles/scout.md`, `roles/analyst.md` and `roles/architect.md`, as before. The diff is empty |
| S-07.4.e2 | pass | `skills/slice/SKILL.md` and `gates.md` name `roles/planner.md` and `roles/dispatch.md` only, as before. The diff is empty |
| 2.1 | pass | `# Role: Scout`, headings `Letter\|Model\|Kind\|Job\|Inputs\|Checklist\|Output\|`, and `Letter=O Model=sonnet Kind=research`. Letters `E F H K L N O R S T V`, none repeated. Kind `research` count 3 |
| 2.2 | pass | `git diff` of `skills/planning/references/roles/scout.md` against the merge base prints nothing |

## Deviations

| Plan said | Reality | Why | Contract affected (y/n) |
|---|---|---|---|
| S-01.1.e2: on T2 the research Scout "says nothing exists that the topic touches, and cites no path" | Over four T2 runs (Agent tool, model: sonnet, Explore), every report said nothing in the repository implements the topic, and three of the four also cited adjacent paths. Run 3, on a revised O3 that gave evidence `none`, cited no path. Review of #288 found that form collides with the research completeness check ("a finding has no evidence"). Run 4, on the committed O3, cited adjacent paths, including this pack's own `design.md:159`, which names T2 as a fixture. The developer amended the row (Decisions) | Two causes. The Scout counts conventions every change meets, and since this pack merged, the repository names T2 itself, so it is no longer a topic the repository has nothing on | y (resolved by the developer's amendment) |
| (first card text, detail) | The first card text missed twice (Agent tool, model: sonnet, Explore). Each run said nothing covers push notifications (run 1 RO2, run 2 RO1), then cited 12 and 15 adjacent paths: modifier conventions, `audit-security`, a Slack-webhook CI sample, `.env.example`, and plugin registration. By the Pass rule, the second miss is a deviation | The first O1 and O3 left "touches" undefined, so the Scout counted conventions every change meets. The card was revised within the design row ("when nothing is found the report says so and cites no path"). O1 now defines "touches" as what the work would read, change or depend on, and excludes conventions every change meets. O3 now asks for one finding with evidence `none`. Both rows were then run again on the committed card, and both passed | n |

## Decisions

- **Developer decision (2026-11-24): amend S-01.1.e2.** This is recorded on #282. On a topic the repository has no work toward, a report passes when it says nothing in the repository implements or builds toward the topic, and every path it cites is adjacent (a convention every change meets, or a fixture that names the topic), not existing work. `prd.md` is not edited (README rule 6). Slices 3 to 5 do not re-run S-01.1.e2 (design §6).
- O3, as committed, puts the nothing-found sentence under **Findings** in place of the table, with no finding row. That form needs no evidence, so it cannot trip the research completeness check (review of #288).

- O1 defines "touches" as "what the work would read, change or depend on". A convention every change meets does not touch a topic on its own. This keeps T1's citations (the brainstorm phases and dispatch sections the work changes) and drops T2's incidental ones.
- O5 (no issues, no pull requests, no network) restates design §2's "it reads no issues and no network" as a card line. ADR-002 puts issue reading on the Facilitator.

## Discoveries

- The research Scout does not always open what it cites. In the first T1 run, RO19 cited `skills/cold-read/references/tree.md` "not opened by me, taken from the design". In the T1 run on the committed card, several ranges lie past the end of the file: `historian.md:60-91` (the file has 46 lines), `skeptic.md:106-135` (45 lines), and ADR lines up to 289 (ADR-009 has 32). The citations the row needs held. O2 is on the card, but the Facilitator should not take a research `path:line` as checked. This bears on Slice 3's intake, and on the Retro.
- Each Scout run read `planning-team-discovery` itself and described this pack's own slices and ADRs as existing work. On a new topic that matches an executing pack, the Scout reports the pack. That is correct, since the pack is repository content.

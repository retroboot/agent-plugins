# Slice 1 — Every skill's bootstrap names a skill its plugin ships

| | |
|---|---|
| **Status** | done |
| **Issue** | #310 |
| **PR** | this PR |
| **Executor model** | Claude Opus 5.5 (`claude-opus-5-5`), via `ship-issue docs/plans/bootstrap-skills-shipped` |
| **Date** | 2026-11-25 |

## Preflight

`git diff --name-only d05a4ab HEAD` at branch creation (`HEAD` = `caac77e`) listed only the six files
of this pack, so every citation in `context.md` outside `docs/plans/bootstrap-skills-shipped/` reads
at `HEAD` exactly as at `d05a4ab`.

| Citation | Holds |
|---|---|
| `.claude-plugin/marketplace.json:17`, `:37-43`, `:51-59` (where `core`, `auditor` and `planner` skills sit) | yes |
| `skills/audit/SKILL.md:20-23`, `skills/brainstorm/SKILL.md:26-29`, `skills/spec/SKILL.md:36-39`, `skills/slice/SKILL.md:38-41`, `skills/cold-read/SKILL.md:40-43` (one `core` step each) | yes |
| `skills/planning/SKILL.md:46-51` (three steps), `:183` (unnumbered `Load the`) | yes |
| `skills/work-issue/SKILL.md:16-21` (bootstrap wording) | yes |
| `skills/ship-pr/SKILL.md:57` (numbered step outside `## Bootstrap`) | yes |
| `docs/verification.md:61-76` (check 6), `:95-102` (check 8), `:200-215` (table), `:219-239` (mechanics), `:277` (bootstrap value) | yes |
| `CLAUDE.md:118`, `:125`, `:138`, `:221` | yes |
| `README.md:21`, `:42-50`, `:52-62` | yes |
| `skills/init/SKILL.md:425-434`, `skills/init/references/git-hygiene.md:64-72`, `skills/init/references/config.md:344-352` | yes |
| The comparison (first Verify command) before any edit | yes: exactly the six `GAP … loads core` lines of `context.md` §4, so stop condition 2 did not trigger |
| The checks before any edit | yes: `structural checks pass`, exit 0 |

## Acceptance

"V*n*" is the *n*th command of the README Slice's **Verify** block; dry runs are the second block.
All were run on the finished tree on 2026-11-25.

| ID | How it was shown | Result |
|---|---|---|
| 1.1 | V1, the comparison | no output |
| 1.1.e1 | V1 | no `GAP auditor/audit` line |
| 1.1.e2 | V1 | no `GAP planner/{brainstorm,spec,slice,cold-read}` line |
| 1.1.e3 | V1 | no `GAP planner/planning` line |
| 1.1.e4 | V1, after the fix; and the baseline dry run at `d05a4ab` before it | no `GAP dev/…` line in either |
| 1.1.e5 | dry run appending the unnumbered sentence "Then Load the `debug` skill …" to `skills/spec/SKILL.md` | `0` `BOOTSTRAP GAP` lines; its numbered control gives `1` |
| 1.1.e6 | baseline dry run in a detached worktree at `d05a4ab` | exactly the six `GAP … loads core` lines, in `context.md` §4's order |
| 1.1.e7 | V1 | no output |
| 1.1.e8 | V1 scans every numbered line of `skills/ship-pr/SKILL.md`, including `:57`; dry run removing `./skills/review-pr` from `dev` | no `GAP` line on the real tree; the dry run reports `BOOTSTRAP GAP dev/ship-pr loads review-pr` (`1`) |
| 1.2 | V3, V4 | `dev true`, `auditor true`, `planner true`; `skills/core` only |
| 1.2.e1 | V3 | `auditor true`, `planner true` |
| 1.2.e2 | V3 | `dev true` |
| 1.2.e3 | V4 | `skills/core` only: one source of `core`'s rules |
| 1.3 | V2 | `structural checks pass`: check 6 reports nothing |
| 1.3.e1 | V2; `git diff` shows the `dev` and `data-platform` arrays unchanged | check 6 silent |
| 1.3.e2 | V2, after `core` was added to `planner` and `init`, `session`, `core` to `auditor` in all three files | check 6 silent |
| 1.3.e3 | dry run adding `./skills/debug` to `planner` in `marketplace.json` only | `SKILLS DRIFT planner claude` (`1`) |
| 1.4 | check 15 added at the end of the fence (`docs/verification.md`), row 15 in the table, `Fifteen checks:` in `CLAUDE.md`; V7 | `1`, `1` |
| 1.4.e1 | V2 | `structural checks pass`, exit 0 |
| 1.4.e2 | on the real tree before the list fix (Suggested path step 2): the six `BOOTSTRAP GAP … loads core` lines beside `CHECK COUNT DRIFT CLAUDE.md says fourteen, verification doc has 15`, exit 1; dry run removing `core` from `planner` and `auditor` | dry run: `6`; a dry run removing it from `auditor` alone exits 1 |
| 1.4.e3 | dry run removing `./skills/review-pr` from `dev` | `BOOTSTRAP GAP dev/ship-pr loads review-pr` (`1`): the check covers `dev` |
| 1.4.e4 | unnumbered `debug` sentence dry run, and the numbered control | `0`, then `1` (`BOOTSTRAP GAP planner/spec loads debug`) |
| 1.4.e5 | dry run setting `CLAUDE.md` back to `Fourteen checks:` | `CHECK COUNT DRIFT` (`1`) |
| 1.4.e6 | V2: the loader runs the block with `</dev/null`; check 15 reads only pipes, never stdin | same result as 1.4.e1 |
| 1.4.e7 | dry run removing `./skills/review-pr` from `dev` | `BOOTSTRAP GAP dev/ship-pr loads review-pr` (`1`), and the block exits 1 |
| 1.5 | V9, V10, V11, V12, and reading the cited sentences | below |
| 1.5.e1 | V9 (no output, exit 1); read `git-hygiene.md:64-72` and `init/SKILL.md:429-435` | neither names a plugin as lacking `core`; the reason given is that `init` runs before any `core` load and keeps the rule in its own file |
| 1.5.e2 | V10 (`0`); read `config.md:344-351` | no skill is named as loading only `core`; it says every skill that reads config loads `init` first, or runs only under one that does (`wave`) |
| 1.5.e3 | V11 (`1`, `1`); read `README.md:21`, `CLAUDE.md:138` | both name `auditor` |
| 1.5.e4 | V12 | no output: `docs/plans/move-to-retroboot/` and `RELEASE-NOTES.md` unchanged |
| 1.6 | V6, V5 | below |
| 1.6.e1 | V6 | `spec`, `slice`, `cold-read`, `brainstorm`, `audit`: `init session core` |
| 1.6.e2 | V5 | `./skills/init`, `./skills/session`, `./skills/core`, then the five `audit` skills in their existing order |
| 1.6.e3 | dry run removing `./skills/init` from `auditor` | `BOOTSTRAP GAP auditor/audit loads init` (`1`) |
| 1.6.e4 | V6 | `planning: init session core`, unchanged |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Suggested path step 2: "The dry runs run after the commit, against `HEAD`" | Ran before the commit, in a detached scratch worktree at `HEAD` with the uncommitted diff applied and committed there as a throwaway commit; the dry-run commands themselves ran unchanged | the proofs belong in this progress file, which goes in the same commit as the fix (README rule 7); running them first keeps that one commit. The tree they ran against is byte-for-byte the committed fix minus this file and the pack README | n |
| C3 and the comparison read `skills/{name}/SKILL.md` and compare `./skills/{name}` | Check 15 reads `{registered path}/SKILL.md` and compares skill names by basename | every registered path is `./skills/{name}` (check 2), so the two agree; reading the registered path avoids building it a second way | n |
| 1.5.e3: `README.md:21` names `auditor` | It also says `core` is shared by the same three plugins | the `core` rows added to the `auditor` and `planner` tables read "Shared setup skill — see `dev`", and the sentence above the tables is where a reader learns which skills those are | n |

## Decisions

- **Check 15's wording in `CLAUDE.md:221`.** Appended as the last item of the existing sentence, in
  the same "; and every …" form the sentence already uses, naming the check by "numbered `Load the`
  step" rather than quoting the full pattern, which would nest backticks.
- **Check 15 skips a skill whose `SKILL.md` is missing** with a comment saying check 2 reports it,
  as C3's Errors column says; without the skip, `sed` would write an error to stderr that the
  loader collects as a failure line.
- **`config.md` names `wave`** as the one config-reading skill that does not load `init` itself,
  because it runs only under `work-issue` (`skills/wave/SKILL.md:18-21`, `context.md` §1).

## Discoveries

- `init` Phase 2 says to skip label bootstrap when "`repoProvider` is not `github`", and Phase 1
  reads `repoProvider` from global `providerConfig` only. On this machine the global value is
  `gitlab` while `.agent-plugins.json` says `"provider": "github"`, so a literal reading skips label
  bootstrap for a GitHub repo. This run resolved the provider per key, as `session` does, and
  bootstrapped. Worth an issue: Phase 2 should name the resolved repo provider.
- Review round 1 on the PR (3 deferred, 0 blocking or required) found that "`init` runs before any
  `core` load" is false in composed runs (`ship-issue` loads `core`, then `work-issue` runs `init`);
  the reason now says the calling skill's own `core` step. It also found `CLAUDE.md:138` not naming
  `core` beside `README.md:21`; both now do. Its third finding, that `audit` now loads `session` but
  its Phase 7 still names `gh issue create` directly (`skills/audit/SKILL.md:124,134`), predates
  this slice and is outside its files: left for a follow-up issue.
- After the move to `retroboot`, global `providerConfig.bootstrappedRepos` still listed
  `hivrr/agent-plugins` and not `retroboot/agent-plugins`, so `init` re-ran the (idempotent) label
  bootstrap here. Every label already existed.

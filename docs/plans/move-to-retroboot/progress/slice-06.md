# Slice 6 — Release v2.0.0 and switch the users

| | |
|---|---|
| **Status** | done |
| **Issue** | #302 |
| **PR** | this PR |
| **Executor model** | claude-opus-5-5 |
| **Date** | 2026-11-26 |

Confirmed (retroboot): 2026-11-26

Confirmed (cedwards-plk): 2026-11-26

## Preflight

| Citation | Holds? |
|---|---|
| Slice 5 merged | holds: `cc1f246` (#308) on `origin/main`, and it is the last commit touching `.claude-plugin/marketplace.json` |
| `retroboot/agent-plugins` public | holds: `gh repo view --json visibility` → `PUBLIC` |
| `v1.6.0` is an annotated tag (the pattern) | holds: `git cat-file -t v1.6.0` → `tag`; no `v2*` tag existed |
| Transfer date in `progress/slice-05.md` | `Dates (UTC): transfer 2026-11-26, remote 2026-11-26, merge 2026-11-26` |

## Slice 5's post-merge checks

Run on `main` at `cc1f246` straight after the merge, as Slice 5's Verify asks:

| Check | Result |
|---|---|
| S-07.2, S-07.2.e1: fresh detached worktree of `HEAD`, `grep -rIl -i "hivrr" --exclude-dir=.git --exclude-dir=plans . \| sort` | `RELEASE-NOTES.md`, `skills/init/SKILL.md`, `skills/init/references/config.md`; structural checks pass there |
| S-07.3, S-07.3.e1: `git diff --name-only 749feb9 -- docs/plans/` plus untracked, filtered to paths outside this pack | no output, exit 1 |

## Acceptance

| ID | How it was shown |
|---|---|
| 6.1 | `git tag -a v2.0.0 -m v2.0.0 cc1f246`, pushed. `git cat-file -t v2.0.0` → `tag`; `git rev-list -n1 v2.0.0` and `git log -1 --format=%H -- .claude-plugin/marketplace.json` both → `cc1f2464b0dcf5599e1d9805b2750e4664298f00`. `gh release create v2.0.0 --title v2.0.0 --notes-file {the ## v2.0.0 entry body} --verify-tag` → https://github.com/retroboot/agent-plugins/releases/tag/v2.0.0 |
| 6.2 | fresh detached worktree of `v2.0.0`: the bootstrap string → `structural checks pass`, exit 0; the `hivrr` grep → the three allowed files only |
| S-01.7 (release and users side), S-01.7.e1 | `gh release view v2.0.0 --json tagName,publishedAt` → `v2.0.0 2026-11-26T00:40:02Z`, the same date as the transfer; both `Confirmed` lines are dated 2026-11-26 |
| S-02.2.e2 | the maintainer ran `/plugin install dev@agent-plugins` while `hivrr-agent-plugins` was still the registered marketplace; it failed as unknown (maintainer's report, 2026-11-26) |
| S-02.2, S-02.2.e1 (`retroboot`) | after the four release-entry steps, on this machine at 2026-11-26T00:46:55Z: `jq -e 'has("agent-plugins") and (has("hivrr-agent-plugins") \| not)' ~/.claude/plugins/known_marketplaces.json` → `true`; `jq -e '[… select(endswith("@hivrr-agent-plugins"))] \| length == 0' ~/.claude/settings.json` → `true`; `jq -e '[… select(endswith("@agent-plugins"))] \| length > 0' ~/.claude/settings.json` → `true`. Enabled: `auditor@agent-plugins`, `dev@agent-plugins`, `planner@agent-plugins`; marketplace source `{"source": "github", "repo": "retroboot/agent-plugins"}` |
| S-02.2, S-02.2.e1 (`cedwards-plk`) | the maintainer ran the same steps as `cedwards-plk` and reported that every install and all three `jq -e` checks passed, with no errors (2026-11-26) |
| 6.3 | the two `Confirmed` lines above |
| 6.4 | the pack README's Retro holds eight rows in place of the placeholder, and its Status is `done` |

The `design.md` §8 P7 check printed nothing, exit 1.

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| The `cedwards-plk` `jq -e` output is recorded verbatim | The maintainer reported the result ("all tests worked including cedwards-plk … no errors") instead of pasting the three lines | That account's `~/.claude` is not reachable from this session | n |

## Decisions

- The release body is the `## v2.0.0` entry without its heading, as cold read round 2 (bQ14)
  defaulted.

## Discoveries

- The follow-up the cold read raised in round 3 (aQ10) still stands: `spec`, `slice`, `cold-read`,
  `brainstorm` and `audit` load only `core`, and sit in plugins that do not ship `core`. That
  deserves its own issue now that the move is done.

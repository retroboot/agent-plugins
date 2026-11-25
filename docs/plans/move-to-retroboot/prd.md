# PRD — Move to retroboot and drop the hivrr name

## Problem

The repository and its public contracts carry the name of an organization that is being
repurposed.

1. **The home is going away.** The repository is `hivrr/agent-plugins`, a private repository in the
   `hivrr` organization (`context.md` §1, Where the repository's home appears). The organization is
   being repurposed and keeps none of this repository's history (README Brief). The redirect from
   the old URL lasts only until the organization creates a repository with that name (README Key
   insights).
2. **The old name is part of the contracts.** The marketplace is named `hivrr-agent-plugins`, so
   every install ID ends in it (`context.md` §2.1). The per-repo config file is `.hivrr.json`, read
   by `init` and seventeen reader files (`context.md` §2.2, §2.3). The heredoc and verification
   markers are `HIVRR_*` (`context.md` §2.4). In all, 31 tracked files outside `docs/plans/` hold
   `hivrr` (`context.md` §1, Where `hivrr` appears).
3. **Renaming the config file alone would break repos silently.** Dozens of repos may hold a
   `.hivrr.json`. An absent config file is not an error: every key resolves from its fallback
   (`context.md` §3, Config-file tests). So skills that read only the new name would quietly drop
   each repo's branch, board and verify settings to defaults (README Key insights).
4. **Some of the docs are already wrong.** The README Setup block and `.env.example` describe a
   GitHub Packages registry and `hivrr/manager-plugin` and `hivrr/data-platform-plugin`
   repositories. That is not how the plugins ship (`context.md` §2.1).
5. **Unused workflows remain.** `.github/workflows/claude.yml` and
   `.github/workflows/claude-code-review.yml` are not used and reference a secret the developer does
   not maintain (`context.md` §2.6).

## Users and jobs

- **Maintainer:** `retroboot`, who owns the repository, moves it and cuts its releases.
- **Installing user:** one of the two people who install these plugins in Claude Code, `retroboot`
  and `cedwards-plk`, which is the maintainer's own second account (developer, cold read panel,
  2026-11-25). Both are reachable by the maintainer, who holds both accounts.
- **Skill run:** a Claude Code agent running a workflow skill in a repository that may hold a config
  file.

**Jobs.**

- Maintainer: "When the `hivrr` organization is repurposed, I want the repository under my own
  account with its history and records intact, so I can keep shipping without depending on the
  organization."
- Installing user: "When I install or update the plugins, I want one marketplace name with no tie
  to an organization, so I can switch once and not think about it again."
- Skill run: "When I start in a repository configured under the old name, I want its config carried
  over to the new name before I read it, so I can keep its branch, board and verify settings."

## Goals

- G1. The repository lives at `retroboot/agent-plugins` with all its history and GitHub records.
- G2. Users install the plugins from a marketplace named `agent-plugins`.
- G3. Every skill reads its per-repo config from `.agent-plugins.json`, with the same schema.
- G4. A repository that holds `.hivrr.json` keeps its settings, migrated the first time `init`
  runs there after the upgrade.
- G5. No `hivrr` string remains in the tracked tree outside the historical record, and the
  structural checks pass.

## Non-goals

- Copying the repository with `git push --mirror` instead of transferring it (README Ruled out).
- Keeping any copy, fork or content in the `hivrr` organization after the transfer.
- Moving org-level items: teams, org secrets and org Projects boards (README Key insights).
  `CLAUDE_CODE_OAUTH_TOKEN` is a repository secret, deleted before the repository goes public
  (S-01.5).
- Relying on the GitHub redirect from `hivrr/agent-plugins` for remotes or the marketplace source.
- A dual-read fallback that lets reader skills fall back to `.hivrr.json` (README Ruled out).
- Removing the `init` migration again. That comes in a later release, outside this plan (README
  Ruled out).
- Changing the config schema, its keys or its defaults.
- Renaming the plugins (`dev`, `auditor`, `planner`, `data-platform`) or changing their per-plugin
  descriptions.
- Rewriting the `hivrr` strings in the historical packs under `docs/plans/` (README Key insights).
- Editing users' `~/.claude/settings.json` or `known_marketplaces.json` automatically. Each user
  switches marketplaces by hand once, and the stale `hivrr/agent-plugins` entry in
  `bootstrappedRepos` is left in place.
- Changing `init`'s phase count. It stays at seven.

## Success measures

- M1. `gh repo view retroboot/agent-plugins` succeeds. Its issue, pull request, label, milestone,
  tag and release counts equal the counts read from `hivrr/agent-plugins` before the transfer.
- M2. Both installing users have `agent-plugins` in their known marketplaces and no
  `hivrr-agent-plugins`. Their enabled plugins end in `@agent-plugins`. The maintainer switches
  `cedwards-plk` (their own second account) as well, and both confirmations are recorded in the last
  slice's progress file; if the `cedwards-plk` one is missing 7 days after the release, a deviation is
  recorded instead (developer, cold read panel, 2026-11-25).
- M3. `grep -rIl -i "hivrr" --exclude-dir=.git --exclude-dir=plans .` lists only the allowed files
  (S-07.2). Today it lists 31.
- M4. After its first run of an `init`-loading skill, each repository the users work in holds
  `.agent-plugins.json` and no `.hivrr.json`. Its `.gitignore` names `.agent-plugins.json` and not
  `.hivrr.json`, except where Phase 3 kept both files (S-04.8, S-05.7) until a later run.
- M5. On a fresh tree of the released commit, the bootstrap string in `docs/verification.md` prints
  `structural checks pass` and exits 0.

## Non-functional requirements

| Quality | Target |
|---|---|
| Performance | none: the migration is one file test and one rename per `init` run |
| Reliability | No config is lost. After the migration, `.agent-plugins.json` holds exactly the bytes `.hivrr.json` held. A repository that starts with a config file never ends with neither, and never loses its only valid one. A second `init` run changes nothing |
| Security | The config file stays out of git: 0 tracked `.agent-plugins.json` files in any repository after `init` Phase 6. After the two workflows are deleted, no tracked file references `CLAUDE_CODE_OAUTH_TOKEN` |
| Privacy | none: no personal data is read, moved or written. The config holds branch, board and command settings |
| Accessibility | none: there is no UI. Output is plain `INIT:` text lines |
| Observability | Every migration and every `.gitignore` swap emits exactly one `INIT:` line. A run that migrates nothing emits no migration line |
| Compatibility / portability | Clean cut. Each of the 2 users switches marketplaces once. No skill reads `.hivrr.json` except `init`'s migration. The config schema is unchanged, so a migrated file needs no edits |
| Maintainability | All 14 structural checks pass. `init` keeps seven phases, so checks 7 and 10 do not change (`context.md` §4) |

## Assumptions

| Assumption | How to validate | If false | Probe |
|---|---|---|---|
| A GitHub transfer keeps issues, pull requests, labels, milestones, tags and releases, and redirects the old URLs | Before and after the transfer, read the counts with `gh issue list --state all`, `gh pr list --state all`, `gh label list`, `gh api repos/{owner}/agent-plugins/milestones?state=all`, `git ls-remote --tags` and `gh release list`, then compare them | Records are lost in the move. Stop before the transfer and re-plan it | not run: changes state. Baseline read 2026-11-25: 154 issues, 138 PRs, 30 labels, 0 milestones, 5 tags, 2 releases |
| `retroboot` has no repository named `agent-plugins` when the transfer runs | `gh repo view retroboot/agent-plugins` fails with "not found" just before the transfer | GitHub refuses the transfer. The existing repository must be renamed or removed first | held: `gh repo view retroboot/agent-plugins` → "Could not resolve to a Repository" (2026-11-25; re-check just before the transfer) |
| The maintainer may transfer repositories out of `hivrr`: admin on the repository, and the organization allows transfers | `gh api repos/hivrr/agent-plugins --jq .permissions.admin` prints `true`, and the transfer page offers `retroboot` as the destination | An organization owner must change the setting or do the transfer | held: `.permissions.admin` → `true`; `gh api user/memberships/orgs/hivrr --jq .role` → `admin` |
| This repository uses no org-level teams, secrets or Projects boards that the transfer would leave behind | `gh api repos/hivrr/agent-plugins/teams` is empty. `gh secret list --repo hivrr/agent-plugins` lists nothing the remaining files use. `CLAUDE.md` records no project board | Something the repository relies on stays in `hivrr` and must be recreated under `retroboot` | held: teams → 0; secrets → `CLAUDE_CODE_OAUTH_TOKEN` only, used solely by the two workflows being deleted; `CLAUDE.md:172` records no board |
| Claude Code accepts a marketplace named `agent-plugins` with install IDs `{plugin}@agent-plugins`, served from `retroboot/agent-plugins`, and neither user already has a marketplace with that name | Add the marketplace from a local checkout of the renamed tree in a scratch Claude Code session, install `dev@agent-plugins`, and read `~/.claude/plugins/known_marketplaces.json` for each user | The new name collides or is rejected. Choose another marketplace name | not run: changes state. Maintainer's `known_marketplaces.json` lists only `claude-plugins-official` and `hivrr-agent-plugins` (2026-11-25) |
| Only two people install these plugins | `gh api repos/hivrr/agent-plugins/collaborators --jq '.[].login'`, and asking the maintainer | Unknown installers break on the clean cut. They need a notice or a fallback period | false: collaborators → `retroboot`, `cedwards-plk`, `bschappaugh-plk` (three, not two). Answered (answered at the acceptance checkpoint, 2026-11-25): the installers are `retroboot` and `cedwards-plk`; the repository goes public, and the other collaborators are removed |
| Users run an `init`-loading skill in a repository before `spec`, `slice`, `cold-read`, `brainstorm` or `audit` reads its config there (`context.md` §1, Who loads `init`) | Compare the skill list in `context.md` §1 with how the users start work. `planning`, which wraps `spec` and `slice`, loads `init` | Those skills treat the repository as unconfigured until an `init`-loading skill runs (accepted at the acceptance checkpoint) | held in part: `skills/planning/SKILL.md:49` loads `init`; the five others load only `core`. How users start work: not run, needs the maintainer |
| Until the remotes are updated, the redirect from `hivrr/agent-plugins` serves `git fetch` and marketplace updates | After the transfer, run `git fetch` in a clone whose remote still names `hivrr/agent-plugins` | Clones and installs fail at once. Remotes and marketplaces must be switched straight after the transfer | not run: needs the transfer done |

## Stories and acceptance criteria

### S-01 Move the repository home

As the maintainer, I want the repository transferred to `retroboot/agent-plugins` and the unused
workflows removed, so that it no longer depends on the `hivrr` organization.

- **S-01.1** Given `hivrr/agent-plugins` exists and `retroboot/agent-plugins` does not, when the
  maintainer transfers the repository, then `gh repo view retroboot/agent-plugins` succeeds. Its
  issue (all states), pull request (all states), label, milestone, tag and release counts equal the
  counts read before the transfer.
- **S-01.2** Given the transfer is done, when `git remote -v` runs in the maintainer's checkout, then
  `origin` names `retroboot/agent-plugins` and not `hivrr/agent-plugins` (`context.md` §1, Where the
  repository's home appears).
- **S-01.3** Given the tree after this work, when `.github/workflows/` is listed, then
  `claude.yml` and `claude-code-review.yml` are absent. No tracked file outside `docs/plans/` names
  either one or `CLAUDE_CODE_OAUTH_TOKEN` (`context.md` §2.6).
- **S-01.4** Given the transfer is done and `bootstrappedRepos` still lists `hivrr/agent-plugins`,
  when `init` runs in this repository, then Phase 2 treats `retroboot/agent-plugins` as a new
  repository. It creates the labels with `--force` without error and appends the new entry
  (`context.md` §2.2, Phase 2 row; §3, Repo identity for labels).
- **S-01.5** Given the transfer is done, when the maintainer prepares to publish, then the counts
  read before the transfer are recorded in the transfer slice's progress file, the repository secret
  `CLAUDE_CODE_OAUTH_TOKEN` is deleted, and every collaborator other than `retroboot` is removed
  after a clean history scan and before the visibility change (ADR-010).
- **S-01.6** Given the full git history of every branch and tag, when it is scanned for credentials
  before the visibility change, then no live secret is found; only then is
  `retroboot/agent-plugins` made public. A finding stops the slice before the visibility change.
- **S-01.7** Given the work is released, when the steps are ordered, then the transfer, the
  maintainer's remote switch, the release (the `marketplace.json` rename merged, tagged `v2.0.0`),
  and the users' marketplace switch happen on the same day, in that order.

### S-02 Install from the `agent-plugins` marketplace

As an installing user, I want to install the plugins from a marketplace named `agent-plugins`, so
that my install IDs carry no organization name.

- **S-02.1** Given `.claude-plugin/marketplace.json`, when it is read, then `name` is
  `agent-plugins` and `owner.name` is `retroboot`. `metadata.description` contains no `Hivrr`. The
  four plugin entries `dev`, `auditor`, `planner` and `data-platform` are unchanged
  (`context.md` §2.1).
- **S-02.2** Given a user who has removed the `hivrr-agent-plugins` marketplace, when they add the
  marketplace from `retroboot/agent-plugins`, then `dev@agent-plugins`, `planner@agent-plugins`,
  `auditor@agent-plugins` and `data-platform@agent-plugins` each install.
- **S-02.3** Given `README.md` and `.env.example`, when they are read, then the Setup block says to
  add the `agent-plugins` marketplace from `retroboot/agent-plugins` and to install each plugin as
  `{plugin}@agent-plugins`. Neither file mentions GitHub Packages, `hivrr/agent-plugin`,
  `hivrr/manager-plugin` or `hivrr/data-platform-plugin`. The `.env.example` header no longer reads
  `hivrr-agent-plugin` (`context.md` §2.1).
- **S-02.4** Given `RELEASE-NOTES.md`, when its top entry is read, then it is headed `v2.0.0`,
  `marketplace.json` `metadata.version` is `2.0.0`, and the entry names the new marketplace, the new
  install IDs and the new config filename. It also gives the one-time steps each user takes: uninstall each
  `@hivrr-agent-plugins` plugin, remove `hivrr-agent-plugins`, then add `agent-plugins` from `retroboot/agent-plugins` (`context.md` §2.5).
- **S-02.5** Given the renamed marketplace, when the structural checks run, then check 5 passes:
  the `CLAUDE.md` plugin descriptions still match `marketplace.json` (`context.md` §4).

### S-03 Skills read `.agent-plugins.json`

As a skill run, I want every config read to use `.agent-plugins.json`, so that one filename with no
organization name holds each repository's settings.

- **S-03.1** Given a repository holding `.agent-plugins.json`, when any skill that reads
  `.hivrr.json` today (`context.md` §2.2, §2.3) reads its config, then it reads the same keys, with
  the same schema and defaults, from `.agent-plugins.json`.
- **S-03.2** Given a repository holding only `.hivrr.json`, when a skill other than `init` reads
  its config before `init` has migrated it, then the skill does not read `.hivrr.json`. It resolves
  every key as it does for an absent file (`context.md` §3, Config-file tests).
- **S-03.3** Given any commit on the integration branch, when its skills are read, then a skill reads
  `.agent-plugins.json` only if `init` Phase 3 in that same commit holds the migration (README Key
  insights).
- **S-03.4** Given this repository's `.gitignore`, `skills/init/references/config.md` and
  `README.md`, when they are read, then `.gitignore` names `.agent-plugins.json` and not
  `.hivrr.json`. Both schema examples give `"owner": "your-org"` under `project`
  (`context.md` §2.2, §2.5).

### S-04 `init` migrates the old config file

As a skill run, I want `init` to carry an old `.hivrr.json` over to `.agent-plugins.json`, so that
the repository keeps its settings without anyone editing it.

- **S-04.1** Given a repository with `.hivrr.json` and no `.agent-plugins.json`, when `init` Phase 3
  runs, then `.agent-plugins.json` holds exactly the bytes `.hivrr.json` held and `.hivrr.json` no
  longer exists. `init` emits the one line `INIT: upgraded .hivrr.json to .agent-plugins.json`, asks
  no question, including in `--auto` mode, and goes on to validate the file as Phase 3 does today
  (`context.md` §2.2, Phase 3 row).
- **S-04.2** Given a repository with both `.hivrr.json` and a valid `.agent-plugins.json`, when
  `init` Phase 3 runs, then `.agent-plugins.json` is unchanged, `.hivrr.json` no longer exists, and
  `init` emits the one line `INIT: removed .hivrr.json (.agent-plugins.json kept)`.
- **S-04.3** Given a repository with neither file, when `init` Phase 3 runs, then it scaffolds as
  it does today, under the new name, and emits no migration line (`context.md` §2.2, Phase 3 row).
- **S-04.4** Given a repository with only `.agent-plugins.json`, when `init` runs, then no file is
  renamed or removed, no migration line is emitted, and Phase 3 emits
  `INIT: .agent-plugins.json ok` when the file parses.
- **S-04.5** Given a migrated `.agent-plugins.json` that does not parse, when Phase 3 validates it,
  then `init` stops with its malformed-config line naming `.agent-plugins.json`. It neither repairs
  nor deletes the file (`context.md` §3, Config-file tests).
- **S-04.6** Given the changed `init`, when its `## Phase` headings are counted, then there are
  seven. The count word in `skills/init/SKILL.md` and `CLAUDE.md` still says seven, and checks 7 and
  10 pass (`context.md` §2.5; §3, Phase headings and counts).
- **S-04.7** Given a repository holding only `.hivrr.json`, when any skill that loads `init` as its
  first bootstrap step runs (`context.md` §1, Who loads `init`), then the migration finishes before
  the first phase that reads the config (`context.md` §1, Run order inside `init`).
- **S-04.8** Given both files exist and `jq` is not installed, when `init` Phase 3 runs, then both
  files are kept, nothing is deleted, and `init` reports `.agent-plugins.json` present but
  unvalidated, as it does today for a lone file.
- **S-04.9** Given the rename or the removal fails, or either config path is not a regular file, when
  `init` Phase 3 runs, then `init` stops with one `INIT:` error line naming the path and the
  operation, and leaves both paths as they were.

### S-05 `init` swaps the `.gitignore` line

As a skill run, I want `init` Phase 6 to replace the old ignore line with the new one, so that the
new config file stays out of git and no `hivrr` line is left behind.

- **S-05.1** Given a `.gitignore` with a line `.hivrr.json`, when `init` Phase 6 runs, then that line
  becomes `.agent-plugins.json`, every other line of `.gitignore` is unchanged, and
  `git check-ignore -q .agent-plugins.json` succeeds.
- **S-05.2** Given a `.gitignore` with no `.hivrr.json` line, in which `.agent-plugins.json` is not
  ignored, when Phase 6 runs, then one `.agent-plugins.json` line is appended. `.gitignore` is never
  overwritten (`context.md` §3, Git operations on the config file).
- **S-05.3** Given a `.gitignore` that holds both a `.hivrr.json` line and an `.agent-plugins.json`
  line, when Phase 6 runs, then the `.hivrr.json` line is removed and `.agent-plugins.json` appears
  exactly once.
- **S-05.4** Given Phase 6 changed `.gitignore` on a branch that is not protected, when it commits,
  then the commit carries only `.gitignore` and, if one was staged, the config file's untracking
  (old or new name). Its message names `.agent-plugins.json`. On a protected branch the change is
  staged and reported, not committed, and nothing is pushed (`context.md` §3, Git operations on the
  config file).
- **S-05.5** Given a `.gitignore` that already ignores `.agent-plugins.json` and has no
  `.hivrr.json` line, with the config file untracked, when Phase 6 runs, then nothing changes and it
  emits `INIT: .agent-plugins.json gitignored`.
- **S-05.6** Given a repository in which `.hivrr.json` is still tracked by git, when `init` Phase 6
  runs after the migration, then it untracks `.hivrr.json` with `git rm --cached` and includes that
  removal in the same commit as `.gitignore`.
- **S-05.7** Given `.hivrr.json` is still on disk after Phase 3 kept it (S-04.8, S-04.2.e2), when
  `init` Phase 6 runs, then every `.gitignore` line `.hivrr.json` is kept, so the kept file stays
  ignored, and `.agent-plugins.json` is still made ignored; a later run that removes `.hivrr.json`
  swaps the line as S-05.1 says. This case takes precedence over S-05.1 and S-05.3 (author, cold read round 2, 2026-11-25).

### S-06 Rename the internal markers

As the maintainer, I want the heredoc and verification markers renamed, so that no internal name
carries `hivrr` and every heredoc still closes.

- **S-06.1** Given the tracked tree outside `docs/plans/`, when it is searched, then it contains no
  `HIVRR_BODY_7f3a`, `HIVRR_COMMIT_7f3a` or `HIVRR_VERIFY_BLOCK`. Each site in `context.md` §2.4
  carries `AGENT_PLUGINS_BODY_7f3a`, `AGENT_PLUGINS_COMMIT_7f3a` or `AGENT_PLUGINS_VERIFY_BLOCK`
  instead.
- **S-06.2** Given each heredoc pair listed in `context.md` §2.4, when it is read, then the opening
  `<<'…'` line and its closing line carry the same new name.
- **S-06.3** Given a fresh tree of the changed commit, when the bootstrap string in
  `docs/verification.md` runs, then it exports `AGENT_PLUGINS_VERIFY_BLOCK`, check 8 counts the
  block without printing `CHECK COUNT UNCHECKED`, and the run prints `structural checks pass` with
  exit status 0 (`context.md` §4).
- **S-06.4** Given this checkout after `init` has migrated its local config, when the config's
  `verify.test` runs, then it prints `structural checks pass` with exit status 0. The migration does
  not rewrite it: the maintainer replaces the local `verify.test` with the new bootstrap string by
  hand, as a Verify step of the marker slice (answered at the acceptance checkpoint, 2026-11-25).

### S-07 Rewrite the name in prose

As an installing user, I want the docs and skill text to use the new name, so that nothing points
me back to `hivrr`.

- **S-07.1** Given the tree, when the titles are read, then `README.md` is titled `agent-plugins`
  and its introduction has no hivrr wording. `CLAUDE.md` is titled `# Agent Plugins`. `core`'s
  description begins "Core coding philosophy" and its heading is `# Core Philosophy`. `init`'s
  description names `.agent-plugins.json` (`context.md` §2.2, §2.5).
- **S-07.2** Given the tree, when
  `grep -rIl -i "hivrr" --exclude-dir=.git --exclude-dir=plans .` runs, then it lists only the
  allowed files: `skills/init/SKILL.md` and `skills/init/references/config.md`, which name
  `.hivrr.json` for the migration, and `RELEASE-NOTES.md`, whose past entries are kept as history
  and whose new entry names `hivrr-agent-plugins` for the switch (answered at the acceptance checkpoint, 2026-11-25) (`context.md` §4, No
  check searches for `hivrr`).
- **S-07.3** Given the base commit `749feb9`, when the changed tree is diffed against it under
  `docs/plans/`, then only files in `docs/plans/move-to-retroboot/` differ (`context.md` §2.7).

## Rules and examples

### S-01 Move the repository home

Rule: the transfer keeps every GitHub record the repository had and leaves the maintainer's
checkout pointing at the new home.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.1.e1 | `hivrr/agent-plugins` with its counts recorded; no `retroboot/agent-plugins` | the maintainer transfers it | `retroboot/agent-plugins` exists with the same issue, pull request, label, milestone, tag and release counts |
| S-01.1.e2 | `retroboot` already holds a repository named `agent-plugins` | the maintainer attempts the transfer | GitHub refuses it, nothing is moved, and the work stops before any tree change that assumes the new home |
| S-01.2.e1 | transfer done; `origin` still names `hivrr/agent-plugins` | the maintainer updates the remote and runs `git remote -v` | `origin` names `retroboot/agent-plugins` |
| S-01.2.e2 | transfer done; the remote was not updated and the redirect still answers | `git fetch` runs | the fetch works through the redirect, but S-01.2 is not met until the remote names `retroboot/agent-plugins` |

Rule: the unused workflows are gone and nothing refers to them.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.3.e1 | the changed tree | `.github/workflows/` is listed | neither `claude.yml` nor `claude-code-review.yml` is present |
| S-01.3.e2 | the changed tree | `grep -rn "claude.yml\|claude-code-review\|CLAUDE_CODE_OAUTH"` runs outside `docs/plans` | no match |

Rule: a renamed owner is a new repository to `init` Phase 2, and re-creating its labels is safe.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.4.e1 | `bootstrappedRepos` lists only `hivrr/agent-plugins` | `init` runs in the transferred checkout | the labels are created with `--force`, `retroboot/agent-plugins` is appended, and Phase 2 reports without error |
| S-01.4.e2 | `bootstrappedRepos` already lists `retroboot/agent-plugins` | `init` runs again | label creation is skipped, as today |

Rule: the repository is cleaned and checked before anyone outside can read it.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.5.e1 | transfer done, C8.d and C8.f's first step run | `gh api repos/retroboot/agent-plugins/collaborators --jq '.[].login'` and `gh secret list --repo retroboot/agent-plugins` run | prints only `retroboot`; lists no secret |
| S-01.5.e2 | the progress file has no pre-transfer counts | the maintainer reaches the visibility change | stop: S-01.1 cannot be shown, and the counts must be reconstructed before going on |
| S-01.6.e1 | a history scan reports no secret | the maintainer changes visibility | `gh repo view retroboot/agent-plugins --json visibility` prints `PUBLIC` |
| S-01.6.e2 | a history scan reports a credential in an old commit | the scan finishes | the repository stays private, and the slice stops for the developer to revoke the credential and decide on history |
| S-01.7.e1 | transfer done in the morning | the remote is switched, the release is cut, then users switch marketplaces | all four on the same date |
| S-01.7.e2 | transfer done; the release is not cut the same day | the next day begins | the users stay on the redirect, which the `hivrr` org could break; the slice records it as a deviation |

### S-02 Install from the `agent-plugins` marketplace

Rule: the registry and every install ID carry `agent-plugins`, and the plugins themselves do not
change.

| ID | Given | When | Then |
|---|---|---|---|
| S-02.1.e1 | the changed `marketplace.json` | `jq -r '.name, .owner.name' .claude-plugin/marketplace.json` runs | prints `agent-plugins` then `retroboot` |
| S-02.1.e2 | the changed `marketplace.json` | the plugin names and descriptions are compared with the base commit | `dev`, `auditor`, `planner` and `data-platform` and their descriptions are identical |
| S-02.2.e1 | a user with the old marketplace removed | they add `agent-plugins` from `retroboot/agent-plugins` and install `dev@agent-plugins` | the plugin installs and appears as `dev@agent-plugins` |
| S-02.2.e2 | a user who still has `hivrr-agent-plugins` and has not added the new one | they try to install `dev@agent-plugins` | the install fails because the marketplace is unknown, which tells them to follow the release-note steps |
| S-02.5.e1 | the changed tree | the structural checks run | check 5 reports nothing |
| S-02.5.e2 | a plugin description edited in `marketplace.json` only | the structural checks run | check 5 reports the drift, as today |

Rule: the setup docs describe how the plugins really ship, and the release notes say how to switch.

| ID | Given | When | Then |
|---|---|---|---|
| S-02.3.e1 | the changed `README.md` | the Setup block is read | it adds the marketplace from `retroboot/agent-plugins` and installs `{plugin}@agent-plugins` |
| S-02.3.e2 | the changed `README.md` and `.env.example` | they are searched for `GitHub Packages`, `manager-plugin` and `data-platform-plugin` | no match |
| S-02.4.e1 | the changed `RELEASE-NOTES.md` | the top entry is read | it is headed `v2.0.0` and gives the uninstall, remove and add steps, the four new install IDs and `.agent-plugins.json` |
| S-02.4.e2 | an entry that gives the new IDs but not the remove step | it is reviewed against S-02.4 | it fails S-02.4 |

### S-03 Skills read `.agent-plugins.json`

Rule: reader skills name only the new file, and never fall back to the old one.

| ID | Given | When | Then |
|---|---|---|---|
| S-03.1.e1 | `.agent-plugins.json` with `branches.integration` set to `dev` | `work-issue` resolves the integration branch | it uses `dev` |
| S-03.1.e2 | `.agent-plugins.json` with no `worktree` key | `merge-pr` reaches its worktree gate | it skips, as for an absent key today |
| S-03.2.e1 | only `.hivrr.json`, with `branches.integration` set to `dev`, and no `init` run | `spec` resolves `{base}` through `dispatch.md` | it does not read `.hivrr.json` and falls back to the default branch (accepted at the acceptance checkpoint) |
| S-03.2.e2 | the tree outside `skills/init/` and `docs/plans/` | it is searched for `.hivrr.json` | no match, apart from the files S-07.2 allows |

Rule: the rename and the migration never ship apart.

| ID | Given | When | Then |
|---|---|---|---|
| S-03.3.e1 | a commit where the readers name `.agent-plugins.json` and `init` Phase 3 holds the migration | it is inspected | it meets S-03.3 |
| S-03.3.e2 | a commit where the readers name `.agent-plugins.json` but `init` has no migration | it is inspected | it fails S-03.3, and must not be merged to the integration branch |
| S-03.4.e1 | the changed `.gitignore` | `git check-ignore -q .agent-plugins.json` runs | it succeeds |
| S-03.4.e2 | the changed `config.md` and `README.md` | they are searched for `"owner": "hivrr"` | no match; both read `"owner": "your-org"` |

### S-04 `init` migrates the old config file

Rule: when `init` finds `.hivrr.json`, it leaves exactly one config file, `.agent-plugins.json`,
and says so once. The new file wins when both exist, but the old one is never removed while it is
the only valid config.

| ID | Given | When `init` Phase 3 runs | Then |
|---|---|---|---|
| S-04.1.e1 | `.hivrr.json` only, valid | | `.agent-plugins.json` holds its exact bytes, `.hivrr.json` is gone, `INIT: upgraded .hivrr.json to .agent-plugins.json`, then `INIT: .agent-plugins.json ok` |
| S-04.1.e2 | `.hivrr.json` only, `--auto` mode | | the same result, with no prompt |
| S-04.2.e1 | both files, with different content, `.agent-plugins.json` valid | | `.agent-plugins.json` is unchanged, `.hivrr.json` is gone, `INIT: removed .hivrr.json (.agent-plugins.json kept)` |
| S-04.2.e2 | both files, `.agent-plugins.json` malformed | | `.hivrr.json` is kept, and `init` stops on the malformed `.agent-plugins.json`; the old file is removed on a later run once the new file validates |
| S-04.3.e1 | neither file | | Phase 3 scaffolds `.agent-plugins.json` as today, with no migration line |
| S-04.3.e2 | neither file, and the developer declines the scaffold | | no config file exists and no migration line is emitted |
| S-04.4.e1 | `.agent-plugins.json` only, valid | | no rename, no migration line, `INIT: .agent-plugins.json ok` |
| S-04.4.e2 | a repository `init` migrated earlier in the same session | `init` runs a second time | nothing changes and no migration line is emitted |
| S-04.5.e1 | `.hivrr.json` only, malformed | | it is renamed unchanged, then `init` stops with the malformed line naming `.agent-plugins.json` |
| S-04.5.e2 | `.hivrr.json` only, `jq` not installed | | it is renamed, and Phase 3 reports the file present but unvalidated, as today |

Rule: the migration never deletes what it cannot validate, and stops rather than guess.

| ID | Given | When `init` Phase 3 runs | Then |
|---|---|---|---|
| S-04.8.e1 | both files, `jq` missing | | both kept; `.agent-plugins.json` reported present but unvalidated |
| S-04.8.e2 | both files, `jq` installed, new file valid | | `.hivrr.json` removed, as S-04.2 |
| S-04.9.e1 | `.hivrr.json` only, the repository root read-only | | `init` stops with one `INIT:` error line naming the rename; `.hivrr.json` is still there |
| S-04.9.e2 | `.hivrr.json` is a directory | | `init` stops with one `INIT:` error line naming the path; nothing is moved |

Rule: the migration adds no phase and runs before any config read.

| ID | Given | When | Then |
|---|---|---|---|
| S-04.6.e1 | the changed `skills/init/SKILL.md` | its `## Phase` headings are counted | 7 |
| S-04.6.e2 | the changed tree | the structural checks run | checks 7 and 10 report nothing |
| S-04.7.e1 | only `.hivrr.json`, holding `branches.integration: dev` | `work-issue` runs | `init` migrates first, and `work-issue` forks from `dev` |
| S-04.7.e2 | only `.hivrr.json`, `worktree` set | `merge-pr` runs | the migration finishes before Phase 7 and the worktree gates read `.agent-plugins.json` |

### S-05 `init` swaps the `.gitignore` line

Rule: Phase 6 leaves exactly one ignore line for the config file, under the new name, and changes
nothing else in `.gitignore`.

| ID | Given `.gitignore` | When `init` Phase 6 runs | Then |
|---|---|---|---|
| S-05.1.e1 | holds `.hivrr.json` under its comment line | | the line reads `.agent-plugins.json`; the comment and all other lines are unchanged |
| S-05.1.e2 | holds `.hivrr.json` and `node_modules/` | | `node_modules/` is untouched; only the config line changes |
| S-05.2.e1 | does not exist | | it is created holding the one line `.agent-plugins.json` |
| S-05.2.e2 | ignores `*.json` and has no config line | | `.agent-plugins.json` is already ignored, so nothing is appended |
| S-05.3.e1 | holds both lines | | the `.hivrr.json` line is gone and `.agent-plugins.json` appears once |
| S-05.3.e2 | holds `.agent-plugins.json` twice and no old line | | Phase 6 adds nothing and removes nothing |
| S-05.4.e1 | changed, on a feature branch | | one commit carrying only `.gitignore`, whose message names `.agent-plugins.json`; no push |
| S-05.4.e2 | changed, on `main` | | `.gitignore` is staged, not committed, and Phase 6 reports that `main` is protected |
| S-05.5.e1 | holds `.agent-plugins.json`; the config is untracked | | no change; `INIT: .agent-plugins.json gitignored` |
| S-05.6.e1 | holds `.agent-plugins.json`; `.hivrr.json` is still tracked from before v1.3.1 | | `.hivrr.json` is untracked with `git rm --cached`, and its removal is in the same commit as any `.gitignore` change |
| S-05.6.e2 | holds `.agent-plugins.json`; `.hivrr.json` tracked; on `main` | | the untracking is staged with the rest and reported, not committed |
| S-05.7.e1 | holds both files, `jq` not installed, `.gitignore` holding `.hivrr.json` | | the `.hivrr.json` line is unchanged, `.agent-plugins.json` is appended, and `git check-ignore -q` succeeds for both files |
| S-05.7.e2 | the same repository after `jq` is installed and `init` runs again with `.agent-plugins.json` valid | | `.hivrr.json` is removed (S-04.2), and its `.gitignore` line is deleted because `.agent-plugins.json` is already listed (S-05.3) |

### S-06 Rename the internal markers

Rule: no `HIVRR_` marker remains, and every heredoc opens and closes on the same name.

| ID | Given | When | Then |
|---|---|---|---|
| S-06.1.e1 | the changed tree | `grep -rn "HIVRR_" --exclude-dir=.git --exclude-dir=plans .` runs | no match |
| S-06.1.e2 | `skills/core/SKILL.md` | lines 99-100's prose is read | it names `AGENT_PLUGINS_COMMIT_7f3a` and `AGENT_PLUGINS_BODY_7f3a` |
| S-06.2.e1 | the pair at `skills/session/references/github.md:14,16` | both lines are read | both carry `AGENT_PLUGINS_BODY_7f3a` |
| S-06.2.e2 | a pair whose opening line was renamed and whose closing line was not | the heredoc runs | the shell runs the rest of the body as commands; S-06.2 forbids this state |

Rule: verification still runs and still counts its own checks after the rename.

| ID | Given | When | Then |
|---|---|---|---|
| S-06.3.e1 | a fresh tree of the changed commit | the bootstrap string runs | `structural checks pass`, exit 0 |
| S-06.3.e2 | the checks block run bare, outside the loader | `bash` runs it | check 8 prints `CHECK COUNT UNCHECKED AGENT_PLUGINS_VERIFY_BLOCK unset …`, as it does today under the old name |
| S-06.4.e1 | this checkout, migrated, with a `verify.test` that exports `AGENT_PLUGINS_VERIFY_BLOCK` | `verify.test` runs | `structural checks pass`, exit 0 |
| S-06.4.e2 | this checkout, migrated, whose `verify.test` still exports `HIVRR_VERIFY_BLOCK` | `verify.test` runs | check 8 reports `CHECK COUNT UNCHECKED` and the run exits 1; S-06.4 is not met until the maintainer replaces it by hand |

### S-07 Rewrite the name in prose

Rule: outside the historical record and the allowed files, no `hivrr` remains, and the historical
packs are untouched.

| ID | Given | When | Then |
|---|---|---|---|
| S-07.1.e1 | the changed `CLAUDE.md` | line 3 is read | `# Agent Plugins` |
| S-07.1.e2 | the changed `skills/core/SKILL.md` | its frontmatter and first heading are read | "Core coding philosophy …" and `# Core Philosophy`, with no "Hivrr" |
| S-07.2.e1 | the changed tree | the `grep` in S-07.2 runs | only the files S-07.2 allows are listed |
| S-07.2.e2 | a `README.md` whose Configuration example still has `"owner": "hivrr"` | the `grep` runs | `README.md` is listed, and S-07.2 fails |
| S-07.3.e1 | the changed tree | `git diff --name-only 749feb9 -- docs/plans/` runs | every path is under `docs/plans/move-to-retroboot/` |
| S-07.3.e2 | an edit to `docs/plans/planning-redesign/progress/slice-06.md:90` | the same diff runs | that path is listed, and S-07.3 fails |

## Failure modes

| Failure | Trigger | Expected behaviour | What the user sees | Criterion |
|---|---|---|---|---|
| The transfer is refused | `retroboot` already has a repository named `agent-plugins`, or the organization forbids transfers | Stop before any tree change that assumes the new home | GitHub's transfer error | S-01.1 |
| Records lost in the move | A count differs after the transfer | Stop and investigate before any other slice | Count mismatch in the maintainer's before and after reading | S-01.1 |
| The old remote outlives the redirect | `hivrr` creates a new `agent-plugins` before remotes and marketplaces are switched | Remotes and marketplace sources are switched straight after the transfer | `git fetch` or a marketplace update fails, or reaches the wrong repository | S-01.2, S-02.2 |
| A user stays on the old marketplace | They skip the release-note steps | Nothing in the new release reads the old name | Installs of `{plugin}@agent-plugins` fail as unknown; the old marketplace stops updating | S-02.2, S-02.4 |
| Config silently dropped | A release ships reader skills on the new name without the migration | Forbidden: rename and migration land in one commit | The repository falls back to defaults, and verification is skipped | S-03.3 |
| A skill reads config before `init` migrates it | `spec`, `slice`, `cold-read`, `brainstorm` or `audit` runs first in a repository holding only `.hivrr.json` | The skill resolves keys as for an absent file (accepted at the acceptance checkpoint) | Work forks from the default branch instead of the configured integration branch | S-03.2 |
| Old config malformed | `.hivrr.json` does not parse | Rename unchanged, then stop on validation | `init`'s malformed-config line naming `.agent-plugins.json` | S-04.5 |
| Both files present, the new one malformed | A half-finished earlier switch | Old kept, `init` stops on the new one | The malformed-config line naming `.agent-plugins.json`; `.hivrr.json` still on disk | S-04.2 |
| Old ignore line left behind | Phase 6 appends the new line but does not remove the old one | Phase 6 replaces the line | A leftover `.hivrr.json` line in `.gitignore` | S-05.1, S-05.3 |
| Old config still tracked | A repository has not run `init` since v1.3.1 | Phase 6 untracks `.hivrr.json` in the same commit | The untracking in Phase 6's commit, or staged on a protected branch | S-05.6 |
| Config commit on a protected branch | `init` runs on `main` | Stage and report, no commit | The protected-branch line from Phase 6 | S-05.4 |
| Secret in history | A credential was committed in the past | Stop before the visibility change; the repository stays private | The scanner's finding | S-01.6 |
| Migration cannot complete | Read-only root, or a config path is a directory or symlink | Stop with an `INIT:` error line, nothing moved | The error line | S-04.9 |
| Heredoc pair mismatched | Only one line of a pair renamed | Forbidden by S-06.2 | The shell runs the body text as commands | S-06.2 |
| Stale local verify string | The migrated local config still exports `HIVRR_VERIFY_BLOCK` | The maintainer replaces the local `verify.test` by hand (S-06.4) | `CHECK COUNT UNCHECKED` and exit 1 from verification | S-06.4 |
| A historical pack edited | A bulk replace runs over `docs/plans/` | Forbidden by S-07.3 | A diff under a past pack | S-07.3 |

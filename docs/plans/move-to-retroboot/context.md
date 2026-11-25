# Context — what exists today

Every citation below was checked on 2026-11-25 at commit `749feb9`. Preflight (README rule 2) means
re-checking the ones your slice touches.

## 1. Repository shape

- **What it is.** A Claude Code plugin marketplace whose product is Markdown and JSON. It ships no
  shell scripts (`docs/verification.md:3-4`) and has no config loader: skills read the config file
  directly by the rules in `skills/init/references/config.md:7`.
- **Layout.** 29 skill directories under `skills/`, each holding a `SKILL.md` and sometimes a
  `references/` folder. `.agents/skills/` holds 29 symlinks, one per skill directory
  (`docs/verification.md:158-168`). `.claude-plugin/marketplace.json` is the one registry. It
  declares four plugins, each with `"source": "./"`: `dev` (line 12), `auditor` (33), `planner` (47)
  and `data-platform` (63).
- **Tracked JSON.** Three files: `.claude-plugin/marketplace.json`, `.mcp.json` and
  `skills/postgres-query/package.json` (`git ls-files '*.json'`). Verification check 1 parses them
  (`docs/verification.md:19-26`).
- **No test runner.** Verification is the 14 structural checks in one fenced block
  (`docs/verification.md:18-194`). See section 4.
- **Where the repository's home appears.** `git remote -v` shows
  `origin https://github.com/hivrr/agent-plugins`. No tracked file holds that URL. The only
  repo-name strings in tracked files are `hivrr/agent-plugin`, `hivrr/manager-plugin` and
  `hivrr/data-platform-plugin` in the README Setup block (`README.md:149-151`), and
  `hivrr-agent-plugin` in `.env.example:1` and `README.md:1`. The GitHub Packages wording is in
  `README.md:144` and `.env.example:4-6`.
- **Where `hivrr` appears.** `grep -rIl -i "hivrr" --exclude-dir=.git --exclude-dir=plans .` matches
  31 tracked files on a clean tree (a checkout's local, untracked `.hivrr.json` adds one more;
  `git grep -Il -i hivrr -- . ':!docs/plans'` counts tracked files only), listed in section 2. Besides the config filename, it matches the marker names, the
  `hivrr-agent-plugins` marketplace name, the `hivrr` owner in `.claude-plugin/marketplace.json:4`,
  and "Hivrr" prose. The two workflow files have no match.
- **Marketplace metadata is outside check 5.** Check 5 reads `.plugins[]` only
  (`docs/verification.md:46-48`), so `.claude-plugin/marketplace.json:7` (`metadata.description`) is
  not compared with `CLAUDE.md`. The per-plugin descriptions at lines 13, 34, 48 and 64 are compared,
  and none contains `hivrr`.
- **Config file state.** `.hivrr.json` is gitignored (`.gitignore:8-10`), so a fresh tree has none.
  This checkout's own local `.hivrr.json` holds the bootstrap `verify.test` string with
  `verify.detectedFrom: ["manual"]` (confirmed by the Facilitator on 2026-11-25).
- **Who loads `init`.** These skills load `init` as bootstrap step 1: `work-issue`
  (`skills/work-issue/SKILL.md:19`), `work-pr` (`skills/work-pr/SKILL.md:23`), `review-pr`
  (`skills/review-pr/SKILL.md:36`), `debug` (`skills/debug/SKILL.md:23`), `merge-pr`
  (`skills/merge-pr/SKILL.md:21`), `promote` (`skills/promote/SKILL.md:25`), `ship-issue`
  (`skills/ship-issue/SKILL.md:27`), `ship-pr` (`skills/ship-pr/SKILL.md:26`) and `planning`
  (`skills/planning/SKILL.md:49`). `wave` has no bootstrap of its own and is reached through
  `work-issue` (`skills/wave/SKILL.md:18-22`). `spec`, `slice`, `cold-read`, `brainstorm` and `audit`
  load only `core` (`skills/spec/SKILL.md:39`, `skills/slice/SKILL.md:41`,
  `skills/cold-read/SKILL.md:43`, `skills/brainstorm/SKILL.md:29`, `skills/audit/SKILL.md:23`).
  `spec` and `slice` resolve the integration branch through `dispatch.md`, which names the config
  file (`skills/planning/references/roles/dispatch.md:65-66`). `cold-read` resolves it "as
  `work-issue` Phase 5 does" (`skills/cold-read/SKILL.md:54`).
- **Run order inside `init`.** Phases 1 and 2 read only `~/.claude/settings.json`
  (`skills/init/SKILL.md:22`, `skills/init/SKILL.md:75`). Phase 3 is the first phase that reads the
  repo config file (`skills/init/SKILL.md:122-138`). Phases 4, 5 and 7 read it after Phase 3
  (`skills/init/SKILL.md:184`, `skills/init/SKILL.md:241`, `skills/init/SKILL.md:360`). Phase 6
  handles its ignore-state (`skills/init/SKILL.md:261-354`) and reads `branches.protected` from it
  (`skills/init/SKILL.md:310`).
- **`init` ships in two plugins.** `init` is listed under `dev` and `planner`
  (`.claude-plugin/marketplace.json:18`, `.claude-plugin/marketplace.json:52`). Only `dev` ships
  `core` (`.claude-plugin/marketplace.json:17`; `skills/init/SKILL.md:329-330`).
- **GitHub side** (read by the Facilitator with `gh` on 2026-11-25): `hivrr/agent-plugins` has 154
  issues and 138 pull requests (all states), 30 labels, 0 milestones, 5 tags and 2 releases; the
  maintainer is an org `admin` with repository admin; the repository has no teams; collaborators
  were `retroboot`, `cedwards-plk` and `bschappaugh-plk` when first read; later the same day
  `cedwards-plk` (the maintainer's second account) was removed as a direct collaborator, leaving
  `retroboot` and `bschappaugh-plk`, and its remaining access is `hivrr` organization membership; one repository secret,
  `CLAUDE_CODE_OAUTH_TOKEN`; `retroboot/agent-plugins` does not exist.
- **Outside the repository** (confirmed by the Facilitator on 2026-11-25, not citable by path):
  `~/.claude/settings.json` `providerConfig.bootstrappedRepos` lists `hivrr/agent-plugins`;
  `~/.claude/plugins/known_marketplaces.json` lists `hivrr-agent-plugins`; `enabledPlugins` holds
  `dev@hivrr-agent-plugins`, `planner@hivrr-agent-plugins` and `auditor@hivrr-agent-plugins`; the
  `retroboot` account has no repository named `agent-plugins`.

## 2. What this work changes

Fates follow the Brief. A slice number is assigned in `plan.md`, not here. "Changed" means the
`hivrr` string or the filename is replaced, and the surrounding logic is kept unless the row says
otherwise.

### 2.1 Marketplace and install IDs

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `.claude-plugin/marketplace.json` | 2 | `"name": "hivrr-agent-plugins"`, the marketplace name that install IDs are suffixed with | changed (to `agent-plugins`) |
| `.claude-plugin/marketplace.json` | 3-5 | `"owner": {"name": "hivrr"}` | changed (to `retroboot`) |
| `.claude-plugin/marketplace.json` | 6-9 | `metadata.description` is "Hivrr Agent Plugin — Skills and commands for implementation, brainstorming, planning, and code review"; `metadata.version` is `1.6.0` | description changed; version bumped at release |
| `.claude-plugin/marketplace.json` | 11-77 | the four plugin entries `dev`, `auditor`, `planner`, `data-platform` | kept |
| `README.md` | 144-154 | Setup block: "Each plugin is distributed separately via the hivrr GitHub Packages registry", with `plugins` entries `hivrr/agent-plugin`, `hivrr/manager-plugin`, `hivrr/data-platform-plugin` | changed (rewritten: add the `agent-plugins` marketplace from `retroboot/agent-plugins`, then install each plugin as `{plugin}@agent-plugins`) |
| `README.md` | 156-164 | the local-path development example, no `hivrr` string | kept |
| `.env.example` | 1, 4-6 | header `hivrr-agent-plugin configuration`; a GitHub Packages `GITHUB_TOKEN` comment | changed (header renamed; Packages comment dropped) |

### 2.2 Config filename in `init`

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/init/SKILL.md` | 3 | frontmatter description "… offers to scaffold a repo-local .hivrr.json. Idempotent." | changed |
| `skills/init/SKILL.md` | 12-14 | "The seven phases run in order, every time"; line 14 says the seventh and tenth structural checks hold this count and `CLAUDE.md`'s | wording changed for the filename; phase count kept at seven |
| `skills/init/SKILL.md` | 113-172 | Phase 3 "Scaffold `.hivrr.json`": Step 2 tests `test -f .hivrr.json` (125). If present it validates with `jq empty` and never overwrites (128-136). If absent it detects repo state and writes the file (140-172). It emits `INIT: .hivrr.json ok` (134) or `INIT: .hivrr.json scaffolded (...)` (172) | changed (gains the migration, per the Brief) |
| `skills/init/SKILL.md` | 184, 228, 230 | Phase 4 reads and writes `verify.*` in `.hivrr.json` | changed (filename) |
| `skills/init/SKILL.md` | 241 | Phase 5 skips when `project` is absent from `.hivrr.json` | changed (filename) |
| `skills/init/SKILL.md` | 261-354 | Phase 6 "Keep `.hivrr.json` Out of Git". Step 1 runs `git check-ignore -q` (276) and, if not ignored, appends one line with `printf` (286). Step 2 runs `git ls-files --error-unmatch` (292) and `git rm --cached` (299). Step 3 commits `.gitignore` plus the file's removal with the message `chore(config): keep .hivrr.json out of git` (322), and emits three `INIT:` lines (352-354) | changed (the old ignore line is replaced, per the Brief) |
| `skills/init/SKILL.md` | 360 | Phase 7 skips when `worktree` is absent from `.hivrr.json` | changed (filename) |
| `skills/init/SKILL.md` | 75-105 | Phase 2 records `{OWNER}/{REPO}` in `providerConfig.bootstrappedRepos`, and skips label creation only when the repo is already listed (77-78). Labels are created with `--force` (88-91) | kept (a renamed owner is a new entry and re-runs the creation) |
| `skills/init/references/config.md` | 1, 3, 7, 18, 108, 191, 205, 273-340, 350, 425-460 | the schema and contract for the file, its read steps (`test -f` at 290, `jq empty` at 298, Read tool at 305), failure modes and the Scaffolding section | changed (filename) |
| `skills/init/references/config.md` | 42 | the schema example has `"owner": "hivrr"` under `project` | changed (to `your-org`, a neutral placeholder) |
| `skills/init/references/git-hygiene.md` | 3, 10-16, 41 | the reasoning for Phase 6, including the trailing pathspec at 41 | changed (filename) |
| `skills/init/references/verify.md` | 13, 16, 31 | reads `verify.test` and `verify.lint` from the file; never creates it for verification alone | changed (filename) |

### 2.3 Config filename in the readers

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/session/SKILL.md` | 19, 25, 31, 35 | Phase 1 reads the file first; a table column is headed by the filename | changed (filename) |
| `skills/session/references/github.md` | 222, 275 | `issues.hierarchy` gate; `{base}` resolved from `branches.integration` | changed (filename) |
| `skills/session/references/gitlab.md` | 119 | `{base}` resolved from `branches.integration` | changed (filename) |
| `skills/work-issue/SKILL.md` | 163, 175, 211, 342 | worktree, integration-branch and project reads | changed (filename) |
| `skills/work-issue/references/worktree.md` | 3, 21 | worktree gate and a warning string naming the file | changed (filename) |
| `skills/work-issue/references/hierarchy.md` | 3 | gate on `issues.hierarchy` | changed (filename) |
| `skills/merge-pr/SKILL.md` | 52, 109, 171, 312, 337 | protected set, ladder, manual-job list, project and worktree gates | changed (filename) |
| `skills/merge-pr/references/board.md` | 3 | board gate on `project` | changed (filename) |
| `skills/merge-pr/references/cleanup.md` | 6, 23, 100 | worktree gates | changed (filename) |
| `skills/promote/SKILL.md` | 39, 202 | ladder and `ci.optionalManualJobs` reads | changed (filename) |
| `skills/wave/SKILL.md` | 44, 51 | integration branch and worktree reads | changed (filename) |
| `skills/ship-issue/SKILL.md` | 69 | integration branch resolution | changed (filename) |
| `skills/planning/SKILL.md` | 368 | integration branch resolution | changed (filename) |
| `skills/planning/references/publish.md` | 134 | board gate on `project` | changed (filename) |
| `skills/planning/references/roles/dispatch.md` | 66 | `{base}` resolution | changed (filename) |
| `skills/planning/references/roles/test-engineer.md` | 33 | V1 names the file as an example of git-ignored config absent from the tree | changed (filename) |
| `skills/core/SKILL.md` | 29 | protected set read | changed (filename) |
| `skills/cold-read/SKILL.md`, `skills/work-issue/references/pack-mode.md` | 54; 45 | resolve the integration branch by naming a rule, not the file | kept (no `hivrr` string) |

### 2.4 Heredoc markers

Each opening delimiter and its closing line must change together. The opening line is the
`<<'MARKER'` line and the closing line is the bare marker.

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/session/references/github.md` | 14, 16, 19, 264, 266 | `HIVRR_BODY_7f3a`: two heredoc pairs (14 and 16, 264 and 266) and a prose line (19) | changed |
| `skills/session/references/gitlab.md` | 18, 20, 23, 108, 110 | `HIVRR_BODY_7f3a`: two heredoc pairs (18 and 20, 108 and 110) and a prose line (23) | changed |
| `skills/session/references/linear.md` | 32 | `HIVRR_BODY_7f3a` named in prose | changed |
| `skills/core/SKILL.md` | 92, 94, 99, 100 | `HIVRR_COMMIT_7f3a`: one heredoc pair (92, 94) and prose naming both `HIVRR_COMMIT_7f3a` and `HIVRR_BODY_7f3a` (99-100) | changed |
| `skills/promote/SKILL.md` | 153, 157, 159 | `HIVRR_BODY_7f3a`: prose (153) and one heredoc pair (157, 159) | changed |
| `skills/audit/SKILL.md` | 129, 131, 136 | `HIVRR_BODY_7f3a`: one heredoc pair (129, 131) and prose (136) | changed |
| `skills/review-pr/SKILL.md` | 252 | `HIVRR_BODY_7f3a` in a stdin heredoc named in prose | changed |
| `skills/planning/references/publish.md` | 17 | `HIVRR_BODY_7f3a` in a prose example | changed |
| `docs/verification.md` | 96, 97, 101, 277 | `HIVRR_VERIFY_BLOCK`: check 8 tests and counts it (96-101); the bootstrap `verify.test` string assigns and exports it (277) | changed |
| `CLAUDE.md` | 215, 217 | names `HIVRR_VERIFY_BLOCK` as the variable the loader exports | changed |

### 2.5 Verification, gitignore and prose

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `docs/verification.md` | 6, 226, 267-277 | says the fence is `verify.test` and that the config file extracts it; line 277 is the bootstrap `verify.test` string | changed (filename and marker); check numbering kept |
| `docs/verification.md` | 84-93, 116-122 | checks 7 and 10 compare the phase count: check 7 over every skill, check 10 against `CLAUDE.md`'s "ordered phases" sentence | kept (init stays at seven phases) |
| `.gitignore` | 8-10 | comment plus the line `.hivrr.json` | changed |
| `README.md` | 1, 3 | title `hivrr-agent-plugin`; intro "for the hivrr workflow … hivrr's automation capabilities" | changed (title `agent-plugins`; intro drops the hivrr wording) |
| `README.md` | 29, 76-140, 170, 172 | the `init` table row; the Configuration section, whose JSON example has `"owner": "hivrr"` at line 92; the Verification pointer and the run command | changed (`owner` to `your-org`) |
| `CLAUDE.md` | 3 | title `# Hivrr Claude Plugin` | changed (to `# Agent Plugins`) |
| `CLAUDE.md` | 140, 145, 149, 157, 165, 170, 174, 190, 209, 215, 217 | the filename in `init`'s bullet, Repo configuration, the verify note, the board note, worktree isolation and script policy | changed (filename) |
| `skills/core/SKILL.md` | 3, 8 | frontmatter description "Hivrr core coding philosophy …" and heading `# Hivrr Core Philosophy` | changed (to "Core coding philosophy …" and `# Core Philosophy`) |
| `RELEASE-NOTES.md` | 16, 53 | past entries that name the config file: line 16 under `## v1.5.0`, line 53 under `## v1.3.1` | kept as history (answered at the acceptance checkpoint, 2026-11-25) |
| `RELEASE-NOTES.md` | 1-10 | title "Agent Plugins Release Notes" and the v1.6.0 section: no `hivrr` string | kept; a new entry goes at the top |

### 2.6 Workflows

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `.github/workflows/claude.yml` | 1-50 (token at 37) | runs on `@claude` mentions in issues, comments and reviews, and passes `secrets.CLAUDE_CODE_OAUTH_TOKEN` | deleted |
| `.github/workflows/claude-code-review.yml` | 1-72 (token at 40) | review workflow using the same secret | deleted |

No other tracked file names either workflow or the secret
(`grep -rn "claude.yml\|claude-code-review\|CLAUDE_CODE_OAUTH"` outside `docs/plans`).

### 2.7 Out of scope

`docs/plans/planning-redesign/`, `docs/plans/planning-team-discovery/`,
`docs/plans/planning-team-review/` and `docs/plans/planning-team-spec/` hold `hivrr` strings in
their records (for example `docs/plans/planning-redesign/progress/slice-06.md:90`). They are kept
unchanged (README Key insights). `docs/plans/move-to-retroboot/` also contains `hivrr` strings,
because it describes the old names, and is kept.

## 3. Shared mechanics to reuse

- **Phase headings and counts.** `init`'s phases are `## Phase N — …` headings
  (`skills/init/SKILL.md:20`, `skills/init/SKILL.md:60`, `skills/init/SKILL.md:113`,
  `skills/init/SKILL.md:176`, `skills/init/SKILL.md:236`, `skills/init/SKILL.md:261`,
  `skills/init/SKILL.md:358`). The count word "seven" appears at `skills/init/SKILL.md:12` and
  `CLAUDE.md:140`. Checks 7 and 10 read them (`docs/verification.md:84-93`,
  `docs/verification.md:116-122`).
- **`INIT:` report lines.** Every `init` result is one `INIT: …` line (`skills/init/SKILL.md:27`,
  `skills/init/SKILL.md:56`, `skills/init/SKILL.md:109`, `skills/init/SKILL.md:134`,
  `skills/init/SKILL.md:172`, `skills/init/SKILL.md:305`, `skills/init/SKILL.md:352-354`). The
  migration's line follows the same form.
- **Config-file tests.** Presence is `test -f` and validity is `jq empty`
  (`skills/init/SKILL.md:125`, `skills/init/SKILL.md:131`, `skills/init/references/config.md:290`,
  `skills/init/references/config.md:298`). A parse failure stops `init`
  (`skills/init/SKILL.md:135`). An absent file is normal and resolves from the fallback chain
  (`skills/init/references/config.md:292-293`, `skills/session/SKILL.md:19`).
- **Git operations on the config file.** `git check-ignore -q`, `git ls-files --error-unmatch`,
  `git rm --cached` and the commit with a trailing pathspec (`skills/init/SKILL.md:276`,
  `skills/init/SKILL.md:292`, `skills/init/SKILL.md:299`, `skills/init/SKILL.md:322`). The pathspec
  rule is restated inline because `planner` has no `core` (`skills/init/SKILL.md:325-330`). Phase 6
  appends to `.gitignore` and never overwrites it (`skills/init/SKILL.md:282-286`). It never pushes
  (`skills/init/SKILL.md:349`). On a protected branch it stages and reports without committing
  (`skills/init/SKILL.md:340-347`).
- **The `["manual"]` sentinel.** `verify.detectedFrom` equal to `["manual"]` stops Phase 4 from
  re-detecting (`skills/init/SKILL.md:186-188`). This repo's verification relies on it
  (`docs/verification.md:273-274`).
- **Repo identity for labels.** `gh repo view --json owner,name` (`skills/init/SKILL.md:67`).
  `providerConfig.bootstrappedRepos` is read and appended in Phase 2 (`skills/init/SKILL.md:75-77`,
  `skills/init/SKILL.md:96-104`).
- **Heredoc bodies through a file.** A single-quoted heredoc with a non-`EOF` delimiter, written
  outside the checkout, then `git commit -F` or `--body-file` (`skills/core/SKILL.md:92-102`,
  `skills/session/references/github.md:14-19`, `skills/promote/SKILL.md:153-159`).
- **Marketplace-to-docs sync.** Plugin names and descriptions in `CLAUDE.md` track
  `.claude-plugin/marketplace.json` verbatim (`CLAUDE.md:38-48`; `docs/verification.md:45-59`). The
  README Overview table names the same plugins (`docs/verification.md:124-133`).
- **Bootstrap string.** The runnable form of `verify.test` is at `docs/verification.md:277`. The doc
  requires `verify.detectedFrom: ["manual"]` with it (`docs/verification.md:273-274`).
- **Pack fence rule.** Fences in `docs/plans/**/*.md` use exactly three backticks tagged `bash`,
  `sh`, `mermaid` or `text` (`docs/verification.md:170-193`).

No config loader, migration helper or rename utility exists to reuse
(`skills/init/references/config.md:7`; no `skills/` entry other than `postgres-query/query.mjs`
holds a script).

## 4. How verification works here

- **Structural checks.** The repo has no test runner. The config file's `verify.test` extracts the
  first fenced block of `docs/verification.md` and passes it to `bash` (`docs/verification.md:6-8`,
  `docs/verification.md:231-235`).
- **Run all checks with a local config.** `eval "$(jq -r .verify.test .hivrr.json)"`, or the README
  form `jq -r '.verify.test' .hivrr.json | bash` (`README.md:172`). This needs the config file, which
  a fresh tree lacks (`.gitignore:10`). After the rename, the file in these commands is
  `.agent-plugins.json`.
- **Run all checks on a fresh tree.** Run the bootstrap string at `docs/verification.md:277`. It
  changes to the repo root, exports `HIVRR_VERIFY_BLOCK`, runs the block, and prints
  `structural checks pass`, or the findings with exit status 1.
- **Expected output.** Observed on 2026-11-25 at `749feb9`, in a detached tree of `origin/main`
  holding this pack: `structural checks pass`, exit status 0. Run bare, outside the loader, check 8
  prints `CHECK COUNT UNCHECKED` because the variable is unset (`docs/verification.md:100-101`).
- **The 14 checks** are in the table at `docs/verification.md:200-215`. Those this work touches:
  - check 5: `CLAUDE.md` plugin descriptions against `marketplace.json`
    (`docs/verification.md:45-54`);
  - check 7: phase sequence and stated counts (`docs/verification.md:78-93`);
  - check 8: the `CLAUDE.md` check count against the block, which needs the exported variable
    (`docs/verification.md:95-102`);
  - check 10: `init` phase count (`docs/verification.md:116-122`);
  - check 13: `.agents/skills` symlinks (`docs/verification.md:158-168`);
  - check 14: pack README presence and fence form over `docs/plans/**/*.md`, which includes this
    pack (`docs/verification.md:170-193`).
- **No check searches for `hivrr`.** The command that finds the remaining strings today is
  `grep -rIl -i "hivrr" --exclude-dir=.git --exclude-dir=plans .`. It lists 31 files now.
- **Behavioural criteria with no test.** The `init` migration and the Phase 6 `.gitignore` swap are
  prose steps in a skill. No test covers them. The proof available is running `init` with a
  temporary `HOME` (so `~/.claude/settings.json` is a scratch copy) against a scratch repo with no
  remote (so Phase 2 skips label creation) (answered at the acceptance checkpoint, 2026-11-25) and reading its `INIT:` lines and `git status` (`skills/init/SKILL.md:134`,
  `skills/init/SKILL.md:352-354`). The GitHub transfer is performed in GitHub and cannot be tested
  from the tree; its proof is `gh repo view retroboot/agent-plugins` and the issue, tag and release
  counts read before and after.

## 5. Glossary

| Term | Meaning |
|---|---|
| transfer | The GitHub repository transfer from `hivrr/agent-plugins` to `retroboot/agent-plugins`; it keeps history, issues, PRs, labels, releases and redirects old URLs (README Brief) |
| marketplace | The registry in `.claude-plugin/marketplace.json`; its `name` field (line 2) is the suffix of every install ID |
| plugin | One entry under `plugins` in `marketplace.json`: `dev`, `auditor`, `planner` or `data-platform`; installed as `plugin@marketplace` |
| config file | The per-repo JSON file at the repository root, named `.hivrr.json` today and `.agent-plugins.json` after the move; gitignored, same schema |
| old config / new config | `.hivrr.json` / `.agent-plugins.json` |
| `init` migration | The new step in `init` Phase 3 that renames the old config to the new, prints a line, and lets the new file win when both exist |
| marker | One of the heredoc delimiter strings `HIVRR_BODY_7f3a`, `HIVRR_COMMIT_7f3a`, or the variable `HIVRR_VERIFY_BLOCK`; renamed to `AGENT_PLUGINS_*` |
| heredoc pair | An opening `<<'MARKER'` line and its closing `MARKER` line; the two must carry the same name |
| structural check | One of the 14 checks in the fenced block of `docs/verification.md`, numbered by the table at `docs/verification.md:200-215` |
| bootstrap string | The `verify.test` value at `docs/verification.md:277` that extracts and runs the checks fence on a fresh checkout |
| historical pack | A pack under `docs/plans/` other than this one; its `hivrr` strings are kept |
| clean cut | No skill falls back to reading the old config; `init` migrates it instead (README Ruled out) |
| `bootstrappedRepos` | The list of `{OWNER}/{REPO}` strings in `~/.claude/settings.json` `providerConfig` that `init` Phase 2 uses to skip label creation |
| integration branch | The branch feature work forks from: `branches.integration` from the config file, then the repository default branch |

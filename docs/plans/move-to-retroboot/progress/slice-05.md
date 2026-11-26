# Slice 5 — Transfer, publish and merge the marketplace rename

| | |
|---|---|
| **Status** | done |
| **Issue** | #301 |
| **PR** | this PR |
| **Executor model** | claude-opus-5-5 |
| **Date** | 2026-11-26 |

Baseline: issues 160, prs 144, labels 30, milestones 0, tags 5, releases 2

After: issues 160, prs 144, labels 30, milestones 0, tags 5, releases 2

gitleaks: 8.30.1

Go public: approved by retroboot 2026-11-26

Dates (UTC): transfer 2026-11-26, remote 2026-11-26, merge 2026-11-26

## Preflight

| Citation | Holds? |
|---|---|
| Slices 1 to 4 merged | holds: #304, #305, #306, #307 merged on `main` (`f6fe558`) |
| `context.md` §2.1, `.claude-plugin/marketplace.json:2,4,7,8` (`hivrr-agent-plugins`, `hivrr`, "Hivrr Agent Plugin …", `1.6.0`) | holds |
| `context.md` §2.1, `.env.example:1,4-6` | holds |
| `README.md:144-154` Setup block (GitHub Packages, `hivrr/…-plugin` list) | differs (line numbers only): now at 147-159, after the paragraphs Slice 2 added; the text is unchanged |
| `README.md:156-164` local-path block, kept | holds, at 161-169 |
| Baseline counts 154, 138, 30, 0, 5, 2 (prd Assumptions, 2026-11-25) | issues and PRs are higher by exactly the six slice issues (#297–#302) and six PRs (#303–#308) opened since, which the Verify note allows; labels, milestones, tags and releases equal |
| `retroboot/agent-plugins` absent before the transfer (S-01.1.e2) | holds: `gh repo view retroboot/agent-plugins` → `GraphQL: Could not resolve to a Repository with the name 'retroboot/agent-plugins'. (repository)` at 2026-11-25T23:44:23Z |
| Collaborators before the transfer | `retroboot`, `cedwards-plk`, `bschappaugh-plk` (`gh api repos/hivrr/agent-plugins/collaborators`; `cedwards-plk`'s access comes from `hivrr` organization membership, design C8.f) |
| Repository secrets before the transfer | `CLAUDE_CODE_OAUTH_TOKEN` only |

## Acceptance

| ID | How it was shown |
|---|---|
| 5.1 | `gitleaks version` → `8.30.1`, recorded above before any scan. Installed from the official `gitleaks/gitleaks` release `v8.30.1` (`gitleaks_8.30.1_linux_x64.tar.gz`). `sha256sum -c` against that release's `gitleaks_8.30.1_checksums.txt` printed `OK` |
| 5.6 | In a scratch directory outside the checkout, a repository holding one generated `ghp_` + 36-character fake token: `gitleaks git detect-test.git --log-opts="--all" --redact` → `leaks found: 1`, `exit 1`; `grep -c 'leaks found: 1'` → 1 |
| S-02.5.e2 | A scratch edit appending ` (scratch)` to the `dev` entry's description made the bootstrap string print `DESC DRIFT dev`, `exit 1`. With the file restored, it prints `structural checks pass` |
| S-02.2 (probe side) | The maintainer ran the probe in Claude Code on this tree (`/plugin marketplace add` of the checkout on `issue/301`), installed `dev@agent-plugins`, `planner@agent-plugins`, `auditor@agent-plugins` and `data-platform@agent-plugins`, uninstalled each and removed the marketplace, with no error reported. After it: `jq -e 'has("agent-plugins") \| not' ~/.claude/plugins/known_marketplaces.json` → `true`; `jq -e '[.enabledPlugins \| keys[] \| select(endswith("@agent-plugins"))] \| length == 0' ~/.claude/settings.json` → `true`; `cmp <(jq -S . {copy}) <(jq -S . {file})` silent for both files, against copies taken before the probe |
| S-01.1 | the transfer was done by the maintainer; `gh repo view retroboot/agent-plugins` → `retroboot/agent-plugins`, `PRIVATE` at 2026-11-26T00:12:59Z |
| S-01.1.e1 | `After:` above equals `Baseline:` |
| S-01.1.e2 | the pre-transfer `Could not resolve to a Repository` line in Preflight |
| S-01.2, S-01.2.e1 | `git remote set-url origin https://github.com/retroboot/agent-plugins`; `git remote get-url origin` → `https://github.com/retroboot/agent-plugins`; `gh auth setup-git`, then `git fetch origin` exit 0 and `gh repo view` → `retroboot/agent-plugins` |
| S-01.2.e2 | not exercised: the remote was switched straight after the transfer, before any fetch through the redirect |
| S-01.4.e1 | In the maintainer's checkout after the remote switch: `~/.claude/settings.json` was copied first, and `bootstrappedRepos` listed `hivrr/agent-plugins` (`true`) and not `retroboot/agent-plugins` (`false`). `init` Phase 2 run 1 detected `retroboot/agent-plugins`, ran `gh label create … --force` for all 20 labels in `labels.md` (20 ok, 0 failed), appended `retroboot/agent-plugins`, and emitted `INIT: labels bootstrapped for retroboot/agent-plugins` |
| S-01.4.e2 | run 2 → `INIT: labels ok`, no label creation; then the copy was restored and `cmp` printed nothing |
| 5.5 | After clean-up, `keys 0`, `hooks 0`, `invitations 0`, `dependabot/secrets 0`, `codespaces/secrets 0`, `actions/runners 0`, `environments 0` (none existed), `runs 0`. All 412 Actions runs were deleted with `gh api -X DELETE repos/retroboot/agent-plugins/actions/runs/{id}` (412 ok, 0 failed). `gh secret delete CLAUDE_CODE_OAUTH_TOKEN` left `gh secret list … --jq length` → 0. Releases `v1.3.1` and `v1.3.0` hold 0 assets each, so there is nothing to read. Fork-PR approval: see Deviations |
| S-01.5 | collaborators `retroboot` only (`gh api repos/retroboot/agent-plugins/collaborators?affiliation=all`); secrets 0; the S-01.5.e1 listing is re-read after C8.f |
| 5.4 | the line `Go public: approved by retroboot 2026-11-26` above was written by the maintainer before C8.f; `bschappaugh-plk` was absent after the transfer (Deviations) |
| S-01.6.e1, 5.3 | `gh repo edit retroboot/agent-plugins --visibility public --accept-visibility-change-consequences` at 2026-11-26T00:36Z, after the clean scan; `gh repo view --json visibility` → `PUBLIC`, before this PR merges |
| S-01.5.e1 | after C8.f: `gh api repos/retroboot/agent-plugins/collaborators --jq '.[].login'` → `retroboot`; `gh secret list … --jq length` → `0`. Fork-PR approval set with `gh api -X PUT …/fork-pr-contributor-approval -f approval_policy=all_external_contributors` → `all_external_contributors` |
| S-01.7 (transfer side) | the `Dates (UTC):` line above: transfer, remote and merge on 2026-11-26 |
| S-02.1, S-02.1.e1, S-02.4 | `jq -r '.name, .owner.name, .metadata.version'` → `agent-plugins`, `retroboot`, `2.0.0`; the description has no `hivrr` (0) |
| S-02.1.e2 | `diff` of `.plugins` against `749feb9` printed nothing |
| S-02.3, S-02.3.e1, S-02.3.e2 | `git grep -n -i 'github packages\|manager-plugin\|data-platform-plugin\|hivrr' -- README.md .env.example` printed nothing; README names `retroboot/agent-plugins` (2) and the `@agent-plugins` IDs (5) |
| S-02.4.e1, S-02.4.e2 | `grep -m1 '^## ' RELEASE-NOTES.md` → `## v2.0.0 (2026-11-26)`; the eight required strings loop printed nothing |
| 5.2 | the entry holds `` `init`-loading skill first `` (1) |
| S-02.5, S-02.5.e1 | the bootstrap string → `structural checks pass` |
| S-07.2, S-07.2.e1, S-07.3, S-07.3.e1 | the fresh-tree grep lists only `./RELEASE-NOTES.md`, `./skills/init/SKILL.md`, `./skills/init/references/config.md`; the `749feb9` diff check printed nothing, exit 1. Both are re-run on `main` after the merge and the results recorded in `progress/slice-06.md` |
| S-07.2.e2, S-07.3.e2 | the same two commands list the offending path in those states, by their construction |
| S-01.6 | `git clone --mirror https://github.com/retroboot/agent-plugins` exit 0 (heads, `refs/pull/*` and 5 tags). `gitleaks git agent-plugins-scan.git --log-opts="--all" --redact --verbose` → `468 commits scanned`, `scanned ~6547672 bytes`, `no leaks found`, exit 0; `grep -c 'no leaks found'` → 1. `git rev-list --all --count` → 481; the 13-commit gap is merge and empty commits, which gitleaks does not count |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Baseline, transfer, remote switch and merge on one UTC date | The baseline was read at 23:44 UTC on 2026-11-25; the transfer, the remote switch and the merge all fall on 2026-11-26, so S-01.7's three dates agree. The transfer date is inferred: the maintainer made the transfer between 23:44Z on the 25th and 00:12:59Z on the 26th, when the repository was first seen at `retroboot`, and gave no exact time | Slices 1 to 4 took the 25th | n |
| The `v2.0.0` heading carries the transfer date | `## v2.0.0 (2026-11-25)` was written before the transfer, and is corrected to `2026-11-26` before the merge | the date was not known until the transfer | n |
| C8.d: set fork-PR workflow approval before C8.f | `gh api repos/retroboot/agent-plugins/actions/permissions/fork-pr-contributor-approval` → `422 Fork PR approval is not allowed for private repositories` | GitHub offers the setting on public repositories only, so it is set straight after the visibility change and before the merge | n |
| C8.f first step: `gh api -X DELETE …/collaborators/bschappaugh-plk` after a clean scan | `bschappaugh-plk` was already absent after the transfer: `gh api repos/retroboot/agent-plugins/collaborators/bschappaugh-plk` → 404, and `?affiliation=all` lists only `retroboot`, with 0 invitations | The access did not survive the transfer to a personal account. The user lost access before the scan rather than after it, which ADR-010 allowed only after a clean scan. The scan was clean, so nothing was exposed either way | n |

## Decisions

## Discoveries

- The probe left a `~/.claude/plugins/cache/agent-plugins` directory behind, although nothing is
  registered or enabled. It is harmless, and is reused or replaced when the real marketplace is
  added in Slice 6.

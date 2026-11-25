# Slice 5 — Transfer, publish and merge the marketplace rename

| | |
|---|---|
| **Status** | in-progress |
| **Issue** | #301 |
| **PR** | this PR |
| **Executor model** | claude-opus-5-5 |
| **Date** | 2026-11-25 |

Baseline: issues 160, prs 144, labels 30, milestones 0, tags 5, releases 2

gitleaks: 8.30.1

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

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Transfer, remote switch and merge on one UTC date | The baseline was read at 23:44 UTC on 2026-11-25, so the transfer falls on the next UTC date at the earliest | Slices 1 to 4 took the day; prd S-01.7.e2 makes a different date a recorded deviation, not a stop | n |

## Decisions

## Discoveries

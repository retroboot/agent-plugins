# Slice 1 — Delete the unused Claude workflows

| | |
|---|---|
| **Status** | done |
| **Issue** | #297 |
| **PR** | this PR |
| **Executor model** | claude-opus-5-5 |
| **Date** | 2026-11-25 |

Token revoked: 2026-11-25

## Preflight

| Citation | Holds? |
|---|---|
| `context.md` §2.6: `.github/workflows/claude.yml`, lines 1-50, token at 37 | holds: 50 lines, line 37 is `claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}` |
| `context.md` §2.6: `.github/workflows/claude-code-review.yml`, lines 1-72, token at 40 | holds: 72 lines, line 40 is the same token line |
| Acceptance 1.1: the two workflows are the only tracked files under `.github` | holds: `git ls-files .github` listed exactly those two |
| `context.md` §2.6: no other tracked file outside `docs/plans` names either workflow or the secret | holds: `git grep -n 'claude.yml\|claude-code-review\|CLAUDE_CODE_OAUTH' -- . ':!docs/plans' ':!.github'` printed nothing, exit 1 |

## Acceptance

| ID | How it was shown |
|---|---|
| S-01.3 | `git rm` of both workflows; the two checks below hold |
| S-01.3.e1 | `test -d .github/workflows && ls .github/workflows \|\| echo absent` printed `absent` |
| S-01.3.e2 | `git grep -n 'claude.yml\|claude-code-review\|CLAUDE_CODE_OAUTH' -- . ':!docs/plans'` printed nothing, exit 1 |
| 1.1 | `git ls-files .github` printed nothing |
| 1.2 | The maintainer revoked the token at its issuer and gave the date; recorded above as `Token revoked: 2026-11-25` |

Also run: `eval "$(grep -m1 '^bash -c ' docs/verification.md)"` printed `structural checks pass`, and
the `design.md` §8 P7 check (`git diff --name-only 749feb9 -- docs/plans/` plus untracked files,
filtered to paths outside `docs/plans/move-to-retroboot/`) printed nothing, exit 1.

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| — | none | — | n |

## Decisions

None. The plan left nothing open for this slice.

## Discoveries

- The `CLAUDE_CODE_OAUTH_TOKEN` repository secret still exists on the repository. Revoking the
  token at its issuer made it useless, but Slice 5 still has to delete the secret itself (C8.d)
  before the repository goes public.

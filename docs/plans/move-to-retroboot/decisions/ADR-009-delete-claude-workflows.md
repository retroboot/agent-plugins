# ADR-009: Delete the unused Claude workflows

**Status:** accepted

**Proposed by:** developer

## Context

`.github/workflows/claude.yml` and `.github/workflows/claude-code-review.yml` use the
`CLAUDE_CODE_OAUTH_TOKEN` secret, and the developer does not use them (`context.md` §2.6).

## Options

1. **Keep them and re-create the secret after the transfer.** Rejected: they are not used.
2. **Delete both files and the repository secret.** Chosen.

## Decision

Delete both workflow files and the `CLAUDE_CODE_OAUTH_TOKEN` repository secret.

## Consequences

Nothing in the public repository refers to a credential.

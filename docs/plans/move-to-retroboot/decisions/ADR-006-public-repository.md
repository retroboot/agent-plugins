# ADR-006: The repository becomes public, with its history checked first

**Status:** accepted; amended by ADR-010, collaborator removal moves after the clean scan

**Proposed by:** developer

## Context

The repository was private so that `cedwards-plk` and `bschappaugh-plk` could see the plugin. On a
personal account it will be public, so those collaborators have no reason to remain. Making it
public exposes every commit, issue and pull request, which cannot be undone.

## Options

1. **Keep it private and invite the other installer as a collaborator.** Rejected: the developer
   wants it public.
2. **Make it public at once after the transfer.** Rejected: a credential committed in the past would
   be exposed with no chance to revoke it first.
3. **Remove the other collaborators and the `CLAUDE_CODE_OAUTH_TOKEN` secret, scan the full history
   for credentials, then make it public.** Chosen.

## Decision

Option 3, as prd S-01.5 and S-01.6 specify. A scan finding stops the slice with the repository
still private.

## Consequences

Installing users need no credential to fetch the marketplace. The scan tool is chosen in the design.

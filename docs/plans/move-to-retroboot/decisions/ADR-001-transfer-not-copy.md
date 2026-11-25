# ADR-001: Transfer the repository rather than copy it

**Status:** accepted

**Proposed by:** developer

## Context

The `hivrr` organization is being repurposed and needs none of this repository's history. The
repository must move to the `retroboot` personal account (README Brief). Two ways exist to move a
GitHub repository, and they keep different records.

## Options

1. **Copy.** Create `retroboot/agent-plugins` and `git push --mirror`. Rejected: it keeps history,
   branches and tags but loses issues, pull requests, comments, labels, milestones and GitHub
   Releases, gives no URL redirect, and leaves a second copy in the organization.
2. **GitHub transfer.** Transfer `hivrr/agent-plugins` to `retroboot` from the repository settings.
   Chosen.

## Decision

Transfer the repository to `retroboot`, keeping the name `agent-plugins`. Nothing is kept in the
`hivrr` organization.

## Consequences

Issues, pull requests, labels, tags and releases keep their numbers, so `#N` citations in
`RELEASE-NOTES.md` and the historical packs stay valid. The old URL redirects only until the
organization creates a repository with that name, so remotes and the marketplace source are switched
the same day (prd S-01.7).

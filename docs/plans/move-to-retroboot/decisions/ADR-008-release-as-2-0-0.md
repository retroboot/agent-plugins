# ADR-008: Release as v2.0.0

**Status:** accepted (developer, 2026-11-25)

**Proposed by:** author (spec); accepted by the developer at the spec ADR checkpoint

## Context

The marketplace name and the config filename are contracts every installing user and repository
depend on, and both change (ADR-002). `metadata.version` in `marketplace.json` is the repository's
only version (`CLAUDE.md`, Version tracking); it is `1.6.0`.

## Options

1. **`1.7.0`.** Rejected: a minor version signals a compatible change, and this one requires every
   user to act.
2. **`2.0.0`.** Chosen.

## Decision

The release that ships the rename is `v2.0.0`: `metadata.version` is `2.0.0`, and the top
`RELEASE-NOTES.md` entry is headed `v2.0.0`.

## Consequences

The version itself warns users that they must switch marketplaces.

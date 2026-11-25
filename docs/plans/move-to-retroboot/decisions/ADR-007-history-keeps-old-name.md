# ADR-007: Historical records keep the old name

**Status:** accepted

**Proposed by:** developer

## Context

The past packs under `docs/plans/` and the past entries of `RELEASE-NOTES.md` record commands that
ran and states that held, under the old names (`context.md` §2.5, §2.7).

## Options

1. **Rewrite them.** Rejected: it would make the record false.
2. **Keep them, and exclude them from the no-`hivrr` check.** Chosen.

## Decision

Historical packs and past release-note entries are not edited. prd S-07.2 lists the allowed files
and S-07.3 checks that no past pack changed.

## Consequences

A search for `hivrr` still finds the history, which is the point of keeping it.

# ADR-011 — Work without a pack behaves exactly as before

**Status:** accepted (developer, 2026-11-13)

## Context
`work-issue` and `ship-issue` are used daily on plain issues and work well. Many issues will never
have a pack.

## Options
1. Require a pack for all work: a regression for small fixes. **Rejected.**
2. Pack mode is triggered only by a `Plan:` marker in the issue body, or a `docs/plans/` path given
   to `ship-issue`. Without one, every phase runs as it does today. **Chosen.**

## Decision
Option 2. The only change to legacy runs is removing the session-memory sections (ADR-002), which
were already no-ops without `SESSION_UUID`.

## Consequences
Every pack-mode addition must be written as a conditional block that starts with
"Skip when no marker".

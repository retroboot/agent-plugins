# ADR-004 — Route on type × size, plus modifiers

**Status:** accepted (developer, 2026-11-13); amended by ADR-012, which adds the `observability` modifier

## Context
The developer named four scenarios (small change, feature, refactor, clean-room rewrite). They
mix two things: what kind of work it is and how big it is. A flat list of scenarios grows without
end (data migration feature, refactor with UI, …).

## Options
1. A flat list of scenarios: combinatorial and hard to extend. **Rejected.**
2. The old size-only tiers (Simple, Medium, Complex): these miss the difference in artifacts
   between, say, a refactor and a feature of the same size. **Rejected.**
3. Two axes plus modifiers. **Chosen.**
   - Type decides which files: Change, Bug, Spike, Feature, Refactor, Migration, Greenfield, Rewrite.
   - Size decides depth: S, M, L, XL.
   - Modifiers add one design section each: data, integration, performance, security, ui,
     public-api, infra.

## Decision
The routing matrix in `design.md` §3 is the single source of truth. Batches of independent items
are not routed; they go to `ship-issue`.

## Consequences
A new kind of work is usually a new modifier (one section), not a new type.

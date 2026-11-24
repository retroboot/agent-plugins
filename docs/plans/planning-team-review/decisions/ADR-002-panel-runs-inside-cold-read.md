# ADR-002: The review panel runs inside cold-read, before round 1

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** author (spec); accepted by the developer at the spec ADR checkpoint

## Context

The panel must run before any cold reader (prd S-02.1). It could live in the skill that writes the
plan, in the skill that reads it, or on its own. This pack's scope leaves `slice` and the
`planning` wrapper unchanged (prd Non-goals).

## Options

1. **In `slice`, before its checkpoint.** The developer would approve a plan whose facts were
   already checked. Rejected for this pack: gates inside `spec` and `slice` are child pack 2, and
   a standalone `cold-read` or re-read would then run without a panel.
2. **A separate skill, called by `planning` between Slice and Cold read.** Rejected: it adds a
   wrapper phase (child pack 4's scope) and a new result contract.
3. **Inside `cold-read`, after Phase 2 Author Checks and before the first reader.** Chosen.

## Decision

`cold-read` runs the panel after its Author Checks and before it dispatches the first reader of a
run. Later rounds in the same run re-check fixes with the roles they touch (ADR-004).

## Consequences

- Every mode gets the panel, standalone runs and re-reads included, with no wrapper change.
- The panel's findings are recorded in the round they precede, beside the author findings.
- When child pack 2 adds gates in `slice`, the panel in `cold-read` should find less, not be removed.

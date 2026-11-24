# ADR-004: The panel re-checks at most twice, then the readers run

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** author (spec); accepted by the developer at the spec ADR checkpoint

## Context

After the Facilitator fixes panel findings, the roles those fixes touch re-check them (prd S-03.2).
A finding the author cannot fix, or keeps fixing wrongly, could loop. About a third of the hyalos
blockers came from earlier fixes, so re-checking is worth having, but it must end.

## Options

1. **Re-check until clean.** Rejected: it can loop with no limit, and every pass costs a dispatch.
2. **Stop the run when the panel is still blocking.** Rejected: one stuck finding would keep every
   reader from running, and readers find what the panel cannot.
3. **At most two re-checks, then hold what is left and dispatch the readers.** Chosen.

## Decision

A run makes at most two panel re-check passes before the first reader. A finding still blocking
after them is recorded as held, counts as Blocking for the round, and the readers are dispatched.

## Consequences

- A run with held findings cannot pass in that round, but still gets its readers' findings.
- The cap is per run, so a later run starts with a fresh panel.

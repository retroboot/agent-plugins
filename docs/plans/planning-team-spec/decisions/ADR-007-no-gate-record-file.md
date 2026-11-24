# ADR-007: Gate findings are fixed in place, with no record file

**Status:** accepted (developer, 2026-11-24); amended by ADR-008, unfinished gate work and spec-change answers go to handoff.md

**Proposed by:** author (spec); accepted by the developer at the spec ADR checkpoint

## Context

Child 1's panel writes its findings into `cold-read.md`. The gates in `spec` and `slice` run before that file exists. Their findings need either a home of their own, or none.

## Options

1. **A new pack file, `gates.md`.** Rejected: a new file in the routing matrix, the templates and the Read order, for findings that are already fixed in the files they concern.
2. **Write gate findings into `cold-read.md` early.** Rejected: `cold-read` creates that file from its template, and starting it earlier changes its first round's rules.
3. **No record: each gate's summary is shown at its checkpoint, fixes stay in the files, and deferred items become README Open questions lines.** Chosen.

## Decision

A gate prints one display line per role and a summary at the checkpoint. A deferred item is written to the README **Open questions** as `Deferred at the {stage} checkpoint on {date}: {Id} — {question}.` (prd S-03.4). Nothing else is recorded.

## Consequences

No new file. A gate's misses still show up in the cold read, where trace-back records them against the role that should have caught them (`context.md` §3, **Trace-back**). How much each gate caught is not recorded; child 4's retro measures it through the cold read instead.

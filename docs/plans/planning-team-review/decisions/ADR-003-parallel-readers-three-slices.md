# ADR-003: Parallel cold readers, at most 3 slices each

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** author (spec); accepted by the developer at the spec ADR checkpoint

## Context

Each round covers about a third of the slices (`skills/cold-read/SKILL.md:145`), so no sliced
pack passes in under 3 rounds. Several Agent calls in one message run concurrently (`context.md`
§3, measured 2026-11-24).

## Options

1. **Keep a third of the slices per round.** Rejected: it forces at least 3 rounds.
2. **One reader per slice.** Rejected: an L pack means up to 12 Haiku reports to merge and classify
   for each round, and each reader still reads the shared files.
3. **Groups of at most 3 slices, in plan order, one new reader per group, all in one step.** Chosen.

## Decision

Round 1 covers every slice in groups of at most 3. Later rounds group only the slices whose files
the last fixes touched. A pack with no slices gets one reader, as today. The reader prompt is
unchanged apart from its slice list.

## Consequences

- A 12-slice pack runs 4 readers in round 1, at about the same wall-clock time as one.
- Merged reports carry the reader's letter in each Id.
- Each report must pass the completeness check on its own.

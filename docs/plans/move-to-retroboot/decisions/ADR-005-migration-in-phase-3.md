# ADR-005: The migration lives in init Phase 3

**Status:** accepted (developer, 2026-11-25)

**Proposed by:** author (spec); accepted by the developer at the spec ADR checkpoint

## Context

ADR-004 puts the migration in `init`. `init` has seven phases, and structural checks 7 and 10 hold
that count in `skills/init/SKILL.md` and `CLAUDE.md` (`context.md` §3). Phase 3 is the first phase
that reads the repository config (`context.md` §1, Run order inside `init`). The developer asked the
author to choose.

## Options

1. **A new Phase 8.** Rejected: it would run after Phases 3 to 7 had already read the config under
   the new name and found nothing, and it moves the count that two checks hold.
2. **A new phase before Phase 3.** Rejected: it renumbers Phases 3 to 7 and every citation of them,
   and moves the count.
3. **A first step of Phase 3**, before its existence test; Phase 6 does the `.gitignore` swap.
   Chosen.

## Decision

The migration is the opening step of `init` Phase 3, and the `.gitignore` swap belongs to Phase 6.
`init` keeps seven phases.

## Consequences

Checks 7 and 10 do not change. Every later phase reads the migrated file.

# ADR-006: Each gate re-checks its fixes once

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** author (spec); accepted by the developer at the spec ADR checkpoint

## Context

A gate's fixes are made by the Facilitator, so they must be checked by someone else (`skills/cold-read/references/panel.md:71`). The panel allows two re-checks before the readers (child 1 ADR-004). A gate sits before a developer checkpoint, so whatever it cannot settle can go to the developer.

## Options

1. **Two re-checks, as the panel.** Rejected: a gate adds wall-clock time to every stage, and the panel and the cold read still follow.
2. **No re-check.** Rejected: an unchecked fix is exactly the source of the hyalOS fix-made blockers (`../planning-team-review/prd.md`, **Problem**, cause 3).
3. **One re-check per gate, by each role whose finding was fixed; whatever it reports again, or newly reports as blocking, is held for the checkpoint's batch.** Chosen.

## Decision

After a gate's fixes, each role with a fixed finding is dispatched once more with `{diff}`. Nothing it reports is fixed again before the checkpoint: it is held and asked in that checkpoint's batch (prd S-02.3, S-06.3).

## Consequences

A gate is at most two dispatch steps. Held items reach the developer rather than looping.

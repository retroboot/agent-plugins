# ADR-004: The Historian and the research Scout run on sonnet; the Skeptic on opus

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** developer

## Context

Each card states its model once (`context.md` §3, **Models by role**); child 2's ADR-002 put
gathering roles on sonnet and judgment roles on opus. The developer chose the Historian's and
the Skeptic's at the acceptance checkpoint (prd **Checkpoint answers**, A9); the research Scout keeps
the Scout's `sonnet`, as child 2's ADR-002 set it.

## Options

1. **All three on opus.** Rejected: reading and citing past packs or the repository does not need
   the strongest model.
2. **All three on sonnet.** Rejected: the Skeptic's case against an idea is judgment, and a weak
   one is noise the Facilitator must filter.
3. **The Historian and the research Scout on sonnet, the Skeptic on opus.** Chosen.

## Decision

The Historian card and the Scout's research card state `sonnet`; the Skeptic card states `opus`.

## Consequences

The research step costs two cheap dispatches and one strong one. A model is changed by editing one
card.

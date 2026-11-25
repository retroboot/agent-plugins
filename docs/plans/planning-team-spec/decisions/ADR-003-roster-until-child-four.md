# ADR-003: Until child 4, each role runs whenever its stage runs

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** developer

## Context

Child 4 (`../planning-team/README.md`, **Child packs**) scales the roster by route. This pack ships first, so it needs a rule of its own until then. The developer chose at the acceptance checkpoint.

## Options

1. **Run the roles at size M and larger only**, keeping the single author at size S. Rejected: a second rule that child 4 would have to replace, for little saving, since most stages do not exist at size S.
2. **Each drafting role and gate runs whenever its stage writes its file, at every size.** Chosen.

## Decision

The Scout and the context gate run whenever `context.md` is written; the Analyst and the acceptance gate whenever the prd or, at size S, the README Slice's acceptance is written; the Architect whenever `design.md` is; the Planner and the slice gate whenever `plan.md` is. A stage the route skips dispatches no role.

## Consequences

No size rule to maintain. Size S still skips most roles naturally: a Change has no `context.md`, prd or `plan.md`. Child 4 may narrow the roster later, by amending this ADR.

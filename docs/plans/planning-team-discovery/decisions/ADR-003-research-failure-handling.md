# ADR-003: Research failures never stop the brainstorm

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** developer

## Context

`dispatch.md` stops the run on a guard void, but `brainstorm` writes nothing until the developer keeps
it and its result statuses must stay as they are (prd S-07.2). The pack left open the outcome of a
void, a late or over-limit report, the user-visible lines, and how the fallback rows are shown (prd
**Checkpoint answers**, A2, A5, A6 and A7).

## Options

1. **Stop the run on a guard void, as `dispatch.md` does.** Rejected: it needs a new result status,
   against S-07.2. **Void every report of that research step and open without research.** Chosen.
2. **A tree per role, voiding only the one that wrote.** Rejected: three trees per step for a case
   that should not happen with read-only `Explore` roles.
3. **A fixed timeout for a role.** Rejected: nothing in the repository fixes a number. **No timeout;
   missing means the harness returned no report, and over-limit counts as incomplete.** Chosen.
4. **A disabled Agent tool and a structural check on `zz-dryrun-*` for the fallback proofs.**
   Rejected: more machinery than the rows need. **A desk walk, and fixtures removed by hand.** Chosen.

## Decision

A guard void voids that step's reports, names the changed files, removes the tree, and the
conversation opens without research. No timeout; an over-limit report is incomplete and retried
once. The lines are `Research run by the Facilitator: not independent.` and
`Research: {role} gave no complete report; not researched by {role}.` The fallback rows are proven
by a desk walk; fixtures are removed by hand before commit.

## Consequences

Research can be lost without the developer losing the conversation. A hung role waits on the
harness. The fallback is proven less strongly than a live run.

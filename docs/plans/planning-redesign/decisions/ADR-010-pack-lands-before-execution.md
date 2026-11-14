# ADR-010 — The pack merges to the integration branch before any slice executes

**Status:** accepted (developer, 2026-11-13)

**Proposed by:** planner author; accepted by the developer after cold-read round 2

## Context
`work-issue` forks each branch from `origin/{integration}`. A pack that exists only in the
planner's working tree is invisible to it.

## Options
1. Commit the pack inside the first slice's PR: later slices still can't see it until that PR
   merges, and slice 1 carries unrelated review weight. **Rejected.**
2. Executors read the pack from the planner's branch: couples execution to an unmerged branch.
   **Rejected.**
3. Publish opens a `plan/<slug>` PR holding only the pack. Execution requires it on the integration
   branch, and `ship-issue` checks this up front. **Chosen.**

## Decision
Option 3. The plan PR also gives the developer and `review-pr` a natural place to review the plan.

## Consequences
- One extra merge per pack.
- Progress files and the retro then arrive through the slice PRs.

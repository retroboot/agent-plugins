# ADR-008 — Each slice ships as its own PR, with its own progress file

**Status:** accepted (developer, 2026-11-13)

**Proposed by:** planner author; accepted by the developer after cold-read round 2

## Context
`work-issue` can route related issues into one `wave` branch. A single `progress.md` edited by
several slice branches would conflict on every merge.

## Options
1. Allow waves of slices. This needs pack support in `wave`, and blurs which PR satisfied which
   criteria. **Rejected.**
2. One slice is one issue, one branch and one PR. A marker forces the `sequential` strategy.
   Progress lives in `progress/slice-NN.md`, one file per slice. **Chosen.**

## Decision
Option 2. The `slice` skill is responsible for sizing slices so that one PR per slice is
reasonable.

## Consequences
- `wave` is untouched.
- Progress files never conflict.

# ADR-007 — Packs are self-describing; `dev` never depends on `planner`

**Status:** accepted (developer, 2026-11-13)

**Proposed by:** planner author; accepted by the developer after cold-read round 2

## Context
`work-issue` ships in `dev`, and the templates ship in `planner`. A `dev`-only install has no
`skills/planning/` to read (the old `work-issue` noted this at its session-context section).

## Options
1. `work-issue` reads `../planning/references/pack-format.md`: breaks on a `dev`-only install.
   **Rejected.**
2. Duplicate the pack format into a `dev` reference: two copies drift. **Rejected.**
3. Every pack README carries the **How to execute this pack** rules verbatim from the template.
   `work-issue` knows only the marker, the README and the progress file. **Chosen.**

## Decision
Option 3. `work-issue` keeps a minimal fallback: when a pack predates rule changes, it follows the
rules in that pack's own README.

## Consequences
Each pack carries the rules that were current when it was written. That is a feature: a pack is
executed under the rules it was planned against.

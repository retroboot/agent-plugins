# ADR-001 — Packs are committed under `docs/plans/<slug>/`

**Status:** accepted (developer, 2026-11-13)

## Context
Plans have moved between `docs/plans/` (committed) and `.ai/plans/` (gitignored) twice. A
gitignored plan cannot be linked from an issue, seen from another clone or CI, or read by an
executor whose branch was forked from the integration branch.

## Options
1. `.ai/plans/` gitignored: private, but invisible to every other session. **Rejected.**
2. `docs/plans/<name>.md` as a single committed file: this cannot grow progressively. **Rejected.**
3. `docs/plans/<slug>/` as a committed folder per piece of work. **Chosen.**

## Decision
Every planned piece of work gets a committed folder. This applies to this repo and to every repo
the plugin runs in.

## Consequences
- The pack reaches executors through the integration branch (see ADR-010).
- `.ai/` stays gitignored for unrelated scratch, but nothing in the planner writes there.

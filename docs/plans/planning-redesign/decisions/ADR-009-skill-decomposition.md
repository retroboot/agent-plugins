# ADR-009 — `planning` becomes a wrapper over `brainstorm`, `spec`, `slice` and `cold-read`

**Status:** accepted (developer, 2026-11-13)

**Proposed by:** planner author; accepted by the developer after cold-read round 2

## Context
The developer wants a wrapper like `ship-issue`/`ship-pr` that walks through every phase. A single
626-line skill already proved hard to maintain and hard to run in parts.

## Options
1. One large `planning` skill: no standalone re-run of a single phase. **Rejected.**
2. One skill per phase (discover, route, prd, adr, design, slice, review, publish): eight new
   registry entries, and route and publish are too thin to stand alone. **Rejected.**
3. The `planning` wrapper (keeps the name the developer already invokes) owns parse, route,
   approve and publish, and composes `brainstorm`, `spec`, `slice` and `cold-read`. **Chosen.**

## Decision
Option 3. That is three new skills in `planner`, each also usable standalone on an existing pack.

## Consequences
- Templates live once, in `skills/planning/references/`.
- The `planner` description in `marketplace.json`, `CLAUDE.md` and `README.md` changes (Slice 9).

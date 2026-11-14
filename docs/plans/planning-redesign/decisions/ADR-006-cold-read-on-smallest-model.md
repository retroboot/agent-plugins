# ADR-006 — Completeness is tested by a cold read on the smallest model

**Status:** accepted (developer, 2026-11-13)

## Context
The old reviewer ran a checklist against the plan. A checklist cannot find what the author
assumed without writing down. Gaps of that kind show up when someone with no context tries to
act on the plan.

## Options
1. Checklist review (the current approach). **Rejected.**
2. Cold read on the same model as the author: shares the author's blind spots and fills gaps with
   inference. **Rejected.**
3. Cold read on the smallest available model, given only the pack path and repository access. It
   restates the design and lists the questions it would need answered, classed blocking or
   non-blocking. The author fixes the pack and the read repeats, up to 3 rounds. **Chosen.**

## Decision
Option 3, persisted to `cold-read.md`. If the vendor offers no model choice, use a fresh subagent
on the default model and record which model was used.

## Consequences
- If Haiku can execute the pack, every larger model can.
- `cold-read.md` against `progress/` is the "assumed versus reality" comparison.

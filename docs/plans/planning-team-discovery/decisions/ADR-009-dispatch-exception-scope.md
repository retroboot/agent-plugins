# ADR-009: The research exception covers five additions to dispatch.md

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** author (cold-read); accepted by the developer in cold-read round 1

## Context

This amends ADR-001, whose Decision names a `research` Kind and a research prompt frame in
`skills/planning/references/roles/dispatch.md`, and whose Consequences call the reach outside
`brainstorm` "two small edits". The approved design (`design.md` §2, **Dispatch**) adds more to
`dispatch.md` than that: the round 1 cold readers (bQ2, bX1, bX2, aQ10, aK3) and the sibling scan
found the README Brief, ADR-001 and the prd Non-goals all narrower than Slices 1 and 5.

## Options

1. **Widen the exception to the design's five additions.** Chosen.
2. **Keep the narrow wording and record a deviation in Slices 1 and 5.** Rejected: an executor
   would build out of scope by the pack's own text.
3. **Narrow the design to the Kind and the frame**, moving the other rules into `brainstorm`'s
   `research.md`. Rejected: a Re-slice of Slices 1, 3 and 5 for no change in behaviour.

## Decision

The exception outside `brainstorm` is five additions to `dispatch.md` (the `research` Kind value,
the research frame, the research completeness check, the research pass beside **Tree and guard**,
and a research paragraph in **No subagent tool**) and the one skip line in `panel.md`.

## Consequences

The README Brief and the prd Non-goals name all six. `spec`, `slice` and the gates read
`dispatch.md` but not its research text, which applies only to a `research` card.

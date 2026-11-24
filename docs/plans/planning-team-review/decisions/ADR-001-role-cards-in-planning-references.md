# ADR-001: Role cards live in the planning skill's references

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** author (spec); accepted by the developer at the spec ADR checkpoint

## Context

The review panel needs each role defined once (prd S-01.1). The later child packs of
`planning-team` (`spec`, `slice`, `brainstorm`, `planning`) dispatch the same roles. Every planner
phase skill already reaches shared material through `$CLAUDE_SKILL_DIR/../planning/references/`
(`skills/cold-read/SKILL.md:20-21`), and `skills/cold-read/SKILL.md` is 397 lines, so the cards
cannot sit inline.

## Options

1. **`skills/cold-read/references/roles/`.** Next to the first skill that uses them. Rejected: child
   packs 2 to 4 would reach into `cold-read` for material that is not cold-read's.
2. **A new shared skill holding only role cards.** Rejected: it needs a `marketplace.json` entry, an
   `.agents/skills/` symlink and `CLAUDE.md` and `README.md` lines (structural checks 6 and 13)
   for something that is data, not a workflow.
3. **`skills/planning/references/roles/<role>.md`, one file per role.** Chosen.

## Decision

Each role card is `skills/planning/references/roles/<role>.md`, one file per role, and skills read
it as `$CLAUDE_SKILL_DIR/../planning/references/roles/<role>.md`. No skill restates a card's
checklist.

## Consequences

- Child packs 2 to 4 add roles to the same folder and reuse the dispatch contract.
- The dispatch and triage rules shared by every role live once, beside the cards.
- A checklist proposal from a cold-read record is a PR to one file.

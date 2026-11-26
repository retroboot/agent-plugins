# ADR-001: Ship `core` in `planner` and `auditor`

**Status:** accepted (developer, 2026-11-25)

**Proposed by:** developer

## Context

Six skills load `core` in their bootstrap, but only `dev` ships it (#310; README **Repro and root
cause**). A user with `planner` or `auditor` and no `dev` runs those skills without `core`'s quality
gates and git-safety rules. #310 named three fixes, and the developer chose one at the spec
acceptance checkpoint on 2026-11-25 (DN1, DS1, GT3).

## Options

1. **Drop the `core` step and restate inline what each skill relies on**, as `init` does for the
   pathspec rule (`skills/init/SKILL.md:425-434`). Rejected: it copies `core`'s rules into six
   skills and `skills/planning/references/publish.md:189-192`, which must then be kept in step by
   hand, and needs a per-skill map of which rules each one uses.
2. **Make the step conditional** ("load `core` when it is installed"). Rejected: it keeps the
   silent skip #310 reports, and a conditional step still names a skill the plugin does not ship.
3. **Ship `core` in `planner` and `auditor`.** Add `./skills/core` to both plugins' `skills` arrays,
   from the one `skills/core/` directory. `init` and `session` already ship in two plugins, so a
   skill shared across plugins has a precedent (`.claude-plugin/marketplace.json:16-29,51-59`).
   Chosen.

## Decision

Register `./skills/core` in the `planner` and `auditor` entries of `.claude-plugin/marketplace.json`,
and list it in the matching `CLAUDE.md` **Skills:** lines and `README.md` per-plugin tables. Leave
every existing `core` bootstrap step as it is.

## Consequences

- `core` stays the single source of its rules; the six skills' text does not change for this.
- The two statements that only `dev` ships `core` (`skills/init/references/git-hygiene.md:64-72`,
  `skills/init/SKILL.md:433-434`) become false and are corrected in the same slice.
- With more than one of these plugins installed, `core` is installed more than once, as `init` and
  `session` already are today. The pack does not establish how the plugin manager resolves that
  (GT2); the `init` and `session` precedent is the only evidence.

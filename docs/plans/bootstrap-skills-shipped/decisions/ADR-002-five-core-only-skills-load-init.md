# ADR-002: The five `core`-only skills load `init` and `session` too

**Status:** accepted (developer, 2026-11-25)

**Proposed by:** developer

## Context

This revisits a gap that `docs/plans/move-to-retroboot/decisions/ADR-002-full-rename-clean-cut.md`
(lines 28-32) accepted for v2.0.0, and decides it differently for these skills. That ADR is in
another, closed pack and is not edited. `spec`, `slice`, `cold-read`, `brainstorm` and `audit` load
`core` alone, so run first in a repo that still holds `.hivrr.json` they resolve config as if there
were none, until an `init`-loading skill runs (`skills/init/references/config.md:344-352`). The
developer chose to close the gap at the spec acceptance checkpoint on 2026-11-25 (DN4, DS2).

## Options

1. **Leave the gap as accepted.** Rejected by the developer.
2. **Load `init` and `session` in the four `planner` skills only.** `planner` already ships both.
   Rejected: `audit` would keep the gap.
3. **Load `init` and `session` in all five, and ship `init` and `session` in `auditor`.** Chosen.

## Decision

Give `spec`, `slice`, `cold-read`, `brainstorm` and `audit` the three-step bootstrap the `dev`
workflow skills use: `init`, then `session`, then `core`, in that order and with the same wording
(`skills/work-issue/SKILL.md:16-21`). Register `./skills/init` and `./skills/session` in the
`auditor` entry, with its `CLAUDE.md` **Skills:** line and `README.md` table.

## Consequences

- Every skill that reads config migrates `.hivrr.json` first, so
  `skills/init/references/config.md:344-352` no longer has a `core`-only list to name and is
  corrected in the same slice. `RELEASE-NOTES.md`'s v2.0.0 entry is a record and is not edited.
- `audit` now runs `init`, which validates provider config, may bootstrap repo labels, and in Phase 6
  may commit a `.gitignore` change (`skills/init/SKILL.md:425-434`). Running an audit can therefore
  make that one `init` commit, as every `dev` workflow skill already can.
- `spec`, `slice` and `cold-read` run inside `planning`, which has already run `init`. They run it
  again; its phases are idempotent, each reporting and moving on when it has nothing to do
  (`CLAUDE.md`, **Shared setup skills**).
- The shared-setup sentences (`README.md:21`, `CLAUDE.md:138`) name `auditor` as well.

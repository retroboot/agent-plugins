# ADR-004: init migrates the old config file automatically

**Status:** accepted

**Proposed by:** developer

## Context

Dozens of repositories may hold a `.hivrr.json`. Under ADR-002's clean cut, a repository that is not
migrated silently falls back to defaults, verification included (prd Problem 3).

## Options

1. **Ask before renaming.** Rejected: dozens of repositories, and the developer wants no prompt.
2. **A separate migration command.** Rejected: one more thing to remember in each repository, when
   `init` already runs first in every `dev` workflow and in `planning`.
3. **Automatic in `init`.** Rename `.hivrr.json` to `.agent-plugins.json` and say so in one `INIT:`
   line. When both exist, the new one wins and the old one is removed, but only once the new one
   validates. A failed rename or removal, or a path that is not a regular file, stops `init` with an
   `INIT:` error line. Phase 6 swaps the `.gitignore` line and untracks a still-tracked
   `.hivrr.json`. Chosen.

## Decision

Option 3, as specified by prd stories S-04 and S-05. The migration stays in `init` until a later
release removes it, outside this plan.

## Consequences

No repository needs a manual step. `init` is the one place left that names `.hivrr.json`, so it is
on the allowed list of prd S-07.2.

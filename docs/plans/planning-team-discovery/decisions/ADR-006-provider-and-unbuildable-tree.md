# ADR-006: Phase 2 loads session on demand; an unbuildable tree means no research

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** developer

## Context

ADR-002 has the Facilitator read open issues through the session provider, but a standalone
`brainstorm` loads only `core` (`skills/brainstorm/SKILL.md:28-29`). ADR-002 also has research read
a detached tree, which cannot be built without a git repository or when `git worktree add` fails.
The developer chose at the design checkpoint (`design.md` **Checkpoint answers**, DR6 and DR7).

## Options

1. **Add `session` to Bootstrap.** Rejected: it changes a Bootstrap `context.md` keeps, and loads a
   provider on runs that may not need one. **Load `session` in Phase 2 only when no provider
   reference is loaded, with the host-unavailable line when that fails.** Chosen.
2. **Read issues only when a reference is already loaded.** Rejected: a standalone run would
   silently lose issues.
3. **Without a tree, research by the cards in the checkout, marked not independent.** Rejected: the
   guard would watch a tree the developer edits. **Stop the run.** Rejected: against ADR-003.
   **One line, and the conversation opens without research.** Chosen.

## Decision

Phase 2 loads `session` when no provider reference is loaded; if that fails, it says
`Issues: issue host unavailable; going on without open issues.` and goes on. When the tree cannot be
built, one line names the failure and the conversation opens without research.

## Consequences

Every run can read issues without a Bootstrap change. A repository with no git still gets a
brainstorm, without research.

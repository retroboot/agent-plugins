# ADR-002: Research reads a detached tree of {base}; the Facilitator reads issues

**Status:** accepted (developer, 2026-11-24); amended by ADR-007, recent commits come from the checkout's git log; amended by ADR-008, fixture packs are copied in by hand

**Proposed by:** developer

## Context

`dispatch.md` **Tree and guard** copies a pack into a detached tree of `{base}`, but a new topic has
no pack and a resumed pack is untracked; Phase 2 also reads open issues, which needs the issue host
and its credential (`context.md` §2 and §3). The developer chose at the acceptance checkpoint (prd
**Checkpoint answers**, A3 and A4).

## Options

1. **The developer's checkout, read-only, guarded.** Rejected: it mixes uncommitted work and
   in-flight packs into what the Historian treats as history, and the guard would watch a tree the
   developer is editing.
2. **A detached tree of `{base}`, a resumed pack copied in and never read as a past pack, nothing
   copied for a new topic; the Historian reads committed packs only.** Chosen.
3. **Research roles read issues with the session's token.** Rejected: it gives read-only subagents
   network and credentials. **The Facilitator reads issues and commits through the session provider,
   roles stay offline.** Chosen.

## Decision

Research roles run in a detached tree of `{base}` under the checksum guard. A resumed pack is copied
in and excluded from the Historian; a new topic copies nothing; dry-run fixture packs are copied in
the same way. The Facilitator reads open issues and recent commits; when the host fails, one line
says so and the run goes on.

## Consequences

History is only what has merged, so an in-flight sibling pack is invisible to the Historian. Roles
need no network. Fixtures reach the Historian without being committed.

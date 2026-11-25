# ADR-007: Recent commits come from the checkout's git log

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** author (cold-read); accepted by the developer in cold-read round 1

## Context

This amends ADR-002, which has the Facilitator read open issues and recent commits through the
session provider. The provider reference lists only issues (`skills/session/references/github.md:34`),
and `brainstorm` Phase 2 already reads recent commits itself (`skills/brainstorm/SKILL.md:74`). The
cold-read panel found the design reading commits from `git log` against ADR-002's wording (PE2,
PT6), and the developer chose at the panel's batch.

## Options

1. **Commits through the session provider.** Rejected: no provider command lists commits, and it
   would add network and a credential to a read the checkout already holds.
2. **The `git log` of `{base}`.** Rejected: it hides the developer's own unpushed work, which is
   what the conversation is about.
3. **The checkout's `git log`, read by the Facilitator.** Chosen.

## Decision

The Facilitator reads open issues through the session provider and recent commits from the
checkout's `git log`. Research roles still read neither.

## Consequences

Commits need no network and no credential, and include unpushed work. Only issues depend on the
issue host.

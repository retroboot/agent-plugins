# ADR-010: Remove the last collaborator only after a clean history scan

**Status:** accepted (developer, 2026-11-25)

**Proposed by:** author (cold-read); accepted by the developer in cold-read round 1

## Context

ADR-006 orders the publish steps as: remove the other collaborators and the
`CLAUDE_CODE_OAUTH_TOKEN` secret, scan the history, then make the repository public. At the cold read
panel the developer moved collaborator removal after the scan, and removed `cedwards-plk` (their own
second account) as a direct collaborator on 2026-11-25, leaving `bschappaugh-plk`.

## Options

1. **Keep ADR-006's order: remove collaborators before the scan.** Rejected: a scan finding keeps
   the repository private, and access should not be cut while the developer judges it.
2. **Delete secrets and clear access paths first, scan, record the approval line, then remove
   `bschappaugh-plk` and make the repository public.** Chosen.

## Decision

C8.d deletes secrets and clears every other access path and surface; C8.e scans; C8.f needs the
`Go public: approved by retroboot {date}` line, then removes `bschappaugh-plk`, then changes the
visibility (`design.md` §2, C8).

## Consequences

`bschappaugh-plk` keeps read access until the moment before the repository goes public, which is
when that access stops mattering.

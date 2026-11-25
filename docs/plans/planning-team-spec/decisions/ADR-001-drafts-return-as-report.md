# ADR-001: A drafting role returns its file as its report, and the Facilitator writes it

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** developer

## Context

A drafting role (prd S-01) produces a whole pack file. Every role child 1 built is read-only, dispatched as `subagent_type: Explore` under a checksum guard that voids the pass if anything in the pack or the tree changes (`context.md` §3, **The tree and guard**). A drafter that writes files needs either that guard relaxed, or a way for its file to reach the pack without the drafter writing it. The developer chose at the acceptance checkpoint.

## Options

1. **The drafter writes into the pack itself**, dispatched as a writing (general-purpose) subagent. Rejected: roles stop being read-only, and the guard can no longer tell a draft from an accidental write, so it would have to be turned off for drafters.
2. **The drafter returns the whole file as its report, and the Facilitator writes it verbatim.** Chosen.

## Decision

Every drafting role runs as `Explore` under the same tree and guard as a reviewing role, and its report is the drafted file. The Facilitator checks the draft for completeness (prd S-01.2), writes it to the pack, and adds its Read order entry.

## Consequences

Every role stays read-only and the guard is unchanged. A draft passes through the Facilitator's context once, which costs tokens for a long file. Whether a long file comes back whole is an Assumptions row probed only by Slice 1's dry run; if it fails, the drafter returns the file one section per dispatch.

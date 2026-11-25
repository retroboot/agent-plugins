# ADR-008: Dry-run fixture packs are copied into a research tree by hand

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** author (cold-read); accepted by the developer in cold-read round 1

## Context

This amends ADR-002, which says dry-run fixture packs are copied into the research tree "the same
way" as a resumed pack. The research pass copies only `{path}`, so no shipped text would copy a
fixture. The cold-read panel asked who copies them (PT8), and the developer chose at the panel's
batch.

## Options

1. **The research pass copies fixtures.** Rejected: shipped text would name dry-run fixtures.
2. **A hand copy by the executor, in dry runs only.** Chosen.

## Decision

The executor copies a fixture pack into a research tree by hand, in a dry run only. No shipped text
copies or names a fixture.

## Consequences

The Historian reads committed packs and, in a dry run, a hand-copied fixture. Each slice's Verify
checks that `skills/` names no `zz-dryrun` fixture.

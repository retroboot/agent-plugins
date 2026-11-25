# ADR-002: Remove every hivrr name, with a clean cut

**Status:** accepted

**Proposed by:** developer

## Context

`hivrr` names three kinds of thing: branding prose, contracts users depend on (the marketplace name
and the config filename), and internal markers no user sees (README Key insights). Each could be
renamed or kept.

## Options

1. **Branding only.** Rename prose and the marketplace; keep `.hivrr.json` and the markers.
   Rejected: the developer wants no `hivrr` left.
2. **Branding and the config file.** Rejected for the same reason: the markers would keep the name.
3. **Everything, with a dual-read fallback** in every reader skill. Rejected: the repository has no
   config loader, so a fallback is prose in seventeen files, for two users who can be told.
4. **Everything, with a clean cut.** Every `hivrr` string outside the historical record is renamed;
   only `init` reads `.hivrr.json`, to migrate it. Chosen.

## Decision

Rename the marketplace, the config file and the `HIVRR_*` markers, and rewrite the prose. No skill
but `init` reads the old config name.

## Consequences

Each installing user switches marketplaces once. Skills that load only `core` (`spec`, `slice`,
`cold-read`, `brainstorm`, `audit`) see an unmigrated repository as unconfigured until an
`init`-loading skill runs; the developer accepted this gap at the acceptance checkpoint.

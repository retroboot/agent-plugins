# ADR-003: The new check scans every numbered `Load the` step

**Status:** accepted (developer, 2026-11-25)

**Proposed by:** developer

## Context

The new structural check (README Slice, 1.4) needs a scope. Acceptance 1.1 first said steps "under
`## Bootstrap`", while the comparison in `context.md` §4 scans the whole `SKILL.md`. One numbered
step already sits outside a Bootstrap section: `skills/ship-pr/SKILL.md:57`,
`1. Load the \`review-pr\` skill …`, under Phase 2 (GF5, GT5). The developer chose at the spec
acceptance checkpoint on 2026-11-25 (DN7). The report tag was left open (DN5, GT4).

## Options

1. **Steps under `## Bootstrap` only.** Rejected: a skill loaded mid-workflow, like `review-pr` in
   `ship-pr`, must be shipped just as much, and the narrower scope needs heading-aware parsing.
2. **Every line of a `SKILL.md` that starts `N. Load the \`{skill}\` skill`.** Chosen.

## Decision

The check reads, for each plugin, every skill it ships, and for each line of that skill's `SKILL.md`
matching `^[0-9]+\. Load the \`{name}\` skill`, reports `BOOTSTRAP GAP {plugin}/{skill} loads {name}`
when `./skills/{name}` is not in that plugin's `skills` array. A `Load the …` sentence that does not
start a numbered line is not scanned.

## Consequences

- "Bootstrap step" in this pack means any such numbered line, wherever it sits.
- Prose that relies on another skill without a numbered step (for example
  `skills/planning/references/publish.md:189-192`) is not covered; under ADR-001 it resolves anyway.

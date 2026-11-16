# ADR-<NNN>: <Decision title>

**Status:** <accepted | proposed | accepted (developer, YYYY-MM-DD)>

**Proposed by:** <developer | author (<skill>)>

_Guidance: `accepted` when the developer stated the decision outright; `proposed` when the author
made it and it is shown at the `spec` checkpoint. When the developer approves a proposed ADR,
change the Status to `accepted (developer, <date>)`. Save the file as
`decisions/ADR-<NNN>-<kebab-title>.md`. Numbers start at 001 and are never reused._

_Guidance: Proposed by is `developer` when the developer stated the decision, otherwise
`author (<skill>)`, naming the skill that wrote it, such as `author (spec)`. When the developer
approves a proposed ADR, append `; accepted by the developer at <checkpoint>`, such as
`at the spec ADR checkpoint`._

_Guidance: once accepted, this ADR is never edited (`pack-format.md` §1, Lifecycle). A later
change is a new ADR whose Context names this one; this one then gains a single clause at the end
of its Status line: `; amended by ADR-<NNN>, <what it changes>` or `; superseded by ADR-<NNN>`.
When this ADR amends or supersedes an earlier one, say so in the first sentence of its Context._

## Context

_Guidance: the forces at play, and why a decision is needed now._

## Options

_Guidance: at least two. Every rejected option says why it was rejected._

1. **<Option A>.** <description>. Rejected: <reason>.
2. **<Option B>.** <description>. Chosen.

## Decision

_Guidance: the choice, in one or two sentences, stated so an executor can apply it._

## Consequences

_Guidance: what becomes easier, what becomes harder, and what follow-up work it creates._

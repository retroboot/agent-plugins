# ADR-002: The Scout runs on sonnet; the Analyst, Architect and Planner on opus

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** developer

## Context

Each card states its model once, in `## Model` (`context.md` §3, **The dispatch contract**). Child 1 put the Fact-checker, Editor and Test engineer on sonnet and the Trust reviewer on opus. The four drafting roles need a model each. The developer chose at the acceptance checkpoint.

## Options

1. **Every drafter on opus.** Rejected: the Scout's job is gathering and citing, like the Fact-checker's, and does not need the strongest model.
2. **Every drafter on sonnet.** Rejected: the prd, the design and the slices are judgment-heavy, and weaker drafts move the work back to the gates and the cold read.
3. **The Scout on sonnet; the Analyst, Architect and Planner on opus.** Chosen.

## Decision

`scout.md` states `sonnet`; `analyst.md`, `architect.md` and `planner.md` state `opus`.

## Consequences

The drafts that carry judgment get the strongest model, and the citation work stays cheap. A model is changed by editing one card.

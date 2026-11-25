# ADR-004: Every role card states its kind, and the panel dispatches review cards only

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** author (spec); accepted by the developer at the spec ADR checkpoint

## Context

The panel pass dispatches every card it finds in `roles/` (`skills/cold-read/references/panel.md:13-14`). The drafting cards this pack adds would be dispatched as panel reviewers unless the panel can tell them apart.

## Options

1. **Drafting cards live in a `roles/drafters/` subfolder.** Rejected: "every file in it" then depends on how a listing treats a folder, and a reviewing card used by a gate in `spec` would still have to live beside the panel's.
2. **A list of panel cards in `panel.md`.** Rejected: a second place to update whenever a reviewing card is added, the drift child 1 removed.
3. **Every card gains a `## Kind` section, `review` or `draft`; the panel dispatches `review` cards only, and a card with no kind is not dispatched.** Chosen.

## Decision

Each card in `skills/planning/references/roles/` has `## Kind` after `## Model`, holding `review` or `draft`. The panel pass step 1 dispatches only `review` cards and says `Card {file} states no kind; not dispatched.` for any card without one (prd S-01.3).

## Consequences

The card stays the one place a role is defined. The four existing cards gain one section each. `dispatch.md` picks the prompt frame by kind.

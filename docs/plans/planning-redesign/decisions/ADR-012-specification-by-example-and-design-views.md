# ADR-012 — Packs specify by example, and show lifecycles, flows, tests and screens

**Status:** accepted (developer, 2026-11-13)

## Context
Two cold reads showed that executors stall on what a plan *implies* but does not state: edge
cases, who owns a transition, which test level proves what. A single Given/When/Then per
criterion states the general case and leaves every edge to inference. The UI modifier only
pointed to a checklist, and no modifier covered observability.

## Options
1. Leave the format as it is, and let the cold read catch omissions one at a time. **Rejected**:
   the same classes of gap recur on every pack.
2. Add every well-known practice to every pack (personas, estimation, RACI, high-fidelity
   mockups, Gantt). **Rejected**: bloat, and none of these help a model build the right thing.
3. Add the practices that remove executor guesswork, each as a section switched on by the route
   (`design.md` §3, Content sections). **Chosen.**
   - Specification by example: rules with example tables, edge and failure cases included.
   - Failure modes, non-functional requirements and assumptions.
   - Story map.
   - Domain model, state machines with illegal transitions, sequence flows.
   - Test strategy and pre-mortem.
   - A full `ui` modifier: screens, flow, text wireframes, state tables.
   - A new `observability` modifier.

## Decision
Option 3. Example rows get IDs (`S-NN.k.eN`) and are traced like criteria (README rule 4).
Wireframes are low-fidelity text in `text` fences. High-fidelity mockups are linked, never
embedded (ADR-003).

## Consequences
- PRDs get longer, though each part is tabular and skimmable.
- `spec` writes most of this, and `slice` and `cold-read` check it.
- This pack was revised to follow the format (prd and design §10–§14), as its first example.
- ADR-004 gains an eighth modifier.

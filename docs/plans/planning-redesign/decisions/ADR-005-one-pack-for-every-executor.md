# ADR-005 — One pack serves every executor: mandatory versus guide

**Status:** accepted (developer, 2026-11-13)

## Context
A frontier model does best with outcomes and contracts and freedom in how to implement them. A
small model does best with a concrete path and hard fences. The developer will not know in advance
which one will execute.

## Options
1. Two pack variants: twice the writing, and they drift. **Rejected.**
2. Write for the weakest executor only: this constrains strong models into typists. **Rejected.**
3. Every slice splits into **mandatory** items (Outcome, Acceptance, Contracts, Stop conditions,
   Verify) and **guide** items (Pattern to follow, Suggested path, Files). The suggested path
   explicitly permits deviation when every mandatory item still holds, as long as the deviation is
   recorded. **Chosen.**

## Decision
Option 3. Stop conditions are the main lever for weak executors, so they are mandatory in every
slice.

## Consequences
Deviations become data (`progress/`), which feeds the retro (S-08.2).

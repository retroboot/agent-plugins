# ADR-003 — No code inside plans

**Status:** accepted (developer, 2026-11-13)

## Context
The old Medium tier wrote failing tests and implementations into the plan. The code went stale,
repeated the executor's work, and fixed the implementation before anyone had looked at the real
codebase.

## Options
1. Code for all executors. **Rejected** for the reasons above.
2. Code only for weaker executors. **Rejected**: the planner cannot know who will execute (ADR-005).
3. No code at all: contracts as tables, behaviour as Given/When/Then, patterns as `path:line`
   pointers to existing code. **Chosen.**

## Decision
No fenced block in a pack may contain code in a programming language. Every fence must be tagged,
and only these tags are allowed:

- `bash` or `sh`: commands under Verify;
- `mermaid`: diagrams;
- `text`: trees and layouts.

An untagged fence is rejected, because it could hide code (tightened after cold-read round 1).

## Consequences
- Weaker executors are guided by **Pattern to follow** pointers to real code, which is never stale
  in the way a pasted snippet becomes stale.
- `cold-read` and `slice` both check this.

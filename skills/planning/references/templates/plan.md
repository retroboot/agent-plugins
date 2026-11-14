# Plan

_Guidance: size M and larger. At size S this file is absent and the README's **Slice** section is
the plan. Each slice is one issue and one PR, independently mergeable. The mandatory headings are
Outcome, Acceptance, Contracts, Stop conditions and Verify; Pattern to follow, Suggested path and
Files are guide. A slice missing a mandatory heading is not ready for the checkpoint._

## Dependency graph

_Required at size L; optional at M. Guidance: a Mermaid `flowchart` with one node per slice._

## Traceability

_Guidance: every PRD criterion ID appears at least once. A row may group several IDs that share the
same slices._

| Criterion | Slices |
|---|---|
| S-01.1 | 1 |

## Shared contract

_Optional. Guidance: interfaces that several slices use, as tables. Delete when there are none._

---

## Slice 1 — <name>

Issue: # · Depends on: none · Stories: S-01 · Map: <story-map steps, only when the PRD has a Story map>

### Outcome

_Mandatory. Guidance: one or two sentences describing the observable result._

### Acceptance

_Mandatory. Guidance: the PRD criterion IDs this slice satisfies, then local criteria `1.k`. A
behavioural local criterion uses Given/When/Then; a structural one may be a plain statement whose
proof is a Verify command. The example rows under each listed PRD criterion are proven too._

- **S-01.1**
- **1.1** Given <state>, when <action>, then <result>.

### Contracts

_Mandatory. Guidance: interfaces this slice creates or changes, as tables (name, inputs, outputs,
errors, invariants), or a reference to a `design.md` table. Migration and Rewrite slices end this
section with a **Rollback:** line._

### Stop conditions

_Mandatory._

- Stop if a contract this slice depends on has drifted from `context.md` (preflight).
- _Guidance: one "Stop if …" bullet per situation the executor must not improvise through._

### Verify

_Mandatory. Guidance: exact commands in a `bash` fence, each with its expected output, then the
dry-run scenarios for behavioural criteria._

### Pattern to follow

_Guide. Guidance: `path:line` of existing work to imitate._

### Suggested path

Default route. You may deviate if every mandatory item still holds; record why.

1. _Guidance: ordered steps._

### Files

_Guide. Guidance: expected create, modify and delete list._

- Create: `<path>`
- Modify: `<path>`

# Design

_Guidance: every heading below says when it is included. Delete a section whose trigger does not
apply; never leave one empty. Nothing here is code: contracts are tables, behaviour is prose, and
every fence is tagged `mermaid`, `text`, `bash` or `sh`._

## 1. Architecture

_Always. Guidance: the components involved, their responsibilities and how they connect. A Mermaid
`flowchart` helps when there are more than three._

## 2. Contracts

_Always. Guidance: every interface the slices create or change, as tables: name, inputs, outputs,
errors, invariants. Slices refer to these tables rather than restating them._

| Name | Inputs | Outputs | Errors | Invariants |
|---|---|---|---|---|
| <interface> | <inputs> | <outputs> | <errors> | <invariants> |

## 3. Domain model

_Included when the work adds or changes persisted entities or core types. Guidance: a Mermaid
`erDiagram`. Entity names must match the glossary in `context.md`._

## 4. State machines

_Included when any entity with a lifecycle is touched. Guidance: one Mermaid `stateDiagram-v2` per
entity, followed by its list of illegal transitions._

### <Entity>

Illegal transitions:

- <from> → <to>: <why it is illegal>

## 5. Flows

_Included when two or more components interact. Guidance: a Mermaid `sequenceDiagram` of each main
flow._

## 6. Test strategy

_Always with a design. Guidance: the levels used, what each proves, and the fixtures. Then state the
level each example row in the PRD is proven at; the slice that owns a criterion proves its rows._

| Level | Proves | How | Fixtures and test data |
|---|---|---|---|
| <unit \| integration \| e2e \| structural \| dry run> | <what> | <command or method> | <fixtures> |

## 7. Risks

_Always. Guidance: numbered `R1`, `R2`, …_

| # | Risk or assumption | Mitigation |
|---|---|---|
| R1 | <risk> | <mitigation> |

## 8. Pre-mortem

_Size M and larger. Guidance: "It is six months later and this failed. Why?" Each item maps to a
mitigation, a stop condition in a named slice, or a risk row above._

| # | Failure story | Maps to |
|---|---|---|
| P1 | <story> | <R-row, stop condition in Slice N, or mitigation> |

## Modifier: <name>

_One section per modifier on the route; delete this heading when there are none. Guidance: state
what `skills/planning/references/pack-format.md` §2, Modifiers, requires for that modifier. For
`ui` at size M and larger, link `ux.md` here instead of writing the screens inline. For Rewrite,
also include the cutover plan; for Migration and Rewrite, the rollback per slice._

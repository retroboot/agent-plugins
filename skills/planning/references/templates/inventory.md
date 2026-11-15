# Inventory

_Migration or Rewrite only. Guidance: keep the section for this pack's type and delete the other.
Every row must map to a slice or a criterion, so nothing found here is left unplanned._

## Usage sites

_Migration. Guidance: every place that uses what is being migrated, and each breaking change mapped
to the slice that handles it._

| path:line | Usage | Breaking change | Slice |
|---|---|---|---|
| `<path:line>` | <how it is used> | <yes: what breaks \| no> | <N> |

## Behaviour inventory

_Rewrite. Guidance: every observable behaviour of the old system, with the evidence for it and the
PRD criterion that keeps, changes or drops it._

| Behaviour | Evidence (path:line in the old system) | Criterion |
|---|---|---|
| <behaviour> | `<path:line>` | S-NN.k |

## Parity matrix

_Rewrite. Guidance: one row per behaviour above. Every status has a reason._

| Behaviour | Old | New | Status |
|---|---|---|---|
| <behaviour> | <old> | <new> | <kept \| changed: reason \| dropped: reason> |

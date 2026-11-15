# Progress — Slice <N>

_Guidance: save as `progress/slice-NN.md`, with `NN` the slice number zero-padded to two digits.
Written by the executor and committed in the slice's own PR. The sections and their order match
README rule 7._

| | |
|---|---|
| **Status** | <in-progress \| blocked \| done> |
| **Issue** | #<n> |
| **PR** | this PR |
| **Executor model** | <model, if known> |
| **Date** | <YYYY-MM-DD> |

## Preflight

_Guidance: each `context.md` citation this slice touches, one line each, and whether it holds._

- `<path:line>`: holds | differs: <how>

## Acceptance

_Guidance: every criterion ID and every example ID under it, and how each was shown: a test name, a
Verify command and its output, or a dry-run scenario with the phase and line that satisfies it._

| ID | How it was shown |
|---|---|
| S-01.1 | <proof> |
| S-01.1.e1 | <proof> |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| <plan> | <what happened> | <reason> | <y \| n> |

## Decisions

_Guidance: choices the plan left open, and what was chosen. Write "None." when empty._

## Discoveries

_Guidance: what the next slice or the retro should know. Write "None." when empty._

## Blocked on

_Only when Status is `blocked`; delete otherwise. Guidance: the question that must be answered, and
the stop condition that triggered. List what is partial in the `wip:` commit._

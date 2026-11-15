# Cold read

| | |
|---|---|
| **Model** | <model, and how it was selected> |
| **Input** | Pack path and repository read access only; no conversation context |
| **Rounds** | <n> |
| **Result** | <pass \| COLD READ BLOCKED, with the count of blocking questions left> |

_Guidance: append one `## Round N` section per round and never overwrite an earlier one. Each round
uses a new reader that has not seen the pack before. At most 3 rounds; blocking questions left
after the third go to the developer._

## Round 1 — <YYYY-MM-DD>

_Guidance: which slices the reader thought through, how many citations it spot-checked and how many
held, and whether it found any code._

### Questions

| Id | Blocking | File | Gap | Resolution |
|---|---|---|---|---|
| Q1 | <y \| n> | <file and section> | <what was missing or ambiguous> | <the edit made, or why none> |

### Contradictions

| Item | Resolution |
|---|---|
| <two places that disagree> | <which one changed> |

### Citations checked

| Citation | Holds |
|---|---|
| `<path:line>` | <yes \| partly \| no> |

## Result

_Guidance: rewritten after every round. "Pass" only when no blocking question remains._

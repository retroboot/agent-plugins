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

_Guidance: each reader's letter, model and the slices it thought through (cold-read
`references/readers.md`), how many citations it spot-checked and how many held, and whether it found
any code._

_Guidance: then one line for the review panel pass before the reader, when one ran: each role, its
model as recorded, its findings and how many were blocking (cold-read `references/panel.md`)._

### Questions

| Id | Blocking | Role | File | Gap | Resolution |
|---|---|---|---|---|---|
| aQ1 | <y \| n> | <fact \| test \| editor \| trust \| reader \| author> | <file and section> | <what was missing or ambiguous> | <the edit made, or why none; for a reader item traced to a role, ending `Checklist line proposed for {role}: …`> |

### Contradictions

| Item | Resolution |
|---|---|
| aC1 (<role>): <two places that disagree> | <which one changed; for a Role other than `reader`, ending `Checklist line proposed for {role}: …`> |

### Citations checked

| Citation | Holds |
|---|---|
| `<path:line>` | <yes \| partly \| no> |

## Result

_Guidance: rewritten after every round. "Pass" only when no blocking question remains._

<`Pass after {total} round(s) ({n} in this run).` \| `COLD READ BLOCKED: {b} blocking question(s) left after round {N} ({total} rounds, {n} in this run).`>

### Checklist proposals

_Guidance: one bullet per checklist line proposed in this run, with the item Id and the role card,
or `None.`_

### Panel without a reader

_Guidance: only when the run stopped before this run recorded a round: the panel's findings in the
Questions table form (cold-read `references/panel.md` **No reader runs**). Otherwise leave it out._

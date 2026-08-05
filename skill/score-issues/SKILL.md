---
name: score-issues
description: Score a list of issues by urgency (0-99) for work allocation prioritization
license: MIT
compatibility: opencode
---

# Score Issues

You are a utility worker. Score a list of issues by urgency and emit a machine-readable
result. No user interaction — run to completion and exit.

## Phase 1 — Parse Input

Input format: `--repo owner/name --issues 123,456,789`

Extract:
- `repo` — required, from `--repo owner/name`
- `issue_numbers` — comma-separated integers from `--issues`

If either `--repo` or `--issues` is missing or the issue list is empty, emit:
RESULT_JSON: {"scores": {}}
and exit.

## Phase 2 — Fetch Issues

For each issue number, use the **Get issue** command from the loaded reference.

Skip any issue that returns an error (closed, not found) — do not stop.

Truncate each body to 500 characters before scoring.

## Phase 3 — Score

Score each fetched issue on a 0–99 urgency scale. Work through the rubric in order — band first,
then adjust — so that the same issue scores the same way on two different runs. An unstated rubric
produces scores that look precise and are not comparable.

**Step 1 — Pick the band from severity and impact.**

| Band | Meaning | Typical signals |
|---|---|---|
| 90–99 | Production is broken or data is at risk right now | data loss, corruption, security vulnerability, auth bypass, total outage, `P0`, `critical` |
| 70–89 | Core functionality broken for many users, with no workaround | crash on a main path, a primary feature unusable, `P1` |
| 50–69 | A real defect with a workaround, or a partial-impact bug | incorrect output in a secondary path, degraded performance, `bug` |
| 30–49 | Wanted work that is not a defect | `enhancement`, `feature`, refactors with a clear payoff |
| 10–29 | Maintenance and polish | `chore`, `refactor`, test coverage, cosmetic UI |
| 0–9 | Documentation and trivia | `docs`, typos, comment fixes |

**Step 2 — Adjust within the band.** Each adjustment moves the score, never the band:

- **+10** if the issue blocks other issues or another person's work — state which
- **+5** if it is a regression of something that previously worked
- **+5** if the body gives concrete reproduction steps, making it immediately actionable
- **−5** if requirements are unclear or the issue is a question rather than a task
- **−10** if it is explicitly blocked by another open issue that is not yet done

Clamp the result into `0…99`.

**Step 3 — Resolve label conflicts.** When labels disagree with the body, the body wins — labels are
applied by hand and go stale. When two priority labels are present, the most urgent wins. Note the
conflict in your reasoning, not in the output.

Assign one integer per issue. Issues that errored during fetch receive score 0.

## Phase 4 — Emit Result

Display:
```
WORKFLOW COMPLETE
Issues scored: {issue_numbers.join(', ')}
```

Then output this exact line as the final line of your response:

RESULT_JSON: {"scores": {"123": 72, "456": 41, "789": 8}}

Where keys are issue number strings and values are integer scores 0–99.

No explanation after this line.

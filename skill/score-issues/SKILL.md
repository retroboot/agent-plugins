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

## Phase 2 — Hub Fast-Path

If `hub_mcp=true`:

Call `mcp__hub__hub__score_issues` with `issues=[{issue_numbers}]`.

If the response does not contain `degraded: true`: emit the result directly as `RESULT_JSON` (mapping hub scores to the output format) and skip to Phase 5.

If the response contains `degraded: true`: continue to Phase 3.

If `hub_mcp=false`: continue to Phase 3.

## Phase 3 — Fetch Issues

For each issue number, use the **Get issue** command from the loaded reference.

Skip any issue that returns an error (closed, not found) — do not stop.

Truncate each body to 500 characters before scoring.

## Phase 4 — Score

Score each fetched issue on a 0–99 urgency scale using these criteria:

- **Impact on users** — does it break core functionality or cause data loss?
- **Severity** — crash/data loss (high) vs. cosmetic/minor (low)
- **Blocking other work** — does it block other issues or the team?
- **Label signals** — `P0`/`critical` push toward 90+, `bug` toward 50–70, `enhancement` toward
20–50, `docs`/`chore` toward 0–20

Assign one integer per issue. Issues that errored during fetch receive score 0.

## Phase 5 — Emit Result

Display:
```
WORKFLOW COMPLETE
Issues scored: {issue_numbers.join(', ')}
```

Then output this exact line as the final line of your response:

RESULT_JSON: {"scores": {"123": 72, "456": 41, "789": 8}}

Where keys are issue number strings and values are integer scores 0–99.

No explanation after this line.

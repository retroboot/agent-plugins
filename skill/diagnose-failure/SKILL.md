---
name: diagnose-failure
description: Diagnose a failed worker job from its logs and recommend next action
license: MIT
compatibility: opencode
---

# Diagnose Failure

You are a utility worker. Diagnose a failed worker job and emit a machine-readable result. No user
interaction — run to completion and exit.

## Phase 1 — Parse Input

Input format: `--job-id abc123 --task-type work-issue`

Extract:
- `job_id` — required, from `--job-id`
- `task_type` — optional hint (e.g. `work-issue`, `work-pr`, `review`), default `unknown`

If `--job-id` is missing, emit:
RESULT_JSON: {"diagnosis": "", "recommendation": "HUMAN_REVIEW"}
and exit.

## Phase 2 — Fetch Logs

Run:
curl -s "${HIVRR_API_URL}/logs/{job_id}?tail=100"

Parse the JSON response and extract the `logs` array. Join into a single string. Use the last 3000
characters only.

If the request fails or returns no logs, emit:
RESULT_JSON: {"diagnosis": "Could not retrieve logs", "recommendation": "HUMAN_REVIEW"}
and exit.

Store: `logs_text`.

## Phase 3 — Hub Fast-Path

If `hub_mcp=true`:

Call `mcp__nexus__hub__diagnose_failure` with `job_id={job_id}` and `logs={logs_text}`.

If the response does not contain `degraded: true`:
- Map `root_cause` → `diagnosis`
- If `recoverable=true` → `RETRY`
- If `recoverable=false` and `suggestion` contains "skip", "invalid", or "not found" → `SKIP`
- Otherwise → `HUMAN_REVIEW`
- Emit result and skip to Phase 5.

If the response contains `degraded: true`: continue to Phase 4.

If `hub_mcp=false`: continue to Phase 4.

## Phase 4 — Diagnose

Analyze the logs for the failed job. Consider:
- What operation was being performed (based on `task_type` hint and log content)
- The last error message or exception
- Whether it is a transient failure (network, timeout, rate limit) or a persistent one (bad code,
missing config, logic error)
- Whether retrying is likely to succeed

## Phase 5 — Emit Result

Display:
```
WORKFLOW COMPLETE
Job: {job_id}
Task type: {task_type}
Recommendation: {recommendation}
```

Then output this exact line as the final line of your response:

RESULT_JSON: {"diagnosis": "One sentence: what failed and likely cause", "recommendation": "RETRY"}

Where `recommendation` is exactly one of:
- `RETRY` — transient failure, safe to retry
- `SKIP` — unrecoverable, skip this issue/PR
- `HUMAN_REVIEW` — ambiguous or requires human judgment

No explanation after this line.

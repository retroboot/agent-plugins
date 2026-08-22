---
name: diagnose-failure
description: Diagnose a failed worker job from its logs and recommend RETRY, SKIP, or HUMAN_REVIEW
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

## Phase 3 — Diagnose

Analyze `logs_text` yourself. Produce three intermediate values, then map them to the output — the
mapping is mechanical, so a given diagnosis always yields the same recommendation.

**Step 1 — Read the logs for:**

- What operation was being performed, from the `task_type` hint and the log content
- The **last** error or exception, not the first — earlier errors are often retried successfully and
  the final one is what actually stopped the job
- Whether anything partially succeeded before the failure, which changes whether a retry is safe

**Step 2 — Produce `root_cause`, `suggestion`, and `recoverable`:**

- `root_cause` — one sentence naming what failed and why
- `suggestion` — the concrete next action
- `recoverable` — `true` when re-running the same job unchanged has a real chance of succeeding

Classify `recoverable` from the failure's nature:

| `recoverable` | Failure type | Examples |
|---|---|---|
| `true` | Transient — the input was fine, the environment was not | network error, timeout, rate limit, `502`/`503`, lock contention, a runner dying mid-job |
| `false` | Persistent — re-running changes nothing | compile or syntax error, failing assertion, missing config or credential, merge conflict, issue not found, permission denied |

An out-of-quota or expired-credential failure is **not** transient: it recurs on retry until a human
intervenes.

**Step 3 — Map to `recommendation`:**

- `recoverable == true` → `RETRY`
- `recoverable == false` **and** `suggestion` indicates the work should be abandoned — it names the
  target as invalid, not found, already done, or otherwise moot → `SKIP`
- Otherwise → `HUMAN_REVIEW`

`HUMAN_REVIEW` is the correct answer when the logs are ambiguous. Do not force a `RETRY` or `SKIP` to
avoid it — a wrong `RETRY` burns a job slot, and a wrong `SKIP` silently drops real work.

Set `diagnosis` to `root_cause`.

## Phase 4 — Emit Result

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

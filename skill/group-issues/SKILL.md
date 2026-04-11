---
name: group-issues
description: Group issues into implementation waves for efficient batched execution
license: MIT
compatibility: opencode
---

# Group Issues

You are a utility worker. Group a list of issues into waves for batched implementation and
emit a machine-readable result. No user interaction — run to completion and exit.

## Phase 1 — Parse Input

Input format: `--repo owner/name --issues 123,456,789 --max-wave-size 10 --sensitivity 2`

Extract:
- `repo` — required, from `--repo owner/name`
- `issue_numbers` — comma-separated integers from `--issues`
- `max_wave_size` — integer, default 10 if omitted
- `sensitivity` — integer 1-3, default 2 if omitted (1=conservative, 2=balanced, 3=aggressive)

If `--repo` or `--issues` is missing or the issue list is empty, emit:
RESULT_JSON: {"groups": []}
and exit.

## Phase 2 — Hub Fast-Path

If `hub_mcp=true`:

Call `mcp__nexus__hub__group_issues` with `issues=[{issue_numbers}]`.

If the response does not contain `degraded: true`: emit the result directly as `RESULT_JSON` (using the returned `groups` array) and skip to Phase 4.

If the response contains `degraded: true`: continue to Phase 3.

If `hub_mcp=false`: continue to Phase 3.

## Phase 3 — Fetch Issues

For each issue number, use the **Get issue** command from the loaded reference. Run fetches in parallel where possible.

Skip any issue that errors. Truncate each body to 500 characters.

## Phase 4 — Group

Group issues into waves. Each wave will be implemented as a single pull request in one worker
session.

**Sensitivity levels:**
- 1 (conservative): Only group when certain both issues are small and will land in one PR. Any
doubt means separate.
- 2 (balanced): Only group when issues are clearly part of the same small atomic change and both
are individually minor.
- 3 (aggressive): Default to grouping for clearly related, small issues. Separate when either is
non-trivial.

**Group together ONLY when:**
- Issues touch the same files or functions, not just the same product area
- One directly depends on or extends another as part of the same atomic change
- The combined scope is small — both issues are individually minor
- A reviewer would expect both changes in a single PR

**Separate when:**
- Either issue alone is a meaningful chunk of work
- Issues could be reviewed and merged independently
- They address distinct concerns, even within the same module
- You are uncertain

Maximum `max_wave_size` issues per group. Every issue must appear in exactly one group.

## Phase 5 — Emit Result

Display:
```
WORKFLOW COMPLETE
Issues grouped: {issue_numbers.join(', ')}
Groups: {groups.length}
```

Then output this exact line as the final line of your response:

RESULT_JSON: {"groups": [[123, 456], [789]]}

Where each inner array is a wave of issue numbers to implement together.

No explanation after this line.

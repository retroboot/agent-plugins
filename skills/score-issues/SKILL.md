---
name: score-issues
description: Score a list of issues by urgency (0-99) for work allocation prioritization
license: MIT
compatibility: opencode
---

# Score Issues

You are a utility worker. Score a list of issues by urgency and emit a machine-readable
result. No user interaction — run to completion and exit.

This skill no longer ships a command wrapper — `command/score-issues.md` has been retired now that
every target coder supports invoking a skill directly. The bootstrap chain that command used to run
lives here instead.

## Bootstrap

Run in order before Phase 1:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference

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

**Exclude issues already underway.** A raw issue list says nothing about whether someone is already
working on an issue, so scoring one that is In Progress proposes duplicate work. Board status is the
better signal.

Read `project` from `.hivrr.json`. **When `project` is absent, skip this step entirely** and score
every open issue — that is the correct behavior for a repo with no board, not a degraded one. See
**Board operations** in [`config.md`](../init/references/config.md) for the status query.

Read the board status for each candidate and drop any whose status is **In Progress** or **Done**.
An issue that is not on the board has no status; keep it — "not tracked" is not "underway".

**Exclude parent epics.** An issue with children is not workable — dispatching an agent at it
proposes implementing a container rather than a change. When `issues.hierarchy` is enabled, read
`subIssuesSummary.total` for each candidate using the **Read hierarchy** command from the loaded
reference and drop any issue whose total is greater than zero. Record it in `excluded` as `Epic`.

Skip this entirely when `issues.hierarchy` is disabled or absent. If the hierarchy query fails,
warn and score every issue — the same fallback as an unconfigured board. Losing the filter
degrades the result; aborting destroys it.

**Surface the exclusion.** A silently shorter list looks like a scoring decision. Before Phase 3,
display:

```
Excluded: #123 In Progress, #456 Done, #789 Epic
```

This skill is machine-executed, so a display line is not enough — record the excluded issues as
`excluded` and emit them in Phase 4 alongside `scores`. Store it as
`{issue_number_string: reason}`, where the reason is a board status name or `Epic`.

If the board query fails, warn and score every issue — the same fallback as an unconfigured board.
Losing the filter degrades the result; aborting destroys it.

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
Excluded: {excluded_numbers.join(', ') or 'none'}
```

Then output this exact line as the final line of your response:

RESULT_JSON: {"scores": {"123": 72, "456": 41, "789": 8}}

Where keys are issue number strings and values are integer scores 0–99.

**When Phase 2 excluded issues**, add the `excluded` key so the omission is machine-readable rather than an unexplained gap between what was requested and what came back:

RESULT_JSON: {"scores": {"123": 72, "456": 41}, "excluded": {"789": "Done"}}

`excluded` maps issue number strings to the reason that caused the exclusion — a board status
(`In Progress`, `Done`) or `Epic` for a parent with children. **Omit the key entirely
when nothing was excluded.** Its presence means something was filtered; it no longer implies that
the board filter specifically ran, because an epic is excluded whether or not a board is
configured.

Existing consumers that read only `scores` are unaffected.

No explanation after this line.

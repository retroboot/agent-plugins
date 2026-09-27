---
name: group-issues
description: Group issues into implementation waves for efficient batched execution
license: MIT
compatibility: opencode
---

# Group Issues

You are a utility worker. Group a list of issues into waves for batched implementation and
emit a machine-readable result. No user interaction — run to completion and exit.

This skill no longer ships a command wrapper — `command/group-issues.md` has been retired now that
every target coder supports invoking a skill directly. The bootstrap chain that command used to run
lives here instead.

## Bootstrap

Run in order before Phase 1:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference

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

## Phase 2 — Fetch Issues

For each issue number, use the **Get issue** command from the loaded reference. Run fetches in parallel where possible.

Skip any issue that errors. Truncate each body to 500 characters.

**Exclude issues already underway.** Grouping an In Progress issue into a new wave proposes work
someone is already doing, and worse, may pair it with an issue that then conflicts with the branch
already open against it.

Read `project` from `.hivrr.json`. **When `project` is absent, skip this step entirely** and group
every open issue — the correct behavior for a repo with no board. See **Board operations** in
[`config.md`](../init/references/config.md) for the status query.

Read the board status for each candidate and drop any whose status is **In Progress** or **Done**.
An issue that is not on the board has no status; keep it.

**Surface the exclusion** before Phase 3:

```
Excluded (board): #123 In Progress, #456 Done
```

This line covers board exclusions only, because it runs before Phase 3 has identified any epic.
Phase 3 Step 1 emits its own line for those. Do not add `Epic` entries here — nothing has been
classified as one yet.

This skill is machine-executed, so a display line is not enough — record the excluded issues as `excluded` and emit them in Phase 4 alongside `groups`. Store it as `{issue_number_string: reason}`, where the reason is a board status name or `Epic`.

If the board query fails, warn and group every issue — the same fallback as an unconfigured board.

Note that an excluded issue may be the stated dependency of one that remains. When that happens,
group the remaining issue on its own and note the dependency rather than pulling the excluded issue
back in.

## Phase 3 — Group

Group issues into waves. Each wave will be implemented as a single pull request in one worker
session.

Work the two signals in this order — dependency first, then file overlap. Stating the order matters:
two issues that depend on each other belong together even when they touch different files, while two
issues that merely share a file may be entirely unrelated.

**Step 1 — Build the dependency edges.** Use structured hierarchy first, prose second.

When `issues.hierarchy` is enabled, read each candidate's `parent`, `subIssues`, and `subIssuesSummary` using the
**Read hierarchy** command from the loaded reference. This yields edges that are *data*, not
inference:

- Two issues sharing a `parent` are **siblings** — strong candidates for one wave.
- An issue whose `parent` is also in the candidate list belongs with it.
- An issue with `subIssuesSummary.total > 0` is an **epic**. Never group an epic with its own
  children; drop it from grouping entirely and record it in `excluded` as `Epic`.

Then read each body for explicit statements: `Depends on #N`, `Blocked by #N`, `Closes #N`,
`Part of #N`, or prose naming another issue as a prerequisite. Prose edges **supplement**
structured ones — they never override them. Treat an unstated dependency as absent; do not infer
one from topic similarity.

When `issues.hierarchy` is disabled, absent, or the provider is not `github`, use prose only —
the behavior this skill had before hierarchy existed. If the hierarchy query fails, warn and fall
back to prose for that run: losing the structured edges degrades the result, aborting destroys it.

**Surface any epics dropped here**, the same way Phase 2 surfaces board exclusions — this is the
only place they can be reported, since Phase 2's line runs before they are identified:

```
Excluded (epic): #789 Epic
```

Add them to the same `excluded` map Phase 2 populates.

**Step 2 — Measure file overlap.** Collect the file paths each body mentions. Two issues overlap
when they name the same file, not merely the same directory or product area. Overlap makes grouping
*safe* (it avoids conflicting PRs); it does not by itself make grouping *correct*.

**Step 3 — Apply the rules below** to each candidate pair, then apply the sensitivity level.

**Step 4 — Order within each group.** The group order is the implementation order, so sort each
group: structural and rename changes first, then type definitions, then new features, then bug
fixes, then documentation. A prerequisite always precedes the issue that depends on it. When a
dependency cycle appears, break it by splitting the pair into separate groups and note it.

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

Maximum `max_wave_size` issues per group. **Every issue that survived Phase 2's board filter must
appear in exactly one group** — no surviving issue may be dropped or duplicated, and a single-issue
group is a valid result. Issues excluded by the filter are accounted for in `excluded`, not in
`groups`; between the two, every issue the caller passed is represented exactly once.

If a group would exceed `max_wave_size`, split it at the weakest link: the pair with no dependency
edge and the least file overlap.

## Phase 4 — Emit Result

Display:
```
WORKFLOW COMPLETE
Issues grouped: {issue_numbers.join(', ')}
Groups: {groups.length}
Excluded: {excluded_numbers.join(', ') or 'none'}
```

Then output this exact line as the final line of your response:

RESULT_JSON: {"groups": [[123, 456], [789]]}

Where each inner array is a wave of issue numbers to implement together.

**When Phase 2 or Phase 3 excluded issues**, add the `excluded` key so the omission is machine-readable rather than an unexplained gap between what was requested and what came back:

RESULT_JSON: {"groups": [[123, 456]], "excluded": {"789": "In Progress"}}

`excluded` maps issue number strings to the reason that caused the exclusion — a board status
(`In Progress`, `Done`) or `Epic` for a parent dropped by Phase 3 Step 1. **Omit the key entirely
when nothing was excluded.** Its presence means something was filtered; it no longer implies that
the board filter specifically ran, because an epic is excluded whether or not a board is
configured.

Existing consumers that read only `groups` are unaffected.

No explanation after this line.

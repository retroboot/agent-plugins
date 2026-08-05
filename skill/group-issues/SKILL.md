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

This skill is machine-executed, so a display line is not enough — record the excluded issues as `excluded` and emit them in Phase 4 alongside `groups`. Store it as `{issue_number_string: status_name}`.

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

**Step 1 — Build the dependency edges.** Read each body for explicit statements: `Depends on #N`,
`Blocked by #N`, `Closes #N`, `Part of #N`, or prose naming another issue as a prerequisite. An
issue and its stated prerequisite are candidates for the same group. Treat an unstated dependency as
absent — do not infer one from topic similarity.

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

**When Phase 2 excluded issues**, add the `excluded` key so the omission is machine-readable rather than an unexplained gap between what was requested and what came back:

RESULT_JSON: {"groups": [[123, 456]], "excluded": {"789": "In Progress"}}

`excluded` maps issue number strings to the board status that caused the exclusion. **Omit the key entirely when nothing was excluded** — including when no board is configured — so its presence always means the board filter actually ran. Existing consumers that read only `groups` are unaffected.

No explanation after this line.

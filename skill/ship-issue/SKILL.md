---
name: ship-issue
description: Drive a list of issues to merged PR(s) end-to-end — group by relatedness, implement each group, and ship every resulting PR through review and merge
license: MIT
compatibility: opencode
---

# Ship Issue Workflow

You are a workflow driver. Your job is to take a list of issues from input to merged PR(s),
composing `work-issue` and `ship-pr` rather than duplicating what they already do. Work with
momentum — keep moving through the phases, communicate progress clearly, and only stop where a
phase says to.

Before starting: read this entire skill, then create a focused todo list, then execute.

This skill ships with no command wrapper — every target coder already supports invoking a skill
directly, and a same-named `/ship-issue` command would only add a second, confusing way to start
the same thing. That means the bootstrap chain other workflows get from their command lives here
instead.

---

## Bootstrap

Run in order before Phase 1:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates, git safety, and task completion standards

---

## Phase 1 — Parse the Input

The input will be one of these forms:
- A single issue number: `123`
- Multiple numbers or a range: `123, 456` or `123-126`
- A GitHub URL
- A Linear identifier: `PROJ-123`
- Any of the above followed by `: some context` for inline hints
- An optional `--no-merge` flag

Extract:
- `issue_numbers` — the list of issue numbers/identifiers to ship
- `inline_context` — any text after `:` in the input
- `no_merge` — true if `--no-merge` is present

There is no `--auto` flag to parse. This skill always calls `work-issue` and `ship-pr` with `--auto`
set — it exists specifically so nothing waits on a checkpoint.

Display: `Input: {issue_numbers} | no-merge: {no_merge}`

---

## Phase 2 — Fetch Each Issue, Including Comments

Use the **Get issue** command from the loaded reference for every issue in `issue_numbers`. On
GitHub, request `comments` alongside the command's default fields —
`gh issue view {N} --repo {OWNER}/{REPO} --json number,title,body,labels,state,comments` — since the
reference's base form omits it; the Linear and GitLab reference commands return comments as part of
their default view.

Fold scope-changing comments into what gets implemented: a comment that narrows, extends, or
reverses part of the issue body supersedes that part of the body for every later phase. Reading only
the body is not enough here — that is the gap this phase exists to close.

Store `issue_data` — title, body, labels, and comments — for every issue in `issue_numbers`.

Display: `Fetched: {count} issue(s), {comment_count} comment(s)`

---

## Phase 3 — Group by Relatedness

Group issues using `wave`'s existing criteria: issues that share mentioned files, share labels, or
reference the same origin PR belong in one group. An issue with no relationship to any other forms
its own group of one.

Store `groups` — the unordered set of relatedness groups.

Display: `Groups: {count}`

---

## Phase 4 — Order Groups

Scan every issue's body and comments (from Phase 2) for `Depends on #N`. When `#N` belongs to a
different group in this run, that group must not start until the group containing `#N` has shipped.

Topologically sort `groups` so a dependent group is queued behind its prerequisite. A dependency on
an issue outside this run's `issue_numbers` is not this skill's concern — treat it as already
satisfied.

Store `ordered_groups`.

Display: `Order: {ordered_groups as group summaries}`

---

## Phase 5 — Per Group, In Order

For each group in `ordered_groups`:

**Implement.** Load the `work-issue` skill with this group's issue numbers, `inline_context` for any
issue it applies to, and `--auto`. `work-issue` fetches the issues itself — the data from Phase 2 is
for this skill's own grouping and ordering decisions, not a substitute for `work-issue`'s own fetch.
A group of more than one issue routes through `work-issue`'s own wave-strategy logic exactly as it
would from `/work-issue`.

`work-issue`'s last phase says to emit its completion JSON as defined in "the command's Output
section" — there is no command here, so take that to be `{pr, pr_url, branch, issues}`, the contract
in `command/work-issue.md`, and capture it directly from the skill's own completion.

**Ship.** Load the `ship-pr` skill with the PR number just captured, passing `--no-merge` through
when this skill received it. **Do not start the next group until `ship-pr` returns.** This is
deliberate, not incidental: finishing one PR fully — through merge, unless `--no-merge` was set —
before the next group's branch is cut is what prevents two in-flight branches from drifting against
the same files.

**Check the dependency gate.** If this group is a prerequisite for a later one, that later group may
only start once this call reported `state: "merged"`. `clean_unmerged` or `stuck` means the
prerequisite never actually landed — stop the run entirely rather than starting a dependent group on
top of it, and report the stall in the final output rather than guessing at a resolution.

Record `{pr, pr_url, issues, state}` for this group, using `ship-pr`'s `pr` and `state` verbatim.

Display: `Group {n}/{total}: PR #{pr} — {state}`

---

## Phase 6 — Final Output

Emit this JSON as your entire final response — no markdown, no preamble, no trailing text:

```json
{
  "status": "SHIP COMPLETE",
  "prs": [
    {
      "pr": 101,
      "pr_url": "https://github.com/owner/repo/pull/101",
      "issues": [123, 124],
      "state": "merged"
    }
  ]
}
```

`state` is one of `merged`, `clean_unmerged` (stopped by `--no-merge`), or `stuck` (loop cap hit
inside `ship-pr`, needs human review).

If any group is `stuck`, set `status` to `SHIP INCOMPLETE` instead, and list every group that had not
started yet under `"not_started": [issue_numbers]` — flattened across the remaining groups in
`ordered_groups`, in the order they would have run.

---

## Error Handling

- A group that fails inside `work-issue` or `ship-pr` stops the run — report the failure and
  everything shipped so far, plus `not_started` for what never began. Do not attempt the next group;
  a later group may depend on the one that just failed.
- Leave every branch and PR exactly where its own skill left it. This skill does not touch git
  directly and has nothing of its own to roll back.
- Don't retry a failed group automatically — `work-issue` and `ship-pr` already have their own retry
  and confirmation logic; a second attempt on top of that hides what actually went wrong.

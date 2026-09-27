---
name: ship-pr
description: Drive an existing PR/MR to clean-or-merged — loop review-pr and work-pr to zero findings, then merge
license: MIT
compatibility: opencode
---

# Ship PR Workflow

You are a workflow driver. Your job is to take an existing PR or MR from open review to merged (or
clean-and-unmerged, under `--no-merge`), composing `review-pr`, `work-pr`, and `merge-pr` rather than
duplicating what they already do. Work with momentum — keep moving through the phases, communicate
progress clearly, and only stop where a phase says to.

Before starting: read this entire skill, then create a focused todo list, then execute.

This skill ships with no command wrapper, for the same reason `ship-issue` does not — see
`skill/ship-issue/SKILL.md`. The bootstrap chain other workflows get from their command lives here
instead.

---

## Bootstrap

Run in order before Phase 1:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates and git safety

---

## Phase 1 — Parse the Input

The input will be one of these forms:
- A PR/MR number: `456`
- A GitHub PR URL: `https://github.com/owner/repo/pull/456`
- A GitLab MR URL: `https://gitlab.com/group/project/-/merge_requests/456`
- Any of the above followed by `: some context` for inline hints
- An optional `--no-merge` flag

Extract:
- `pr_number` — the PR/MR number to ship
- `inline_context` — any text after `:` in the input
- `no_merge` — true if `--no-merge` is present

There is no `--auto` flag to parse. This skill always calls `review-pr`, `work-pr`, and `merge-pr` in
auto mode — it exists specifically so nothing waits on a checkpoint.

Display: `Input: PR #{pr_number} | no-merge: {no_merge}`

---

## Phase 2 — Review/Fix Loop

Up to 3 rounds. For each round, in order:

1. Load the `review-pr` skill with `pr_number` — pass `inline_context` on round 1 only; it is a hint
   for the first look, not something to repeat verbatim on a re-review. `review-pr`'s last phase
   says to emit its completion JSON as defined in "the command's Output section" — there is no
   command here, so take that to be `{status, pr, review_type, findings: {blockers, required,
   deferred}}`, the contract in `command/review-pr.md`.
2. Record `{round, blockers, required, deferred}` in `findings_history`.
3. **All three zero** → the PR is clean. Go to Phase 3.
4. **Otherwise** → load the `work-pr` skill with `pr_number` and `--auto`; its contract is
   `{status, pr, branch, feedback_addressed}` from `command/work-pr.md`. Then start the next round.

**After 3 rounds without reaching zero:** stop. Do not load `merge-pr`. Set `state` to `stuck`, keep
all 3 rounds in `findings_history`, and go straight to Phase 4.

Display each round: `Round {n}: blockers={b} required={r} deferred={d}`

---

## Phase 3 — Merge, Unless `--no-merge`

Skip this phase — and set `state` to `clean_unmerged` — when `no_merge` is true.

Load the `merge-pr` skill with `pr_number` and `--auto`. Its contract is `{status, pr, issues_closed,
parents_closed, branch_deleted, followup_issues}` from `command/merge-pr.md`.

`merge-pr` has its own hard stops — a closed PR, or CI that is failing or still running. If it stops
rather than merging, do not report a merge that didn't happen: set `state` to `stuck` and carry
`merge-pr`'s reported reason into the final output instead of `issues_closed`/`followup_issues`.

Otherwise capture `issues_closed` and `followup_issues`, and set `state` to `merged`.

Display: `Merge: {merged | skipped (--no-merge) | stuck — {reason}}`

---

## Phase 4 — Final Output

Emit this JSON as your entire final response — no markdown, no preamble, no trailing text:

```json
{
  "status": "SHIP COMPLETE",
  "pr": 101,
  "state": "merged",
  "rounds": 1,
  "findings_history": [{ "round": 1, "blockers": 0, "required": 0, "deferred": 0 }],
  "issues_closed": [123, 124],
  "followup_issues": [130]
}
```

`state` is `merged`, `clean_unmerged` (`--no-merge` set), or `stuck` (the review/fix cap was hit, or
`merge-pr` itself stopped). When `state` is `stuck`, `status` is `SHIP INCOMPLETE`,
`findings_history` shows every round that ran, and `issues_closed`/`followup_issues` are omitted.

---

## Error Handling

- A closed-but-not-merged PR, or CI that is failing or still running, are `merge-pr`'s own hard
  stops — surface its reason and stop, do not retry.
- Don't retry a round automatically beyond the 3-round cap — that cap exists so an unresolvable PR
  surfaces for human review instead of looping forever.
- Leave every branch and PR exactly where `review-pr`/`work-pr`/`merge-pr` left it. This skill does
  not touch git directly.

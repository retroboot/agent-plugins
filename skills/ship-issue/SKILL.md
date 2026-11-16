---
name: ship-issue
description: Drive a list of issues (grouped by relatedness) or a plan pack's slices (one PR each, in plan order) to merged PR(s) end-to-end, shipping every PR through review and merge
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
- A plan pack path: `docs/plans/<slug>` (see **Pack path** below)
- Any of the above followed by `: some context` for inline hints
- An optional `--no-merge` flag

Extract:
- `issue_numbers` — the list of issue numbers/identifiers to ship
- `inline_context` — any text after `:` in the input
- `no_merge` — true if `--no-merge` is present

There is no `--auto` flag to parse. This skill always calls `work-issue` and `ship-pr` with `--auto`
set — it exists specifically so nothing waits on a checkpoint.

Display: `Input: {issue_numbers} | no-merge: {no_merge}`

**Pack path (conditional).** Skip this when the input does not start with `docs/plans/`. A path that
does names a plan pack, a committed folder `docs/plans/<slug>/` whose slices are published as
issues, one PR each. Store `pack_slug`, the folder name after `docs/plans/` with any trailing `/`
removed, and extract `inline_context` and `no_merge` as above. Display
`Input: pack docs/plans/{pack_slug} | no-merge: {no_merge}` in place of the line above, then run
**Load the pack** before Phase 2. It fills `issue_numbers`.

### Load the pack

**Skip this section when the input is not a pack path.** The pack describes itself: everything here
comes from the pack's own files on the integration branch, never from the working tree and never
from another plugin's files. This section only fetches and reads. It writes nothing, to the pack or
anywhere else.

1. Resolve `{integration}` by the rule `work-issue` Phase 5 uses: `branches.integration` from
   `.hivrr.json`, then the repository default branch
   (`gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`), then the branch
   `origin/HEAD` points at, then `main`. Run `git fetch origin {integration}`, which updates
   remote-tracking refs only.
2. Check that the pack is on the integration branch:
   `git ls-tree origin/{integration} -- docs/plans/{pack_slug}/README.md`. No output means it is not
   there. Display `pack docs/plans/{pack_slug} is not on {integration}; merge its PR first` and stop.
   No slice has started, so that line is the whole report.
3. Build the slice list. Read each file with
   `git show origin/{integration}:docs/plans/{pack_slug}/{file}`.
   - **XL parent:** when the README header table's **Size** row starts with `XL`, the pack has child packs and
     no slices of its own. Display `XL parent pack: ship each child pack` and stop before any slice
     starts.
   - **With `plan.md`:** one entry per `## Slice N — …` heading. Its issue is the `Issue:` reference
     on the first non-blank line after the heading, and its prerequisites are that line's
     `Depends on:` field (`Slice 1`, `Slices 6, 8`, or `none`).
   - **Without `plan.md` (size S):** one entry, Slice 1, with no prerequisites. Its issue is the
     README header table's **Issues** row.
   An issue reference is `#N`, or a Linear identifier (`ENG-123`, the pattern the linear reference
   gives) when the slice issues were created in Linear: `Issue: #214` or `Issue: ENG-123`. A line
   that names both, `Issue: #214 (Linear ENG-123)`, names `#214`: the repo provider holds that
   issue, and the Linear one only mirrors it. Keep each reference as written; `{issue}` below is
   that text (`#214`, `ENG-123`), and the plain number or identifier is what is passed on.
   If a slice has no issue reference to read, stop before any slice starts:
   `pack docs/plans/{pack_slug}: Slice {N} has no issue — publish the pack first`.
4. Drop every slice whose `progress/slice-NN.md` (`NN` zero-padded to two digits) on
   `origin/{integration}` has Status `done`. A missing file, `in-progress` or `blocked` keeps the
   slice, because it is unfinished. A prerequisite that was dropped counts as satisfied.
5. Look for an open PR on each remaining slice. Its `{branch}` is `issue/` followed by the number or
   identifier, the name `work-issue` Phase 5 gives it (`issue/214`, `issue/ENG-123`). Run the
   **Find open PR for a branch** command from the loaded repo provider reference with that branch.
   This is a read, like the rest of this section.
   - **No result:** the slice has no `open_pr`.
   - **One result:** store it as the slice's `open_pr`, its number and URL. An earlier run
     implemented the slice and opened this PR, but it never merged: `ship-pr` returned `stuck`, the
     run used `--no-merge`, or it was interrupted. Its `done` progress file exists only on the
     branch, which is why step 4 kept it. Phase 5 ships this PR instead of implementing the slice
     again, which would open a second one.

     A PR that was closed without merging is not open, so it is not found: the slice has no
     `open_pr` and is implemented again, as it would be with no PR at all.
   - **More than one, or the command fails:** stop before any slice starts:
     `pack docs/plans/{pack_slug}: cannot tell which PR ships Slice {N} from {branch} — {count} open PRs | {error}`.
6. Store `pack_slices`, the remaining slices with their number, issue, prerequisites and any
   `open_pr`, and set `issue_numbers` to their issues in slice-number order. If none remain, display
   `Pack: docs/plans/{pack_slug} — every slice is done` and go straight to Phase 6 with no groups.

Display: `Pack: docs/plans/{pack_slug} · {remaining}/{total} slice(s) to ship (from origin/{integration})`,
then `Open PR: Slice {N} ({issue}) — #{pr}` for each slice with an `open_pr`.

---

## Phase 2 — Fetch Each Issue, Including Comments

Use the **Get issue** command from the loaded reference for every issue in `issue_numbers`. On
GitHub, request `comments` alongside the command's default fields —
`gh issue view {N} --repo {OWNER}/{REPO} --json number,title,body,labels,state,comments` — since the
reference's base form omits it; `linear issue view` and `glab issue view` typically include comments
in their default output, but confirm against what the command actually returns rather than assuming
it.

Fold scope-changing comments into what gets implemented: a comment that narrows, extends, or
reverses part of the issue body supersedes that part of the body for every later phase. Reading only
the body is not enough here — that is the gap this phase exists to close.

Store `issue_data` — title, body, labels, and comments — for every issue in `issue_numbers`.

Display: `Fetched: {count} issue(s), {comment_count} comment(s)`

**Pack slices (conditional).** Skip this when the input is not a pack path. Check every slice's
marker against `plan.md` now, before any slice starts: a hand-edited `Issue:` line or a
mis-numbered marker would otherwise run another slice's contract. With Linear as the tracker, the
fetch above is **Get** in the linear reference, and the body is the issue's description. In each
body, the marker is the first line that starts with `Plan: docs/plans/`, read as `work-issue`
Phase 3 reads it: `Plan: docs/plans/<slug> · Slice: <M>`, separator `·` or `|`, any trailing `/`
removed from the slug. Compare it with the slice's entry in `pack_slices`:

- **Same slug and number** (`<slug>` is `pack_slug`, `<M>` is the slice's `N`): it matches.
- **Anything else** stops the run, with the first failing slice's line:
  - a different slug or number:
    `marker mismatch on {issue}: the issue says docs/plans/{slug} · Slice {M}, plan.md says docs/plans/{pack_slug} · Slice {N} — fix the Issue: line or the issue body`
  - no marker line, or one with no `Slice: <M>`:
    `marker missing on {issue}: plan.md says docs/plans/{pack_slug} · Slice {N} — fix the issue body`
  - an issue the **Get issue** command (**Get** in the linear reference) could not fetch:
    `cannot read the marker on {issue}: {error}`

No slice has started, so that line is the whole report, as in **Load the pack**.

Display: `Markers: {count}/{count} match plan.md`

---

## Phase 3 — Group by Relatedness

**Skip the grouping logic below when there is only one issue** — store `groups` as that issue's
single group of one and continue to Phase 4. This mirrors `work-issue`'s Phase 2, which skips its own
multi-issue routing the same way and for the same reason: relatedness has nothing to compare a lone
issue against.

**Pack slices (conditional).** Skip this when the input is not a pack path. Do not group by
relatedness. Each slice in `pack_slices` is its own group of one, even when slices share files or
labels, because a slice is one issue, one branch and one PR. Store `groups` that way and continue to
Phase 4.

Group issues using `wave`'s existing criteria: issues that share mentioned files, share labels, or
reference the same origin PR belong in one group. An issue with no relationship to any other forms
its own group of one.

Store `groups` — the unordered set of relatedness groups.

Display: `Groups: {count}`

---

## Phase 4 — Order Groups

**Skip the ordering logic below when there is only one issue** — store `ordered_groups` as that
single group and continue to Phase 5. A lone group has nothing to topologically sort against.

**Pack slices (conditional).** Skip this when the input is not a pack path. Order by the
prerequisites `plan.md` gives (Phase 1, **Load the pack**), not by `Depends on #N`: a slice does not
start until every remaining slice it depends on has shipped. When several slices are free to start,
take the lowest slice number first, so independent slices still run in plan order, one at a time.
The cycle rule below applies unchanged. Display `Order: Slice {N} ({issue}), …` in place of the line
below.

Scan every issue's body and comments (from Phase 2) for `Depends on #N`. When `#N` belongs to a
different group in this run, that group must not start until the group containing `#N` has shipped.

Topologically sort `groups` so a dependent group is queued behind its prerequisite. A dependency on
an issue outside this run's `issue_numbers` is not this skill's concern — treat it as already
satisfied.

If this produces a cycle — two groups depending on each other — stop before Phase 5 and report the
cycle rather than guessing at a break point; this is a data error in the source issues, not something
this skill should resolve silently.

Store `ordered_groups`.

Display: `Order: {ordered_groups as group summaries}`

---

## Phase 5 — Per Group, In Order

For each group in `ordered_groups`:

**A slice with an open PR (conditional).** Skip this unless the input is a pack path and this
group's slice has an `open_pr` (Phase 1, **Load the pack**, step 5). Skip Implement: do not load
`work-issue`, which would resume `{branch}` and open a second PR in its Phase 11. Take `pr` and
`pr_url` from `open_pr`, and `issues` from this group's slice, in place of `work-issue`'s completion
JSON. Display `Group {n}/{total}: {issue} — open PR #{pr}, shipping it` and go straight to Ship.
Everything from Ship on runs as written, the dependency gate included.

**Implement.** Load the `work-issue` skill with this group's issue numbers, `inline_context` for any
issue it applies to, and `--auto`. `work-issue` fetches the issues itself — the data from Phase 2 is
for this skill's own grouping and ordering decisions, not a substitute for `work-issue`'s own fetch.
A group of more than one issue routes through `work-issue`'s own wave-strategy logic exactly as it
would from a direct `work-issue` invocation.

`work-issue` ships with no command wrapper — its `## Phase 12 — Done` inlines the completion JSON
directly (`{pr, pr_url, branch, issues}`). Capture it directly from the skill's own completion.

**A blocked slice.** Skip this when `work-issue` returns any status other than `BLOCKED`.
`work-issue` returns `"status": "BLOCKED"` when a plan-pack slice hits one of its stop conditions,
whether this run was given a pack path or the slice's issue number. It has then pushed its branch
with a `wip:` commit and opened no PR, so `pr` and `pr_url` are null. Skip the Ship step for this
group and record it with `state: "stuck"`, `pr` and `pr_url` null. Then stop the run, as for any
`stuck` group: no later group starts, whether or not it depends on this one. Display
`Group {n}/{total}: #{issues} — BLOCKED on {branch}, stuck` in place of the line below.

**Ship.** Load the `ship-pr` skill with the PR number just captured, passing `--no-merge` through
when this skill received it. **Do not start the next group until `ship-pr` returns.** This is
deliberate, not incidental: finishing one PR fully — through merge, unless `--no-merge` was set —
before the next group's branch is cut is what prevents two in-flight branches from drifting against
the same files.

**Check the dependency gate.** If this group is a prerequisite for a later one, that later group may
only start once this call reported `state: "merged"`. `clean_unmerged` or `stuck` means the
prerequisite never actually landed — stop the run entirely rather than starting a dependent group on
top of it, and report the stall in the final output rather than guessing at a resolution.

**Pack slices (conditional).** Skip this when the input is not a pack path. The prerequisites in the
gate above are the `plan.md` ones from Phase 4. On `stuck` or any failure, stop the whole run as
Error Handling says. No later slice starts, whether or not it depends on the one that stopped. In
the **A blocked slice** display, write the slice's `{issue}` (`#214`, `ENG-123`) where it says
`#{issues}`, as the Order line does.

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

A group that `work-issue` returned as `BLOCKED` is `stuck` as well, with `pr` and `pr_url` null
(Phase 5). `state` has no other values.

**Pack path (conditional).** Skip this when the input is not a pack path. Add
`"pack": "docs/plans/{pack_slug}"` to the JSON above. Every other key is unchanged, and `issues` and
`not_started` hold the slices' issue numbers, or their Linear identifiers as strings when `plan.md`
names those: `"issues": ["ENG-123"]` in place of the integer example above. When every slice was
already done, `prs` is empty and `status` is `SHIP COMPLETE`.

---

## Error Handling

- A group that fails inside `work-issue` or `ship-pr` stops the run — report the failure and
  everything shipped so far, plus `not_started` for what never began. Do not attempt the next group;
  a later group may depend on the one that just failed.
- A `work-issue` run that ends without its final JSON is a failure of this kind. It ends that way
  when it stops before creating a branch, for example on a marked issue whose pack is not on the
  integration branch. Report the message it displayed as the failure.
- Leave every branch and PR exactly where its own skill left it. This skill changes no working tree,
  index or branch; it only fetches and reads, and has nothing of its own to roll back.
- Don't retry a failed group automatically — `work-issue` and `ship-pr` already have their own retry
  and confirmation logic; a second attempt on top of that hides what actually went wrong.

# Publish

`planning` Phase 8. It runs only at Status `approved`, on what the developer approved in Phase 7:
the issue titles, labels and, when one applies, the epic. Run the five steps in this order. Every
provider command comes from the reference `session` loaded (**Create**, **Edit**, the sub-issue
commands), and every board command from **Board operations** in
`$CLAUDE_SKILL_DIR/../init/references/config.md`.

Display each line as it happens. Keep the counts for the Phase 9 summary.

---

## Step 1 — Create one issue per slice

In slice order: each `## Slice N` of `plan.md`, or at size S the README **Slice** as Slice 1. Size S
creates one issue.

**Already created.** A slice whose header line already carries an issue number (`Issue: #N`, not
`Issue: #`) was created by an earlier, interrupted Publish. Do not create it again; use its number.

Create each with the **Create** command, the approved title and labels, and this body:

```text
Plan: docs/plans/{slug} · Slice: {N}

This issue is one slice of the plan pack at `docs/plans/{slug}/`. Read that pack's `README.md` and
follow its **How to execute this pack** rules. The slice's full contract is `## Slice {N}` in
`plan.md` (at size S, the README's **Slice** section); the pack wins over this summary.

## Outcome

{the slice's Outcome}

## Acceptance

- **{ID}** {the criterion's text, from prd.md or the slice}
```

The marker is the body's first line, exactly as shown, with no other line before it that starts
with `Plan: `. List every acceptance ID the slice names, PRD criteria and local criteria alike,
each with its text.

Display `Created: #{number} — {title}` for each.

**Then add the dependency lines.** Once every slice's issue exists, edit each body that has
dependencies with the **Edit** command, appending:

```text
## Dependencies

Depends on #{number of each slice in its Depends on line}
```

one `Depends on` line per prerequisite slice, so legacy ordering by `Depends on #N` works too. A
slice with `Depends on: none` gets no section. With Linear as the tracker, write the identifier in
place of `#{number}`.

**A create or edit fails:** stop Publish. Write the numbers created so far into the pack (step 2),
so a resume skips them, and leave Status `approved`. Say what failed and
`Resume: planning docs/plans/{slug}`. Nothing is lost: the pack is on disk and the issues that exist
are recorded in it.

---

## Step 2 — Write the issue numbers into the pack

- Each slice's header line in `plan.md`: `Issue: #` becomes `Issue: #{number}`. At size S, the
  README **Slice** line the same way.
- The README header **Issues** row: `#{first}–#{last} (Slices 1–{n})` when the numbers run
  consecutively, otherwise each `#{number} (Slice {N})`, comma-separated.

---

## Step 3 — Epic, hierarchy, board and Linear

These are the old `planning`'s tracker behaviours, unchanged in effect. **Each call warns and
continues on failure**: the issues are the deliverable and they already exist, so an outage here
must never lose a planning run's output.

### Epic

An epic applies when `issues.hierarchy` is enabled, the resolved tracker is `github`, **and**
either the pack's Size is L or the pack has at least `issues.epicThreshold` slices (default `4`).
Below that bar, the set stays flat — a parent wrapping two issues is bookkeeping with no board
benefit. Skip all of this silently when `issues.hierarchy` is disabled or absent, or the tracker is
not `github`.

The epic is an issue like any other, shown and approved in Phase 7:

- **Title:** the feature name, the pack's title, not an action.
- **Body:** the goal (the Brief's first paragraph), a link to `docs/plans/{slug}/README.md`, and the
  list of slice issues. No acceptance criteria of its own and no marker: its children carry those.
- **Labels:** the type and priority labels, **no size label**. An epic has no size.

With an approved epic:

1. Create it with the **Create** command. Display `Created: #{number} — {title} (epic)`.
2. For each slice issue, run step 1 of **Link a child to a parent** — check-then-add, not blind-add.
   A child that already reports the intended parent is skipped silently.
3. **Resolve node IDs** for the epic and every child still to link, in **one** aliased query.
4. **Link** each such child with one mutation.

Display `Hierarchy: {n}/{total} children attached to #{epic}`, or nothing when no epic applies.

### Board

Read `project` from `.hivrr.json`. **When `project` is absent, skip this silently** — most repos
have no board. For each created issue, **including the epic**, which must reach the board beside its
children or the rollup that motivates it has nothing to display:

1. Add it: `gh project item-add {project.number} --owner {project.owner} --url {issue_url}`.
2. Resolve its item ID.
3. Set Status to Todo with `project.statusFieldId` and `project.status.todo`.

Display `Board: {n}/{total} issues added as Todo` or `Board: not configured — skipped`.

### Linear

Skip when `ISSUE_TRACKER` is not `linear`. **Legacy fallback:** when `ISSUE_TRACKER` is not set but
`LINEAR_API_KEY` is in the environment or a `.linear.yaml` exists at the repository root, treat it
as `linear`.

- When Linear was the tracker step 1 created the issues in, there is nothing more to do here.
- When step 1 created them in the repo provider, also create a matching Linear issue for each with
  the **Create** command from the linear reference: the same title, the same body with the repo
  issue number linked in it, and story points from the size label: `size:xs`=1, `size:s`=2,
  `size:m`=3, `size:l`=5.

With `.linear.yaml`, read the team ID, project ID and default labels from it:

```text
teamId: ENG
projectId: proj_abc123
defaultLabels: [feature]
```

Display each: `Linear: {identifier} — {title}`.

---

## Step 4 — Commit the pack and open the pack PR

1. Set the README header **Status** to `published` (from `approved`).
2. Resolve `{integration}` (Phase 8), then:

   ```bash
   git fetch origin {integration}
   git switch -c plan/{slug} --no-track origin/{integration}
   ```

   The untracked pack folder carries across the branch switch unchanged.
3. Stage every file in the pack by name — list them with `find docs/plans/{slug} -type f` — and,
   for the first child of an XL parent, the parent's `README.md` when it is untracked or changed.
   Follow **Staging** in the `core` skill: `git status --short` must show nothing staged that this
   run did not write.
4. Commit `docs(plans): add {slug} plan pack`, with the issue numbers in the body as `Refs #{number}`
   (never `Closes`: the slice issues stay open until their own PRs merge).
5. `git push -u origin plan/{slug}`, then open the PR with the **Create PR** command, passing
   `--base {integration}` explicitly. Title `Plan: {pack title}`; body: the pack path, its Route,
   the created issues, and `Next: ship-issue docs/plans/{slug}` once this PR merges.

Display `Pack PR: {url} (base: {integration})`.

A failure here leaves the issues created and Status `published` in the working copy. Say what
failed and which of these commands are left to run by hand: the pack must reach `{integration}`
through this PR before `ship-issue` can run it.

---

## Step 5 — Hand off

If `ship-pr` appears among the session's available skills, offer to run it on the pack PR. On yes,
load the `ship-pr` skill with that PR number. Otherwise say:
`Merge {url} before executing: ship-issue reads the pack from {integration}.`

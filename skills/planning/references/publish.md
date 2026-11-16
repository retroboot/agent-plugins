# Publish

`planning` Phase 8. It runs only at Status `approved`, on what the developer approved in Phase 7:
the issue titles, labels and, when one applies, the epic. Run the five steps in this order. Every
provider command comes from the reference `session` loaded (**Create**, **Edit**, the sub-issue
commands), and every board command from **Board operations** in
`$CLAUDE_SKILL_DIR/../init/references/config.md`.

Display each line as it happens. Keep the counts for the Phase 9 summary.

**Publish is safe to resume.** Every issue's reference is written into the pack the moment it is
created, and every step skips what the pack already records, so a run interrupted anywhere and
resumed with `planning docs/plans/{slug}` never creates an issue twice.

**Bodies go through a file.** An issue or PR body holds backticked paths, which a shell would run
as command substitutions inside double quotes. Write each body to a scratch file outside the checkout
(`mktemp`, so `core` **Staging** never sees it) with a single-quoted heredoc (`cat > {file} <<'HIVRR_BODY_7f3a'`; never `EOF`, which a body quoting a heredoc would end early — if the body holds a line equal to the delimiter, choose another), and pass the file with the reference's file form,
which every body-taking command in the references uses, the PR commands included. Never put a
body's text in double quotes on the command line.

**Issue references.** On GitHub or GitLab a slice's reference is `#{number}`. With Linear as the
tracker that creates the slice issues, it is the Linear identifier (`ENG-123`), written where
`#{number}` is below; see **Linear**.

---

## Step 1 — Create one issue per slice

In slice order: each `## Slice N` of `plan.md`, or at size S the README **Slice** as Slice 1. Size S
creates one issue.

**Already created.** A slice whose header line already carries an issue reference (`Issue: #N` or
`Issue: ENG-123`, not a bare `Issue: #`) was created by an earlier, interrupted Publish. Do not
create it again; use its reference.

**Record each one at once.** As soon as an issue is created, write its reference into that slice's
header line: `Issue: #` becomes `Issue: #{number}` in `plan.md`, or at size S in the README
**Slice**. Do this before creating the next issue.

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
dependencies with the **Edit** command. The edit replaces the whole body, so build the full body
again — the body above, then this section — write it to a file, and pass that. Rebuilding gives the
same body every time, so a resumed run simply repeats the edit:

```text
## Dependencies

Depends on #{number of each slice in its Depends on line}
```

one `Depends on` line per prerequisite slice, so legacy ordering by `Depends on #N` works too. A
slice with `Depends on: none` gets no section. With Linear as the tracker, write the identifier in
place of `#{number}`.

**A create or edit fails:** stop Publish and leave Status `approved`. The issues that exist are
already recorded in the pack, so a resume skips them. Say what failed and
`Resume: planning docs/plans/{slug}`.

---

## Step 2 — Write the issue numbers into the pack

- Confirm every slice's header line carries its reference (step 1 wrote each as it was created).
- The README header **Issues** row:
  - **Size S:** `#{number}`, the slice's issue alone. This is the form `ship-issue` reads for a
    pack without `plan.md`.
  - **Size M or L:** `#{first}–#{last} (Slices 1–{n})` when the numbers run consecutively,
    otherwise each `#{number} (Slice {N})`, comma-separated. Step 3 appends ` · epic #{epic}`;
    when rewriting a row that already carries that suffix, keep it, since step 3 reads it to skip
    an epic that already exists.

---

## Step 3 — Epic, hierarchy, board and Linear

These are the old `planning`'s tracker behaviours, unchanged in effect. **Each call warns and
continues on failure**: the issues are the deliverable and they already exist, so an outage here
must never lose a planning run's output.

### Epic

An epic applies when `issues.hierarchy` is enabled, the resolved tracker is `github`, **and**
either the pack's Size is L or the pack has at least `issues.epicThreshold` slices (default `4`).
Below that bar, the set stays flat — a parent wrapping two issues is bookkeeping with no board
benefit. **Size S never gets an epic**: one parent over one issue is the same bookkeeping, and the
size-S Issues row must stay a single `#{number}`. Skip all of this silently when `issues.hierarchy` is disabled or absent, or the tracker is
not `github`.

The epic is an issue like any other, shown and approved in Phase 7:

- **Title:** the feature name, the pack's title, not an action.
- **Body:** the goal (the Brief's first paragraph), a link to `docs/plans/{slug}/README.md`, and the
  list of slice issues. No acceptance criteria of its own and no marker: its children carry those.
- **Labels:** the type and priority labels, **no size label**. An epic has no size.

With an approved epic:

1. **Already created** when the README Issues row ends ` · epic #{epic}`: use that number.
   Otherwise create it with the **Create** command, body through a file, and append
   ` · epic #{number}` to the Issues row at once. Display `Created: #{number} — {title} (epic)`.
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
  `size:m`=3, `size:l`=5. Record each at once on the slice's header line, after the repo number:
  `Issue: #{number} (Linear {identifier})`. A slice whose line already names a Linear identifier is
  skipped. The executors read only the `#{number}`.

**Linear as the slice tracker.** The header lines then hold `Issue: {identifier}`, and the issue
bodies `Depends on {identifier}`. `work-issue` still finds each marker, because it fetches the issue
through the linear reference, and `ship-issue`'s pack mode reads `Issue: {identifier}` as well as
`Issue: #{number}`. So Phase 9's Next line is `ship-issue docs/plans/{slug}` for such a pack too.

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

   The untracked pack folder carries across the branch switch unchanged. When `plan/{slug}` already
   exists (a resumed step 4), switch to it instead with `git switch plan/{slug}`.
3. Stage every file in the pack by name — list them with `find docs/plans/{slug} -type f` — and,
   for the first child of an XL parent, the parent's `README.md` when it is untracked or changed.
   Follow **Staging** in the `core` skill: `git status --short` must show nothing staged that this
   run did not write.
4. Commit `docs(plans): add {slug} plan pack` through a file, as **Commit** in the `core` skill shows,
   with the issue numbers in the body as `Refs #{number}` (never `Closes`:
   the slice issues stay open until their own PRs merge).
5. `git push -u origin plan/{slug}`, then open the PR with the **Create PR** command, passing
   `--base {integration}` explicitly. Title `Plan: {pack title}`; body: the pack path, its Route,
   the created issues, and `Next: ship-issue docs/plans/{slug}` once this PR merges.

Display `Pack PR: {url} (base: {integration})`.

A failure here leaves the issues created and Status `published` in the working copy. Say what
failed and `Resume: planning docs/plans/{slug}`: a resume at `published` whose pack is not on
`{integration}` offers this step again (`SKILL.md` Phase 1). On that rerun, skip what is already
done: a commit already on `plan/{slug}` (`git log origin/{integration}..plan/{slug} -- docs/plans/{slug}`),
a branch already pushed, and a PR already open (`gh pr list --head plan/{slug}` or the provider's
equivalent), which is shown rather than created again.

---

## Step 5 — Hand off

If `ship-pr` appears among the session's available skills, offer to run it on the pack PR. On yes,
load the `ship-pr` skill with that PR number. Otherwise say:
`Merge {url} before executing: ship-issue reads the pack from {integration}.`

# Pack mode

Read this file in full when `work-issue` Phase 2 or Phase 3 finds a line in an issue body that
starts with `Plan: `. Without such a line, nothing here applies and every phase of `SKILL.md` runs
exactly as written. Each section names the `SKILL.md` phase that sends you to it; take it at that
phase, not before.

## The contract

A marker makes the issue one slice of a plan pack, a committed folder `docs/plans/<slug>/`. The pack
is self-describing: its README's **How to execute this pack** rules are the contract for the run,
and everything this skill needs comes from the pack and the repository. Never read another plugin's
files to interpret a pack. Where the executed pack's own README rules differ from what this skill
says, follow the README: a pack is executed under the rules it was planned against.

The pack wins over the issue body, which is only a summary of the slice; issue comments still
override scope. Throughout the run, keep notes for the progress file: deviations (plan said /
reality / why / contract affected), decisions the plan left open, and discoveries for the next slice
or the retro.

## Detect a pack marker (Phase 3)

For each issue, look at the lines that start with `Plan: `. Matching is case-sensitive. A body that
mentions a plan mid-sentence, such as `Plan: TBD` inside a paragraph, has no such line.

A Linear issue, such as `ENG-123`, works the same way: its body is the description that the linear
reference's **Get** command returns, and the marker is found in it by the rules below. In the
messages of this pack-mode run, write its identifier where they say `#{number}`. Its branch is
`issue/{identifier}`, exactly (`issue/ENG-123`), wherever Phase 5 and later phases say
`issue/{number}`: `ship-issue` finds a slice's open PR by that branch name, and any other name
would let a rerun open a second PR.

- **Marker.** The first line that starts with `Plan: docs/plans/`, in the form
  `Plan: docs/plans/<slug> · Slice: <N>`. The separator may be `·` or `|`. Store `pack_slug`, with
  any trailing `/` removed, and `slice_number` for that issue. If no `Slice: <N>` can be read from
  the line, stop: `marker on #{number} names no slice — fix the issue body`.
- **Not a marker.** A `Plan: ` line that is not a `docs/plans/` path, such as `Plan: docs/plan/x`.
  When no line of the body is a marker, display `unrecognised Plan: line — legacy mode` and treat
  that issue as having no marker. When another line is a marker, ignore it silently.

## Load the pack (Phase 3)

Skip this section when no issue carries a marker. For each issue that does:

1. Resolve `{integration}` now, by the rule Phase 5 uses (`branches.integration`, then the
   repository default branch, then `origin/HEAD`, then `main`). Phase 5 reuses this value.
2. Run `git fetch origin {integration}`.
3. Read the README with `git show origin/{integration}:docs/plans/{pack_slug}/README.md`. If it is
   not there, stop: `pack docs/plans/{pack_slug} is not on {integration}; merge its PR first`.
4. Read the files in the README's **Read order** the same way. For a directory entry, such as
   `decisions/` or `progress/`, list it with
   `git ls-tree --name-only origin/{integration} docs/plans/{pack_slug}/{dir}/` and read each file.
   An entry that does not exist yet, such as `progress/` before the first slice, is skipped.
5. Find the slice: the `## Slice {slice_number}` section of `plan.md`. A pack with no `plan.md`
   (size S) has one slice, `Slice: 1`, which is the README's **Slice** section. If the slice is not
   there, stop: `pack docs/plans/{pack_slug} has no Slice {slice_number}`.

Read from `origin/{integration}`, never the working copy: that is what the branch will fork from.
These stops come before any branch exists, so there is nothing to commit; report them as Error
Handling says.

Hold `pack_context` for the issue: the README's **How to execute this pack** rules and Size, the
slice section, the text of every criterion it lists and the example rows under them, and any
Discoveries other slices' progress files address to this one.

Display: `Pack: docs/plans/{pack_slug} · Slice {slice_number} (from origin/{integration})`

## Plan the slice (Phase 6)

This runs at every complexity, `simple` included, because preflight cannot be skipped:

1. **Preflight** (README rule 2), against the branch's working tree, which now exists. Check every
   path and symbol `context.md` cites that this slice touches, plus those the slice itself cites,
   and record each as holds or differs. A difference is a deviation. A difference that touches the
   slice's **Contracts** is a stop: take the **Blocked path** below.
2. **Resumed after a block.** If the branch already holds this slice's progress file with Status
   `blocked`, read its **Blocked on** first. Unless the issue comments or the pack on
   `origin/{integration}` now answer the question, the stop still holds: take the blocked path
   again without further work. When it is answered, set the progress file's Status to
   `in-progress`, record the answer as a decision, and continue.
3. **The slice is the plan.** Its Outcome, Acceptance, Contracts, Stop conditions and Verify are
   mandatory. Pattern to follow, Suggested path and Files are guidance: you may leave them if every
   mandatory item still holds, and record why as a deviation. Write no separate plan.

Display `Plan: pack slice {slice_number}` in place of `Plan: ready`, and skip the rest of Phase 6.

## Proofs (Phase 8)

Also run every command in the slice's **Verify** and show its real output. Then collect a proof, to
be written in Phase 10, for each of these:

- every acceptance ID the slice lists, PRD criteria (`S-NN.k`) and slice-local ones (`N.k`) alike;
- every example row in `prd.md` **Rules and examples** whose ID extends one of those criteria
  (`S-NN.k.eN` under `S-NN.k`). A criterion the slice limits ("for X only") limits its rows too.

A proof is a test that names the ID or, where the repo has no test runner, a verification step at
the level the design's **Test strategy** gives the row: a structural check or grep, or a recorded
dry run that reads the changed files against the row's Given and names the phase, file and line
that produce its Then. An ID without a proof means the slice is not done: go back to Phase 7. If it
cannot hold without changing a contract, that is a stop under Phase 7's rules.

## Pack files (Phase 10)

Before staging, write the pack files below, then add each one you wrote to the list by name.

1. **The progress file,** `docs/plans/{pack_slug}/progress/slice-NN.md` (`NN` is `slice_number`
   zero-padded to two digits). Its sections and their order come from the executed pack's README
   rule 7, never from any other source. Status `done`, the issue, PR `this PR` (the PR is opened in
   Phase 11 and is found from the branch), the executor model if known, and the date. Then the
   Phase 6 preflight, the Phase 8 proofs with one row per criterion ID and example ID, and the
   deviations, decisions and discoveries noted since Phase 6. Omit **Blocked on**.
2. **README Status.** If it is `published`, set it to `executing`.
3. **Last slice.** Read `progress/slice-NN.md` with `git show origin/{integration}:…` for every
   other slice listed in `plan.md`. If all of them say `done`, this is the last slice; at size S
   there is no other slice, so the single slice is always the last. Any other slice whose file is
   missing or says `in-progress` or `blocked` means this is not the last slice, whatever its number:
   write no Retro. For the last slice, replace the README's **Retro** placeholder with a Retro that
   compares `cold-read.md` with the deviations recorded across every progress file, this one
   included: what the cold read predicted, and what really diverged. Then set README Status `done`.

## Blocked path

Take this path when a stop condition triggers in Phase 6 or Phase 7, with or without `--auto`.
Legacy blockers, on an issue with no marker, stop as Phase 7 and Error Handling describe instead.

1. Skip Phases 8, 9 and 11.
2. Write the progress file as **Pack files (Phase 10)** above describes, with Status `blocked`, PR
   `none (no PR is opened)`, everything shown so far, and what is partial. Fill in **Blocked on**:
   the question, and the stop condition that triggered (quote the slice's bullet, or name the
   README rule). Leave README Status and the Retro alone.
3. Stage the partial work and the progress file by name, following **Staging** in `core`, and make
   one commit through a file, as [**Commit**](../../core/SKILL.md#commit) in `core` shows: `wip: slice
   {slice_number} {what it does} (blocked)`, with the question and the progress file's path in the
   body, then `Refs #{number}` (`Refs ENG-123` for a Linear issue). Not `Closes`: nothing is ready.
   The state now survives a new session or machine.
4. Push the branch: `git push -u origin {branch_name}`.
5. Open no PR. Display `Blocked: slice {slice_number} — {question}`, then emit the Phase 12 JSON
   with `"status": "BLOCKED"`, `"pr": null` and `"pr_url": null`. The keys are unchanged. Under
   the sequential strategy, no later issue starts.

A rerun resumes this branch through Phase 5, and Phase 6 checks whether the question is answered.

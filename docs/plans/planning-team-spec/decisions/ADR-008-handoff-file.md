# ADR-008: Unfinished work between runs goes in `handoff.md`

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** author (cold-read); accepted by the developer in cold-read round 1

## Context

ADR-007 keeps no record of a gate: held items, trust notices and an unchecked fix live in the session
until the checkpoint. A session that ends after a stage's file is written and before its checkpoint
loses them, although every skill says files are its only state (cold-read round 1: aQ2, PT17 to
PT20). A `slice` stop on an answer that needs a spec change has the same gap: `slice` may not edit a
spec file, so the answer has nowhere to go (PT22). The developer wants these in a named file, not in
the README.

## Options

1. **README Open questions lines.** Rejected by the developer: the README fills up with transient
   entries.
2. **Keep everything in the session, and re-run the gate on resume.** Rejected: the drafting notices
   and the developer's answer to a spec-change stop are still lost.
3. **One handoff note per pack, `handoff.md`, holding only work in flight.** Chosen: what a team does
   at a shift change, one agreed place the next person reads first.

## Decision

`docs/plans/<slug>/handoff.md` exists only while an entry is pending. It holds two kinds of entry,
each a `##` section: **Gate pending: {file}**, written when a stage's file is written and holding its
drafting line, every trust notice and the gate's held items; and **Spec pending: {Id}**, written by a
`slice` spec-change stop and holding the item and the developer's answer. Each entry is removed when
its checkpoint or revision is done, and the file is deleted when its last entry goes. A run that finds
a Gate pending entry re-runs only that file's gate, on the file as it stands; `planning` resumes a
Spec pending entry at Specify. `planning` Approve and Publish refuse while the file exists. Gate Ids
continue from the highest `G…` Id in the README Deferred lines and in `handoff.md`.

## Consequences

ADR-007 holds for everything else: fixes stay in their files and deferrals are README Open questions
lines. The pack format gains one optional, transient file, and `planning` reads it on resume, a small
change to the wrapper ahead of child 4.

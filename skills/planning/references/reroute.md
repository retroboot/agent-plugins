# Rework steps: Re-route, Re-slice and Revise spec

`planning`'s three steps that send a pack back through an earlier phase. None lowers Status, except
a Spike re-route, which sets `routed` (`SKILL.md` Phase 4). Each one leaves lines in the README
**Open questions** that say what is still to run, so a session that ends partway through resumes at
the right phase (`SKILL.md` Phase 1, **Resume**).

---

## Where each is offered

| Step | Offered |
|---|---|
| Re-route | The Route checkpoint (Phase 3), Approve (Phase 7), after a `STOPPED` result that asks for one, and after a `COLD READ BLOCKED` whose Resolution names one |
| Re-slice | Approve, and after a `COLD READ BLOCKED` whose Resolution names one |
| Revise spec | Approve, after a `SLICE STOPPED` that asks for it, and after a `COLD READ BLOCKED` whose Resolution names one |

On a resume, do not offer one. The developer may still ask for one by name, as
`planning docs/plans/<slug> {re-route | re-slice | revise spec}` (Phase 1). That works at Status
`specified` to `approved`; a Spike takes only a re-route, and size S has no re-slice. Otherwise say
`{step} is not available: the pack is at Status {status}.` and resume as usual. When any pending,
`Revised by spec …` or `Revised by slice …` line below is already in **Open questions**, an earlier
rework is unfinished: say `A rework is still in progress; finishing it first. Ask for {step} again
after it.` and resume instead.

When the developer declines an offer, the result that led to it stands: after a `COLD READ BLOCKED`,
say `Answer these, then planning docs/plans/{slug} to run the cold read again.` and stop; after a
`STOPPED` result, end with `Resume: planning {path}`.

---

## Pending lines

Before loading any skill, a step writes to **Open questions**:

- For Re-route and Revise spec, at any Status: `Spec pending after re-route on {date}.`, or
  `Spec pending after spec revision: {request} on {date}.` Phase 4 removes it on `SPEC COMPLETE`;
  a resume passes the request back to `spec` as `docs/plans/{slug}: {request}`.

At Status `sliced` or later, also:

- `Cold read pending after {re-route | re-slice | spec revision} on {date}.` Phase 6 removes it on
  `COLD READ COMPLETE`, and the gate before Approve and Publish waits for that.
- For Re-route and Revise spec, unless the size is S:
  `Re-slice pending after {re-route | spec revision} on {date}.` Phase 5 removes it on
  `SLICE COMPLETE`.

Together with the `Revised by spec …` and `Revised by slice …` lines that `spec` and `slice` write
and remove at their checkpoints, these lines are what **Resume** reads, in this order: `Spec
pending`, then `Revised by spec`, then `Revised by slice` or `Re-slice pending`. The cold-read line
is read by the Phase 6 gate. A re-route to XL writes none of them: it stops at **Child packs**.

---

## Re-route

A route can grow at any checkpoint, including the wrapper's own Route checkpoint (S-03.4).

1. Run the Phase 3 checkpoint again with the new Type, Size and Modifiers, each with its reason.
   Never delete a pack file or rewrite one wholesale. Status stays where it is, except a Spike
   re-route, which sets `routed` (Phase 4).
2. Rewrite the header rows and the **Route** section as Phase 3 does. Add the sections the new
   route needs (Repro and root cause, Child packs) and keep every other section.
3. Unless the new size is XL, write the pending lines (above).
4. Then run the phases again from Specify: `spec` (its Re-route mode at `specified` or later adds
   the files the new route needs and lists every revised section in **Open questions**), `slice`
   (Re-slice, unless the size is S), and `cold-read`, then Approve. A re-route to XL instead writes
   **Child packs** (Phase 3) and stops.

---

## Re-slice

The route and the spec hold, but the plan does not.

1. Write the pending cold-read line (above).
2. Load `slice` with `docs/plans/{slug}` (its Re-slice mode), then Phase 6, then Approve.

---

## Revise spec

The route holds but the spec does not: a criterion `slice` cannot place, a Story map step no slice
touches, or a size mismatch the prd explains. The Route checkpoint does not run: Type, Size,
Modifiers, **Route** and Status stay as they are.

1. Ask what to revise, in one line. Write the pending lines (above).
2. Load `spec` with `docs/plans/{slug}: {what to revise}`. Status is `specified` or later, so it
   runs in its Re-route mode on the same route.
3. Then `slice` (Slice at `specified`, Re-slice later, skipped at size S), `cold-read`, then
   Approve, as Re-route step 4.

# Re-route and Revise spec: working against existing files

`spec`'s **Re-route** mode (`SKILL.md` Phase 1), in both of its forms, and Specify at `routed` when
spec files are already in the folder. Read it before Phase 2 of any run whose mode is Re-route, and
of a Specify run that found spec files already in the pack. The `Revised by spec …` line rules and
the Status rule stay in `SKILL.md`, because every checkpoint applies them. This file must agree
with `$CLAUDE_SKILL_DIR/../planning/references/reroute.md`, the `planning` wrapper's side of the
same steps.

---

## Re-route: the route grew

The route grew after spec files were written (for example Feature to Rewrite). Work through every
phase as in Specify, but against the files already there (`pack-format.md` §2, Re-routing):

- A required file that is missing is written new.
- A file that exists is never deleted or rewritten wholesale. Add each section the new route needs
  that it lacks. Revise an existing section only when the new route changes what that section must
  hold — for example, Feature to Refactor turns Stories into a behaviour-preservation contract;
  Feature to Rewrite adds behaviour criteria and keeps the Story map.
- For each revised section, add its `Revised by spec …` line to the README **Open questions**
  (`SKILL.md` Phase 1, Re-route).
- ADR numbers continue after the highest one in `decisions/`; none is renumbered. An accepted ADR
  is never revised: a changed decision is a new ADR that amends or supersedes it, marked on the old
  ADR only once the new one is accepted (Phase 5).
- Status is not changed by this run (Phase 9).

---

## Same route (Revise spec)

When the input names what to revise, the route has not changed: no file is missing and no section
is added for the route. Revise only the sections that answer the request — for example a criterion
`slice` could not place, moved or dropped with the developer's agreement — and list each with its
same-route `Revised by spec …` line (`SKILL.md` Phase 1, Re-route).

Everything in the Re-route section above holds; the checkpoints show only the files revised, and
Phase 9 treats the run as a Re-route. A run with no request whose **Open questions** already hold
`Revised by spec …` lines is a resumed revision: show those sections at the checkpoints for
approval.

**The wrapper's `Spec pending` line.** `planning` writes `Spec pending after re-route on {date}.` or
`Spec pending after spec revision: {request} on {date}.` to **Open questions** before it loads
`spec`, and removes it itself after `SPEC COMPLETE`. `spec` neither writes nor removes that line,
and never reads it: when `planning` resumes from a `Spec pending` line it passes any request in it
back in the input, as `docs/plans/<slug>: {request}`, and `spec` takes the mode from that input as
usual.

---

## Specify with files already there

Specify at `routed` follows the same rules for any spec file already in the folder (an earlier
stopped run, or a re-routed Spike), and still sets Status on approval.

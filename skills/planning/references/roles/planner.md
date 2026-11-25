# Role: Planner

## Letter

L

## Model

opus

## Kind

draft

## Job

Draft the pack's whole `plan.md`, its Dependency graph and Traceability table included, from the
approved prd, `context.md`, `decisions/`, `design.md` and any `inventory.md` or `ux.md`. Follow the
phases in `{skill}` and the template for every rule about how slices are cut, ordered, traced and
verified. Split the work the spec defines; do not change what the spec asks.

## Inputs

- `{tree}`: a detached tree of the integration branch with the pack copied in.
- `{path}`: the pack's path, relative to `{tree}`.
- `{file}`, `{template}`, `{skill}`, `{format}`, `{date}` and `{sha}`: as the drafting frame gives
  them. `{skill}` names `slice`'s Phases 2 to 4.
- `{current}`, in a Re-slice only: a file outside `{tree}` holding the reason on its first line,
  then the current `plan.md`. Return the whole file with only the slices the reason names revised,
  and every other slice's text exactly as it is there.

## Checklist

What `plan.md` needs beyond the phases' own rules:

- **L1** Every contract, stop condition and pattern a slice states cites its source: a `design.md`
  or `context.md` section, or a `path:line` opened in `{tree}`.
- **L2** Every slice's Verify proves its Outcome on that slice's own merge, with no step that needs
  a later slice.
- **L3** A choice the spec leaves open that changes how the work is split, such as an order or a
  boundary between two slices, which only the developer can make, is an open point.
- **L4** A criterion no slice can deliver, or a spec rule the slices cannot meet as written, is a
  blocking open point naming it; never drop it, and never contradict the spec in `plan.md`.

## Output

The two sections the drafting frame gives: **Draft**, holding the whole `plan.md` between its
marker lines, and **Open points**, with Ids `DL1`, `DL2` ….

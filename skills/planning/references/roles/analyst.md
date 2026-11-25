# Role: Analyst

## Letter

N

## Model

opus

## Kind

draft

## Job

Draft the pack's `prd.md`, or at size S the README Slice's `### Outcome` and `### Acceptance`
only, from the README and the checked `context.md`. Follow the phase in `{skill}` and the template
for every rule about which sections the route triggers and how rules and examples are written.
Say what the work must do and why; do not design how, and do not probe the assumptions you state.

## Inputs

- `{tree}`: a detached tree of the integration branch with the pack copied in.
- `{path}`: the pack's path, relative to `{tree}`.
- `{file}`, `{template}`, `{skill}`, `{format}`, `{date}` and `{sha}`: as the drafting frame gives
  them. At size S, `{file}` is `README.md`.

## Checklist

What the prd needs beyond the phase's own rules:

- **N1** Every outcome and scope item in the Brief, and every **Key insights** line, is met by a
  story or a criterion, or named in Non-goals.
- **N2** Every belief the prd rests on that the pack does not prove is an Assumptions row, with a
  check a reader could run, and its **Probe** cell reads `not probed yet`.
- **N3** A rule that rests on a value nothing in the pack fixes (a key, a clock, a limit, a
  wording), which only the developer can choose, is an open point, not a criterion.
- **N4** Cite `context.md` by section for every existing behaviour a criterion relies on; a
  criterion `context.md` contradicts is kept and raised as a blocking open point.

## Output

The two sections the drafting frame gives: **Draft**, holding the whole `prd.md` between its
marker lines (at size S, the two README headings and their text, with markers naming `README.md`),
and **Open points**, with Ids `DN1`, `DN2` ….

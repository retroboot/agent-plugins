# Handoff — work in flight

_Guidance: this file exists only while an entry below is pending. It holds work a run left between
a stage's file and its checkpoint, or between a `slice` stop and the `spec` revision it needs.
Answers, fixes and deferrals never go here; they go into their files. Remove an entry when its
checkpoint or revision is done, and delete this file when the last entry goes
(`skills/planning/references/gates.md`, **Handoff**)._

## Gate pending: <file>

_Guidance: one per stage file (`context.md`, `prd.md`, `design.md`, `plan.md`) written and not yet
shown at its checkpoint. Keep `Fix not re-checked` only while a fix waits for its re-check._

- **Drafting line:** <the drafting line>
- **Notices:** <each trust and fallback line, or "None.">
- Fix not re-checked

| Id | Question | Options | Blocking |
|---|---|---|---|
| <G… or D… Id> | <the role's wording, with file and section> | <the options the pack leaves open> | <yes \| no> |

## Spec pending: <Id>

_Guidance: written by a `slice` stop on an answer that needs a spec file changed._

- **Item:** <Id> — <file>, <section>
- **Answer (<YYYY-MM-DD>):** <the developer's answer>

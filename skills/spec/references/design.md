# Design and modifier sections: what each must hold

`spec` Phase 7. Read **design.md sections** when writing or extending `design.md`, and **Modifier
sections** when the route has any modifier. `SKILL.md` keeps when each file is required, where a
modifier section goes, the README Slice at size S, and the self-check; this file holds what goes
inside them beyond `pack-format.md` §2's triggers.

---

## design.md sections

Include each section (Domain model, State machines, Flows, Test strategy, Pre-mortem) **exactly**
when its trigger in `pack-format.md` §2, **Content sections**, applies, and delete it when it does
not. Beyond those triggers:

- **State machines:** list every illegal transition, including each move back to an earlier state
  that the lifecycle forbids.
- **Test strategy:** name the level each example row in the prd is proven at.
- **Pre-mortem:** "It is six months later and this failed. Why?" Each item maps to a mitigation, a
  risk row, or a stop condition. Slices do not exist yet, so name the slice by what it does — "stop
  condition in the slice that runs the migration" — for `slice` to carry into that slice.
- **Rewrite:** add the cutover plan as a `### Cutover` subsection under **Architecture**.
  **Migration and Rewrite:** the rollback approach each slice will apply.

---

## Modifier sections

Each `## Modifier: <name>` section states everything `pack-format.md` §2, **Modifiers**, requires
for it, and:

- **ui, size M or larger:** write `ux.md` from `templates/ux.md`, following
  `$CLAUDE_SKILL_DIR/../planning/references/ux-checklist.md`, and link it from the modifier section.
  One wireframe (`text` fence) and one state table (loading, empty, error, success, partial) per
  screen in the inventory, so 3 screens give 3 of each. A high-fidelity mockup is a link under
  **Mockups**, never embedded; delete Mockups when there are none.
- **ui, size S:** the same six parts inline in the modifier section.
- **observability:** name what must never be logged concretely (for example, log a payment
  webhook's event ID, never its card data), give every alert a numeric threshold, and tie the
  production check to the prd's success measures (at size S without a prd, to the Slice Outcome).

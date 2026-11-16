# Inventory: what each section lists

`spec` Phase 6, Migration and Rewrite only. Read it when writing `inventory.md` from
`templates/inventory.md`. `SKILL.md` keeps the trigger and the one rule a later checkpoint depends
on: a Rewrite behaviour with no prd criterion gets one added, and Phase 8 shows it.

- **Migration — Usage sites:** every place that uses what is being migrated, found by searching the
  code (cite each `path:line`), whether it breaks and how. Slices do not exist yet: write `pending`
  in the Slice column for `slice` to fill.
- **Rewrite — Behaviour inventory:** every observable behaviour of the old system, with its
  evidence (`path:line` in the old system) and the prd criterion that keeps, changes or drops it.
  A behaviour with no criterion gets one added to the prd now, at the end of its story.
- **Rewrite — Parity matrix:** one row per behaviour in the inventory, with old, new and a status
  of `kept`, `changed: <reason>` or `dropped: <reason>`.

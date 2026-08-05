# Linear Reference

Issue tracker only. For PR/MR operations, use the repo provider reference (github.md or gitlab.md).

All operations use the `linear` CLI.

Variables: `{TEAM}` = team key from `providerConfig.linearTeam` (e.g. `ENG`), `{ID}` = Linear issue identifier (e.g. `ENG-123`), `{T}` = title, `{B}` = description.

---

## Issues

**List**
```
linear issue list --team {TEAM}
```

**Get**
```
linear issue view {ID}
```

**Create**
```
linear issue create --team {TEAM} --title "{T}" --description "{B}"
```

**Label**
```
linear issue update {ID} --label "{label}"
```

**Close** (transition to Done state)
```
linear issue update {ID} --state Done
```

---

## Notes

- Linear identifiers follow the pattern `[A-Z]+-[0-9]+` (e.g. `ENG-123`). Include them in PR/MR descriptions to link issues.
- Linear does not support PR/MR operations — branch and merge via the repo provider.
- To list the workflow states for a team: `linear team states --team {TEAM}`.

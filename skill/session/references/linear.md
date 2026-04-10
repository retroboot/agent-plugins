# Linear Reference

Issue tracker only. For PR/MR operations, use the repo provider reference (github.md or gitlab.md).

Use MCP tools when `issues_mcp=true`. Fall back to `linear` CLI otherwise.

Variables: `{TEAM}` = team key from `providerConfig.linearTeam` (e.g. `ENG`), `{ID}` = Linear issue identifier (e.g. `ENG-123`), `{T}` = title, `{B}` = description.

---

## Issues

**List**
```
MCP: mcp__linear__list_issues  teamId={TEAM}
CLI: linear issue list --team {TEAM}
```

**Get**
```
MCP: mcp__linear__get_issue  issueId={ID}
CLI: linear issue view {ID}
```

**Create**
```
MCP: mcp__linear__create_issue  teamId={TEAM} title={T} description={B}
CLI: linear issue create --team {TEAM} --title "{T}" --description "{B}"
```

**Label**
```
MCP: mcp__linear__update_issue  issueId={ID} labelIds=[...]
CLI: linear issue update {ID} --label "{label}"
```

**Close** (transition to Done state)
```
MCP: mcp__linear__update_issue  issueId={ID} stateId={DONE_STATE_ID}
CLI: linear issue update {ID} --state Done
```

---

## Notes

- Linear identifiers follow the pattern `[A-Z]+-[0-9]+` (e.g. `ENG-123`). Include them in PR/MR descriptions to link issues.
- Linear does not support PR/MR operations — branch and merge via the repo provider.
- To find `DONE_STATE_ID` for close operations: `linear team states --team {TEAM}` or `mcp__linear__list_workflow_states teamId={TEAM}`.

# Linear Issue Tracker Reference

Use MCP tools when `issues_mcp=true`, CLI fallback when `issues_mcp=false`.

Linear is used as an **issue tracker only** — PR/MR operations still use the repo provider reference (github.md or gitlab.md).

---

## Get issue

**MCP:**
```
mcp__linear__get_issue(id={identifier})
# identifier format: ENG-123
```

**CLI:**
```bash
linear issue view {identifier}
# e.g.: linear issue view ENG-123
```

---

## List issues

**MCP:**
```
mcp__linear__list_issues(teamId={LINEAR_TEAM}, filter={state: {type: {in: ["started","unstarted","backlog"]}}})
```

**CLI:**
```bash
linear issue list --team {LINEAR_TEAM} --state backlog,todo,in-progress
```

---

## Create issue

**MCP:**
```
mcp__linear__create_issue(teamId={LINEAR_TEAM}, title={title}, description={body}, labelIds=[...], estimate={story_points})
```

**CLI:**
```bash
linear issue create --team {LINEAR_TEAM} --title "{title}" --description "{body}"
```

Size → story points: XS=1, S=2, M=3, L=5

---

## Close issue

**MCP:**
```
mcp__linear__update_issue(id={identifier}, stateId={done_state_id})
```

**CLI:**
```bash
linear issue update {identifier} --state done
# e.g.: linear issue update ENG-123 --state done
```

---

## Post comment

**MCP:**
```
mcp__linear__create_comment(issueId={identifier}, body={comment_body})
```

**CLI:**
```bash
linear issue comment {identifier} --body "{comment_body}"
```

---

## Label management

**MCP:**
```
mcp__linear__list_labels(teamId={LINEAR_TEAM})
mcp__linear__update_issue(id={identifier}, labelIds=[{label_id}])
```

**CLI:**
```bash
linear label list --team {LINEAR_TEAM}
linear issue update {identifier} --label "{label_name}"
```

---

## List projects

**MCP:**
```
mcp__linear__list_projects(teamId={LINEAR_TEAM})
```

**CLI:**
```bash
linear project list --team {LINEAR_TEAM}
```

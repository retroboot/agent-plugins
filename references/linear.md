# Linear Issue Tracker Reference

Use MCP tools when `issues_mcp=true`, CLI fallback when `issues_mcp=false`.

Linear is used as an **issue tracker only** — PR/MR operations still use the repo provider reference (github.md or gitlab.md).

**CLI fallback prerequisite:** Requires `LINEAR_API_KEY` in the environment and the official Linear CLI (`npm i -g @linear/cli`). The CLI command is `linear` with colon-separated subcommands (e.g. `linear issue:view`). If the CLI is unavailable, use the GraphQL API fallback shown under each command.

---

## Get issue

**MCP:**
```
mcp__linear__get_issue(id={identifier})
# identifier format: ENG-123
```

**CLI** (requires `@linear/cli`):
```bash
linear issue:view {identifier}
# e.g.: linear issue:view ENG-123
```

**API fallback** (requires `LINEAR_API_KEY`):
```bash
curl -s https://api.linear.app/graphql \
  -H "Authorization: ${LINEAR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ issue(id: \"{identifier}\") { id title description state { name } } }"}'
```

---

## List issues

**MCP:**
```
mcp__linear__list_issues(teamId={LINEAR_TEAM}, filter={state: {type: {in: ["started","unstarted","backlog"]}}})
```

**CLI** (requires `@linear/cli`):
```bash
linear issue:list --team {LINEAR_TEAM} --state backlog,todo,in-progress
```

**API fallback** (requires `LINEAR_API_KEY`):
```bash
curl -s https://api.linear.app/graphql \
  -H "Authorization: ${LINEAR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ team(id: \"{LINEAR_TEAM}\") { issues(filter: { state: { type: { in: [\"started\",\"unstarted\",\"backlog\"] } } }) { nodes { identifier title state { name } } } } }"}'
```

---

## Create issue

**MCP:**
```
mcp__linear__create_issue(teamId={LINEAR_TEAM}, title={title}, description={body}, labelIds=[...], estimate={story_points})
```

**CLI** (requires `@linear/cli`):
```bash
linear issue:create --team {LINEAR_TEAM} --title "{title}" --description "{body}"
```

**API fallback** (requires `LINEAR_API_KEY`):
```bash
curl -s https://api.linear.app/graphql \
  -H "Authorization: ${LINEAR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation { issueCreate(input: { teamId: \"{LINEAR_TEAM}\", title: \"{title}\", description: \"{body}\" }) { issue { identifier url } } }"}'
```

Size → story points: XS=1, S=2, M=3, L=5

---

## Close issue

**MCP:**
```
mcp__linear__update_issue(id={identifier}, stateId={done_state_id})
```

**CLI** (requires `@linear/cli`):
```bash
linear issue:update {identifier} --state done
# e.g.: linear issue:update ENG-123 --state done
```

**API fallback** (requires `LINEAR_API_KEY` and `LINEAR_DONE_STATE_ID`):
```bash
# First, get the "Done" state ID for the team (one-time lookup):
curl -s https://api.linear.app/graphql \
  -H "Authorization: ${LINEAR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ team(id: \"{LINEAR_TEAM}\") { states { nodes { id name type } } } }"}'

# Then close the issue:
curl -s https://api.linear.app/graphql \
  -H "Authorization: ${LINEAR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation { issueUpdate(id: \"{identifier}\", input: { stateId: \"{LINEAR_DONE_STATE_ID}\" }) { success } }"}'
```

---

## Post comment

**MCP:**
```
mcp__linear__create_comment(issueId={identifier}, body={comment_body})
```

**CLI** (requires `@linear/cli`):
```bash
linear issue:comment {identifier} --body "{comment_body}"
```

**API fallback** (requires `LINEAR_API_KEY`):
```bash
curl -s https://api.linear.app/graphql \
  -H "Authorization: ${LINEAR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation { commentCreate(input: { issueId: \"{identifier}\", body: \"{comment_body}\" }) { success } }"}'
```

---

## Label management

**MCP:**
```
mcp__linear__list_labels(teamId={LINEAR_TEAM})
mcp__linear__update_issue(id={identifier}, labelIds=[{label_id}])
```

**API fallback** (requires `LINEAR_API_KEY`):
```bash
# List labels:
curl -s https://api.linear.app/graphql \
  -H "Authorization: ${LINEAR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ team(id: \"{LINEAR_TEAM}\") { labels { nodes { id name } } } }"}'
```

---

## List projects

**MCP:**
```
mcp__linear__list_projects(teamId={LINEAR_TEAM})
```

**API fallback** (requires `LINEAR_API_KEY`):
```bash
curl -s https://api.linear.app/graphql \
  -H "Authorization: ${LINEAR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ team(id: \"{LINEAR_TEAM}\") { projects { nodes { id name } } } }"}'
```

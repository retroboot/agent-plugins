# GitLab Reference

Use MCP tools when `repo_mcp=true` / `issues_mcp=true`. Fall back to `glab` CLI otherwise.

**Terminology:** MR (Merge Request) = PR. Issues and MRs use `iid` (project-scoped internal ID), not a global number. Branch fields are `sourceBranch` / `targetBranch`.

Variables: `{PROJECT}` = `group/project` path, `{N}` = issue iid or MR iid, `{B}` = body/description, `{T}` = title.

---

## Issues

**List**
```
MCP: mcp__gitlab__list_issues  project_id={PROJECT} state=opened
CLI: glab issue list --repo {PROJECT}
```

**Get**
```
MCP: mcp__gitlab__get_issue  project_id={PROJECT} issue_iid={N}
CLI: glab issue view {N} --repo {PROJECT}
```

**Create**
```
MCP: mcp__gitlab__create_issue  project_id={PROJECT} title={T} description={B} labels=[{labels}]
CLI: glab issue create --repo {PROJECT} --title "{T}" --description "{B}" --label "{labels}"
```

Use labels from the label reference loaded by init. Pick one or more that fit the issue type and priority.

**Close**
```
MCP: mcp__gitlab__update_issue  project_id={PROJECT} issue_iid={N} state_event=close
CLI: glab issue close {N} --repo {PROJECT}
```

---

## Merge Requests

**Get diff**
```
MCP: mcp__gitlab__get_merge_request_diffs  project_id={PROJECT} merge_request_iid={N}
CLI: glab mr diff {N} --repo {PROJECT}
```

**View MR**
```
MCP: mcp__gitlab__get_merge_request  project_id={PROJECT} merge_request_iid={N}
CLI: glab mr view {N} --repo {PROJECT} --output json
```

**MR discussion notes** (conversation thread)
```
MCP: mcp__gitlab__list_merge_request_notes  project_id={PROJECT} merge_request_iid={N}
CLI: glab api projects/{PROJECT_ENCODED}/merge_requests/{N}/notes
     (PROJECT_ENCODED = group%2Fproject)
```

**Post comment**
```
MCP: mcp__gitlab__create_note  project_id={PROJECT} noteable_type=MergeRequest noteable_iid={N} body={B}
CLI: glab mr comment {N} --repo {PROJECT} --message "{B}"
```

**Create MR**
```
MCP: mcp__gitlab__create_merge_request  project_id={PROJECT} title={T} description={B} source_branch={branch} target_branch={base}
CLI: glab mr create --repo {PROJECT} --title "{T}" --description "{B}" --target-branch {base}
```

**Merge MR** (squash)
```
MCP: mcp__gitlab__merge_merge_request  project_id={PROJECT} merge_request_iid={N}
CLI: glab mr merge {N} --repo {PROJECT} --squash --remove-source-branch
```

**Check CI**
```
MCP: not available — use CLI
CLI: glab ci status --repo {PROJECT} --branch {branch}
     or: glab mr checks {N} --repo {PROJECT}
```

**Latest pipeline status**
```
CLI: glab ci list --repo {PROJECT} --branch {branch} --output json | jq '.[0].status'
```

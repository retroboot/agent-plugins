# GitLab Provider Reference

Use MCP tools when `repo_mcp=true`, CLI fallback when `repo_mcp=false`.

---

## Get issue

**MCP:**
```
mcp__gitlab__get_issue(project_id={repo_owner}/{repo_name}, issue_iid={number})
```

**CLI:**
```bash
glab issue view {number} --repo {repo_owner}/{repo_name} --output json
```

---

## List issues

**MCP:**
```
mcp__gitlab__list_issues(project_id={repo_owner}/{repo_name}, state="opened")
```

**CLI:**
```bash
glab issue list --repo {repo_owner}/{repo_name} --state opened --output json
```

---

## Create issue

**MCP:**
```
mcp__gitlab__create_issue(project_id={repo_owner}/{repo_name}, title={title}, description={body}, labels=[...])
```

**CLI:**
```bash
glab issue create --repo {repo_owner}/{repo_name} --title "{title}" --description "{body}" --label "{label}"
```

---

## Get diff

**MCP:**
```
mcp__gitlab__get_merge_request_diff(project_id={repo_owner}/{repo_name}, mr_iid={mr_number})
```

**CLI:**
```bash
glab mr diff {mr_number} --repo {repo_owner}/{repo_name}
```

---

## View PR

**MCP:**
```
mcp__gitlab__get_merge_request(project_id={repo_owner}/{repo_name}, mr_iid={mr_number})
```

**CLI:**
```bash
glab mr view {mr_number} --repo {repo_owner}/{repo_name} --output json
```

---

## PR conversation thread

**MCP:**
```
mcp__gitlab__list_merge_request_notes(project_id={repo_owner}/{repo_name}, mr_iid={mr_number})
```

**CLI:**
```bash
glab mr note list {mr_number} --repo {repo_owner}/{repo_name} --output json
```

---

## Post comment

**MCP:**
```
mcp__gitlab__create_merge_request_note(project_id={repo_owner}/{repo_name}, mr_iid={mr_number}, body={comment_body})
```

**CLI:**
```bash
glab mr note create {mr_number} --repo {repo_owner}/{repo_name} --message "{comment_body}"
```

---

## Create PR

**MCP:**
```
mcp__gitlab__create_merge_request(project_id={repo_owner}/{repo_name}, title={title}, description={body}, source_branch={branch}, target_branch="main")
```

**CLI:**
```bash
glab mr create --repo {repo_owner}/{repo_name} --title "{title}" --description "{body}" --source-branch {branch} --target-branch main
```

---

## Latest commit timestamp

**CLI:**
```bash
git log -1 --format="%cI" {head_sha}
```

---

## Label management

**MCP:**
```
mcp__gitlab__list_project_labels(project_id={repo_owner}/{repo_name})
```

**CLI:**
```bash
glab label list --repo {repo_owner}/{repo_name}
glab issue label add {number} --repo {repo_owner}/{repo_name} {label}
```

---

## CI checks

**MCP:**
```
mcp__gitlab__list_pipelines(project_id={repo_owner}/{repo_name}, ref={head_sha})
```

**CLI:**
```bash
glab pipeline list --repo {repo_owner}/{repo_name} --ref {head_sha}
```

---

## Close issue

**CLI:**
```bash
glab issue close {number} --repo {repo_owner}/{repo_name}
```

GitLab also auto-closes issues when an MR with `Closes #{N}` in the description is merged.

---

## Merge PR

**MCP:**
```
mcp__gitlab__accept_merge_request(project_id={repo_owner}/{repo_name}, mr_iid={mr_number}, squash=true, should_remove_source_branch=true)
```

**CLI:**
```bash
glab mr merge {mr_number} --repo {repo_owner}/{repo_name} --squash --remove-source-branch
```

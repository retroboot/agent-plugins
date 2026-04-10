# GitHub Provider Reference

Use MCP tools when `repo_mcp=true`, CLI fallback when `repo_mcp=false`.

---

## Get issue

**MCP:**
```
mcp__github__issue_read(method="get", owner={repo_owner}, repo={repo_name}, issue_number={number})
```

**CLI:**
```bash
gh issue view {number} --repo {repo_owner}/{repo_name} --json number,title,body,labels,state,assignees,url
```

---

## List issues

**MCP:**
```
mcp__github__list_issues(owner={repo_owner}, repo={repo_name}, state="open")
```

**CLI:**
```bash
gh issue list --repo {repo_owner}/{repo_name} --state open --json number,title,labels,assignees,url
```

---

## Create issue

**MCP:**
```
mcp__github__issue_write(method="create", owner={repo_owner}, repo={repo_name}, title={title}, body={body}, labels=[...])
```

**CLI:**
```bash
gh issue create --repo {repo_owner}/{repo_name} --title "{title}" --body "{body}" --label "{label}"
```

---

## Get diff

**MCP:**
```
mcp__github__pull_request_read(method="get_diff", owner={repo_owner}, repo={repo_name}, pullNumber={pr_number})
```

**CLI:**
```bash
gh pr diff {pr_number} --repo {repo_owner}/{repo_name}
```

---

## View PR

**MCP:**
```
mcp__github__pull_request_read(method="get", owner={repo_owner}, repo={repo_name}, pullNumber={pr_number})
```

**CLI:**
```bash
gh pr view {pr_number} --repo {repo_owner}/{repo_name} --json number,title,body,author,additions,deletions,state,headRefName,baseRefName,url
```

---

## PR conversation thread

**MCP:**
```
mcp__github__pull_request_read(method="get_comments", owner={repo_owner}, repo={repo_name}, pullNumber={pr_number})
```

**CLI:**
```bash
gh pr view {pr_number} --repo {repo_owner}/{repo_name} --comments --json comments,reviews
```

---

## Post comment

**MCP:**
```
mcp__github__add_issue_comment(owner={repo_owner}, repo={repo_name}, issue_number={pr_number}, body={comment_body})
```

**CLI:**
```bash
gh pr comment {pr_number} --repo {repo_owner}/{repo_name} --body "{comment_body}"
```

---

## Create PR

**MCP:**
```
mcp__github__create_pull_request(owner={repo_owner}, repo={repo_name}, title={title}, body={body}, head={branch}, base="main")
```

**CLI:**
```bash
gh pr create --repo {repo_owner}/{repo_name} --title "{title}" --body "{body}" --head {branch} --base main
```

---

## Latest commit timestamp

**MCP:**
```
mcp__github__get_commit(owner={repo_owner}, repo={repo_name}, ref={head_sha})
# Returns commit.author.date — use as the cutoff timestamp
```

**CLI:**
```bash
git log -1 --format="%cI" {head_sha}
```

---

## Label management

**MCP:**
```
mcp__github__get_label(owner={repo_owner}, repo={repo_name}, name={label_name})
```

**CLI:**
```bash
gh label list --repo {repo_owner}/{repo_name}
gh issue edit {number} --repo {repo_owner}/{repo_name} --add-label "{label}"
```

---

## CI checks

**MCP:**
```
mcp__github__pull_request_read(method="get_check_runs", owner={repo_owner}, repo={repo_name}, pullNumber={pr_number})
```

**CLI:**
```bash
gh pr checks {pr_number} --repo {repo_owner}/{repo_name}
```

---

## Close issue

**CLI:**
```bash
gh issue close {number} --repo {repo_owner}/{repo_name}
```

GitHub also auto-closes issues when a PR with `Closes #N` in the body is merged.

---

## Merge PR

**MCP:**
```
mcp__github__merge_pull_request(owner={repo_owner}, repo={repo_name}, pullNumber={pr_number}, mergeMethod="squash")
```

**CLI:**
```bash
gh pr merge {pr_number} --repo {repo_owner}/{repo_name} --squash --delete-branch
```

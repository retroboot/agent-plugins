# GitHub Reference

Use MCP tools when `repo_mcp=true` / `issues_mcp=true`. Fall back to `gh` CLI otherwise.

Variables: `{OWNER}` = repo owner, `{REPO}` = repo name, `{N}` = issue or PR number, `{B}` = body text, `{T}` = title.

---

## Issues

**List**
```
MCP: mcp__github__list_issues  owner={OWNER} repo={REPO} state=open
CLI: gh issue list --repo {OWNER}/{REPO} --state open --json number,title,labels,state
```

**Get**
```
MCP: mcp__github__issue_read  owner={OWNER} repo={REPO} issue_number={N}
CLI: gh issue view {N} --repo {OWNER}/{REPO} --json number,title,body,labels,state
```

**Create**
```
MCP: mcp__github__issue_write  owner={OWNER} repo={REPO} title={T} body={B} labels=[{labels}]
CLI: gh issue create --repo {OWNER}/{REPO} --title "{T}" --body "{B}" --label "{labels}"
```

Use labels from the label reference loaded by init. Pick one or more that fit the issue type and priority.

**Close**
```
MCP: mcp__github__issue_write  owner={OWNER} repo={REPO} issue_number={N} state=closed
CLI: gh issue close {N} --repo {OWNER}/{REPO}
```

---

## Pull Requests

**Get diff**
```
MCP: mcp__github__pull_request_read  owner={OWNER} repo={REPO} pull_number={N}
CLI: gh pr diff {N} --repo {OWNER}/{REPO}
```

**View PR**
```
MCP: mcp__github__pull_request_read  owner={OWNER} repo={REPO} pull_number={N}
CLI: gh pr view {N} --repo {OWNER}/{REPO} --json title,body,headRefName,state,baseRefName,reviews
```

**PR conversation thread** (issue-style comments, not inline diff comments)
```
MCP: mcp__github__add_issue_comment  owner={OWNER} repo={REPO} issue_number={N}  [for reading: list_issues or pull_request_read]
CLI: gh api repos/{OWNER}/{REPO}/issues/{N}/comments
```

**Post comment**
```
MCP: mcp__github__add_issue_comment  owner={OWNER} repo={REPO} issue_number={N} body={B}
CLI: gh pr comment {N} --repo {OWNER}/{REPO} --body "{B}"
```

**Create PR**
```
MCP: mcp__github__create_pull_request  owner={OWNER} repo={REPO} title={T} body={B} head={branch} base={base}
CLI: gh pr create --repo {OWNER}/{REPO} --title "{T}" --body "{B}" --base {base}
```

**Merge PR** (squash)
```
MCP: mcp__github__merge_pull_request  owner={OWNER} repo={REPO} pull_number={N} merge_method=squash
CLI: gh pr merge {N} --repo {OWNER}/{REPO} --squash --delete-branch
```

**Check CI**
```
MCP: mcp__nexus__hub__get_pr_ci_status  id={OWNER}/{REPO}!{N}
CLI: gh pr checks {N} --repo {OWNER}/{REPO}
```

**Latest commit timestamp**
```
CLI: gh pr view {N} --repo {OWNER}/{REPO} --json commits --jq '.commits[-1].committedDate'
```

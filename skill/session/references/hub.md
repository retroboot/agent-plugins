# Hub Reference

Use hub MCP tools when `hub_mcp=true`. For operations hub does not cover (diff text, CI checks, comment reads), use the **provider reference** loaded alongside this file — it has the correct CLI syntax for both GitHub and GitLab.

> **Multi-provider:** Hub initializes every provider that has credentials in secrets (`GITHUB_TOKEN`, `GITLAB_TOKEN`, etc.). Pass `provider="github"` or `provider="gitlab"` to any tool to route explicitly — hub ignores `REPO_PROVIDER` when `provider` is set. Omit `provider` to use the default (`REPO_PROVIDER`).

Variables: `{OWNER}` = owner/org slug, `{REPO}` = repo name, `{N}` = issue or PR number, `{B}` = body text, `{T}` = title.

ID encoding: `{OWNER}/{REPO}#{N}` for issues · `{OWNER}/{REPO}!{N}` for PRs/MRs

---

## Issues

**List**
```
MCP: mcp__nexus__hub__list_issues  repo={OWNER}/{REPO} state=open [provider={provider}]
```

**Get**
```
MCP: mcp__nexus__hub__get_issue  id={OWNER}/{REPO}#{N} [provider={provider}]
```

**Create**
```
MCP: mcp__nexus__hub__create_issue  repo={OWNER}/{REPO} title={T} body={B} labels=[{labels}] [provider={provider}]
```

Use labels from the label reference loaded by init. Pick one or more that fit the issue type and priority.

**Close**
```
MCP: mcp__nexus__hub__update_issue  id={OWNER}/{REPO}#{N} state=closed [provider={provider}]
```

**Comment**
```
MCP: mcp__nexus__hub__comment_issue  id={OWNER}/{REPO}#{N} body={B} [provider={provider}]
```

---

## Pull / Merge Requests

**Get diff**
```
MCP: mcp__nexus__hub__get_pr_diff  id={OWNER}/{REPO}!{N} [provider={provider}]
Returns: {"diff": "<unified diff text>"}
```

**View PR**
```
MCP: mcp__nexus__hub__get_pr  id={OWNER}/{REPO}!{N} [provider={provider}]
```

**PR conversation thread**
```
MCP: mcp__nexus__hub__list_pr_comments  id={OWNER}/{REPO}!{N} [provider={provider}]
Returns: [{id, body, url, created_at}, ...]
```

**Post comment**
```
MCP: mcp__nexus__hub__comment_pr  id={OWNER}/{REPO}!{N} body={B} [provider={provider}]
```

**Create PR**
```
MCP: mcp__nexus__hub__create_pr  repo={OWNER}/{REPO} title={T} body={B} source_branch={branch} target_branch={base} [provider={provider}]
```

**Merge PR** (squash)
```
MCP: mcp__nexus__hub__merge_pr  id={OWNER}/{REPO}!{N} strategy=squash [provider={provider}]
```

**List PRs**
```
MCP: mcp__nexus__hub__list_prs  repo={OWNER}/{REPO} state=open [provider={provider}]
```

**Check CI**
```
CLI: use **Check CI** from the provider reference
```
CI status is not available via hub — use the provider reference for the correct CLI command.

**Latest commit timestamp**
```
MCP: mcp__nexus__hub__get_pr_latest_commit  id={OWNER}/{REPO}!{N} [provider={provider}]
Returns: {"sha": "abc123", "committed_at": "2026-04-11T12:00:00Z"}
```

---

## Repositories

**List repos**
```
MCP: mcp__nexus__hub__list_repos  [provider={provider}]
```

**Create branch**
```
MCP: mcp__nexus__hub__create_branch  repo={OWNER}/{REPO} branch={branch} ref={base} [provider={provider}]
```

---

## Intelligence (LLM-powered — degrade gracefully)

These tools return `degraded: true` when the LLM backend is unavailable. Always check for degradation before using the result.

**Score issues by urgency**
```
MCP: mcp__nexus__hub__score_issues  issues=[{issue_ids}]
Returns: {"scores": {"123": 72, "456": 41}}
```

**Group issues into implementation waves**
```
MCP: mcp__nexus__hub__group_issues  issues=[{issue_ids}]
Returns: {"groups": [[123, 456], [789]]}
```

**Diagnose a job failure**
```
MCP: mcp__nexus__hub__diagnose_failure  job_id={job_id} logs={logs}
Returns: {"root_cause": "...", "suggestion": "...", "recoverable": true|false}
```

**Review a PR**
```
MCP: mcp__nexus__hub__review_pr  id={OWNER}/{REPO}!{N}
Returns: {"verdict": "approve|request_changes|comment", "summary": "...", "comments": [...]}
```

**Classify a task to a workflow**
```
MCP: mcp__nexus__hub__classify_workflow  task={task_description}
Returns: {"workflow": "work-issue|review-pr|...", "confidence": 0.0-1.0}
```

# Hub Reference

Use hub MCP tools when `hub_mcp=true`. Hub routes to the configured provider internally — no provider-specific MCP tools or CLI needed for most operations.

> **Single-provider limitation:** Hub routes all calls to one pre-configured provider (`REPO_PROVIDER` env). If your session repo lives on a different provider than hub's configured one, hub MCP calls will return errors — fall back to provider-specific MCP or CLI in that case.

Variables: `{OWNER}` = owner/org slug, `{REPO}` = repo name, `{N}` = issue or PR number, `{B}` = body text, `{T}` = title.

ID encoding: `{OWNER}/{REPO}#{N}` for issues · `{OWNER}/{REPO}!{N}` for PRs/MRs

---

## Issues

**List**
```
MCP: mcp__nexus__hub__list_issues  repo={OWNER}/{REPO} state=open
```

**Get**
```
MCP: mcp__nexus__hub__get_issue  id={OWNER}/{REPO}#{N}
```

**Create**
```
MCP: mcp__nexus__hub__create_issue  repo={OWNER}/{REPO} title={T} body={B} labels=[{labels}]
```

Use labels from the label reference loaded by init. Pick one or more that fit the issue type and priority.

**Close**
```
MCP: mcp__nexus__hub__update_issue  id={OWNER}/{REPO}#{N} state=closed
```

**Comment**
```
MCP: mcp__nexus__hub__comment_issue  id={OWNER}/{REPO}#{N} body={B}
```

---

## Pull / Merge Requests

**Get diff**
```
CLI: gh pr diff {N} --repo {OWNER}/{REPO}
```
Raw diff text is not available via hub — always use CLI for this operation.

**View PR**
```
MCP: mcp__nexus__hub__get_pr  id={OWNER}/{REPO}!{N}
```

**PR conversation thread**
```
CLI: gh api repos/{OWNER}/{REPO}/issues/{N}/comments
```
Hub does not expose a read-comments endpoint — always use CLI for this operation.

**Post comment**
```
MCP: mcp__nexus__hub__comment_pr  id={OWNER}/{REPO}!{N} body={B}
```

**Create PR**
```
MCP: mcp__nexus__hub__create_pr  repo={OWNER}/{REPO} title={T} body={B} source_branch={branch} target_branch={base}
```

**Merge PR** (squash)
```
MCP: mcp__nexus__hub__merge_pr  id={OWNER}/{REPO}!{N} strategy=squash
```

**List PRs**
```
MCP: mcp__nexus__hub__list_prs  repo={OWNER}/{REPO} state=open
```

**Check CI**
```
CLI: gh pr checks {N} --repo {OWNER}/{REPO}
```
CI status is not available via hub — always use CLI for this operation.

**Latest commit timestamp**
```
CLI: gh pr view {N} --repo {OWNER}/{REPO} --json commits --jq '.commits[-1].committedDate'
```

---

## Repositories

**List repos**
```
MCP: mcp__nexus__hub__list_repos
```

**Create branch**
```
MCP: mcp__nexus__hub__create_branch  repo={OWNER}/{REPO} branch={branch} ref={base}
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

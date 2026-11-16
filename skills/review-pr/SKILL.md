---
name: review-pr
description: Review a pull request or merge request — fetches the diff, analyzes it, and posts a structured comment
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh:*)
  - Bash(glab:*)
  - Bash(jq:*)
  - Bash(git remote:*)
  - Bash(grep:*)
  - Bash(rg:*)
  - Bash(ls:*)
  - Bash(head:*)
  - Bash(wc:*)
license: MIT
compatibility: opencode
---

# Review PR/MR Workflow

You are a code reviewer. Your job is to fetch a PR or MR's diff, analyze it thoroughly, and post a structured review comment. Work with precision — every finding must include a file:line reference and a concrete fix.

Before starting: read this entire skill, then execute.

This skill no longer ships a command wrapper — `command/review-pr.md` has been retired now that
every target coder supports invoking a skill directly. The bootstrap chain that command used to run
lives here instead.

---

## Bootstrap

Run in order before Phase 1:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates and code review standards

---

## Read-only contract

This workflow reads and reports. The only thing it changes anywhere is the one comment **Phase 6**
posts.

- **Do not modify the working tree.** No `git checkout`, no branch switch, no stash, no edit to any
  file — not even a temporary one you intend to revert. This checkout may be shared with whatever
  else the user is running, and a review that leaves it dirty costs more than any finding it
  returns.
- **Do not build, install, or run the test suite**, and do not mutate code to watch a test go red.
  CI already ran the suite against this PR in a clean environment and **Phase 2** reads its verdict.
  Proving that a test is load-bearing is a test-authoring question, not a review one.
- **Do not fetch or check out the PR branch.** The diff from **Phase 2** and the files already in
  this checkout are the input.

None of this restricts *reading*. Open whole files, read above and below a hunk, follow a call into
another file, grep for the caller — reading past the diff is the most valuable thing this workflow
does, and the one thing a hunk-scoped reviewer never does. The rule is read, do not run.

This skill's own Bootstrap loads `core`, which is written for workflows that commit: branch
discipline, staging rules, worktree adoption. Take `core`'s quality bar and leave its git procedure
— there is nothing here to commit.

---

## Phase 1 — Parse the Input

The input will be one of these forms:
- A PR/MR number: `99`
- A GitHub PR URL: `https://github.com/owner/repo/pull/99`
- A GitLab MR URL: `https://gitlab.com/group/project/-/merge_requests/99`
- Either of the above followed by `: some context` for inline hints

Extract:
- `pr_number` — the PR/MR number
- `repo_owner` / `repo_name` — from the URL if provided, otherwise from `git remote get-url origin`
- `inline_context` — any text after `:` in the input

Display: `Review: PR/MR #{pr_number} in {repo_owner}/{repo_name}`

---

## Phase 2 — Fetch PR/MR Context

Run these in parallel using commands from the loaded reference:

1. **Diff:** use **Get diff** command
2. **PR/MR metadata:** use **View PR** command (extract title, body, author, additions, deletions)
3. **Review history:** use **PR conversation thread** command
4. **CI status:** use **Check CI** command

If `additions + deletions > 3000`, emit a warning: `⚠️ Large diff ({additions + deletions} lines) — consider narrowing scope with inline context, e.g. /review-pr {pr_number} : focus on auth/`. Continue regardless.

Determine review type from the comment history:
- **First review** — no prior review comments exist, or all existing comments are from bots (login ending in `[bot]`) and none contain the markers `## Code Review`, `BLOCKER`, `REQUIRED`, or `DEFERRED`
- **Follow-up review** — at least one non-bot comment exists, or a bot comment contains one of those markers (indicating a prior structured review was posted)

Store: `diff`, `pr_meta`, `review_history`, `review_type`, `ci_status`.

**CI status is context, not a finding.** A red pipeline may be failing on something this PR never
touched. Do not open the logs, do not re-run anything locally, and do not raise a finding whose
entire evidence is "CI is red" — report it in the Summary so the author sees it, and where a failing
check names a file the diff touches, say which one. If the provider returns no pipeline, treat that
as unknown rather than as passing.

Display: `Type: {first review | follow-up} | +{additions}/-{deletions} lines | CI: {ci_status}`

---

## Phase 3 — Read Repository Conventions

If a `CLAUDE.md` exists at the repo root, read it for project conventions. These conventions take precedence over generic best practices when there is a conflict.

---

## Phase 4 — Analyze the Diff

**Skip generated files.** Lockfiles (`package-lock.json`, `yarn.lock`, `uv.lock`, `poetry.lock`,
`Cargo.lock`, `go.sum`), vendored directories, compiled assets, and generated clients or fixtures
are output, not intent — reading them line by line spends the context budget on exactly the diffs
where it is scarcest. Review the manifest that produced the change (`package.json`,
`pyproject.toml`, `go.mod`) rather than the lock it generated.

One exception, and it is worth the read: scan the **names and versions** a lockfile adds. A new
direct dependency that is unpinned, unmaintained, or carries a known advisory is a real finding,
and the manifest alone will not always show it.

If the large-diff warning fired in **Phase 2** and most of those lines are generated, say so in the
Summary. A 4,000-line PR that is 3,800 lines of lockfile is a small PR, and calling it large tells
the author nothing.

Read the diff carefully. For every finding, require:
- ≥80% confidence before including it
- A specific `file:line` reference
- A clear explanation of why it matters
- A concrete fix (not "refactor this" — actual code or steps)

If the PR introduces or modifies structured output schemas (JSON, API responses, event payloads), verify: field types are consistent across all instances of the same schema; no field carries different types in different code paths.

Classify each finding:

**🔴 BLOCKER** — must fix before merge:
- Security vulnerabilities (injection, auth bypass, secrets in code, XSS, CSRF)
- Resource leaks (unclosed connections, goroutines, file handles)
- Data loss or corruption risks
- Migrations that cannot run against real data, or that break the currently-deployed code before
  the new code ships — a non-nullable column added with no default, a column or table dropped in
  the same release that stops writing to it, a rename with no phased read path
- Broken functionality (logic errors that cause incorrect behavior)
- Failing or missing tests for critical paths

**🟡 REQUIRED** — should fix now:
- Missing error handling where failures are plausible
- Unclear or misleading logic
- Incomplete implementations that leave the feature partially working
- Code that violates stated repository conventions
- Schema or interface contract violations — type mismatches, inconsistent field naming, or missing required fields across related outputs that would silently break a consumer

**🟢 DEFERRED** — nice to have:
- Refactoring suggestions
- Additional test coverage for edge cases
- Documentation improvements
- Style preferences (only when not covered by a linter)

**For follow-up reviews**, structure findings differently:
- ✅ **Fixed:** items from the prior review that are now addressed
- ⏳ **Remaining:** items from the prior review still open
- 🆕 **New:** only BLOCKER-level new findings (do not pile on REQUIRED or DEFERRED on a follow-up)

---

## Phase 5 — Compose the Review

Build the review body using this structure:

```
## Code Review — PR #{pr_number}

**Scope:** {one-line description of what the PR does, inferred from the diff and title}

---

### 🔴 BLOCKER (must fix before merge)

{findings or "None."}

---

### 🟡 REQUIRED (should fix now)

{findings or "None."}

---

### 🟢 DEFERRED (nice to have)

{findings or "None."}

---

### Summary

{2–4 sentences: overall assessment, what's good about the PR, and the most important thing to address if anything}
```

State `ci_status` in the Summary whenever it is anything other than passing, and name the failing
check. Say plainly that the review did not investigate it — the author should not have to guess
whether a red pipeline was read and dismissed or never looked at.

For each finding, use this format:
```
**`{file}:{line}` — {finding title}**

{explanation of what's wrong and why it matters}

**Fix:** {concrete fix}
```

**When the fix is code, fence it** in the file's language, so `/work-pr` can lift it straight out of
the comment without reconstructing it from prose:

````
**`services/auth.py:42` — Missing check on the token payload**

`payload["sub"]` raises `KeyError` when the claim is absent, which a malformed token produces, so
the handler 500s where it should 401.

**Fix:**
```python
sub = payload.get("sub")
if not sub:
    raise UnauthorizedError("Missing sub claim")
```
````

When the fix is a decision, a sequence of steps, or a question for the author, prose is the right
form — do not fence prose to make it look rigorous.

If there are no findings at any level, say so explicitly in that section ("None.") — don't omit the section.

Always note at least one positive observation in the Summary.

Store: `review_body`.

---

## Phase 6 — Post the Review

Use the **Post comment** command from the loaded reference to post `review_body` as a comment on the PR/MR.
This skill may not write files, so take the reference's stdin form for callers that may not write
files: `review_body` goes in a single-quoted heredoc (`<<'EOF'`), never in double quotes on the
command line, where every backticked path in it would run as a command substitution.

Display: `Posted: review comment on PR/MR #{pr_number}`

---

## Phase 7 — Done

There is no command here to defer to — `command/review-pr.md` has been retired. Emit this JSON as
your entire final response — no markdown, no preamble, no trailing text:

```json
{
  "status": "WORKFLOW COMPLETE",
  "pr": {pr_number},
  "review_type": "<first|followup>",
  "findings": { "blockers": {n}, "required": {n}, "deferred": {n} }
}
```

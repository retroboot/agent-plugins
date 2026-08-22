---
description: Review a pull request or merge request — fetches the diff, analyzes it, and posts a structured comment
---

# /review-pr $ARGUMENTS

Bootstrap — run in order before the main skill:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates and code review standards

Then load the `review-pr` skill and run a full PR review.

**Arguments:** $ARGUMENTS

Supported formats:
- `99` — PR number (uses current repo)
- `https://github.com/owner/repo/pull/99` — full PR URL
- Either of the above followed by `: some context` for inline hints

Fetches the diff, detects whether this is a first review or follow-up, and posts a structured BLOCKER / REQUIRED / DEFERRED comment directly on the PR. Optionally append `: some context` to focus the review on a specific area.

Examples:
```
/review-pr 99
/review-pr 99 : focus on the auth changes
/review-pr https://github.com/acme/api/pull/99
```

## Output

This command is machine-executed. When the workflow completes, your **entire final response** must be ONLY this JSON — no markdown, no preamble, no trailing text:

```json
{
  "status": "WORKFLOW COMPLETE",
  "pr": {pr_number},
  "review_type": "<first|followup>",
  "findings": { "blockers": {n}, "required": {n}, "deferred": {n} }
}
```

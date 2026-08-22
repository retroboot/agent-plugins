---
description: Merge a PR or MR, close linked issues, clean up branches, capture follow-up work
---

# /merge-pr $ARGUMENTS

Bootstrap — run in order before the main skill:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates and git safety

Then load the `merge-pr` skill and drive the full merge, cleanup, and follow-up capture workflow.

**Arguments:** $ARGUMENTS

Supported formats:
- `99` — PR number
- `https://github.com/owner/repo/pull/99` — GitHub PR URL
- Append `--auto` to skip the confirmation checkpoint and auto-create follow-up issues
- Append `--strategy squash|merge|rebase` to override the strategy derived from `branches.ladder`

Examples:
```
/merge-pr 99
/merge-pr 99 --auto
/merge-pr 99 --strategy merge
/merge-pr https://github.com/owner/repo/pull/99
```

The strategy is derived automatically: a **promotion** PR — one whose head and base are both rungs in `branches.ladder` — merges with a merge commit, keeps its head branch, and closes no issues. Everything else squashes.

## Output

This command is machine-executed. When the workflow completes, your **entire final response** must be ONLY this JSON — no markdown, no preamble, no trailing text:

```json
{
  "status": "WORKFLOW COMPLETE",
  "pr": {pr_number},
  "issues_closed": [issue_numbers],
  "parents_closed": [issue_numbers],
  "branch_deleted": "{branch_name}",
  "followup_issues": [issue_numbers]
}
```

`branch_deleted` is `"none"` when a branch-deletion safety rule prevented the delete.

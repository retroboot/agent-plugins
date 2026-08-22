---
description: Address PR or MR feedback end-to-end — fetch, implement fixes, test, push
---

# /work-pr $ARGUMENTS

Bootstrap — run in order before the main skill:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates, git safety, and task completion standards

Then load the `work-pr` skill and drive the full PR feedback resolution workflow.

**Arguments:** $ARGUMENTS

Supported formats:
- `456` — PR number
- `https://github.com/owner/repo/pull/456` — GitHub PR URL
- Either of the above followed by `: some context` for inline hints
- Append `--auto` to skip the user approval checkpoint before committing

Examples:
```
/work-pr 456
/work-pr 456 --auto
/work-pr 456 : focus on the test coverage comments
/work-pr https://github.com/owner/repo/pull/456
```

## Output

This command is machine-executed. When the workflow completes, your **entire final response** must be ONLY this JSON — no markdown, no preamble, no trailing text:

```json
{
  "status": "WORKFLOW COMPLETE",
  "pr": {pr_number},
  "branch": "{branch_name}",
  "feedback_addressed": { "blocking": {n}, "recommended": {n} }
}
```

---
description: Execute multiple related issues in order on a single shared branch
---

# /wave $ARGUMENTS

Bootstrap — run in order before the main skill:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates, git safety, and task completion standards

Then load the `work-issue` skill with the unified wave strategy. `work-issue` fetches the issues, assesses complexity, and hands the ordered group to the `wave` skill, which creates the shared branch and implements each issue in sequence. `work-issue` then verifies, commits, and opens one PR for the whole group.

**Arguments:** $ARGUMENTS

Supported formats:
- `123 124 125` — space-separated issue numbers
- `123, 124, 125` — comma-separated
- `123-126` — a range
- Any of the above followed by `: some context` for inline hints
- Append `--auto` to skip the user approval checkpoint before committing

Examples:
```
/wave 123 124 125
/wave 123-126 --auto
/wave 123, 127 : keep the config changes together
```

The branch is named `wave/{min}-{max}-{count}` and is forked from `branches.integration`. Re-running the same set resumes the existing branch and skips issues whose numbers already appear in its commit log, so an interrupted wave can be continued rather than restarted.

Group issues that genuinely belong together — shared files, or one depending on another as part of the same atomic change. Unrelated issues should each get their own `/work-issue` run; a wave PR is reviewed as one unit.

## Output

This command is machine-executed. When the workflow completes, your **entire final response** must be ONLY this JSON — no markdown, no preamble, no trailing text:

```json
{
  "status": "WORKFLOW COMPLETE",
  "pr": {pr_number},
  "pr_url": "{url}",
  "branch": "{branch_name}",
  "issues": [issue_numbers]
}
```

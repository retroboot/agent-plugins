---
description: Promote one environment rung to the next — dev to staging to main
---

# /promote $ARGUMENTS

Bootstrap — run in order before the main skill:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates and git safety

Then load the `promote` skill and drive the full promotion workflow.

**Arguments:** $ARGUMENTS

Supported formats:
- `dev` — promote the named branch to the next rung in `branches.ladder`
- *(no argument)* — promote `branches.integration` to the next rung
- Append `--auto` to skip the confirmation checkpoint

Examples:
```
/promote
/promote dev
/promote staging --auto
```

The rungs come from `branches.ladder` in `.hivrr.json`. Promotion merges with a **merge commit**, never a squash, and never deletes the source branch — it is a live environment.

Promotion refuses rather than proceeding when the source is behind its upstream, or when the target has commits the source does not (an unmerged hotfix). Both are reported with the specific commits involved.

A single-rung ladder makes `/promote` a clean no-op.

## Output

This command is machine-executed. When the workflow completes, your **entire final response** must be ONLY this JSON — no markdown, no preamble, no trailing text:

```json
{
  "status": "WORKFLOW COMPLETE",
  "source": "{source_branch}",
  "target": "{target_branch}",
  "pr": {pr_number},
  "commits_promoted": {n},
  "merged": true
}
```

When promotion is a no-op or was refused, emit the same shape with `"merged": false` and a `"reason"` field naming the condition.

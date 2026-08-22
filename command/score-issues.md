---
description: Score a list of issues by urgency (0-99) for work allocation prioritization
---

# /score-issues $ARGUMENTS

Bootstrap — run in order before the main skill:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference

Then load the `score-issues` skill and score the given issues.

**Arguments:** $ARGUMENTS

Format: `--repo owner/name --issues 123,456,789`

Example:
/score-issues --repo hivrr/manager --issues 123,456,789

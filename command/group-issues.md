---
description: Group issues into implementation waves for efficient batched execution
---

# /group-issues $ARGUMENTS

Bootstrap — run in order before the main skill:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference

Then load the `group-issues` skill and group the given issues into waves.

**Arguments:** $ARGUMENTS

Format: `--repo owner/name --issues 123,456,789 --max-wave-size 10 --sensitivity 2`

Example:
/group-issues --repo hivrr/manager --issues 123,456,789 --max-wave-size 10

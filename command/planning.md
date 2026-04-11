---
description: Triage a feature or problem into sized GitHub and Linear issues
---

Bootstrap — run in order before the main skill:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — probes MCP availability and loads the active provider reference
3. Load the `core` skill — internalizes quality standards and architectural principles

Then load the `planning` skill and execute the full triage workflow for the input provided.

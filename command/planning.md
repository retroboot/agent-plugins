---
description: Triage a feature or problem into sized, actionable issues in the configured tracker — then write a comprehensive implementation plan with TDD tasks, complexity-aware blueprints, UI/UX coverage, and an automated plan review
---

Bootstrap — run in order before the main skill:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality standards and architectural principles

Then load the `planning` skill and execute the full triage workflow for the input provided.

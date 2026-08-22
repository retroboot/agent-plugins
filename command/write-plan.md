---
description: Create a detailed implementation plan document for a spec or set of existing issues — without creating new tracker issues
---

Bootstrap — run before the main skill:
1. Load the `core` skill — internalizes quality standards and architectural principles

Then load the `planning` skill and execute in plan-only mode (`--plan-only`).

Use this when issues already exist (pass their numbers as input) or when you have a spec and want the implementation plan document before triaging into issues.

The skill will research the codebase, assess complexity, write a comprehensive implementation plan with TDD tasks, run an automated plan review, and save the result to `docs/plans/`. Issue creation is skipped.

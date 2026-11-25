# ADR-003: The new names

**Status:** accepted

**Proposed by:** developer

## Context

ADR-002 removes `hivrr`, so every renamed thing needs a replacement. The developer asked for the
name `agent-plugins` and for a config filename that does not collide.

## Options

1. **`.retroboot.json` and a `RETROBOOT_` prefix.** Rejected: it ties the names to an owner again,
   the mistake being undone.
2. **`.claude/agent-plugins.json`.** Rejected: many repositories commit `.claude/`, which works
   against keeping the file out of git.
3. **Product-named:** marketplace `agent-plugins`, config `.agent-plugins.json`, markers
   `AGENT_PLUGINS_BODY_7f3a`, `AGENT_PLUGINS_COMMIT_7f3a`, `AGENT_PLUGINS_VERIFY_BLOCK`. Chosen.

## Decision

Use the product-named set in option 3. Install IDs become `{plugin}@agent-plugins`. The
marketplace `owner.name` becomes `retroboot`, and schema examples use `"owner": "your-org"`.

## Consequences

The names survive a later change of owner. Neither user has a marketplace named `agent-plugins`
today (`context.md` §1).

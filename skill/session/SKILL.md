---
name: session
description: Load provider context for the current session — reads config and loads the active provider reference. Requires init to have run first.
license: MIT
compatibility: opencode
---

# Session

Load provider context for the current workflow. Reads the validated config written by `init` and loads the active provider reference into context.

---

## Phase 1 — Read Config

Read `~/.claude/settings.json` using the Read tool. Extract `providerConfig`:

- `repoProvider` — `github` | `gitlab`
- `issueTracker` — `github` | `gitlab` | `linear`

Optional fields: `repoTarget`, `gitlabGroup`, `githubOrg`, `linearTeam`.

Store: `REPO_PROVIDER`, `ISSUE_TRACKER`, `REPO_TARGET`, provider slugs.

---

## Phase 2 — Load Reference

Read the repo provider reference:

```
Read $CLAUDE_SKILL_DIR/references/{REPO_PROVIDER}.md
```

If `ISSUE_TRACKER != REPO_PROVIDER`, also read the tracker reference:

```
Read $CLAUDE_SKILL_DIR/references/{ISSUE_TRACKER}.md
```

The loaded reference(s) are now active for this session. All provider-specific commands in subsequent phases must come from the reference.

Emit:
```
SESSION: provider={REPO_PROVIDER} tracker={ISSUE_TRACKER}
```

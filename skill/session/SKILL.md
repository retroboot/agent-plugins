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

Two sources, resolved **per key**. Read both before resolving anything.

**Repo-local:** run the **Read steps** in [`config.md`](../init/references/config.md) against
`.hivrr.json`. An absent file is normal — it means every key resolves from the fallback chain.

**Global:** read `~/.claude/settings.json` using the Read tool and extract `providerConfig`.

Then resolve each key by taking the first source that defines it:

| Variable | `.hivrr.json` | then global `providerConfig` | then |
|---|---|---|---|
| `REPO_PROVIDER` | `provider` | `repoProvider` | repo's own host |
| `ISSUE_TRACKER` | `issueTracker` | `issueTracker` | the resolved `REPO_PROVIDER` |

**Resolve the two separately.** They are independent facts, and a repo that overrides one without
the other is the case this precedence exists for: `.hivrr.json` saying `"provider": "github"`
against a global config of `{"repoProvider": "gitlab", "issueTracker": "gitlab"}` must resolve to
`provider=github tracker=gitlab` only if the repo genuinely tracks issues on GitLab. If it does
not, the repo states `"issueTracker": "github"` and this phase honors it. Taking the tracker from
global config regardless of `.hivrr.json` would load `gitlab.md` for a repo whose issues are on
GitHub — every command correct in form and aimed at the wrong host.

Global-only fields, which have no repo-local equivalent: `repoTarget`, `gitlabGroup`, `githubOrg`,
`linearTeam`.

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

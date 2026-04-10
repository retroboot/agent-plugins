---
name: session
description: Bootstrap provider config and MCP availability for the current session — loads the active cheat sheet into context
license: MIT
compatibility: opencode
---

# Session Bootstrap

Initialize provider context for the current session. Called by any skill that needs to interact with a repo host or issue tracker.

---

## Phase 1 — Read Config

Read `~/.claude/settings.json` using the Read tool. Extract `providerConfig`. Required fields:

- `repoProvider` — `github` | `gitlab`
- `issueTracker` — `github` | `gitlab` | `linear`

Optional fields: `repoTarget`, `gitlabGroup`, `githubOrg`, `linearTeam`.

**If any required field is missing:** Ask the user once for all missing values together:

```
Provider setup — answer once, saved to ~/.claude/settings.json

Which provider hosts your repos and PRs/MRs? (github | gitlab)
Which provider tracks your issues?           (github | gitlab | linear)
Org / group slug:
```

Then merge the answers into `~/.claude/settings.json`, preserving all existing keys.

Serialize the collected config as a JSON string and pass it via an environment variable to avoid shell injection:

```bash
NEW_CONFIG='{"repoProvider":"...","issueTracker":"...","repoTarget":"..."}' \
python3 -c "
import json, os
path = os.path.expanduser('~/.claude/settings.json')
s = json.loads(open(path).read()) if os.path.exists(path) else {}
s['providerConfig'] = json.loads(os.environ['NEW_CONFIG'])
open(path, 'w').write(json.dumps(s, indent=2))
"
```

Substitute the actual collected values into `NEW_CONFIG` as a valid JSON string before running this command.

Store: `REPO_PROVIDER`, `ISSUE_TRACKER`, `REPO_TARGET`, provider slugs.

---

## Phase 2 — Probe MCP

Silently attempt each relevant probe. Record `true`/`false` — do not stop on failure.

- `repo_mcp`: attempt `mcp__github__get_me` if `REPO_PROVIDER=github`; attempt `mcp__gitlab__get_me` if `REPO_PROVIDER=gitlab`
- `issues_mcp`: same as `repo_mcp` when `ISSUE_TRACKER=REPO_PROVIDER`; attempt any `mcp__linear__*` tool if `ISSUE_TRACKER=linear`

If a probe tool is not available in this session or returns an auth/capability error → flag = `false`.

---

## Phase 3 — Load Reference

**Guard:** If `$CLAUDE_SKILL_DIR` is not set in the environment, stop immediately and emit:
```
SESSION ERROR: $CLAUDE_SKILL_DIR is not set — cannot load provider reference.
Set CLAUDE_SKILL_DIR to the plugin root directory and retry.
```

```
Read $CLAUDE_SKILL_DIR/references/{REPO_PROVIDER}.md
```

If `ISSUE_TRACKER != REPO_PROVIDER`:
```
Also read $CLAUDE_SKILL_DIR/references/{ISSUE_TRACKER}.md
```

The loaded reference(s) are now active for this session. All provider-specific commands in subsequent phases must come from the reference — use MCP tools when the corresponding flag is `true`, CLI when `false`.

Emit:
```
SESSION: provider={REPO_PROVIDER} tracker={ISSUE_TRACKER} repo_mcp={true|false} issues_mcp={true|false}
```

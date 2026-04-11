---
name: init
description: One-time provider config setup — validates ~/.claude/settings.json and prompts if any required fields are missing. Idempotent: skips immediately if already configured.
license: MIT
compatibility: opencode
---

# Init

Ensure provider config exists before any workflow runs. Called once per command — skips silently if config is already present.

---

## Phase 1 — Check Config

Read `~/.claude/settings.json` using the Read tool. Check `providerConfig` for these required fields:

- `repoProvider` — `github` | `gitlab`
- `issueTracker` — `github` | `gitlab` | `linear`

**If both fields are present:**

Emit: `INIT: ok`

Stop — no further action needed.

**If either field is missing:**

Ask the user once for all missing values together:

```
Provider setup — answer once, saved to ~/.claude/settings.json

Which provider hosts your repos and PRs/MRs? (github | gitlab)
Which provider tracks your issues?           (github | gitlab | linear)
Org / group slug:
```

Serialize the answers as a JSON string and write to `~/.claude/settings.json`, preserving all existing keys:

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

Emit: `INIT: config written`

---

## Phase 2 — Bootstrap Labels

Ensure the core label set exists in the current repository. Skips if already done.

**Step 1 — Detect repo**

```bash
gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'
```

If this fails (not in a git repo, no remote, or `repoProvider` is not `github`):

Emit: `INIT: no repo detected — skipping label bootstrap`

Stop — no further action needed.

**Step 2 — Check bootstrap record**

Read `~/.claude/settings.json`. Check `providerConfig.bootstrappedRepos` (default: `[]`).

If the detected `{OWNER}/{REPO}` is already in the list:

Emit: `INIT: labels ok`

Stop — no further action needed.

**Step 3 — Load label reference**

```
Read $CLAUDE_SKILL_DIR/references/labels.md
```

**Step 4 — Create labels**

For each label in the reference, run:

```bash
gh label create "{name}" --repo {OWNER}/{REPO} --color "{color}" --description "{description}" --force
```

The `--force` flag updates any label that already exists — safe to run repeatedly.

**Step 5 — Record completion**

```bash
REPO="{OWNER}/{REPO}" python3 -c "
import json, os
path = os.path.expanduser('~/.claude/settings.json')
s = json.loads(open(path).read()) if os.path.exists(path) else {}
s.setdefault('providerConfig', {}).setdefault('bootstrappedRepos', [])
if os.environ['REPO'] not in s['providerConfig']['bootstrappedRepos']:
    s['providerConfig']['bootstrappedRepos'].append(os.environ['REPO'])
open(path, 'w').write(json.dumps(s, indent=2))
"
```

Substitute the actual `{OWNER}/{REPO}` value into `REPO` before running.

Emit: `INIT: labels bootstrapped for {OWNER}/{REPO}`

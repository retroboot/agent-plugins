---
name: init
description: One-time setup — validates ~/.claude/settings.json, bootstraps repo labels, and offers to scaffold a repo-local .hivrr.json. Idempotent.
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

---

## Phase 3 — Scaffold `.hivrr.json`

Offer the repo a committed config file so branch, board, and verify settings travel with the code instead of living in per-user global settings.

**Step 1 — Load the config reference**

```
Read $CLAUDE_SKILL_DIR/references/config.md
```

**Step 2 — Check for an existing file**

```bash
test -f .hivrr.json && echo present || echo absent
```

**If present:** validate it and stop.

```bash
jq empty .hivrr.json
```

- Parses → Emit `INIT: .hivrr.json ok` and stop. **Never overwrite an existing file** — editing it is the user's job.
- Fails to parse → Emit `INIT: .hivrr.json is malformed — {jq error}` and stop. Do not repair it silently.

**If absent:** continue to Step 3.

**Step 3 — Detect repo state**

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
git branch -r --format='%(refname:short)' | sed 's|^origin/||'
```

From the results, derive proposed values:

- `provider` — the resolved `repoProvider`
- `branches.integration` — the default branch, unless a `dev` branch exists on the remote, in which case propose `dev`
- `branches.ladder` — the subset of `["dev", "staging", "main"]` (or `master`) that actually exists on the remote, ordered lowest environment first. A single existing branch yields a single-rung ladder, which is correct.
- `branches.protected` — the ladder, plus the default branch if it is not already in it

Omit `project` and `verify` entirely. `project` requires the ID resolution flow; `verify` is filled in by Phase 4. An absent key is valid and falls through to its documented default.

**Step 4 — Confirm and write**

Show the proposed JSON and ask whether to write it. In `--auto` mode, write it without asking.

Write the file with the Write tool, then validate:

```bash
jq empty .hivrr.json
```

If validation fails, delete the file and report the error rather than leaving a malformed config behind.

Emit: `INIT: .hivrr.json scaffolded (integration: {integration}, ladder: {ladder})`

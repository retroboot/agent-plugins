---
name: init
description: One-time setup — validates ~/.claude/settings.json, bootstraps repo labels, and offers to scaffold a repo-local .hivrr.json. Idempotent.
license: MIT
compatibility: opencode
---

# Init

Ensure provider config, labels, repo config, and verify commands are in place before any workflow runs. Called once per command.

**Phase contract — read this before anything else.** The five phases run **in order, every time**. A phase that finds its work already done reports and **continues to the next phase**; it does not end the skill. Only an unrecoverable error stops `init`.

"Idempotent" here means each phase is cheap and safe to re-run, not that the skill exits early. Phase 4 in particular exists to catch repo drift and is worthless if an earlier phase short-circuits past it.

---

## Phase 1 — Check Config

Read `~/.claude/settings.json` using the Read tool. Check `providerConfig` for these required fields:

- `repoProvider` — `github` | `gitlab`
- `issueTracker` — `github` | `gitlab` | `linear`

**If both fields are present:**

Emit: `INIT: ok`

Phase 1 complete — continue to Phase 2.

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

Skip the rest of Phase 2 and continue to Phase 3.

**Step 2 — Check bootstrap record**

Read `~/.claude/settings.json`. Check `providerConfig.bootstrappedRepos` (default: `[]`).

If the detected `{OWNER}/{REPO}` is already in the list:

Emit: `INIT: labels ok`

Skip the rest of Phase 2 and continue to Phase 3.

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

**If present:** validate it, then continue to Phase 4. **Never overwrite an existing file** — editing it is the user's job.

```bash
jq empty .hivrr.json
```

- Parses → Emit `INIT: .hivrr.json ok` and continue to Phase 4.
- Fails to parse → Emit `INIT: .hivrr.json is malformed — {jq error}` and **stop the skill**. Do not repair it silently. This is the one unrecoverable error in `init`: every later phase reads and writes this file, so continuing would compound the damage.
- `jq: command not found` (exit 127) → the validator is missing, not the config. Emit `INIT: .hivrr.json present (unvalidated — jq not installed)` and continue to Phase 4.

**If absent:** continue to Step 3.

**Step 3 — Detect repo state**

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
git branch -r --format='%(refname:short)' | sed 's|^origin/||'
```

From the results, derive proposed values:

- `provider` — the resolved `repoProvider`
- `issueTracker` — the resolved `issueTracker`. Where it disagrees with the repo's own host, propose
  the **repo's host** and say so in the Step 4 confirmation. A config written *for this repo* is the
  one place that disagreement is most likely a stale global setting, and writing `provider` without
  `issueTracker` reproduces the exact defect `.hivrr.json` exists to prevent — a repo resolving to
  one provider and reading its issues from another.
- `branches.integration` — the default branch, unless a `dev` branch exists on the remote, in which case propose `dev`
- `branches.ladder` — the subset of `["dev", "staging", "main"]` (or `master`) that actually exists on the remote, ordered lowest environment first. A single existing branch yields a single-rung ladder, which is correct.
- `branches.protected` — omit this key unless the ladder or default branch adds a name the documented default does not already cover. Because precedence resolves per key, writing the key at all *replaces* the default set rather than extending it, so a scaffold that writes a narrow list leaves the repo less protected than one with no config at all. When you do write it, write the **union** of the documented default set (`main, master, dev, develop, staging, release/*`), the ladder, and the default branch — never a subset.

Omit `project` and `verify` entirely — Phase 4 fills in `verify` and Phase 5 fills in `project`, both against the file this step writes. An absent key is valid and falls through to its documented default.

**Step 4 — Confirm and write**

Show the proposed JSON and ask whether to write it. In `--auto` mode, write it without asking.

Write the file with the Write tool, then validate:

```bash
jq empty .hivrr.json
```

If `jq` reports a parse error, delete the file and report it rather than leaving a malformed config behind. If `jq` is not installed, keep the file and note that it went unvalidated.

Emit: `INIT: .hivrr.json scaffolded (integration: {integration}, ladder: {ladder})`

---

## Phase 4 — Detect Verify Commands

Record how this repo runs its tests and its linter, so `work-issue` and `work-pr` can run the right commands instead of re-guessing from heuristics on every invocation.

**This phase does not obey the "skip if already configured" rule that governs Phases 1–3.** Detection is a fact about the repo, and repo facts drift — a project migrating `.eslintrc.json → eslint.config.js` would otherwise keep running a command that no longer matches anything. Re-validate every time; that costs a few file checks and prevents a silent `lint skipped`.

**Step 1 — Read what is already recorded**

Read `verify.test`, `verify.lint`, and `verify.detectedFrom` from `.hivrr.json`. Any of them may be absent.

**Step 2 — Detect from the repo**

Look for a test command, in this order, and stop at the first match:

| Source | Command |
|---|---|
| `package.json` with a `scripts.test` entry | `npm test` |
| `Makefile` with a `test:` target | `make test` |
| `pyproject.toml` with `[tool.pytest…]`, or `pytest.ini` | `pytest` |
| `jest.config.{js,ts,mjs,cjs}` | `npx jest` |
| `go.mod` | `go test ./...` |
| `Cargo.toml` | `cargo test` |
| A CI workflow that runs a test step | the command that workflow runs |

Then a lint command, same rule:

| Source | Command |
|---|---|
| `package.json` with a `scripts.lint` entry | `npm run lint` |
| `eslint.config.{js,mjs,cjs,ts}` — **flat config** | `npx eslint .` |
| `.eslintrc`, `.eslintrc.{js,cjs,json,yaml,yml}` — legacy config | `npx eslint .` |
| `ruff.toml`, or `pyproject.toml` with `[tool.ruff]` | `ruff check .` |
| `.flake8`, or `setup.cfg` with `[flake8]` | `flake8 .` |
| `Makefile` with a `lint:` target | `make lint` |
| A CI workflow that runs a lint step | the command that workflow runs |

Check flat config **and** legacy config. Matching only `.eslintrc*` is how a repo on `eslint.config.js` silently reports `lint skipped`.

Record the file and key that justified each command in `verify.detectedFrom`, e.g. `["package.json:scripts.test", "eslint.config.js"]`. This is the fingerprint, not decoration — Step 3 depends on it.

If a repo genuinely has no test or lint setup, record the key as `null` rather than omitting it. `null` means "checked, there is nothing"; absent means "never checked".

**Step 3 — Compare against the fingerprint**

**An empty or absent `detectedFrom` is a miss, not a match.** Iterating an empty list succeeds vacuously, which would report a fingerprint as intact when nothing was ever recorded — the one case where re-detection is *most* warranted. Treat `[]` and absent identically: fall straight through to the mismatch branch and re-detect. This is cheap and silent when the repo genuinely still has nothing, because re-detection produces the same `null` values and Step 3 only reports when a command actually changes.

Otherwise, for each path in the recorded `verify.detectedFrom`, check whether it still exists and still contains the key it names.

- **Fingerprint intact and commands match** → Emit `INIT: verify ok` and continue to Phase 5.
- **Fingerprint broken, or detection produced a different command** → the repo changed. Report the change explicitly:

  ```
  INIT: verify commands updated (npx eslint . → npm run lint)
  ```

  Then confirm with the user before writing, and write the new values plus the new `detectedFrom`.

**Step 4 — Confirm and record**

Confirm with the user on first detection, and again whenever re-detection changes a command. In `--auto` mode, write without asking but still report the change.

Write `verify.test`, `verify.lint`, and `verify.detectedFrom` into `.hivrr.json`, preserving every other key. Validate with `jq empty` afterward.

If `.hivrr.json` does not exist, do not create one solely for this — report the detected commands so the user can adopt them, and let `work-issue` fall back to detection.

Emit: `INIT: verify recorded (test: {test}, lint: {lint})`

---

## Phase 5 — Resolve Project Board IDs

Resolve and cache the GitHub Projects v2 IDs that board operations need, so they are looked up once
rather than on every call.

**Skip this phase entirely** when `project` is absent from `.hivrr.json`, or when `project.owner` and
`project.number` are not both set. A repo with no board is the normal case, not an error — emit
nothing and move on.

**Skip it as well** when `project.statusFieldId` and all three `project.status.*` option IDs are
already present. Re-resolve only when an ID is missing or the user explicitly asks.

Otherwise follow **Resolving GitHub Project v2 IDs** in `references/config.md` — it has the token
scopes, the two `gh api graphql` queries, the option-name matching table, and the failure modes.

Every failure in this phase is a warning, never a stop. A board that cannot be reached must not
prevent `init` from completing.

Emit one of:
- `INIT: project IDs resolved ({project.owner}/#{project.number})`
- `INIT: project IDs already cached`
- `INIT: project resolution failed — {reason}` (warning only)

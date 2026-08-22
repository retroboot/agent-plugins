---
name: init
description: One-time setup — validates ~/.claude/settings.json, bootstraps repo labels, and offers to scaffold a repo-local .hivrr.json. Idempotent.
license: MIT
compatibility: opencode
---

# Init

Ensure provider config, labels, repo config, and verify commands are in place before any workflow runs. Called once per command.

**Phase contract — read this before anything else.** The seven phases run **in order, every time**. A phase that finds its work already done reports and **continues to the next phase**; it does not end the skill. Only an unrecoverable error stops `init`.

**The count in that sentence is load-bearing.** It is what tells you the run is not finished, so a wrong number truncates the skill silently — stopping after Phase 5 would skip Phase 6, which is what commits `.hivrr.json`. Nothing verifies it. If you add or remove a phase here, update this line, the `init` row in `README.md`, and the `init` bullet under **Shared setup skills** in `CLAUDE.md` in the same commit.

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

**If `detectedFrom` is exactly `["manual"]`, stop here.** That sentinel means a human recorded these
commands deliberately and detection must not touch them. Emit `INIT: verify manual — not re-detected`
and continue to Phase 5. Do not run Step 2, do not compare, do not offer to update.

This exists because detection can only find what its tables know about, and a repo whose
verification is real but unconventional would otherwise have it overwritten with `null` on every
run — and `null` contractually means "checked, there is nothing", which makes `work-issue` and
`work-pr` report `skipped`. The result is an unattended run skipping verification on a repo that
has it. The sentinel is the repo saying *stop looking, I already told you*.

`["manual"]` is a whole-block sentinel, not a per-key one: it governs `test` and `lint` together. A
repo that wants one key detected and the other pinned should record both by hand — mixing the two
would make the block's provenance unreadable.

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

---

## Phase 6 — Reconcile the Config

`.hivrr.json` is only useful if it travels with the code — an untracked config resolves to defaults
for every teammate, agent, and CI runner, which is the failure this file exists to prevent. Phases
3, 4, and 5 may all have written it, so reconcile once here rather than per phase.

This phase is gated on nothing but the file itself. It runs whether or not the repo has a project
board, a verify command, or a worktree.

**Skip silently** when the file is unchanged:

```bash
git status --porcelain .hivrr.json
```

Empty output means nothing to do.

Otherwise resolve the current branch and the protected set — `branches.protected` from
`.hivrr.json`, falling back to the documented default (`main`, `master`, `dev`, `develop`,
`staging`, `release/*`):

```bash
git branch --show-current
```

**On a branch that is not protected** — stage and commit it alone:

```bash
git add .hivrr.json
git commit -m "chore(config): record .hivrr.json settings" -- .hivrr.json
```

**The trailing pathspec is required, not decoration.** `git add .hivrr.json` stages one file, but a
bare `git commit` commits the **whole index** — including anything staged before `init` ran, by the
user or by an interrupted workflow. `init` runs as the first bootstrap step of every command, so it
routinely executes mid-workflow in a checkout with a populated index. Without the pathspec this
commit sweeps a feature's staged files in under a config message, which is the exact bug the commit
phases of `work-issue` and `work-pr` no longer permit.

Keep the `git add` as well: `git commit -- {path}` fails on a never-tracked file, and a freshly
scaffolded `.hivrr.json` is exactly that.

**Why this rule is restated here rather than linked.** `core` states it once, under **Staging**, and
`work-issue` and `work-pr` link to it. `init` cannot: it ships in `dev`, `planner`, **and**
`dispatcher`, and only `dev` ships `core` — a plugin install carries just the skills its
`marketplace.json` entry names, so `../core/SKILL.md` resolves to nothing in two installs out of
three. Reordering the bootstrap so `core` loads before `init` would not change that; the constraint
is packaging, not load order. Keep the copy inline, and keep it phase-agnostic — the phase numbers
in the other two skills are hand-maintained and nothing verifies a prose reference to them.

Then confirm the commit carries one path and no more:

```bash
git show --stat --oneline HEAD
```

If anything but `.hivrr.json` is listed, report it and stop. Do not report a clean config commit.

**On a protected branch** — do not commit. Stage it and report:

```bash
git add .hivrr.json
```

`core` forbids committing directly to a protected branch, so the decision is the user's: commit it
from a feature branch, or run `git commit -m "chore(config): record .hivrr.json settings" --
.hivrr.json` deliberately.

**Never push.** `init` is setup, not delivery, and a push from a setup phase is a surprise.

Emit one of:
- `INIT: .hivrr.json committed on {branch}`
- `INIT: .hivrr.json staged — {branch} is protected, commit deliberately`
- `INIT: .hivrr.json unchanged`

---

## Phase 7 — Report Orphan Worktrees

**Skip when `worktree` is absent from `.hivrr.json`.** This is the phase's only gate.

Like Phase 6, this is a **sibling of Phase 5, not a step inside it.** Phase 5 skips entirely when
`project` is absent, and a repo that configures `worktree` without a board would then never hear
about its orphans. The two keys are independent.

An abandoned or crashed session leaves a worktree that nothing else will notice, and each one holds
a branch that cannot be deleted while it exists. `init` runs on every command, which makes it the
cheapest place to surface them.

```bash
git worktree list --porcelain
```

For each worktree other than the main checkout, report those in either of two states:

**Prunable** — the directory is gone but the metadata survives. `git worktree list --porcelain`
marks these itself; no second command is needed.

**Branch gone from the remote** — the usual signature of a session whose PR merged and whose
worktree was never cleaned up:

```bash
git branch -vv | grep ': gone]'
```

**Do not use `git branch --merged` here.** Under squash merges — this plugin's default strategy, and
what `merge-pr` documents at length where it cleans up branches — a merged branch shares no commit
with the base, so `--merged` returns nothing for exactly the branches this phase most needs to find.
The failure is silent: an empty result is indistinguishable from "no merged orphans".

`: gone]` means the remote ref disappeared, **not** that the work landed — a closed-unmerged PR and a
force-pushed rename produce the same signature. `merge-pr` treats that ambiguity as a reason to
verify before deleting. Here it is not a problem: this phase only reports, and a worktree worth a
second look is worth reporting either way. Say `branch gone from remote` rather than `merged`, so
the report claims only what it checked.

```
INIT: 2 orphan worktree(s)
      .claude/worktrees/issue/41  [issue/41]  branch gone from remote
      .claude/worktrees/issue/38  [issue/38]  prunable
      Clean up: git worktree prune, or git worktree remove {path}
```

**Report only — never remove.** An orphan may hold the only copy of unfinished work, and `init` is
setup, not cleanup. Offer the commands and let the user run them.

Emit `INIT: worktrees ok` when there are none, and nothing at all when `worktree` is absent.

---
name: init
description: One-time setup — validates ~/.claude/settings.json, bootstraps repo labels, and offers to scaffold a repo-local .hivrr.json. Idempotent.
license: MIT
compatibility: opencode
---

# Init

Ensure provider config, labels, repo config, and verify commands are in place before any workflow runs. Called once per command.

**Phase contract — read this before anything else.** The seven phases run **in order, every time**. A phase that finds its work already done reports and **continues to the next phase**; it does not end the skill. Only an unrecoverable error stops `init`.

**The count in that sentence is load-bearing.** It is what tells you the run is not finished, so a wrong number truncates the skill silently — stopping after Phase 5 would skip Phase 6, which is what keeps `.hivrr.json` out of git. The seventh and tenth structural checks in `docs/verification.md` hold this count and `CLAUDE.md`'s against the `## Phase` headings; nothing checks the `README.md` row. If you add or remove a phase here, update this line, the `init` row in `README.md`, and the `init` bullet under **Shared setup skills** in `CLAUDE.md` in the same commit.

"Idempotent" here means each phase is cheap and safe to re-run, not that the skill exits early. Phase 4 in particular exists to catch repo drift and is worthless if an earlier phase short-circuits past it.

---

## Phase 1 — Check Config

Read `~/.claude/settings.json` using the Read tool. Check `providerConfig` for these required fields:

- `repoProvider` — `github` | `gitlab`
- `issueTracker` — `github` | `gitlab` | `linear`

**If both fields are present:** emit `INIT: ok`. Phase 1 complete — continue to Phase 2.

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

If this fails (not in a git repo, no remote, or `repoProvider` is not `github`): emit
`INIT: no repo detected — skipping label bootstrap`, skip the rest of Phase 2, and continue to Phase 3.

**Step 2 — Check bootstrap record**

Read `~/.claude/settings.json`. Check `providerConfig.bootstrappedRepos` (default: `[]`).

If the detected `{OWNER}/{REPO}` is already in the list: emit `INIT: labels ok`, skip the rest of
Phase 2, and continue to Phase 3.

**Step 3 — Load label reference.** Read `$CLAUDE_SKILL_DIR/references/labels.md` — it holds the
label set Step 4 creates.

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

Offer the repo a local config file so branch, board, and verify settings are derived once per
checkout instead of living in per-user global settings or being re-guessed on every command. The
file is **gitignored, never committed** — see Phase 6.

**Step 1 — Load the config reference.** Read `$CLAUDE_SKILL_DIR/references/config.md`. It is the
`config.md` the rest of this skill names: the schema, defaults and precedence every later phase reads.

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
  the **repo's host** and say so in the Step 4 confirmation: here the disagreement is most likely a
  stale global setting, and writing `provider` without `issueTracker` makes the repo read its issues
  from another host (**`provider` and `issueTracker`** in `config.md`).
- `branches.integration` — the default branch, unless a `dev` branch exists on the remote, in which case propose `dev`
- `branches.ladder` — the subset of `["dev", "staging", "main"]` (or `master`) that actually exists on the remote, ordered lowest environment first. A single existing branch yields a single-rung ladder, which is correct.
- `branches.protected` — omit this key unless the ladder or default branch adds a name the documented default does not already cover. Writing it *replaces* the default set rather than extending it (**`branches.protected`** in `config.md`), so when you do write it, write the **union** of the documented default set (`main, master, dev, develop, staging, release/*`), the ladder, and the default branch — never a subset.

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

`["manual"]` is a whole-block sentinel, not a per-key one: it governs `test` and `lint` together. A
repo that wants one key detected and the other pinned should record both by hand. Why the sentinel
exists — without it an unconventional repo's real verification is overwritten with `null` and every
run reports `skipped` — is **The `["manual"]` sentinel** in `config.md`; read it before advising a
repo to adopt or drop it.

**Step 2 — Detect from the repo**

Read **Detecting the commands** in `$CLAUDE_SKILL_DIR/references/verify.md` now and apply its
two tables: a test command first, then a lint command, each stopping at the first match. The rules
that govern this step live beside the tables and are restated here because Step 3 depends on them:

- Check ESLint flat config **and** legacy config — matching only `.eslintrc*` is how a repo on
  `eslint.config.js` silently reports `lint skipped`.
- Record the file and key that justified each command in `verify.detectedFrom`, e.g.
  `["package.json:scripts.test", "eslint.config.js"]`. This is the fingerprint Step 3 compares.
- A repo with genuinely no test or lint setup gets the key recorded as `null`, never omitted: `null`
  means "checked, there is nothing"; absent means "never checked".

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

## Phase 6 — Keep `.hivrr.json` Out of Git

`.hivrr.json` is per-checkout, not shared — each teammate, agent, and CI run derives its own copy by
running `init`. A copy that leaks into git gives every clone a stale, silently-inherited config; this
phase makes that structurally impossible. The reasoning behind each step below is in
[`references/git-hygiene.md`](references/git-hygiene.md), under the **Phase 6 — …** heading the
step names. Read that section when the step's result surprises you or before changing the step; the
steps here are complete without it.

This phase is gated on nothing but the file itself. It runs whether or not the repo has a project
board, a verify command, or a worktree.

**Step 1 — Check whether `.hivrr.json` is already ignored**

```bash
git check-ignore -q .hivrr.json && echo ignored || echo not-ignored
```

**If ignored:** continue to Step 2 anyway — an ignored file can still be tracked (**Phase 6 — why an
ignored file still goes to Step 2**).

**If not ignored:** append it — append, never overwrite `.gitignore` (**Phase 6 — why append to
`.gitignore`**) — and record that fact for Step 3's commit message:

```bash
printf '%s\n' '.hivrr.json' >> .gitignore
```

**Step 2 — Check whether `.hivrr.json` is tracked**

```bash
git ls-files --error-unmatch .hivrr.json >/dev/null 2>&1 && echo tracked || echo untracked
```

**If tracked:** untrack it without touching the working-tree file. This stages a deletion from the
index only; the file and its config stay on disk (**Phase 6 — what `git rm --cached` does**):

```bash
git rm --cached .hivrr.json
```

**If untracked:** nothing to do here.

**Skip Step 3 entirely** when neither Step 1 nor Step 2 changed anything — `.gitignore` already had
the line and `.hivrr.json` was already untracked. Emit `INIT: .hivrr.json gitignored` and continue to
Phase 7.

**Step 3 — Commit the change**

Resolve the current branch and the protected set — `branches.protected` from `.hivrr.json` (read it
before Step 2's `git rm --cached` if you need it, the working-tree file is unaffected either way),
falling back to the documented default (`main`, `master`, `dev`, `develop`, `staging`, `release/*`):

```bash
git branch --show-current
```

**On a branch that is not protected** — stage and commit exactly the two paths this phase can touch:

```bash
git add .gitignore
git commit -m "chore(config): keep .hivrr.json out of git" -- .gitignore .hivrr.json
```

**The trailing pathspec is required, not decoration.** A bare `git commit` commits the **whole
index**, including anything staged before `init` ran, and `init` routinely runs mid-workflow with a
populated index. With the pathspec the commit carries `.gitignore`, plus `.hivrr.json`'s removal when
Step 2 staged one, and nothing else (**Phase 6 — the commit's trailing pathspec**). Keep this rule
inline rather than linking to `core`'s **Staging**: `init` also ships in `planner`, which has no
`core` (**Phase 6 — why the pathspec rule is restated in `init`, not linked**).

Then confirm the commit carries only `.gitignore` and, if Step 2 ran, `.hivrr.json`'s removal:

```bash
git show --stat --oneline HEAD
```

If anything else is listed, report it and stop. Do not report a clean config commit.

**On a protected branch** — do not commit. Stage what changed and report:

```bash
git add .gitignore
```

`core` forbids committing directly to a protected branch, so the decision is the user's: commit it
from a feature branch, or run the Step 3 commit deliberately.

**Never push.** `init` is setup, not delivery, and a push from a setup phase is a surprise.

Emit one of:
- `INIT: .hivrr.json gitignored ({branch})` — `.gitignore` updated, and untracked if it was tracked
- `INIT: .hivrr.json gitignored — {branch} is protected, commit deliberately`
- `INIT: .hivrr.json gitignored` — already ignored and already untracked, nothing to do

---

## Phase 7 — Report Orphan Worktrees

**Skip when `worktree` is absent from `.hivrr.json`.** This is the phase's only gate: it does not
depend on `project`, so it runs even when Phase 5 skipped (**Phase 7 — why it is not gated on
`project`** in [`references/git-hygiene.md`](references/git-hygiene.md)).

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

**Do not use `git branch --merged` here.** Under squash merges a merged branch shares no commit with
the base, so `--merged` silently returns nothing for exactly these branches. And `: gone]` means the
remote ref disappeared, **not** that the work landed, so say `branch gone from remote` rather than
`merged`. Read **Phase 7 — why `: gone]`, not `git branch --merged`** in `references/git-hygiene.md`
before changing either rule.

```
INIT: 2 orphan worktree(s)
      .claude/worktrees/issue/41  [issue/41]  branch gone from remote
      .claude/worktrees/issue/38  [issue/38]  prunable
      Clean up: git worktree prune, or git worktree remove {path}
```

**Report only — never remove.** An orphan may hold the only copy of unfinished work, and `init` is
setup, not cleanup. Offer the commands and let the user run them.

Emit `INIT: worktrees ok` when there are none, and nothing at all when `worktree` is absent.

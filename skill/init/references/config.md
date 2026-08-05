# `.hivrr.json` — Repo-Local Configuration

`.hivrr.json` lives at the repository root and is **committed**. It travels with the code, so every teammate, agent, and CI runner resolves the same values.

There is no loader script. This file is the contract: skills read `.hivrr.json` directly and apply the precedence rule below.

---

## Why repo-local

Per-repo facts do not belong in a global config. Global `~/.claude/settings.json` `providerConfig` is per-*user*, so a user whose global config says `repoProvider: gitlab` gets GitLab behavior while standing in a GitHub repo — label bootstrap skips and the wrong provider reference loads.

Global `providerConfig` survives for values that genuinely are user-shaped: `gitlabGroup`, `githubOrg`, `linearTeam`, `repoTarget`, `bootstrappedRepos`.

---

## Schema

```json
{
  "provider": "github",
  "branches": {
    "integration": "dev",
    "ladder": ["dev", "staging", "main"],
    "protected": ["dev", "staging", "main"]
  },
  "project": {
    "owner": "hivrr",
    "number": 1,
    "statusFieldId": "PVTSSF_xxx",
    "status": { "todo": "<option id>", "inProgress": "<option id>", "done": "<option id>" }
  },
  "verify": {
    "test": "npm test",
    "lint": "npx eslint .",
    "detectedFrom": ["package.json:scripts.test", "eslint.config.js"]
  }
}
```

Every top-level key is optional. A file containing only `{}` is valid and resolves entirely to defaults.

---

## Fields

| Key | Type | Default when absent | Read by |
|---|---|---|---|
| `provider` | `"github"` \| `"gitlab"` | global `providerConfig.repoProvider` | `session` |
| `branches.integration` | string | repo default branch | `work-issue`, `wave` |
| `branches.ladder` | string[] | `[default branch]` | `merge-pr`, `promote` |
| `branches.protected` | string[] | `["main", "master", "dev", "develop", "staging", "release/*"]` | `merge-pr`, `core`, `promote` |
| `project` | object \| absent | absent — all board operations are silent no-ops | `planning`, `work-issue`, `merge-pr`, `score-issues`, `group-issues` |
| `project.owner` | string | — | board operations |
| `project.number` | number | — | board operations |
| `project.statusFieldId` | string (`PVTSSF_…`) | — | board status transitions |
| `project.status.todo` \| `.inProgress` \| `.done` | string (option id) | — | board status transitions |
| `verify.test` | string | model detects, then offers to record | `work-issue`, `work-pr` |
| `verify.lint` | string | model detects, then offers to record | `work-issue`, `work-pr` |
| `verify.detectedFrom` | string[] | — | `init` (staleness check) |

### `branches.integration`

The branch feature work forks from and targets. On a repo with no ladder this is just the default branch; on a ladder repo it is the lowest rung (`dev`).

### `branches.ladder`

Ordered rungs, lowest environment first. `promote` resolves the next rung from this list, and `merge-pr` uses it to detect promotion PRs: a PR is a promotion when **both** its head and its base appear in `ladder`.

A single-element ladder means promotion no-ops — which is the correct behavior for a repo with one long-lived branch.

### `branches.protected`

Branches that must never be deleted or force-pushed. Entries may use a trailing `*` wildcard (`release/*`). `merge-pr` consults this before passing `--delete-branch`.

### `project`

GitHub Projects v2 board wiring. Field mutations on Projects v2 are GraphQL-only and need opaque IDs, so they are resolved once and cached here rather than looked up per call. When `project` is absent, every board operation is a silent no-op — never an error.

### `verify`

The test and lint commands for this repo. `detectedFrom` records *which files justified each command*, so `init` can tell a stale command from a current one rather than trusting a "already configured, skip" flag.

---

## Precedence

Resolved **per key**, not per file. A `.hivrr.json` that sets only `branches.integration` does not suppress `provider` from global config.

```
.hivrr.json  →  ~/.claude/settings.json providerConfig  →  hardcoded default
```

For each key a skill needs, take the first source that defines it. A key present but set to `null` counts as absent and falls through.

---

## Read steps

Skills that need config run this sequence once per session:

**1 — Does the file exist?**

```bash
test -f .hivrr.json && echo present || echo absent
```

Absent is normal. Skip to step 4 and resolve every key from the fallback chain.

**2 — Validate it parses.**

```bash
jq empty .hivrr.json
```

**3 — Read it.**

Use the Read tool on `.hivrr.json`. Do not `cat` it — the Read tool keeps the content in context for later phases.

**4 — Resolve each key** through the precedence chain above, using the defaults in the field table.

---

## Failure modes

These are deliberately different, and conflating them is a bug:

| Condition | Behavior |
|---|---|
| File absent | **Normal.** Resolve everything from fallbacks. Emit nothing. |
| File present, `jq empty` fails | **Hard error.** Stop and report the parse error with the file path. Do not guess at defaults — a malformed config is a mistake the user needs to see, and silently ignoring it produces behavior they did not ask for. |
| File present, valid JSON, key missing | **Normal.** Fall through to the next source for that key. |
| File present, key has the wrong type (e.g. `ladder` is a string) | **Hard error.** Report the key and the expected type. |

---

## Scaffolding

`init` Phase 3 offers to write a `.hivrr.json` derived from detected repo state. It **never overwrites an existing file** — if one is present, init reports it and moves on. Editing an existing config is the user's job.

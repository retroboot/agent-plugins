# `.hivrr.json` — Repo-Local Configuration

`.hivrr.json` lives at the repository root and is **gitignored** — `init` Phase 6 keeps it out of
git deliberately. It is per-checkout, not committed: every teammate, agent, and CI run derives its
own copy by running `init`, rather than inheriting one that travels with the code.

There is no loader script. This file is the contract: skills read `.hivrr.json` directly and apply the precedence rule below.

---

## Why repo-local, and why gitignored

Per-repo facts do not belong in a global config. Global `~/.claude/settings.json` `providerConfig` is per-*user*, so a user whose global config says `repoProvider: gitlab` gets GitLab behavior while standing in a GitHub repo — label bootstrap skips and the wrong provider reference loads.

Global `providerConfig` survives for values that genuinely are user-shaped: `gitlabGroup`, `githubOrg`, `linearTeam`, `repoTarget`, `bootstrappedRepos`.

**Repo-local does not mean committed.** An earlier version of this file argued the opposite — that
`.hivrr.json` should travel with the code so every teammate, agent, and CI runner resolves the same
values — and this plugin's own repo did exactly that. In practice a committed config is a copy of
whatever was true on whichever machine last ran `init`, not a live fact about the repo; the branch
ladder, verify commands, and board IDs it holds are all things `init` can re-derive on any machine in
seconds, in `--auto` mode with no prompting. Committing it buys nothing a fresh `init` run doesn't
already provide, and it costs a stale copy silently drifting from what a real `init` run would
produce — which is how it ended up committed here in the first place, before Phase 6 existed to stop
it. Every teammate, agent, and CI run is expected to run `init` for itself; that is what keeps them
in sync, not git.

---

## Schema

```json
{
  "provider": "github",
  "issueTracker": "github",
  "branches": {
    "integration": "dev",
    "ladder": ["dev", "staging", "main"],
    "protected": ["dev", "staging", "main"]
  },
  "project": {
    "owner": "hivrr",
    "number": 1,
    "id": "PVT_xxx",
    "statusFieldId": "PVTSSF_xxx",
    "status": { "todo": "<option id>", "inProgress": "<option id>", "done": "<option id>" }
  },
  "issues": {
    "hierarchy": true,
    "epicThreshold": 4
  },
  "worktree": {
    "enabled": true,
    "carry": [".env", ".claude/settings.local.json"],
    "setup": "npm ci"
  },
  "ci": {
    "optionalManualJobs": ["deploy-review-app"]
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
| `provider` | `"github"` \| `"gitlab"` | global `providerConfig.repoProvider`, then the host in `git remote get-url origin` | `session` |
| `issueTracker` | `"github"` \| `"gitlab"` \| `"linear"` | global `providerConfig.issueTracker`, then the resolved `provider` | `session` |
| `branches.integration` | string | repo default branch | `work-issue`, `wave` |
| `branches.ladder` | string[] | `[default branch]` | `merge-pr`, `promote` |
| `branches.protected` | string[] | `["main", "master", "dev", "develop", "staging", "release/*"]` | `merge-pr`, `core`, `promote` |
| `project` | object \| absent | absent — all board operations are silent no-ops | `planning`, `work-issue`, `merge-pr` |
| `project.owner` | string | — | board operations |
| `project.number` | number | — | board operations |
| `project.id` | string (`PVT_…`) | — | `gh project item-edit --project-id` |
| `project.statusFieldId` | string (`PVTSSF_…`) | — | board status transitions |
| `project.status.todo` \| `.inProgress` \| `.done` | string (option id) | — | board status transitions |
| `issues` | object \| absent | absent — all hierarchy operations are silent no-ops | `planning`, `work-issue`, `merge-pr` |
| `issues.hierarchy` | boolean | `false` | all hierarchy operations |
| `issues.epicThreshold` | number | `4` | `planning` |
| `worktree` | object \| absent | absent — no worktree behavior | `work-issue`, `wave`, `merge-pr`, `init` |
| `worktree.enabled` | boolean | `false` | `work-issue`, `wave` |
| `worktree.carry` | string[] | `[]` | `work-issue`, `wave` |
| `worktree.setup` | string \| `null` | `null` | `work-issue`, `wave` |
| `ci` | object \| absent | absent — every unplayed manual job blocks a merge | `merge-pr` |
| `ci.optionalManualJobs` | string[] | `[]` — every unplayed manual job blocks a merge | `merge-pr` |
| `verify.test` | string \| `null` | model detects, then offers to record | `work-issue`, `work-pr` |
| `verify.lint` | string \| `null` | model detects, then offers to record | `work-issue`, `work-pr` |
| `verify.detectedFrom` | string[] | — | `init` Phase 4 (staleness check) |

A `verify` command recorded as `null` means "checked, this repo has nothing" — distinct from the key being absent, which means "never checked".

### `provider` and `issueTracker`

Two independent keys, because the two facts are independent: a repo hosted on one provider can
track its issues on another. Resolve them **separately** through the precedence chain — a repo
that sets only `provider` still takes its tracker from global config.

Setting one and not the other is the case that goes wrong quietly. A repo whose `.hivrr.json`
says `"provider": "github"` against a global config of `{"repoProvider": "gitlab",
"issueTracker": "gitlab"}` resolves as a GitHub repo whose issues are read from GitLab —
`session` loads `gitlab.md` and every issue command in it is aimed at the wrong host. Nothing
errors; the commands simply address a tracker that does not hold the issues.

`issueTracker` falls through to global `providerConfig.issueTracker` when absent, and to the
**resolved `provider`** when that is absent too. A repo that states its provider and nothing else
therefore tracks issues on that same provider, which is the common arrangement and the one worth
getting for free.

### `branches.integration`

The branch feature work forks from and targets. On a repo with no ladder this is just the default branch; on a ladder repo it is the lowest rung (`dev`).

### `branches.ladder`

Ordered rungs, lowest environment first. `promote` resolves the next rung from this list, and `merge-pr` uses it to detect promotion PRs: a PR is a promotion when **both** its head and its base appear in `ladder`.

A single-element ladder means promotion no-ops — which is the correct behavior for a repo with one long-lived branch.

### `branches.protected`

Branches that must never be deleted or force-pushed. Entries may use a trailing `*` wildcard (`release/*`). `merge-pr` consults this before passing `--delete-branch`.

**Writing this key replaces the default set — it does not extend it.** Precedence resolves per key, so `"protected": ["main"]` leaves `dev`, `develop`, `staging`, and `release/*` unprotected. That is strictly worse than omitting the key. Set it only to *add* names the default does not cover, and when you do, write the full union rather than a subset.

### `project`

GitHub Projects v2 board wiring. Field mutations on Projects v2 are GraphQL-only and need opaque IDs, so they are resolved once and cached here rather than looked up per call. When `project` is absent, every board operation is a silent no-op — never an error.

### `issues`

Issue-hierarchy wiring. `hierarchy` opts the repo into GitHub sub-issues; when it is `false` or the
`issues` key is absent, every hierarchy operation is a **silent no-op** — never a warning. This is
the same contract as `project`, and for the same reason: most repos will not adopt hierarchy, and
announcing that on every invocation is noise.

`epicThreshold` is the slice count at or above which `planning` proposes a parent epic. A plan pack
publishes one issue per slice, so this is also the issue count; a pack of Size L gets an epic
whatever its slice count (see `skills/planning/references/publish.md`, **Epic**). Below it,
planning emits a flat set — a parent wrapping two issues is bookkeeping with no board benefit.

**`hierarchy` is GitHub-only.** GitLab has no equivalent outside Premium epics and Linear has its
own native parent/sub-issue model that does not route through these commands. When the resolved
provider is not `github`, treat `hierarchy` as `false` regardless of its configured value.

### `worktree`

Isolation for mutating sessions. When `enabled` is true, `work-issue` and `wave` run inside a git
worktree instead of the shared checkout, so two concurrent sessions cannot stage or commit each
other's changes. Absent or `false` means every worktree operation is a **silent no-op**.

Only mutating skills use this. `review-pr` and `audit` are read-only — they cannot collide, so a
worktree there is setup cost for no benefit.

**`enabled` alone is not sufficient.** The harness `EnterWorktree` tool acts only when the user says
"worktree" explicitly or when the repo's own `CLAUDE.md` instructs it. A repo that sets `enabled`
without adding the CLAUDE.md line gets no worktree, silently. Both are required; see
**Adopting worktrees** below.

#### `carry`

A worktree receives **tracked files only**. Untracked and ignored files — `.env`, `node_modules`,
`.claude/settings.local.json` — do not come along. `carry` names the paths to bring in, relative to
the repo root. Each is copied when small, or symlinked when it is a large directory.

Losing `.claude/settings.local.json` resets the permission allowlist, so the operator re-approves
prompts they already dismissed. Losing `.env` breaks anything that reads configuration at startup.
Both are quiet failures that look like something else, which is why the list is explicit rather
than inferred.

#### `setup`

A single command run once inside a fresh worktree after `carry` completes — typically a dependency
install. Runs only on creation, never on resume. A non-zero exit is a **warning**: report it and
continue, because a worktree with missing dependencies is still recoverable by hand, while aborting
loses the session's context.

#### Adopting worktrees

A repo opts in with **both** of these:

1. `worktree.enabled: true` in `.hivrr.json`, plus whatever `carry` and `setup` it needs.
2. This line in the repo's own `CLAUDE.md`:

   > Mutating agent work (`/work-issue`, `/wave`) runs in a git worktree. Use `EnterWorktree` at
   > the start of those workflows and clean up per `merge-pr`.

3. `.claude/` in the repo's `.gitignore`. Worktrees are created under `.claude/worktrees/`, and if
   that path is not ignored it shows up as an untracked `??` entry in the `git status --short`
   check `core` requires before committing. That does not halt the run — `core` judges untracked
   entries by who created them, and a worktree this run entered is expected — but it does put a
   directory in front of every later commit that has to be told apart from a genuine
   concurrent-session signal, and it is what a regression to blanket staging would sweep into a
   commit wholesale. Ignore it and the question never arises.

The `.hivrr.json` key carries the settings; the CLAUDE.md line is what authorizes the tool; the
`.gitignore` entry is what keeps the worktree invisible to the staging check.

Do not assume the third is already true. `.claude/` being gitignored is a convention, not a
guarantee — and `carry`'s default list names `.claude/settings.local.json`, so an adopting repo is
expected to have files under `.claude/` it cares about. Check rather than infer.

### `ci`

`optionalManualJobs` names the manual CI jobs that `merge-pr` may merge without anyone playing. By
default every unplayed manual job stops a merge (`merge-pr` Phase 4), because nothing in the CI
payload tells a must-play job such as `sign-bundles` from a deploy-on-demand one, and both can carry
`allow_failure: true`. List a job here only when merging without it is genuinely fine. Names match
exactly, case included; a listed job is still named in `merge-pr`'s CI line, never skipped silently.

**Why every unplayed manual job, not only those that block their pipeline.** A manual job with
`allow_failure: false` already blocks its pipeline, which then reports `manual`, so a
pipeline-status check would catch it. The job that slipped through was the other kind —
`allow_failure: true`, which GitLab treats as optional and the project did not. Nothing in the CI
payload tells a deploy-on-demand job from a must-play one, so the default is to stop, and this
allowlist is how a repo records the difference rather than `merge-pr` guessing it.

**List the jobs behind it too.** A job that `needs:` an unplayed manual job, or sits in a later
stage of a blocked pipeline, stays `created`, and `merge-pr` reports it as `manual` under its own
name. Allowlisting `deploy-prod` alone still stops on its `smoke-prod`; list both.

**A value that is not an array of strings is treated as `[]`**, so every manual job blocks. A `ci`
key that is not an object is treated the same way, as if absent.
`merge-pr` names the bad value once and carries on with the empty list. Unlike other wrong-type keys
this is not a hard error, because the fallback already fails closed: the worst it can do is stop a
merge, never let one through.

It is GitLab-only in practice: GitHub has no manual jobs, so there is nothing for the list to match.
`init` never writes it, and like the rest of the file it is per checkout, not shared through git.

### `verify`

The test and lint commands for this repo. `detectedFrom` records *which files justified each command*, so `init` can tell a stale command from a current one rather than trusting a "already configured, skip" flag.

#### The `["manual"]` sentinel

`detectedFrom` set to exactly `["manual"]` means **a human recorded these commands and `init` Phase 4
must not re-detect them.** Phase 4 stops at Step 1, emits `INIT: verify manual — not re-detected`,
and leaves the block alone.

Use it when a repo's verification is real but unconventional — structural checks defined in a
`README`, a bespoke harness, anything the detection tables have no row for. Without the sentinel
Phase 4 correctly finds nothing and writes `null`, and `null` contractually means "checked, there is
nothing", so `work-issue` and `work-pr` report `skipped`. An unattended run then skips verification
on a repo that has it — which is worse than never having detected at all, because the config now
asserts the absence.

It governs the whole block, not one key. A repo wanting `test` pinned and `lint` detected should
record both by hand; a half-manual block has unreadable provenance.

The trade is explicit: the sentinel buys accuracy and gives up drift detection. A manual command
that stops working will keep being run until someone notices, because nothing re-checks it.

**A manual command must fail loudly when it cannot run.** Detection at least reports `skipped`
honestly; a hand-written command that collects findings on stdout and ignores stderr reports `pass`
after every one of its inputs failed to open, and the skills relay that as verified. Anchor it to
the repo root, fold stderr into what is collected, and assert that each input file exists before
trusting a check's silence.

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

A non-zero exit here means malformed JSON — **except** for `command not found` (exit 127), which means `jq` is missing, not that the config is bad. Treat that case as "unvalidated but readable": note it once and continue to step 3. Do not report a valid config as malformed because the validator is absent.

**3 — Read it.**

Use the Read tool on `.hivrr.json`. Do not `cat` it — the Read tool keeps the content in context for later phases.

**4 — Resolve each key** through the precedence chain above, using the defaults in the field table.

---

## Failure modes

These are deliberately different, and conflating them is a bug:

| Condition | Behavior |
|---|---|
| File absent | **Normal.** Resolve everything from fallbacks. Emit nothing. |
| File present, `jq empty` reports a parse error | **Hard error.** Stop and report the parse error with the file path. Do not guess at defaults — a malformed config is a mistake the user needs to see, and silently ignoring it produces behavior they did not ask for. |
| File present, `jq` itself is not installed (exit 127) | **Not an error.** The validator is missing, not the config. Note it once and read the file anyway. |
| File present, valid JSON, key missing | **Normal.** Fall through to the next source for that key. |
| File present, key has the wrong type (e.g. `ladder` is a string) | **Hard error.** Report the key and the expected type. |
| `worktree.enabled` true, no CLAUDE.md authorization | **Warn once and continue without a worktree.** Name the missing line. Never fail the workflow — the work is the deliverable. |
| `worktree.carry` names a path that does not exist | **Warn and continue.** A repo without a `.env` is normal, not an error. |
| `ci.optionalManualJobs` is not an array of strings | **Warn and treat it as `[]`.** Every manual job then blocks, which fails closed. |
| `worktree.setup` exits non-zero | **Warn and continue.** Report the exit code and the command. |

---

## Scaffolding

`init` Phase 3 offers to write a `.hivrr.json` derived from detected repo state. It **never overwrites an existing file** — if one is present, init reports it and moves on. Editing an existing config is the user's job.

`init` Phase 6 ensures `.hivrr.json` is gitignored and untracked — adding the `.gitignore` line and
running `git rm --cached` if the file was ever committed — and commits *that* change, never
`.hivrr.json`'s own content. On a protected branch it stages the `.gitignore` change and reports,
because `core` forbids committing directly to protected branches and a setup phase is the wrong place
to break that rule.

This is what makes the "is gitignored" claim at the top of this document true rather than
aspirational, and it is what fixes a repo — like this plugin's own — that committed `.hivrr.json`
before this phase existed. Every teammate, agent, and CI run is expected to resolve its own copy by
running `init`, not by reading one out of git.

---

## Resolving GitHub Project v2 IDs

Projects v2 field mutations are **GraphQL-only** — there is no `gh project` subcommand that edits a single-select field by name. Editing an item's Status requires four opaque IDs: the project ID, the item ID, the *field* ID, and the *option* ID for the value you want.

Three of those are stable per repo, so resolve them **once** and cache them in `.hivrr.json.project`. Only the item ID is per-issue and must be looked up at call time. Re-resolving the cached IDs on every board operation would add two GraphQL round trips to every workflow step for values that never change.

### Required token scopes

`gh auth login` does not grant project scopes by default. Board operations need:

| Scope | Needed for |
|---|---|
| `read:project` | Reading the board, resolving field and option IDs |
| `project` | Writing — adding items, changing Status |

Check what the current token has:

```bash
gh auth status
```

Add them without re-authenticating from scratch:

```bash
gh auth refresh -s read:project -s project
```

A missing scope surfaces as a GraphQL error containing `INSUFFICIENT_SCOPES` or `Resource not accessible by personal access token` — **not** as an empty result. Report the missing scope and the `gh auth refresh` command; do not silently treat it as "no project configured".

### Step 1 — Resolve the project ID

The `id` returned here is the project **node ID** (`PVT_…`). It is a distinct value from `project.number`, and `gh project item-edit --project-id` needs the node ID, not the number.

For an organization-owned project:

```bash
gh api graphql -f query='
  query($owner: String!, $number: Int!) {
    organization(login: $owner) {
      projectV2(number: $number) { id title }
    }
  }' -f owner={project.owner} -F number={project.number}
```

For a user-owned project, replace `organization` with `user`. Try `organization` first; a `Could not resolve to an Organization` error means retry as `user`.

### Step 2 — Resolve the Status field and its options

One query returns both the field ID and every option ID:

```bash
gh api graphql -f query='
  query($projectId: ID!) {
    node(id: $projectId) {
      ... on ProjectV2 {
        fields(first: 50) {
          nodes {
            ... on ProjectV2SingleSelectField {
              id
              name
              options { id name }
            }
          }
        }
      }
    }
  }' -f projectId={project_id}
```

Find the node whose `name` is `Status`. Its `id` is `statusFieldId`. Match its options to the three config keys by name, case-insensitively:

| Config key | Matches option named |
|---|---|
| `status.todo` | `Todo`, `To do`, `Backlog` |
| `status.inProgress` | `In Progress`, `In progress`, `Doing` |
| `status.done` | `Done`, `Complete`, `Completed` |

### Step 3 — Cache the result

Write `project.id` (from Step 1), `project.statusFieldId`, and the three `project.status.*` option IDs into `.hivrr.json`, preserving every other key. Validate with `jq empty`.

Verify:

```bash
jq '.project | {id, statusFieldId, status}' .hivrr.json
```

### Re-resolution

Re-resolve **only** when an ID is absent, or when explicitly asked to. Do not re-resolve as a routine step.

### Failure modes

| Condition | Behavior |
|---|---|
| `project` absent from `.hivrr.json` | **Not an error.** The repo has no board. Every board operation is a silent no-op. |
| Token missing `read:project` / `project` | Report the missing scope and the `gh auth refresh` command. Do not confuse this with "no project". |
| Project number does not exist | Report it. The likely cause is a typo in `project.number` or an org/user mismatch. |
| No field named `Status` | Report which fields do exist. Some boards rename it. |
| A Status option was renamed, so a config key has no match | **Warn, name the unmatched key and the options that do exist, and offer to re-resolve.** Never crash, and never write a `null` option ID — a null would make later `item-edit` calls fail with a far less obvious error. |
| A cached option ID no longer exists on the board | Same as above: the option was deleted or recreated. Re-resolve. |

---

## Board operations

The operations every board-aware skill performs, defined once. `planning`, `work-issue`, and `merge-pr` all use these rather than each carrying its own GraphQL.

### The universal rule

**Every board call warns and continues on failure. None of them ever aborts the workflow that called it.**

A board is a reporting surface. Failing to move a card must never prevent an issue from being created, a branch from being made, or a PR from merging — the work is the point, and the card is a record of it. A skill that aborts on a board error converts a cosmetic outage into a blocked pipeline.

Likewise, **`project` absent from `.hivrr.json` is a silent no-op**, not a warning. Most repos have no board; saying so on every invocation is noise.

### Add an issue to the board

```bash
gh project item-add {project.number} --owner {project.owner} --url {issue_url}
```

Adding an item that is already on the board is harmless — it returns the existing item.

### Resolve an issue's item ID

Item IDs are per-issue and cannot be cached. Resolve at call time:

```bash
gh project item-list {project.number} --owner {project.owner} --format json \
  --jq '.items[] | select(.content.number == {N}) | .id'
```

**Empty result means the issue is not on the board.** Add it first with `item-add`, then resolve again. If it is still missing after that, warn and skip — do not loop.

For large boards, pass `--limit` above the default (`gh project item-list` defaults to 30) or the query will silently miss items:

```bash
gh project item-list {project.number} --owner {project.owner} --limit 500 --format json
```

### Set an item's Status

```bash
gh project item-edit \
  --project-id {project.id} \
  --id {item_id} \
  --field-id {project.statusFieldId} \
  --single-select-option-id {project.status.todo | .inProgress | .done}
```

All four IDs are required, and three of them come from the cache written by `init` Phase 5. If `statusFieldId` or the needed option ID is missing, warn that the board IDs are unresolved, point at `init`, and continue.

### Read an issue's Status

```bash
gh project item-list {project.number} --owner {project.owner} --limit 500 --format json \
  --jq '.items[] | select(.content.number == {N}) | .status'
```

Returns the option **name** (`Todo`, `In Progress`, `Done`), not its ID. Match it case-insensitively — boards rename these.

An issue absent from the board has no status. Treat that as "not tracked", which is different from `Todo`.

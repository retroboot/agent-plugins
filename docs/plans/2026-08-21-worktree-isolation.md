# Worktree Isolation and Staging Hygiene — Implementation Plan

> **For agentic workers:** Use the `work-issue` skill to implement this plan step-by-step.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop concurrent sessions in the same checkout from committing each other's work — by fixing the staging bug that causes the sweep, and by isolating mutating sessions into git worktrees.

**Architecture:** Two independent tracks. **Hygiene** replaces `git add -A` with staging from the files-touched record each skill already keeps, and makes `init` commit the `.hivrr.json` it writes. **Isolation** adds an opt-in `worktree` key to `.hivrr.json`, has `work-issue` and `wave` enter a harness worktree, and teaches `merge-pr` and `init` the cleanup ordering git actually enforces. No worktree machinery is built — the harness already ships `EnterWorktree`/`ExitWorktree`, so the plugin prescribes and gates rather than implements.

**Tech Stack:** Markdown skill definitions, `git` (`worktree`, `checkout -B`, targeted `add`), `EnterWorktree`/`ExitWorktree` harness tools, `jq`.

---

## Context: what was verified, and how

Every claim below was executed on 2026-08-21 — the git mechanics in throwaway repos under the scratchpad, the file references against this working tree.

### The staging bug is a self-contradiction, and it is the root cause

```
skill/work-issue/SKILL.md:275   Stage all changes: `git add -A`
skill/work-pr/SKILL.md:183      Stage all changes: `git add -A`
skill/planning/references/plan-writing.md:136
                                One commit per task. Stage only the files for that task.
                                Never `git add .`.
```

The planning reference forbids what the two execution skills mandate. `-A` is the broader of the two hazards: `git add .` is scoped to the current directory, while `-A` stages across the entire repository including deletions, regardless of where the process is standing.

**Worktrees contain the blast radius; they do not fix this.** Inside a worktree, `git add -A` still sweeps every unrelated edit in that worktree. What isolation buys is that a *concurrent session's* edits are no longer in the same directory to be swept. Both changes are worth making and neither substitutes for the other — which is why the hygiene track lands first and independently.

### `.hivrr.json` asserts a property nothing establishes

`skill/init/references/config.md:3` opens:

> `.hivrr.json` lives at the repository root and is **committed**. It travels with the code, so every teammate, agent, and CI runner resolves the same values.

`init` Phase 3 scaffolds the file, Phase 4 writes `verify`, Phase 5 writes `project` — and **none of those phases mentions `git`**. Nothing ever stages it. It is tracked in this repo (`git ls-files .hivrr.json` confirms), so the untracked case appears in repos where `init` scaffolded it fresh.

**The two findings interact, and the order matters.** Today an untracked `.hivrr.json` gets committed anyway — swept up by `git add -A` into whatever unrelated feature commit runs next, with the wrong message on the wrong branch. Fixing the staging bug **removes that accidental mechanism**, so a repo that fixes staging without also fixing config sync goes from "committed wrongly" to "never committed at all," silently. Step 2 must land with or immediately after Step 1.

### Cleanup ordering is enforced by git, not chosen

```
$ git worktree remove .claude/worktrees/s1
fatal: '.claude/worktrees/s1' contains modified or untracked files, use --force to delete it

$ rm -rf .claude/worktrees/s1 && git worktree list
…/.claude/worktrees/s1  7a39694 [issue/42] prunable        ← stale entry survives deletion

$ git worktree prune && git branch -D issue/42
Deleted branch issue/42 (was 7a39694).                     ← only succeeds after prune
```

And while a worktree holds a branch:

```
$ git branch -D issue/42
error: cannot delete branch 'issue/42' used by worktree at '…/.claude/worktrees/s1'

$ git worktree add .claude/worktrees/s2 issue/42
fatal: 'issue/42' is already used by worktree at '…/.claude/worktrees/s1'
```

So the sequence **exit → remove/prune → delete branch** is forced. `merge-pr` deletes branches today with no knowledge of any of it and would fail mid-phase on a worktree session.

### `baseRef` mismatch is real but neutralizable

`EnterWorktree` branches per the `worktree.baseRef` setting: `fresh` (default) forks from `origin/<default-branch>`. `~/.claude/settings.json` has no `worktree` key, so the default applies. On a ladder repo `branches.integration` is `dev`, so a worktree would fork from `main` — the same class of defect `github.md` already warns about for `gh pr create --base`.

Verified fix — re-pointing from inside the worktree costs one command and makes `baseRef` irrelevant:

```
base before re-point: 4dc2ee4 main commit     (dev's file absent)
$ git checkout -B issue/42 dev
Reset branch 'issue/42'
base after re-point:  5eb3c17 dev commit      (dev's file present)
```

### Fixed decisions (do not re-litigate)

| ID | Decision | Grounds |
|----|----------|---------|
| **A** | **Hygiene lands before isolation.** Steps 1–2 are independent of 3–5. | The staging fix is a two-line change against the root cause. Isolation is containment. Shipping containment first leaves the actual bug live. |
| **B** | **Step 2 ships with Step 1, never after a gap.** | Step 1 removes the `git add -A` sweep that is currently the only thing committing `.hivrr.json`. Step 1 alone makes the config gap silently worse. |
| **C** | **Worktrees only for `work-issue` and `wave`.** | Read-only skills (`review-pr`, `audit`, `score-issues`, `group-issues`, `diagnose-failure`) cannot collide. A worktree there is setup cost for no benefit. |
| **D** | **The plugin builds no worktree machinery.** It gates and prescribes; the harness executes. | `EnterWorktree`/`ExitWorktree` already exist. Reimplementing them as `git worktree` steps would duplicate a working tool and violate the script policy's single-purpose test. |
| **E** | **`worktree` absent from `.hivrr.json` ⇒ silent no-op.** | Mirrors `project` and `issues` exactly. Most repos will not adopt this. |
| **F** | **The skill re-points its branch after entering.** | Makes the global `baseRef` setting irrelevant, so adoption needs no change to `~/.claude/settings.json`. |
| **G** | **`git worktree remove --force` is a confirmation point, never automatic.** | It discards uncommitted work. Same posture `branches.protected` takes toward deletion. |
| **H** | **Orphan worktrees are reported, never auto-deleted.** | An abandoned worktree may hold the only copy of someone's work. Reporting is safe; sweeping is not. |

### The authorization constraint — read this before Step 4

`EnterWorktree`'s contract states it must be used **only** when the user says "worktree" explicitly, **or when CLAUDE.md / memory instructs it**. A `SKILL.md` is arguably project instruction, but it is not named in that list, and relying on the ambiguity would make adoption unreliable in a way that is invisible until it silently does not happen.

Therefore adoption is **belt-and-braces**: the repo records `worktree.enabled` in `.hivrr.json` *and* carries a line in its own `CLAUDE.md` authorizing worktrees for mutating work. Step 3 ships the exact sentence for adopters to paste. A repo with the config key but no CLAUDE.md line must degrade to no worktree rather than silently half-adopting — Step 4 makes that check explicit.

---

## Complexity

**Complex** — two independent tracks, five steps, a hard ordering constraint inside each track, and behavior spanning `dev` and `planner` plugins plus the config contract.

---

## File Structure

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `skill/work-issue/SKILL.md:275` | Targeted staging; worktree entry in Phase 5 |
| Modify | `skill/work-pr/SKILL.md:183` | Targeted staging |
| Modify | `skill/planning/references/plan-writing.md:136` | Reconcile the staging rule wording |
| Modify | `skill/init/SKILL.md` — new Phases 6 and 7 | Commit `.hivrr.json`; report orphan worktrees. **Sibling phases, not steps inside Phase 5** — Phase 5 skips when `project` is absent |
| Modify | `skill/init/references/config.md` | `worktree` key: schema, fields, failure modes |
| Modify | `skill/wave/SKILL.md` Step 2 | Worktree-aware branch creation |
| Modify | `skill/merge-pr/SKILL.md` Phase 9, Steps 1 and 2 | Exit → remove → prune → delete ordering; skip worktree-held branches in the stale-branch prune |
| Modify | `CLAUDE.md` | Worktree opt-in sentence and the adopter snippet |

---

## Blueprint

**Steps:** 5 | **Track A (hygiene):** Steps 1 → 2 | **Track B (isolation):** Step 3 → Steps 4 and 5 [PARALLEL]

```
Track A:  Step 1 ──> Step 2

Track B:  Step 3 ──> Step 4 ──┐
                 └──> Step 5 ─┘
                     [PARALLEL]
```

The tracks share no files and can run concurrently. Track A is recommended first — it is smaller and fixes the root cause.

| Step | Points | Files |
|---|---|---|
| Step 1 — Targeted staging | 2 (S) | 3 |
| Step 2 — Commit `.hivrr.json` | 3 (M) | 1 |
| Step 3 — Worktree foundation | 3 (M) | 2 |
| Step 4 — Worktree entry | 5 (L) | 2 |
| Step 5 — Worktree cleanup | 5 (L) | 2 |

---

### Step 1: Targeted staging — branch: `fix/targeted-staging`

**Context brief:** `work-issue` Phase 10 and `work-pr` Phase 9 each instruct `git add -A`, which stages every change in the repository including deletions and files belonging to other concurrent work. `plan-writing.md:136` already states the opposite rule for plan-generated tasks. Both skills already know which files they touched: `wave` Step 3 records `git diff --name-only` per issue into a running implementation record, and single-issue runs edit a known set. This step makes the instruction match the rule the repo already publishes. It is independent of every other step here.

**Dependencies:** None.

**Tasks:**

- [ ] **Task 1.1 — Replace the staging instruction in `work-issue`**

  In `skill/work-issue/SKILL.md` Phase 10, replace `Stage all changes: \`git add -A\`` with:

  ````markdown
  **Stage only the files this work touched.** Never `git add -A` or `git add .` — both stage
  unrelated edits from any other work sharing this checkout, and `-A` does it repo-wide regardless of
  the current directory. A commit that sweeps in someone else's half-finished change is far more
  expensive to unpick than an extra staging command is to write.

  Build the file list from what you actually changed:

  - **Wave runs:** use the per-issue file lists recorded in Step 3 of the `wave` skill.
  - **Single-issue runs:** use the files you edited, plus any you created.

  Then stage them explicitly:

  ```bash
  git add {file} {file} …
  ```

  Before committing, confirm nothing unexpected is staged:

  ```bash
  git status --short
  ```

  Every staged path must be one you touched for this issue. **If an unexpected path appears, stop and
  report it** — it means another session is writing to this checkout, which is the exact condition
  worktree isolation exists to prevent. Do not unstage and continue silently.
  ````

- [ ] **Task 1.2 — Replace the staging instruction in `work-pr`**

  In `skill/work-pr/SKILL.md` Phase 9, replace `Stage all changes: \`git add -A\`` with the same
  block, substituting the source of the file list:

  ````markdown
  **Stage only the files this work touched.** Never `git add -A` or `git add .` — both stage
  unrelated edits from any other work sharing this checkout, and `-A` does it repo-wide regardless of
  the current directory.

  Build the list from the feedback items you addressed in this run, then stage explicitly:

  ```bash
  git add {file} {file} …
  git status --short
  ```

  Every staged path must be one you touched while addressing feedback. **If an unexpected path
  appears, stop and report it** rather than unstaging and continuing.
  ````

- [ ] **Task 1.3 — Reconcile the wording in `plan-writing.md`**

  `skill/planning/references/plan-writing.md:136` currently reads:

  ```markdown
  One commit per task. Stage only the files for that task. Never `git add .`.
  ```

  Replace with:

  ```markdown
  One commit per task. Stage only the files for that task. Never `git add .` or `git add -A` — `-A`
  is the broader hazard, staging repo-wide including deletions regardless of the current directory.
  ```

- [ ] **Task 1.4 — Verify and commit**

  Confirm no skill instructs blanket staging any more:

  ```bash
  grep -rn "git add -A\|git add \." --include="*.md" skill/ command/
  ```

  Expected: only the three prohibition lines from Tasks 1.1–1.3. No line that *instructs* blanket staging.

  ```bash
  jq empty .hivrr.json .claude-plugin/marketplace.json
  jq -r '.plugins[] | ((.skills // [])[], (.commands // [])[])' .claude-plugin/marketplace.json \
    | while read -r p; do [ -e "$p" ] || echo "MISSING $p"; done
  ```

  Expected: no output from either command.

  ```bash
  git add skill/work-issue/SKILL.md skill/work-pr/SKILL.md \
          skill/planning/references/plan-writing.md
  git commit -m "fix(work-issue,work-pr): stage only touched files instead of git add -A"
  ```

**Verification:**

Run: `grep -rn "Stage all changes" --include="*.md" skill/`
Expected: no output.

Run: `grep -c "Never \`git add" skill/work-issue/SKILL.md skill/work-pr/SKILL.md skill/planning/references/plan-writing.md`
Expected: at least `1` in each file.

**Exit criteria:** No skill instructs `git add -A` or `git add .`. Both execution skills stage from an explicit file list and verify with `git status --short` before committing.

**Rollback:** `git revert` the commit. Behavior returns to blanket staging.

**PR title suggestion:** `fix(work-issue,work-pr): stage only touched files instead of git add -A`

---

### Step 2: Commit `.hivrr.json` — branch: `fix/hivrr-config-sync`

**Context brief:** `config.md:3` states `.hivrr.json` is committed and travels with the code, but `init` Phases 3, 4, and 5 write it without ever staging it — no phase mentions `git`. Until Step 1, blanket staging committed it accidentally into unrelated feature commits. **After Step 1 it will never be committed at all**, which is why this step is not optional and must not lag. `init` frequently runs while standing on a protected branch, and `core` forbids committing directly to those, so this step must distinguish the two cases rather than committing unconditionally. It also must not live inside Phase 5, which skips whenever `project` is absent — the boardless repos that skip would be precisely the ones left with an untracked config.

**Dependencies:** Step 1 must be merged. See decision **B**.

**Tasks:**

- [ ] **Task 2.1 — Add a commit phase to `init`**

  Add a **new top-level phase** to `skill/init/SKILL.md`, after Phase 5, so it runs once after every
  phase that may have written the file.

  **It must be a sibling of Phase 5, not a step inside it.** `init` Phase 5 opens with *"**Skip this
  phase entirely** when `project` is absent from `.hivrr.json`"*, and a repo with no board is the
  documented normal case — including this one. A commit step nested under Phase 5 would never run on
  any boardless repo, which is exactly where an untracked `.hivrr.json` does the damage. Combined
  with Step 1 removing the `git add -A` sweep, nesting it would deliver the silent regression
  decision **B** exists to prevent while appearing to fix it.

  Note also that Phase 5 has no `Step` subdivisions at all, and Phases 2–4 number theirs with bold
  `**Step N —**` rather than `### Step N` headings — so there is nothing for a `### Step 4` to
  continue from.

  ````markdown
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

  **The trailing pathspec is required.** `git add .hivrr.json` stages one file, but a bare
  `git commit` commits the whole index — including anything staged before `init` ran. `init` is the
  first bootstrap step of every command, so it routinely runs mid-workflow with a populated index.
  Without the pathspec this commit sweeps a feature's staged files in under a config message, which
  is the bug Step 1 of this plan removed. Keep the `git add` too: `git commit -- {path}` fails on a
  never-tracked file, and a freshly scaffolded config is exactly that.

  Then confirm the commit carries one path and no more, and stop if it does not:

  ```bash
  git show --stat --oneline HEAD
  ```

  **On a protected branch** — do not commit. Stage it and report, leaving the decision to the user.
  Emit only the line from the list below; do not invent a second wording for the same outcome.

  ```bash
  git add .hivrr.json
  ```

  **Never push.** `init` is setup, not delivery, and a push from a setup phase is a surprise.

  Emit one of:
  - `INIT: .hivrr.json committed on {branch}`
  - `INIT: .hivrr.json staged — {branch} is protected, commit deliberately`
  - `INIT: .hivrr.json unchanged`
  ````

- [ ] **Task 2.2 — State the guarantee in `config.md`**

  `config.md:3` claims the file is committed without saying what makes that true. Extend the
  **Scaffolding** section:

  ```markdown
  `init` Phase 6 stages and commits `.hivrr.json` whenever a phase changed it — but **only on a
  non-protected branch**. On a protected branch it stages the file and reports, because `core` forbids
  committing directly to protected branches and a setup phase is the wrong place to break that rule.

  This is what makes the "is committed" claim at the top of this document true rather than aspirational.
  A repo whose `.hivrr.json` is untracked resolves every key to its default for every other teammate,
  agent, and CI runner — silently, and looking exactly like a repo that chose those defaults.
  ```

- [ ] **Task 2.3 — Verify and commit**

  ```bash
  jq empty .hivrr.json .claude-plugin/marketplace.json
  jq -r '.plugins[] | ((.skills // [])[], (.commands // [])[])' .claude-plugin/marketplace.json \
    | while read -r p; do [ -e "$p" ] || echo "MISSING $p"; done
  ```

  Expected: no output from either command.

  ```bash
  git add skill/init/SKILL.md skill/init/references/config.md
  git commit -m "fix(init): commit .hivrr.json instead of leaving it untracked"
  ```

**Verification:**

Run: `grep -n "^## Phase 6 — Reconcile the Config" skill/init/SKILL.md`
Expected: one hit — the phase is top-level, not nested under Phase 5.

Run: `grep -n "protected" skill/init/SKILL.md`
Expected: a hit inside the new Phase 6 covering the protected-branch branch of the logic.

Run `init` on a repo whose `.hivrr.json` has **no** `project` key.
Expected: Phase 5 reports nothing and Phase 6 still runs. This is the regression check for the
nesting defect — a boardless repo is the common case, not an edge case.

**Live check** — in a scratch clone with no `.hivrr.json`:

Run `init` while on a feature branch.
Expected: `INIT: .hivrr.json committed on {branch}`, and `git show --stat HEAD` lists **only** `.hivrr.json`.

Run `init` while on `main`.
Expected: `INIT: .hivrr.json staged — main is protected…`, and `git log -1` shows no new commit.

**Exit criteria:** `init` never leaves a changed `.hivrr.json` untracked without saying so, never commits to a protected branch, never pushes, and never stages a second file alongside it. The reconcile runs as a top-level phase, so it is reached on a repo with no project board — verify that case explicitly rather than assuming it.

**Rollback:** `git revert` the commit. Already-committed configs stay committed and are correct.

**PR title suggestion:** `fix(init): commit .hivrr.json instead of leaving it untracked`

---

### Step 3: Worktree foundation — branch: `feat/worktree-foundation`

**Context brief:** `.hivrr.json` already carries two optional objects whose absence is a silent no-op — `project` and `verify` — and `config.md` documents that pattern with a schema block, a field table, per-key precedence, and a failure-modes table. This step adds a third such key, `worktree`, and ships the CLAUDE.md sentence adopting repos need. It wires nothing: no skill enters a worktree yet, which is what makes it safe to merge alone. Note that `.claude/` is already in this repo's `.gitignore`, and `EnterWorktree` creates worktrees under `.claude/worktrees/`, so worktrees never appear in `git status`.

**Dependencies:** None. Independent of Track A.

**Tasks:**

- [ ] **Task 3.1 — Add the `worktree` key to `config.md`**

  Add to the schema block in `skill/init/references/config.md`, after `project`:

  ```json
  "worktree": {
    "enabled": true,
    "carry": [".env", ".claude/settings.local.json"],
    "setup": "npm ci"
  }
  ```

  Add to the field table:

  ```markdown
  | `worktree` | object \| absent | absent — no worktree behavior | `work-issue`, `wave`, `merge-pr`, `init` |
  | `worktree.enabled` | boolean | `false` | `work-issue`, `wave` |
  | `worktree.carry` | string[] | `[]` | `work-issue`, `wave` |
  | `worktree.setup` | string \| `null` | `null` | `work-issue`, `wave` |
  ```

  Add this subsection after `### project`:

  ```markdown
  ### `worktree`

  Isolation for mutating sessions. When `enabled` is true, `work-issue` and `wave` run inside a git
  worktree instead of the shared checkout, so two concurrent sessions cannot stage or commit each
  other's changes. Absent or `false` means every worktree operation is a **silent no-op**.

  Only mutating skills use this. `review-pr`, `audit`, `score-issues`, `group-issues`, and
  `diagnose-failure` are read-only — they cannot collide, so a worktree there is setup cost for no
  benefit.

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

  The `.hivrr.json` key carries the settings; the CLAUDE.md line is what authorizes the tool.
  ```

  Add to the failure-modes table:

  ```markdown
  | `worktree.enabled` true, no CLAUDE.md authorization | **Warn once and continue without a worktree.** Name the missing line. Never fail the workflow — the work is the deliverable. |
  | `worktree.carry` names a path that does not exist | **Warn and continue.** A repo without a `.env` is normal, not an error. |
  | `worktree.setup` exits non-zero | **Warn and continue.** Report the exit code and the command. |
  ```

- [ ] **Task 3.2 — Document the opt-in in `CLAUDE.md`**

  Add a section to `CLAUDE.md` after **Repo configuration**:

  ```markdown
  ## Worktree isolation

  Mutating workflows can run in a git worktree so concurrent sessions in one checkout cannot commit
  each other's changes. It is opt-in per repo and needs two things: `worktree.enabled` in
  `.hivrr.json`, and a line in the repo's own `CLAUDE.md` authorizing the harness tool. One without
  the other silently does nothing.

  Worktrees live under `.claude/worktrees/`, which is already gitignored. They are **not** free —
  untracked files do not travel, and they must be cleaned up. See `skill/init/references/config.md`.

  This repo does not enable it: `agent-plugins` has no dependencies, no `.env`, and its sessions edit
  Markdown rather than running a stack.
  ```

- [ ] **Task 3.3 — Verify and commit**

  ```bash
  jq empty .hivrr.json .claude-plugin/marketplace.json
  jq -r '.plugins[] | ((.skills // [])[], (.commands // [])[])' .claude-plugin/marketplace.json \
    | while read -r p; do [ -e "$p" ] || echo "MISSING $p"; done
  ```

  Expected: no output from either command.

  ```bash
  git add skill/init/references/config.md CLAUDE.md
  git commit -m "feat(init): define the worktree config key and adoption contract"
  ```

**Verification:**

Run: `grep -n "worktree.carry\|worktree.enabled\|EnterWorktree" skill/init/references/config.md CLAUDE.md`
Expected: hits in both files.

**Exit criteria:** The `worktree` key is fully specified with its own failure modes, and the two-part adoption contract is documented. No skill reads the key yet, so merging changes no behavior.

**Rollback:** `git revert` the commit. Nothing consumes the key.

**PR title suggestion:** `feat(init): define the worktree config key and adoption contract`

---

### Step 4: Worktree entry — branch: `feat/worktree-entry`

**Context brief:** `work-issue` Phase 5 creates an `issue/{N}` branch; `wave` Step 2 creates `wave/{min}-{max}-{count}`, forking from `branches.integration` and resuming an existing branch when one is found. Both must now optionally do that work inside a worktree. Two mechanics matter and were verified: `EnterWorktree` branches from `origin/<default-branch>` by default (`worktree.baseRef: fresh`), which is the wrong rung on a ladder repo — and `git checkout -B {branch} origin/{integration}` from inside the worktree re-points it cleanly, making the global setting irrelevant. Separately, git refuses to check one branch out in two worktrees, so resume must find the existing worktree rather than create a second.

**Dependencies:** Step 3 must be merged.

**Tasks:**

- [ ] **Task 4.1 — Add worktree entry to `work-issue`**

  In `skill/work-issue/SKILL.md`, insert before the branch-creation phase:

  ````markdown
  ### Enter a worktree (conditional)

  Read `worktree` from `.hivrr.json`. **Skip this entire section** when `worktree.enabled` is absent
  or false — the session works in the current checkout exactly as before.

  Before entering, confirm the repo's `CLAUDE.md` authorizes it (see **Adopting worktrees** in
  [`config.md`](../init/references/config.md)). If the config key is set but the authorization line is
  absent, warn once and continue **without** a worktree:

  `Worktree: enabled in .hivrr.json but not authorized in CLAUDE.md — continuing in the current checkout`

  **Check for an existing worktree first.** Git refuses to check one branch out in two worktrees, so a
  resumed issue must re-enter its own rather than create a second:

  ```bash
  git worktree list --porcelain
  ```

  - **An entry already holds `issue/{N}`** — re-enter it with `EnterWorktree` using its `path`. Skip
    carry and setup; they ran on creation. Continue to the branch phase.
  - **No entry holds it** — create one with `EnterWorktree` named `issue/{N}`, then continue below.

  **Re-point the branch.** `EnterWorktree` forks from the repository default branch, which on a ladder
  repo is the wrong rung — `branches.integration` is `dev`, not `main`. Re-point rather than depending
  on a global setting adopters would each have to change:

  ```bash
  git fetch origin {integration}
  git checkout -B issue/{N} origin/{integration}
  ```

  **Carry untracked files.** For each path in `worktree.carry`, copy it from the original checkout
  into the worktree — symlink it instead when it is a large directory such as `node_modules`. A path
  that does not exist in the source is a warning, not an error.

  **Run setup.** If `worktree.setup` is non-null, run it once inside the worktree. A non-zero exit is
  a warning: report the command and exit code and continue.

  Display: `Worktree: {path} | branch: issue/{N} | carried: {n} | setup: ok | skipped | failed`
  ````

- [ ] **Task 4.2 — Add worktree entry to `wave`**

  In `skill/wave/SKILL.md` Step 2, add before the existing branch logic:

  ```markdown
  **Worktree (conditional).** Read `worktree` from `.hivrr.json`. When `worktree.enabled` is true and
  the repo's `CLAUDE.md` authorizes it, run this wave inside a worktree named
  `wave/{min}-{max}-{count}` — the same name as the branch.

  Follow the **Enter a worktree** section in `work-issue/SKILL.md`: check `git worktree list
  --porcelain` for an existing entry holding the branch and re-enter it if found, otherwise create one;
  then re-point with `git checkout -B wave/{min}-{max}-{count} origin/{integration}`, carry
  `worktree.carry`, and run `worktree.setup`.

  The resume logic below is unchanged and runs **after** entry — scanning
  `git log origin/{integration}..HEAD` inside the worktree yields the same answer as in the main
  checkout, because it is the same branch.

  When `worktree.enabled` is absent or false, skip this and use the existing branch logic unchanged.
  ```

- [ ] **Task 4.3 — Verify and commit**

  ```bash
  jq empty .hivrr.json .claude-plugin/marketplace.json
  jq -r '.plugins[] | ((.skills // [])[], (.commands // [])[])' .claude-plugin/marketplace.json \
    | while read -r p; do [ -e "$p" ] || echo "MISSING $p"; done
  ```

  Expected: no output from either command.

  ```bash
  git add skill/work-issue/SKILL.md skill/wave/SKILL.md
  git commit -m "feat(work-issue,wave): run mutating sessions in a git worktree"
  ```

**Verification:**

Run: `grep -n "EnterWorktree\|checkout -B" skill/work-issue/SKILL.md skill/wave/SKILL.md`
Expected: hits in both files.

**Live check** — in a scratch repo with a `dev` branch, `worktree.enabled: true`, and the CLAUDE.md line:

Run `/work-issue` on any issue.
Expected: a worktree at `.claude/worktrees/issue/{N}`, and `git log --oneline -1` inside it showing the tip of `dev` — **not** `main`.

Run it again on the same issue.
Expected: it re-enters the existing worktree. No `fatal: 'issue/{N}' is already used by worktree` error.

With `worktree.enabled` true but the CLAUDE.md line removed.
Expected: the warning, and work proceeding in the main checkout.

**Exit criteria:** Both skills enter a worktree only when the key and the authorization agree, re-point to `branches.integration` rather than trusting `baseRef`, re-enter rather than duplicate on resume, and behave exactly as today when the key is absent.

**Rollback:** `git revert` the commit. Existing worktrees stay on disk and are removed with Step 5's cleanup or `git worktree remove` by hand.

**PR title suggestion:** `feat(work-issue,wave): run mutating sessions in a git worktree`

---

### Step 5: Worktree cleanup — branch: `feat/worktree-cleanup`

**Context brief:** `merge-pr` splits branch deletion across two phases. Phase 6 passes `--delete-branch` to the merge command, which removes the **remote** branch only; Phase 9 — Clean Up Branches does the local work, deleting the head branch in Step 1 and pruning stale local branches in Step 2, both subject to `branches.protected`. Only the Phase 9 commands are the ones git blocks, so this step targets Phase 9 and leaves Phase 6 alone. Neither phase is aware of worktrees today, and git makes the interaction hard-fail: a branch checked out in a worktree cannot be deleted, and a manually deleted worktree directory leaves a `prunable` entry that keeps blocking deletion until `git worktree prune` runs. Separately, an abandoned session leaves a worktree that nothing will ever notice; `init` already performs drift detection every run and is the natural place to report them. Nothing here deletes uncommitted work without an explicit decision.

**Dependencies:** Step 3 must be merged. Independent of Step 4 — disjoint files.

**Tasks:**

- [ ] **Task 5.1 — Teach `merge-pr` the cleanup ordering**

  In `skill/merge-pr/SKILL.md` **Phase 9 — Clean Up Branches**, at the top of **Step 1**, before
  `git branch -D {head_branch}`.

  **Not Phase 6.** Phase 6 merges, and its only deletion is the `--delete-branch` /
  `--remove-source-branch` flag on `gh pr merge` / `glab mr merge` — a **remote** deletion, which no
  local worktree blocks. The refusal quoted below is a `git branch -D` error, and that command lives
  in Phase 9 Step 1. Phase 6 evaluates the Branch Deletion Safety rules; Phase 9 acts on them and
  skips when one tripped, so "then delete the branch, applying the existing rules unchanged" only has
  a referent in Phase 9.

  ````markdown
  **Worktree cleanup runs before branch deletion — the order is enforced by git, not chosen.**

  Skip this entirely when `worktree` is absent from `.hivrr.json`, and when the merged PR is a
  promotion (`is_promotion` true) — promotion branches are long-lived rungs and never have worktrees.

  Check whether a worktree holds the head branch:

  ```bash
  git worktree list --porcelain
  ```

  When one does, work in this order. Skipping a step makes the next one fail:

  1. **Leave it.** If this session is inside that worktree, exit with `ExitWorktree` using
     `action: "remove"`. A session cannot remove the worktree it is standing in.

  2. **Remove it.** For a worktree this session did not create:

     ```bash
     git worktree remove {path}
     ```

     This **refuses when the worktree has uncommitted or untracked files**:

     ```
     fatal: '{path}' contains modified or untracked files, use --force to delete it
     ```

     That refusal is a safety feature. **Stop and ask** — report the path and what is uncommitted, and
     force only on an explicit answer. Never pass `--force` automatically: the PR merged, so anything
     still uncommitted there is work that never reached it.

  3. **Prune.** A worktree whose directory was deleted by hand leaves a `prunable` entry that keeps
     blocking branch deletion:

     ```bash
     git worktree prune
     ```

  4. **Then delete the branch,** applying the existing `branches.protected` rules unchanged.

  Attempting deletion before this sequence produces:

  ```
  error: cannot delete branch '{branch}' used by worktree at '{path}'
  ```

  Every step warns and continues on failure. The PR has already merged; cleanup failing must not be
  reported as a failed merge. Report what was left behind so it can be cleaned by hand.

  Display: `Worktree: removed {path}` | `Worktree: left in place — uncommitted work` | nothing when none.
  ````

  **Then cover Step 2 of the same phase.** Step 2 prunes stale local branches with `git branch -D` in
  a loop, and any candidate may be held by *another* session's worktree — that session is still
  working, so its worktree must not be touched. The ordered candidate list has two checks today —
  `1 — Is it protected?` and `2 — Did it actually merge?` — so this appends as **check 3**, leaving
  their numbering alone. It is a local command and the checks short-circuit on the first `keep`, so
  running it ahead of check 2 would save a network call; that is a fair optimization but renumbers an
  existing check, so it is not bundled here:

  ````markdown
  **3 — Is it held by a worktree?** A branch checked out in any worktree cannot be deleted, and the
  worktree may belong to a live session:

  ```bash
  git worktree list --porcelain
  ```

  Held → **keep it** and report as `kept: {branch} (held by worktree at {path})`. Never remove a
  worktree this skill did not create in order to delete a branch; the head branch handled above is
  the only worktree this phase acts on.
  ````

  This check is skipped along with the rest when `worktree` is absent from `.hivrr.json`.

- [ ] **Task 5.2 — Report orphan worktrees from `init`**

  Add a **new top-level phase** to `skill/init/SKILL.md`, after the Phase 6 added by Step 2.

  Like Phase 6, it must be a sibling rather than a step inside Phase 5, which skips entirely when
  `project` is absent. Nesting it there would mean a repo that configures `worktree` but has no
  project board never hears about its orphans — and those two keys are independent.

  ````markdown
  ## Phase 7 — Report Orphan Worktrees

  **Skip when `worktree` is absent from `.hivrr.json`.** This is the phase's only gate.

  An abandoned or crashed session leaves a worktree that nothing else will notice, and each one holds
  a branch that cannot be deleted while it exists. `init` runs on every command, which makes it the
  cheapest place to surface them.

  ```bash
  git worktree list --porcelain
  ```

  For each worktree other than the main checkout, report those that are **prunable** (directory gone,
  metadata stale) or whose branch is already merged into `branches.integration`:

  ```bash
  git branch --merged origin/{integration} --format='%(refname:short)'
  ```

  ```
  INIT: 2 orphan worktree(s)
        .claude/worktrees/issue/41  [issue/41]  branch merged
        .claude/worktrees/issue/38  [issue/38]  prunable
        Clean up: git worktree prune, or git worktree remove {path}
  ```

  **Report only — never remove.** An orphan may hold the only copy of unfinished work, and `init` is
  setup, not cleanup. Offer the commands and let the user run them.

  Emit `INIT: worktrees ok` when there are none, and nothing at all when `worktree` is absent.
  ````

- [ ] **Task 5.3 — Verify and commit**

  ```bash
  jq empty .hivrr.json .claude-plugin/marketplace.json
  jq -r '.plugins[] | ((.skills // [])[], (.commands // [])[])' .claude-plugin/marketplace.json \
    | while read -r p; do [ -e "$p" ] || echo "MISSING $p"; done
  ```

  Expected: no output from either command.

  ```bash
  git add skill/merge-pr/SKILL.md skill/init/SKILL.md
  git commit -m "feat(merge-pr,init): clean up worktrees and report orphans"
  ```

**Verification:**

Run: `grep -n "worktree prune\|ExitWorktree" skill/merge-pr/SKILL.md`
Expected: hits for both, inside **Phase 9** — confirm with `sed -n '/^## Phase 9/,/^## Phase 10/p'`.

Run: `sed -n '/^## Phase 6 — Merge/,/^## Phase 7/p' skill/merge-pr/SKILL.md | grep -c worktree`
Expected: `0`. Phase 6 deletes only the remote branch and must stay untouched.

Run: `grep -n "held by worktree" skill/merge-pr/SKILL.md`
Expected: one hit, in Phase 9 Step 2's candidate checks.

Run: `grep -n "^## Phase 7 — Report Orphan Worktrees" skill/init/SKILL.md`
Expected: one hit — top-level, not nested under Phase 5.

Run: `grep -n "orphan" skill/init/SKILL.md`
Expected: a hit inside the new Phase 7.

**Live check** — in a scratch repo:

Create a worktree on `issue/99`, commit and merge a PR from it, then run `merge-pr`.
Expected: the worktree is removed, then the branch is deleted, with no `cannot delete branch` error.

Leave an uncommitted file in a worktree and run `merge-pr`.
Expected: it stops and asks. The worktree still exists and the file is intact.

Delete a worktree directory with `rm -rf`, then run any command.
Expected: `INIT: 1 orphan worktree(s) … prunable`, and nothing removed.

**Exit criteria:** `merge-pr` Phase 9 follows exit → remove → prune → delete, keeps any stale branch held by another worktree, stops rather than forcing when uncommitted work exists, and never reports a merge as failed because cleanup failed. Phase 6 is unchanged. `init` reports orphans from a top-level phase that runs regardless of whether a project board is configured, and removes nothing.

**Rollback:** `git revert` the commit. Worktrees accumulate again and branch deletion fails loudly rather than silently — no data is at risk.

**PR title suggestion:** `feat(merge-pr,init): clean up worktrees and report orphans`

---

## Out of scope

- **Worktrees for read-only skills.** Decision **C**. `review-pr`, `audit`, `score-issues`,
  `group-issues`, and `diagnose-failure` cannot collide.
- **Changing `worktree.baseRef` in `~/.claude/settings.json`.** Decision **F** makes it irrelevant, and
  it is per-user global state this repo deliberately keeps out of per-repo config.
- **Container network naming.** `CLAUDE.md` documents `CONTAINER_NETWORK={directory_name}_default`, and
  a worktree changes the directory name — arguably an improvement, since sessions stop sharing a
  network. But `.env` does not travel to a worktree except via `worktree.carry`, so the value carried
  in would be the *old* network name. Resolving this needs a decision about whether the name should be
  derived or pinned, and it belongs with the container work rather than here.
- **Coordinating with the sub-issue plan.** `docs/plans/2026-08-21-github-sub-issues.md` Step 1 adds
  an `issues` key to the same three anchors this plan's Step 3 touches: the `config.md` schema block,
  the field table, and a `### {key}` subsection after `### project`. It also adds a row to the
  `README.md` config table and a paragraph to `CLAUDE.md`. The two are independent in substance and
  can land in either order, but **whichever lands second appends after the key the first one added**,
  not after `project` — read the file before inserting rather than trusting the anchor named here.
  Decision **E** already assumes `issues` exists as a precedent; it does not depend on it having
  landed.
- **Automatic orphan removal.** Decision **H**.
- **`git add -A` in user repos' own scripts or CI.** Step 1 fixes the skills this repo ships. Anything
  a consuming repo runs itself is outside the plugin.

---

## Self-review

| Check | Result |
|---|---|
| Spec coverage | All three items raised — blanket staging, cleanup, config sync — have a step. Isolation itself spans Steps 3–5. |
| Phase targeting | Verified against the current files rather than assumed: `init` Phase 5 skips when `project` is absent, so Steps 2 and 5 add **top-level** Phases 6 and 7. `merge-pr` Phase 6 deletes only the remote branch (`grep -c 'git branch -D'` → `0`); Phase 9 does the local deletion in both its steps (→ `2`), so Step 5 targets Phase 9. |
| Placeholder scan | No TBD/TODO/vague steps. Every command is literal. |
| Name consistency | `worktree.enabled`, `worktree.carry`, `worktree.setup` used identically across Steps 3, 4, and 5. Branch and worktree names match (`issue/{N}`, `wave/{min}-{max}-{count}`). |
| Allowed APIs | Every git mechanic was executed on 2026-08-21: the delete/double-checkout refusals, the dirty-remove refusal, the prunable-then-prune sequence, and the `checkout -B` re-point. Tool contracts quoted from `EnterWorktree`/`ExitWorktree`. |
| Commit coverage | Each of the five steps ends with a staged, scoped commit — none using `git add -A`. |
| Ordering | Track A serial (1→2, per decision **B**). Track B: 3 gates 4 and 5, which are parallel. No cycles. |

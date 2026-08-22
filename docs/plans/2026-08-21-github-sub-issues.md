# GitHub Sub-Issue Support — Implementation Plan

> **For agentic workers:** Use the `work-issue` skill to implement this plan step-by-step.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make issue hierarchy a first-class, structured signal across `planner`, `dev`, and `dispatcher` — so parent/child relationships that today survive only as prose in issue bodies become data the skills read and write.

**Architecture:** One new provider-reference section in `session/references/github.md` defines every sub-issue operation; one new optional `.hivrr.json` key (`issues`) gates them. Consumers read hierarchy instead of regexing bodies (`group-issues`, `score-issues`, `work-issue`) or write it (`planning`, `merge-pr`). Absent config is a silent no-op, matching the existing `project` convention exactly. GitLab and Linear get explicit degradation notes rather than silent divergence.

**Tech Stack:** Markdown skill definitions, `gh api graphql` (mutations and reads), `gh api` REST (alternate path), `jq`.

---

## Context: what was verified, and how

Every API claim below was executed live against `hivrr/agent-plugins` on 2026-08-21 using three throwaway issues (#125 parent, #126/#127 children), which were linked, reprioritized, unlinked, and then **deleted** (`410 Gone`). Nothing was left behind. The findings that shaped this plan are the ones that contradicted the documentation-level expectation.

### The API exists and is GA — but `gh` has no first-class support

| Surface | Status |
|---|---|
| GraphQL `parent`, `subIssues`, `subIssuesSummary` on `Issue` | Works, **no feature header needed** |
| GraphQL `addSubIssue` / `removeSubIssue` / `reprioritizeSubIssue` | Present in schema, all three executed successfully |
| REST `GET`/`POST /repos/{o}/{r}/issues/{n}/sub_issues` | Works |
| REST `DELETE /repos/{o}/{r}/issues/{n}/sub_issue` | Works — note the **singular** path segment |
| `gh issue` subcommand for sub-issues | **Does not exist** |
| `gh issue create --parent` | **Does not exist** |
| `gh issue view --json parent` / `subIssues` | **Not in the field list** — dumped and confirmed |

Consequence: every operation is raw `gh api`. That diverges from `github.md`, which is otherwise clean `gh` commands — but `config.md` already established the `gh api graphql` precedent for Projects v2, so this extends an existing pattern rather than inventing one.

### Fixed decisions (do not re-litigate)

| ID | Decision | Grounds |
|----|----------|---------|
| **A** | **GraphQL is the canonical path.** REST is documented only as a fallback. | One aliased query resolves every ID needed; mutations return the updated `subIssuesSummary`, so verification is free. REST `POST` returns the *parent*, so you cannot confirm which child you linked from the response. |
| **B** | **Linking is check-then-add, never blind-add.** | Re-adding an already-linked child returns **`422`**, not a no-op. This breaks the `project item-add` convention ("adding an item that is already on the board is harmless"). Assuming idempotence here produces spurious failures on every resume path. |
| **C** | **`merge-pr` closes the parent explicitly when the last child closes.** | Verified: with both children closed, the parent sat at `{total:2, completed:2, percentCompleted:100}` and `state: OPEN`, `stateReason: null`. GitHub does **not** auto-close parents. The rollup is display-only. |
| **D** | **`issues` absent from `.hivrr.json` ⇒ silent no-op.** Not a warning. | Mirrors the `project` key exactly. Most repos will not adopt hierarchy; announcing that on every invocation is noise. |
| **E** | **Epics are created only at Complex tier, or at ≥ `epicThreshold` issues.** | A parent wrapping two issues is bookkeeping overhead with no board benefit. |
| **F** | **A sub-issue has exactly one parent.** Re-parenting is remove-then-add. | Enforced by the API — the `422` message states it outright. |
| **G** | **All sub-issue failures warn and continue.** Never abort the calling workflow. | Identical reasoning to the board rule in `config.md`: hierarchy is a reporting surface, and the issues/PR are the deliverable. |

**Note on this repo, following from decision C:** the epic rollup is display-only here in a second
sense. This repo has no Projects v2 board — see **Repo configuration** in `CLAUDE.md`, where the
absence is recorded as a decision — so there is no board for a rollup to surface on. The hierarchy
itself is unaffected: parents, children, and `subIssuesSummary` are all real and readable through
the tracker, and `merge-pr` still closes a satisfied parent. Only the board view is missing.

### The three-identifier trap

This is the single most likely implementation defect, so it is stated once here and enforced in every task.

One issue carries three distinct identifiers. Verified on the throwaway parent #126:

| Kind | Example value | Consumed by |
|---|---|---|
| number | `126` | `gh issue` commands, issue bodies, humans |
| `databaseId` | `5218577347` | REST `sub_issue_id`, `before_id`, `after_id` |
| node `id` | `I_kwDORlvmmc8AAAABNw0r_g` | GraphQL `issueId`, `subIssueId` |

Passing the **number** where a `databaseId` belongs returns a bare `404 Not Found` with no hint that the field wanted a different identifier — indistinguishable from a deleted issue or a scope problem. Decision **A** exists largely to avoid this: the GraphQL path never touches `databaseId`.

### Two pre-existing gaps found while running `init`

Both are adjacent to this work, both are real, and **neither is in scope for this plan.** They are recorded so they are not rediscovered as regressions.

1. **`.hivrr.json` cannot override `issueTracker`.** The schema has `provider` but no tracker key. Global `providerConfig` on this machine is `{"repoProvider":"gitlab","issueTracker":"gitlab"}` while `.hivrr.json` declares `"provider":"github"` — so `session` Phase 2 resolves the repo correctly and the *tracker* incorrectly, loading `gitlab.md` for a repo whose issues are demonstrably GitHub. This is precisely the bug `.hivrr.json` was introduced to fix, solved for one key and not the other. **Sub-issue support is tracker-gated, so this gap will suppress it on exactly the repo it was built for.**
2. **This repo records `verify.test: null, verify.lint: null`** with `detectedFrom: []`, while `README.md:172-179` and `CLAUDE.md` define real structural verification commands. `init` Phase 4's detection table has no row that matches "structural checks defined in the README", so it correctly re-detects nothing and writes `null`. The result is that `work-issue` skips verification on a repo whose `CLAUDE.md` says *"Do not skip verification on it."*

---

## Complexity

**Complex** — spans three plugins (`dev`, `planner`, `dispatcher`), needs strict ordering (every consumer depends on the reference block existing), and splits into independently reviewable PRs.

---

## File Structure

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `skill/session/references/github.md` | Canonical sub-issue operations — the only place commands are defined |
| Modify | `skill/session/references/gitlab.md` | Explicit "not supported" degradation note |
| Modify | `skill/session/references/linear.md` | Explicit "native, not via this path" note |
| Modify | `skill/init/references/config.md` | `issues` key: schema row, field docs, failure modes |
| Modify | `skill/group-issues/SKILL.md:67` | Replace prose-parsed dependency edges with structured hierarchy |
| Modify | `skill/score-issues/SKILL.md` Phase 2 | Exclude parent epics from scoring |
| Modify | `skill/work-issue/SKILL.md` Phase 3 | Warn when handed a parent with open children |
| Modify | `skill/planning/SKILL.md` Phase 6/9/10 | Propose and create the epic + attach children |
| Modify | `skill/merge-pr/SKILL.md` Phase 7 | Close parent when its last child closes |
| Modify | `README.md:118-140` | Document the `issues` key in the config table |
| Modify | `CLAUDE.md` | Note hierarchy in the repo-configuration section |

---

## Blueprint

**Steps:** 4 | **Serial:** Steps 1, 4 | **Parallel:** Steps 2 and 3 (both after Step 1)

```
Step 1 ──> Step 2 ──┐
       └──> Step 3 ──┴──> Step 4
            [PARALLEL]
```

Step 1 is the hard gate: Steps 2 and 3 both consume commands that only exist once Step 1 lands. Steps 2 and 3 touch disjoint files and share no output. Step 4 documents behavior that must already be real.

| Step | Points | Files touched |
|---|---|---|
| Step 1 — Foundation | 5 (L) | 4 |
| Step 2 — Read-side consumers | 3 (M) | 3 |
| Step 3 — Write-side consumers | 5 (L) | 2 |
| Step 4 — Documentation sync | 2 (S) | 2 |

---

### Step 1: Foundation — provider reference and config schema — branch: `feat/sub-issues-foundation`

**Context brief:** `skill/session/references/github.md` is the single place provider commands are defined; every skill is instructed to use commands "from the loaded reference" rather than inlining its own. `skill/init/references/config.md` is the `.hivrr.json` contract — it defines the schema block, a field table, per-key precedence, and a failure-mode table, and it already documents an identical optional-key pattern for `project` (absent ⇒ silent no-op). This step adds sub-issue operations to the GitHub reference, degradation notes to the other two providers, and the `issues` key to the config contract. It writes **no consumer logic** — nothing calls these commands yet, which is what makes the step independently safe to merge.

**Dependencies:** None. This is the root step.

**Tasks:**

- [ ] **Task 1.1 — Add the `issues` key to `config.md`**

  Add to the schema block in `skill/init/references/config.md` (the JSON example under `## Schema`), after the `project` object:

  ```json
  "issues": {
    "hierarchy": true,
    "epicThreshold": 4
  }
  ```

  Add these rows to the field table (`| Key | Type | Default when absent | Read by |`):

  ```markdown
  | `issues` | object \| absent | absent — all hierarchy operations are silent no-ops | `planning`, `work-issue`, `merge-pr`, `score-issues`, `group-issues` |
  | `issues.hierarchy` | boolean | `false` | all hierarchy operations |
  | `issues.epicThreshold` | number | `4` | `planning` |
  ```

  Add this subsection after the existing `### project` subsection:

  ```markdown
  ### `issues`

  Issue-hierarchy wiring. `hierarchy` opts the repo into GitHub sub-issues; when it is `false` or the
  `issues` key is absent, every hierarchy operation is a **silent no-op** — never a warning. This is
  the same contract as `project`, and for the same reason: most repos will not adopt hierarchy, and
  announcing that on every invocation is noise.

  `epicThreshold` is the issue count at or above which `planning` proposes a parent epic. Below it,
  planning emits a flat set — a parent wrapping two issues is bookkeeping with no board benefit.

  **`hierarchy` is GitHub-only.** GitLab has no equivalent outside Premium epics and Linear has its
  own native parent/sub-issue model that does not route through these commands. When the resolved
  provider is not `github`, treat `hierarchy` as `false` regardless of its configured value.
  ```

- [ ] **Task 1.2 — Add the Sub-Issues section to `github.md`**

  Append to `skill/session/references/github.md`, after the `## Issues` section and before `## Pull Requests`. Every command below was executed successfully against the live API on 2026-08-21.

  ````markdown
  ---

  ## Sub-Issues

  `gh` has **no** first-class support for sub-issues — there is no `gh issue` subcommand, no
  `--parent` flag on `gh issue create`, and `parent`/`subIssues` are absent from the
  `gh issue view --json` field list. Every operation here is `gh api`.

  **GraphQL is the canonical path.** It resolves every identifier in one query and returns the
  updated summary from each mutation, so a successful call is self-verifying. REST is documented at
  the end as a fallback.

  ### The three identifiers

  One issue carries three. Using the wrong one is the most common failure here:

  | Kind | Example | Used by |
  |---|---|---|
  | number | `126` | `gh issue` commands, issue bodies |
  | `databaseId` | `5218577347` | REST `sub_issue_id`, `before_id`, `after_id` |
  | node `id` | `I_kwDORlvmmc8AAAABNw0r_g` | GraphQL `issueId`, `subIssueId` |

  Passing a **number** where REST wants a `databaseId` returns a bare `404 Not Found` — it does not
  say the identifier was the wrong kind. The GraphQL path avoids `databaseId` entirely.

  ### Resolve node IDs

  Resolve every issue you intend to link in **one** query using aliases, rather than one query per
  issue:

  ```
  gh api graphql -f query='
    query($o:String!,$r:String!,$p:Int!,$c:Int!){
      repository(owner:$o,name:$r){
        parent: issue(number:$p){ id }
        child:  issue(number:$c){ id }
      } }' -f o={OWNER} -f r={REPO} -F p={PARENT} -F c={CHILD}
  ```

  ### Read hierarchy

  ```
  gh api graphql -f query='
    query($o:String!,$r:String!,$n:Int!){
      repository(owner:$o,name:$r){
        issue(number:$n){
          parent { number title state }
          subIssues(first:100){ totalCount nodes{ number title state } }
          subIssuesSummary { total completed percentCompleted }
        } } }' -f o={OWNER} -f r={REPO} -F n={N}
  ```

  `parent` is `null` for a top-level issue. `subIssuesSummary.total` is `0` for a leaf.
  These two facts are how every consumer distinguishes an epic from a workable issue.

  ### Link a child to a parent

  **Check first — this is not idempotent.** Re-adding an already-linked child returns `422`
  (`Issue may not contain duplicate sub-issues and Sub issue may only have one parent`), unlike
  `gh project item-add`, which is safe to repeat. Read the child's `parent` before adding:

  - `parent` is `null` → add it.
  - `parent` is already the intended parent → **already linked, skip.** Not an error.
  - `parent` is a *different* issue → warn and skip. A sub-issue has exactly one parent;
    re-parenting is an explicit remove-then-add, never an implicit overwrite.

  ```
  gh api graphql -f query='
    mutation($p:ID!,$c:ID!){
      addSubIssue(input:{issueId:$p, subIssueId:$c}){
        issue { number subIssuesSummary { total completed } }
        subIssue { number title }
      } }' -f p={PARENT_NODE_ID} -f c={CHILD_NODE_ID}
  ```

  The response names both issues and the updated summary — use it as the confirmation. Do not
  re-query to verify.

  ### Unlink a child

  ```
  gh api graphql -f query='
    mutation($p:ID!,$c:ID!){
      removeSubIssue(input:{issueId:$p, subIssueId:$c}){
        issue { number subIssuesSummary { total completed } }
      } }' -f p={PARENT_NODE_ID} -f c={CHILD_NODE_ID}
  ```

  ### Reorder children

  `reprioritizeSubIssue` moves one child relative to another. Order is display-only — it does not
  imply dependency, and no skill should read it as one.

  ### Closing behavior

  **Closing every child does not close the parent.** Verified: with both children closed the parent
  reported `{total:2, completed:2, percentCompleted:100}` and remained `state: OPEN` with
  `stateReason: null`. The rollup is a display value; nothing acts on it. A skill that wants the
  parent closed must close it explicitly with the **Close** command above.

  ### REST fallback

  Use only when GraphQL is unavailable. These take `databaseId`, not numbers:

  ```
  gh api repos/{OWNER}/{REPO}/issues/{N}/sub_issues                                  # list
  gh api --method POST repos/{OWNER}/{REPO}/issues/{N}/sub_issues -F sub_issue_id={DB_ID}
  gh api --method DELETE repos/{OWNER}/{REPO}/issues/{N}/sub_issue -F sub_issue_id={DB_ID}
  ```

  Note the asymmetry: `GET`/`POST` use plural `sub_issues`; `DELETE` uses **singular** `sub_issue`.
  A typo there returns the same bare `404` as a wrong identifier. `POST` returns the **parent**
  issue, not the child, so it cannot confirm which child was linked.

  ### Gating

  Every operation in this section is gated on `issues.hierarchy` in `.hivrr.json`. When it is
  `false` or absent, these commands are **not run at all** and the calling skill continues silently.
  Every failure here warns and continues — hierarchy is a reporting surface, and the issue or PR is
  the deliverable.
  ````

- [ ] **Task 1.3 — Add degradation notes to the other two providers**

  Append to `skill/session/references/gitlab.md`:

  ```markdown
  ---

  ## Sub-Issues

  **Not supported.** GitLab has no free-tier equivalent of GitHub sub-issues; the nearest analogue
  is Premium-tier epics, which have a different data model and are out of scope.

  When the resolved provider is `gitlab`, treat `issues.hierarchy` as `false` regardless of its
  configured value. Every hierarchy operation is a silent no-op, and skills that consume hierarchy
  fall back to their documented pre-hierarchy behavior — for `group-issues`, that means parsing
  `Depends on #N` and `Part of #N` from issue bodies.
  ```

  Append to `skill/session/references/linear.md`:

  ```markdown
  ---

  ## Sub-Issues

  Linear has a **native** parent/sub-issue model. It does not route through the GitHub commands in
  `github.md`, and `issues.hierarchy` does not govern it.

  Wiring Linear hierarchy into the hierarchy-consuming skills is deliberately out of scope. Until it
  is done, treat `issues.hierarchy` as `false` when `ISSUE_TRACKER=linear` so that no skill emits
  GitHub-shaped commands against a Linear tracker.
  ```

- [ ] **Task 1.4 — Verify and commit**

  Run the repo's structural verification (`README.md:172-179`):

  ```bash
  jq empty .hivrr.json .claude-plugin/marketplace.json
  jq -r '.plugins[] | ((.skills // [])[], (.commands // [])[])' .claude-plugin/marketplace.json \
    | while read -r p; do [ -e "$p" ] || echo "MISSING $p"; done
  ```

  Expected: no output from either command.

  Confirm every fenced block in the new section is balanced — the `github.md` addition nests fenced
  blocks inside a fenced block, which is the most likely place for this step to break rendering.
  Match indented fences too: the nested inner blocks sit two spaces in, so a pattern anchored at
  column zero would skip exactly the ones this check exists to count:

  ```bash
  awk '/^ *`{3,}/{n++} END{print n" fence lines — must be even"}' skill/session/references/github.md
  ```

  Expected: an even count.

  ```bash
  git add skill/session/references/github.md skill/session/references/gitlab.md \
          skill/session/references/linear.md skill/init/references/config.md
  git commit -m "feat(session,init): define sub-issue operations and the issues config key"
  ```

**Verification:**

Run: `grep -c "addSubIssue\|removeSubIssue\|subIssuesSummary" skill/session/references/github.md`
Expected: `3` or greater.

Run: `grep -n "issues.hierarchy" skill/init/references/config.md skill/session/references/gitlab.md skill/session/references/linear.md`
Expected: at least one hit in each of the three files.

**Exit criteria:** The three provider references and the config contract describe sub-issue behavior completely. No skill calls any of it yet, so merging this changes no runtime behavior.

**Rollback:** `git revert` the commit. Nothing consumes these commands, so the revert is inert.

**PR title suggestion:** `feat(session,init): define sub-issue operations and the issues config key`

---

### Step 2: Read-side consumers — branch: `feat/sub-issues-read`

**Context brief:** Three skills currently infer issue relationships from unstructured text or ignore them. `group-issues/SKILL.md:67` builds dependency edges by regexing bodies for `Depends on #N` / `Blocked by #N` / `Part of #N`. `score-issues` Phase 2 filters candidates by board status but has no concept of an unworkable parent. `work-issue` Phase 3 fetches issue data and will happily implement an epic as a single PR. All three now have structured hierarchy available from Step 1. This step only **reads** — it creates and mutates nothing, which is why it can run in parallel with Step 3.

**Dependencies:** Step 1 must be merged.

**Tasks:**

- [ ] **Task 2.1 — `group-issues`: prefer structured hierarchy over prose**

  In `skill/group-issues/SKILL.md`, replace the body of **Step 1 — Build the dependency edges** (`:67`) with:

  ```markdown
  **Step 1 — Build the dependency edges.** Use structured hierarchy first, prose second.

  When `issues.hierarchy` is enabled, read each candidate's `parent` and `subIssues` using the
  **Read hierarchy** command from the loaded reference. This yields edges that are *data*, not
  inference:

  - Two issues sharing a `parent` are **siblings** — strong candidates for one wave.
  - An issue whose `parent` is also in the candidate list belongs with it.
  - An issue with `subIssuesSummary.total > 0` is an **epic**. Never group an epic with its own
    children; drop it from grouping entirely and record it in `excluded` as `Epic`.

  Then read each body for explicit statements: `Depends on #N`, `Blocked by #N`, `Closes #N`,
  `Part of #N`, or prose naming another issue as a prerequisite. Prose edges **supplement**
  structured ones — they never override them. Treat an unstated dependency as absent; do not infer
  one from topic similarity.

  When `issues.hierarchy` is disabled, absent, or the provider is not `github`, use prose only —
  the behavior this skill had before hierarchy existed.
  ```

  Extend the `excluded` contract in Phase 4 so the new exclusion reason is machine-readable. Replace
  the paragraph at `skill/group-issues/SKILL.md:131` in full — both of its current sentences become
  false once epics can populate the key:

  ```markdown
  `excluded` maps issue number strings to the reason that caused the exclusion — a board status
  (`In Progress`, `Done`) or `Epic` for a parent dropped by Phase 3 Step 1. **Omit the key entirely
  when nothing was excluded.** Its presence means something was filtered; it no longer implies that
  the board filter specifically ran, because an epic is excluded whether or not a board is
  configured.
  ```

  **Widen the emission trigger too.** `:127` currently reads *"When Phase 2 excluded issues, add the
  `excluded` key"* — but epic exclusion happens in **Phase 3** Step 1, so under the current wording it
  never reaches the JSON. Change it to *"When Phase 2 or Phase 3 excluded issues"*.

- [ ] **Task 2.2 — `score-issues`: exclude epics**

  In `skill/score-issues/SKILL.md` Phase 2, after the board-status exclusion paragraph, add:

  ```markdown
  **Exclude parent epics.** An issue with children is not workable — dispatching an agent at it
  proposes implementing a container rather than a change. When `issues.hierarchy` is enabled, read
  `subIssuesSummary.total` for each candidate using the **Read hierarchy** command from the loaded
  reference and drop any issue whose total is greater than zero. Record it in `excluded` as `Epic`.

  Skip this entirely when `issues.hierarchy` is disabled or absent. If the hierarchy query fails,
  warn and score every issue — the same fallback as an unconfigured board. Losing the filter
  degrades the result; aborting destroys it.
  ```

  **Then rewrite the `excluded` contract, exactly as Task 2.1 does for `group-issues`.** This is not
  optional cleanup: `score-issues` and `group-issues` emit the same `excluded` shape in their
  `RESULT_JSON`, and adding `Epic` to one skill's values while leaving the other skill's contract text
  untouched is how the two silently diverge. `skill/score-issues/SKILL.md:110` currently reads:

  > `excluded` maps issue number strings to the **board status** that caused the exclusion. **Omit the
  > key entirely when nothing was excluded** — including when no board is configured — so **its
  > presence always means the board filter actually ran**.

  Both bolded claims become false — the values are no longer only board statuses, and the key can now
  appear on a repo with no board at all. A dispatcher reading presence-implies-board-ran would get a
  correct answer from `group-issues` and a wrong one from `score-issues`. Replace it with the same
  wording used in Task 2.1, changing only the phase reference:

  ```markdown
  `excluded` maps issue number strings to the reason that caused the exclusion — a board status
  (`In Progress`, `Done`) or `Epic` for a parent with children. **Omit the key entirely when nothing
  was excluded.** Its presence means something was filtered; it no longer implies that the board
  filter specifically ran, because an epic is excluded whether or not a board is configured.
  ```

  The two paragraphs must stay byte-identical apart from that phase reference. If they drift again,
  the duplication check from the verify-extraction plan is the mechanism that would catch it.

  **Finally, fix the display label in both skills.** `skill/score-issues/SKILL.md:48` and
  `skill/group-issues/SKILL.md:47` both print:

  ```
  Excluded (board): #123 In Progress, #456 Done
  ```

  Once epics populate the same list the `(board)` parenthetical misreports the reason on screen even
  where the JSON is right. Drop it and carry the reason per entry, which the `excluded` map already
  holds:

  ```
  Excluded: #123 In Progress, #456 Done, #789 Epic
  ```

- [ ] **Task 2.3 — `work-issue`: warn when handed an epic**

  In `skill/work-issue/SKILL.md` Phase 3, after the **Issue details** paragraph, add:

  ```markdown
  **Check for hierarchy.** When `issues.hierarchy` is enabled, read `parent` and `subIssuesSummary`
  for each issue using the **Read hierarchy** command from the loaded reference.

  If an issue has `subIssuesSummary.total > 0` with at least one child still open, it is an epic.
  Implementing it directly produces one oversized PR that closes a container rather than its
  contents. Display:

  `Epic: #{number} has {open}/{total} open sub-issues — work those instead: {child_numbers}`

  Then stop and ask which children to work, unless `--auto` is set. Under `--auto`, substitute the
  **open children** for the epic in `issue_numbers` and continue — do not abort, and do not
  implement the epic.

  An epic whose children are all closed is workable as an ordinary issue; it is likely a
  documentation or wrap-up task.
  ```

- [ ] **Task 2.4 — Verify and commit**

  ```bash
  jq empty .hivrr.json .claude-plugin/marketplace.json
  jq -r '.plugins[] | ((.skills // [])[], (.commands // [])[])' .claude-plugin/marketplace.json \
    | while read -r p; do [ -e "$p" ] || echo "MISSING $p"; done
  ```

  Expected: no output from either command.

  ```bash
  git add skill/group-issues/SKILL.md skill/score-issues/SKILL.md skill/work-issue/SKILL.md
  git commit -m "feat(group-issues,score-issues,work-issue): read issue hierarchy as structured data"
  ```

**Verification:**

Run: `grep -n "Read hierarchy" skill/group-issues/SKILL.md skill/score-issues/SKILL.md skill/work-issue/SKILL.md`
Expected: at least one hit in each of the three files.

Run: `grep -n "Epic" skill/group-issues/SKILL.md skill/score-issues/SKILL.md`
Expected: hits in both, covering the `excluded` reason.

**Exit criteria:** All three skills gate on `issues.hierarchy`, degrade to their pre-hierarchy behavior when it is off, and warn-and-continue when a hierarchy query fails. No skill mutates hierarchy.

**Rollback:** `git revert` the commit. The three skills return to prose-only inference, which is their current behavior.

**PR title suggestion:** `feat(group-issues,score-issues,work-issue): read issue hierarchy as structured data`

---

### Step 3: Write-side consumers — branch: `feat/sub-issues-write`

**Context brief:** Two skills should *create* hierarchy. `planning` Phase 6 already produces sized issues carrying a **Dependencies** field, and at Complex tier already produces a multi-PR Blueprint — but Phase 10 creates every issue flat, so that structure exists only in prose and is lost at creation time. `merge-pr` Phase 7 closes `linked_issues` parsed from the PR body and then marks them Done on the board; it has no concept of a parent that is now fully satisfied. This step is the one with real behavioral risk, because it mutates the tracker. Every mutation is gated, checked before writing, and warns rather than aborting.

**Dependencies:** Step 1 must be merged. Independent of Step 2 — disjoint files, no shared output.

**Tasks:**

- [ ] **Task 3.1 — `planning`: propose the epic in the breakdown**

  In `skill/planning/SKILL.md` Phase 6, after the issue-attribute list (`Title` / `Body` / `Size` /
  `Labels` / `Dependencies`), add:

  ```markdown
  **Propose a parent epic** when `issues.hierarchy` is enabled **and** either the complexity tier is
  Complex or the breakdown contains at least `issues.epicThreshold` issues (default `4`). Below that
  bar, emit a flat set — a parent wrapping two issues is bookkeeping with no board benefit.

  The epic is an issue like any other, with:
  - **Title**: the feature name, not an action ("Email verification", not "Add email verification")
  - **Body**: the goal, the architecture summary, and a link to the plan doc — no acceptance criteria
    of its own, because its children carry those
  - **Labels**: the feature/priority labels, **no size label** — an epic has no size
  - **Size**: none

  At Complex tier the epic corresponds to the Blueprint as a whole, and each Blueprint step maps to
  one child.
  ```

  In Phase 9, extend the checkpoint display so the user approves the hierarchy rather than
  discovering it after creation:

  ```markdown
  Issues:
    EPIC {epic_title}
      1. [{size}] {title}
         {one-line summary}
         depends on: none

      2. [{size}] {title}
         {one-line summary}
         depends on: #1
    ...

  Ready to create 1 epic + {n} issues in GitHub{linear_note}.
  ```

  When no epic is proposed, the display is unchanged.

- [ ] **Task 3.2 — `planning`: create and attach in Phase 10**

  In `skill/planning/SKILL.md` Phase 10, insert before the existing board-add paragraph:

  ```markdown
  **When an epic was approved, create it first.** Its number is needed to attach the children, and a
  child created before its parent cannot be linked without a second pass.

  1. Create the epic using the **Create issue** command from the loaded reference.
  2. Create each child issue as normal.
  3. Resolve the epic's and every child's node ID in **one** aliased query using the
     **Resolve node IDs** command from the loaded reference.
  4. Attach each child using the **Link a child to a parent** command — which is check-then-add, not
     blind-add. A child that already reports the intended parent is already linked; skip it silently.

  **Each attach warns and continues on failure.** The issues are the deliverable and they already
  exist by this point; a hierarchy outage must not lose a planning session's output. This is the same
  rule the board operations follow.

  Track how many children attached for the Phase 13 summary.

  Add the epic to the project board alongside the children — an epic absent from the board defeats
  the rollup that motivates creating it.

  Display: `Hierarchy: {n}/{total} children attached to #{epic}` or nothing when disabled.
  ```

  Extend the Phase 13 summary block:

  ```markdown
  Epic:      #{epic_number} — {n}/{total} children attached | not applicable
  ```

- [ ] **Task 3.3 — `merge-pr`: close the parent when its last child closes**

  In `skill/merge-pr/SKILL.md` Phase 7, after the loop that collects `issues_closed` and before the
  board update, add:

  ```markdown
  **Close the parent when its last child closes.** GitHub does not do this — a parent whose children
  are all closed reports `percentCompleted: 100` and stays `OPEN`. Nothing acts on the rollup, so if
  this skill does not close the parent, nothing will.

  Skip this entirely when `issues.hierarchy` is disabled or absent, and when `is_promotion` is true.

  For each reference in `issues_closed`:

  1. Read its `parent` using the **Read hierarchy** command from the loaded reference. No parent —
     which is the common case — means nothing to do.
  2. Read the parent's `subIssuesSummary`. Close the parent with the **Close** command **only** when
     `completed == total` and `total > 0`.
  3. Deduplicate by parent. Several children of one epic closing in a single merge must produce one
     close attempt, not one per child.

  A parent that is already closed needs no action. A parent with open children is left open —
  **never** close a parent with unfinished children, and never reopen one.

  Then mark the closed parent Done on the board using the same rules as its children: if the parent
  is not on the board, warn and skip rather than adding it at merge time.

  Every step here warns and continues. A failure to close a parent must not affect the merge, which
  has already happened.

  Collect closed parents into `parents_closed` and include them in the Phase 11 completion JSON.

  Display: `Parents closed: {list}` or nothing when none qualified.
  ```

- [ ] **Task 3.4 — Verify and commit**

  ```bash
  jq empty .hivrr.json .claude-plugin/marketplace.json
  jq -r '.plugins[] | ((.skills // [])[], (.commands // [])[])' .claude-plugin/marketplace.json \
    | while read -r p; do [ -e "$p" ] || echo "MISSING $p"; done
  ```

  Expected: no output from either command.

  ```bash
  git add skill/planning/SKILL.md skill/merge-pr/SKILL.md
  git commit -m "feat(planning,merge-pr): create epics with children and close satisfied parents"
  ```

**Verification:**

Run: `grep -n "Link a child to a parent\|epicThreshold" skill/planning/SKILL.md`
Expected: hits for both.

Run: `grep -n "parents_closed\|completed == total" skill/merge-pr/SKILL.md`
Expected: hits for both.

**Live check** — the only step whose behavior is worth proving against the API before merge. On a
scratch repo, or with throwaway issues you delete afterward:

Run: `/planning` on a spec that yields four or more issues with `issues.hierarchy` enabled.
Expected: one epic created, every child reporting that epic as its `parent`, and all of them on the board.

Then close every child and merge a PR referencing them.
Expected: `Parents closed: #{epic}`, and the epic reads `CLOSED`.

**Exit criteria:** `planning` creates an epic at Complex tier or ≥ `epicThreshold` issues and attaches every child; `merge-pr` closes a parent exactly when its last child closes and never otherwise. Both are no-ops when `issues.hierarchy` is off. Neither aborts its workflow on a hierarchy failure.

**Rollback:** `git revert` the commit. Already-created hierarchy links persist in GitHub and are harmless — they are read by nothing once Step 2 is also reverted, and display fine in the GitHub UI regardless. No cleanup is required.

**PR title suggestion:** `feat(planning,merge-pr): create epics with children and close satisfied parents`

---

### Step 4: Documentation sync — branch: `docs/sub-issues`

**Context brief:** `README.md` carries a `.hivrr.json` schema example around `:118-140` and a field table that must match `config.md` — the two drifting apart is exactly the failure this repo's structural verification cannot catch, since both files are valid Markdown either way. `CLAUDE.md` has a **Repo configuration** section summarizing the same contract. Per `CLAUDE.md`, a change to a `SKILL.md` or `marketplace.json` **is a behavior change, not a docs change** — but this step touches neither, so it is genuinely documentation. It comes last so it describes behavior that already exists.

**Dependencies:** Steps 2 and 3 must both be merged.

**Tasks:**

- [ ] **Task 4.1 — Update the README schema block and field table**

  Add the `issues` object to the `.hivrr.json` example in `README.md` and add this row to the field
  table, matching the wording in `config.md` exactly:

  ```markdown
  | `issues` | Issue hierarchy — GitHub sub-issues, and the epic threshold for planning | absent — hierarchy operations are silent no-ops |
  ```

- [ ] **Task 4.2 — Note hierarchy in `CLAUDE.md`**

  Add to the **Repo configuration** section, after the sentence describing per-key precedence:

  ```markdown
  Issue hierarchy (GitHub sub-issues) is opt-in via `issues.hierarchy` and is GitHub-only. When it is
  off, `planning` emits a flat issue set and `group-issues` falls back to parsing `Depends on #N` from
  issue bodies. See `skill/init/references/config.md`.
  ```

- [ ] **Task 4.3 — Verify and commit**

  Confirm the README and `config.md` field tables agree on the `issues` rows:

  ```bash
  grep -n "issues" README.md skill/init/references/config.md | grep -i "hierarchy\|epicThreshold"
  ```

  Expected: matching descriptions in both files.

  ```bash
  jq empty .hivrr.json .claude-plugin/marketplace.json
  ```

  Expected: no output.

  ```bash
  git add README.md CLAUDE.md
  git commit -m "docs: document the issues hierarchy config key"
  ```

**Verification:**

Run: `grep -c "hierarchy" README.md CLAUDE.md`
Expected: at least `1` in each.

**Exit criteria:** README and `CLAUDE.md` describe the `issues` key consistently with `config.md`. No skill file changed in this step.

**Rollback:** `git revert` the commit.

**PR title suggestion:** `docs: document the issues hierarchy config key`

---

## Out of scope

Recorded so they are not mistaken for oversights:

- **Linear hierarchy.** Linear has a native parent/sub-issue model. Wiring it in is a separate plan; until then `issues.hierarchy` is forced `false` when the tracker is Linear.
- **GitLab hierarchy.** No free-tier equivalent exists.
- **Nesting beyond one level.** GitHub supports nesting, but every consumer here treats hierarchy as exactly two levels — epic and child. Deeper trees are not read and not created.
- **`wave`.** It receives an ordered issue list from its caller and never fetches relationships itself, so it needs no change. Sibling grouping happens upstream in `group-issues`.
- **The two `init` gaps** in the Context section — the missing `issueTracker` override in `.hivrr.json`, and this repo's `verify` values being `null` against a README that defines real checks. Gap 1 will suppress hierarchy on this repo until it is fixed; it is a prerequisite in practice, and deliberately not bundled here.
- **Coordinating with the worktree plan.** `docs/plans/2026-08-21-worktree-isolation.md` Step 3 adds a
  `worktree` key to the same three anchors this plan's Step 1 touches: the `config.md` schema block,
  the field table, and a `### {key}` subsection after `### project`. It also adds a row to the
  `README.md` config table and a paragraph to `CLAUDE.md`. The two are independent in substance and
  can land in either order, but **whichever lands second appends after the key the first one added**,
  not after `project` — read the file before inserting rather than trusting the anchor named here.

---

## Self-review

| Check | Result |
|---|---|
| Spec coverage | All seven integration points from the exploration have a task. |
| Placeholder scan | No TBD/TODO/"handle edge cases". Every command is literal. |
| Name consistency | `issues.hierarchy`, `issues.epicThreshold`, `excluded` reason `Epic`, `parents_closed` — each used identically in every step. |
| Allowed APIs | Every `gh` command was executed live on 2026-08-21. Every cross-skill reference cites a command defined in Step 1. |
| Commit coverage | Each of the four steps ends with a staged, scoped commit. |
| Ordering | Step 1 gates 2 and 3; 4 follows both. No cycles. |

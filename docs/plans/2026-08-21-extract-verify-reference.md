# Extract the Shared Verify Block into a Reference — Implementation Plan

> **For agentic workers:** Use the `work-issue` skill to implement this plan task-by-task.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the verify procedure exist once, so `work-issue` and `work-pr` stop carrying divergent copies of the same rule.

**Architecture:** The shared procedure moves to `skill/init/references/verify.md`, alongside `config.md`. `init` already owns verification as a concept — Phase 4 detects the commands and writes them, and `config.md` documents the keys — and seven skills already reach into `../init/references/`, so the path convention is established rather than invented. Each driver keeps only what is genuinely its own: its review questions and its display line.

**Tech Stack:** Markdown skill definitions, `grep`, `jq`.

---

## Context: what was measured

`work-issue` and `work-pr` share **19 byte-identical substantial lines**, verified with `grep -Fxf`. The verify block is nearly all of them.

Identical in both files today:

```
Read `verify.test` and `verify.lint` from `.hivrr.json` and run each command directly…
**If `verify` is absent from config** (or there is no `.hivrr.json`), detect the commands…
**If a key is recorded as `null`**, that repo genuinely has no such command — report `skipped`…
Run each command and **show its real output**. Never reduce a failure to a bare status word…
On failure, fix the cause and retry — up to 3 attempts…
Display: `Verify: tests {pass|fail|skipped} | lint {pass|fail|skipped}`
```

**The copies have already drifted**, which is the reason to act now rather than later. `work-issue:238` carries the full "When to skip tests" rule with its reasoning and a two-way bullet list. `work-pr:146` carries a compressed single-paragraph summary of the same rule that drops the worked example. Neither is wrong; they are two maintainers' worth of the same idea, and only one of them gets updated when the idea changes.

### The consumer set is exactly two

`grep` for `verify.test`/`verify.lint` across the repo returns four sites:

| File | Role |
|---|---|
| `skill/work-issue/SKILL.md:218` | **Consumer** — runs the commands |
| `skill/work-pr/SKILL.md:132` | **Consumer** — runs the commands |
| `skill/init/SKILL.md:192,245` | Producer — detects and records |
| `skill/init/references/config.md:60-61` | Schema — documents the keys |

Two consumers, one producer, one schema. That is a clean extraction with no hidden third caller.

### What must NOT be flattened

The two skills' **"Review your own changes"** bullets differ, and the difference is correct:

| `work-issue` | `work-pr` |
|---|---|
| Do the changes actually satisfy the acceptance criteria from the issue(s)? | Does each piece of blocking feedback have a clear resolution? |
| Is there anything obviously wrong, missing, or broken? | Did you introduce any new issues? |

An issue has acceptance criteria; a PR has review feedback. Merging these into one list would replace two accurate prompts with one vague one. **They stay in their own skills.** The extraction covers the shared procedure, not the whole phase.

### A latent bug the extraction must fix

`work-issue:238` currently reads:

> Extension is not the test. **In this repo,** `.json` and `.md` *are* the product — `marketplace.json` defines which skills load, and a skill's `SKILL.md` is its implementation.

`work-issue` runs in the **user's** repo, not in `agent-plugins`. "In this repo" is therefore wrong at execution time in every repo except this one, where a `.json` file may legitimately be configuration nobody executes. The principle is right and the example is useful — but the example has to be labelled as one. Canonicalizing the text is the moment to fix this, because the extraction forces a decision about which wording wins.

### Fixed decisions (do not re-litigate)

| ID | Decision | Grounds |
|----|----------|---------|
| **A** | The reference lives at `skill/init/references/verify.md`. | `init` detects and writes the verify keys; `config.md` next door documents them. Seven skills already link into `../init/references/`. |
| **B** | `work-issue`'s fuller "When to skip tests" wins over `work-pr`'s summary. | It states the reasoning and gives the two-way list. A summary that drops the worked example is how the rule gets misapplied. |
| **C** | Per-skill review questions stay in their own skills. | They are genuinely different questions. See the table above. |
| **D** | "In this repo" becomes a labelled example. | The guidance executes in the user's repo. |
| **E** | A duplication check ships with the change, in the README. | This repo's product is Markdown, so drift is invisible to `jq`. An unchecked extraction re-duplicates within two PRs. |

---

## Complexity

**Medium** — three files plus a README addition, one PR, no ordering constraint against other work. Per `references/blueprint.md`, blueprint mode is explicitly *not* for work completable in a single PR, so this plan uses the Medium-tier task breakdown instead.

---

## File Structure

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `skill/init/references/verify.md` | The shared verify procedure — the single definition |
| Modify | `skill/work-issue/SKILL.md:216-253` | Link to the reference; keep issue-specific review questions |
| Modify | `skill/work-pr/SKILL.md:130-160` | Link to the reference; keep feedback-specific review questions |
| Modify | `README.md` | Third structural check: assert the block is not duplicated |

---

## Tasks

### Task 1: Write the duplication check

The repo's product is Markdown, so the "failing test" is a `grep` that proves the duplication exists. Writing it first means the extraction has something to satisfy rather than something to claim.

**Files:**
- Modify: `README.md` (Verification section, after the existing two checks)

- [ ] **Step 1: Add the check to the README**

  In `README.md`, inside the Verification section's `bash` block, after the two existing checks:

  ```bash
  # no skill duplicates another skill's procedure verbatim
  grep -Fxf skill/work-pr/SKILL.md skill/work-issue/SKILL.md \
    | awk 'length > 60' | grep . && echo "DUPLICATED — extract to a shared reference" || true
  ```

  Add this sentence beneath the block:

  ```markdown
  The third check guards against the failure the first two cannot see: two skills carrying the same
  procedure in prose. Markdown that parses and resolves is still wrong if it says the same thing
  twice and the two copies disagree.
  ```

- [ ] **Step 2: Run it and confirm it FAILS**

  Run:
  ```bash
  grep -Fxf skill/work-pr/SKILL.md skill/work-issue/SKILL.md | awk 'length > 60' | grep . \
    && echo "DUPLICATED" || echo "clean"
  ```

  Expected: `DUPLICATED`, preceded by the shared lines — the verify paragraphs among them.
  This is the failing state the rest of the plan removes.

- [ ] **Step 3: Commit**

  ```bash
  git add README.md
  git commit -m "test: add duplication check for shared skill procedures"
  ```

---

### Task 2: Create the shared reference

**Files:**
- Create: `skill/init/references/verify.md`

- [ ] **Step 1: Write the reference**

  Create `skill/init/references/verify.md` with exactly this content. It is `work-issue`'s wording
  (decision **B**) with the "in this repo" example generalized (decision **D**) and the per-skill
  review questions removed (decision **C**):

  ````markdown
  # Verify — Running a Repo's Tests and Linter

  The shared procedure for `work-issue` and `work-pr`. Both run the same commands under the same
  rules; only their review questions differ, and those stay in the skills.

  `init` Phase 4 detects and records these commands. [`config.md`](config.md) documents the keys and
  the precedence chain.

  ---

  ## Resolving the commands

  Read `verify.test` and `verify.lint` from `.hivrr.json` and run each command directly. See
  [`config.md`](config.md) for the read steps and per-key precedence.

  **If `verify` is absent from config** (or there is no `.hivrr.json`), detect the commands yourself
  using the detection tables in `init` Phase 4, run them, and then offer to record what you found so
  the next run does not repeat the guesswork.

  **If a key is recorded as `null`**, that repo genuinely has no such command — report `skipped`, and
  do not go looking.

  ---

  ## Running the commands

  Run each command and **show its real output**. Never reduce a failure to a bare status word: "tests
  fail" with no output tells you nothing about what to fix and forces another round trip. Do not pipe
  through `--silent`, do not capture into a variable you then discard, and do not swallow stderr.

  On failure, fix the cause and retry — up to 3 attempts. If it still fails, stop and report the
  actual output.

  ---

  ## When to skip tests

  Skip tests only when the changed files **cannot affect behavior**. Judge this by what each file
  does, not by its extension.

  ```bash
  git diff --name-only HEAD
  ```

  **Extension is not the test.** Whether a file affects behavior depends on what reads it in *this*
  repository — the one the workflow is running in, which is usually not the repo that ships these
  skills.

  - **Affects behavior** — source files, configuration that programs read, CI workflow definitions,
    schema and manifest files, and any markdown a tool consumes as instructions
  - **Does not affect behavior** — prose documentation, `README`, `CHANGELOG`, `LICENSE`, comments

  For a worked example: in a plugin repository whose product *is* JSON and Markdown, a manifest that
  declares which skills load and a `SKILL.md` that is a skill's implementation both affect behavior,
  and treating them as docs is how a change to either ships unverified. In a repository whose product
  is compiled code, the same two extensions may genuinely be documentation. Ask what reads the file.

  When in doubt, run the tests. The cost of running them unnecessarily is far below the cost of
  skipping them when they mattered.

  ---

  ## Reporting

  ```
  Verify: tests {pass|fail|skipped} | lint {pass|fail|skipped}
  ```

  Each of `pass`, `fail`, and `skipped` is a distinct outcome. `skipped` means the command was not
  run — because the key is `null` or the change cannot affect behavior — and must never be reported
  as `pass`.
  ````

- [ ] **Step 2: Confirm it parses as expected**

  Run:
  ```bash
  test -f skill/init/references/verify.md && wc -l skill/init/references/verify.md
  awk '/^ *```/{n++} END{print n" fence markers — must be even"}' skill/init/references/verify.md
  ```

  Expected: the file exists, and an even fence count.

- [ ] **Step 3: Commit**

  ```bash
  git add skill/init/references/verify.md
  git commit -m "docs(init): add shared verify reference"
  ```

---

### Task 3: Point `work-issue` at the reference

**Files:**
- Modify: `skill/work-issue/SKILL.md:216-253`

- [ ] **Step 1: Replace Phase 8's body**

  Replace everything from `## Phase 8 — Verify` up to (not including) the `---` that precedes
  `## Phase 9 — Review Checkpoint` with:

  ````markdown
  ## Phase 8 — Verify

  Follow [`verify.md`](../init/references/verify.md) — it has the command resolution, the
  run-and-show-real-output rule, the skip criteria, and the reporting format.

  **Review your own changes** once the commands have run:
  - Do the changes actually satisfy the acceptance criteria from the issue(s)?
  - Is there anything obviously wrong, missing, or broken?
  - Fix what you find.
  ````

- [ ] **Step 2: Confirm the shared prose is gone and the skill-specific prose stayed**

  Run:
  ```bash
  grep -c "show its real output\|detection tables in \`init\` Phase 4" skill/work-issue/SKILL.md
  grep -c "acceptance criteria from the issue" skill/work-issue/SKILL.md
  ```

  Expected: `0` for the first, `1` for the second.

- [ ] **Step 3: Commit**

  ```bash
  git add skill/work-issue/SKILL.md
  git commit -m "refactor(work-issue): use the shared verify reference"
  ```

---

### Task 4: Point `work-pr` at the reference

**Files:**
- Modify: `skill/work-pr/SKILL.md:130-160`

- [ ] **Step 1: Replace Phase 7's body**

  Replace everything from `## Phase 7 — Verify` up to (not including) the `---` that precedes
  `## Phase 8 — Review Checkpoint` with:

  ````markdown
  ## Phase 7 — Verify

  Follow [`verify.md`](../init/references/verify.md) — it has the command resolution, the
  run-and-show-real-output rule, the skip criteria, and the reporting format.

  **Review your own changes** once the commands have run:
  - Does each piece of blocking feedback have a clear resolution?
  - Did you introduce any new issues?
  - Fix what you find.
  ````

  Note that `work-pr` gains the fuller skip-criteria rule by doing this — it previously carried a
  compressed summary. That is the point of the extraction, not a side effect.

- [ ] **Step 2: Confirm**

  Run:
  ```bash
  grep -c "show its real output" skill/work-pr/SKILL.md
  grep -c "blocking feedback have a clear resolution" skill/work-pr/SKILL.md
  ```

  Expected: `0` for the first, `1` for the second.

- [ ] **Step 3: Commit**

  ```bash
  git add skill/work-pr/SKILL.md
  git commit -m "refactor(work-pr): use the shared verify reference"
  ```

---

### Task 5: Run the check and close out

- [ ] **Step 1: The duplication check now PASSES**

  Run:
  ```bash
  grep -Fxf skill/work-pr/SKILL.md skill/work-issue/SKILL.md | awk 'length > 60' | grep . \
    && echo "DUPLICATED" || echo "clean"
  ```

  Expected: `clean`.

  **If any long shared lines remain**, read them before deleting anything. A line shared by both
  skills is not automatically duplication — a genuinely common instruction that belongs in both is
  fine. Judge each survivor; if it is shared procedure, move it into `verify.md`, and if it is
  coincidental phrasing, raise the `awk` length threshold and record why in the README sentence.

- [ ] **Step 2: Repo structural verification**

  Run:
  ```bash
  jq empty .hivrr.json .claude-plugin/marketplace.json
  jq -r '.plugins[] | ((.skills // [])[], (.commands // [])[])' .claude-plugin/marketplace.json \
    | while read -r p; do [ -e "$p" ] || echo "MISSING $p"; done
  ```

  Expected: no output from either command.

- [ ] **Step 3: Confirm the reference link resolves from both skills**

  A relative link that does not resolve is the one way this refactor fails silently:

  ```bash
  for s in work-issue work-pr; do
    test -e "skill/$s/../init/references/verify.md" \
      && echo "$s -> verify.md ok" || echo "$s -> BROKEN LINK"
  done
  ```

  Expected: `ok` for both.

- [ ] **Step 4: Commit any remaining changes**

  ```bash
  git status --short
  ```

  Expected: clean. Every task above committed its own files.

---

## Verification summary

| Check | Command | Expected |
|---|---|---|
| Duplication gone | `grep -Fxf skill/work-pr/SKILL.md skill/work-issue/SKILL.md \| awk 'length>60'` | no output |
| Links resolve | `test -e skill/work-issue/../init/references/verify.md` | exit 0 |
| JSON parses | `jq empty .hivrr.json .claude-plugin/marketplace.json` | no output |
| Registered paths exist | the `marketplace.json` loop | no output |
| Skill-specific prose kept | `grep -c "acceptance criteria from the issue" skill/work-issue/SKILL.md` | `1` |

---

## Out of scope

- **Extracting anything else.** The other 13 shared lines between the two skills — the `--auto`
  handling, the uncommitted-changes warning, the "skip this phase for simple tasks" line — are
  individually short and contextual. They are worth a second look *after* this lands and the check is
  in place, not bundled into it.
- **`merge-pr`'s inline "Branch Deletion Safety" block** (`merge-pr:37`). It is a strong extraction
  candidate for the same reasons and is already cross-linked from `github.md`, but it has one
  consumer, so it is refactoring rather than de-duplication.
- **The command/skill naming collision.** Independent of this work — the extraction needs no
  renaming, which is precisely why it can proceed while that question stays open.
- **Splitting `init`** into setup phases versus shared library. This plan adds a second file to
  `init/references/`, which strengthens the case, but the split is its own change.

---

## Self-review

| Check | Result |
|---|---|
| Spec coverage | The shared block is defined once and consumed twice; the check proves it. |
| Placeholder scan | No TBD/TODO. Every command is literal; the reference content is given in full, not described. |
| Name consistency | `verify.md`, `verify.test`, `verify.lint` used identically throughout. Phase numbers match each skill's actual numbering — `work-issue` Phase 8, `work-pr` Phase 7. |
| Allowed APIs | `grep -Fxf`, `awk`, `jq`, `test -e` only. The 19-line duplication count and the four consumer sites were measured, not estimated. |
| Commit coverage | Five tasks, five commits, each staging only its own files. |
| Ordering | Task 1 must precede Tasks 3–4 so the check exists in its failing state first. Task 2 must precede 3 and 4 so the link target exists. |

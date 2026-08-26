# Audit and Review Verification Pipeline — Implementation Plan

> **Filename note:** this document started as an `auditor`-only plan and kept its path when
> `review-pr` was added as Step 7. The path is `docs/plans/2026-08-26-audit-verification-pipeline.md`;
> the scope is both.

> **For agentic workers:** Use the `work-issue` skill to implement this plan step-by-step.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop the `auditor` plugin filing unverified findings as GitHub issues and stop `review-pr` posting unverified findings to a PR, by splitting discovery from verification in both and giving each stage a bar of its own.

**Architecture:** One pipeline, six edits, no new skills. Discovery is widened (vulnerability *shapes* instead of an OWASP checklist, an explicit exclusion list, and a deliberately low reporting bar) and made evidence-bound. Between discovery and issue creation, two new phases land in the orchestrator: an adversarial verification pass where N independent typed subagents try to refute each finding, and a ranking pass that derives severity from preconditions after the verdict is in. A JSON findings artifact under `.ai/audit/` carries findings between the phases so they can be deduplicated before verification is paid for, and unioned across runs. Step 7 applies the same split to `review-pr`, adapted to a diff: discovery gets adversarial lenses instead of a checklist, and verification reads the whole file rather than the hunk, because "the guard you say is missing exists twenty lines above the diff" is that skill's dominant false positive. Every behavioural change is held by a new structural check in `README.md`.

**Tech Stack:** Markdown skill definitions, `jq`, `awk`/`grep` structural checks, `gh` CLI, Claude Code `Task` subagents.

---

## Provenance

Every concept here is lifted from [`anthropics/defending-code-reference-harness`](https://github.com/anthropics/defending-code-reference-harness), read at commit depth 1 on 2026-08-26. The specific sources:

| Concept | Their file |
|---|---|
| Discovery is noisy, verification is adversarial | `docs/best-practices.md` § *Verification: the load-bearing component* |
| Shapes, not checklists — enumerating bug classes worsens recall | `docs/prompting.md` § *Describe Vulnerability Shapes, Not Checklists* |
| The DO-NOT-REPORT exclusion list, per-finding confidence | `.claude/skills/vuln-scan/SKILL.md` |
| N-vote refutation, `subagent_type` never fork, dedupe-before-verify | `.claude/skills/triage/SKILL.md` §§ 3a, 3b, 3c, *Design notes* |
| Severity from preconditions, ranked separately from the verdict | `docs/best-practices.md` § *Severity and triage*; `triage` § 4a |
| Focus-area partition so parallel finders do not converge | `docs/prompting.md` § *Specifying Scope*; `vuln-scan` Step 1 |
| Never fabricate a `file:line` | `vuln-scan` § *Constraints* |

Their `harness/` (Python + Docker + gVisor + ASAN) is deliberately **not** adopted — this repo ships no runtime and no shell scripts.

---

## Context: what was verified, and how

Every claim below was executed against this working tree on 2026-08-26.

### Unverified findings become issues, which become work

`skill/audit/SKILL.md` Phase 4 aggregates findings in context; Phase 7 files each one with `gh issue create` and Phase 8 closes with:

```
skill/audit/SKILL.md:163   Suggest: "Use `/work-issue {first_issue_number}` to start fixing."
```

Nothing between the scan and the tracker asks whether a finding is real. A false positive becomes an issue, an issue becomes a `/work-issue` run, and a `/work-issue` run becomes a PR against code that was never broken. That is the failure this plan exists to close.

### The discovery prompt is the exact anti-pattern their prompting guide names

`skill/audit-security/SKILL.md:29-63` is a six-heading OWASP checklist — *Injection (A03)*, *Broken Access Control (A01)*, *Authentication Failures (A07)*, and so on, each with a bulleted API list. Their guide, `docs/prompting.md`:

> The flip side: enumerating the bug types you want found ("look for SQLi, XSS, and CSRF") *worsens recall* — the model overfocuses on the named classes and walks past everything else.

The same document names the fix, and points at the file that demonstrates it:

> The `/vuln-scan` skill's focus-area prompt is a worked example of the right abstraction level — "attacker input alters the syntactic structure of an interpreted language" rather than a list of injection APIs.

### `core`'s ≥80% confidence bar is loaded into every audit run

`command/audit.md:7` bootstraps `core` before the `audit` skill, and `skill/core/SKILL.md:94` states:

```
Only report findings with >=80% confidence.
```

That is correct for `review-pr`, where there is no verification stage and a finding goes straight to a human. It is wrong for a pipeline that verifies, and it is currently in force for one. Their guidance is explicit that this filter is the thing that loses real bugs:

> Asking discovery agents to apply strict criteria up front quietly filters out things a verifier would have confirmed.

**This plan does not edit `core`.** It scopes an override to the audit discovery phase and re-imposes a higher bar at verification. See **Decisions**.

### `review-pr` has the same defect, on a surface where it is posted publicly

`command/review-pr.md:10` bootstraps `core`, and `skill/review-pr/SKILL.md:62` makes the bar a
find-time filter:

```
skill/review-pr/SKILL.md:59   ## Phase 4 — Analyze the Diff
skill/review-pr/SKILL.md:62   - ≥80% confidence before including it
```

One pass finds, judges, and files, and Phase 6 posts the result as a public comment. The failure is
symmetrical to the audit's: a threshold applied while looking drops findings a verifier would have
confirmed, and nothing downstream re-examines what survives. The consequence differs, though, and it
is what shapes Step 7 — an audit's false positive costs an issue, a review's costs the team's
willingness to read the bot at all.

**Diff review has a dominant false-positive class of its own.** The reviewer sees a hunk; the guard,
the null check, the validation, or the early return often sits outside it. "You forgot to handle X"
where X is handled twenty lines above the diff is the single most common wrong finding in
diff-scoped review, and it is invisible unless the verifier opens the file. Their verification
guidance generalises directly: their verifiers are told to start from the code rather than the
scanner's description, for the same reason.

### The domain skills already share a four-section shape

All four of `skill/audit-{security,accessibility,performance,tech-debt}/SKILL.md` carry the same headings — `## What to Scan`, `## What to Look For`, `## Severity Guide`, `## Output Format` — and the same four-row severity table shape. Confirmed by `grep -n '^#\+ '` across all four. Edits to the contract therefore land in four predictable places, and a structural check can read all four with one glob.

### Nothing declares these skills read-only

None of the four domain skills has an `allowed-tools:` key; their frontmatter is `name`, `description`, `license`, `compatibility` only. Their equivalents declare it — `vuln-scan` restricts Bash to `Bash(rg:*)`, `Bash(grep:*)`, `Bash(ls:*)`, `Bash(wc:*)`, `Bash(head:*)`, `Bash(file:*)` and nothing else. A scanner that can write is a scanner that can "fix" what it found mid-scan.

### `.ai/` is already the scratch location, and already ignored

```
.gitignore:4   # Worker session scratch — memory fallback written by the planning and work-issue skills
.gitignore:5   .ai/
```

The findings artifact goes to `.ai/audit/findings.json`. No new ignore rule, no new convention — this reuses the one the `planning` and `work-issue` skills already write to.

### The six new checks are red today, and their syntax runs

All five proposed checks were executed against this tree before this plan was written. Current output:

```
AUDIT NOT READ-ONLY skill/audit-accessibility/SKILL.md (no allowed-tools)
AUDIT NOT READ-ONLY skill/audit-performance/SKILL.md (no allowed-tools)
AUDIT NOT READ-ONLY skill/audit-security/SKILL.md (no allowed-tools)
AUDIT NOT READ-ONLY skill/audit-tech-debt/SKILL.md (no allowed-tools)
FINDING FIELD skill/audit-accessibility/SKILL.md missing id
… (24 FINDING FIELD lines)
NO EXCLUSION LIST skill/audit-security/SKILL.md
NO VERIFY PHASE skill/audit/SKILL.md
RANK ORDER skill/audit/SKILL.md (missing Verify or Rank phase)
REVIEW BAR AT DISCOVERY skill/review-pr/SKILL.md (threshold applied while finding)
REVIEW UNVERIFIED skill/review-pr/SKILL.md (no Verify phase)
```

### `w2n` cannot count past thirteen

`README.md`'s verify block defines `w2n()` with cases `one` through `thirteen`. The block currently holds 11 checks:

```
$ FENCE=$(printf "\140\140\140"); awk -v fence="$FENCE" '…' README.md | grep -c '^# '
11
```

This plan adds six, reaching seventeen. `w2n seventeen` returns `0`, the eighth check compares `0` against `17`, and reports `CHECK COUNT DRIFT` on a count that is correct. **Step 1 extends `w2n` to twenty before adding the first check** — otherwise every later step fails verification for a reason that has nothing to do with the step.

### The phase-sequence check governs every renumbering

The seventh check requires `^## Phase N` headings in each `skill/*/SKILL.md` to run `1..N` with no gaps. `skill/audit/SKILL.md` has phases 1–8 today and ends at 11. Every step that inserts a phase renumbers the ones after it, in the same commit, or verification fails. Each step below states its exact target numbering.

### The verification command

```
$ jq -r '.verify.test' .hivrr.json | bash
structural checks pass
```

That is the command every step verifies with. It extracts the fenced block from `README.md`, exports it as `HIVRR_VERIFY_BLOCK`, and runs it with stdin closed.

---

## Decisions

**The discovery bar overrides `core`, in one place, in writing.** `skill/audit/SKILL.md` Phase 4 (Run Domain Scans) states the override and its reason; each domain skill carries a one-line restatement and points there. `core` is not edited — `review-pr` and every `dev` workflow keep the ≥80% bar, which is right for them because they have no verifier.

**`review-pr` gets the same split, calibrated down.** It carries the identical defect and was deferred in the first draft of this plan; that call was overridden. Three things are deliberately different from the audit path, because a diff is not a tree and a PR comment is not an issue: **two votes by default** rather than three (bounded scope, interactive use), **only BLOCKER and REQUIRED are verified** (DEFERRED is opinion, and verifying an opinion buys nothing), and a split vote **demotes one tier rather than dropping** — in a diff review the cost of a real finding filed a tier low is small, and the cost of dropping it is not.

**The review reports its own filtering.** When verification drops candidates, the posted comment says how many. A review that silently discards half its findings reads as a thorough review that found little, which is the opposite of true.

**Each behavioural change gets a structural check.** `CLAUDE.md` states that a change to any `SKILL.md` in this repo is a behaviour change, not a docs change. This repo's only test is the structural block, so "write the failing test first" means "write the failing check first". Six new checks — one each for Steps 1–5 and Step 7; Step 6's guarantee comes free from the existing seventh check. This is the largest discretionary decision in the plan — the seven skill edits would work without it, and the checks are what stop them silently regressing.

**Verification spend is capped and the cap is reported.** Three votes per finding on a 33-finding audit is 99 subagents. Phase 6 caps concurrency at 10, and drops to one vote per finding when `findings × votes` would exceed 60 — printing that it did. Their `triage` shards at ~40; the cap here is lower because an audit runs interactively. A silent cap reads as "we verified everything" when it did not.

**`--votes N` is the only new knob.** `--votes 1` is the quick path. No `--no-verify`: an audit that skips verification is the behaviour this plan removes.

---

## Non-goals

- No `harness/`-style execution, sandboxing, PoC generation, or ASAN. This repo has no runtime.
- No `checkpoint.py` or any other script. `skill/core/SKILL.md`'s script policy forbids it, and the four-condition test in that policy fails on the first condition for a state-mutating helper.
- No new skills, no new commands. `marketplace.json`, `CLAUDE.md`'s `**Skills:**`/`**Commands:**` lines, and `README.md`'s Overview table are untouched by this plan, so checks 6, 9, and 11 have nothing to react to.
- No CVSS scoring. Their guidance is that the model should not compute CVSS at all without a calculator; this plan emits no CVSS, which sidesteps it.
- No org-specific false-positive rules file (`--fp-rules`). It maps cleanly onto `.hivrr.json` and is recorded as future work.

---

## File Structure

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `README.md` | Six new structural checks; `w2n` extended to twenty; `--votes` in two usage lines |
| Modify | `CLAUDE.md` | Check-count sentence and the named list it opens with |
| Modify | `skill/audit/SKILL.md` | Findings artifact, verification phase, ranking phase, security recon, discovery-bar override |
| Modify | `skill/audit-security/SKILL.md` | Shapes replace the OWASP checklist; exclusion list; focus-area brief; contract fields; `allowed-tools` |
| Modify | `skill/audit-accessibility/SKILL.md` | Contract fields; precondition severity; `allowed-tools`; evidence rule |
| Modify | `skill/audit-performance/SKILL.md` | Contract fields; precondition severity; `allowed-tools`; evidence rule |
| Modify | `skill/audit-tech-debt/SKILL.md` | Contract fields; precondition severity; `allowed-tools`; evidence rule |
| Modify | `command/audit.md` | `--votes N` argument |
| Modify | `skill/review-pr/SKILL.md` | Adversarial discovery lenses, verification phase, whole-file rule, phase count |
| Modify | `command/review-pr.md` | `--votes N` argument |
| Create | `.ai/audit/findings.json` | Runtime artifact — written by the skill, gitignored, not committed |

---

## Blueprint

**Steps:** 7 | **Serial:** all seven | **Parallel:** none

```
Step 1 ──> Step 2 ──> Step 3 ──> Step 4 ──> Step 5 ──> Step 6 ──> Step 7
```

There is no parallelism here, and that is a finding rather than an oversight. Blueprint's parallel rule requires no shared output files; every step edits either `skill/audit/SKILL.md` or the same four domain-skill sections, and **every** step edits `README.md` and `CLAUDE.md` — the check-count sentence alone serialises the whole plan. Step 7 touches a different skill in a different plugin and is still serial for that reason.

Step 7 is last rather than first despite being independent of the audit work: it reuses the verifier prompt shape that Step 4 establishes, and lands the seventeenth check on a count that Steps 1–6 have already moved five times.

| Step | Item | Scope | Size |
|---|---|---|---|
| 1 | 5 | Read-only frontmatter, evidence rule, `w2n` | S |
| 2 | 3 | Findings contract and artifact | M |
| 3 | 1 | Shapes and the exclusion list | M |
| 4 | 2 | Adversarial verification phase | L |
| 5 | 4 | Precondition-derived severity | M |
| 6 | 6 | Security focus-area recon | M |
| 7 | — | `review-pr` discovery bar and verification | L |

Story points: XS=1, S=2, M=3, L=5. Total: 24.

---

### Step 1: Read-only guarantees and the evidence rule — branch: `feat/audit-read-only`

**Context brief:** The four domain skills at `skill/audit-{security,accessibility,performance,tech-debt}/SKILL.md` declare no `allowed-tools`, so a scanner can write files, run arbitrary Bash, and edit the code it is auditing. They also emit `file:line` references straight into GitHub issue bodies with nothing requiring those lines to have been read. This step closes both, and extends `README.md`'s `w2n()` helper past thirteen so the four later steps can add checks without tripping the eighth check on an arithmetic limit.

**Dependencies:** none.

**Tasks:**

- [ ] **Step 1: Extend `w2n()` to twenty**

  In `README.md`, inside the fenced block under `## Verification`, find the `w2n()` definition in the seventh check and replace it:

  ```bash
  w2n() { case "$1" in one) echo 1;; two) echo 2;; three) echo 3;; four) echo 4;; five) echo 5;;
          six) echo 6;; seven) echo 7;; eight) echo 8;; nine) echo 9;; ten) echo 10;;
          eleven) echo 11;; twelve) echo 12;; thirteen) echo 13;; fourteen) echo 14;;
          fifteen) echo 15;; sixteen) echo 16;; seventeen) echo 17;; eighteen) echo 18;;
          nineteen) echo 19;; twenty) echo 20;; *) echo 0;; esac; }
  ```

  This is a pure extension — every existing case keeps its value, so no current check changes behaviour.

- [ ] **Step 2: Add the twelfth check**

  Append to the end of the fenced block in `README.md`, after the Overview-table check:

  ```bash
  # the audit domain skills are declared read-only
  for f in skill/audit-*/SKILL.md; do
      fm=$(awk 'NR > 1 && /^---$/ { exit } NR > 1' "$f")
      printf '%s\n' "$fm" | grep -q '^allowed-tools:' \
        || { echo "AUDIT NOT READ-ONLY $f (no allowed-tools)"; continue; }
      printf '%s\n' "$fm" | grep -qE '^ *- *(Edit|Write|NotebookEdit) *$' \
        && echo "AUDIT NOT READ-ONLY $f (declares a mutating tool)"
    done
  ```

  The glob `skill/audit-*/SKILL.md` matches the four domain skills and **not** `skill/audit/SKILL.md` — the orchestrator writes the findings artifact and calls `gh`, so it is deliberately outside this check.

- [ ] **Step 3: Update the check count in `CLAUDE.md`**

  Under `## Verification`, the sentence currently opens `Eleven checks: every JSON file parses, …`. Change the word to `Twelve` and append this to the end of the list:

  ```
  ; and the four `audit-*` skills declare themselves read-only
  ```

  Keep the list order matching the block order — the new check is last in both.

- [ ] **Step 4: Run verification and confirm exactly one failure class**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: exit 1, and these four lines only —

  ```
  AUDIT NOT READ-ONLY skill/audit-accessibility/SKILL.md (no allowed-tools)
  AUDIT NOT READ-ONLY skill/audit-performance/SKILL.md (no allowed-tools)
  AUDIT NOT READ-ONLY skill/audit-security/SKILL.md (no allowed-tools)
  AUDIT NOT READ-ONLY skill/audit-tech-debt/SKILL.md (no allowed-tools)
  ```

  If `CHECK COUNT DRIFT` also appears, Step 3 did not land — fix it before continuing. Any other message means an unrelated regression; stop.

- [ ] **Step 5: Declare `allowed-tools` in all four domain skills**

  In each of `skill/audit-{security,accessibility,performance,tech-debt}/SKILL.md`, add the key to the existing frontmatter, between `description:` and `license:`:

  ```yaml
  allowed-tools:
    - Read
    - Glob
    - Grep
    - Bash(rg:*)
    - Bash(grep:*)
    - Bash(ls:*)
    - Bash(wc:*)
    - Bash(head:*)
    - Bash(file:*)
  ```

  Leave `compatibility: opencode` in place. `allowed-tools` is a Claude Code key; a runtime that does not read it ignores it, which is the same behaviour as today.

- [ ] **Step 6: Add the tool-fallback note to all four domain skills**

  Immediately after the `## What to Scan` section in each of the four files, add:

  ```markdown
  **Tool fallbacks.** `allowed-tools` is a permission filter, not a loader — listing Glob and Grep
  does not make them appear in a session that does not provision them. When they are unavailable,
  fall back to the read-only Bash commands above: `rg --files <scope>` or `ls -R` to enumerate,
  `rg -n` or `grep -rn` to search, `wc` / `head` / `file` to sniff. Those are the only permitted
  Bash commands. Do not write helper scripts and do not pipe scanned content into an interpreter.
  ```

- [ ] **Step 7: Add the evidence rule to all four domain skills**

  At the end of the `## Output Format` section in each of the four files, add:

  ```markdown
  **Never emit a `file:line` you did not read.** Every location you report must be one you opened
  with Read, or that came back from a Grep hit you then read. If you are confident about the
  function but not the exact line, cite the function name and say so in the description rather
  than guessing a number. A finding citing a line that does not exist is worse than no finding:
  it burns a verifier, it burns a reviewer, and it is the fastest way to make the whole audit
  untrusted.
  ```

- [ ] **Step 8: Run verification and confirm it passes**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: `structural checks pass`, exit 0.

- [ ] **Step 9: Commit**

  ```bash
  git add README.md CLAUDE.md skill/audit-security/SKILL.md skill/audit-accessibility/SKILL.md skill/audit-performance/SKILL.md skill/audit-tech-debt/SKILL.md
  git status --short
  git commit -m "feat(auditor): declare the domain skills read-only and forbid fabricated line numbers" -- README.md CLAUDE.md skill/audit-security/SKILL.md skill/audit-accessibility/SKILL.md skill/audit-performance/SKILL.md skill/audit-tech-debt/SKILL.md
  ```

**Verification:**

Run: `jq -r '.verify.test' .hivrr.json | bash`
Expected: `structural checks pass`

Run: `head -20 skill/audit-security/SKILL.md`
Expected: frontmatter containing an `allowed-tools:` list with no `Edit`, `Write`, or bare `Bash`.

**Exit criteria:** All four domain skills declare `allowed-tools`; the twelfth check is green; `w2n` resolves `sixteen` to 16; every domain skill's Output Format forbids unread line numbers.

**Rollback:** `git revert` the commit. Nothing else depends on this step yet.

**PR title suggestion:** `feat(auditor): declare the domain skills read-only and forbid fabricated line numbers`

---

### Step 2: The findings contract — branch: `feat/audit-findings-contract`

**Context brief:** `skill/audit/SKILL.md` Phase 4 ("Aggregate and Prioritize") merges findings in conversation context and hands them to Phase 5 as prose. Nothing is addressable, so nothing can be deduplicated by identity, verified by id, carried across runs, or re-triaged after the session ends. This step gives every finding a stable id and a fixed field set, has the orchestrator write them to `.ai/audit/findings.json`, and unions against any artifact from a previous run. `.ai/` is already in `.gitignore` as worker session scratch. Phase count stays at 8 — this step renames Phase 4 and extends it, it does not insert one.

**Dependencies:** Step 1 must be merged. It adds the evidence rule to the same `## Output Format` sections this step rewrites.

**Tasks:**

- [ ] **Step 1: Add the thirteenth check**

  Append to the fenced block in `README.md`:

  ```bash
  # every audit domain skill emits the shared finding fields
  for f in skill/audit-*/SKILL.md; do
      sec=$(awk '/^## Output Format/ { v = 1; next } v && /^## / { exit } v' "$f")
      for k in id file line severity confidence evidence; do
        printf '%s\n' "$sec" | grep -qF "\`$k\`" || echo "FINDING FIELD $f missing $k"
      done
    done
  ```

- [ ] **Step 2: Update the check count in `CLAUDE.md`**

  Change `Twelve checks:` to `Thirteen checks:` and append to the list:

  ```
  ; and every `audit-*` skill's output format names the shared finding fields
  ```

- [ ] **Step 3: Run verification and confirm the red state**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: exit 1, 24 lines of the form `FINDING FIELD skill/audit-*/SKILL.md missing {id,file,line,severity,confidence,evidence}` and nothing else.

- [ ] **Step 4: Rewrite `## Output Format` in all four domain skills**

  Replace the section body in each of `skill/audit-{security,accessibility,performance,tech-debt}/SKILL.md` with this, keeping the evidence-rule paragraph added in Step 1 at the end:

  ```markdown
  ## Output Format

  Report each finding as a block with these fields. The orchestrator collects them into
  `.ai/audit/findings.json`; field names are a contract, so use them exactly.

  | Field | Type | Notes |
  |---|---|---|
  | `id` | string | Leave empty — the orchestrator assigns `A-001`, `A-002`, … |
  | `domain` | string | This skill's domain |
  | `file` | string | Repo-relative path |
  | `line` | integer | A line you actually read. See the evidence rule below |
  | `evidence` | string | The line's text, verbatim, ≤200 chars. This is what a verifier re-derives from |
  | `category` | string | Short kebab-case slug, e.g. `sql-injection`, `missing-label`, `n-plus-one` |
  | `severity` | string | `critical` / `high` / `medium` / `low` — your first read; the orchestrator re-derives it |
  | `effort` | string | `trivial` / `small` / `medium` / `large` |
  | `confidence` | number | 0.0–1.0. Your own honest estimate. Do not filter on it |
  | `title` | string | One line, specific |
  | `description` | string | What the code does and why it is a problem |
  | `recommendation` | string | A concrete fix, not "refactor this" |

  **Report at the orchestrator's bar, not `core`'s.** `core` sets a ≥80% confidence floor for code
  review, where a finding goes straight to a human with nothing downstream to filter it. This
  pipeline verifies before anything is presented or filed, so the floor here is different: report
  anything with a plausible story, and when you are unsure, report it with a low `confidence`
  rather than dropping it. A finding you drop is one no verifier will ever see. Do not apply a
  confidence threshold of your own — that judgment belongs to the verification phase. See the
  **Run Domain Scans** phase in `skill/audit/SKILL.md`.

  Group findings by severity (critical first). At the end, report how many files were scanned and
  how many findings were emitted. If nothing was found, say so clearly — a clean result is useful
  information. If a file cannot be read, skip it and note it in the summary; do not stop the scan.
  ```

  Then re-append the **Never emit a `file:line` you did not read** paragraph from Step 1 below it.

- [ ] **Step 5: Run verification and confirm the thirteenth check passes**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: `structural checks pass`, exit 0.

- [ ] **Step 6: Add the discovery bar to the existing Phase 3**

  `skill/audit/SKILL.md:47` is already `## Phase 3 — Run Domain Scans`. **Do not add, rename, or
  renumber a heading in this task** — the phase already exists and this step leaves the count at 8.
  Insert one paragraph into its body, immediately after the line beginning "Pass the mode
  (`quick` or `deep`)":

  ```markdown
  **Set the discovery bar explicitly, and say so.** `core` is loaded by `/audit` and states "only
  report findings with >=80% confidence." That is correct where a finding goes straight to a human,
  and wrong here: the **Verify** phase runs adversarial verification, so a filter applied during
  discovery removes candidates a verifier would have confirmed and no later stage can recover them.
  For the duration of this phase the bar is **plausible exploit path, report if unsure with a low
  `confidence`**. The ≥80% standard is re-imposed at **Verify**, against evidence rather than a
  guess.
  ```

  The paragraph names the Verify phase rather than a number because Verify does not exist until
  Step 4 and moves twice after that. **Every cross-reference this plan adds inside a skill body
  names its phase, never numbers it** — the phase-sequence check guards heading numbers, and
  nothing guards a number written in prose.

- [ ] **Step 7: Rename Phase 4 and replace its body**

  Rename `## Phase 4 — Aggregate and Prioritize` to `## Phase 4 — Collate and Deduplicate` and
  replace its body with the block below. **No renumbering:** this step neither adds nor removes a
  phase, so the file stays at 8 and every other heading is untouched.

  | # | Heading | Change |
  |---|---|---|
  | 1 | `## Phase 1 — Parse the Input` | unchanged |
  | 2 | `## Phase 2 — Explore the Codebase` | unchanged |
  | 3 | `## Phase 3 — Run Domain Scans` | body gains the discovery-bar paragraph (Task 6) |
  | 4 | `## Phase 4 — Collate and Deduplicate` | renamed, body replaced (this task) |
  | 5 | `## Phase 5 — Present Findings` | unchanged |
  | 6 | `## Phase 6 — Offer GitHub Issue Creation` | unchanged |
  | 7 | `## Phase 7 — Create GitHub Issues` | unchanged |
  | 8 | `## Phase 8 — Done` | unchanged |

  Phase 4's body:

  ````markdown
  ## Phase 4 — Collate and Deduplicate

  Collect every finding block from every domain scan and turn them into one addressable set.

  **1. Union with the previous run.** If `.ai/audit/findings.json` exists, read it. Findings from
  that file whose `file` + `line` + `category` do not appear in this run are carried forward with
  `"carried_from": "<its scanned_at>"` — a scan that missed something the last one caught is
  variance, not a fix. Their guidance is explicit: the same prompt on the same target does not
  return identical findings, so union across runs rather than trusting any single pass.

  **2. Deterministic dedupe.** Two findings with the same `file`, `line`, and `category` are one
  finding. Keep the longer `description` and the higher `confidence`, and record the other's
  `domain` in a `domains` array. Do this before anything else — verification is the expensive
  stage, and every duplicate removed here is N subagents not spawned.

  **3. Cross-domain merge.** Two findings at the same `file:line` with *different* categories from
  *different* domains stay separate. They are two claims about one line, and a verifier can confirm
  one and refute the other.

  **4. Assign stable ids.** Sort by (`severity` desc, `file`, `line`) and assign `A-001`, `A-002`,
  … in that order. Ids are stable for the run and are what every later phase refers to.

  **5. Write the artifact.** Create `.ai/audit/` if absent and write `.ai/audit/findings.json`:

  ```json
  {
    "repo": "{owner}/{name}",
    "scanned_at": "{ISO 8601}",
    "mode": "quick",
    "domains": ["security", "tech-debt"],
    "findings": [
      {
        "id": "A-001",
        "domain": "security",
        "domains": ["security"],
        "file": "src/db/users.ts",
        "line": 42,
        "evidence": "const q = `SELECT * FROM users WHERE id = ${req.params.id}`",
        "category": "sql-injection",
        "severity": "high",
        "effort": "small",
        "confidence": 0.6,
        "title": "User id interpolated into a raw SQL string",
        "description": "…",
        "recommendation": "…"
      }
    ],
    "summary": {"total": 1, "critical": 0, "high": 1, "medium": 0, "low": 0, "deduped": 0, "carried": 0}
  }
  ```

  `.ai/` is worker session scratch and is gitignored. If the target repo does not ignore `.ai/`,
  say so once and continue — do not edit the user's `.gitignore` during an audit.

  Display the summary table:

  ```
  Domain          | Critical | High | Medium | Low | Total
  security        |    2     |  3   |   1    |  1  |   7
  tech-debt       |    1     |  4   |   6    |  2  |  13
  ─────────────────────────────────────────────────────────
  Total           |    3     |  7   |   7    |  3  |  20
  Deduplicated: 4 | Carried from previous run: 1
  ```
  ````

- [ ] **Step 8: Update the audit skill's Error Handling section**

  At the end of `skill/audit/SKILL.md`, add to the `## Error Handling` list:

  ```markdown
  - If `.ai/audit/findings.json` exists but does not parse: rename it to
    `.ai/audit/findings.corrupt.json`, note it, and continue with this run's findings only. Never
    silently discard it — a corrupt artifact is a bug report.
  ```

- [ ] **Step 9: Run verification and commit**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: `structural checks pass`

  ```bash
  git add README.md CLAUDE.md skill/audit/SKILL.md skill/audit-security/SKILL.md skill/audit-accessibility/SKILL.md skill/audit-performance/SKILL.md skill/audit-tech-debt/SKILL.md
  git status --short
  git commit -m "feat(auditor): give findings stable ids and a JSON artifact" -- README.md CLAUDE.md skill/audit/SKILL.md skill/audit-security/SKILL.md skill/audit-accessibility/SKILL.md skill/audit-performance/SKILL.md skill/audit-tech-debt/SKILL.md
  ```

**Verification:**

Run: `jq -r '.verify.test' .hivrr.json | bash`
Expected: `structural checks pass`

Run: `grep -c '^## Phase [0-9]' skill/audit/SKILL.md`
Expected: `8`

**Exit criteria:** All four domain skills document the same twelve-field contract; `skill/audit/SKILL.md` Phase 4 unions, dedupes, assigns ids, and writes `.ai/audit/findings.json`; the discovery-bar override is stated once in Phase 3; the thirteenth check is green.

**Rollback:** `git revert` the commit. The artifact path is new, so no consumer breaks; delete `.ai/audit/` if a run created one.

**PR title suggestion:** `feat(auditor): give findings stable ids and a JSON artifact`

---

### Step 3: Shapes and the exclusion list — branch: `feat/audit-security-shapes`

**Context brief:** `skill/audit-security/SKILL.md`'s `## What to Look For` is a six-heading OWASP checklist naming specific APIs. Their prompting guide names that exact form as recall-worsening, because the model overfocuses on the enumerated classes. This step replaces it with vulnerability shapes — structural properties rather than API names — and adds the explicit `## Do Not Report` exclusion list that keeps noise down without narrowing discovery. Only `skill/audit-security/SKILL.md` changes; the other three domains are checklist-shaped for good reason (WCAG success criteria and performance patterns genuinely are enumerable).

**Dependencies:** Step 2 must be merged. It rewrites the `## Output Format` section of this same file.

**Tasks:**

- [ ] **Step 1: Add the fourteenth check**

  Append to the fenced block in `README.md`:

  ```bash
  # the security scan carries an explicit exclusion list
  grep -qxF '## Do Not Report' skill/audit-security/SKILL.md \
    || echo "NO EXCLUSION LIST skill/audit-security/SKILL.md"
  ```

- [ ] **Step 2: Update the check count in `CLAUDE.md`**

  Change `Thirteen checks:` to `Fourteen checks:` and append:

  ```
  ; and the security scan carries an explicit exclusion list
  ```

- [ ] **Step 3: Run verification and confirm the red state**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: exit 1, exactly one line —

  ```
  NO EXCLUSION LIST skill/audit-security/SKILL.md
  ```

- [ ] **Step 4: Replace `## What to Look For` in `skill/audit-security/SKILL.md`**

  Delete the six OWASP headings and their bullets. Write in their place:

  ```markdown
  ## What to Look For

  Look for these **shapes**. Each names a structural property, not an API. The same shape appears
  in languages and libraries this list does not mention, and that is the point — a checklist of
  named bug classes makes you overfocus on the names and walk past everything else. Read these to
  calibrate what exploitable looks like, then go read the code.

  **Attacker input alters the syntactic structure of an interpreted language.**
  The interpreter may be SQL, a shell, a template engine, an LDAP or XPath query, a regex, or a
  serialization format. The tell is a value crossing from data into grammar. A fully parameterized
  ORM query with one dynamically-built table name is this shape; a hand-rolled query with every
  value bound is not.

  **A value naming a resource is taken from the caller and never re-derived server-side.**
  Path traversal, IDOR, SSRF, and mass assignment are all this shape. The tell is that the
  identifier used to fetch or write is the one the caller supplied, and no step establishes that
  this caller is entitled to that resource.

  **A check and the use of what it checked are separated by something that can change.**
  TOCTOU on a file, an authorization decision cached across a privilege change, a balance read
  before a concurrent write. The tell is a gap between the guarantee and the action relying on it.

  **Trust is inferred from a property the attacker controls.**
  A request header, a `Host` value, a redirect target, a JWT `alg` field, a filename extension, a
  client-supplied role claim. The tell is a server-side decision resting on something that arrived
  with the request.

  **A secret is durable where it should be ephemeral, or readable where it should not be.**
  Credentials in source or committed config, tokens in logs or error bodies, PII in telemetry,
  passwords under a fast hash. The tell is a secret whose lifetime or blast radius exceeds its
  purpose.

  **Untrusted input drives an allocation, an index, or a recursion depth.**
  In C/C++ and in `unsafe`/FFI blocks this is memory corruption. In memory-safe languages it is
  algorithmic-complexity blowup and ReDoS. The tell is a size, count, or depth the attacker picks.

  **A guard exists but is not on every path to the thing it guards.**
  Auth middleware on the router but not on a second registration site; validation in the HTTP
  handler but not in the batch importer that calls the same sink. The tell is one sink, two
  callers, one guard.

  For every finding, trace three things and put them in the description: where untrusted input
  enters, what path reaches the sink, and what condition triggers it. A finding without that trace
  is a guess, and a verifier will treat it as one.

  If you find something exploitable that fits none of these shapes, **report it anyway.** The list
  calibrates the bar; it does not bound it.

  ### Deep mode only

  - **Dependencies**: a package manifest pinning a version with a known vulnerability, *and* a
    reachable call into the vulnerable code path. Version alone is not a finding — see below.
  ```

- [ ] **Step 5: Add the `## Do Not Report` section**

  Immediately after `## What to Look For`, before `## Severity Guide`:

  ```markdown
  ## Do Not Report

  Skip these even when technically present. Each is a false-positive class that costs a verifier a
  full round trip and returns nothing.

  - **Volumetric DoS, rate limiting, resource exhaustion.** But unbounded recursion, algorithmic
    complexity blowup, and ReDoS driven by untrusted input **are** reportable — they are the
    allocation/recursion shape above, not capacity planning.
  - **Memory-safety findings in memory-safe languages**, outside `unsafe` blocks and FFI
    boundaries.
  - **XSS in React, Angular, Vue, or Svelte**, unless it goes through `dangerouslySetInnerHTML`,
    `bypassSecurityTrustHtml`, `v-html`, `{@html}`, or an equivalent raw-HTML escape hatch. The
    framework auto-escapes; reporting the escaped path is noise.
  - **Anything in test files, fixtures, mocks, build scripts, documentation, or notebooks.**
  - **Missing hardening with no concrete exploit.** An absent security header, a permissive-looking
    default with no reachable consequence, "should use a stricter setting." If you cannot say what
    an attacker gets, it is not a finding.
  - **Environment variables and CLI flags as the attack vector.** These are operator-controlled;
    an operator who wants to compromise their own process does not need a vulnerability.
  - **Regex injection, log spoofing, missing audit logs, and open redirects with no auth
    consequence.**
  - **An outdated dependency version on its own.** Report it only when you can name the vulnerable
    function and show the code path that reaches it.

  This list narrows *noise*, not *scope*. Nothing here overrides the reporting bar in
  `## Output Format`: when you are unsure whether something belongs on this list, report it with a
  low `confidence` and let verification decide.
  ```

- [ ] **Step 6: Retire OWASP from the frontmatter and the intro**

  Two places outside `## What to Look For` still frame the whole skill as an OWASP pass, and the
  step's own `grep -c 'OWASP A0'` check would not catch either.

  In `skill/audit-security/SKILL.md`, change the frontmatter description:

  ```yaml
  description: Scan codebase for security vulnerabilities by vulnerability shape, with an explicit exclusion list
  ```

  and replace the sentence under `# Security Audit`:

  ```markdown
  Scan the codebase for security vulnerabilities. Reason from vulnerability *shapes* rather than a
  checklist of named bug classes, and skip the exclusions listed below.
  ```

  This is skill frontmatter, not a plugin description — the fifth check compares `CLAUDE.md`'s
  `### `plugin`` lines against `marketplace.json` and never reads a `SKILL.md` frontmatter
  description, so nothing here can drift a checked value.

- [ ] **Step 7: Update the skill description in `README.md`**

  In the `### `auditor`` table, change the `audit-security` row's Description cell to:

  ```
  | `audit-security` | Scan codebase for security vulnerabilities by shape, with an explicit exclusion list |
  ```

  The sixth check reads only the backticked names in column one, so the Description column is free
  to change. Do not touch the name.

- [ ] **Step 8: Run verification and confirm it passes**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: `structural checks pass`, exit 0.

- [ ] **Step 9: Commit**

  ```bash
  git add README.md CLAUDE.md skill/audit-security/SKILL.md
  git status --short
  git commit -m "feat(auditor): describe vulnerability shapes instead of an OWASP checklist" -- README.md CLAUDE.md skill/audit-security/SKILL.md
  ```

**Verification:**

Run: `jq -r '.verify.test' .hivrr.json | bash`
Expected: `structural checks pass`

Run: `grep -c 'OWASP' skill/audit-security/SKILL.md`
Expected: `0` — the checklist headings, the frontmatter description, and the intro sentence all stop framing this skill as an OWASP pass.

**Exit criteria:** `## What to Look For` names seven shapes and no APIs-by-class headings; `## Do Not Report` exists with eight exclusions; the fourteenth check is green.

**Rollback:** `git revert` the commit. Discovery reverts to the checklist; nothing downstream depends on the shape list.

**PR title suggestion:** `feat(auditor): describe vulnerability shapes instead of an OWASP checklist`

---

### Step 4: Adversarial verification — branch: `feat/audit-verify-phase`

**Context brief:** `skill/audit/SKILL.md` currently runs Phase 4 (Collate and Deduplicate) straight into Phase 5 (Present Findings) and Phase 7 (Create GitHub Issues). Nothing asks whether a finding is real. This step inserts a verification phase after collation: for each finding, N independent subagents re-derive the claim from the code with the stance "the scanner is wrong", and a majority decides. The failure mode this phase exists to prevent is inherited framing, so every spawn must set `subagent_type` — omitting it forks the orchestrator, and a fork carries every other finding's description and every prior verdict into a context that is supposed to be blind. `skill/planning/references/plan-review.md` is this repo's existing subagent-dispatch precedent; follow its shape. Phase count goes 8 → 9.

**Dependencies:** Step 3 must be merged. Verification needs the low discovery bar (Step 3 and Step 2) to have something worth verifying, and the `evidence` field (Step 2) as the verifier's starting point.

**Tasks:**

- [ ] **Step 1: Add the fifteenth check**

  Append to the fenced block in `README.md`:

  ```bash
  # the verify phase spawns typed subagents rather than forking
  vsec=$(awk '/^## Phase .* — Verify$/ { v = 1; next } v && /^## / { exit } v' skill/audit/SKILL.md)
  if [ -z "$vsec" ]; then
      echo "NO VERIFY PHASE skill/audit/SKILL.md"
    else
      printf '%s\n' "$vsec" | grep -qF 'subagent_type' \
        || echo "VERIFY MAY FORK skill/audit/SKILL.md (verify phase does not set subagent_type)"
    fi
  ```

- [ ] **Step 2: Update the check count in `CLAUDE.md`**

  Change `Fourteen checks:` to `Fifteen checks:` and append:

  ```
  ; and the audit verify phase spawns typed subagents rather than forking
  ```

- [ ] **Step 3: Run verification and confirm the red state**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: exit 1, exactly one line —

  ```
  NO VERIFY PHASE skill/audit/SKILL.md
  ```

- [ ] **Step 4: Add `--votes N` to Phase 1 of `skill/audit/SKILL.md`**

  In `## Phase 1 — Parse the Input`, add to the input forms list and the extraction list:

  ```markdown
  - `--votes N` — verifier votes per finding (default 3; `--votes 1` for a quick pass, `--votes 5`
    for high-stakes)
  ```

  ```markdown
  - `votes` — integer, default 3, clamped to 1–5
  ```

  And change the display line to:

  ```
  Display: `Audit: {domains.join(', ')} | mode: {mode} | votes: {votes}`
  ```

- [ ] **Step 5: Insert the verification phase and renumber**

  Insert `## Phase 5 — Verify` after Phase 4 and renumber the rest. Target numbering, all 9 phases:

  | # | Heading |
  |---|---|
  | 1 | `## Phase 1 — Parse the Input` |
  | 2 | `## Phase 2 — Explore the Codebase` |
  | 3 | `## Phase 3 — Run Domain Scans` |
  | 4 | `## Phase 4 — Collate and Deduplicate` |
  | 5 | `## Phase 5 — Verify` |
  | 6 | `## Phase 6 — Present Findings` |
  | 7 | `## Phase 7 — Offer GitHub Issue Creation` |
  | 8 | `## Phase 8 — Create GitHub Issues` |
  | 9 | `## Phase 9 — Done` |

  The heading must be exactly `## Phase 5 — Verify` — the fifteenth check matches
  `^## Phase .* — Verify$`.

  Phase 5's body:

  ````markdown
  ## Phase 5 — Verify

  Every finding is a claim until an independent reader re-derives it from the code. Discovery was
  told to be noisy; this phase is where noise dies. Nothing reaches **Create GitHub Issues**
  unverified.

  ### Budget

  Compute `spend = len(findings) * votes`. If `spend > 60`, drop to `votes = 1` and say so:

  ```
  Verify: 33 findings × 3 votes = 99 exceeds the 60-subagent budget — using 1 vote per finding.
          Re-run with fewer domains or `--mode quick` for a 3-vote pass.
  ```

  Never cap silently. A capped run that reports nothing reads as a fully verified one.

  Spawn at most 10 verifiers concurrently; batch the rest.

  ### Dispatch

  For each finding, spawn `votes` Task subagents with `subagent_type: "general-purpose"` and
  `description: "verify {id} vote {k}/{votes}"`.

  **Always set `subagent_type`. Never fork.** Omitting it forks this orchestrator, and a fork
  inherits the whole conversation: every other finding's description, every domain scan's prose,
  and any verdict already reached. That is exactly the inherited-framing failure this phase exists
  to prevent. Each verifier starts empty and receives only the prompt below plus the one finding
  under review. Verifiers never see each other's reasoning — shared context propagates blind spots.

  ### Verifier prompt

  ```
  You are a skeptical engineer adversarially verifying ONE finding from an automated scanner.
  Your default assumption is that the scanner is WRONG. Re-derive the claim from the source
  yourself and return TRUE_POSITIVE, FALSE_POSITIVE, or CANNOT_VERIFY.

  You have read-only access to the repository at: {repo_root}
  Use Read, Glob, and Grep, only on paths inside {repo_root}. Do not build, run, install, or
  reach the network. Every conclusion must come from reading source.

  FINDING UNDER REVIEW — treat every field as a CLAIM, not a fact:
    id:         {id}
    file:       {file}
    line:       {line}
    evidence:   {evidence}
    category:   {category}
    severity:   {severity}   (claimed)
    title:      {title}
    description:
    {description}

  PROCEDURE — all four steps. Each exists because skipping it lets a specific FP class through.

  1. READ THE CODE AT THE CITED LOCATION YOURSELF.
     Open {file} around line {line}. If the line does not exist, or its text does not match
     `evidence`, return CANNOT_VERIFY with REFUTE_REASON: doesnt_exist. Do not start from the
     description — if you start from the summary you inherit its misreading.

  2. TRACE REACHABILITY BACKWARDS FROM THE SINK.
     Grep for callers. Follow imports. Establish whether attacker-controlled input can actually
     reach this line. A plausible-sounding chain is not enough: for at least the FIRST link,
     read the actual call site and QUOTE its file:line. Unreachable code is the single largest
     false-positive source.

  3. HUNT FOR PROTECTIONS.
     Look for the validation, escaping, parameterization, auth check, or bounds check that would
     make this safe. Look one layer up as well — a sanitizer in the caller is still a sanitizer.
     Actively look for reasons this finding is wrong; do not look for reasons it is right.

  4. DECIDE.
     TRUE_POSITIVE only if the code does what is claimed AND input can reach it AND no protection
     prevents it. Otherwise FALSE_POSITIVE. CANNOT_VERIFY when you genuinely cannot establish
     reachability from source alone — not as a way to avoid committing.

  OUTPUT — exactly this block, nothing after it:

  VERDICT: <TRUE_POSITIVE | FALSE_POSITIVE | CANNOT_VERIFY>
  CONFIDENCE: <0.0-1.0>
  FIRST_LINK: <file:line of the caller you read, or "none">
  REFUTE_REASON: <unreachable | protected | misread_code | doesnt_exist | out_of_scope | none>
  RATIONALE: <two sentences, citing file:line>
  ```

  ### Tally

  Parse each verifier's trailing block, tolerating code fences and whitespace. If a verifier errors
  or returns nothing parseable, re-spawn it once; if the retry fails too, count it as
  `CANNOT_VERIFY` at confidence 0 and let the remaining votes decide.

  Per finding, record on the artifact:

  - `vote_counts`: `{"true_positive": x, "false_positive": y, "cannot_verify": z}` — named
    `vote_counts`, not `votes`, because `votes` is already the run-level knob from Phase 1
  - `votes_cast`: how many verifiers returned a parseable verdict for this finding, retries
    included. This is the denominator the issue body prints
  - `verified_confidence`: mean CONFIDENCE across the votes on the winning side, to one decimal
  - `first_links`: unique FIRST_LINK values — the reachability audit trail
  - `refute_reasons`: sorted unique REFUTE_REASON values from FALSE_POSITIVE votes
  - `rationale`: the RATIONALE from the highest-confidence vote on the winning side, verbatim
  - `verdict`: as decided below

  **Decide:**

  - Majority TRUE_POSITIVE → `verdict: confirmed`. Continues to the next phase.
  - Majority FALSE_POSITIVE → `verdict: refuted`. Dropped, but kept in the artifact with its
    reasons — a refuted finding that reappears next run should be recognizable.
  - No majority, or majority CANNOT_VERIFY → `verdict: needs_review`. Continues to the next phase,
    is presented in its own section, and **is never filed as an issue automatically**.

  Rewrite `.ai/audit/findings.json` with the verdicts attached.

  Display:

  ```
  Verify: 20 findings × 3 votes = 60 subagents
          confirmed 7 | refuted 11 | needs review 2
  ```
  ````

- [ ] **Step 6: Gate issue creation on the verdict**

  In what is now `## Phase 8 — Create GitHub Issues`, add at the top:

  ```markdown
  **Only findings with `verdict: confirmed` are filed.** A `needs_review` finding is offered to the
  user one at a time with its `refute_reasons` and `first_links`, and filed only on an explicit
  yes. A `refuted` finding is never filed and is never offered.
  ```

  And add to the issue body template, after the `## What's Wrong` section:

  ```markdown
  ## Verification

  **Verdict:** confirmed ({vote_counts.true_positive} of {votes_cast} verifiers)
  **Reachability:** {first_links}

  {rationale}
  ```

- [ ] **Step 7: Update Present Findings and Done**

  In `## Phase 6 — Present Findings`, add after the existing confirmed-findings display:

  ```markdown
  ### Needs review

  After the confirmed findings, display any finding with `verdict: needs_review` under its own
  heading. For each, show `file:line`, title, the `vote_counts` split, `refute_reasons`, and
  `first_links`. State plainly that these were not confirmed and will not be filed unless the user
  asks for them individually.

  If there are none, omit the section entirely rather than printing an empty heading.
  ```

  Then replace the completion block in `## Phase 9 — Done` with:

  ```
  WORKFLOW COMPLETE
  Domains scanned: {domains}
  Findings: {total} raw → {deduped} after dedupe → {confirmed} confirmed, {needs_review} need review, {refuted} refuted
  Verification: {votes} votes per finding{, capped note if the budget applied}
  Artifact: .ai/audit/findings.json
  GitHub issues created: {issue_numbers.join(', ') || 'none'}
  ```

- [ ] **Step 8: Add `--votes` to `command/audit.md` and `README.md`**

  In `command/audit.md`, add to the supported formats list:

  ```markdown
  - Append `--votes N` to set verifier votes per finding (default 3, range 1–5)
  ```

  and to the examples block:

  ```
  /audit security --votes 5
  ```

  In `README.md`'s `## Commands` block, change the audit line to:

  ```
  /audit security --mode deep --votes 5
  ```

  The ninth check extracts only the command name from these lines, so the flags are free.

- [ ] **Step 9: Run verification and confirm it passes**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: `structural checks pass`, exit 0.

- [ ] **Step 10: Commit**

  ```bash
  git add README.md CLAUDE.md command/audit.md skill/audit/SKILL.md
  git status --short
  git commit -m "feat(auditor): verify every finding adversarially before filing it" -- README.md CLAUDE.md command/audit.md skill/audit/SKILL.md
  ```

**Verification:**

Run: `jq -r '.verify.test' .hivrr.json | bash`
Expected: `structural checks pass`

Run: `grep -c '^## Phase [0-9]' skill/audit/SKILL.md`
Expected: `9`

Run: `grep -n 'subagent_type' skill/audit/SKILL.md`
Expected: at least one hit inside the Phase 5 body.

**Exit criteria:** Phase 5 exists, dispatches typed subagents, tallies votes, and writes verdicts back to the artifact; issue creation files only `confirmed` findings; the budget cap is reported when it applies; the fifteenth check is green.

**Rollback:** `git revert` the commit. Phase numbering returns to 1–8; the artifact keeps its Step 2 shape and simply carries no verdicts.

**PR title suggestion:** `feat(auditor): verify every finding adversarially before filing it`

---

### Step 5: Severity from preconditions — branch: `feat/audit-precondition-severity`

**Context brief:** Every domain skill maps category to severity — `skill/audit-security/SKILL.md:70` says auth bypass is high, remote code execution is critical, and so on, with no reference to what an attacker would first need. Their guidance is that category-anchored severity "isn't useful", and that severity must be judged separately from the verdict so that "this is real" does not inflate into "this is critical". This step adds a ranking phase after verification that re-derives severity from preconditions and reachability, and discards the discovery-time claim rather than adjusting it. Phase count goes 9 → 10.

**Dependencies:** Step 4 must be merged. Ranking runs on confirmed findings only, and the sixteenth check asserts it comes after Verify.

**Tasks:**

- [ ] **Step 1: Add the sixteenth check**

  Append to the fenced block in `README.md`:

  ```bash
  # severity ranking runs after verification, never before it
  vl=$(grep -n '^## Phase .* — Verify$' skill/audit/SKILL.md | cut -d: -f1 | head -1)
  rl=$(grep -n '^## Phase .* — Rank by Preconditions$' skill/audit/SKILL.md | cut -d: -f1 | head -1)
  if [ -z "$vl" ] || [ -z "$rl" ]; then
      echo "RANK ORDER skill/audit/SKILL.md (missing Verify or Rank phase)"
    elif [ "$rl" -lt "$vl" ]; then
      echo "RANK ORDER skill/audit/SKILL.md (Rank at line $rl precedes Verify at line $vl)"
    fi
  ```

- [ ] **Step 2: Update the check count in `CLAUDE.md`**

  Change `Fifteen checks:` to `Sixteen checks:` and append:

  ```
  ; and the audit ranking phase runs after verification rather than before it
  ```

  `w2n` resolves `sixteen` because Step 1 of this plan extended it. If `CHECK COUNT DRIFT` appears
  here reporting `says sixteen, README has 16`, the `w2n` extension was lost — restore it.

- [ ] **Step 3: Run verification and confirm the red state**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: exit 1, exactly one line —

  ```
  RANK ORDER skill/audit/SKILL.md (missing Verify or Rank phase)
  ```

- [ ] **Step 4: Insert the ranking phase and renumber**

  Insert `## Phase 6 — Rank by Preconditions` after Verify. Target numbering, all 10 phases:

  | # | Heading |
  |---|---|
  | 1 | `## Phase 1 — Parse the Input` |
  | 2 | `## Phase 2 — Explore the Codebase` |
  | 3 | `## Phase 3 — Run Domain Scans` |
  | 4 | `## Phase 4 — Collate and Deduplicate` |
  | 5 | `## Phase 5 — Verify` |
  | 6 | `## Phase 6 — Rank by Preconditions` |
  | 7 | `## Phase 7 — Present Findings` |
  | 8 | `## Phase 8 — Offer GitHub Issue Creation` |
  | 9 | `## Phase 9 — Create GitHub Issues` |
  | 10 | `## Phase 10 — Done` |

  The heading must be exactly `## Phase 6 — Rank by Preconditions`.

  Phase 6's body:

  ````markdown
  ## Phase 6 — Rank by Preconditions

  Confirmed findings only. Verification already decided the finding is real; this phase decides how
  bad it is, and the two judgments stay independent. "This is real" must not inflate into "this is
  critical" — a confirmed low is a common and correct outcome.

  **Discard the discovery-time severity.** Do not adjust it, do not average it in. It was assigned
  by an agent that had not traced reachability and had no verdict to reason from.

  Spawn one Task subagent per confirmed finding, `subagent_type: "general-purpose"`, all in one
  message, capped at 10 concurrent.

  ### Ranking prompt

  ```
  You are assigning severity to a CONFIRMED finding. Verification already happened — assume it is
  real. Your only job is to derive how bad it is.

  You may Read and Grep the repository at {repo_root}. Do not execute anything.

  FINDING:
    id:        {id}
    location:  {file}:{line}
    category:  {category}
    domain:    {domain}
    reachability evidence: {first_links}
    verifier rationale:    {rationale}

  STEP 1 — LIST THE PRECONDITIONS.
  Enumerate everything an attacker must already have before this finding is exploitable. Be
  concrete: "a valid session for any user", "network access to an internal-only port", "the
  ability to upload a file", "physical access to the host". Zero preconditions is a valid answer
  and should be stated as such.

  STEP 2 — STATE REACHABILITY.
  unauthenticated-remote / authenticated-remote / local-only / operator-only.

  STEP 3 — MAP TO SEVERITY.

    | Preconditions | Reachability          | Severity |
    |---------------|-----------------------|----------|
    | none          | unauthenticated-remote| critical |
    | none          | authenticated-remote  | high     |
    | one or two    | unauthenticated-remote| high     |
    | one or two    | authenticated-remote  | medium   |
    | three or more | any                   | low      |
    | any           | local-only            | low      |
    | any           | operator-only         | low      |

  Anchored examples, so the scale does not drift:
    critical — unauthenticated SQL injection on a public endpoint returning other users' rows
    high     — any authenticated user reads any other user's records by changing an id
    medium   — stored XSS requiring an admin to visit a page only admins can reach
    low      — a weak hash on a value that is never used as a credential

  STEP 4 — ESTIMATE EFFORT: trivial / small / medium / large.

  OUTPUT — exactly this block, nothing after it:

  PRECONDITIONS: <one per line, or "none">
  REACHABILITY: <unauthenticated-remote | authenticated-remote | local-only | operator-only>
  SEVERITY: <critical | high | medium | low>
  EFFORT: <trivial | small | medium | large>
  RATIONALE: <one or two sentences>
  ```

  ### Merge

  Overwrite each confirmed finding's `severity` and `effort` with the ranker's values, and attach
  `preconditions`, `reachability`, and `severity_rationale`. Re-sort by (`severity` desc,
  `verified_confidence` desc, `file`, `line`) and reassign ids `A-001…` in that order. Rewrite
  `.ai/audit/findings.json`.

  Report every finding whose severity moved:

  ```
  Rank: 7 confirmed | 3 downgraded (A-002 high→medium, A-005 critical→high, A-006 medium→low)
  ```

  Findings with `verdict: needs_review` keep their discovery-time severity and are labelled
  `unranked` wherever they are presented.
  ````

- [ ] **Step 5: Replace the severity guides in all four domain skills**

  In each of `skill/audit-{security,accessibility,performance,tech-debt}/SKILL.md`, replace the
  `## Severity Guide` severity table with:

  ```markdown
  ## Severity Guide

  **Severity you assign here is a first read, not a verdict.** The orchestrator re-derives it from
  preconditions after verification and overwrites whatever you set. Assign it anyway — it orders
  the report before ranking runs — but do not spend effort defending it, and do not inflate it to
  make sure a finding gets attention. Attention comes from surviving verification.

  Derive it from what an attacker or user must already have, not from the category name:

  | Preconditions | Reachability | Severity |
  |---|---|---|
  | none | `unauthenticated-remote` | critical |
  | none | `authenticated-remote` | high |
  | one or two | `unauthenticated-remote` | high |
  | one or two | `authenticated-remote` | medium |
  | three or more | any | low |
  | any | `local-only` or `operator-only` | low |

  Use those four reachability tokens exactly. They are the values the ranker emits and the ones
  persisted to `.ai/audit/findings.json`, so a second vocabulary here only makes the two reports
  read as if they disagree.
  ```

  Keep each file's existing **Effort** table unchanged — effort is orthogonal to preconditions.

  For `audit-accessibility`, read "preconditions" as assistive-technology conditions: a control
  unreachable by keyboard for every user has zero preconditions; a contrast failure that only bites
  at a specific zoom level has one or two.

- [ ] **Step 6: Point the label mapping and the completion block at the ranked severity**

  The `priority:p0..p3` label mapping in `## Phase 9 — Create GitHub Issues` now reads the ranked
  severity. The mapping itself does not change — add one line directly above it:

  ```markdown
  Severity here is the **ranked** severity from the **Rank by Preconditions** phase, never the
  discovery-time claim.
  ```

  Then add one line to the completion block in `## Phase 10 — Done`, after the `Verification:`
  line:

  ```
  Ranking:      {n} re-ranked, {d} downgraded, {u} left unranked (needs review)
  ```

- [ ] **Step 7: Run verification and confirm it passes**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: `structural checks pass`, exit 0.

- [ ] **Step 8: Commit**

  ```bash
  git add README.md CLAUDE.md skill/audit/SKILL.md skill/audit-security/SKILL.md skill/audit-accessibility/SKILL.md skill/audit-performance/SKILL.md skill/audit-tech-debt/SKILL.md
  git status --short
  git commit -m "feat(auditor): derive severity from preconditions after verification" -- README.md CLAUDE.md skill/audit/SKILL.md skill/audit-security/SKILL.md skill/audit-accessibility/SKILL.md skill/audit-performance/SKILL.md skill/audit-tech-debt/SKILL.md
  ```

**Verification:**

Run: `jq -r '.verify.test' .hivrr.json | bash`
Expected: `structural checks pass`

Run: `grep -c '^## Phase [0-9]' skill/audit/SKILL.md`
Expected: `10`

Run: `grep -n 'Preconditions' skill/audit-tech-debt/SKILL.md`
Expected: a hit in the `## Severity Guide` table header.

**Exit criteria:** Phase 6 exists after Phase 5, ranks confirmed findings from preconditions, discards the discovery claim, and reports every movement; all four domain severity guides are precondition-anchored; the sixteenth check is green.

**Rollback:** `git revert` the commit. Phase numbering returns to 1–9 and severity falls back to the discovery-time claim.

**PR title suggestion:** `feat(auditor): derive severity from preconditions after verification`

---

### Step 6: Security focus-area recon — branch: `feat/audit-security-recon`

**Context brief:** Phase 3 fans out by *domain* — security, accessibility, performance, tech-debt — but within security one agent reads the whole tree. Their guidance is that domains are not a partition of the search space, and that parallel finders converge on the same shallow bugs unless each is told precisely which slice to search. This step adds a recon phase before the scans that proposes 3–10 focus areas for the security domain and fans out one subagent per area. It is last because it multiplies discovery volume, and multiplying discovery before verification exists would multiply exactly the wrong thing. Phase count goes 10 → 11, and this step adds a stated count sentence so the existing seventh check guards it from then on.

**Dependencies:** Steps 1–5 must be merged. This step is only safe once verification, ranking, dedupe, and the exclusion list are all in place.

**Tasks:**

- [ ] **Step 1: Insert the recon phase and renumber**

  Insert `## Phase 3 — Recon — Security Focus Areas` after Explore the Codebase. Target numbering,
  all 11 phases:

  | # | Heading |
  |---|---|
  | 1 | `## Phase 1 — Parse the Input` |
  | 2 | `## Phase 2 — Explore the Codebase` |
  | 3 | `## Phase 3 — Recon — Security Focus Areas` |
  | 4 | `## Phase 4 — Run Domain Scans` |
  | 5 | `## Phase 5 — Collate and Deduplicate` |
  | 6 | `## Phase 6 — Verify` |
  | 7 | `## Phase 7 — Rank by Preconditions` |
  | 8 | `## Phase 8 — Present Findings` |
  | 9 | `## Phase 9 — Offer GitHub Issue Creation` |
  | 10 | `## Phase 10 — Create GitHub Issues` |
  | 11 | `## Phase 11 — Done` |

  The Verify and Rank headings keep their exact suffixes — `— Verify` and `— Rank by
  Preconditions` — so the fifteenth and sixteenth checks still match after renumbering.

  No cross-reference in any domain skill needs touching: every reference this plan added names its
  phase rather than numbering it, which is why renumbering four times costs nothing outside the
  heading lines and the tables above.

  Phase 3's body:

  ````markdown
  ## Phase 3 — Recon — Security Focus Areas

  Skip this phase entirely when `security` is not in the domain list.

  Domains are not a partition of the search space. One agent reading a whole tree finds the
  shallow bugs near the entry points and stops; several agents reading the same whole tree find
  the same shallow bugs several times. What prevents both is telling each agent precisely which
  slice to search.

  **Propose focus areas.** Read the source tree, the entry points, and the dispatch or routing
  code. Propose 3–10 focus areas in the form:

  ```
  <subsystem> (<function or file>) — <key operations>
  ```

  Examples:

  ```
  session handling (src/auth/session.ts) — token mint, refresh, revoke, cookie flags
  file upload (src/api/upload.ts) — multipart parse, extension check, storage path build
  admin surface (src/routes/admin/*) — role gate, bulk operations, impersonation
  ```

  Cap at 10. On a codebase with fewer than 15 source files, skip recon and run one sequential pass
  — partitioning a small tree costs more in duplicate reads than it saves.

  Areas must be **disjoint in what they own** and may overlap in what they read; the model reasons
  well across files, so do not lock an area to a single path.

  Display the proposed areas and the source-file count before continuing:

  ```
  Recon: 5 focus areas across 214 source files
    1. session handling (src/auth/session.ts) — token mint, refresh, revoke, cookie flags
    …
  ```

  Store `focus_areas`. The **Run Domain Scans** phase consumes it.
  ````

- [ ] **Step 2: Fan out the security scan in Phase 4**

  In `## Phase 4 — Run Domain Scans`, replace the `security` dispatch line with:

  ```markdown
  - `security` → load `audit-security` skill. When `focus_areas` is non-empty, spawn one Task
    subagent per focus area, `subagent_type: "general-purpose"`, capped at 10 concurrent, each
    given the `audit-security` brief with **its** focus area filled in and told that other agents
    cover the other areas so duplication is wasted effort. When `focus_areas` is empty — because
    recon was skipped or the tree is small — run one sequential pass.
  ```

- [ ] **Step 3: Add the focus-area brief to `skill/audit-security/SKILL.md`**

  After `## What to Scan`, before `## What to Look For`:

  ````markdown
  ## Focus Area

  When the orchestrator supplies a focus area, it is the scope of this scan. Read the code that
  the area names and the code it calls, and report only what you find there.

  ```
  Your focus area: {focus_area}
  Trust boundary: {trust_boundary, or "untrusted input → application state"}
  Other agents cover the other areas. Duplication is wasted effort.
  ```

  You may read outside your area to establish reachability — following a caller into another
  subsystem is how the reachability trace works. Report the finding at the sink inside your area.

  When no focus area is supplied, the whole tree is your area.
  ````

- [ ] **Step 4: Add the phase-count sentence to `skill/audit/SKILL.md`**

  Immediately under the `# Audit Workflow` heading, after the orchestrator sentence:

  ```markdown
  **Phase contract.** The eleven phases run in order. A phase with nothing to do reports and
  continues; it does not end the skill. Only an unrecoverable error stops the audit.
  ```

  The seventh check reads that count against the `## Phase N` headings, so from here on a phase
  added or removed without updating this sentence fails verification. That is the intent — the
  same guard `skill/init/SKILL.md` carries.

- [ ] **Step 5: Update the `auditor` section of `CLAUDE.md`**

  After the `**Skills:**` and `**Commands:**` lines under `### `auditor``, add:

  ```markdown
  The audit pipeline is **recon → scan → collate → verify → rank → file**. Discovery deliberately
  runs at a lower bar than `core`'s ≥80%, because the **Verify** phase re-derives every candidate
  adversarially and a filter applied during discovery removes candidates no verifier will ever see.
  Only findings with `verdict: confirmed` are filed as issues. The twelfth through sixteenth
  structural checks hold each of those properties.
  ```

  **Do not put this above the `**Skills:**` line, and never between the heading and the
  description line.** The fifth check reads the single line immediately after `### `auditor`` and
  compares it against `marketplace.json`; a blank line or any other content there reports
  `DESC BLANK AFTER HEADING auditor` or `DESC DRIFT auditor`.

- [ ] **Step 6: Update the `audit` row in `README.md`**

  ```
  | `audit` | Scan, verify, and rank findings across all domains (dispatches to the sub-skills below) |
  ```

- [ ] **Step 7: Run verification and confirm it passes**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: `structural checks pass`, exit 0.

  If `PHASE COUNT DRIFT skill/audit/SKILL.md (says eleven, has N)` appears, the renumbering in
  Step 1 is incomplete — find the gap with
  `grep '^## Phase [0-9]' skill/audit/SKILL.md`.

- [ ] **Step 8: Commit**

  ```bash
  git add CLAUDE.md README.md skill/audit/SKILL.md skill/audit-security/SKILL.md skill/audit-accessibility/SKILL.md skill/audit-performance/SKILL.md skill/audit-tech-debt/SKILL.md
  git status --short
  git commit -m "feat(auditor): partition the security scan into focus areas" -- CLAUDE.md README.md skill/audit/SKILL.md skill/audit-security/SKILL.md skill/audit-accessibility/SKILL.md skill/audit-performance/SKILL.md skill/audit-tech-debt/SKILL.md
  ```

**Verification:**

Run: `jq -r '.verify.test' .hivrr.json | bash`
Expected: `structural checks pass`

Run: `grep '^## Phase [0-9]' skill/audit/SKILL.md | sed 's/^## Phase *\([0-9]*\).*/\1/' | tr '\n' ' '`
Expected: `1 2 3 4 5 6 7 8 9 10 11`

**Exit criteria:** Phase 3 proposes 3–10 disjoint focus areas and skips on small trees; Phase 4 fans out one subagent per area for the security domain; `skill/audit/SKILL.md` states its phase count and the seventh check holds it; `CLAUDE.md` documents the pipeline under `### `auditor``.

**Rollback:** `git revert` the commit. Phase numbering returns to 1–10 and the security scan runs as a single pass — every other guarantee from Steps 1–5 survives.

**PR title suggestion:** `feat(auditor): partition the security scan into focus areas`

---

### Step 7: `review-pr` discovery bar and verification — branch: `feat/review-pr-verify`

**Context brief:** `skill/review-pr/SKILL.md` fetches a diff, analyses it in one pass, and posts the
result as a public PR comment. `skill/review-pr/SKILL.md:62` requires "≥80% confidence before
including it" while the finding is still being formed, so the filter runs during discovery and
nothing re-examines what gets through. This step lowers the discovery bar, sharpens the discovery
framing from "read the diff carefully" into a set of adversarial questions, and inserts a
verification phase whose defining rule is that a verifier reads the **whole file**, not the hunk —
"you forgot to handle X" where X is handled outside the diff is this skill's dominant false
positive. Phase count goes 7 → 8. The skill lives in the `dev` plugin, not `auditor`.

**Dependencies:** Step 6 must be merged. This step's verifier prompt is a diff-scoped adaptation of
the one Step 4 puts in `skill/audit/SKILL.md`, and its check lands on a count Steps 1–6 have already
moved.

**Tasks:**

- [ ] **Step 1: Add the seventeenth check**

  Append to the fenced block in `README.md`:

  ```bash
  # the PR review verifies findings and does not filter at discovery
  rsec=$(awk '/^## Phase .* — Analyze the Diff$/ { v = 1; next } v && /^## / { exit } v' \
           skill/review-pr/SKILL.md)
  if [ -z "$rsec" ]; then
      echo "REVIEW PHASE MISSING skill/review-pr/SKILL.md (no Analyze the Diff phase)"
    else
      printf '%s\n' "$rsec" | grep -qE '^ *- .*(>=|≥) *80' \
        && echo "REVIEW BAR AT DISCOVERY skill/review-pr/SKILL.md (threshold applied while finding)"
    fi
  rvsec=$(awk '/^## Phase .* — Verify$/ { v = 1; next } v && /^## / { exit } v' \
            skill/review-pr/SKILL.md)
  if [ -z "$rvsec" ]; then
      echo "REVIEW UNVERIFIED skill/review-pr/SKILL.md (no Verify phase)"
    else
      printf '%s\n' "$rvsec" | grep -qF 'subagent_type' \
        || echo "REVIEW MAY FORK skill/review-pr/SKILL.md (verify phase does not set subagent_type)"
    fi
  ```

  This is one check with four messages, matching how the fifth check reports several distinct
  disagreements under one `# ` comment. It counts as one toward the block total.

  **Both halves are guarded against a missing section.** An `awk` extraction that finds nothing
  returns empty, and `grep -q` over empty input fails — so an unguarded `grep` half goes silently
  green forever the day someone renames the phase. That is the failure mode the first check's
  `NO JSON FILES TRACKED` guard exists for, one level down.

  **The first pattern is anchored to a list item on purpose.** A bare `grep -qE '(>=|≥) *80'` over
  the phase would also match the override paragraph Task 4 adds, which quotes `core`'s rule in
  order to scope it — the check would fire on its own fix and could never go green. The defect has
  a shape: it is a **requirement bullet** in the finding criteria (`- ≥80% confidence before
  including it`), not prose. Match the shape, not the number.

- [ ] **Step 2: Update the check count in `CLAUDE.md`**

  Change `Sixteen checks:` to `Seventeen checks:` and append this to the end of the list:

  ```
  ; and `review-pr` verifies its findings rather than filtering them at discovery
  ```

- [ ] **Step 3: Run verification and confirm the red state**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: exit 1, exactly these two lines —

  ```
  REVIEW BAR AT DISCOVERY skill/review-pr/SKILL.md (threshold applied while finding)
  REVIEW UNVERIFIED skill/review-pr/SKILL.md (no Verify phase)
  ```

- [ ] **Step 4: Replace the finding requirements in `## Phase 4 — Analyze the Diff`**

  Replace the four-bullet requirements list at `skill/review-pr/SKILL.md:61-65` with:

  ````markdown
  Read the diff assuming it is broken. Not "check whether it is correct" — assume a defect is in
  there and your job is to name it. A review that opens by looking for reasons to approve finds
  reasons to approve.

  Ask each of these against every hunk, and answer in specifics rather than in the abstract:

  - **What input makes this fail?** Name the value, not the category.
  - **What did this silently change for an existing caller?** A changed default, a widened type, a
    renamed field, a newly-nullable return.
  - **What does the new test not cover that this change makes reachable?** An added branch with no
    added case is the most common gap in a green PR.
  - **What happens on the error path, the second call, and the concurrent call?** Most diffs are
    written for the first, successful, serial one.
  - **What does this assume about state it does not establish?** An ordering, an initialised field,
    a lock already held, a migration already run.
  - **What did the PR description promise that the diff does not do?** Compare `pr_meta.body`
    against what actually changed.

  **The diff is not the file.** Before writing a finding that something is missing — a guard, a
  null check, a validation, an early return — open the file and read around the hunk. Half the
  "you forgot to X" findings in diff review are X handled fifteen lines above the change.

  For every finding, require:
  - A specific `file:line` reference, in a file you actually opened
  - A clear explanation of why it matters
  - A concrete fix — not "refactor this", actual code or steps
  - A `confidence` from 0.0 to 1.0

  **Set the discovery bar explicitly, and say so.** `core` is loaded by `/review-pr` and states
  "only report findings with >=80% confidence." That was the right bar when this skill posted
  straight to the PR with nothing in between. It is the wrong bar now: the **Verify** phase
  re-derives every BLOCKER and REQUIRED from the file, so a threshold applied here removes findings
  a verifier would have confirmed and no later stage can recover them. For the duration of this
  phase the bar is **a plausible failure story, reported with a low `confidence` when unsure**. The
  ≥80% standard is re-imposed at **Verify**, against the file rather than against a hunch.
  ````

- [ ] **Step 5: Insert the verification phase and renumber**

  Insert `## Phase 5 — Verify` after Analyze the Diff. Target numbering, all 8 phases:

  | # | Heading |
  |---|---|
  | 1 | `## Phase 1 — Parse the Input` |
  | 2 | `## Phase 2 — Fetch PR/MR Context` |
  | 3 | `## Phase 3 — Read Repository Conventions` |
  | 4 | `## Phase 4 — Analyze the Diff` |
  | 5 | `## Phase 5 — Verify` |
  | 6 | `## Phase 6 — Compose the Review` |
  | 7 | `## Phase 7 — Post the Review` |
  | 8 | `## Phase 8 — Done` |

  The heading must be exactly `## Phase 5 — Verify` — the seventeenth check matches
  `^## Phase .* — Verify$`.

  Phase 5's body:

  ````markdown
  ## Phase 5 — Verify

  Discovery was told to assume the PR is broken. This phase assumes the reviewer is wrong. Nothing
  reaches **Post the Review** as a BLOCKER or a REQUIRED without surviving it.

  ### Scope and budget

  Verify **BLOCKER and REQUIRED findings only.** DEFERRED findings are suggestions rather than
  claims about correctness — there is nothing for a verifier to refute, and spending a subagent to
  confirm that a refactor would be nice is spend with no payoff. DEFERRED passes through unverified
  and is labelled as such in the composed review.

  `votes` defaults to **2**, not the audit's 3: the scope is one diff, the skill runs
  interactively, and a tie demotes rather than drops, so the third vote buys less here. `--votes`
  accepts 1–3. Spawn at most 10 verifiers concurrently.

  If BLOCKER + REQUIRED exceeds 20 findings, verify the BLOCKERs first and say so:

  ```
  Verify: 24 candidates exceeds the 20-finding budget — verifying 9 BLOCKER, deferring 15 REQUIRED
          to a follow-up review.
  ```

  Never cap silently.

  ### Dispatch

  For each candidate, spawn `votes` Task subagents with `subagent_type: "general-purpose"` and
  `description: "verify {tier} {n} vote {k}/{votes}"`.

  **Always set `subagent_type`. Never fork.** A fork inherits this conversation — the whole diff,
  every other finding, and the framing that produced them. The verifier's value comes entirely from
  not having seen any of that.

  ### Verifier prompt

  ```
  You are a skeptical engineer adversarially verifying ONE finding from a code review. Your
  default assumption is that the reviewer is WRONG. Re-derive the claim from the source yourself
  and return TRUE_POSITIVE, FALSE_POSITIVE, or CANNOT_VERIFY.

  You have read-only access to the checkout at: {repo_root}, at this PR's head commit.
  Use Read, Glob, and Grep. Do not build, run, install, or reach the network.

  FINDING UNDER REVIEW — treat every field as a CLAIM, not a fact:
    tier:        {BLOCKER | REQUIRED}
    file:        {file}
    line:        {line}
    title:       {title}
    explanation: {explanation}
    proposed fix: {fix}

  THE HUNK THE REVIEWER SAW:
  {the diff hunk containing {file}:{line}}

  PROCEDURE — all four steps.

  1. OPEN THE WHOLE FILE. Not the hunk. Read {file} around {line} with enough context to see the
     function, its callers within the file, and anything that runs before this point. The
     reviewer saw a hunk; you are here because a hunk is not a file. If the claim is that
     something is MISSING, this step is where most such claims die — search the file for the
     guard, the check, or the early return before accepting that it is absent.

  2. CHECK WHETHER THE DEFECT IS NEW. Read the pre-change side of the hunk. If the same defect
     exists there, this is PRE-EXISTING: real, but not something this PR introduced. Return
     FALSE_POSITIVE with REFUTE_REASON: pre_existing, and say so in the rationale — it belongs in
     an issue, not in this PR's blocking list.

  3. LOOK FOR THE PROTECTION, AND FOR THE INTENT. Grep for validation in the caller, a type that
     makes the state unreachable, a framework guarantee, a test that pins the behaviour. Then read
     the PR description: behaviour the author states is deliberate is not a defect unless it
     breaks something else.

  4. DECIDE. TRUE_POSITIVE only if the code does what is claimed AND the problem is reachable AND
     nothing already prevents it AND the PR introduced it.

  OUTPUT — exactly this block, nothing after it:

  VERDICT: <TRUE_POSITIVE | FALSE_POSITIVE | CANNOT_VERIFY>
  CONFIDENCE: <0.0-1.0>
  READ_RANGE: <file:start-end of what you actually read>
  REFUTE_REASON: <already_handled | not_reachable | misread_diff | intended_behaviour |
                  pre_existing | style_not_defect | none>
  RATIONALE: <two sentences, quoting the file:line that settles it>
  ```

  ### Tally

  Parse each verifier's trailing block. Re-spawn once on an unparseable or errored reply; count a
  second failure as CANNOT_VERIFY at confidence 0.

  - Majority TRUE_POSITIVE → keep the finding at its tier.
  - Majority FALSE_POSITIVE with `REFUTE_REASON: pre_existing` → **demote to DEFERRED** with the
    verifier's rationale appended and the words "pre-existing, not introduced by this PR". It is
    real; it is just not this PR's to block on.
  - Majority FALSE_POSITIVE for any other reason → drop, and count it.
  - Split, or majority CANNOT_VERIFY → **demote one tier** (BLOCKER → REQUIRED, REQUIRED →
    DEFERRED) and append "unconfirmed — one verifier could not reproduce this from the file". A
    diff review pays little for a real finding filed one tier low, and a lot for dropping it.

  Attach `READ_RANGE` from the highest-confidence winning vote to every surviving finding — it is
  what lets the author see the review read past the hunk.

  Display:

  ```
  Verify: 11 candidates (3 BLOCKER, 8 REQUIRED) × 2 votes
          kept 6 | demoted 2 | dropped 3
  ```
  ````

- [ ] **Step 6: Report the filtering in `## Phase 6 — Compose the Review`**

  Three edits to the template, all in `## Phase 6 — Compose the Review`.

  **1. The Summary reports what verification did.** Add to the `### Summary` instructions:

  ```markdown
  State the verification result in the Summary, always, including when nothing was dropped:

  > Verified {kept} of {candidates} candidate findings against the full files. {demoted} were
  > demoted a tier for want of a second confirmation, and {dropped} did not survive verification
  > and are not listed. DEFERRED items are suggestions and are not verified.

  The three numbers must account for every candidate: `kept + demoted + dropped == candidates`. A
  review that quietly discards half of what it found reads as a thorough review that found little.
  Say what was filtered.
  ```

  **2. Every surviving finding shows what the verifier read.** Change the per-finding format to:

  ```markdown
  **`{file}:{line}` — {finding title}**

  {explanation of what's wrong and why it matters}

  **Fix:** {concrete fix}

  **Verified:** read `{READ_RANGE}` — {one-line verifier rationale}
  ```

  The `**Verified:**` line is what shows the author the review read past the hunk. Omit it only on
  DEFERRED items, which are not verified.

  **3. Label DEFERRED without contradicting demotions.** Add under the
  `### 🟢 DEFERRED (nice to have)` heading in the template:

  ```markdown
  _Suggestions rather than defect claims, and not verified — except any item marked
  **pre-existing** or **unconfirmed**, which was verified and demoted to this tier._
  ```

  A `pre_existing` demotion is a confirmed defect that this PR did not introduce; a flat
  "unverified" stamp over the whole section would say the opposite.

- [ ] **Step 7: State how follow-up reviews verify**

  `## Phase 4 — Analyze the Diff` restructures a follow-up review into ✅ Fixed / ⏳ Remaining /
  🆕 New, and the Summary template edited above belongs to the first-review structure. Add to
  `## Phase 5 — Verify`, at the end of **Scope and budget**:

  ```markdown
  **On a follow-up review**, verify only 🆕 New findings. ⏳ Remaining items were verified when
  they were first raised and their verdicts stand — re-verifying them spends subagents to
  re-derive a conclusion already posted, and risks a split vote silently demoting a finding the
  author is already working on. ✅ Fixed items are claims about the new diff, not about a defect,
  and are confirmed by reading the diff rather than by a verifier.

  A follow-up review's Summary reports verification for the New section only:

  > Verified {kept} of {candidates} new findings against the full files. Prior findings keep the
  > verdicts from the earlier review.
  ```

- [ ] **Step 8: Parse `--votes N`, then document it**

  A flag documented on the command but not parsed by the skill is swallowed into `pr_number` or
  `inline_context`. All three touchpoints land in this task.

  **1. Parse it.** In `## Phase 1 — Parse the Input` of `skill/review-pr/SKILL.md`, add to the
  input-forms list:

  ```markdown
  - Any of the above followed by `--votes N` to set verifier votes per finding
  ```

  to the Extract list:

  ```markdown
  - `votes` — integer, default 2, clamped to 1–3
  ```

  and change the display line to:

  ```
  Display: `Review: PR/MR #{pr_number} in {repo_owner}/{repo_name} | votes: {votes}`
  ```

  Strip `--votes N` from the input **before** parsing `inline_context`, or the flag ends up in the
  free-text hint that Phase 4 reads as reviewer guidance.

  **2. Document it on the command.** In `command/review-pr.md`, add to the supported formats list:

  ```markdown
  - Append `--votes N` to set verifier votes per finding (default 2, range 1–3)
  ```

  **3. Show it in the README.** In `README.md`'s `## Commands` block, change the review line to:

  ```
  /review-pr 789 --votes 3
  ```

  The ninth check reads only the command name from that line, so the flag is free.

- [ ] **Step 9: Add the phase-count sentence to `skill/review-pr/SKILL.md`**

  Under `# Review PR/MR Workflow`, replace the line `Before starting: read this entire skill, then
  execute.` with:

  ```markdown
  Before starting: read this entire skill, then execute.

  **Phase contract.** The eight phases run in order. Discovery and verification are separate on
  purpose — Phase 4 is told to assume the PR is broken, Phase 5 is told the reviewer is wrong, and
  neither bar is the other's.
  ```

  The seventh check now holds that count against the headings, so a phase added or removed without
  updating this sentence fails verification.

- [ ] **Step 10: Note the split under `### `dev`` in `CLAUDE.md`**

  After the `**Skills:**` and `**Commands:**` lines under `### `dev``, add:

  ```markdown
  `review-pr` splits discovery from verification the same way `audit` does: Phase 4 finds at a
  deliberately low bar, Phase 5 re-derives every BLOCKER and REQUIRED from the **whole file** rather
  than the diff hunk, and only survivors are posted. DEFERRED is not verified and is labelled as
  opinion. The seventeenth structural check holds both halves.
  ```

  **Never insert anything between the `### `dev`` heading and its description line.** The fifth
  check reads that single line and compares it against `marketplace.json`; a blank line there
  reports `DESC BLANK AFTER HEADING dev`.

- [ ] **Step 11: Run verification and confirm it passes**

  Run: `jq -r '.verify.test' .hivrr.json | bash`
  Expected: `structural checks pass`, exit 0.

  If `PHASE COUNT DRIFT skill/review-pr/SKILL.md (says eight, has N)` appears, the renumbering in
  Task 5 is incomplete — find the gap with `grep '^## Phase [0-9]' skill/review-pr/SKILL.md`.

- [ ] **Step 12: Commit**

  ```bash
  git add README.md CLAUDE.md command/review-pr.md skill/review-pr/SKILL.md
  git status --short
  git commit -m "feat(review-pr): verify findings against the whole file before posting them" -- README.md CLAUDE.md command/review-pr.md skill/review-pr/SKILL.md
  ```

**Verification:**

Run: `jq -r '.verify.test' .hivrr.json | bash`
Expected: `structural checks pass`

Run: `grep -c '^## Phase [0-9]' skill/review-pr/SKILL.md`
Expected: `8`

Run: `grep -nE '(>=|≥) *80' skill/review-pr/SKILL.md`
Expected: exactly two hits, both prose inside the discovery-bar override paragraph — the sentence
quoting `core`'s rule, and the sentence re-imposing it at Verify. **Neither may start with `- `.**
A hit on a list item means the find-time requirement bullet survived, which is what the seventeenth
check reports.

**Exit criteria:** Phase 4 asks six adversarial questions, requires a whole-file read before any
"missing X" finding, and states the bar override; Phase 5 exists, verifies BLOCKER and REQUIRED with
typed subagents against full files, demotes rather than drops on a split, and routes `pre_existing`
to DEFERRED; the composed review reports what was filtered; the seventeenth check is green.

**Rollback:** `git revert` the commit. Phase numbering returns to 1–7 and review reverts to a single
pass at the ≥80% bar. Nothing in Steps 1–6 depends on this step.

**PR title suggestion:** `feat(review-pr): verify findings against the whole file before posting them`

---

## Future work

Not in this plan, recorded so it is not rediscovered:

- **Org-specific false-positive rules.** Their `--fp-rules FILE` maps cleanly onto an `audit.excludeRules` key in `.hivrr.json`, which already resolves per key with documented precedence. "We use Prisma everywhere, raw-query SQLi only" is exactly the kind of precedent that should live in the repo rather than the prompt.
- **Codify confirmed findings as static-analysis rules.** Their strongest cost argument: when a confirmed finding has a syntactically recognizable shape, have the model author a Semgrep rule for it. The discovery tokens are then spent once and the pattern is caught in CI for free.
- **Find-fix-find.** Iterating beats parallelism — fixing what a run surfaces forces the next run onto new ground. Would need audit to read the previous artifact's `confirmed` set and tell discovery what has already been fixed.

## Change Log

_No mutations yet._

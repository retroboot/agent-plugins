# Context — what exists today

Every citation below was checked on 2026-11-25 at commit `d05a4ab`. Preflight (README rule 2) means
re-checking the ones your slice touches.

## 1. Repository shape

- **What it is.** A Claude Code plugin marketplace whose product is JSON and Markdown. It ships no
  shell scripts, so verification is structural (`docs/verification.md:3-4`; `CLAUDE.md:221`). There
  is no build and no test runner.
- **Layout.** `.claude-plugin/marketplace.json` registers four plugins, `dev`, `auditor`, `planner`
  and `data-platform` (`.claude-plugin/marketplace.json:12,33,47,63`). Each skill is a directory
  `skills/<name>/` holding a `SKILL.md`. A plugin lists the skill directories it ships in its
  `skills` array (`.claude-plugin/marketplace.json:16-29`). `.agents/skills/<name>` is a symlink to
  `../../skills/<name>`, one per skill (`CLAUDE.md:88-96`; `docs/verification.md:158-168`).
- **A plugin install carries only the skills its entry names** (the Brief's claim; the repository states
  it only in prose, README **Open questions**). `skills/init/references/git-hygiene.md:67-69`
  states this as the reason `init` restates a `core` rule inline: "it ships in **both** `dev` and
  `planner`, and only `dev` ships `core`". A developer ruling of 2026-11-14 (#221) adds the other half:
  a skill loaded by name is found across *installed* plugins, and only relative file links such as
  `../core/SKILL.md` break across them (`docs/plans/planning-redesign/progress/slice-04.md:98-100`).
  So a `core` step resolves whenever `dev` is also installed, and the gap bites only without it. The
  ruling settles lookup by name across installed plugins, not which copy loads when two plugins ship
  the same skill (`decisions/ADR-001`, Consequences).
- **Where `core` is shipped.** `./skills/core` is in `dev`'s `skills` array only
  (`.claude-plugin/marketplace.json:17`). `planner` ships `init`, `session`, `brainstorm`, `spec`,
  `slice`, `cold-read` and `planning` (`.claude-plugin/marketplace.json:51-59`). `auditor` ships
  `audit` and the four `audit-*` skills, and neither `init` nor `session`
  (`.claude-plugin/marketplace.json:37-43`).
- **The six gaps the Brief names hold at this commit.** Each lists `core` in a numbered
  `Load the \`core\` skill` step while its plugin does not ship `core`: `auditor/audit`,
  `planner/brainstorm`, `planner/spec`, `planner/slice`, `planner/cold-read` and `planner/planning`
  (locations in §2). Comparing every `N. Load the \`{skill}\` skill` step of each plugin's skills with
  that plugin's `skills` array finds no other gap (§4 has the comparison).
- **The `dev` workflow skills load `init`, `session` and `core` in that order**, apart from `wave`,
  which has no `## Bootstrap` and relies on `work-issue`'s (`skills/wave/SKILL.md:18-21`). `work-issue` is the model
  (`skills/work-issue/SKILL.md:16-21`). `planning` loads the same three (`skills/planning/SKILL.md:46-51`).
  At `d05a4ab` the other five skills in the Brief load `core` alone (§2).
- **The config file.** Per-repo config is `.agent-plugins.json`, gitignored (`.gitignore:10`;
  `CLAUDE.md` section "Repo configuration"). It is absent from a fresh checkout, so this tree has none.
  Before v2.0.0 it was `.hivrr.json`. Only `init` reads that name, to migrate it
  (`skills/init/SKILL.md:121-125`; `skills/init/references/config.md:344-352`).
- **The structural checks are one fenced block**, `docs/verification.md:18-194`, run by the bootstrap
  value at `docs/verification.md:277`. It holds fourteen checks, each opened by a column-0 `# `
  comment (`docs/verification.md:19,28,32,39,45,61,78,95,104,116,124,135,158,170`). `CLAUDE.md:221`
  states the count ("Fourteen checks"), and check 8 compares it with the block
  (`docs/verification.md:95-102`).

## 2. What this work changes

The Brief's #310 names three options. Fates below use the glossary's option letters: (a) ship `core` in `planner` and
`auditor`; (b) drop the `core` step and restate inline what each skill relies on; (c) make the step
conditional. **Decided 2026-11-25: (a)** (`decisions/ADR-001`); the five `core`-only skills also
load `init` and `session` (`decisions/ADR-002`). The fates below are for that decision.

### 2.1 Bootstrap steps that name `core`

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/audit/SKILL.md` | 20-23 | `## Bootstrap` has one step, "Load the `core` skill — internalizes quality gates and severity prioritization standards". It loads neither `init` nor `session`. | changed in Slice 1: gains `init` and `session` steps before `core` (ADR-002) |
| `skills/brainstorm/SKILL.md` | 26-29 | One step: load `core`. No `init`. | changed in Slice 1: gains `init` and `session` steps before `core` (ADR-002) |
| `skills/spec/SKILL.md` | 36-39 | One step: load `core`. No `init`. | changed in Slice 1: gains `init` and `session` steps before `core` (ADR-002) |
| `skills/slice/SKILL.md` | 38-41 | One step: load `core`. No `init`. | changed in Slice 1: gains `init` and `session` steps before `core` (ADR-002) |
| `skills/cold-read/SKILL.md` | 40-43 | One step: load `core`. No `init`. | changed in Slice 1: gains `init` and `session` steps before `core` (ADR-002) |
| `skills/planning/SKILL.md` | 46-51 | Three steps in order: `init`, `session`, `core`. | kept |

Under ADR-002, `audit`, `brainstorm`, `spec`, `slice` and `cold-read` change in Slice 1 even under (a): each gains `init` and `session` steps before its `core` step.

### 2.2 Prose that relies on `core` outside a bootstrap step

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/planning/references/publish.md` | 189-192 | Publish step 3 says "Follow **Staging** in the `core` skill" and step 4 commits "as **Commit** in the `core` skill shows". The static comparison in the Brief does not see these. | kept: under ADR-001 `planner` ships `core`, so they resolve |
| `skills/core/SKILL.md` | 44-79 (Staging), 81-102 (Commit), 117-137 (Script Policy), 144-154 (Skill Composition) | The sections the other skills point at. `core` holds the pathspec rule at lines 76-79. | kept |

### 2.3 Skill lists that must agree with each other

`marketplace.json`, the `CLAUDE.md` `**Skills:**` lines and `README.md`'s per-plugin tables are held
equal by check 6 (`docs/verification.md:61-76`, table row at `docs/verification.md:207`).

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `.claude-plugin/marketplace.json` | 37-43 | `auditor` `skills` array: the five `audit` skills. | changed in Slice 1: gains `core` (ADR-001), `init` and `session` (ADR-002) |
| `.claude-plugin/marketplace.json` | 51-59 | `planner` `skills` array: `init`, `session`, `brainstorm`, `spec`, `slice`, `cold-read`, `planning`. | changed in Slice 1 (ADR-001) |
| `.claude-plugin/marketplace.json` | 16-29 | `dev` `skills` array. `core` is at line 17. | kept |
| `CLAUDE.md` | 118 | `**Skills:**` line for `auditor`. | changed in Slice 1 (ADR-001) |
| `CLAUDE.md` | 125 | `**Skills:**` line for `planner`. | changed in Slice 1 (ADR-001) |
| `CLAUDE.md` | 111 | `**Skills:**` line for `dev`, with `core` first. | kept |
| `README.md` | 42-50 | `### \`auditor\`` table, one row per skill. Check 6 reads rows shaped `\| \`name\` \|` in this section (`docs/verification.md:69,72`). | changed in Slice 1 (ADR-001) |
| `README.md` | 52-62 | `### \`planner\`` table. `init` and `session` rows read "Shared setup skill — see `dev`". | changed in Slice 1 (ADR-001) |
| `README.md` | 31 | The `core` row in the `dev` table. | kept |
| `README.md` | 21 | "`init` and `session` are shared setup skills included by `dev` and `planner`." | changed in Slice 1: names `auditor` (ADR-002) |
| `CLAUDE.md` | 136-141 | **Shared setup skills**: a sentence matching `README.md:21` in substance ("`init` and `session` are included by `dev` and `planner`, and every command loads them…", line 138), then the `init` and `session` bullets. | changed in Slice 1: names `auditor` (ADR-002) |

### 2.4 Checks and the docs that describe them

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `docs/verification.md` | 61-76 | Check 6 compares skill names across `marketplace.json`, `CLAUDE.md` and `README.md`. It never opens a `SKILL.md`, so it cannot see a bootstrap step that names a missing skill. | kept |
| `docs/verification.md` | 18-194 | The whole checks fence. A check is added by a column-0 `# ` comment plus its body. | changed in Slice 1: gains the new check (ADR-003) |
| `docs/verification.md` | 200-215 | The table of checks, one row each, numbered 1-14. | changed in Slice 1: the new check (ADR-003) |
| `CLAUDE.md` | 221 | "Fourteen checks: …" lists each check in prose. Check 8 fails with `CHECK COUNT DRIFT` when this word differs from the number of column-0 `# ` comments in the fence (`docs/verification.md:95-102`). | changed in Slice 1: the new check (ADR-003) |
| `CLAUDE.md` | 223 | Explains that the opening count is itself check 8. | kept |
| `skills/init/references/git-hygiene.md` | 64-72 | Records "only `dev` ships `core`" as the reason `init` restates the pathspec rule. | changed in Slice 1: the sentence stops being true (ADR-001) |
| `skills/init/SKILL.md` | 425-434 | Restates the commit-pathspec rule inline, and says `planner` is the plugin "which has no `core`" (lines 433-434). | changed in Slice 1: the sentence stops being true (ADR-001) |

### 2.5 The `init`-skipping gap

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/init/references/config.md` | 344-352 | Says `init` is the only skill that knows `.hivrr.json`, and that a skill loading only `core` (`spec`, `slice`, `cold-read`, `brainstorm`, `audit`) in an unmigrated repo "uses defaults until an `init`-loading skill runs". | changed in Slice 1 (ADR-002) |
| `skills/init/SKILL.md` | 119-125 | Phase 3 Step 1 migrates `.hivrr.json`. | kept |
| `docs/plans/move-to-retroboot/decisions/ADR-002-full-rename-clean-cut.md` | 28-32 | Records the gap as accepted by the developer. An accepted ADR is never edited (`skills/planning/references/pack-format.md` §1, **Lifecycle**). | kept |
| `docs/plans/move-to-retroboot/design.md` | 411 | Risk row R8: "`core`-only skills run first in an unmigrated repository and use defaults". | kept |
| `RELEASE-NOTES.md` | 24-28 | The v2.0.0 entry tells users to run an `init`-loading skill first, because `spec`, `slice`, `cold-read`, `brainstorm` and `audit` load only `core`. | kept |

## 3. Shared mechanics to reuse

- **Bootstrap step wording.** "Run in order before Phase 1:" followed by numbered
  "Load the `{skill}` skill — {purpose}" lines (`skills/work-issue/SKILL.md:16-21`;
  `skills/planning/SKILL.md:46-51`).
- **Inline restatement of a `core` rule in a skill that cannot link to `core`.** `init` keeps the
  pathspec rule inline and phase-agnostic (`skills/init/SKILL.md:429-434`), with the reason in
  `skills/init/references/git-hygiene.md:64-72`. The rule's source is `skills/core/SKILL.md:76-79`.
- **Lists held equal by check 6.** A skill added to or removed from a plugin changes three files:
  `.claude-plugin/marketplace.json`, the `**Skills:**` line in `CLAUDE.md` and the per-plugin table
  in `README.md` (`CLAUDE.md:18-21`; `docs/verification.md:61-76`).
- **Skill paths in `marketplace.json`.** A skill is registered as a directory without extension, for
  example `./skills/core` (`.claude-plugin/marketplace.json:17`; `CLAUDE.md` section "Path resolution").
- **Check shape.** Each check is one column-0 `# ` comment, then shell with no fence-shaped line in
  it, reading through `jq` on `marketplace.json` and `awk` or `sed` on Markdown
  (`docs/verification.md:61-76`). Output is silence on success and an upper-case tag with names on
  failure, such as `SKILLS DRIFT {plugin} claude` (`docs/verification.md:73-75`).
- **Rules for editing the checks fence.** One column-0 `# ` comment per check, nothing indented
  at column 0 that starts with `# `, no fence before this one in the file, and the block must run with
  stdin closed (`docs/verification.md:228-239`).
- **Test a detection-logic change on constructed input before editing the real target**
  (`docs/verification.md:219-225`).
- **Plan-pack fence rule.** Fences in `docs/plans/**/*.md` open with exactly three backticks tagged
  `bash`, `sh`, `mermaid` or `text` (check 14, `docs/verification.md:170-193`).
- **The check-count sentence.** `CLAUDE.md:221` spells the number as an English word followed by
  "checks:"; check 8 reads it with `sed` for `[A-Za-z][a-z]* checks:` (`docs/verification.md:98`).

## 4. How verification works here

There is no test runner. A change to `marketplace.json` or any `SKILL.md` is a behaviour change, so
verification is not skipped for it (`CLAUDE.md:225`).

**Structural checks.** `.agent-plugins.json` is gitignored and absent here (`.gitignore:10`), so
`jq -r '.verify.test' .agent-plugins.json | bash` (`README.md:177`) has nothing to read on a fresh
checkout. Run the bootstrap value that `docs/verification.md` documents for exactly this case
(`docs/verification.md:267-278`) from the repository root: `eval "$(grep -m1 '^bash -c ' docs/verification.md)"`.
Expected output at `d05a4ab`: the single line `structural checks pass`, exit status 0. On a
failure it prints each report line (for example `SKILLS DRIFT planner claude`,
`CHECK COUNT DRIFT CLAUDE.md says …`) and exits 1 (`docs/verification.md:277`). Find the line by its
start, `bash -c 'cd "$(git rev-parse --show-toplevel)"`, not by its number: adding a check moves it.

**What the checks do not prove for this work.** Check 6 compares skill lists only
(`docs/verification.md:61-76`). Nothing in the 14 checks compares a bootstrap step with its plugin's
`skills` array, which is the Root cause named in the README. Until a slice adds such a check, a
**comparison** written from the Brief's Repro shows the gap. It is not a command found in the repo;
it is the first command in the README Slice's **Verify**. For each plugin and each skill it ships,
it reads every line of that skill's `SKILL.md` starting `N. Load the \`{name}\` skill`, and prints
`GAP {plugin}/{skill} loads {name}` when `./skills/{name}` is not in that plugin's `skills` array.
Expected output at `d05a4ab`, exactly six lines (order as listed): `GAP auditor/audit loads core`,
`GAP planner/brainstorm loads core`, `GAP planner/spec loads core`, `GAP planner/slice loads core`,
`GAP planner/cold-read loads core`, `GAP planner/planning loads core`. After the fix, silence. A
`Load the \`{skill}\` skill` line that is not at the start of a numbered item (for example
`skills/planning/SKILL.md:183`) is not a bootstrap step and is not matched.

**Behavioural criteria with no test.** Whether a missing skill "fails or is skipped without a word"
at install time cannot be shown from this repository, because it happens in the Claude Code plugin
manager (DS4). A criterion about it is proven by the static comparison above, which shows every
named skill is shipped by the plugin that names it.

## 5. Glossary

| Term | Meaning |
|---|---|
| plugin | One entry in `.claude-plugin/marketplace.json` `plugins`: `dev`, `auditor`, `planner` or `data-platform` (`.claude-plugin/marketplace.json:12,33,47,63`). |
| ships | A plugin ships a skill when the skill's directory is in that plugin's `skills` array. A plugin install carries only the skills it ships (the Brief's claim, §1). |
| bootstrap step | Any line of a `SKILL.md` that starts `N. Load the \`{skill}\` skill`, under `## Bootstrap` or not (ADR-003; `skills/ship-pr/SKILL.md:57` is one outside it). A `Load the …` sentence that does not start a numbered line is not one. |
| gap | A bootstrap step naming a skill that the skill's own plugin does not ship. There are six at `d05a4ab`, all naming `core`. |
| `core` | The skill at `skills/core/SKILL.md`: quality gates, git safety, task completion, script policy. Shipped by `dev` only at `d05a4ab`; by `dev`, `planner` and `auditor` after the fix (ADR-001). |
| `init`-loading skill | A skill whose bootstrap loads `init`, so it migrates `.hivrr.json` before reading config: at `d05a4ab`, every `dev` workflow skill but `wave` (which runs `work-issue`), and `planning`; after the fix the five `core`-only skills as well (ADR-002). |
| core-only skill | At `d05a4ab`, a skill whose bootstrap loads `core` and nothing else: `spec`, `slice`, `cold-read`, `brainstorm` and `audit`. After the fix there are none (ADR-002). |
| option (a) / (b) / (c) | #310's three options, in the Brief's order: (a) ship `core` in `planner` and `auditor`; (b) drop the `core` step and restate inline what each skill relies on; (c) make the step conditional. |
| structural check | One of the numbered checks in the fence at `docs/verification.md:18-194`, run by `verify.test`. "Check 6" is the skill-list comparison. |
| skill-list agreement | Check 6's condition: `marketplace.json`, the `CLAUDE.md` `**Skills:**` lines and the `README.md` per-plugin tables name the same skills for each plugin. |
| `{sha}` form | A citation is `path:line` and is read at commit `d05a4ab`. |

# Context — what exists today

Every citation below was checked on 2026-11-24 at commit `52fa634`. Preflight (README rule 2) means
re-checking the ones your slice touches.

## 1. Repository shape

- **Product.** The planner plugin is Markdown and JSON. A skill is `skills/<name>/SKILL.md`,
  registered as a directory in `.claude-plugin/marketplace.json`; the planner's list is
  `.claude-plugin/marketplace.json:51-58` (`init`, `session`, `brainstorm`, `spec`, `slice`,
  `cold-read`, `planning`).
- **Shared planner references.** Phase skills reach the planning skill's references through
  `$CLAUDE_SKILL_DIR/../planning/references/`. `cold-read` reads the pack format and its record
  template this way (`skills/cold-read/SKILL.md:20-21`).
- **Detail moves to references.** Every `SKILL.md` is kept under 400 lines, and detail goes to a
  `references/` folder next to it (commits `bb1c2b1` and `4830e81`). `skills/cold-read/SKILL.md` is
  397 lines today and has no `references/` folder, so anything this pack adds to it must go to
  `skills/cold-read/references/` or to `skills/planning/references/`, and leave a pointer in the skill.
- **No scripts.** The script policy (`skills/core/SKILL.md:117-137`) says when a script earns its
  place; the repo ships none (`CLAUDE.md`, **Script policy**). Checks that a
  skill runs are `bash` fences inside the skill, for example the slice **Headings** and **Trace**
  checks (`skills/slice/SKILL.md:239`, `skills/slice/SKILL.md:278`).

## 2. What this work changes

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/cold-read/SKILL.md` | 26-38 | Rules: the read stays cold, the reader classes and the author resolves, no code, never rewrite a round | changed: the panel's rules sit beside these; "stays cold" is kept for readers only |
| `skills/cold-read/SKILL.md` | 81-93 | **Slices to assign**: lists the slices; reads only round headers of earlier rounds | changed in the parallel-read slice |
| `skills/cold-read/SKILL.md` | 95-138 | Phase 2, Author Checks: fence check, slice Headings and Trace; findings recorded as `A1`, `A2` … | changed: the review panel runs after these checks and before any reader |
| `skills/cold-read/SKILL.md` | 140-150 | Round number; cap of 3 rounds per run; **Assign slices** picks about a third of the slices per round | changed: round 1 covers every slice through parallel readers |
| `skills/cold-read/SKILL.md` | 149-155 | **Choose the reader**: Explore with `model: haiku`, a default-model fallback, or stop when there is no subagent tool | kept for readers; each role card names its own model |
| `skills/cold-read/SKILL.md` | 157-200 | Builds a detached worktree of `{base}` with the pack copied in; checksum guard before and after each read | moved to `skills/cold-read/references/tree.md` in Slice 1, with a pointer, to make room under 400 lines; reused by the panel and by every parallel reader |
| `skills/cold-read/SKILL.md` | 202-246 | The reader prompt, the five report sections, and the incomplete-report rule | kept word for word for each reader; their reports are merged |
| `skills/cold-read/SKILL.md` | 252-269 | Phase 4, Classify: the class table and developer-only marking | changed: adds the panel's finding classes and the role each reader blocker traces back to |
| `skills/cold-read/SKILL.md` | 271-341 | Phase 5: developer-only questions asked at once; fixes; grep for restatements; write the round; next round or stop | changed: developer-only questions are asked as one batch; affected roles re-check fixes |
| `skills/cold-read/SKILL.md` | 343-368 | Phase 6: `Pass after {n} rounds.` (line 350), where `{n}` is the rounds of this run | changed: Result states the total rounds and this run's rounds |
| `skills/planning/references/templates/cold-read.md` | 1-39 | Record template: header (Model, Input, Rounds, Result), one `## Round N` with Questions, Contradictions, Citations, then `## Result` | changed: a panel section per round and a role column for reader blockers |
| `skills/planning/references/pack-format.md` | 29, 203 | Names `cold-read.md` as written by cold-read; `reviewed` means the cold read ended with zero blocking questions | changed only if the meaning of `reviewed` changes |
| `skills/planning/SKILL.md` | 285-306 | Phase 6 loads `cold-read` and reads `status`, `rounds` and `blocking` (`skills/planning/SKILL.md:64`) | kept: the result JSON keeps its fields, so the wrapper needs no change |

## 3. Shared mechanics to reuse

- Reader dispatch with a model override and a read-only type, recorded as
  `Haiku (Agent tool, model: haiku, Explore)` — `skills/cold-read/SKILL.md:153`.
- Fallback when the subagent tool has no model choice — `skills/cold-read/SKILL.md:154`.
- Reader tree: `git worktree add --detach "{tree}" {base}` with the pack copied in —
  `skills/cold-read/SKILL.md:179`.
- Read-only guard: the checksum listing run before and after each read —
  `skills/cold-read/SKILL.md:193-194`. Frontmatter `allowed-tools` does not scope a spawned
  subagent — `skills/cold-read/SKILL.md:188`. Slice 1 moves the tree and guard lines (157-200)
  to `skills/cold-read/references/tree.md`; slices after it cite that file.
- An exact, fill-in-the-blanks prompt with required report sections, and a completeness check that
  dispatches one more reader — `skills/cold-read/SKILL.md:202-246`.
- Author findings as Ids `A1`, `A2` …, blocking unless fixed before the reader sees the pack —
  `skills/cold-read/SKILL.md:132-138`.
- The restatement rule ("grep the pack for every restatement of the rule you changed") —
  `skills/cold-read/SKILL.md:293`.
- Checks named by section in another skill, with a warning to change both in one commit —
  `skills/slice/SKILL.md:232`.
- The prd **Assumptions** table with a "How to validate" column, which nothing runs today —
  `skills/planning/references/templates/prd.md:54-60`.
- Running independent fetches in parallel, as one step — `skills/review-pr/SKILL.md:86`.
- **Measured 2026-11-24 (prd Assumptions 2 and 3).** Two Agent calls in one message,
  `subagent_type: Explore` with `model: sonnet` and with `model: opus`, both ran: they reported
  Sonnet 5.5 and Opus 5.5, and their `date +%T.%N` readings were 0.14 s apart, so they ran
  concurrently.

## 4. How verification works here

The repo's structural checks are the fenced block in `docs/verification.md`, run by `.hivrr.json`
`verify.test`. From the repository root, run `eval "$(jq -r .verify.test .hivrr.json)"`.
Expected output: `structural checks pass`, exit 0. `.hivrr.json` is gitignored: scaffold it as
`docs/verification.md` documents (`CLAUDE.md`, **This repo's verify command can't be
auto-detected**). Without it the command prints nothing, and no output is a failure, not a pass. Two checks bear on this pack:

- **Phase headings** run `1..N` with any stated count matching (`CLAUDE.md:215`, the seventh
  check). Adding or renumbering a `## Phase` in `skills/cold-read/SKILL.md` must keep the sequence
  unbroken.
- **Pack fences** (`docs/verification.md:170-191`, check 14): every fence in `docs/plans/**/*.md` is
  three backticks tagged `bash`, `sh`, `mermaid` or `text`.

There is no test runner. A behavioural criterion is proven by a dry run recorded against its ID in
the slice's progress file: the skill is run on a fixture pack and the resulting `cold-read.md` is
read. The design's **Test strategy** names the fixture packs.

## 5. Glossary

| Term | Meaning |
|---|---|
| Role | One tight job in the planning team, defined once in a role card |
| Role card | A reference file defining a role: job, inputs, model, checklist, output table and blocking test |
| Facilitator | The main session running a phase skill. It dispatches roles, merges and triages their findings, and fixes the pack. It is never a role itself |
| Review panel | The roles that read the pack in parallel before any cold reader: Fact-checker, Test engineer, Editor and Trust reviewer, all four on every pass |
| Fact-checker | Role that proves or disproves every claim, citation and assumption about the repository with a read-only command |
| Test engineer | Role that checks every criterion can be proven and every Verify command runs now, or has a "would fail because…" note, with output that is the same on every run |
| Editor | Role that checks each rule is stated once, that its restatements agree, and that a fix diff left no restatement unchanged |
| Trust reviewer | Role that lists every outside party and input, and gathers every open trust decision into one questionnaire for the developer |
| Panel finding | One item in a role's output table: Id `P{role letter}{n}`, blocking yes or no, location, what is wrong, evidence |
| Cold reader | A fresh Haiku subagent that has never seen the pack and reads it as the executor would. Unchanged in meaning |
| Parallel round | One cold-read round that dispatches several cold readers at once, each on a different group of slices |
| Trace-back | Tagging each blocker a cold reader finds with the role whose checklist should have caught it |
| Round | One pass that ends with cold readers' reports classed and resolved. A panel pass is not a round: its findings are recorded in the round that follows it, or in the closing Result when no reader runs |
| Blocker | An item classed Blocking in Phase 4: the executor could not build the slice correctly without its answer |

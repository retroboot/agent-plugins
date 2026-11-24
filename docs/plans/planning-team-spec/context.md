# Context — what exists today

Every citation below was checked on 2026-11-24 at commit `f8e598f`. Preflight (README rule 2) means
re-checking the ones your slice touches.

## 1. Repository shape

- **Product.** The planner plugin is Markdown and JSON. Each skill is `skills/<name>/SKILL.md`. The
  phase skills this pack changes are `skills/spec/SKILL.md` (370 lines, 10 `## Phase` headings) and
  `skills/slice/SKILL.md` (385 lines, 7 `## Phase` headings).
- **Shared planner references.** Phase skills reach the planning skill's references through
  `$CLAUDE_SKILL_DIR/../planning/references/`. `spec` reads the pack format and templates this way
  (`skills/spec/SKILL.md:17-18`), and so does `slice` (`skills/slice/SKILL.md:18-19`).
- **Detail moves to references.** Every `SKILL.md` is kept under 400 lines, and detail goes to a
  `references/` folder next to it (`docs/plans/planning-team-review/context.md:15`). `spec` already
  has `skills/spec/references/` (`design.md`, `inventory.md`, `reroute.md`). `slice` has no
  `references/` folder. With 29 and 14 lines of headroom, any procedure this pack adds to either
  skill goes to a reference file, and the skill keeps only a pointer.
- **No scripts.** The repo ships no shell scripts (`CLAUDE.md`, **Script policy**). Checks a skill
  runs live as `bash` fences inside the skill, as `slice`'s Self-check does
  (`skills/slice/SKILL.md:239-249`).
- **One author today.** `spec` and `slice` are run by the main session itself, and every file they
  write is drafted by that session in one context: `spec` Phase 2 reads the code and writes
  `context.md` (`skills/spec/SKILL.md:118-140`), Phase 3 writes `prd.md`
  (`skills/spec/SKILL.md:155-158`) and Phase 7 writes `design.md` (`skills/spec/SKILL.md:277-284`).
  `slice` Phase 2 drafts the slices in the conversation (`skills/slice/SKILL.md:115`) and Phase 4
  writes `plan.md` (`skills/slice/SKILL.md:216`). Nothing outside that session checks any of them
  before the developer's checkpoint.
- **Child 1 built the team's base.** The role cards, the dispatch contract and the review panel are
  in `skills/planning/references/roles/` and `skills/cold-read/references/panel.md`
  (`docs/plans/planning-team-review/README.md`, Status `done`). This pack reuses them, and changes the panel
  only so that it dispatches reviewing cards (ADR-004) and its Fact-checker gains F7 (ADR-005).

## 2. What this work changes

### The phase skills

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/spec/SKILL.md` | 114-140 | Phase 2: the author reads the code, then writes `context.md` with a `path:line` for every claim, then re-reads it for missing citations | changed: a Scout drafts `context.md` and the Fact-checker checks it before Phase 3 |
| `skills/spec/SKILL.md` | 153-178 | Phase 3: the author writes `prd.md`, including Rules and examples | changed: an Analyst drafts `prd.md` |
| `skills/spec/SKILL.md` | 197-211 | Phase 4: the acceptance checkpoint shows `context.md`, the prd and any rule with no edge row, then asks approve, change or stop | changed: before it, the assumption probes run and the Trust reviewer reviews; their developer-only items are asked as one batch at the checkpoint |
| `skills/spec/SKILL.md` | 273-284 | Phase 7: the author writes `design.md` | changed: an Architect drafts `design.md` |
| `skills/spec/SKILL.md` | 13-15 | Files are the only state: a later run picks the work up from the files | changed: Phase 1 reads `handoff.md` for work in flight (ADR-008) |
| `skills/spec/SKILL.md` | 316-334 | Phase 8: the design checkpoint | changed: it also asks the Architect's held open points |
| `skills/slice/SKILL.md` | 45-112 | Phase 1: reads the pack, offers Re-slice | changed: resolves `{base}` and reads `handoff.md` |
| `skills/slice/SKILL.md` | 113-196 | Phase 2: the author drafts the slices in the conversation | changed: a Planner drafts the slices |
| `skills/slice/SKILL.md` | 214-318 | Phase 4: writes `plan.md` and runs the Self-check commands | changed: after the Self-check, the Test engineer and the Editor check the draft |
| `skills/slice/SKILL.md` | 322-346 | Phase 5: the checkpoint shows the slices, graph, traceability and any gap | changed: it also shows the gate's developer-only items as one batch |

### The role cards and dispatch

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/planning/references/roles/dispatch.md` | 1-9 | Defines a role as a card in `roles/`, dispatched by the Facilitator; no role dispatches another | changed: adds drafting roles alongside reviewing ones |
| `skills/planning/references/roles/dispatch.md` | 22-54 | One prompt frame, for reviewers only: "Review a plan pack with the checklist on your role card", "Change nothing in the pack", and a report of **Checklist run** and **Findings** | changed: a second frame for drafting roles |
| `skills/planning/references/roles/dispatch.md` | 56-72 | Tree and guard: a new detached tree per pass, built by `tree.md`, with the checksum guard before and after | kept; drafting roles run under the same guard |
| `skills/planning/references/roles/dispatch.md` | 97-102 | No subagent tool: the Facilitator works through each card in turn and says `Panel run by the Facilitator: not independent.` | changed: the same fallback covers drafting roles |
| `skills/cold-read/references/panel.md` | 13-14 | Panel pass step 1: "Every file in it except `dispatch.md` is a role card; the panel dispatches every card it finds" | changed: the panel dispatches reviewing cards only, so no drafting card is sent before the cold read |
| `skills/planning/references/roles/fact-checker.md` | 24-45 | Checklist F1-F6: citations, named things, what code does, library behaviour, fixed values, counts | changed: gains `## Kind` and **F7**, the assumption probe (ADR-004, ADR-005); it is the role that checks `context.md` |
| `skills/planning/references/roles/trust-reviewer.md` | 51-61 | Output adds a third section, the **Questionnaire** | changed: gains `## Kind`; it is dispatched before the acceptance checkpoint as well as in the panel |
| `skills/planning/references/roles/editor.md`, `test-engineer.md` | 1-10 | Card header: `# Role:`, `## Letter`, `## Model` | changed: each gains `## Kind`; both are dispatched before the slice checkpoint as well as in the panel |
| `skills/planning/references/roles/` | none | No card for a Scout, an Analyst, an Architect or a Planner | new cards |
| `skills/planning/references/gates.md` | none | Does not exist; the panel's procedure is `cold-read`'s own (`skills/cold-read/references/panel.md`) | new: the gate procedure `spec` and `slice` share |

### The templates

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/planning/references/pack-format.md` | 16-36, 136 | §1 Layout lists the pack's files; the Assumptions content-section row | changed: §1 lists `handoff.md`; the row names the probe result |
| `skills/planning/references/templates/handoff.md` | none | Does not exist | new: the handoff note's template (ADR-008) |
| `skills/planning/SKILL.md` | 114-116, 305-307 | Resume reads README pending lines; the gate before Approve and Publish | changed: Resume reads `handoff.md` first; the gate refuses while it exists |
| `skills/planning/references/templates/prd.md` | 54-60 | Assumptions table: `Assumption \| How to validate \| If false`, with nothing that records whether the check was run | changed: each row records its probe result |

## 3. Shared mechanics to reuse

- **The dispatch contract.** Model resolution, with `subagent_type: Explore` and the card's
  `## Model` (`skills/planning/references/roles/dispatch.md:11-20`); one prompt per role with the
  card pasted in verbatim and nothing else added (`skills/planning/references/roles/dispatch.md:24-28`);
  the completeness check, which re-dispatches a role once and then records it as not reviewed
  (`skills/planning/references/roles/dispatch.md:80-86`).
- **The card shape.** `# Role:`, then `## Letter`, `## Model`, `## Job`, `## Inputs`,
  `## Checklist`, `## Output` and `## Blocking test`, in that order
  (`skills/planning/references/roles/fact-checker.md:1-53`). A card may add a section, as the Trust
  reviewer adds `## Questionnaire` (`skills/planning/references/roles/trust-reviewer.md:57`).
- **Extra inputs.** A card's **Inputs** may list `{diff}` or `{seed}`, each added as one line after
  the Pack line (`skills/planning/references/roles/dispatch.md:25-26`). Both are files outside the
  tree, in a temporary directory of their own (`skills/planning/references/roles/dispatch.md:70-72`).
- **The tree and guard.** `skills/cold-read/references/tree.md` builds the tree with
  `mktemp -d` (`skills/cold-read/references/tree.md:22`) and
  `git worktree add --detach "{tree}" {base}` (`skills/cold-read/references/tree.md:28`), and runs
  the checksum guard. A difference outside git-ignored output voids the pass
  (`skills/planning/references/roles/dispatch.md:65-68`).
- **`{base}`.** The tree is built from `{base}`, which `cold-read` Phase 1 resolves: `origin/{integration}`
  after `git fetch origin {integration}`, falling back to the stale ref and then to `HEAD`, with a
  recorded line for each (`skills/cold-read/SKILL.md:54-60`). Neither `spec` nor `slice` resolves
  `{integration}` or `{base}` today, so a gate in either needs that step.
- **Triage.** A finding is Blocking when the executor could not build the slice correctly without
  it, and developer-only when it is a product decision or about an ADR
  (`skills/planning/references/roles/dispatch.md:88-95`).
- **Developer batch.** Every developer-only item reaches the developer in one message; nothing is
  asked twice; a deferred item stays unanswered (`skills/cold-read/references/panel.md:36-57`).
- **Re-check.** Every fix is checked by someone other than its author; a `{diff}` of a snapshot
  against the fixed pack goes to the Editor and to each role whose finding was fixed
  (`skills/cold-read/references/panel.md:69-84`). At most two re-checks after the panel pass
  (`skills/cold-read/references/panel.md:86`).
- **Checkpoints write first.** Every file is written to disk before the checkpoint that shows it
  (`skills/spec/SKILL.md:13-15`, `skills/slice/SKILL.md:14-16`).
- **No code in a pack.** Shell commands belong only in Verify (`skills/spec/SKILL.md:23-25`,
  `skills/slice/SKILL.md:24-26`).
- **Trace-back.** Every cold-read question or contradiction is traced to `fact`, `test`, `editor`
  or `trust` when a line of that card's job would have caught it, and otherwise to `reader`; `A`
  items to `author` (`skills/cold-read/SKILL.md:241-246`).

## 4. How verification works here

The repo's structural checks are the fenced block in `docs/verification.md`, run by `.hivrr.json`
`verify.test`. From the repository root, run `eval "$(jq -r .verify.test .hivrr.json)"`.
Expected output: `structural checks pass`, exit 0. `.hivrr.json` is gitignored: scaffold it as
`docs/verification.md` documents (`CLAUDE.md`, **This repo's verify command can't be
auto-detected**). Without it the command prints nothing, and no output is a failure, not a pass.
Three checks bear on this pack:

- **Phase headings** run `1..N` with any stated count matching (`docs/verification.md:78`, the
  seventh check). A new or renumbered `## Phase` in `spec` or `slice` must keep the sequence
  unbroken.
- **Agents symlinks** (`docs/verification.md:158`, the thirteenth check): a new skill directory
  needs a symlink under `.agents/skills/`. This pack adds no skill, so none is needed.
- **Pack fences** (`docs/verification.md:170`, the fourteenth check): every fence in
  `docs/plans/**/*.md` is three backticks tagged `bash`, `sh`, `mermaid` or `text`.

There is no test runner. A behavioural criterion is proven by a dry run recorded against its ID in
the slice's progress file: the skill is run on a fixture pack and the files it writes are read.
Child 1 proved its criteria this way, with seeded fixtures under `docs/plans/zz-dryrun-*` removed
before commit (`docs/plans/planning-team-review/progress/slice-05.md:48-61`).

## 5. Glossary

| Term | Meaning |
|---|---|
| Facilitator | The main session. It dispatches every role, builds each prompt, runs the guard, checks each report, triages findings and writes the pack files. No role dispatches another |
| Role | One tight job, defined once in a role card in `skills/planning/references/roles/` |
| Reviewing role | A role that reads a pack and reports findings: the Fact-checker, the Editor, the Test engineer and the Trust reviewer |
| Drafting role | A role that drafts one pack file: the Scout (`context.md`), the Analyst (`prd.md`), the Architect (`design.md`) and the Planner (`plan.md`) |
| Gate | A reviewing pass run on one stage's file before that stage's checkpoint, so its problems are caught in the stage that made them |
| Assumption probe | A read-only check that settles one row of the prd's Assumptions table before the design is written |
| Developer batch | Every developer-only item of a stage, sent in one message |
| Panel | Child 1's review pass of every reviewing role, run by `cold-read` before the first reader |
| Kind | A card's `## Kind`: `review` for a reviewing role, `draft` for a drafting role |
| Draft report | A drafting role's report: the drafted file between marker lines, then its open points |
| Open point | Something a drafting role could not settle, with the options; Id `D{letter}{n}` |
| Held | A finding or open point not fixed before the checkpoint, asked in its batch |

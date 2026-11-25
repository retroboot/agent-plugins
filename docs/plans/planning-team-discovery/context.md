# Context — what exists today

Every citation below was checked on 2026-11-24 at commit `54a2980`. Preflight (README rule 2) means
re-checking the ones your slice touches.

## 1. Repository shape

- **Product.** The planner plugin is Markdown and JSON, and each skill is `skills/<name>/SKILL.md`.
  `brainstorm` is registered in the `planner` plugin (`.claude-plugin/marketplace.json:46-61`, entry
  `./skills/brainstorm` at line 54). It is also listed in `CLAUDE.md:125` and `README.md:58`, and
  linked at `.agents/skills/brainstorm`. This pack adds no skill, so none of those lists changes.
- **`brainstorm` today is one agent.** Its 287 lines hold eight phases and no `references/` folder
  (`skills/brainstorm/SKILL.md`, headings at lines 26-246; the folder `skills/brainstorm/` holds
  only `SKILL.md`). A search of the file for `dispatch`, `subagent`, `role`, `Facilitator` and
  `Scout` finds nothing. Phase 2 reads "the relevant code, open issues, and recent commits" itself,
  silently (`skills/brainstorm/SKILL.md:72-76`). Phase 3 opens the conversation from that reading
  (`skills/brainstorm/SKILL.md:82-92`), and Phase 4 iterates until the developer has clarity
  (`skills/brainstorm/SKILL.md:105-118`).
- **Files are the only state.** Until the developer chooses to keep the brainstorm, nothing is
  written, and a new pack folder is created only in Phase 7 and left untracked
  (`skills/brainstorm/SKILL.md:14`, `skills/brainstorm/SKILL.md:201-226`). Resuming a pack at
  `published`, `executing` or `done` writes nothing (`skills/brainstorm/SKILL.md:61-64`).
- **`brainstorm` ends with a JSON result that `planning` reads.** The statuses are
  `BRAINSTORM COMPLETE`, `BRAINSTORM DISCARDED` and `BRAINSTORM NOT ROUTED`
  (`skills/brainstorm/SKILL.md:246-287`). `planning` Phase 2 loads `brainstorm` and branches on
  them (`skills/planning/SKILL.md:175-183`), and its result table names the keys
  (`skills/planning/SKILL.md:59-64`).
- **Roles live in one folder.** Every file in `skills/planning/references/roles/` except
  `dispatch.md` is a role card (`skills/planning/references/roles/dispatch.md:3-4`). The cards
  today are `analyst.md`, `architect.md`, `editor.md`, `fact-checker.md`, `planner.md`, `scout.md`,
  `test-engineer.md` and `trust-reviewer.md`. **There is no Historian card and no Skeptic card.**
  Their letters, in use by the existing cards, are N, R, E, F, L, S, V and T (line 5 of each card).
- **`brainstorm` is the only phase skill that dispatches no role.** `spec` dispatches the Scout,
  the Analyst and the Architect (`skills/spec/SKILL.md:131`, `:166`, `:309`), `slice` the Planner
  (`skills/slice/SKILL.md:112`), and the gates and `cold-read`'s panel the review cards
  (`skills/planning/references/gates.md:8-14`, `skills/cold-read/references/panel.md:13-16`).
- **Past packs the Historian would read.** `docs/plans/` holds five packs: `planning-redesign`,
  `planning-team`, `planning-team-review`, `planning-team-spec` and this one. Three are Status
  `done` and have a **Retro** (`docs/plans/planning-redesign/README.md:104`,
  `docs/plans/planning-team-review/README.md:122`, `docs/plans/planning-team-spec/README.md:107`)
  and a `cold-read.md` each. The parent is at `routed`, with an empty Retro
  (`docs/plans/planning-team/README.md:140`); this pack is not yet done and has none either.
  A pack's folder layout, with `cold-read.md` written by `cold-read`, is in
  `skills/planning/references/pack-format.md:16-36`.
- **Size convention.** Every `SKILL.md` is kept under 400 lines, with procedure in `references/`
  (`RELEASE-NOTES.md:15`; stated for the skills each pack changed in
  `docs/plans/planning-redesign/prd.md:72`, `docs/plans/planning-team-review/prd.md:92` and
  `docs/plans/planning-team-spec/prd.md:86`). The structural checks do not enforce it.
- **No scripts.** The repo ships no shell scripts (`CLAUDE.md:207-211`, `skills/core/SKILL.md:117`).
  Checks live as `bash` fences.
- **Areas the Brief names that this pack leaves alone.** `spec`, `slice`, `cold-read` and the
  `planning` wrapper's roster by route are out of scope (README Brief). Their entries in §2 say
  what they do today, because the new work reuses their mechanics.

## 2. What this work changes

Slice numbers do not exist yet (`slice` writes `plan.md` later), so the Fate column says what the
Brief asks, and `slice` assigns the slice.

### The `brainstorm` skill

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/brainstorm/SKILL.md` | 28-29 | Bootstrap: loads the `core` skill, nothing else | kept |
| `skills/brainstorm/SKILL.md` | 33-66 | Phase 1: parses the input; a pack path resumes an earlier brainstorm, with a read-only run at `published`, `executing` or `done` | kept |
| `skills/brainstorm/SKILL.md` | 70-76 | Phase 2: the one agent reads the relevant code, open issues and recent commits, silently, "before saying anything"; when resuming it also reads the pack folder | changed: Scout, Historian and Skeptic research runs here (Brief, "before") |
| `skills/brainstorm/SKILL.md` | 80-101 | Phase 3: presents 2-4 sentences of understanding and asks the single most important question; a resume opens from the saved Brief, Ruled out and Open questions | changed: findings reach the opening (Brief: the Facilitator "brings their findings into the conversation") |
| `skills/brainstorm/SKILL.md` | 105-130 | Phase 4: iterates one angle per reply, and holds Brief, Ruled out, Key insights and Open questions in the conversation, not in a file | changed: research continues "during the conversation" (Brief) |
| `skills/brainstorm/SKILL.md` | 134-172 | Phase 5: proposes Type, Size, Modifiers and Slug from the routing terms; skipped when resuming past `discovered`; "Not routed" ends the run | kept |
| `skills/brainstorm/SKILL.md` | 176-243 | Phases 6 and 7: asks keep or discard, then writes `README.md` from the template, untracked | kept (Brief names no change to what is written) |
| `skills/brainstorm/SKILL.md` | 246-287 | Phase 8: emits one JSON object as the entire final response | kept; `planning` reads it |
| `skills/brainstorm/SKILL.md` | none | No fallback for a session with no subagent tool | new: the README Route's "no-subagent fallback" |

### The role cards and dispatch contract

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/planning/references/roles/scout.md` | 11-27 | Kind `draft`; the Job is to draft `context.md` as the map of the repository; Inputs are `{tree}`, `{path}`, `{file}`, `{template}`, `{skill}`, `{format}`, `{date}`, `{sha}` | kept: the Scout's research use is a separate card (ADR-001) |
| `skills/planning/references/roles/` | none | No card for a Historian or a Skeptic | new cards |
| `skills/planning/references/roles/dispatch.md` | 9-11 | Each card's `## Kind` is `review` or `draft`; "A card with no `## Kind`, or any other value, is dispatched by no one" | changed: a third Kind, `research` (ADR-001) |
| `skills/planning/references/roles/dispatch.md` | 26-58 | The review prompt frame: "Review a plan pack", `Pack: {tree}/{path}`, a report of **Checklist run** and **Findings** | kept; a research frame is added beside it (ADR-001) |
| `skills/planning/references/roles/dispatch.md` | 72-126 | The drafting frame: a `File to draft`, a template, the skill phase and `{date}`/`{sha}`; the report is the file between marker lines, then open points | kept; a research frame is added beside it (ADR-001) |
| `skills/planning/references/roles/dispatch.md` | 60-70, 161-174 | **Base** resolves `{base}`, `{date}` and `{sha}` once per run; **Tree and guard** builds a detached tree of `{base}` with the pack copied in, and runs a checksum guard before and after | kept; a research pass is added beside it, copying nothing for a new topic (ADR-002) |
| `skills/planning/references/roles/dispatch.md` | 203-217 | **No subagent tool**: the Facilitator works through each card itself, for the panel, for a drafting role and for a gate | changed: a research paragraph (ADR-001) |
| `skills/cold-read/references/panel.md` | 13-16 | The panel dispatches every card whose Kind is `review`; for a card with no Kind "or any other value" it says `Card {file} states no kind; not dispatched.` | changed: step 1 skips a `research` card silently, the Brief's one `cold-read` exception (ADR-001) |
| `skills/cold-read/references/tree.md` | 28-29, 42-43 | Builds the tree with `git worktree add --detach` and copies `{path}` in; the guard runs `find {path}` | kept |
| `skills/planning/references/gates.md` | 8-14 | The gate table: Context, Acceptance and Slice gates, run by `spec` and `slice` | kept (out of scope) |
| `skills/spec/SKILL.md` | 128-133 | Phase 2 dispatches the Scout by the **Drafting frame** and checks its draft | kept (out of scope); the pattern a phase skill follows to dispatch a role |
| `skills/planning/SKILL.md` | 175-183 | Phase 2 loads `brainstorm` and reads its JSON result | kept (out of scope, child 4) |

### The sources the Historian reads

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `docs/plans/*/README.md` | **Retro** sections, e.g. `docs/plans/planning-team-spec/README.md:107-115` | A table of what the cold read predicted, what diverged, the slice and the lesson | kept (read only) |
| `docs/plans/*/cold-read.md` | e.g. `docs/plans/planning-team-spec/cold-read.md:10-327` | Per round: Questions, Contradictions and Citations checked, then a Result and Checklist proposals | kept (read only) |

## 3. Shared mechanics to reuse

- **Role card shape.** `# Role: <name>`, then `## Letter`, `## Model`, `## Kind`, `## Job`,
  `## Inputs`, `## Checklist` and `## Output` (`skills/planning/references/roles/scout.md:1-45`).
  A card may add a section: the Fact-checker adds `## Blocking test`
  (`skills/planning/references/roles/fact-checker.md:63-68`).
- **Models by role.** A card states its model once, in `## Model`. Existing values are `sonnet` for
  the Scout, Fact-checker, Editor and Test engineer, and `opus` for the Analyst, Architect, Planner
  and Trust reviewer (line 9 of each card). The Scout's choice is recorded in
  `docs/plans/planning-team-spec/decisions/ADR-002-drafting-role-models.md`.
- **Model resolution.** Dispatch with `subagent_type: Explore` and the card's model, and record it as
  `{Model} (Agent tool, model: {alias}, Explore)`. With no model choice, use the default model
  (`skills/planning/references/roles/dispatch.md:15-24`).
- **One prompt per role, nothing added.** The card is pasted verbatim, and only the extra inputs its
  **Inputs** lists are added (`skills/planning/references/roles/dispatch.md:26-33`,
  `skills/planning/references/roles/dispatch.md:80-88`).
- **Facilitator and no nesting.** The main session is the Facilitator. It builds each prompt, runs the
  guard, checks each report and triages, and no role dispatches another
  (`skills/planning/references/roles/dispatch.md:3-7`).
- **Completeness and one retry.** An incomplete report is re-dispatched once, then recorded, and the run
  continues (`skills/planning/references/roles/dispatch.md:186-192`; for drafts, `133-150`).
- **Triage.** A finding is Blocking when the executor could not build the slice correctly without it,
  and developer-only when it is a product decision or about an ADR
  (`skills/planning/references/roles/dispatch.md:194-201`).
- **Tree and guard.** A detached worktree of `{base}`, with a checksum guard before and after; a
  difference outside git-ignored output voids the pass
  (`skills/planning/references/roles/dispatch.md:161-174`, `skills/cold-read/references/tree.md:28-29`).
- **`{base}`, `{date}` and `{sha}`.** Resolved once per run: `branches.integration` from
  `.hivrr.json`, then the repository default branch, then `origin/HEAD`, then `main`, after
  `git fetch origin {integration}`, with a recorded line for the stale fetch and the `HEAD` fallback
  (`skills/planning/references/roles/dispatch.md:60-70`).
- **Drafting lines.** `Draft: {role} {model} — {file}, {o} open points`, and the checkpoint line
  `Drafted by the {role}, {Model} (Agent tool, model: {alias}, Explore).`
  (`skills/planning/references/roles/dispatch.md:152-159`).
- **Fallback sentences.** `Panel run by the Facilitator: not independent.` and
  `Drafted by the Facilitator: not independent.` are the wording the contract uses today
  (`skills/planning/references/roles/dispatch.md:203-211`).
- **Pointer from a skill to a reference.** A phase skill reaches shared references through
  `$CLAUDE_SKILL_DIR/../planning/references/` (`skills/brainstorm/SKILL.md:20-22`).
- **Resume rules in `brainstorm`.** Status `discovered` re-opens the conversation. Status `routed` to
  `approved` revises sections in place and lists each revision under Open questions. Status
  `published`, `executing` or `done` is a read-only run (`skills/brainstorm/SKILL.md:47-66`,
  `skills/brainstorm/SKILL.md:228-239`).
- **Roles settled by child 1.** Role cards live in `skills/planning/references/roles/<role>.md`,
  shared by every skill (`docs/plans/planning-team/README.md:135-137`).

## 4. How verification works here

The repo's structural checks are the fenced block in `docs/verification.md`, run by `.hivrr.json`
`verify.test`. `.hivrr.json` is gitignored (`.gitignore:10`) and absent from a fresh tree, so
scaffold it as `docs/verification.md` documents (`CLAUDE.md:163-170`). The command it holds is at
`docs/verification.md:277`, and it prints `structural checks pass` on success and the failing
messages otherwise. Without `.hivrr.json`, `eval "$(jq -r .verify.test .hivrr.json)"` prints a jq
error and exits 0, which is a failure, not a pass. The gates ran the command and it printed
`structural checks pass`. Three
checks bear on this pack:

- **Phase headings** run `1..N`, with any stated count matching (`docs/verification.md:78`). A new
  or renumbered `## Phase` in `skills/brainstorm/SKILL.md` must keep the sequence unbroken.
- **Agents symlinks** (`docs/verification.md:158`): a new skill directory needs a symlink under
  `.agents/skills/`. This pack adds no skill, so none is needed.
- **Pack fences** (`docs/verification.md:170`): every fence in `docs/plans/**/*.md` is three
  backticks tagged `bash`, `sh`, `mermaid` or `text`.

There is no test runner. A behavioural criterion is proven by a dry run recorded against its ID in
the slice's progress file: the skill is run on a fixture and what it writes or says is read. Earlier
packs used fixtures under `docs/plans/zz-dryrun-*`, removed before commit
(`docs/plans/planning-team-spec/progress/slice-04.md:29`).

## 5. Glossary

| Term | Meaning |
|---|---|
| Facilitator | The main session. It dispatches every role, builds each prompt, runs the guard, checks each report and triages findings. No role dispatches another |
| Role | One tight job, defined once in a role card in `skills/planning/references/roles/` |
| Role card | The file that defines a role: letter, model, kind, job, inputs, checklist and output |
| Kind | A card's `## Kind`: `review` (checks a pack and reports findings) or `draft` (writes one pack file as its report) |
| Scout | The role that reads the repository. Today a drafting role for `context.md`; the Brief also gives it a research use in `brainstorm` |
| Historian | The role the Brief defines as reading past packs, their Retros and their cold-read records for what earlier work learned about the same ground. No card exists yet |
| Skeptic | The role the Brief defines as looking for why the idea could fail, or should not be built. No card exists yet |
| Discovery research | The Brief's name for the Scout, Historian and Skeptic work run in parallel before and during `brainstorm`'s conversation |
| Past pack | A folder under `docs/plans/` other than the one being brainstormed |
| Retro | The README section a pack's final slice writes: what the cold read predicted, what diverged, and the lesson |
| Cold-read record | A pack's `cold-read.md`: one section per round, then a Result |
| Child pack | One of the four packs the XL parent `docs/plans/planning-team` is split into; this pack is child 3 |
| Brainstorm result | The one JSON object `brainstorm` emits as its final response, with `status`, `pack`, `pack_status` and `route` |
| Resume | A `brainstorm` run whose input is an existing pack path, handled by the pack's Status |

---
name: spec
description: Write the what-and-why files a plan pack's route requires — PRD, context, decisions, design, inventory and UX — each behind a developer checkpoint
license: MIT
compatibility: opencode
---

# Spec

Turns a routed plan pack into its specification: what to build, why, and the shape it takes. The
route decides which files exist. Nothing is sliced (that is `slice`) and nothing is built.

**Files are the only state.** Every file is written to disk before the checkpoint that shows it, so
a session that ends at any checkpoint leaves its work in the pack, with Status unchanged, and a
later run picks it up from the files.

The pack format of record is `$CLAUDE_SKILL_DIR/../planning/references/pack-format.md`; read it in
Phase 1. Templates for every file are in `$CLAUDE_SKILL_DIR/../planning/references/templates/`.
When this skill and the format disagree, the format is right.

Rules that hold in every phase:

- **No code.** No file this skill writes contains implementation code. Contracts are tables,
  behaviour is prose or Given/When/Then, and every fence is tagged `bash`, `sh`, `mermaid` or
  `text` (`pack-format.md` §6). Shell commands belong only in Verify.
- **Templates.** Write each file from its template, keeping the template's section order. Delete a
  section whose trigger does not apply, never leave one empty, and remove every `_Guidance:` line
  the content replaced.
- **Read order.** Whenever this skill creates a file in the pack, add its entry to the README
  **Read order** in the same step, using the template's wording and order and renumbering the list.
  `decisions/` gets one entry, however many ADRs it holds.
- **Never delete or rewrite wholesale.** An existing file is extended or revised section by
  section (Phase 1, Re-route, and `$CLAUDE_SKILL_DIR/references/reroute.md`).
- **Do not stage or commit.** The pack stays untracked until the `planning` wrapper publishes it.

## Bootstrap

Run before Phase 1:
1. Load the `core` skill — internalizes quality standards and architectural principles

---

## Phase 1 — Read the Pack and the Route

The input is a pack path, `docs/plans/<slug>`, optionally followed by `: {what to revise}` (the
`planning` wrapper's **Revise spec** step passes it). `{path}` is the part before any `: `; the
rest is the request. Read `{path}/README.md`.

- **No README there:** say `No pack at {path}` and go to Phase 10 with no files written.
- Read the header **Status**, **Type**, **Size** and **Modifiers**, and the **Route**, **Brief**,
  **Ruled out**, **Key insights**, **Question** and **Open questions** sections. List every other
  file already in the folder.
- **`handoff.md`**, if present (`$CLAUDE_SKILL_DIR/../planning/references/gates.md` **Handoff**): a
  **Gate pending** entry skips its file's drafter and re-runs only its gate; a **Spec pending** entry
  is removed when the checkpoint that shows its revised file approves.

Read `pack-format.md` §2 (routing matrix, size, modifiers, content sections, re-routing) and §3
(README contract and Status).

### Choose the mode

| Status | Type | Mode |
|---|---|---|
| `discovered` | any | Not routed yet. Say `Route not confirmed: run planning to confirm the Route first.` Go to Phase 10 |
| `routed` | Spike | **Spike question** |
| `specified` | Spike, and `decisions/` holds no `accepted` ADR | **Spike outcome** (a `proposed` outcome ADR resumes at the Phase 5 ADR checkpoint) |
| `specified` | Spike, and `decisions/` holds an `accepted` ADR | Say `Spike outcome already recorded; re-route it with planning.` Go to Phase 10 |
| `routed` | any other | **Specify** |
| `specified`, `sliced`, `reviewed` or `approved` | any other | **Re-route** (below) |
| `published`, `executing` or `done` | any | Read-only. Say `Pack is at Status {status}; spec will not edit a published pack.` Go to Phase 10 |

Size XL: the parent pack is a README only. Say `XL parent: plan each child pack with its own planning run.` and go to Phase 10.

### Required files

From the routing matrix row for the Type, and the size table, list:

- **Required:** each R entry, applying any "at M+" qualifier to the Size. Leave out README (it
  always exists) and plan (`slice` owns it, and at size S it is absent).
- **Optional:** each O entry, apart from plan. Each is proposed at the checkpoint of the phase that
  owns it, saying what it would hold. The developer decides; write it only on a yes.
- **ux.md:** when the modifiers include `ui` and Size is M or larger.
- **README Slice section:** at size S, for every type, Change included.

**Format gap.** If the Type, Size or a modifier is not in the routing tables, or the route asks for
a file they do not define, stop. Say
`Format gap: {what} is not defined in pack-format.md §2; nothing was written.` and go to Phase 10.
Never invent a file or a section.

### Re-route

Two forms, both working through every phase as in Specify but against the files already there:
the route grew after spec files were written (for example Feature to Rewrite), or, when the input
names what to revise, the same route (**Revise spec**), revising only the sections that answer the
request. **Before Phase 2, read `$CLAUDE_SKILL_DIR/references/reroute.md`**: which files and
sections each form adds or revises, ADR numbering, and how `planning`'s `Spec pending` line relates.
Read it too in Specify at `routed` when spec files are already in the folder (an earlier stopped
run, or a re-routed Spike); that run still sets Status on approval. These rules apply at every
checkpoint:

- For each revised section, add one line to the README **Open questions**. Grown route:
  `Revised by spec on {date}: {file} — {section}, for the re-route to {type}. Awaiting approval at the next checkpoint.`
  Same route:
  `Revised by spec on {date}: {file} — {section}, {what to revise}. Awaiting approval at the next checkpoint.`
- When the developer approves the checkpoint that shows that file, remove its lines; write "None."
  if the list is then empty. A stop before approval leaves them in place.
- A run with no request whose **Open questions** already hold `Revised by spec …` lines is a
  resumed revision: show those sections at the checkpoints for approval.
- Same route: the checkpoints show only the files revised.
- Status is not changed by a Re-route of either form (Phase 9).

Display: `Pack: {path} | Status: {status} | Route: {type}, {size}, {modifiers} | Mode: {mode}`, then
the required and optional file lists.

---

## Phase 2 — Research and Context

Spike outcome: skip to Phase 5.

Before writing anything, read the code: the areas the Brief names, their callers and tests, and the
repo's `CLAUDE.md` and contributing notes for its conventions. Understand it; do not design yet.

As you read, collect every API, helper, pattern, convention and test command the work will touch,
each with its exact `path:line`. This list replaces the old "Allowed APIs" list: it is what stops
an executor from inventing an API that does not exist.

When `context.md` is required, or is optional and the developer accepts it (a Spike proposes it
here, with the evidence it would record), the Scout drafts it, as
`$CLAUDE_SKILL_DIR/../planning/references/roles/dispatch.md` says: resolve `{base}` (**Base**),
dispatch `roles/scout.md` by **Drafting frame**, with `{skill}` this file's Phase 2, and check and
write its draft by **Draft completeness check** (with no subagent tool, **No subagent tool**).
Otherwise no Scout is dispatched. Whoever drafts it follows these rules and `templates/context.md`:

- The opening line gives `{date}` and `{sha}`, the short commit of `{base}`.
- **Every API, pattern and convention it names carries a `path:line` citation** that you opened
  and read in this run. A claim you cannot cite is either cited or removed; never write one
  unsupported.
- §2 tables each file the work changes, with its lines, current behaviour and fate.
- §3, Shared mechanics, is one bullet per item, each ending with its `path:line`.
- §4 gives the exact verify commands and their expected output, as found in the repo.
- §5, Glossary, holds every domain term the pack will use, with one meaning each.
- **Greenfield:** there is no code yet, so context records the chosen stack and conventions, as a
  seed for the new `CLAUDE.md`. Cite each choice to its source: a file in the repo if one exists,
  otherwise the Brief or the **Ruled out** option that chose it; Phase 5 adds the ADR citation.

Before moving on, re-read `context.md`: every named API, pattern and convention has its citation.
Then run the **context gate**, the Fact-checker, as `$CLAUDE_SKILL_DIR/../planning/references/gates.md`
says, with its **Gate pending** entry in `handoff.md`. Nothing it holds is asked before Phase 4.

---

## Phase 3 — Acceptance

### Spike question

Write the README **Question** section from `templates/README.md`, in template order (after Brief
and before Route): the single question the spike answers and its timebox. Take both from the Brief
and Key insights; ask the developer for whichever is missing. A Spike has no prd and no rules or
examples. Go to Phase 4.

### prd.md

When prd is required, write it from `templates/prd.md`. Include each section **exactly** when its
trigger applies to the route: `pack-format.md` §2 **Content sections** for Story map, Stories, Rules
and examples and Failure modes; the routing-matrix notes and `templates/prd.md` for the
Behaviour-preservation contract and Regression criteria. Add the template's always-present sections. Beyond those triggers:

- **Non-functional requirements:** every quality is a row; one with no need is `none` with a short
  reason, never omitted.

At size S, Rules and examples and Failure modes are not written in the prd. They go in the README
Slice (below), and the prd keeps everything else.

### Rules and examples

For each story (or each preservation or regression area):

- At least one rule, in one sentence, with an examples table whose columns make given, when and
  then explicit. A When shared by every row may sit in the column header.
- **At least 2 rows, with at least one edge or failure case.** Row IDs extend the criterion ID:
  `S-01.1.e1` is the first example under S-01.1, so each row names the criterion it exercises.
- **Refactor:** each row is a characterization case: an input and the output the current code
  really gives, read from the code (cite its `path:line`), including at least one invalid input.
- When a rule has only happy-path rows, add an edge or failure row. If no such case exists, do not
  invent one: note the rule for the checkpoint, ask the developer why none applies, and record the
  answer under the rule.

### README Slice, at size S

Write the README **Slice** section from `templates/README.md`, in template order (after Brief,
Question and Repro and root cause; before Route), with the line `Issue: # · Depends on: none`.
In this phase, write **Outcome** and **Acceptance**:

- **Outcome:** one or two sentences describing the observable result.
- **Acceptance:** criteria as rules and examples, in the form above. With a prd, list its criterion
  IDs; without one, number them `1.k`, with rows `1.k.eN`. Bug at S: these are the regression
  criteria.
- **Failure note:** one line naming the main failure and what the user sees, in place of a Failure
  modes table.

The rest of the Slice is written in Phase 7.

---

## Phase 4 — Acceptance Checkpoint

Show the developer, in this order:

- `context.md` (if written): a short summary and its citation count, its drafting line and any
  `{base}` fallback line, its settled open points, and each held one with its Id (Phase 2);
- the prd, or at size S the Slice's Outcome and Acceptance, or for a Spike the Question;
- any rule left without an edge or failure row, with the question of why none applies;
- in a re-route, each revised section and its Open questions line;
- each gate's Display lines, then every held item as one batch (`gates.md` **Checkpoint batch**).

Then ask: **approve**, **change** or **stop**. On approve, write the answers and the deferral lines,
and remove this checkpoint's Gate pending entries (`gates.md` **Handoff**).

- **Approve:** for a re-route, remove the approved files' revision lines from Open questions. Spike
  question: go to Phase 9. Otherwise go to Phase 5.
- **Change:** revise the files in place and show this checkpoint again.
- **Stop:** go to Phase 10. Status is unchanged; files written so far stay on disk.

---

## Phase 5 — Decisions

Every decision with at least one rejected option gets an ADR, written from `templates/adr.md` as
`decisions/ADR-NNN-<kebab-title>.md`. Numbers start at 001, or after the highest existing one, and
are never reused.

Required for Spike (the outcome only), Migration, Greenfield and Rewrite. Optional for Change, Bug,
Feature and Refactor: when the work has a decision with a rejected option, propose `decisions/` at
this checkpoint with the decisions it would record; write it only on a yes. Skip this phase when
there is none to record.

Sources: the **Ruled out** section (each option there is a rejected option), choices the developer
stated in the Brief or at Phase 4, and choices you made while writing the prd and researching.

- Status `accepted` for a decision the developer stated outright; `proposed` for one you made.
- **Proposed by** `developer` for an `accepted` one; `author (spec)` for a `proposed` one.
- Options: at least two, every rejected one with its reason.
- **Greenfield:** for each stack choice an ADR records, add the ADR's citation beside that choice's
  Brief or Ruled out citation in `context.md`.
- **Lifecycle** (`pack-format.md` §1). Only a `proposed` ADR is revised in place. An accepted ADR
  is never edited: when a decision it records changes, write a new ADR whose Context names it.
  Once the new ADR is accepted — at once when the developer stated it, otherwise at the checkpoint's
  Approve or Change — append to the old one's Status line `; amended by ADR-NNN, {what it changes}`,
  or `; superseded by ADR-NNN` when the new one replaces it. List both paths in `files`.

### Spike outcome

If `decisions/` already holds a `proposed` outcome ADR, go straight to its checkpoint below; never
write a second one. Otherwise ask the developer what the spike found, and write the outcome as the next ADR: the Context is the
Question and timebox, the Options are what was tried or considered, and the Decision is the
outcome. Status `accepted` when the developer states the outcome outright, otherwise `proposed`;
Proposed by and the lifecycle as above.

### ADR checkpoint

Show each `proposed` ADR, one at a time and in number order, and ask: **approve**, **change** or
**stop**.

- **Approve:** set its Status to `accepted (developer, {date})`, and append
  `; accepted by the developer at the spec ADR checkpoint` to its Proposed by line. If it amends
  or supersedes an accepted ADR, append that ADR's Status clause now (Lifecycle above).
- **Change:** revise it in place (it is still `proposed`), or record the developer's choice as the
  Decision with the chosen option moved and the reason for each rejection kept, accepted as in
  Approve. Show it again if it is still `proposed`.
- **Stop:** go to Phase 10. Status is unchanged.

Spike outcome: when every ADR is accepted, go to Phase 9.

---

## Phase 6 — Inventory

Migration and Rewrite only; otherwise skip. Write `inventory.md` from `templates/inventory.md`,
keeping the section for this type and deleting the other. **Read
`$CLAUDE_SKILL_DIR/references/inventory.md` first**: what Usage sites, Behaviour inventory and
Parity matrix each list. A Rewrite behaviour with no prd criterion gets one added to the prd now,
at the end of its story; Phase 8 shows it.

---

## Phase 7 — Design and Modifiers

### design.md

Required for Refactor, Migration, Greenfield and Rewrite, and for Feature at size M or larger.
Bug: required at size M or larger when the route has modifiers, so their sections always have a
home in design.md. Otherwise optional: when the fix crosses components, propose it before writing,
saying what it would hold, and write it only on a yes. Write it from `templates/design.md`, with
each section exactly when its `pack-format.md` §2 trigger applies. **Before writing or extending
it, read `$CLAUDE_SKILL_DIR/references/design.md`, design.md sections:** which sections to include,
and what State machines, Test strategy, Pre-mortem, a Rewrite cutover and Migration or Rewrite
rollback hold.

### Modifier sections

Each modifier on the route adds one `## Modifier: <name>` section, stating everything
`pack-format.md` §2, **Modifiers**, requires for it. It goes in `design.md`; with no design.md
(only at size S), in the README, after the Slice section and before Route. **When the route has any
modifier, read `$CLAUDE_SKILL_DIR/references/design.md`, Modifier sections, before writing them:**
what each must state, including the `ux.md` that `ui` at size M+ writes, and its inline parts at S.

### README Slice, at size S

Complete the Slice section from Phase 3: **Contracts** (tables, or "None new."), **Stop
conditions** (keep the template's preflight bullet, and add one per situation the executor must not
improvise through), **Verify** (exact commands in a `bash` fence with expected output, taken from
the repo, then the dry-run scenarios), **Pattern to follow** (`path:line` from Phase 2),
**Suggested path** (opening with the template's line) and **Files**.

### Self-check

Before the checkpoint, check every file this run wrote or extended:

- every fence is tagged `bash`, `sh`, `mermaid` or `text`, and holds no code;
- no section is empty, and no `_Guidance:` line is left;
- at size S, the Slice has all eight headings — Outcome, Acceptance, Contracts, Stop conditions,
  Verify, Pattern to follow, Suggested path, Files — each with content;
- every file created is in the README Read order.

Fix anything that fails before showing it.

---

## Phase 8 — Design Checkpoint

Show `design.md`, `ux.md`, `inventory.md`, the README modifier sections and, at size S, the rest of
the Slice — whichever were written. Also show each prd criterion Phase 6 added, with its story,
since the acceptance checkpoint never saw it. In a re-route, show each revised section and its Open
questions line.

Ask: **approve**, **change** or **stop**.

- **Approve:** for a re-route, remove the approved files' revision lines from Open questions. Go to
  Phase 9.
- **Change:** revise in place, re-run the Phase 7 self-check, and show this checkpoint again.
- **Stop:** go to Phase 10. Status is unchanged.

If this run wrote nothing for this checkpoint (for example a Bug at size M whose design.md was
declined), go straight to Phase 9.

---

## Phase 9 — Read Order and Status

Only reached when every checkpoint of this run was approved.

1. Confirm every file this run created is in the README **Read order**; add any that is missing.
2. Status. **No skill lowers Status**, and spec writes `specified` only when the current Status is
   `routed`, the one immediately before it:
   - Specify, or Spike question, at `routed`: set the header Status to `specified`.
   - Re-route: leave Status as it is and say `Status stays {status}: it advances only through the next approved checkpoint.`
   - Spike outcome: leave Status `specified`. Say `Outcome recorded in {ADR path}. Next: planning {path} to re-route, or close the Spike.`

Display: `Pack specified: {path} (Status: {status})` and the files written or extended.

---

## Phase 10 — Emit the Result

Emit one JSON object as your entire final response — no markdown, no preamble, no trailing text.
Write `null` bare, never as the string `"null"`.

```json
{
  "status": "SPEC COMPLETE | SPEC STOPPED",
  "pack": "docs/plans/{slug}",
  "pack_status": "{README Status after the run}",
  "files": ["docs/plans/{slug}/{file}"]
}
```

- `files` lists every path this run wrote or extended, README included when it was extended, in
  the order written. ADRs are listed one path each. It is `[]` when nothing was written.
- `SPEC COMPLETE` only when this run reached Phase 9, its last checkpoint approved.
- `SPEC STOPPED` for every other path to this phase: a stop at a checkpoint, a refused mode (no
  README, `discovered`, read-only, XL parent, Spike outcome already recorded) or a format gap.
  `pack_status` is the unchanged Status and `files` lists what was written before the stop.
- With no README at the path, `pack_status` is bare `null`.

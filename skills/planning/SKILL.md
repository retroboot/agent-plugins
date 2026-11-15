---
name: planning
description: Guide a topic, issue or existing plan pack through discovery, routing, specification, slicing and a cold read to published issues and a pack PR, resuming from the pack's README Status
license: MIT
compatibility: opencode
---

# Planning

The wrapper over the planner's phase skills. It takes a topic, issue references or an existing plan
pack, and walks it through every planning phase to a **plan pack** under `docs/plans/<slug>/`, one
published issue per slice, and a pack PR. It composes `brainstorm`, `spec`, `slice` and `cold-read`
rather than doing their work, and it resumes from whatever the pack's README Status says.

Keep moving through the phases. Stop only at a checkpoint or where a phase says to.

The pack format of record is `$CLAUDE_SKILL_DIR/references/pack-format.md`, and the templates are in
`$CLAUDE_SKILL_DIR/references/templates/`. Read `pack-format.md` §2 (routing) and §3 (README
contract and Status) before Phase 3. When this skill and the format disagree, the format is right.
Publish's tracker detail is in `$CLAUDE_SKILL_DIR/references/publish.md`.

Rules that hold in every phase:

- **Files are the only state.** Nothing is kept anywhere but the pack. Every phase skill writes its
  files before the checkpoint that shows them, so a session that ends at any checkpoint leaves the
  pack on disk with Status naming the last finished phase, and `planning docs/plans/<slug>` picks it
  up from there.
- **Each checkpoint lives in the skill that does the phase.** The wrapper sequences the phases and
  holds only the Route and Approve checkpoints. It writes only the README parts `pack-format.md` §3
  gives it: the Discover-skip README, the confirmed Type, Size, Modifiers and **Route**, the Bug's
  **Repro and root cause**, an XL parent's **Child packs**, the `progress/` Read order entry at size
  S, the Issues row, and the Status values for Route, a skipped phase, Approve and Publish.
- **No skill lowers Status.** The wrapper sets a Status only when the current one is immediately
  before it. The one exception is a Spike re-route, `specified` back to `routed` (Phase 4).
- **A skipped phase still passes through its Status.** When the route skips a phase, the wrapper
  sets that phase's Status without loading its skill, at the moment of the skip.
- **No code in a pack.** Nothing the wrapper writes holds implementation code; every fence is tagged
  `bash`, `sh`, `mermaid` or `text` (`pack-format.md` §6).
- **The pack stays untracked until Publish.** Do not stage or commit it before Phase 8.

---

## Bootstrap

Run in order before Phase 1:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality standards and architectural principles

---

## Reading a phase skill's result

Every phase skill ends with one JSON object as its entire final response. Capture it from the
skill's own completion and read only these fields:

| Field | Meaning |
|---|---|
| `status` | `{SKILL} COMPLETE` to advance; anything else is handled below |
| `pack` | The pack path, or bare `null` for a `brainstorm` with no pack |
| `pack_status` | README Status after the run, or bare `null` when the path has no README |
| extras | `brainstorm`: `route`. `spec`: `files`. `slice`: `slices`. `cold-read`: `model` (may be `null`), `rounds`, `blocking` |

- **`pack_status` is `null`:** stop. Say `No pack at {path}`. Never treat `null` as a Status. The
  exception is `BRAINSTORM DISCARDED` with `pack` `null`, which means nothing was kept (Phase 2).
- **`SPEC STOPPED`, `SLICE STOPPED` or `COLD READ STOPPED`:** a stop, not a failure. Do not advance.
  Show the developer the reason the skill gave (its last message before the JSON) and the unchanged
  Status. Files written so far stay on disk. Where the reason asks for a re-route (`slice`: over 12
  slices, a size mismatch, or a Bug's plan declined), offer **Re-route** (below); otherwise end with
  `Resume: planning {path}`. A `COLD READ STOPPED` round does not count as a cold read.
- **`COLD READ BLOCKED`:** handled in Phase 6.
- **`{SKILL} COMPLETE` with an unexpected `pack_status`:** stop and show both values. Never set
  the Status the skill did not. The expected value depends on the Status the run started at: the
  skill's own Status when it started at the one before (`spec` from `routed` gives `specified`,
  `slice` from `specified` gives `sliced`, `cold-read` from `sliced` gives `reviewed`), and the
  **unchanged** Status otherwise (`spec` Re-route, `slice` Re-slice, `cold-read` re-read, and a
  Spike outcome, which stays `specified`).

---

## Re-route

A route can grow at any checkpoint, including the wrapper's own Route checkpoint (S-03.4). Offer it
at Approve (Phase 7) and after a phase skill stops asking for one; on a resume, do not ask.

1. Run the Phase 3 checkpoint again with the new Type, Size and Modifiers, each with its reason.
   Never delete a pack file or rewrite one wholesale. Status stays where it is, except a Spike
   re-route, which sets `routed` (Phase 4).
2. Rewrite the header rows and the **Route** section as Phase 3 does. Add the sections the new
   route needs (Repro and root cause, Child packs) and keep every other section.
3. When Status is `sliced` or later, add to the README **Open questions** the line
   `Cold read pending after re-route on {date}.` (Phase 6 gates on it).
4. Then run the phases again from Specify: `spec` (its Re-route mode at `specified` or later adds
   the files the new route needs and lists every revised section in **Open questions**), `slice`
   (Re-slice, unless the size is S), and `cold-read`, then Approve. A re-route to XL instead writes
   **Child packs** (Phase 3) and stops.

---

## Phase 1 — Parse the Input

The input is one of:

- **A topic:** freeform text — a feature, problem, question or idea.
- **Issue references:** `#N`, several (`#N #M`), or Linear identifiers. Fetch each with the **Get
  issue** command from the loaded reference. Their titles, bodies and acceptance criteria are folded
  into the Brief (Phase 2).
- **A pack path:** `docs/plans/<slug>`. Resume it (below).

A topic or issue references go on to Phase 2.

**Not routed (S-09.3).** When the input is a batch of small, independent items — several unrelated
issues, a list of lint findings, a set of one-line fixes — planning adds nothing. Say
`Not routed: these are independent small items; planning adds nothing. Run ship-issue {items} directly.`
Write nothing and stop.

### Resume

Read `{path}/README.md`.

- **No README there** (S-02.2.e4): say `No pack at {path}`, and offer to start a new one. On yes,
  ask for the topic and go to Phase 2 with `{slug}` proposed as the slug. On no, stop.
- **XL parent:** when the Size row starts with `XL` and Status is `routed` or later, show **Child
  packs** with each child's Status (from its README, or `not started`), then stop. This comes before
  the table, so a pack re-routed to XL past `routed` never reaches `slice`.
- Otherwise read the header **Status**, **Type** and **Size**, and resume at the phase after the
  Status, without repeating a finished phase and without asking about the route (S-02.2):

| Status | Resume at |
|---|---|
| `discovered` | Phase 3, Route |
| `routed` | Phase 4, Specify |
| `specified` | Phase 5, Slice. Spike: Phase 4, **Spike outcome** |
| `sliced` | Phase 6, Cold read |
| `reviewed` | Phase 7, Approve, through the cold-read gate (Phase 6) |
| `approved` | Phase 8, Publish, through the same gate |
| `published` | Pack on `{integration}`: Phase 9, display the Next line, then stop. Not there: offer `publish.md` step 4 again |
| `executing` | Phase 9: display each slice's progress status (below), then the same Next line, then stop |
| `done` | Phase 9: display the README **Retro** (a Spike: its outcome ADR), then stop |

Any other Status: stop with `Unknown Status {status} in {path}/README.md`.

**Pack on `{integration}`** means `git ls-tree origin/{integration} -- docs/plans/{slug}/README.md`
prints a line, after `git fetch origin {integration}`. At `published` without it, the commit, push or
pack PR never finished; say so and offer to run step 4 again, which skips what is done.

**Progress status at `executing`.** Resolve `{integration}` as Phase 8 does, run
`git fetch origin {integration}`, and for each slice in `plan.md` (at size S, Slice 1) read the
Status line of `progress/slice-NN.md` with `git show origin/{integration}:docs/plans/{slug}/progress/slice-NN.md`.
A slice with no file there is `not started`.

Display: `Pack: {path} | Status: {status} | Resuming at: {phase}`, or for new input
`Topic: {topic} | Source: {topic | issue refs}`.

---

## Phase 2 — Discover

**Discover skip (6.4).** When the input already states the problem, the outcome wanted and the
scope — for example an issue with acceptance criteria — ask once: **Skip discovery?**

- **Yes:** write the README yourself, and do not load `brainstorm`:
  1. Propose a kebab-case slug from the topic. List `docs/plans/`; if the folder exists, append `-2`
     (or the next free number).
  2. Read `templates/README.md`. Run `git config user.name` for Owner and `date +%F` for Opened.
  3. Write `docs/plans/{slug}/README.md` from the template, in its section order: the title line;
     the header with Status `discovered`, Type, Size and Modifiers `not yet routed`, Issues
     `not yet published`, Owner and Opened; **Brief** from the input (the problem, the outcome and
     the scope, citing each issue ref); a **Route** section holding only `Not yet routed.`;
     **Read order** item 1 only; **How to execute this pack** verbatim with `<slug>` replaced;
     **Open questions** from the input, or "None."; **Retro** unchanged. Delete **Ruled out** and
     **Key insights** (Discover was skipped), and **Child packs**, **Question**, **Repro and root
     cause** and **Slice** (later phases add them). Remove every `_Guidance:` line.
  4. Display `Pack written: docs/plans/{slug}/README.md (Status: discovered)` and go to Phase 3.
- **No**, or the input does not state all three: load `brainstorm` below.

**Brainstorm.** Load the `brainstorm` skill with the topic, and the fetched issue text when there is
some. It holds its own conversation and asks keep or discard. Read its result (above):

- `BRAINSTORM COMPLETE` with `pack_status` `discovered`: go to Phase 3 with `pack` and `route`.
- `BRAINSTORM DISCARDED` with `pack` `null`: nothing was kept. When brainstorm said the work is not
  routed, repeat its `ship-issue` recommendation (S-09.3). Say `Nothing written.` and stop.

---

## Phase 3 — Route

**Checkpoint (held here).** Read the README header and **Route** section, `pack-format.md` §2, and
brainstorm's proposed route if there is one. Propose each part with a one-line reason (S-09.1):

- **Type:** one of Change, Bug, Spike, Feature, Refactor, Migration, Greenfield or Rewrite.
- **Size:** S, M, L or XL, from the size table. A Change is always S; a Spike is `n/a`.
- **Modifiers:** zero or more of data, integration, performance, security, ui, observability,
  public-api and infra. "No modifiers" is valid, with its reason.
- **Slug:** the folder's current name. The developer may change it.

Then, by route:

- **Bug with an unknown cause (S-09.2):** recommend running `debug` before specifying. On yes, load
  the `debug` skill with the symptom; if it is not among the session's skills, tell the developer to
  run it and resume with `planning {path}`, then stop with Status unchanged. Keep its root-cause
  report for the README.
- **XL (S-09.4):** propose splitting into child packs, `docs/plans/{slug}-{part}/`, one per
  subsystem or independent outcome, each sized M or L, with its order and dependencies. Never one
  pack with more than 12 slices.
- **Not routed (S-09.3):** if routing shows a batch of independent small items, say so as Phase 1
  does and stop. The README stays on disk at `discovered`.

```text
Route
  Type:      {type} — {reason}
  Size:      {size} — {reason}
  Modifiers: {modifiers or "none"} — {reason}
  Slug:      {slug}
  {Bug: debug recommended — {yes/no}. XL: child packs — {order. slug: covers}}
```

Ask: **confirm**, **change** or **stop**. Change revises the proposal and shows it again. Stop
leaves the README as it is (S-02.3).

**On confirm**, edit the README in place:

1. **Slug changed:** the pack is untracked, so rename the folder with `mv docs/plans/{old} docs/plans/{new}`,
   then replace `{old}` with `{new}` in the README's **How to execute this pack** rule 1.
2. **Header:** Type; Size as `S — 1 slice`, `M — 2–6 slices`, `L — 7–12 slices`,
   `XL — {n} child packs`, or `n/a` for a Spike; Modifiers, or `none`.
3. **Route section:** replace it with one bullet each for type, size and modifiers, with its reason.
   Remove the line `Proposed by brainstorm; not yet confirmed.`, and `Not yet routed.`
4. **Bug:** write **Repro and root cause** from `templates/README.md`, in template order (after Brief
   and any Question; before Slice and Route): the steps to reproduce, expected versus actual, and the
   root cause, folding in the `debug` report when one was run.
5. **XL:** write **Child packs** from the template, after Brief, Ruled out and Key insights: one row
   per child, in order, with its pack path, what it covers and what it depends on. An XL parent has
   no Slice section.
6. **Status:** `routed`, when it was `discovered`. In a re-route, leave it (Re-route, above).

Display `Pack routed: {path} (Status: {status})`.

**XL parent:** stop here. Each child is planned as its own run, in order:
`planning "{child scope}"`, whose Brief links `../{slug}/README.md`. The parent stays at `routed`,
and its README is committed with the first child's pack PR (Phase 8).

---

## Phase 4 — Specify

Load the `spec` skill with `docs/plans/{slug}`. It holds the acceptance, ADR and design checkpoints
and sets `specified` on approval. Read its result: `SPEC COMPLETE` with `pack_status` `specified`
goes on; a stop is handled as above (S-02.3.e1: a rejected PRD checkpoint leaves `prd.md` on disk
and Status `routed`).

**Size S (Change included):** `spec` writes the README's single **Slice**. Nothing else is needed
here. **A Spike** follows the steps below instead of going on to Phase 5.

### Spike

A Spike skips Slice, Cold read, Approve and Publish for itself (S-03.5).

1. **Question.** At `routed`, `spec` writes the **Question** and timebox and sets `specified`. Stop:
   `Spike: run the spike within its timebox, then planning docs/plans/{slug}.` A Spike publishes no
   issues.
2. **Spike outcome** (resume at `specified`). If `decisions/` already holds an `accepted` outcome
   ADR, go to step 3 without loading `spec`. Otherwise load `spec` again; it writes the outcome as
   the next ADR (`proposed` ones are approved at its checkpoint). Go on only on `SPEC COMPLETE`.
3. **Offer a re-route** of the same pack, naming the type the outcome suggests (for example "use
   library X" suggests a Feature).
   - **Re-route:** run the Phase 3 checkpoint for the new type, then set Status `routed` (the one
     lowering allowed). The Question section and the ADR stay. Continue at Phase 4.
   - **No re-route:** set Status `done` and display the outcome ADR. The pack is not published; say
     `Spike closed: docs/plans/{slug} is untracked — commit it through a PR to keep it.` Stop.

---

## Phase 5 — Slice

**Size S:** skip `slice`. Set Status `sliced` (from `specified`), and add the template's `progress/`
entry to the README **Read order**, renumbering it. Go to Phase 6.

Otherwise load the `slice` skill with `docs/plans/{slug}`. It holds the slice checkpoint and sets
`sliced` on approval (a Re-slice leaves Status unchanged). On any `SLICE COMPLETE` with the expected
`pack_status`, update the README Size row to `{size} — {slices} slices`. A stop is handled as above; `slices` over 12 means the draft needs child
packs, so offer a re-route to XL (S-09.4).

---

## Phase 6 — Cold read

Load the `cold-read` skill with `docs/plans/{slug}`. It runs up to three rounds and sets `reviewed`
on a pass from `sliced`. Read its `status`, not only `pack_status`:

- **`COLD READ COMPLETE`:** remove any `Cold read pending after …` line from **Open questions**
  (write "None." if the list is then empty) and go to Phase 7. At `sliced` the Status is now
  `reviewed`.
- **`COLD READ BLOCKED` (S-05.3):** do not publish. Show the remaining questions from the closing
  **Result** of `cold-read.md`, each with its Resolution, and `blocking`. Status stays where it was
  (`sliced` on a first read). Say `Answer these, then planning docs/plans/{slug} to run the cold read again.`
  and stop.
- **`COLD READ STOPPED`:** handled as above. It does not count as a cold read.

**After a Re-slice or Re-route past `sliced`** (Status `reviewed` or `approved`), the cold read that
passed saw the old plan, and Status no longer shows it. The Re-slice or Re-route therefore writes
`Cold read pending after {re-slice | re-route} on {date}.` to **Open questions**, and this phase runs
`cold-read` again; it fixes the pack but leaves Status as it is.

**Gate before Approve and Publish.** Phases 7 and 8, including on a resume, run only when
`cold-read.md`'s closing **Result** says `Pass after …` and **Open questions** holds no
`Cold read pending after …` line. Otherwise run this phase first.

---

## Phase 7 — Approve

**Checkpoint (held here).** Publish needs Status `reviewed` (or `approved` after a re-read) and
the Phase 6 gate; never approve a pack at `sliced`. Read `plan.md`, or at size S the README **Slice**, and show:

```text
Approve for publish: docs/plans/{slug}
  {Epic: {title} — labels {labels}}          (only when an epic applies; publish.md)
  1. {issue title} — labels {labels} — depends on: none
  2. {issue title} — labels {labels} — depends on: Slice 1
Ready to create {n} issue(s){ + 1 epic} in {tracker}, then open the pack PR.
```

- **Issue title:** `{pack title} — Slice {N}: {slice name}`; at size S, the pack title. Drop any
  backtick or `$` from every title Publish builds, including the epic and the `Plan:` PR title: the
  **Create** commands pass titles in double quotes, where both expand.
- **Labels:** from `$CLAUDE_SKILL_DIR/../init/references/labels.md`: one type label that fits the
  route (`feature`, `bug`, `refactor`, `enhancement`, `chore`, `documentation`, `security`), a
  priority `P0`–`P3`, and the slice's size label `size:xs`–`size:l` (as estimated by `slice`; no
  slice is larger).
- **Epic:** as `publish.md` **Epic** says.

Ask: **approve**, **change**, **re-slice**, **re-route** or **stop**.

- **Approve:** set Status `approved` (from `reviewed`). Go to Phase 8.
- **Change:** revise titles, labels or the epic, and show this again. Nothing in the pack changes.
- **Re-slice:** write `Cold read pending after re-slice on {date}.` to **Open questions**, load
  `slice` (its Re-slice mode), then Phase 6 again, then this checkpoint.
- **Re-route:** see **Re-route** above.
- **Stop:** Status is unchanged.

---

## Phase 8 — Publish

Follow `$CLAUDE_SKILL_DIR/references/publish.md`, its five steps in order (6.1):

1. Create one issue per slice, in slice order, each body holding the marker, the Outcome and the
   acceptance IDs with their text; then edit each body to add its `Depends on #N` lines.
2. Write the issue numbers into `plan.md` (or the README Slice) and the README Issues row.
3. The epic, hierarchy, board and Linear behaviours (6.2), with the epic body linking the README.
4. Set Status `published`, create `plan/{slug}` from `origin/{integration}`, stage the pack by name,
   commit, push, and open the pack PR.
5. Offer `ship-pr` on that PR, or tell the developer to merge it before executing.

**Integration branch.** `branches.integration` from `.hivrr.json`, then the repository default
branch, then `origin/HEAD`, then `main`.

A tracker or board failure never loses pack files: the pack is on disk before Publish starts, and
`publish.md` says where each failure warns and continues and where it stops.

---

## Phase 9 — Done

Display:

```text
PLANNING COMPLETE
─────────────────
Pack:     docs/plans/{slug} (Status: {status})
Issues:   {#N — title, one per line | none created}
Epic:     #{epic} — {n}/{total} children attached | not applicable
Linear:   {identifiers | not configured}
Board:    {n}/{total} added as Todo | not configured
Pack PR:  {url | none}

Next: ship-issue docs/plans/{slug}
```

With Linear as the slice tracker, the Next line names the identifiers instead (`publish.md`,
**Linear**). On a resume at `published` or later, Phase 1 says what to display instead. Return control to the
developer.

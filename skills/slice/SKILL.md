---
name: slice
description: Split a specified plan pack into ordered, PR-sized vertical slices in plan.md, with a dependency graph and a traceability table that covers every PRD criterion, behind a developer checkpoint
license: MIT
compatibility: opencode
---

# Slice

Turns a specified plan pack into its `plan.md`: ordered, vertical slices, each one issue and one PR,
each meeting the slice contract, with a traceability table that lists every PRD criterion. Nothing is
built and nothing is published (that is the `planning` wrapper).

**Files are the only state.** `plan.md` is written to disk before the checkpoint that shows it, so a
session that ends at the checkpoint leaves the draft in the pack, with Status unchanged, and a later
run picks it up from the file.

The pack format of record is `$CLAUDE_SKILL_DIR/../planning/references/pack-format.md`; read it in
Phase 1. The plan template is `$CLAUDE_SKILL_DIR/../planning/references/templates/plan.md`. When this
skill and the format disagree, the format is right.

Rules that hold in every phase:

- **No code.** No slice contains implementation code. Contracts are tables, behaviour is prose or
  Given/When/Then, patterns are `path:line` pointers, and every fence is tagged `bash`, `sh`,
  `mermaid` or `text` (`pack-format.md` §6). Shell commands belong only in Verify.
- **Template.** Write `plan.md` from the template, keeping its section order. Delete an optional
  section that does not apply, never leave one empty, and remove every `_Guidance:` line the content
  replaced.
- **Read order.** When this skill creates `plan.md`, add its entry, and the `progress/` entry that
  follows it, to the README **Read order** in the same step, using the template's wording and order
  and renumbering the list.
- **Only plan.md is yours.** Besides `plan.md`, this skill writes only the README Read order, Open
  questions and Status, and the Slice column of a Migration's `inventory.md` (Phase 4). The prd,
  design and ADRs are `spec`'s: a gap in them is shown at the checkpoint, never fixed here.
- **Do not stage or commit.** The pack stays untracked until the `planning` wrapper publishes it.

## Bootstrap

Run before Phase 1:
1. If this install ships the `core` skill, load it — it internalizes quality standards and
   architectural principles. `planner` does not ship it; when it is absent, continue without it.

---

## Phase 1 — Read the Pack

The input is a pack path, `docs/plans/<slug>`. Read `{path}/README.md`.

- **No README there:** say `No pack at {path}` and go to Phase 7.
- Read the header **Status**, **Type**, **Size** and **Modifiers**, and the **Route**, **Brief** and
  **Open questions** sections. List every other file in the folder.

Read `pack-format.md` §2 (routing matrix, size table), §4 (slice contract) and §6 (fences).

### Choose the mode

| Status | Mode |
|---|---|
| `discovered` or `routed` | Not specified yet. Say `Pack is at Status {status}: run spec first.` Go to Phase 7 |
| `specified` | **Slice** |
| `sliced`, `reviewed` or `approved` | **Re-slice** (below) |
| `published`, `executing` or `done` | Read-only. Say `Pack is at Status {status}; slice will not edit a published pack.` Go to Phase 7 |

Then, whatever the Status, by route:

- **Spike:** a Spike is never sliced. Say `Spike: no slices; its outcome is an ADR.` Go to Phase 7.
- **Size S** (every Change is S): `plan.md` is absent and the README's **Slice** section is the
  pack's single slice, written by `spec`. Say `Size S: no plan.md; the README Slice is the plan.`
  Go to Phase 7.
- **Size XL:** the parent pack is a README only. Say `XL parent: plan each child pack with its own planning run.` Go to Phase 7.
- **Bug at size M or larger:** plan is optional in the routing matrix, but only `plan.md` can hold
  more than one slice. Propose it, saying so. On a no, say
  `No plan.md: re-route the Bug to size S with planning.` and go to Phase 7.
- **Format gap:** if the Type or Size is not in the routing tables, say
  `Format gap: {what} is not defined in pack-format.md §2; nothing was written.` and go to Phase 7.

### Re-slice

`plan.md` was approved before, and the plan or the route changed since (for example a re-route, or
a cold-read finding). Work through every phase as in Slice, against the `plan.md` already there:

- Never delete it or rewrite it wholesale. Revise it slice by slice, and the traceability table and
  graph with them. Issues are not published yet, so slices may be renumbered.
- For each revised slice, add one line to the README **Open questions**:
  `Revised by slice on {date}: plan.md — Slice {N}, {reason}. Awaiting approval at the next checkpoint.`
  On approval at Phase 5, remove those lines; write "None." if the list is then empty. A stop
  leaves them in place.
- Status is not changed by this run (Phase 6).

Slice at `specified` follows the same revision rules when `plan.md` already exists (an earlier
stopped run), and still sets Status on approval.

### Read the specification

Read every spec file the pack holds, in the README Read order: `prd.md` (stories, criteria, Story
map, Rules and examples, Failure modes, NFRs), `context.md` (citations and verify commands),
`decisions/`, `design.md` (contracts, modifier sections, Test strategy, Pre-mortem, rollback and
cutover), `inventory.md` and `ux.md`.

List every PRD criterion ID — each bold `S-NN.k` that opens a criterion in `prd.md`:

```bash
grep -oE '\*\*S-[0-9]+\.[0-9]+\*\*' docs/plans/{slug}/prd.md | tr -d '*' | sort -u
```

**No criteria:** when `prd.md` exists but the command prints nothing, say
`Format gap: prd.md states no bold S-NN.k criteria; nothing was written.` and go to Phase 7.

Display: `Pack: {path} | Status: {status} | Route: {type}, {size}, {modifiers} | Mode: {mode} | Criteria: {count}`.

---

## Phase 2 — Draft the Slices

Draft in the conversation first; nothing is written until Phase 4.

### Vertical, one PR each

A slice is a vertical, independently mergeable unit: one issue, one branch, one PR. It delivers an
observable result end to end, leaving the repository's verify command green on its own. Do not
slice by layer ("all the schema", then "all the API"); slice by outcome.

**Sizing (4.1).** Every slice is at most `size:l` in
`$CLAUDE_SKILL_DIR/../init/references/labels.md` terms: 1–2 days of work. That is a label size, not
the pack size L. Estimate each slice's label. Split a slice when it is `size:xl`, or when it:

- covers stories from more than one step of the Story map with no shared outcome;
- changes more than one component that could each merge on its own;
- needs more than one rollback, or more than one migration step;
- has a Verify that would prove unrelated things.

Split along an observable result, so each part still has an Outcome of its own. Re-estimate the parts.

### Sources

- **Criteria:** every PRD criterion ID goes in at least one slice's Acceptance. A slice lists the
  IDs it satisfies; a criterion split across slices says in each which side that slice proves, as
  "**S-04.3** (author side): …". Its example rows follow it, so they are not listed separately.
- **Local criteria** `N.k` cover what the slice needs beyond the PRD (for example "the skill is
  registered"). A behavioural one uses Given/When/Then; a structural one may be a plain statement
  whose proof is a Verify command.
- **Contracts:** each interface the slice creates or changes, as a table or a reference to a
  `design.md` table. A contract several slices use goes once in a **Shared contract** section.
- **Pre-mortem:** each item in `design.md` that maps to "stop condition in the slice that …"
  becomes a "Stop if …" bullet in the slice that does that thing.
- **Modifiers:** follow the order the modifier sections set — a `data` change's expand/contract
  steps and deploy order, an `infra` rollout order — one step per slice where they must ship apart.
- **Test strategy:** each slice's Verify proves its criteria and their example rows at the level
  `design.md` names for each row.
- **Inventory (Migration):** every usage site is covered by a slice.

### By type (4.2)

- **Refactor:** Slice 1 adds characterization tests for the behaviour-preservation contract — the
  prd's characterization rows — and changes no behaviour. Every later slice depends on it.
- **Greenfield:** Slice 1 is a walking skeleton: the thinnest end-to-end path through every layer
  of the chosen stack, with the verify command from `context.md` running green. Every later slice
  depends on it.
- **Migration and Rewrite:** every slice's Contracts ends with a **Rollback:** line saying how that
  slice is undone, following the rollback approach in `design.md`. A Rewrite's cutover, from
  `design.md`'s **Cutover**, is its own slice, after the slices that reach parity.

### Each slice holds

The slice contract, `pack-format.md` §4, with the eight headings in order:

- **Header line:** `Issue: # · Depends on: {Slice N, … or none} · Stories: {S-NN, …} · Map: {steps}`.
  The issue number stays `#` for Publish to fill. `Map:` is present only when the prd has a Story
  map; it names the journey steps (the map's column headings) that the slice's Outcome changes —
  the steps it touches — whichever step its stories sit under.
- **Outcome** (mandatory): one or two sentences describing the observable result.
- **Acceptance** (mandatory): the PRD criterion IDs, each in bold as its own bullet, then the local
  criteria.
- **Contracts** (mandatory): tables, a `design.md` reference, or "None new." when the slice changes
  no interface; the Rollback line for Migration and Rewrite.
- **Stop conditions** (mandatory): keep the template's preflight bullet; add one per situation the
  executor must not improvise through, including each pre-mortem item carried here.
- **Verify** (mandatory): exact commands in a `bash` fence, taken from `context.md` §4 or the repo,
  each with its expected output; then the dry-run scenarios for behavioural criteria, each naming
  the IDs it proves.
- **Pattern to follow** (guide): `path:line` of existing work to imitate, from `context.md`, or
  opened and read in this run. A greenfield slice cites the ADR that chose the pattern.
- **Suggested path** (guide): opens with the template's line
  "Default route. You may deviate if every mandatory item still holds; record why.", then ordered
  steps.
- **Files** (guide): the expected create, modify and delete list.

### Count

**More than 12 slices is a hard stop.** Do not write `plan.md`, or any change to an existing one.
Say `XL: split into child packs — the draft has {n} slices, over the 12 a pack holds. Re-route to XL with planning.`
and go to Phase 7 (S-09.4).

When the count is outside the Size row's range (M is 2–6, L is 7–12), keep it for the Phase 5
checkpoint as a size mismatch.

---

## Phase 3 — Order and Dependency Graph

Order the slices so every slice comes after each one it depends on, numbered from 1 with no gaps.
Slice 1 depends on none. Prefer an order that delivers an observable result early, and keeps
independent slices independent rather than chaining them for tidiness.

- Each `Depends on:` names only earlier slices, and only real dependencies: a slice needs the other
  merged first to build or verify.
- **Dependency graph:** a Mermaid `flowchart` with one node per slice and one edge per dependency.
  Required at size L. At size M, write it when the order is not a single chain; otherwise delete it.
- When independent slices edit the same lines (a shared registry, a shared list), add a line under
  the graph giving the order to merge them in, and that each rebases on the one before.

---

## Phase 4 — Write plan.md and Self-check

Write `docs/plans/{slug}/plan.md` from `templates/plan.md`:

1. **Dependency graph** (Phase 3), or delete the section.
2. **Traceability:** a table of criterion → slices. A row may group IDs that share the same slices,
   comma-separated, each ID written out — never a range. Every PRD criterion ID appears. Below it:
   `Example rows (S-NN.k.eN) follow their criterion's slices.`
3. **Shared contract**, or delete the section.
4. One section per slice, in order, separated by `---`.

Add the Read order entries (`plan.md`, then `progress/`) if they are missing.

**Migration:** fill the Slice column of `inventory.md` **Usage sites**, replacing each `pending`
with the slice number that covers that site. In a Re-slice, update the numbers that changed.

### Self-check

Before the checkpoint, check the draft on disk. A draft that fails any check is rejected: fix it and
check again. Never show a failing draft as ready.

**Headings (S-04.2).** Every slice has the eight headings, exactly and in order. This prints
each slice whose headings differ, with the headings it has; expected no output:

```bash
awk -v want="Outcome|Acceptance|Contracts|Stop conditions|Verify|Pattern to follow|Suggested path|Files" '
  function chk() { if (got != want) print s ": headings " got }
  /^## / { if (s) chk(); s = ""; got = "" }
  /^## Slice / { s = $0 }
  s && /^### / { got = got (got == "" ? "" : "|") substr($0, 5) }
  END { if (s) chk() }' docs/plans/{slug}/plan.md
```

Then read each slice: every heading has content, and the header line has the fields above.

**Fences (S-04.3).** Every opening fence, at any indentation and with backticks or tildes, is
tagged `bash`, `sh`, `mermaid` or `text`. This prints each one that is not, untagged included;
expected no output:

```bash
awk '/^[ \t]*(```|~~~)/ { if (open) { open = 0; next } open = 1; t = $0; sub(/^[ \t]*(```|~~~)[`~]*/, "", t); sub(/[ \t\r]+$/, "", t)
  if (t != "bash" && t != "sh" && t != "mermaid" && t != "text") print FILENAME ":" FNR ": fence \"" t "\"" }' docs/plans/{slug}/plan.md
```

Then read each fence: a `bash` or `sh` fence sits under a Verify heading and holds only commands,
`mermaid` holds a diagram, `text` a tree or layout. Code in any language is rejected, whatever its
tag — move what it meant into a contract table, a Given/When/Then, or a `path:line` pointer.

**Trace (S-04.4).** Only a bold criterion ID counts as listing it; a mention such as "like
S-05.3.e1" in prose does not. The first command prints each PRD criterion no slice's Acceptance
lists, the second each one missing from the Traceability table's first column (example IDs there do
not count), the third each bold ID a slice lists that the prd does not have; expected no output from
any:

```bash
p=docs/plans/{slug}
crit() { grep -oE '\*\*S-[0-9]+\.[0-9]+\*\*' "$@" | tr -d '*' | sort -u; }
comm -23 <(crit "$p/prd.md") <(awk '/^#/ { a = ($0 == "### Acceptance") } a' "$p/plan.md" | crit)
comm -23 <(crit "$p/prd.md") <(awk -F'|' '/^#/ { t = ($0 == "## Traceability") } t && /^\|/ { print $2 }' "$p/plan.md" \
  | grep -oE 'S-[0-9]+\.[0-9]+(\.e[0-9]+)?' | grep -v '\.e' | sort -u)
comm -13 <(crit "$p/prd.md") <(awk '/^#/ { a = ($0 == "### Acceptance") } a' "$p/plan.md" | crit)
```

Each Traceability row's slices must also match the slices that list its IDs. A missing ID is fixed
by adding it to the slice that delivers it. When no slice could deliver it — it belongs to no
outcome in the plan — leave it out and keep it as a **gap** for the checkpoint. Never drop it
silently.

**Map (S-11.5).** When the prd has a Story map, every slice header has `Map:`, naming only the
map's column headings, and every step is named by at least one slice. This prints each step no slice
names; expected no output:

```bash
p=docs/plans/{slug}
comm -23 <(awk '/^## /{m=($0=="## Story map")} m && /^\|/{print; exit}' "$p/prd.md" | tr '|' '\n' | sed 's/^ *//;s/ *$//' | grep . | sort -u) \
  <(grep -E '^Issue:' "$p/plan.md" | grep -oE 'Map: .*' | sed 's/^Map: //' | tr ',' '\n' | sed 's/^ *//;s/ *$//' | sort -u)
```

Without a Story map, no header has `Map:`.

**The rest.** Fix anything that fails:

- **Size (4.1):** no slice is estimated above `size:l`.
- **Type (4.2):** the Refactor or Greenfield Slice 1 rule, or a Rollback line in every Migration
  and Rewrite slice.
- **Dependencies:** each names only earlier slices; the graph matches the header lines.
- **Pre-mortem:** each item mapped to a stop condition is a "Stop if …" in a slice.
- **Inventory:** no `pending` is left in a Migration's Slice column.
- No section is empty, no `_Guidance:` line is left, and `plan.md` and `progress/` are in Read order.

---

## Phase 5 — Checkpoint

Show the developer, in this order:

- one line per slice: number, name, `Depends on`, Stories, Map, acceptance IDs, and its estimated
  label size;
- the dependency graph, and any merge-order line;
- the traceability table;
- each **gap**: a PRD criterion no slice lists, with why none can, and the choice to add it to a
  slice, or take it back to `spec` to drop or move it;
- each Story map step no slice touches;
- a **size mismatch**: `Size {size} expects {range} slices; the draft has {n}.`;
- in a Re-slice, each revised slice and its Open questions line.

Then ask: **approve**, **change** or **stop**. Approve is offered only when there is no gap, no
untouched map step and no size mismatch. Otherwise offer **change**, or **stop** to re-route the
size or revise the prd with `planning`.

- **Approve:** for a Re-slice, remove the revision lines from Open questions. Go to Phase 6.
- **Change:** revise `plan.md` in place, re-run the Phase 4 self-check, and show this checkpoint
  again.
- **Stop:** go to Phase 7. Status is unchanged; `plan.md` stays on disk.

---

## Phase 6 — Status

Only reached when the checkpoint was approved.

1. Confirm `plan.md` and `progress/` are in the README **Read order**; add either that is missing.
2. Status. **No skill lowers Status**, and slice writes `sliced` only when the current Status is
   `specified`, the one immediately before it:
   - Slice at `specified`: set the header Status to `sliced`.
   - Re-slice: leave Status as it is and say `Status stays {status}: it advances only through the next approved checkpoint.`

Display: `Pack sliced: {path} (Status: {status}) — {n} slices`.

---

## Phase 7 — Emit the Result

Emit one JSON object as your entire final response — no markdown, no preamble, no trailing text.
Write `null` bare, never as the string `"null"`.

```json
{
  "status": "SLICE COMPLETE | SLICE STOPPED",
  "pack": "docs/plans/{slug}",
  "pack_status": "{README Status after the run}",
  "slices": 0
}
```

- `slices` is the number of slices in `plan.md` after the run, `0` when there is none. For the
  more-than-12 stop it is the drafted count, so a value over 12 means "split into child packs" and
  `plan.md` was not written or changed.
- `SLICE COMPLETE` only when this run reached Phase 6, its checkpoint approved.
- `SLICE STOPPED` for every other path to this phase: a stop at the checkpoint, a refused mode (no
  README, not yet specified, read-only, Spike, size S, XL parent, Bug plan declined), a format gap or
  more than 12 slices. `pack_status` is the unchanged Status.
- With no README at the path, `pack_status` is bare `null`.

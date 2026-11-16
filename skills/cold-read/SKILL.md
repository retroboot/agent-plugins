---
name: cold-read
description: Prove a plan pack complete by having a fresh subagent on the smallest available model read it cold, then fix the pack until no blocking questions remain, in at most three rounds recorded in cold-read.md
license: MIT
compatibility: opencode
---

# Cold Read

Proves a plan pack complete before anything is built. A reader that has never seen the pack — a
fresh subagent on the smallest available model, given only the pack path and repository access —
reads it as the executor would, and lists what it could not build without asking. The author (this
skill) fixes the pack and a new reader tries again, up to three rounds. Every round is recorded in
`cold-read.md`. Nothing is built and nothing is published (that is the `planning` wrapper).

**Files are the only state.** Each round is appended to `cold-read.md` as soon as it is resolved,
so a session that ends mid-run leaves every finished round in the pack, and a later run continues
the numbering from the file.

The pack format of record is `$CLAUDE_SKILL_DIR/../planning/references/pack-format.md`; read it in
Phase 1. The record template is `$CLAUDE_SKILL_DIR/../planning/references/templates/cold-read.md`.
When this skill and the format disagree, the format is right.

Rules that hold in every phase:

- **The read stays cold.** The reader gets the prompt in Phase 3 and nothing else: no summary of the
  pack, no conversation, no earlier rounds, no hint of what the author expects it to find. A reader
  that has seen the pack before is not cold, so every round is a **new** subagent — never a
  continued one, never one sent a follow-up message.
- **The reader classes, the author resolves.** The reader says which questions block it. The author
  may re-class one only with a reason recorded in its Resolution. Every blocking question is
  resolved by editing the pack before the next round.
- **No code.** No edit this skill makes adds implementation code. Contracts are tables, behaviour is
  prose or Given/When/Then, and every fence is tagged `bash`, `sh`, `mermaid` or `text`
  (`pack-format.md` §6).
- **Never rewrite a round.** `cold-read.md` gains one `## Round N` section per round. Earlier rounds
  are never edited or removed; only the header table and the closing **Result** are rewritten.
- **Do not stage or commit.** The pack stays untracked until the `planning` wrapper publishes it.

## Bootstrap

Run before Phase 1:
1. Load the `core` skill — internalizes quality standards and architectural principles

---

## Phase 1 — Read the Pack

The input is a pack path, `docs/plans/<slug>`. Read `{path}/README.md`.

- **No README there:** say `No pack at {path}` and go to Phase 7.
- Read the header **Status**, **Type** and **Size**, and the **Read order**. List every file in the
  folder.
- **Record only** (below): the pack executors read is the one on the integration branch. Resolve
  `{integration}` as `work-issue` Phase 5 does (`branches.integration`, then the repository default
  branch, then `origin/HEAD`, then `main`), run `git fetch origin {integration}`, and compare with
  `git diff --stat origin/{integration} -- {path}`. When the working copy differs, warn
  `Working copy of {path} differs from origin/{integration}; the reader sees the working copy.`
  and record the warning in the round's summary paragraph.

Read `pack-format.md` §3 (README contract and Status) and §6 (fences).

### Choose the mode

The cold read runs at any Status, so the developer can repeat it standalone. The mode decides only
what the run may edit and whether it may set Status.

| Status | Mode |
|---|---|
| `discovered`, `routed` or `specified` | **Early read.** Rounds run and the pack is fixed as usual; Status is never set (Phase 6) |
| `sliced` | **Read** — the normal case inside the wrapper. On a pass, Phase 6 sets `reviewed` |
| `reviewed` or `approved` | **Re-read**, for example after a re-slice. Rounds run and the pack is fixed; Status is left as it is |
| `published`, `executing` or `done` | **Record only.** One round runs and is recorded, but no other pack file is edited: the pack is on the integration branch and executors read it from there. Each fix is written as a proposal in its Resolution, for the developer to make through a PR |

### Slices to assign

List the slices the reader can think through: each `## Slice N` in `plan.md`, or, at size S, the
README's **Slice** as Slice 1. A Spike, an XL parent, or a pack not sliced yet has none; its reader
thinks through the pack as a whole.

When `cold-read.md` exists, read only its header table and the first paragraph of each
`## Round N` section, for the round count so far and the slices each round covered. Do not read
the earlier questions now — what the next reader is asked must not lean on what the last one found.

Display: `Pack: {path} | Status: {status} | Mode: {mode} | Slices: {count} | Earlier rounds: {n}`.

---

## Phase 2 — Author Checks

Before any reader sees the pack, fix what a command can find. A reader's attention is for gaps only
a reader can find.

**Fences (S-04.3).** Every opening fence in every pack file, at any indentation, is exactly three
backticks tagged `bash`, `sh`, `mermaid` or `text` (`pack-format.md` §6). This prints each `~~~` or
four-backtick fence as `fence form`, and each tag that is not allowed, untagged included; expected
no output:

```bash
find docs/plans/{slug} -name '*.md' -print0 | xargs -0 awk 'FNR == 1 { open = 0 }
  { s = $0; sub(/^[ \t]+/, "", s) }
  !match(s, /^(```+|~~~+)/) { next }
  { n = RLENGTH; r = substr(s, 1, n); t = substr(s, n + 1); sub(/[ \t\r]+$/, "", t) }
  open { if (substr(r, 1, 1) == oc && n >= on && t == "") open = 0; next }
  { open = 1; oc = substr(r, 1, 1); on = n
    if (r != "```") print FILENAME ":" FNR ": fence form \"" r "\""
    if (t != "bash" && t != "sh" && t != "mermaid" && t != "text") print FILENAME ":" FNR ": fence \"" t "\"" }'
```

Then read each fence: a `bash` or `sh` fence sits under a Verify heading and holds only commands,
`mermaid` a diagram, `text` a tree or layout. Code in any language is a defect whatever its tag.

**Plan (when `plan.md` exists).** Run the **Headings** and **Trace** commands from
`$CLAUDE_SKILL_DIR/../slice/SKILL.md` Phase 4, Self-check, exactly as written there with `{slug}`
filled in; expected no output from either.

Every finding is a blocking item, recorded in the coming round's Questions table as an author
finding, Id `A1`, `A2` …, so the round shows it. Fix it now, unless the mode is Record only or the
fix is developer-only — one that changes what a criterion means, or drops one; hold those for
Phase 5. A **held** finding is not excepted from the pass rule: it counts as Blocking for this
round even if Phase 5 fixes it, because no reader has seen the fix.

---

## Phase 3 — Dispatch the Reader

Number this round `N`: one more than the rounds already in `cold-read.md`, or 1. This run holds at
most **3 rounds**; a later run of this skill continues the numbering with a fresh cap of 3.

**Assign slices.** Pick about a third of the slices, at least one, from those no earlier round
covered, in plan order. Once every slice has been covered, prefer the slices whose files the last
round's fixes touched. With no slices, leave the slice line out of the prompt.

**Choose the reader**, the first that this environment offers:

| Offer | Dispatch | Record as the model |
|---|---|---|
| A subagent tool with a model override (Claude Code's Agent tool) | `subagent_type: Explore`, which is read-only by tool set, with `model: haiku` | `Haiku (Agent tool, model: haiku, Explore)` |
| A subagent tool with no model choice (R1 in the design) | A fresh subagent on the default model; a read-only type where one exists | The default model by name if known, else `default model`, and the tool used |
| No subagent tool | Do not read it yourself — you have seen the pack, so you are not cold. Say `No subagent available: run cold-read {path} in a session that can start one.` Go to Phase 7 | — |

Frontmatter `allowed-tools` does not scope a spawned subagent, so when no read-only type exists the
prompt's "change nothing" line is the only guard. Run this before and after every read and compare
the two outputs; they must be identical:

```bash
find docs/plans/{slug} -type f -exec cksum {} + | sort -k3
```

A difference means the reader changed the pack: the round is void. Say which files changed and go
to Phase 7.

**The prompt** is exactly this, with `{path}` and `{slices}` filled in. Add nothing to it — no
summary, no context, no reason for the read:

```text
You are about to implement part of a plan pack, and you have never seen it. Read it cold.

Pack: {path}

Read {path}/README.md first, then follow its Read order. Do not open {path}/cold-read.md until
your report is written. Read only: change nothing.

Think these slices through as if you were implementing them now: {slices}.

Spot-check at least 8 citations (a path:line, or a path and a symbol) against the repository.

Any code in the pack is a blocking defect: a fence holding any programming language, whatever its
tag, or a fence with no tag. Report each one as a blocking question. Shell commands in a bash or
sh fence under a Verify heading are allowed, and are not code.

Your report has these sections, in this order:

## Restated outcome
What the pack delivers, in your own words.

## Restated design
Five sentences or fewer.

## Questions
A table: id | blocking (yes/no) | file and section | what is missing. A question is blocking
when you could not build the slice correctly without its answer. Give the default you would
choose for each non-blocking one.

## Contradictions
A table: id | first place | second place | how they disagree.

## Citations spot-checked
A table: citation | holds (yes/partly/no) | note.
```

`{slices}` reads `Slice 2, Slice 5` — numbers only, never names or what they contain.

**Check the report.** It must have all five sections and at least 8 citations. If it does not,
dispatch one more new reader for the same round; a second incomplete report goes to Phase 7 with
the round unrecorded.

Display: `Round {N}: reader {model} — {q} questions ({b} blocking), {c} contradictions, {k} citations checked`.

---

## Phase 4 — Classify

Now read the earlier rounds in `cold-read.md` in full, and class every item in the report:

| Item | Class |
|---|---|
| Question the reader marked blocking | **Blocking**, unless the pack already answers it in the place an executor would look: then re-class non-blocking, citing that place. A re-class never rests on conversation context — if the answer is only in your head, it is blocking |
| Question marked non-blocking | **Non-blocking**. Re-class blocking when the reader's default would build the wrong thing |
| Contradiction | **Blocking** when two mandatory items (`pack-format.md` §4) or two contracts disagree, so no executor can satisfy both; otherwise non-blocking |
| Citation that does not hold | **Blocking** when a slice's Contracts or Stop conditions rest on it; otherwise non-blocking |
| Code in the pack | **Blocking**, always |
| Author finding from Phase 2 | **Blocking**; already fixed, unless held in Phase 2 |

Then mark each blocking item **developer-only** when only the developer can answer it: a product
decision (scope, a goal or non-goal, what a user sees), or confirming, changing or reversing an
ADR. Everything else is the author's to fix.

---

## Phase 5 — Resolve and Record

### Developer-only first

**Stop condition.** A developer-only question is asked at once, before any fix and before any
further round — never carried into the next round in the hope a reader settles it. Show each one
with the reader's wording, the file, and the options the pack leaves open. Then:

- **Answered:** resolve it as below, recording the developer's answer and date in the Resolution.
  An ADR the developer confirms becomes `accepted (developer, {date})`.
- **Not answered** (the developer defers it or stops): it remains blocking. Record the round, then
  go to Phase 6 without dispatching another round. The run ends `COLD READ BLOCKED`.

### Fix the pack

Skip this in Record only mode; write each fix as `Proposed: …` in its Resolution instead.

- **Blocking:** edit the pack so an executor reading it cold would find the answer where it would
  look first — usually the slice's mandatory section, or the `design.md` section the slice cites.
  Then **grep the pack for every restatement of the rule you changed** (plan slices restate the
  design; the prd restates criteria) and bring each into line. A fix applied in one place and not
  in its restatement is the next round's blocker.
- **Non-blocking:** adopt the reader's default when it is right, writing it into the pack, or record
  why the pack stands as it is. Either way the Resolution says which.
- Never renumber a PRD criterion; a new one goes at the end of its story. A fix that adds a
  criterion also adds it to a slice's Acceptance and the Traceability table.
- Fix only what an item asked for. A wider rework is a re-slice or a re-route: say so in the
  Resolution and leave it to the developer.

After the fixes, run the Phase 2 checks again; expected no output.

### Write the round

Add `## Round {N} — {YYYY-MM-DD}` to `{path}/cold-read.md` after the last round and before the
closing `## Result` (at the end, if an older file has none). When the file does not exist, write
it from the template first, and add its entry to the README **Read order** in the same step, using
the template's wording and position. In Record only mode leave the README alone, and write the
entry as a `Proposed:` line in the closing Result instead. Fill the round from the template's
skeleton:

1. **Summary paragraph:** the reader and model, the slices it thought through, how many citations it
   checked and how many held, and whether it found any code.
2. **Questions:** one row per question and author finding — Id, Blocking (`y`/`n`, plus
   `developer-only` where it applies), File, Gap, Resolution. Every row has a Resolution.
3. **Contradictions:** one row each, with which place changed.
4. **Citations checked:** the reader's citations and whether each holds.

Then rewrite the header table — **Model**, **Rounds** (all rounds in the file), **Result** — and the
closing `## Result` section, which stays the last section of the file.

### Next round, or stop

- **No item classed Blocking in this round's Phase 4** (author findings fixed in Phase 2 excepted,
  since the reader saw the fixed pack; a held one counts): the pack **passes**. Go to Phase 6.
- **Blocking items, all resolved, fewer than 3 rounds this run, and not Record only:** go back to
  Phase 3 with a new reader. Only a new reader can show the fixes worked.
- **Otherwise** — the third round of this run still had items classed Blocking, a developer-only
  question is unanswered, or the mode is Record only: go to Phase 6 without passing. Fixes already
  made stay in the pack, but no cold reader has checked them.

---

## Phase 6 — Result and Status

`blocking` is the number of items classed **Blocking** in the last round's Phase 4, author
findings fixed in Phase 2 excepted (a held one counts), each counted once — so an item the author
re-classed blocking counts, one re-classed non-blocking with a cited pack location does not, and an
unanswered developer-only question is already among them. It is 0 only on a pass.

**On a pass:** the closing **Result** says `Pass after {n} rounds.`

**Not passed:** the closing **Result** says `COLD READ BLOCKED: {blocking} blocking question(s) left after round {N}.`
and lists each one with its Resolution: `resolved, not yet checked by a cold reader`,
`awaiting the developer`, or, in Record only mode, the proposal. Show the same list to the
developer — this is the cold read's checkpoint (S-05.3). Nothing is published from here: the
developer answers what is theirs, then runs `cold-read {path}` again for up to 3 more rounds.

**Status.** **No skill lowers Status**, and cold-read writes `reviewed` only when the current
Status is `sliced`, the one immediately before it:

- Read mode, on a pass: set the header Status to `reviewed`.
- Read mode, not passed: Status stays `sliced`. Nothing is published.
- Any other mode: leave Status as it is and say `Status stays {status}: cold-read sets reviewed only from sliced.`

Display: `Cold read: {path} — {result}, {rounds} round(s) this run on {model} (Status: {status})`.
In Record only mode also say `Record only: commit cold-read.md and any proposed fix through a PR.`

---

## Phase 7 — Emit the Result

Emit one JSON object as your entire final response — no markdown, no preamble, no trailing text.
Write `null` bare, never as the string `"null"`.

```json
{
  "status": "COLD READ COMPLETE | COLD READ BLOCKED | COLD READ STOPPED",
  "pack": "docs/plans/{slug}",
  "pack_status": "{README Status after the run}",
  "model": "{the reader model as recorded}",
  "rounds": 0,
  "blocking": 0
}
```

- `rounds` is the number of rounds this run recorded; `blocking` as Phase 6 defines it.
- `COLD READ COMPLETE` only when the last round passed.
- `COLD READ BLOCKED` when the run ended without a pass: the third round still had items classed
  Blocking (author findings fixed in Phase 2 excepted; a held one counts), a developer-only
  question is unanswered, or a Record only round had one — in Record only mode every author
  finding is held.
- `COLD READ STOPPED` when no round could be recorded: no README, no subagent available, two
  incomplete reports, or a reader that changed the pack. `model` is bare `null` when no reader
  ran, `rounds` counts the rounds recorded before the stop, and `pack_status` is the unchanged
  Status.
- With no README at the path, `pack_status` is bare `null`.

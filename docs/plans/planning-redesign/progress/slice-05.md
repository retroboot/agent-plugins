# Progress — Slice 5

| | |
|---|---|
| **Status** | done |
| **Issue** | #211 |
| **PR** | this PR |
| **Executor model** | Claude Opus 5.5 (`claude-opus-5-5`), pack rules followed by hand |
| **Date** | 2026-11-14 |

## Preflight

Pack read from `origin/main` at `9a34397`; the working copy matched it.

- `skills/planning/references/plan-review.md` (Pattern to follow, dispatch shape): exists; dispatch
  at line 13. Still present, as Slice 6 has not deleted it.
- `skills/planning/references/templates/cold-read.md` (Slice 1 output): exists, with the header
  (Model, Input, Rounds, Result), one `## Round N` section with Questions (Id, Blocking, File, Gap,
  Resolution), Contradictions and Citations checked, then `## Result`: holds.
- `skills/planning/references/pack-format.md` §3 Status (line 175) and §6 Fences (line 281): hold.
  §6 says `slice` and `cold-read` enforce what is inside each fence.
- `skills/slice/SKILL.md` Phase 4 Self-check, Headings and Trace commands (lines 236–276; Slice 4
  Discoveries): hold.
- `design.md` §8 "No skill ever lowers Status" with the `cold-read` at `executing` example, and §9
  R1 (line 404): hold.
- `context.md` §4, frontmatter keys and `## Phase N — Title` headings (check 7,
  `docs/verification.md:78`): holds. `skills/review-pr/SKILL.md:4-14` for `allowed-tools`: the list
  runs 4–16. Not used here, since `cold-read` edits the pack and is not read-only.
- `context.md` §5, adding a skill: checks 6 (`docs/verification.md:61`) and 13 (`:158`): hold.
- `.claude-plugin/marketplace.json` `planner` lists `init`, `session`, `brainstorm`, `spec`,
  `slice`, `planning`: holds after Slices 3 and 4.
- Shared contract (`plan.md`, phase-skill completion): unchanged on disk. Slices 3 and 4's accepted
  `SPEC STOPPED` and `SLICE STOPPED` deviations read from their progress files.

## Acceptance

Line numbers refer to `skills/cold-read/SKILL.md` (316 lines). The dry run used a synthetic size-S
Change pack, `brainstorm-blurb`, at Status `sliced`, built in the session scratchpad outside the
repository and never committed. It had planted defects: a `python` fence, JavaScript inside a `text`
fence, a source file that has no such string, two wrong line citations and a wrong check number.
Two rounds were really dispatched through the Agent tool exactly as Phase 3 says: `subagent_type:
Explore`, `model: haiku`, the prompt verbatim with `{path}` (absolute, because the fixture sits
outside the repo) and `{slices}` = `Slice 1`. This pack's `cold-read.md` was not touched.

| ID | How it was shown |
|---|---|
| S-05.1 | Phase 3 (121–127) dispatches a subagent on the smallest model (`model: haiku`), falling back to the default model and recording it (R1). Rule 26–29: the prompt and nothing else. Prompt (144–177) gives only the pack path and the repo. Dry run: both readers got only the prompt; each restated the pack from the files alone |
| S-05.1.e1 | Rule 28–29: every round is a **new** subagent, never continued or messaged. Dry run: round 2 was a second Agent call, not a SendMessage to the round-1 reader. Its report did not mention round 1, and it reported that it did not open `cold-read.md` |
| S-05.2 | Phase 4 (189–206) classes every item blocking or non-blocking, with re-class reasons recorded (30–32). Phase 5 (221–237) fixes each blocking item by editing the pack before the next round (260–261). Dry run, round 1: A1 (`python`) fixed before the read; Q1 (JS) and Q3 (undefined source) blocking and fixed; Q2 ("is a Verify grep code?") re-classed non-blocking, citing `pack-format.md` §6. Round 2 raised one new blocker, a wrong awk field in the round-1 Verify fix. This is the case Phase 5's "only a new reader can show the fixes worked" (260–261) exists for |
| S-05.2.e1 | Same rule: a reader question the pack does not answer is blocking unless the pack answers it where an executor would look (195). The fix goes where the slice's executor looks first (225–226), followed by the restatement grep (227–229). Dry run: Q3 was fixed in Acceptance 1.1, and its restatements in the Brief, e1 and the failure note were brought into line |
| S-05.2.e2 | Phase 4 (202–204) marks product decisions and ADR changes developer-only. Phase 5 (212–219) asks them at once, before any fix or further round. Unanswered, the round is recorded and the run ends `COLD READ BLOCKED` with no further round. "Should XL packs be allowed?" is a product decision, so it is developer-only |
| S-05.3 | Phase 3 (114–115) caps a run at 3 rounds. Phase 5 (262–264): when the third round still raised blocking items, go to Phase 6 without passing. Phase 6 (275–278) writes `COLD READ BLOCKED: …`, lists each blocker and shows it to the developer. Status stays `sliced` (285), `reviewed` is set only on a pass from `sliced` (281–284), and the JSON is `COLD READ BLOCKED` (311–312) |
| S-05.3.e1 | 3 rounds, 1 blocking left: `blocking` = 1 (270–271), Result `COLD READ BLOCKED`, Status stays `sliced`, "Nothing is published from here" (277–278) |
| S-05.4 | Phase 5 Write the round (239–254): the template's round skeleton with model, slices, citations and code found; Questions with a Resolution on every row; Contradictions; Citations. Header Model, Rounds and Result are rewritten, and earlier rounds never are (36–37). Dry run: round 1 written into the fixture's `cold-read.md` from the template, and its Read order entry added in the same step (242–244) |
| S-04.3 | Reader side: the prompt (155–157) calls any code a blocking defect, untagged fences included. Author side: Phase 2 fence command over every pack file (89–100), plus reading each fence. Dry run: Phase 2's command printed `README.md:47: fence "python"` (A1). The round-1 reader reported the JavaScript in the `text` fence as blocking Q1. Fixture for the command alone: `python`, untagged and indented `~~~json` fences across two files all reported; an unclosed fence in one file does not carry into the next (`FNR == 1` reset). On this pack: no output |
| 5.1 | The prompt (144–177) holds the path, "read README first, then follow its Read order", the slice numbers, the citation count, the code rule and the report format, and no pack content. "Add nothing to it" (140–141); `{slices}` is numbers only (179). See Deviations for the two process lines it also carries |
| Stop condition | Built into Phase 5 (212–219): a developer-only question is surfaced at once and never carried into later rounds. Not triggered while building this slice |
| Registration | `cold-read` in `marketplace.json` (after `slice`), the planner `**Skills:**` line in `CLAUDE.md`, the README planner table, and `.agents/skills/cold-read -> ../../skills/cold-read` |
| Structural | `eval "$(jq -r .verify.test .hivrr.json)"`: `structural checks pass`. Phases `## Phase 1`–`## Phase 7`, with no stated count |
| NFR Size | `skills/cold-read/SKILL.md` is 316 lines, under the 400-line limit |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Verify: dry run `cold-read docs/plans/planning-redesign` | Two real rounds against a synthetic pack outside the repo. This pack's `cold-read.md` was not changed | The orchestrator's brief forbids writing to this pack's `cold-read.md`, and running the skill would append a round and edit the pack. Every ID that dry run was meant to prove is proven above | n |
| Reader prompt: path, Read order, citations, slices, report format, "nothing else" | Two more lines: "do not open cold-read.md until your report is written", and "read only: change nothing". A third, required by S-04.3, makes code a blocking defect, with the note that Verify shell commands are not code | Round 3 of this pack named the first as needed, and round 4 used it. Explore is read-only only "where available", so a fallback reader needs the second. The Verify note was added after dry-run round 1's reader flagged a Verify `grep` as code. None of them carries pack content, so 5.1's purpose holds | n (refines the mandated lines; adds no summary) |
| Shared contract: `status` is `COLD READ COMPLETE` or `COLD READ BLOCKED` | Adds `COLD READ STOPPED` | Same case as the accepted `SPEC STOPPED` and `SLICE STOPPED`: no README, no subagent available, two incomplete reports, or a reader that changed the pack. A run in which no round was recorded is neither a pass nor a blocked read | y (mirrors the accepted Slice 3 and 4 deviations) |
| Shared contract: `pack_status` is a string; `model` untyped | `pack_status` is `null` with no README; `model` is `null` when no reader ran | Same as Slices 2–4 | y (already accepted) |
| Suggested path: dispatch → classify → fix → repeat → write `cold-read.md` → Status → JSON | Seven phases: Read, Author checks, Dispatch, Classify, Resolve and record, Result and Status, Emit. Each round is written to `cold-read.md` as it finishes, not at the end | Files are the only state (ADR-002): a session that dies in round 3 keeps rounds 1–2. Author checks run first so readers spend their attention on gaps only a reader finds | n |
| `context.md` §4: `review-pr:4-14` | The list runs 4–16 | Two Bash entries were added since | n |

## Decisions

- **Pass rule:** the pack passes only when a round's **reader** raised no blocking item. Blockers
  that were fixed after round 3 are "resolved, not yet checked by a cold reader", so the run
  ends `COLD READ BLOCKED`. This pack's round-3 Result set the same precedent. `blocking` counts
  that last round's blockers plus any unanswered developer-only question.
- **Rounds:** the cap is 3 per run. A later run continues the numbering in `cold-read.md` with a
  fresh cap, which is how this pack's round 4 came about.
- **Modes by Status:** the read runs at any Status (the Input contract). `sliced` may set `reviewed`.
  Earlier Statuses, `reviewed` and `approved` fix the pack but leave Status alone. `published`,
  `executing` and `done` are **Record only**: one round is recorded and fixes are written as
  proposals, because the pack lives on the integration branch and executors read it from there.
- **No subagent at all** (R1): the skill never reads the pack itself, because it is not cold. It
  says to run `cold-read` in a session that can start one, and emits `COLD READ STOPPED`.
- **Author checks** (Phase 2) reuse `slice`'s Headings and Trace commands by reference
  (`$CLAUDE_SKILL_DIR/../slice/SKILL.md`, the same plugin), as Slice 4's Discoveries suggested. The
  fence command is generalised to every pack file. Its findings are recorded as `A1…` rows.
- **Earlier rounds are hidden from the author's slice choice:** Phase 1 reads only each round's
  first paragraph, and the full rounds only in Phase 4, after the new report.
- **Reader-changed pack:** before and after every read, the skill compares `cksum` listings. A
  difference voids the round with `COLD READ STOPPED`. `git status` cannot see changes inside an
  untracked pack, so it is not used.
- **Classification of contradictions and citations:** a contradiction is blocking when two mandatory
  items or two contracts disagree. A failed citation is blocking when a slice's Contracts or Stop
  conditions rest on it.
- **Restatement grep** after every blocking fix (this pack's round-4 lesson). The dry run showed
  why: round 2's only blocker was a fault in a round-1 fix.
- **Read order:** `cold-read` adds the `cold-read.md` entry when it creates the file (Slice 4
  Discoveries).
- **Bootstrap** loads `core` only when the install ships it (issue #221), as `spec` and `slice` do.
- **Registration order:** `cold-read` after `slice` in `marketplace.json`, the `**Skills:**` line and
  the README table.

## Discoveries

- **For Slice 6:** treat `COLD READ BLOCKED` as the S-05.3 stop: show the remaining questions from
  the closing **Result** of `cold-read.md` and do not publish. Treat `COLD READ STOPPED` as a stop
  that does not count as a cold read. Publish needs Status `reviewed`.
- **For Slice 6:** with Status at `reviewed` or `approved`, `cold-read` fixes the pack but never sets
  Status. After a Re-slice (Slice 4 Discoveries), the wrapper should re-run it and read `status`,
  not `pack_status`.
- **For Slice 6 or 9:** the Shared contract should list `COLD READ STOPPED` beside `SPEC STOPPED`
  and `SLICE STOPPED`, and allow `model` to be `null`.
- **For the Retro:** dry-run round 1 (Haiku) found every planted defect except the `python` fence,
  which the author check had already removed. It also flagged a valid Verify `grep` as code until
  the prompt said Verify commands are allowed. Round 2 found a real fault in the author's own
  round-1 fix, an awk field number, by running the command. Readers that **run** Verify commands
  catch what readers that only read cannot; compare Slice 1's note that four rounds missed a check-8
  fault.
- Both readers noticed the developer's uncommitted working-tree changes (`git status`) and reported
  them as questions. A cold read on a dirty checkout sees context the pack does not hold. Running it
  on a clean tree would avoid that.

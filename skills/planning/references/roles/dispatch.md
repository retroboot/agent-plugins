# Dispatch contract

How any planner skill dispatches any role. A role is one tight job defined once in a role card, a
file in this folder (`fact-checker.md` and the others; every file here but this one is a card). The
main session that dispatches roles is the **Facilitator**: it builds each prompt, runs the guard,
checks each report and triages the findings. No role dispatches another, and the Facilitator is
never a role itself.

Each card's `## Kind`, after its `## Model`, says what the role does: `review` (it checks a pack and
reports findings, by **Prompt frame**) or `draft` (it writes one pack file as its report, by
**Drafting frame**). A card with no `## Kind`, or any other value, is dispatched by no one.

Cold readers are not roles. They keep their own prompt and model rule in `cold-read` Phase 3.

## Model resolution

Read the card's `## Model`, the only place a role's model is stated, and dispatch with
`subagent_type: Explore`, which is read-only by tool set, and that model. Record the role's model
as `{Model} (Agent tool, model: {alias}, Explore)`, for example
`Sonnet (Agent tool, model: sonnet, Explore)`.

When the subagent tool has no model choice, dispatch a fresh subagent on the default model, with a
read-only type where one exists. Record the default model by name if known, else `default model`,
and the tool used. A missing capability changes where a role runs, never whether it runs.

## Prompt frame

One prompt per role, exactly this, with `{tree}`, `{path}`, `{name}` (the card's `# Role:` name),
`{letter}` and `{card}` filled in, and one line added after the Pack line per extra input the
card's **Inputs** lists (`Diff: {diff}`, `Seed: {seed}`). `{card}` is the card file pasted
verbatim. Add nothing else: no summary of the pack, no conversation, no reason for the review,
nothing the Facilitator learned this session. A fix diff reaches a role only as `{diff}`.

```text
You are the {name} on a planning team. Review a plan pack with the checklist on your role card.

Repository: {tree}
Pack: {tree}/{path}

Read only files under {tree}, and the input files named above. Every path in the pack is
relative to {tree}. Change nothing in the pack. Run only commands that are read-only or whose writes are git-ignored build output in {tree}.

Your role card:

{card}

Your report has these sections, in this order:

## Checklist run
A table: item | result | note. One row per checklist item on your card. The result is done, or
n/a with the reason.

## Findings
A table: id | blocking (yes/no) | file and section | what is wrong | evidence | checklist item.
Number the ids P{letter}1, P{letter}2 …. Evidence is a command and
the output it gave, or the quoted lines with path:line. A finding with no evidence is not
reported. Write "None." under the heading when there are no findings.
```

## Base

A skill that dispatches roles resolves `{base}` once per run, before its first dispatch, as
`cold-read` Phase 1 does (`cold-read` keeps its own): resolve `{integration}` (`branches.integration`
from `.hivrr.json`, then the repository default branch, then `origin/HEAD`, then `main`) and run
`git fetch origin {integration}`. `{base}` is `origin/{integration}`. If the fetch fails but
`git rev-parse --verify -q origin/{integration}` finds the ref, keep it, with the line
`Tree from origin/{integration}, not refreshed: fetch failed, may be stale.` When the ref is missing
too, `{base}` is `HEAD`, with the line `Tree from HEAD: origin/{integration} unavailable.` A fallback
is never a stop; the next checkpoint shows its line. In the same step take `{date}` (`date +%F`)
and `{sha}` (`git rev-parse --short {base}`), once for the run.

## Drafting frame

A drafter is dispatched only for a file the run writes new (at size S, for the README Slice's
Outcome and Acceptance when they are not yet written). In a Re-route or Revise spec, a file or
section that already exists is revised in place by the Facilitator, as `spec/references/reroute.md`
says, and gets no drafting line. A Re-slice is the exception: the Planner redrafts `plan.md` from
`{current}` (`slice/references/reslice.md`).

One prompt per drafting role, exactly this, with `{tree}`, `{path}`, `{name}`, `{letter}` and
`{card}` filled in as for **Prompt frame**, and `{file}` (the file to draft, relative to the pack),
`{template}` (its template), `{skill}` (the phase skill's `SKILL.md`, the phase to follow, and each
reference file that phase points to) and `{format}` (`pack-format.md`), each an absolute path, plus
`{date}` and `{sha}` from **Base**. `{template}`, `{skill}` and `{format}` resolve through
`$CLAUDE_SKILL_DIR` of the skill being run, the copy it reads its own references from; they are
read-only inputs outside the tree and the guard. An extra input the card's **Inputs** lists is one
line after the Pack line, as for **Prompt frame**. Add nothing else: the pack already holds every
approved earlier file.

```text
You are the {name} on a planning team. Draft one file of a plan pack, as your role card says.

Repository: {tree}
Pack: {tree}/{path}
File to draft: {file}
Template: {template}
Skill: {skill}
Pack format: {format}
Date: {date}
Commit: {sha}

Read only files under {tree}, and the input files named above. Every path in the pack is
relative to {tree}, and so is every path you write in the draft. Change nothing anywhere: your
report is the draft, and the Facilitator writes it. Run only read-only commands.

Follow the skill's phase for this file, and its template. Your role card says what the file
needs beyond them.

Your role card:

{card}

Your report has these sections, in this order:

## Draft
The whole file, verbatim, between these two lines and nothing else in this section. Do not
wrap it in a fence.
=== BEGIN {file} ===
=== END {file} ===

## Open points
A table: Id | Question | Options | Blocking (yes/no). One row per point the file could not
settle from the pack and the repository: a choice only the developer can make, or a claim you
could not check. Number the ids D{letter}1, D{letter}2 …. Write "None." under the heading when
there are none.
```

The marker lines are not a fence, so the file's own `bash` and `mermaid` fences pass through
intact. When the Analyst drafts the size S Slice, its markers name `README.md`, and its draft holds
only the Slice's `### Outcome` and `### Acceptance`, which the Facilitator puts in place of those
two headings.

## Draft completeness check

Check each draft on its own. It is incomplete when a marker line is missing, names another file or
comes twice; when `## Open points` is missing; when a section the template's trigger requires for
this route is missing, apart from those the Facilitator adds after the draft (ADRs, `inventory.md`,
`ux.md`, modifier sections and the size S README Slice's later headings); in a Re-slice, when it
changes a slice the recorded reason does not name; or when no report came back, the tool ended the
dispatch with an error, or the developer interrupted it. There is no time limit.

Dispatch an incomplete draft's role once more, in a new tree under the same guard. After a second
incomplete draft, the Facilitator drafts the file itself by the card, and the drafting line is
`Drafted by the Facilitator: {role} gave no complete draft.`

An accepted draft: write the text between the markers to `{path}/{file}`, over whatever is there,
with its Read order entry as the phase skill says. Triage each open point as **Triage** says for a
finding. A non-blocking one the Facilitator settles in the file and lists at the checkpoint that
shows it; a blocking or developer-only one is held for its stage's checkpoint, which lists it, with
its Id, alongside that checkpoint's content.

## Drafting lines

When a draft is accepted, display `Draft: {role} {model} — {file}, {o} open points`.

The checkpoint that shows a drafted file shows its drafting line,
`Drafted by the {role}, {Model} (Agent tool, model: {alias}, Explore).`, and any **Base** fallback
line. When the tool rejects the card's model, the role runs on the default model as **Model
resolution** says, and the line is `Drafted by the {role}, default model (Agent tool, Explore).`

## Tree and guard

Build a new detached tree of `{base}` with the pack copied in for each **pass**, by the commands
in `$CLAUDE_SKILL_DIR/../cold-read/references/tree.md`, in every mode. In Record only, skip the copy
line, and leave the tree `cold-read` Phase 2 built alone: it is the first reader's. The panel never
uses it, and removes it only on a void pass (`cold-read` `references/panel.md`). A pass is one
dispatch step, however many roles it sends; every role in it shares that tree, and `{tree}` in each
prompt is its path.

Each drafting dispatch is a pass of its own. Run the checksum guard before the pass and after the
last report. A difference outside git-ignored output voids the pass: say which files changed,
remove the tree, and stop the run, `COLD READ STOPPED` in the panel and `{SKILL} STOPPED` in the
skill that dispatched a drafter, with Status unchanged and the files on disk. Git-ignored build output in the tree, such as `target/`, is not a difference:
the guard's `git status --porcelain` does not list ignored files. Remove the tree after the guard.

`{diff}` and `{seed}` are files outside the tree, in a temporary directory of their own. `{diff}`
is `diff -ru` of a copy of the pack taken before the fixes against the pack after them, since the
pack is untracked; `{seed}` holds each seed item's Id, file and section, and its text verbatim.

## Output contract

Each report has `## Checklist run` (item, result: done, or n/a with the reason) and `## Findings`
(Id, blocking, file and section, what is wrong, evidence, checklist item). Ids are
`P{letter}{n}`. Evidence is a command and the output it gave, or quoted lines with `path:line`.

## Completeness check

Check each role's report on its own, never the panel as a whole. A report is incomplete when a
section is missing (the two the prompt gives, and any the card's **Output** adds), a checklist
item of its card is absent from **Checklist run**, or a blocking finding has no evidence. Dispatch that role alone once more, in a new tree under the same guard.
A second incomplete report is recorded in the round summary as
`Panel: {role} gave no complete report; not reviewed by {role}.`, and the run continues without it.

## Triage

Class every finding of the complete reports with the cold read's blocking test: a finding is
**Blocking** when the executor could not build the slice correctly without it. A role's `blocking`
column is its own call; the Facilitator may re-class a finding only with a reason recorded in its
Resolution, as `cold-read` Phase 4 does for a reader. Mark a blocking finding **developer-only**
on the same rule as `cold-read` Phase 4: a product decision, or confirming, changing or reversing
an ADR.

## No subagent tool

When no subagent tool exists, the Facilitator works through each card in turn itself, in the same
tree under the same guard, and writes each report in the output contract. The round summary says
`Panel run by the Facilitator: not independent.`

A drafting role due with no subagent tool: the Facilitator drafts the file by the card itself, and
the checkpoint that shows the file says `Drafted by the Facilitator: not independent.` in place of
the drafting line.

In a gate (`../gates.md`), the Facilitator works through each of the gate's cards itself, in the
same tree under the same guard, and the checkpoint says
`Gate run by the Facilitator: not independent.`

Cold readers are not covered by this: a reader
needs a subagent, and `cold-read` Phase 3 stops without one.

# Dispatch contract

How any planner skill dispatches any role. A role is one tight job defined once in a role card, a
file in this folder (`fact-checker.md` and the others; every file here but this one is a card). The
main session that dispatches roles is the **Facilitator**: it builds each prompt, runs the guard,
checks each report and triages the findings. No role dispatches another, and the Facilitator is
never a role itself.

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

## Tree and guard

Build a new detached tree of `{base}` with the pack copied in for each **pass**, by the commands
in `$CLAUDE_SKILL_DIR/../cold-read/references/tree.md`, in every mode. In Record only, skip the copy
line, and leave the tree `cold-read` Phase 2 built alone: it is the first reader's. The panel never
uses it, and removes it only on a void pass (`cold-read` `references/panel.md`). A pass is one
dispatch step, however many roles it sends; every role in it shares that tree, and `{tree}` in each
prompt is its path.

Run the checksum guard before the pass and after the last report. A difference outside git-ignored
output voids the pass: say which files changed, remove the tree, and stop the run
`COLD READ STOPPED`. Git-ignored build output in the tree, such as `target/`, is not a difference:
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
`Panel run by the Facilitator: not independent.` Cold readers are not covered by this: a reader
needs a subagent, and `cold-read` Phase 3 stops without one.

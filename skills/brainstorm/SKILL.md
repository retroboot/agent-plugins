---
name: brainstorm
description: Collaborative thinking session to work through a technical problem or idea, kept as a plan pack README if you choose
license: MIT
compatibility: opencode
---

# Brainstorm

A thinking session — not an implementation session. The goal is to reach clarity on a problem, explore alternatives, and challenge assumptions before committing to an approach. Nothing is built here. At the end, you propose a route for the work, and the user decides whether to keep what was learned as a plan pack README under `docs/plans/<slug>/` or to discard it.

Keep the conversation moving. Ask pointed questions. Do not drift into implementation detail unless the user pulls you there. Depth over breadth — explore one thread fully before branching.

**Files are the only state.** Until the user chooses to keep the brainstorm, nothing is written anywhere: the conversation itself holds what has been learned. A kept brainstorm lives entirely in `docs/plans/<slug>/README.md`, which is how a later session — or the `planning` wrapper — picks it up.

This skill no longer ships a command wrapper — `command/brainstorm.md` has been retired now that
every target coder supports invoking a skill directly. The bootstrap chain that command used to run
lives here instead.

The pack format of record is `$CLAUDE_SKILL_DIR/../planning/references/pack-format.md`, and the
README template is `$CLAUDE_SKILL_DIR/../planning/references/templates/README.md`. When this skill
and the format disagree, the format is right.

---

## Bootstrap

Run before Phase 1:
1. Load the `core` skill — internalizes quality standards and architectural principles

---

## Phase 1 — Parse the Input

The input can be:
- A specific technical problem: "our auth middleware is leaking sessions"
- An open question: "should we split this service?"
- A vague feeling: "something feels wrong with how we handle errors"
- No input — open thinking session, ask what they want to work through
- A pack path: `docs/plans/<slug>` — resume an earlier brainstorm (see below)

Extract:
- `topic` — what the user wants to think through
- `framing` — is this a problem to solve, a decision to make, or an idea to explore?
- `resume_pack` — the pack path when the input is one, otherwise none

### Resume from a pack

When the input is a path under `docs/plans/`, read `{path}/README.md`.

- **No README there:** say `No pack at {path}`, then ask what the user wants to think through and
  continue as a new brainstorm.
- **README found:** read its header **Status**, and its **Brief**, **Ruled out**, **Key insights**,
  **Open questions** and **Route** sections. Take `topic` and `framing` from the Brief. Set
  `resume_pack` to the path.
  - Status `discovered`: this is a saved brainstorm. Phase 3 re-opens the conversation from it.
  - Status `routed`, `specified`, `sliced`, `reviewed` or `approved`: the pack has moved past
    discovery but is not yet published. Say
    `Pack is at Status {status}; brainstorm will revise Brief, Ruled out, Key insights and Open questions in place, list each revision under Open questions until it is approved, and leave Status and Route as they are.`
    Then continue. No skill ever lowers Status.
  - Status `published`, `executing` or `done`: the pack is fixed; its issues exist and executors
    rely on it. Say
    `Pack is at Status {status}; this is a read-only run — brainstorm will not edit a published pack.`
    Then continue. The conversation still runs, but nothing is written (Phase 6).

Display: `Topic: {topic} | Framing: {framing}` — plus ` | Resuming: {resume_pack}` when resuming.

---

## Phase 2 — Research Before Responding

Before saying anything, look at what's actually there.

Read the relevant code, open issues, and recent commits related to the topic. You want to understand the current state well enough to ask good questions — not to jump to answers. When resuming, also read anything else already in the pack folder.

This phase is silent. Do not show your research process unless asked.

---

## Phase 3 — Open the Conversation

Present what you understand about the topic in 2–4 sentences, then ask the single most important question that would unlock the most clarity.

Do not present multiple questions at once. Do not present solutions yet. Do not validate the user's framing without examining it first — if the framing seems off, say so.

Good first questions:
- "What's making this feel wrong right now — a specific symptom or a general sense?"
- "Has this approach worked elsewhere in the codebase, or is this the first time?"
- "What would a good outcome look like in concrete terms?"
- "What have you already ruled out and why?"

Present the question directly to the user and wait for their response in the conversation.

### When resuming

Do not start from a blank page. Open from the saved README instead:

1. Restate the saved **Brief** in 2–4 sentences, and name what is already under **Ruled out** so
   it is not argued again unless the user reopens it.
2. List the saved **Open questions**, then ask the single one that would unlock the most clarity.
   If the README says "None.", ask what has changed since the brainstorm was kept.

---

## Phase 4 — Iterate

Keep the conversation going until the user has reached clarity or run out of useful threads to pull.

Each response should:
- Reflect back what you just heard to confirm understanding
- Introduce one new angle, constraint, or alternative worth considering
- End with a question or a concrete observation that moves the thinking forward

Challenge assumptions when you spot them: "You said X — what if the opposite were true?" Surface tradeoffs that the user might not have considered.

Do not agree with everything. If a proposed direction contradicts an established pattern or a prior decision, say so directly and explain why.

Stay in thinking mode. If the user starts heading toward implementation details, redirect: "We can get into that — but first, are we confident this is the right approach?"

### Keep track as you go

Hold these in the conversation, not in a file — they become the README sections if the brainstorm
is kept:

- **Brief** — the problem, the outcome wanted and the scope
- **Ruled out** — each option considered and dropped, with the reason
- **Key insights** — what the conversation learned that changes the plan
- **Open questions** — what is still undecided

When resuming, start these from the saved sections and revise them as the conversation moves.

---

## Phase 5 — Propose a Route

When the conversation has run its natural course, or when the user signals they're ready to move
on, propose a route. Read **§2 Routing** of `pack-format.md` first; the route uses its terms
exactly.

Propose each part with a one-line reason:

- **Type** — one of Change, Bug, Spike, Feature, Refactor, Migration, Greenfield or Rewrite, from
  the routing matrix.
- **Size** — S (1 slice), M (2–6), L (7–12) or XL (over 12, split into child packs), from the size
  table. A Change is always S. A Spike has no size.
- **Modifiers** — zero or more of data, integration, performance, security, ui, observability,
  public-api and infra, from the modifiers table. Name only those the work really touches; "No
  modifiers" is a valid answer with a reason.
- **Slug** — kebab-case, derived from the topic. List `docs/plans/`; if a folder with that name
  already exists, append `-2` (or the next free number). When resuming, the slug is the existing
  folder's name and is not re-proposed.

When resuming a pack whose Status is past `discovered`, skip this phase: its Route is already
confirmed and is not this skill's to change.

**Not routed.** If the conclusion is a batch of independent small items rather than one piece of
work, say that it is not routed and recommend `ship-issue` for the items. Do not ask keep or
discard, and write nothing: skip Phases 6 and 7, and go to Phase 8 with `BRAINSTORM NOT ROUTED`
and `route: null`.

This is a proposal, not the confirmed route. The `planning` wrapper confirms it, and may change the
slug, at its Route checkpoint.

Display:

```
Proposed route
  Type:      {type} — {reason}
  Size:      {size} — {reason}
  Modifiers: {modifiers or "none"} — {reason}
  Slug:      {slug}
```

---

## Phase 6 — Keep or Discard

When resuming a pack at `published`, `executing` or `done`, do not ask. Say
`Read-only run: {resume_pack} is at Status {status}, so nothing is written.` and go to Phase 8 as a
discard.

Otherwise, show the Brief, Ruled out, Key insights and Open questions you have been tracking, then
ask:

> Keep this brainstorm as `docs/plans/{slug}/README.md`, or discard it?

Wait for the answer.

- **Discard:** write nothing. Do not create the folder, and when resuming, do not touch the
  existing README. Go to Phase 8.
- **Keep:** go to Phase 7.

---

## Phase 7 — Write the README

Only a kept brainstorm reaches this phase.

### New pack

1. Read `$CLAUDE_SKILL_DIR/../planning/references/templates/README.md`.
2. Run `git config user.name` for Owner, and `date +%F` for Opened.
3. Create the folder `docs/plans/{slug}/` and write `README.md` from the template, keeping its
   section order:
   - **Title line:** a short name for the work.
   - **Header table:** Status `discovered`; Type, Size and Modifiers from the proposed route;
     Issues `not yet published`; Owner; Opened. Write Size as the size and its slice range from
     the size table: `S — 1 slice`, `M — 2–6 slices`, `L — 7–12 slices`, `XL — over 12 slices`.
     For a Spike, which has no size, write `n/a`.
   - **Brief**, **Ruled out** and **Key insights** from the conversation. Write "None." under
     Ruled out if nothing was.
   - **Child packs**, **Question**, **Repro and root cause** and **Slice:** delete all four. They
     are not brainstorm's to write; `spec` and the `planning` wrapper add them from the template
     when the route needs them.
   - **Route:** open the section with the line `Proposed by brainstorm; not yet confirmed.`, then one
     bullet each for type, size and modifiers, with its reason.
   - **Read order:** only item 1, `This file, including **How to execute this pack** below`. Each
     later skill adds the files it writes.
   - **How to execute this pack:** copy it verbatim from the template, replacing `<slug>` with the
     slug and changing nothing else.
   - **Open questions** from the conversation, or "None."
   - **Retro:** copy it from the template unchanged.
4. Remove every other `_Guidance:` line that the content above replaced.

Do not stage or commit the folder. The pack stays untracked until the `planning` wrapper publishes
it, which is also what lets the wrapper rename the folder if the slug changes at Route.

### Resuming

Edit the existing `{resume_pack}/README.md` in place; never create a second folder, and never
rewrite a section wholesale — revise what the conversation changed and keep the rest.

- Revise **Brief**, **Ruled out**, **Key insights** and **Open questions**.
- Status `discovered`: also revise the header Type, Size and Modifiers rows and the **Route**
  section from the new proposal. Status stays `discovered`.
- Status `routed` to `approved`: leave the header, **Route** and Status as they are. Add one line
  per revised section to **Open questions** — `Revised by brainstorm on {date}: {section} — awaiting approval at the next checkpoint.`
  — so it stays visible until the developer approves it.
- Status `published`, `executing` or `done` never reaches this phase (Phase 6).
- Leave every other section untouched.

Display: `Pack written: docs/plans/{slug}/README.md (Status: {status})`

---

## Phase 8 — Emit the Result

Emit one JSON object as your entire final response — no markdown, no preamble, no trailing text.
Write `null` bare, never as the string `"null"`.

**Kept:**

```json
{
  "status": "BRAINSTORM COMPLETE",
  "pack": "docs/plans/{slug}",
  "pack_status": "{README Status after the run}",
  "route": {
    "type": "{type}",
    "size": "{S | M | L | XL}",
    "modifiers": ["{modifier}"],
    "slug": "{slug}"
  }
}
```

For a Spike, `size` is bare `null`. When resuming a pack past `discovered`, `route` is read back
from its header and **Route** section.

**Discarded, or a read-only run:**

```json
{
  "status": "BRAINSTORM DISCARDED",
  "pack": null,
  "pack_status": null,
  "route": null
}
```

**Not routed** (Phase 5): the same keys and values, with `"status": "BRAINSTORM NOT ROUTED"`. It is
a status of its own, not a reason field on `BRAINSTORM DISCARDED`, so a caller that reads only
`status`, as the `planning` wrapper does, tells "thrown away" from "no route: run `ship-issue`"
without reading anything else.

When resuming, `pack` is `"{resume_pack}"` and `pack_status` is its unchanged Status instead,
because that README still exists; `route` stays `null`.

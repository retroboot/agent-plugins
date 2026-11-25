# ADR-001: Research roles take a third Kind, research, with its own frame

**Status:** accepted (developer, 2026-11-24); amended by ADR-009, the exception covers five `dispatch.md` additions

**Proposed by:** developer

## Context

A research report fits neither dispatch frame: `dispatch.md` knows only `review` and `draft`, and
any other Kind is dispatched by no one, while `cold-read`'s panel prints
`Card {file} states no kind; not dispatched.` for it (`context.md` §2, The role cards and dispatch
contract). The Brief keeps `cold-read` out of scope. The developer chose at the acceptance
checkpoint (prd **Checkpoint answers**, A1 and A8).

## Options

1. **Reuse the review frame.** Rejected: a review frame checks a pack, and a new topic has none;
   the panel would also dispatch research cards as reviewers.
2. **A research frame defined inside `brainstorm`, `dispatch.md` unchanged.** Rejected: the cards
   would still carry a Kind the contract does not know, and the frame would live apart from every
   other frame.
3. **A third Kind, `research`, with its frame in `dispatch.md`, and one `panel.md` line that skips
   it silently.** Chosen.

For the Scout: reusing `scout.md` was rejected because a card has one Kind and `scout.md` is a
`draft` card that `spec` depends on; a separate `research` card for the Scout's research use was
chosen.

## Decision

`dispatch.md` gains a `research` Kind and a research prompt frame; `panel.md` skips a `research`
card without a line. The Scout's research use, the Historian and the Skeptic are three `research`
cards; `scout.md` is unchanged.

## Consequences

Two small edits reach outside `brainstorm` (`dispatch.md`, `panel.md`), a deliberate exception to
the Brief's scope. Every frame stays in one file. A fourth Kind would need the same panel line.

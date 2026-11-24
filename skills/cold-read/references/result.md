# Closing Result

How cold-read Phase 6 writes the closing `## Result` of `cold-read.md`. It is rewritten after every
round and stays the last section of the file. The result JSON (Phase 7) is unchanged: `rounds` is
still this run's count, and `blocking` as Phase 6 defines it.

## Result line

`{total}` is the header **Rounds**, every round in the file; `{n}` is this run's rounds; `{N}` is the
last round's number, which equals `{total}`.

**On a pass:** the closing **Result** says `Pass after {total} round(s) ({n} in this run).`

**Not passed:** the closing **Result** says
`COLD READ BLOCKED: {blocking} blocking question(s) left after round {N} ({total} rounds, {n} in this run).`
and lists each one with its Resolution: `resolved, not yet checked by a cold reader`,
`awaiting the developer`, or, in Record only mode, the proposal. Show the same list to the
developer — this is the cold read's checkpoint (S-05.3). Nothing is published from here: the
developer answers what is theirs, then runs `cold-read {path}` again for up to 3 more rounds.

## Checklist proposals and panel findings

After the line come, in order: on a block, the blocking items; in Record only, any `Proposed:`
README **Read order** line; then these subsections, with nothing after them.

- `### Checklist proposals` lists every proposal in the run, one bullet per
  `Checklist line proposed for {role}: …` in a Resolution. Each bullet gives the item's Id, the role
  card's file and the proposed line verbatim, for example
  `- aQ3 → test-engineer.md: **V7** …`. A run with none writes `None.`. A proposal is never
  applied to the card here: cards change only through a PR the developer makes.
- `### Panel without a reader` is written when the run stops before this run recorded a round,
  holding the panel's findings in the Questions table form. A stopped run goes to Phase 7 from
  Phase 2 (a void re-check) or Phase 3 and never reaches Phase 6, so `panel.md` **No reader runs**
  writes it on the way, with `### Checklist proposals` reading `None.` since no reader item was
  traced. It goes after the existing result line, which a stopped run leaves as it was; a new file
  has none. It is left out otherwise.

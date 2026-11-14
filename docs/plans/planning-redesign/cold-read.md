# Cold read

| | |
|---|---|
| **Model** | Haiku (Claude Code Agent tool, `model: haiku`) |
| **Input** | Pack path and repository read access only; no conversation context |
| **Rounds** | 4 (round 4 requested by the developer past the cap) |
| **Result** | Round 4: 1 blocker, a leftover of a round-3 edit, resolved; awaiting developer |

## Round 1 — 2026-11-13

The reader was assigned Slices 1, 3 and 7 to think through. It spot-checked 23 citations: 21 held
in full, 1 held in part and 1 did not hold. It found no code in the pack.

### Questions

| Id | Blocking | File | Gap | Resolution |
|---|---|---|---|---|
| Q7.1 | yes | design §7 | Pack load point: "after the branch exists" in Phase 3, but the branch is created in Phase 5, and Phase 4 needs the size | Pack is read in Phase 3 via `git show origin/{integration}:…`; preflight moved to Phase 6, after the branch exists |
| Q7.2 | yes | README rule 7, ADR-007 | Progress format unreachable from a `dev`-only install | Progress format embedded in README rule 7; design §6 is now the mirror |
| Q7.3 | yes | design §4 | Nobody owns writing Status `executing` | `work-issue` writes it in the first slice PR that finds `published` (README rule 7, design §4 and §7) |
| Q7.4 | no | README rule 8 | How "last slice" is detected | design §7 **Last slice**: read the progress files on `origin/{integration}` |
| Q7.5 | no | design §7 | Blocked-path mechanics | design §7 **Blocked path** |
| Q7.6 | no | design §7 | Trace proofs (Phase 8) vs the progress write (Phase 10) | Collected in Phase 8, written in Phase 10 |
| Q7.7 | no | design §7 | Complexity mapping mixed type and size; XL never exists | Map by size only; Change is always S; XL is split |
| Q7.8 | no | plan Slice 7 | "Shape unchanged", but a new value | 7.3 reworded: keys unchanged, `BLOCKED` is a new value |
| Q7.9 | no | plan Slice 7 | S-07.3 scope | Slice 7 covers work-issue only, Slice 9 the rest |
| Q1.1 | no | plan Slice 1 | How to run the negative test | Verify spells out the scratch-dir procedure |
| Q1.2 | no | plan Slice 1 | Opening-fence detection | Line-start only, outside any open fence |
| Q1.3 | no | ADR-003, check 14 | Untagged fence could hide code | Untagged fences now rejected; this pack's tree retagged `text` |
| Q1.4 | no | design §5 | `bash` allowed anywhere vs "under Verify" | Accepted: the check enforces the tag; placement is a `slice`/`cold-read` concern |
| Q1.5 | no | plan Slice 1 | Template skeleton contents | Slice 1 Contracts now specify each template, including the size-S README sections |
| Q1.6 | no | plan Slice 1 | Does pack-format.md copy §7? | §2–§6 plus the Marker only |
| Q3.1 | no | plan Slice 3 | "8 types at size M" undefined for Change and Spike | S-03.1 scoped to the six types that admit M |
| Q3.2 | no | design §8 | "Contested ADR" undefined | `proposed` ADR = a decision the author made; defined in design §2 |
| Q3.3 | no | design §3 | Rule for O files | The owning skill proposes, the developer decides |
| Q3.4 | no | design §3 | Refactor prd vs "never replaced" | Section-level revision allowed; no file is deleted or rewritten |
| Q3.5 | no | design §3 | Status after re-route | Unchanged until the next approved checkpoint |
| Q3.6 | no | design §4 | Who updates Read order | Whichever skill adds the file; Slice 3 criterion 3.3 |
| Q3.7 | no | design §2 | Inventory skeleton | design §2, Inventory sections |
| Q3.8 | no | plan | Parallel slices edit the same registry lines | Merge 3 → 4 → 5 in order, rebasing each |

### Contradictions

| Id | Resolution |
|---|---|
| C1 `cold-read.md` claimed to exist | This file |
| C2 design §7 vs work-issue order | = Q7.1 |
| C3 Refactor prd vs never-replace | = Q3.4 |
| C4 S-03.1 vs the matrix | = Q3.1 |
| C5 complexity mapping | = Q7.7 |
| C6 ADR-009 `proposed` but "no open questions" | Listed in README Open questions; awaiting the developer |
| C7 fence policy three ways | = Q1.3, Q1.4; ADR-003 updated |
| C8 Given/When/Then required but local criteria are bare | design §5: behavioural local criteria use G/W/T; structural ones may be statements proven by Verify; 1.1 and 7.2 rewritten |
| C9 `executing` ownership | = Q7.3 |
| C10 S-07.3 split | = Q7.9 |
| C11 parallel claim vs shared lines | = Q3.8 |
| C12 Spike path inconsistent | design §4 and §8: explicit Spike status path, no publish |
| C13 line-count drift | context.md corrected (549, 178, `review-pr:4-14`) |

### What this round shows

All three blocking questions sat at the boundary between the planner and `dev`: phase order in
another skill, a format one plugin cannot read, and a write with no owner. The checklist reviewer
that this pack replaces would have missed every one of them. They only appear when a reader
actually tries to execute a slice.

## Round 2 — 2026-11-13

A fresh Haiku reader thought through Slices 2, 5, 6 and 8, and formed its questions before reading
round 1. It spot-checked 21 citations: 19 held, 2 held but were misleading (`work-issue:136` sits
inside a deleted range; `{integration}` is resolved after Phase 3). It found no code in the pack.

### Blocking

| Id | Gap | Resolution |
|---|---|---|
| B1 | ADR-009 is `proposed`, so Slices 3–6 are gated | Gate, not a gap. Widened by C-b to ADR-007–010; **awaiting the developer** |
| B2 | ADR-001 conflicts with an auto-memory entry saying plans go in `.ai/plans/` | Stale snapshot: that memory was updated this session to `docs/plans/<slug>/` after the developer confirmed it. No pack change |

### Non-blocking

Every default the reader proposed was adopted unless noted.

| Id | Resolution |
|---|---|
| N1, C-a | design §7 ship-issue step 6: `BLOCKED` skips Ship and becomes `stuck` |
| N2, C-i | **Chose the legacy rule**: any `stuck` stops the whole run. S-06.2 reworded |
| N3, C-g | Step 3: slice list from plan.md, or from README as Slice 1 at size S; issue from the `Issue:` line or the Issues row |
| N4, Q7.1 follow-up | `{integration}` resolved in step 1 for ship-issue, and in Phase 3 for work-issue |
| N5, C-h | Step 8 rewords the Error Handling bullet; Slice 8 Files updated |
| N6, N7, C-c | Slice 2 Pattern now keeps 133–144 and 189–202, and deletes the container (145–185) and memory (204–220) parts |
| N8 | Owner and Opened written by whoever writes the README first (design §8) |
| N9 | Unchanged: haiku, recorded |
| N10, C-k | Reader uses `subagent_type: Explore`; the misleading review-pr pattern was removed |
| N11 | New subagent every round |
| N12 | Append rounds, never overwrite |
| N13 | design §8: no skill lowers Status |
| N14 | Developer-only questions are asked at once; unanswered means `COLD READ BLOCKED` |
| N15 | At least 8 citations, in the Slice 5 reader prompt |
| N16, C-d | The wrapper owns the Discover-skip README |
| N17 | The wrapper writes the Type, Size and Modifiers rows and the Route section at Route |
| N18 | Slug proposed at Discover; the folder may be renamed at Route while untracked |
| N19 | Publish step 4: the untracked pack carries across the branch switch |
| N20 | `ship-pr` detected via the session's available skills |
| N21 | Resume behaviour at `published`, `executing` and `done` |
| N22 | XL parent is README-only, with a Child packs template section |
| N23 | Verify (a) lists the would-be tracker and git commands instead of making them |
| N24 | Pattern cites `:231` only |
| N25 | design §5: traceability rows may group IDs |
| N26, C-e | `done` defined for Spike |
| N27, C-f | S-09.1: Spike size `n/a` |
| N28 | S-04.3 states the strict tag list |
| N29 | Accepted weakness: S-04.2 and S-04.4 are proven by the `slice` self-check and the cold read, not a structural check (R3) |
| C-b | ADR-007, 008 and 010 reclassified `proposed`; the README lists all four for confirmation |
| C-l | Slice 3 Contracts: `pack-format.md` is the format of record after Slice 1 |

### What this round shows

Round 1 found gaps at the boundary between the plugins. Round 2 found gaps in **ownership** (who
writes which README field, who resolves `{integration}`, who may change Status) and one honest
inconsistency in the author's own rules (C-b). It found no new blocking *knowledge* gap. The only
blocking items left are decisions only the developer can make.

## Result

**Pass, gated on the developer.** After 2 rounds there are zero blocking knowledge gaps. ADR-007,
008, 009 and 010 await confirmation. Once they are confirmed, Status moves to `reviewed`.

## Round 3 — 2026-11-13

A fresh Haiku reader ran as `subagent_type: Explore`, which is read-only. It thought through Slices 1,
3 and 4, the new content sections (ADR-012), and the pack's conformance to its own format. It
spot-checked 25 citations and all of them held. It found no code. Process note: it saw rounds 1–2
before finalising rather than after, which the Slice 5 reader prompt should guard against more
firmly.

### Blocking

| Id | Blocking | File | Gap | Resolution |
|---|---|---|---|---|
| B1 | yes | design §3, §4, §8 | Nobody writes a size-S pack's single slice: `spec` was skipped for Change, and `slice` at S | `spec` writes the README **Slice** section for every route at S, Change included (§4 item 4, §8 skip rules; Slice 3 criteria 3.4 and S-03.2) |
| B2 | yes | README, ADR-010 | How is *this* pack published when the wrapper doesn't exist yet? | New README section **Bootstrapping this pack**: issues and plan PR by hand, executed by issue number until Slices 7–8 |
| B3 | yes | ADR-007–010, round 2 | ADR status form vs design §2; round 2 said they await the developer | Stale: the developer approved after round 2. Headers now `accepted (developer, 2026-11-13)` plus a **Proposed by** line |
| B4 | yes | design §3 | Bug has no prd, yet its regression rules, NFRs and assumptions live in the prd | Bug: prd required at M+; at S the rules and examples go in the README slice. Spike has no rules or examples |

### Non-blocking

| Id | Blocking | Resolution |
|---|---|---|
| N1 | no | Slice 3 S-03.4 reworded to match design §3 Re-routing |
| N2 | no | Accepted as is: `ux.md` is the `ui` modifier's file (S-03.1.e1) |
| N3 | no | The folder is created only on keep |
| N4 | no | Status table: a Spike at `specified` resumes at the outcome ADR |
| N5 | no | Publish: create every issue, then add the `Depends on` lines |
| N6 | no | Progress PR field is `this PR` |
| N7 | no | **Changed**: the blocked path makes one `wip:` commit of the partial work, so state survives (ADR-002) |
| N8 | no | Phase 2 reads bodies for markers |
| N9 | no | Accepted risk: if the fetch fails, no marker is seen and legacy mode runs; `ship-issue` pack mode has already fetched every slice issue in its Phase 2 |
| N10 | no | design §13: every row is proven in the slice that owns its criterion; the listed dry runs are a minimum |
| N11 | no | Fixtures go in a temporary directory outside the repo |
| N12 | no | Slice 1 Verify: build the fence with `printf`; print nothing when `docs/plans/` is absent |
| N13 | no | Route added to the README contract (§4 item 5), and to this README |
| N14 | no | XL: the wrapper writes the parent, and each child is its own `planning` run |
| N15 | no | Observability alerts need a numeric threshold |
| N16 | no | Slice 4 4.1 explains the label size vs pack size |
| N17 | no | Contracts end with a **Rollback:** line for Migration and Rewrite |
| N18 | no | Covered by R1 |
| N19 | no | The NFR qualities are enumerated in design §3 |

### Contradictions

| Item | Resolution |
|---|---|
| design.md vs pack-format.md authority | README: design.md governs this pack; pack-format.md governs new packs after Slice 1 |
| Slice 9 "six planner skills" | Lists all seven |
| `in_progress` vs `in-progress` | The state diagram labels it `in-progress` |
| NFR one combined row | Split into one row per quality |
| Example tables without a When column | Format relaxed: a When shared by every row may sit in the column header |
| README Type cell a sentence | Now `Feature`; the explanation moved to Brief |
| plan.md Shared contract placement | Allowed by design §5 |
| cold-read.md not in template form | The template is created in Slice 1; this round is in the target form |
| Failure-mode row with trigger "—" | Removed |
| ER entity names not in glossary | Criterion, Issue and Progress file added |

### What this round shows

Round 1 found plugin-boundary gaps, round 2 ownership gaps, and round 3 **producer** gaps: an
artifact the format requires (the size-S slice, Bug rules) with no skill that writes it. The
pack's self-conformance review also caught 10 places where the pack broke its own format. Without
it, the first example of the format would have taught the wrong thing.

## Result

**Round cap reached (3).** Round 3 raised 4 blocking items. Per S-05.3 they are shown to the
developer rather than auto-passed. All 4 are resolved by edits above, but no fourth cold read has
verified those edits. Status stays `sliced` until the developer accepts this or asks for round 4.

## Round 4 — 2026-11-13

The developer asked for a fourth round past the cap. A fresh Haiku reader ran as
`subagent_type: Explore`, told not to open this file until its report was written. It did not open
it. It thought through Slices 3, 7 and 9; Slice 9 had not been covered before. It spot-checked 22
citations: 19 held, 3 held in part, none failed. It found no code, and every fence is tagged.

### Blocking

| Id | Blocking | File | Gap | Resolution |
|---|---|---|---|---|
| S7-Q1 / K3 | yes | plan Slice 7 (7.2) vs design §7 | Round 3 changed the blocked path to a `wip:` commit in design.md only; 7.2 still said "only the progress file is committed" | 7.2 now matches design §7; prd failure-mode row updated too |

### Non-blocking

| Id | Resolution |
|---|---|
| K1 | Slice 6 S-03.2 no longer says a Change skips `spec`; it skips `slice` only |
| K2 | `brainstorm` writes a *proposed* Route; the wrapper rewrites it as confirmed (design §1, §4, §8) |
| K4 | `sliced` at size S is passed through when `slice` is skipped; Status table and state diagram say so |
| K5 | `git fetch` writes remote-tracking refs. Rule reworded: `ship-issue` changes no working tree, index or branch (design §7 step 8, 8.1) |
| K6 | Slice 9 Verify grep adds `memory MCP` |
| K7 | design §4: an XL parent adds **Child packs** after Brief and has no Slice section |
| K8 | Traceability: S-04.2 maps to Slices 3 and 4 |
| K9 | 9.1 cites check 5 only |
| S6-Q1 | New criterion 6.4 covers the Discover skip |
| S7-Q2 | Accepted: the executor picks the citations its slice touches; drift in a contract stops the run |
| S7-Q3 | Accepted: the progress PR field is `this PR`; the PR number lives on the PR itself |
| S7-Q4, S3-Q1 | Retro and Spike README shapes come from the Slice 1 templates; the executor writes the skeleton there |
| S7-Q5 | Accepted: `Slice: N` names `## Slice N`; at size S the README slice is the last slice |
| S3-Q2, K10 | Accepted: `$CLAUDE_SKILL_DIR` is used by existing skills today; covered by R1-style portability risk |
| S3-Q3, S3-Q4 | Accepted as developer judgement during `spec`, prompted at its checkpoint |
| S9-Q1 | Release follows the repo's existing practice (see `139786d`); tagging is not changed by this pack |
| S9-Q2 | Accepted: the executor writes the description within 9.1's constraints |
| S1-Q2 | Accepted: Slice 1 writes the screen-inventory, navigation, wireframe and state-table parts as new content |

### What this round shows

The one blocker was not a new kind of gap. It was a round-3 fix applied to `design.md` but not
to the slice that restates it. The lesson for the `cold-read` skill: after resolving a blocker,
grep the pack for every restatement of the changed rule.

## Result

**Pass, gated on the developer.** Round 4 raised 1 blocking item, a leftover of a round-3 edit, now
resolved. No new kind of gap was found. Status moves to `reviewed` when the developer accepts.

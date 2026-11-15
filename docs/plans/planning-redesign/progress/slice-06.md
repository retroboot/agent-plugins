# Progress — Slice 6

| | |
|---|---|
| **Status** | done |
| **Issue** | #212 |
| **PR** | this PR |
| **Executor model** | Claude Opus 5.5 (`claude-opus-5-5`), following this repo's `skills/work-issue/SKILL.md` pack mode with marker `Plan: docs/plans/planning-redesign · Slice: 6` |
| **Date** | 2026-11-14 |

The slice was executed by following the repo's own `work-issue` pack mode (on `main`) as the
step-by-step procedure, with this README's **How to execute this pack** rules winning where the two
could differ. They did not differ in this run.

## Preflight

Checked against branch `issue/212`, cut from `origin/main` at `2477f7b`.

- `context.md` §2, `skills/planning/SKILL.md` 626 lines, 13 phases: holds (Phase 1 at 33, Phase 13
  at 608).
- Tracker behaviour to carry over (Pattern to follow), `skills/planning/SKILL.md:187-234` and
  `:488-559`: holds. Within them, label guidance at 198, epic rules at 201–216, issue creation and
  hierarchy at 488–518, board at 520–535, Linear at 539–559, story points at 555: hold.
- "Allowed APIs" at 110–119: holds. It is `spec`'s now (`context.md` citations, Slice 3).
- `skills/planning/references/blueprint.md` (161), `plan-writing.md` (191), `plan-review.md` (110):
  hold. Only `skills/planning/SKILL.md` referenced them outside this pack's records.
- `skills/planning/references/ux-checklist.md`: 143 lines, not 159. Differs; not touched by this
  slice, and `spec` reads it, not the wrapper.
- `skills/ship-issue/SKILL.md:24-29` Bootstrap block (Pattern to follow): holds. The file is now 258
  lines, not 178 (Slice 8); only the Bootstrap and "Load the X skill … capture its JSON" pattern
  (174–181) were used.
- `skills/planning/references/pack-format.md` §2, §3, §6, §7 and `templates/README.md`: hold.
- Phase-skill completion JSON, read from the merged skills: `brainstorm` Phase 8 (246–282),
  `spec` Phase 10 (359–379), `slice` Phase 7 (345–366), `cold-read` Phase 7 (304–330). They match
  the Shared contract plus the deviations Slices 2–5 recorded. Contract affected only through the
  amendment below.
- `skills/session/references/github.md`, `gitlab.md`, `linear.md`: hold **Create**, the sub-issue
  commands and **Create PR**, but no command to edit an issue body, which Publish step 1 needs.
  Differs; see Deviations.
- `skills/init/references/config.md` **Board operations** (414–): holds.

## Acceptance

Dry runs read `skills/planning/SKILL.md` (cited as `SKILL:line`) and
`skills/planning/references/publish.md` (`publish:line`) against each Given. Synthetic fixtures were
in `/tmp/claude-1000/…/scratchpad/s6`, never in the repository.

| ID | How it was shown |
|---|---|
| S-02.1 | Dry run (a), below: topic → Phase 2 `brainstorm` (SKILL:177) → Phase 3 Route checkpoint (SKILL:186–218, confirm/change/stop) → Phase 4 `spec`, whose checkpoints hold specify (SKILL:245) → Phase 5 `slice`, whose checkpoint holds slice (SKILL:279) → Phase 6 `cold-read` (SKILL:288) → Phase 7 Approve checkpoint before publish (SKILL:311–340) → Phase 8 Publish (SKILL:344). The four confirmations are Route, spec's, slice's and Approve |
| S-02.2 | Resume SKILL:121–141: the XL check, then the table mapping every Status before `published` to the phase after it, "without repeating a finished phase and without asking about the route" (SKILL:126–127) |
| S-02.2 (from `specified`) | Dry run (b), the Verify's own scenario: Status `specified`, Type Feature, Size M → SKILL:133 → Phase 5, loads `slice` with no `brainstorm`, Route or `spec`. `slice` starts at `specified`, so `SLICE COMPLETE` is expected with `sliced` (SKILL:72–77); the Size row is updated (SKILL:280–281). A Spike at `specified` goes to Phase 4 **Spike outcome** instead (SKILL:133, 262) |
| S-02.2.e1 | Status `routed` → SKILL:132 → Phase 4, loads `spec`; no `brainstorm`, and Re-route says "on a resume, do not ask" (SKILL:84) |
| S-02.2.e2 | Status `sliced` → SKILL:134 → Phase 6, Cold read |
| S-02.2.e3 | Status `executing` → SKILL:138 and 147–150: progress Status per slice from `origin/{integration}`, `not started` for a missing file, then the Next line, then stop |
| S-02.2.e4 | No README at `docs/plans/x` → SKILL:121–122: `No pack at docs/plans/x`, offers a new pack; on yes asks the topic and goes to Phase 2 with `x` proposed as the slug |
| S-02.3 | Dry run (c): stop at the Slice checkpoint → `slice` returns `SLICE STOPPED` with Status `specified` and `plan.md` on disk; SKILL:66–70 shows the reason, keeps the files, does not advance, ends `Resume: planning {path}`. "Files are the only state" (SKILL:24–27) covers every checkpoint; the Route stop leaves the README at `discovered` (SKILL:218–219), the Approve stop leaves Status unchanged (SKILL:340) |
| S-02.3.e1 | Status `routed`, PRD checkpoint rejected → `spec` stops with `prd.md` written and Status `routed`; the wrapper reads `SPEC STOPPED` (SKILL:66) and stops; named at SKILL:249–250 |
| S-03.2 | Dry run (d), Change: Phase 3 forces S (SKILL:192); Phase 4 `spec` writes the README single Slice (SKILL:252); Phase 5 skips `slice`, sets `sliced` and adds `progress/` to Read order (SKILL:276–277); cold read; Approve shows one issue titled with the pack title (SKILL:324); Publish creates one issue (publish:30–31) and writes the Issues row as `#{number}` (publish:90–91) |
| S-03.2.e1 | Change S: the spec files are `README.md` alone, holding the Slice's Acceptance with examples and Verify. See Decisions for `cold-read.md` |
| S-03.4 | Re-route section SKILL:81–97: allowed at any checkpoint, including Route; offered at Approve (SKILL:333, 339) and after a stop that asks for it (SKILL:68–69); "Never delete a pack file or rewrite one wholesale" (SKILL:87) |
| S-03.4.e1 | Feature M re-routed to Rewrite at Approve: SKILL:86–97 re-runs the Route checkpoint, rewrites header and Route only, writes `Cold read pending after re-route` (SKILL:92), then `spec` Re-route mode (adds `inventory.md` and required ADRs, lists each revised prd section in Open questions; expected `pack_status` unchanged, SKILL:72–77), `slice` Re-slice, `cold-read` re-read, then the gate (SKILL:305–308) and Approve. Status stays `reviewed` |
| S-03.5 | Dry run (e), Spike: Route Size `n/a` (SKILL:192, 225); Phase 4 Spike steps SKILL:255–272: `spec` writes the Question and sets `specified`, the wrapper stops; on resume (SKILL:133) `spec` writes the outcome ADR, or is skipped when an `accepted` one exists; then the re-route offer. Slice, cold read, approve and publish never run for the Spike (SKILL:257) |
| S-03.5.e1 | Outcome "use library X": `spec` records ADR-001 (expected `pack_status` `specified`, unchanged, SKILL:76–77); SKILL:265–268 offers a re-route naming Feature; on yes, Status `routed` and Phase 4 again; on no, Status `done` (SKILL:269) |
| S-05.3 | SKILL:294–298: `COLD READ BLOCKED` shows the closing **Result** questions with their Resolutions and `blocking`, does not publish, Status stays where it was, stop |
| S-05.3.e1 | 3 rounds, 1 blocking left: `cold-read` returns BLOCKED with Status `sliced`; the wrapper stops at SKILL:294 before Phase 7. Approve refuses `sliced` and both Approve and Publish pass the gate (SKILL:305–308, 313–314), so nothing is published. Re-read case: a BLOCKED re-read at `reviewed` leaves the closing Result `COLD READ BLOCKED …` and the `Cold read pending` line, so a resume at `reviewed` or `approved` runs Phase 6 again (SKILL:135–136) instead of publishing |
| S-09.1 | SKILL:188–195 proposes Type (the 8), Size (S/M/L/XL, `n/a` for a Spike), Modifiers (the 8), each with a one-line reason, then waits on confirm/change/stop (SKILL:218) |
| S-09.1.e1 | "Fix typo in signup email": Change, S (forced for Change, SKILL:192), no modifiers |
| S-09.1.e2 | "Move from Express 4 to 5": Migration from the routing matrix, M (2–6 slices), no modifiers; shown in the SKILL:209–216 display |
| S-09.2 | Dry run (f): SKILL:199–202 recommends `debug`, loads it by name or tells the developer to run it and resume; on confirm, SKILL:229–231 writes **Repro and root cause** folding in the report |
| S-09.2.e1 | "Users get logged out randomly": Bug, cause unknown → `debug` first (SKILL:199) |
| S-09.3 | Dry run (g): SKILL:112–115 (input) and 206–207 (at Route), plus SKILL:181–182 for brainstorm's own not-routed result, which the `null` exception lets through (SKILL:64–65): `Not routed … Run ship-issue {items} directly.`, nothing written |
| S-09.3.e1 | "These 9 lint findings": a list of independent small items → SKILL:112, no pack, recommend `ship-issue` |
| S-09.4 | Dry run (h): SKILL:203–205 proposes child packs, never one pack over 12 slices; on confirm SKILL:232–234 writes **Child packs**; SKILL:239–241 stops, each child its own `planning` run linking the parent. Resume of an XL pack at any Status from `routed`, including one re-routed to XL at `specified`, shows Child packs and stops before the Status table (SKILL:123–125), so `slice` is never loaded. Safety net: `slices` over 12 → re-route to XL (SKILL:281–282) |
| S-09.4.e1 | "Rebuild billing and auth and admin": XL, child packs `…-billing`, `…-auth`, `…-admin`, one per subsystem (SKILL:203) |
| 6.1 | SKILL:346–354 and publish.md Steps 1–5 in order (publish:28, 86, 99, 177, 210). The body template (publish:43–58) opens with the marker; the dependency pass (publish:65–78) rebuilds the full body with `Depends on #N`. Fixture: the marker parses as `work-issue` Phase 3 reads it (`slug=docs/plans/fix-typo slice=1`, one `Plan: ` line), and `grep -oE 'Depends on #[0-9]+'` (ship-issue Phase 4's scan) finds both lines. Bodies go through a file (publish:15–20). Fixture: a body passed as a double-quoted literal lost its backticks, because the shell ran them; the same text through `"$(cat b.txt)"` kept both backtick spans verbatim |
| 6.1 (resume) | Interrupted Publish: each `Issue:` reference is written at creation (publish:37–40) and skipped on resume (publish:33–35); the dependency edit is a full rebuilt body, so repeating it is harmless (publish:65–68); the epic is recorded as ` · epic #E` and skipped when recorded (publish:123–125); Linear mirror IDs are recorded on the `Issue:` line and skipped (publish:155–157); step 4 on a branch that exists switches to it (publish:187–188) and skips a done commit, push or PR (publish:201–206). Resume at `published` with no pack on `{integration}` offers step 4 again (SKILL:137, 143–145) |
| 6.2 | Parity with the old skill, publish.md Step 3: epic threshold (`issues.hierarchy`, github only, Size L — the old Complex tier — or ≥ `epicThreshold`, default 4; never at size S); epic title, body, labels, no size; check-then-add, one aliased node-ID query, one mutation per child; warn and continue; board for every issue including the epic, silent when `project` is absent; Linear primary/secondary, legacy fallback, `.linear.yaml`, story points 1/2/3/5; label guidance (SKILL:327–330); display lines. The plan doc link becomes the pack README link (design §8 step 3). No ADR conflicts, so the stop condition did not trigger |
| 6.3 | `git rm` of the three files. Verify grep below: no output. `grep -rnE 'blueprint\.md\|plan-writing\.md\|plan-review\.md'` across the repo finds only this pack's own records (`context.md`, `plan.md`, `progress/slice-05.md`) |
| 6.4 | SKILL:159–175: asks **Skip discovery?** once; on yes writes the README from the template (Brief from the input, Owner from `git config user.name`, Opened from `date +%F`), Status `discovered`, and does not load `brainstorm` |

**Dry run (a), a feature topic end to end**, on this repo (`github`, no `issues` key, no `project`),
with every checkpoint approved. Commands in order, beyond the phase skills' own:

1. Bootstrap: `init`, `session` (`SESSION: provider=github tracker=github`), `core`.
2. Phase 2: `brainstorm` (it runs `git config user.name` and `date +%F` when kept).
3. Phase 3: none (`mv docs/plans/{old} docs/plans/{new}` only if the slug changes).
4. Phases 4–6: `spec`, `slice`, `cold-read`; Phase 7: none.
5. Phase 8, step 1: per slice, in order, `cat > {file} <<'EOF'` (the body), then
   `gh issue create --repo hivrr/agent-plugins --title … --body-file {file} --label …`, then the
   `Issue: #{number}` edit to `plan.md`; then, per slice with dependencies, the rebuilt body to a
   file and `gh api --method PATCH repos/hivrr/agent-plugins/issues/{N} -F body=@{file}`.
6. Step 2: the Issues row (file edit). Step 3: epic and board skipped silently, Linear skipped.
7. Step 4: `git fetch origin main`; `git switch -c plan/{slug} --no-track origin/main`;
   `find docs/plans/{slug} -type f`; `git add {each file}`; `git status --short`;
   `git commit -m "docs(plans): add {slug} plan pack" …`; `git push -u origin plan/{slug}`;
   `gh pr create --repo hivrr/agent-plugins --title "Plan: …" --body "$(cat {file})" --base main`.
8. Step 5: offer `ship-pr` on the PR. Phase 9 display ends `Next: ship-issue docs/plans/{slug}`.

**Verify commands**, real output:

```text
$ eval "$(jq -r .verify.test .hivrr.json)"
structural checks pass
$ grep -rnE 'SESSION_UUID|session/\{|CONTAINER_MODE|plan-only|blueprint\.md|plan-writing\.md|plan-review\.md' skills/planning
(no output)
$ wc -l skills/planning/SKILL.md skills/planning/references/publish.md
  382 skills/planning/SKILL.md
  212 skills/planning/references/publish.md
```

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Files: rewrite `skills/planning/SKILL.md` | Also created `skills/planning/references/publish.md` | The NFR caps a rewritten `SKILL.md` at 400 lines; Publish's tracker detail moved to a reference. `SKILL.md` is 381 lines | n |
| Files list nothing in `skills/session/references/` | Added an **Edit** issue-body command to `github.md`, `gitlab.md` and `linear.md`, and changed their issue **Create** forms to take the body from a file | Publish step 1 edits each body, and `session` says every provider command comes from the reference; none had one. `session` ships in both `dev` and `planner`, so these are shared files, not planner-only ones. The change is additive: the new **Edit** commands, plus file-based bodies, which keep backticks a double-quoted `"{B}"` would run as commands (review round 1, R5). The `linear issue update --description` form is marked untested. Accepted by the orchestrator (review round 1) | n |
| Shared contract: `pack_status` string; no `STOPPED` values; `model` a string | Amended in `plan.md`: `pack_status` may be null, `SPEC STOPPED`, `SLICE STOPPED`, `COLD READ STOPPED` listed, `model` may be null | Recorded as contract deviations by Slices 2–5 (contract affected y) and accepted by the orchestrator for this slice | y (orchestrator-accepted amendment) |
| Old planning created the epic first, then the children | The epic is created in Publish step 3, after every slice issue, then the children are attached | design §8 puts slice issues in step 1 and the epic in step 3, and 6.1 requires that order. Linking was already a separate pass, so the effect is unchanged. Accepted by the orchestrator (review round 1) | n |
| Files: the frontmatter is part of the rewritten file | Its `description` now describes the wrapper | The old one promised TDD tasks, blueprints and a plan review, which no longer exist. `marketplace.json`, `CLAUDE.md` and `README.md` descriptions are left to Slice 9. Accepted by the orchestrator (review round 1) | n |
| work-issue Bootstrap: load `init`, `session`, `core` | Read the repository's own `skills/core/SKILL.md`, `.hivrr.json` and `CLAUDE.md` instead of loading the installed plugin skills | The orchestrator forbade reading anything under the installed plugins; the repo copies are the ones on `main` | n |

## Decisions

- **Phases** are the nine rows of design §8, headed `## Phase 1` to `## Phase 9`. The result
  handling and **Re-route** are unnumbered sections shared by several phases.
- **Re-route** is offered at Approve and after a phase skill stops asking for one, never on a resume
  (S-02.2.e1 says "no route question"). This is how the Route checkpoint is re-entered past `routed`.
  Accepted by the orchestrator (review round 1).
- **Cold read after a Re-slice or Re-route past `sliced`** is re-run, and only `COLD READ COMPLETE`
  lets the run reach Approve (Slices 4 and 5 Discoveries).
- **Size S** passes Status through `sliced` and adds the `progress/` Read order entry; after
  `SLICE COMPLETE` the Size row becomes `{size} — {slices} slices` (Slice 4 Discoveries).
- **brainstorm's `Proposed by brainstorm; not yet confirmed.`** line is removed at Route confirm,
  with the Discover skip's `Not yet routed.` (Slice 2 Discoveries).
- **Discover-skip header:** Type, Size and Modifiers read `not yet routed` until Route, which is
  where the wrapper proposes them (S-09.1).
- **XL parent:** Size row `XL — {n} child packs`; Status stays `routed`; it publishes nothing
  itself, and its README is committed with the first child's pack PR so check 14 and the children's
  links hold. Design §3 leaves the parent's Status and commit open. Accepted by the orchestrator
  (review round 1).
- **Spike with no re-route:** Status `done`; the pack is never published, so it stays untracked and
  the wrapper says how to keep it. Design §8 says Publish never runs for a Spike. Accepted by the
  orchestrator (review round 1).
- **Slug rename** also rewrites the slug in **How to execute this pack** rule 1, which holds it.
- **Interrupted Publish** leaves Status `approved`. Each reference is written the moment its
  issue is created, and a resume skips what the pack records (review round 1, R3). Step 1 therefore
  writes each slice's `Issue:` line itself, and step 2 confirms them and writes the Issues row. The
  order of design §8's steps is unchanged. Accepted by the orchestrator (review round 1).
- **Issue titles** `{pack title} — Slice {N}: {slice name}` (this pack's own form); labels: one
  type, one priority, the slice's size label. The pack PR body uses `Refs`, never `Closes`.
- **Epic threshold:** the old Complex tier maps to pack Size L, as `work-issue` maps L to complex.
- **S-03.2 "README alone"** is read as the spec files: `cold-read.md` is the cold read's record, and
  Publish needs a passed cold read (design §11), so a Change pack also gains `cold-read.md`.
  Accepted by the orchestrator (review round 1).
- **6.3 "nothing references them"** is read as nothing outside this pack's records. `context.md`,
  `plan.md` and `progress/slice-05.md` cite the files historically and are not edited (rule 6).
- **Re-read gate** (review round 1, R1). After a Re-slice or Re-route past `sliced`, Status cannot
  show that the cold read is stale. Two markers carry it instead: the README Open question
  `Cold read pending after …`, and `cold-read.md`'s closing Result. Approve and Publish require a
  `Pass after …` Result and no pending line. Only `COLD READ COMPLETE` removes the line.
- **Expected `pack_status` per mode** (R2). A first run expects the skill's own Status. A Re-route,
  Re-slice, re-read or Spike outcome expects the Status left unchanged. The Size row is updated on
  every `SLICE COMPLETE`.
- **Size S never gets an epic** (R4). Its Issues row stays a single `#{number}`, which is the form
  `ship-issue` reads for a pack with no `plan.md`. One parent over one issue is the bookkeeping the
  old threshold existed to avoid.
- **Linear as the tracker** (review round 1, deferred). Two cases:
  - **Linear mirrors the repo provider.** `plan.md` keeps `Issue: #{number}`, and the mirror's ID
    follows it in parentheses: `(Linear ENG-5)`. The executors parse only `#N`, so both still work.
  - **Linear creates the slice issues.** The `Issue:` lines then hold the Linear identifier. For the
    developer, `work-issue` still finds the marker, but `ship-issue`'s pack mode and its
    `Depends on #N` ordering read only `#N`, so the Next line names the identifiers in slice order.
    This matches design §7, which defines pack mode over `#N`, and changes no executor.
- **XL check before the Status table on resume** (R6). A pack re-routed to XL past `routed` would
  otherwise loop into `slice`, which refuses an XL parent.
- **Resume at `published` without the pack on `{integration}`** (deferred) offers Publish step 4
  again, and that step skips whatever is already done.
- **Loading `debug` and `ship-pr`** is by name and only when the session lists them; nothing reads a
  `dev` file (ADR-007).
- **Review round 2 (orchestrator):** every Publish title drops backticks and `$` (SKILL:324–326), since the
  **Create** commands pass the title in double quotes; step 2 keeps an existing ` · epic #E` suffix
  on the Issues row (publish:93–95), so a resumed Publish never creates a second epic.

## Discoveries

- **For a follow-up:** `ship-issue`'s pack mode reads only `Issue: #N`, so a pack whose slice
  issues live in Linear cannot run as `ship-issue docs/plans/<slug>`. Supporting
  `Issue: {identifier}` there would close that gap.
- **For a follow-up:** the PR commands in `github.md` and `gitlab.md` (**Create PR**, **Post
  comment**, **Edit a PR's title or body**) still show `"{B}"`, so they carry the same backtick
  hazard that R5 fixed for issues. `publish.md` passes `"$(cat {file})"` in their place.

- **For Slice 9:** `README.md:62` still describes `planning` as "Triage a feature into sized issues,
  and place them on the project board", and the `planner` description in `marketplace.json` and
  `CLAUDE.md` still names TDD tasks, complexity-aware blueprints and an automated plan review. None
  of those exist now.
- **For Slice 9:** `skills/init/references/config.md:141` defines `epicThreshold` as an issue count.
  With packs it is the slice count, which is the same number; a word there would help.
- **For Slice 9 or a follow-up:** a `brainstorm` that ends "not routed" returns the same JSON as a
  discard (`BRAINSTORM DISCARDED`, `route: null`). The wrapper relies on having seen brainstorm's
  message in the same session. A distinct status or a `reason` field would make it machine-readable.
- **For a follow-up:** `slice`'s checkpoint offers "revise the prd with `planning`" for a gap, but
  the wrapper has no "revise the spec, same route" step: a re-route with the same route reaches
  `spec`'s Re-route mode, and `spec docs/plans/<slug>` standalone does the same.
- **For the Retro (procedure used for real):** `work-issue`'s Bootstrap loads `init`, `session` and
  `core` by name, which resolves to the installed plugin, not the checkout being changed. An executor
  told never to read the installed plugin has to substitute the repo's own files, and the skill does
  not say which copy wins when they differ.
- **For the Retro:** `work-issue` Phase 8 points at `../init/references/verify.md` for command
  resolution; in pack mode the slice's own **Verify** plus `.hivrr.json` `verify.test` was all that
  was needed, and the pointer added nothing.
- **For the Retro:** as in Slice 8, **Load the pack** step 4 means reading the whole pack (about 2,500
  lines with progress files). The Discoveries addressed to this slice were spread over five progress
  files; a grep for `Slice 6` found them all, and a note in the procedure to do that would help.

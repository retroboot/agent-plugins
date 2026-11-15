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
| S-02.1 | Dry run (a), below: topic → Phase 2 `brainstorm` (SKILL:163) → Phase 3 Route checkpoint (SKILL:172–204, confirm/change/stop) → Phase 4 `spec`, whose checkpoints hold specify (SKILL:231) → Phase 5 `slice`, whose checkpoint holds slice (SKILL:265) → Phase 6 `cold-read` (SKILL:274) → Phase 7 Approve checkpoint before publish (SKILL:289–315) → Phase 8 Publish (SKILL:319). The four confirmations are Route, spec's, slice's and Approve |
| S-02.2 | Resume table SKILL:119–129 maps every Status before `published` to the phase after it; "without repeating a finished phase and without asking about the route" (SKILL:116–117) |
| S-02.2.e1 | Dry run (b): Status `routed` → SKILL:122 → Phase 4, loads `spec`; no `brainstorm`, and the Re-route section says "on a resume, do not ask" (SKILL:79) |
| S-02.2.e2 | Status `sliced` → SKILL:124 → Phase 6, Cold read |
| S-02.2.e3 | Status `executing` → SKILL:128 and 133–136: progress Status per slice from `origin/{integration}`, `not started` for a missing file, then `Next: ship-issue docs/plans/{slug}`, then stop |
| S-02.2.e4 | No README at `docs/plans/x` → SKILL:114–115: `No pack at docs/plans/x`, offers a new pack; on yes asks the topic and goes to Phase 2 with `x` proposed as the slug |
| S-02.3 | Dry run (c): stop at the Slice checkpoint → `slice` returns `SLICE STOPPED` with Status `specified` and `plan.md` on disk; SKILL:65–69 shows the reason, keeps the files, does not advance, ends `Resume: planning {path}`; Status names the last finished phase (`specified`). The rule "Files are the only state" (SKILL:24–27) covers every checkpoint; the Route stop leaves the README at `discovered` (SKILL:204–205), Approve stop leaves `reviewed` (SKILL:315) |
| S-02.3.e1 | Status `routed`, PRD checkpoint rejected → `spec` stops with `prd.md` written and Status `routed` (spec Phase 4, Stop); the wrapper reads `SPEC STOPPED` (SKILL:65) and stops; named at SKILL:235–236 |
| S-03.2 | Dry run (d), Change: Phase 3 forces S (SKILL:178); Phase 4 `spec` writes the README single Slice (SKILL:238); Phase 5 skips `slice`, sets `sliced` and adds `progress/` to Read order (SKILL:262–263); cold read; Approve shows one issue titled with the pack title (SKILL:302); Publish step 1 "Size S creates one issue" (publish:15–16) |
| S-03.2.e1 | Change S: the spec files are `README.md` alone, holding the Slice's Acceptance with examples and Verify (spec's README Slice at size S). See Decisions for `cold-read.md` |
| S-03.4 | Re-route section SKILL:76–91: allowed at any checkpoint, including Route; offered at Approve (SKILL:309, 314) and after a stop that asks for it (SKILL:67–68); "Never delete a pack file or rewrite one wholesale" (SKILL:82) |
| S-03.4.e1 | Feature M re-routed to Rewrite at Approve: SKILL:81–89 re-runs the Route checkpoint, rewrites header and Route only, then `spec` Re-route mode (adds `inventory.md` and required ADRs, lists each revised prd section in Open questions), `slice` Re-slice, `cold-read` re-read (SKILL:283–285), then Approve. Status stays `reviewed` |
| S-03.5 | Dry run (e), Spike: Route Size `n/a` (SKILL:178, 211); Phase 4 Spike steps SKILL:241–256: `spec` writes the Question and sets `specified`, the wrapper stops; on resume (SKILL:123) `spec` writes the outcome ADR, or is skipped when an `accepted` one exists; then the re-route offer. Slice, cold read, approve and publish never run for the Spike (SKILL:243) |
| S-03.5.e1 | Outcome "use library X": `spec` records ADR-001; SKILL:251–254 offers a re-route naming Feature; on yes, Status `routed` and Phase 4 again; on no, Status `done` (SKILL:255) |
| S-05.3 | SKILL:278–280: `COLD READ BLOCKED` shows the closing **Result** questions with their Resolutions and `blocking`, does not publish, Status stays `sliced`, stop |
| S-05.3.e1 | 3 rounds, 1 blocking left: `cold-read` returns BLOCKED with Status `sliced`; the wrapper stops at SKILL:278 before Phase 7, so nothing is published; Publish is reachable only from Approve, which refuses `sliced` (SKILL:291–292) |
| S-09.1 | SKILL:174–181 proposes Type (the 8), Size (S/M/L/XL, `n/a` for a Spike), Modifiers (the 8), each with a one-line reason, then waits on confirm/change/stop (SKILL:204) |
| S-09.1.e1 | "Fix typo in signup email": Change (a small fix to existing behaviour), S (forced for Change, SKILL:178), no modifiers |
| S-09.1.e2 | "Move from Express 4 to 5": Migration from the routing matrix, M (2–6 slices), no modifiers; shown in the SKILL:195–202 display |
| S-09.2 | Dry run (f): SKILL:185–188 recommends `debug`, loads it by name or tells the developer to run it and resume; on confirm, SKILL:215–217 writes **Repro and root cause** folding in the report |
| S-09.2.e1 | "Users get logged out randomly": Bug, cause unknown → `debug` first (SKILL:185) |
| S-09.3 | Dry run (g): SKILL:105–108 (input) and 192–193 (at Route), plus SKILL:167–168 for brainstorm's own not-routed result: `Not routed … Run ship-issue {items} directly.`, nothing written |
| S-09.3.e1 | "These 9 lint findings": a list of independent small items → SKILL:105, no pack, recommend `ship-issue` |
| S-09.4 | Dry run (h): SKILL:189–191 proposes child packs, never one pack over 12 slices; on confirm SKILL:218–220 writes **Child packs**; SKILL:225–227 stops, each child its own `planning` run linking the parent. Safety net: `slices` over 12 → re-route to XL (SKILL:267–268) |
| S-09.4.e1 | "Rebuild billing and auth and admin": XL, child packs `…-billing`, `…-auth`, `…-admin`, one per subsystem (SKILL:189) |
| 6.1 | SKILL:321–330 and publish.md Steps 1–5 in order (publish:13, 65, 74, 141, 170). Body template publish:23–37 opens with the marker; dependency lines publish:45–54 add `Depends on #N`. Fixture: the body's marker parses as `work-issue` Phase 3 reads it (`slug=docs/plans/fix-typo slice=1`, one `Plan: ` line) and `grep -oE 'Depends on #[0-9]+'` (ship-issue Phase 4's scan) finds both lines |
| 6.2 | Parity with the old skill, publish.md Step 3: epic threshold (`issues.hierarchy`, github only, Size L — the old Complex tier — or ≥ `epicThreshold`, default 4); epic title, body, labels, no size; check-then-add, one aliased node-ID query, one mutation per child; warn and continue; board for every issue including the epic, silent when `project` is absent; Linear primary/secondary, legacy fallback, `.linear.yaml`, story points 1/2/3/5; label guidance (SKILL:303–306); display lines. The plan doc link becomes the pack README link (design §8 step 3). No ADR conflicts, so the stop condition did not trigger |
| 6.3 | `git rm` of the three files. Verify grep below: no output. `grep -rnE 'blueprint\.md\|plan-writing\.md\|plan-review\.md'` across the repo finds only this pack's own records (`context.md`, `plan.md`, `progress/slice-05.md`) |
| 6.4 | SKILL:145–161: asks **Skip discovery?** once; on yes writes the README from the template (Brief from the input, Owner from `git config user.name`, Opened from `date +%F`), Status `discovered`, and does not load `brainstorm` |

**Dry run (a), a feature topic end to end**, on this repo (`github`, no `issues` key, no `project`),
with every checkpoint approved. Commands in order, beyond the phase skills' own:

1. Bootstrap: `init`, `session` (`SESSION: provider=github tracker=github`), `core`.
2. Phase 2: `brainstorm` (it runs `git config user.name` and `date +%F` when kept).
3. Phase 3: none (`mv docs/plans/{old} docs/plans/{new}` only if the slug changes).
4. Phases 4–6: `spec`, `slice`, `cold-read`; Phase 7: none.
5. Phase 8, step 1: `gh issue create --repo hivrr/agent-plugins --title … --body … --label …` once per
   slice, in order; then `gh api --method PATCH repos/hivrr/agent-plugins/issues/{N} -f body=…` for
   each slice with dependencies.
6. Step 2: file edits only. Step 3: epic and board skipped silently, Linear skipped.
7. Step 4: `git fetch origin main`; `git switch -c plan/{slug} --no-track origin/main`;
   `find docs/plans/{slug} -type f`; `git add {each file}`; `git status --short`;
   `git commit -m "docs(plans): add {slug} plan pack" …`; `git push -u origin plan/{slug}`;
   `gh pr create --repo hivrr/agent-plugins --title "Plan: …" --body … --base main`.
8. Step 5: offer `ship-pr` on the PR. Phase 9 display ends `Next: ship-issue docs/plans/{slug}`.

**Verify commands**, real output:

```text
$ eval "$(jq -r .verify.test .hivrr.json)"
structural checks pass
$ grep -rnE 'SESSION_UUID|session/\{|CONTAINER_MODE|plan-only|blueprint\.md|plan-writing\.md|plan-review\.md' skills/planning
(no output)
$ wc -l skills/planning/SKILL.md skills/planning/references/publish.md
  357 skills/planning/SKILL.md
  174 skills/planning/references/publish.md
```

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Files: rewrite `skills/planning/SKILL.md` | Also created `skills/planning/references/publish.md` | The NFR caps a rewritten `SKILL.md` at 400 lines; Publish's tracker detail moved to a reference. `SKILL.md` is 357 lines | n |
| Files list nothing in `skills/session/references/` | Added an **Edit** issue-body command to `github.md`, `gitlab.md` and `linear.md` | Publish step 1 edits each body, and `session` says every provider command comes from the reference; none had one. `session` ships in `planner`, so this is no `dev` file (ADR-007) | n |
| Shared contract: `pack_status` string; no `STOPPED` values; `model` a string | Amended in `plan.md`: `pack_status` may be null, `SPEC STOPPED`, `SLICE STOPPED`, `COLD READ STOPPED` listed, `model` may be null | Recorded as contract deviations by Slices 2–5 (contract affected y) and accepted by the orchestrator for this slice | y (orchestrator-accepted amendment) |
| Old planning created the epic first, then the children | The epic is created in Publish step 3, after every slice issue, then the children are attached | design §8 puts slice issues in step 1 and the epic in step 3, and 6.1 requires that order. Linking was already a separate pass, so the effect is unchanged | n |
| Files: the frontmatter is part of the rewritten file | Its `description` now describes the wrapper | The old one promised TDD tasks, blueprints and a plan review, which no longer exist. `marketplace.json`, `CLAUDE.md` and `README.md` descriptions are left to Slice 9 | n |
| work-issue Bootstrap: load `init`, `session`, `core` | Read the repository's own `skills/core/SKILL.md`, `.hivrr.json` and `CLAUDE.md` instead of loading the installed plugin skills | The orchestrator forbade reading anything under the installed plugins; the repo copies are the ones on `main` | n |

## Decisions

- **Phases** are the nine rows of design §8, headed `## Phase 1` to `## Phase 9`. The result
  handling and **Re-route** are unnumbered sections shared by several phases.
- **Re-route** is offered at Approve and after a phase skill stops asking for one, never on a resume
  (S-02.2.e1 says "no route question"). This is how the Route checkpoint is re-entered past `routed`.
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
  links hold. Design §3 leaves the parent's Status and commit open.
- **Spike with no re-route:** Status `done`; the pack is never published, so it stays untracked and
  the wrapper says how to keep it. Design §8 says Publish never runs for a Spike.
- **Slug rename** also rewrites the slug in **How to execute this pack** rule 1, which holds it.
- **Interrupted Publish** writes the issue numbers created so far into the pack and leaves Status
  `approved`; a resume skips slices that already have a number, so no issue is created twice.
- **Issue titles** `{pack title} — Slice {N}: {slice name}` (this pack's own form); labels: one
  type, one priority, the slice's size label. The pack PR body uses `Refs`, never `Closes`.
- **Epic threshold:** the old Complex tier maps to pack Size L, as `work-issue` maps L to complex.
- **S-03.2 "README alone"** is read as the spec files: `cold-read.md` is the cold read's record, and
  Publish needs a passed cold read (design §11), so a Change pack also gains `cold-read.md`.
- **6.3 "nothing references them"** is read as nothing outside this pack's records. `context.md`,
  `plan.md` and `progress/slice-05.md` cite the files historically and are not edited (rule 6).
- **Loading `debug` and `ship-pr`** is by name and only when the session lists them; nothing reads a
  `dev` file (ADR-007).

## Discoveries

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

# Progress — Slice 2

| | |
|---|---|
| **Status** | done |
| **Issue** | #208 |
| **PR** | this PR |
| **Executor model** | Claude Opus 5.5 (`claude-opus-5-5`), pack rules followed by hand |
| **Date** | 2026-11-14 |

## Preflight

Pack read from `origin/main` at `e4312cb`; the working copy matched it.

- `skills/brainstorm/SKILL.md` is 269 lines with 6 phases (`context.md` §2): holds.
- Phase 1 session UUID and memory at lines 27–70: holds.
- Container-mode polling at 145–185, with the live-terminal sentence at 147–148: holds.
- Incremental memory updates at 204–220: holds.
- Phase 6 summary and `/planning` offer at 224–269: holds.
- Conversational guidance at 133–144 and 189–202 (Pattern to follow): holds.
- `skills/work-issue/SKILL.md:526-539`, final JSON shape: holds (`### Emit the result` at 526).
- `skills/planning/references/templates/README.md` and `pack-format.md` (Slice 1 output): exist.
  The template's **How to execute this pack** matches this pack's own, with `<slug>` filled in
  (checked with `diff -B`).
- Check 7 phase rules (`docs/verification.md`, around line 78): holds.
- `$CLAUDE_SKILL_DIR/../planning/references/` is reachable from `brainstorm`: both are in `planner`
  (`.claude-plugin/marketplace.json`).

## Acceptance
## Acceptance

Line numbers refer to the new `skills/brainstorm/SKILL.md` after review round 1.

| ID | How it was shown |
|---|---|
| S-01.1 | Dry run (a), topic "add SSO", kept: Phase 6 Keep (line 191) → Phase 7 New pack (197–225). Line 203 creates `docs/plans/{slug}/README.md`; lines 206–218 write the header, Brief, Ruled out, Key insights and a proposed Route; Open questions follows the template order. The README rendered by following Phase 7 in the scratchpad had the headings Brief, Ruled out, Key insights, Route, Read order, How to execute this pack, Open questions, Retro, and no Child packs, Question, Repro or Slice section (line 212) |
| S-01.1.e1 | Same dry run with two options ruled out (own SAML stack, social login only): both under **Ruled out** (line 210), Route opens with `Proposed by brainstorm; not yet confirmed.` (line 215), header Status `discovered` and Size `M — 2–6 slices` (lines 206–209) |
| S-01.1.e2 | Dry run with `docs/plans/sso` existing: Phase 5 slug rule (line 150) gives `sso-2`; Phase 7 writes only `docs/plans/sso-2/`. In the scratchpad, `cmp` of `sso/README.md` before and after: identical |
| S-01.2 | Dry run (b), discard: Phase 6 Discard (line 189) writes nothing and goes to Phase 8; Phase 7 is reached only on keep (line 197). Phases 1–6 write no file: line 14 and line 122 (tracked in the conversation, not a file). The not-routed path (156–159) also writes nothing and skips Phases 6–7 |
| S-01.2.e1 | Brainstorm concluding "not worth doing", discarded: as S-01.2; the only folder creation is line 203, inside Phase 7. Phase 8 emits `BRAINSTORM DISCARDED` with bare `null` for `pack`, `pack_status` and `route` (lines 272–279) |
| S-01.3 | Verify grep `SESSION_UUID\|session/\{\|CONTAINER_MODE\|question\.json\|memory` on `skills/brainstorm/SKILL.md`: no output (exit 1). Also no `.ai/`, `uuid` or `container` anywhere in the file |
| S-01.3.e1 | No memory MCP configured: nothing in any phase calls or mentions one (grep above), so no warning can appear; the old fallback warning (old line 56) is deleted |
| S-04.1 | Phase 7 line 219 copies **How to execute this pack** verbatim with only `<slug>` replaced. Dry run (a): `diff -B` of the rendered `sso-2` section against the template with `<slug>`→`sso-2`: no difference |
| 2.1 | Dry run (c): resume on the scratchpad `sso-2` README (Status `discovered`). Phase 1 resume branch (47–66) reads Status, Brief, Ruled out, Key insights, Open questions and Route; line 56 sends Status `discovered` to Phase 3's resume branch, which says "Do not start from a blank page" (96), restates the saved Brief and Ruled out (98) and asks from the saved Open questions (100). Phase 7 Resuming (230) revises the README in place; Status stays `discovered` (234) |
| Stop condition | Not triggered. Old 135–143 and 191–202 are carried over verbatim (`diff` against `origin/main`: no difference) to new 82–90 and 107–118, plus the live-terminal sentence (new line 92). The file output sits in later phases and does not conflict |
| Structural | `eval "$(jq -r .verify.test .hivrr.json)"`: `structural checks pass`. Phases are `## Phase 1`–`## Phase 8` with no stated count. Check 14's lines run on the scratchpad pack (`sso`, `sso-2`): no output |

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Shared contract: `pack_status` is a string | On a discarded new brainstorm (and the not-routed path), no README exists, so `pack_status` is `null` | There is no Status to report; `pack` is already `null` for the same case. The Shared contract never defined the no-README case; the orchestrator accepted this in review round 1 rather than stopping | y |
| Suggested path step 2, "add a resume branch to Parse" | Done, plus matching resume branches in Phase 3 (open the conversation), Phase 6 (read-only run) and Phase 7 (revise in place) | 2.1 needs the conversation to re-open from the saved sections, which happens in Phase 3, not Parse | n |

## Decisions

- **Resume at `routed` to `approved`** (review round 1): `brainstorm` revises Brief, Ruled out,
  Key insights and Open questions in place, never wholesale, and adds one line per revised section
  to **Open questions** until the developer approves it (`pack-format.md` §2, Re-routing). Status
  and Route stay, following "No skill ever lowers Status" (`design.md` §8).
- **Resume at `published`, `executing` or `done`** (review round 1): a read-only run. The
  conversation runs, Phase 6 says why nothing is written, and the result is a discard.
- **Discard after resume.** The existing README is untouched; `pack` is the path, `pack_status`
  its unchanged Status, and `route` is `null` (review round 1).
- **Not routed** (review round 1): a batch of independent small items gets a `ship-issue`
  recommendation, no keep question and no file, and ends `BRAINSTORM DISCARDED` with `pack`,
  `pack_status` and `route` all `null`. When resuming, `pack` is the untouched pack path.
- **Sections brainstorm writes** (review round 1): only Brief, Ruled out, Key insights, Open
  questions and Route, plus the template's fixed header, Read order, How to execute and Retro.
  Child packs, Question, Repro and root cause and Slice are deleted.
- **Read order** holds only item 1; each later skill adds its own files.
- **Proposed marker.** The Route section opens with `Proposed by brainstorm; not yet confirmed.`
  The heading stays `## Route`, as the README contract names it.
- **Size row** (review round 1): `S — 1 slice`, `M — 2–6 slices`, `L — 7–12 slices`,
  `XL — over 12 slices`; `n/a` for a Spike. In the JSON, a Spike's `size` is bare `null`, and the
  templates write every `null` unquoted.
- The pack is not staged or committed by `brainstorm`; it stays untracked until Publish
  (`design.md` §8, Slug).
- Bootstrap still loads `core` only, as before; nothing in the slice needs tracker context.
- The frontmatter description now mentions the plan pack README.

## Discoveries

- **For Slice 6:** `brainstorm` returns `pack_status: null` (with `pack: null`) on
  `BRAINSTORM DISCARDED` when no pack exists, which is a new brainstorm discarded or not routed. The
  wrapper must accept a null there, not just a string.
- **For Slice 6:** when the wrapper confirms the Route, it must remove the line
  `Proposed by brainstorm; not yet confirmed.` from the README's **Route** section.
- **For Slices 3 and 6:** `brainstorm` no longer leaves placeholders for **Child packs**,
  **Question**, **Repro and root cause** or **Slice**. `spec` (Slice 3: Slice at size S, Question
  for a Spike) and the wrapper (Slice 6: Child packs at XL, Repro and root cause for a Bug) must
  add them from the template, in template order.
- Legacy `skills/planning/SKILL.md:37-61` still looks for brainstorm intent under a session UUID.
  After this slice it never finds any and falls back to its own Clarify phase. Slice 6 replaces it.
- No skill owns the `progress/` line in a pack's **Read order**: the template lists it, but
  `brainstorm` writes only item 1, and executors write progress files without editing the README.
  Slice 3, 4 or 6 should decide who adds it.
- `README.md:58` still describes `brainstorm` as "Collaborative thinking session on a technical
  problem"; Slice 9 owns that text.

# Context — what exists today

Every citation below was checked on 2026-11-13 at commit `139786d`. Preflight (README rule 2) means
re-checking the ones your slice touches.

## 1. Repository shape

- The product is Markdown and JSON. There is no build and no runtime. A skill is
  `skills/<name>/SKILL.md` plus optional `skills/<name>/references/*.md`.
- `.claude-plugin/marketplace.json` registers the skills for each plugin. `planner` currently lists
  `init`, `session`, `brainstorm`, `planning`. `dev` lists 12 skills, including `work-issue` and
  `ship-issue`.
- `.agents/skills/<name>` is a relative symlink to `../../skills/<name>`, one per skill directory.
- `CLAUDE.md` and `README.md` repeat the plugin descriptions and skill lists. Structural checks
  enforce that they match (see §5).

## 2. The skills being replaced

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `skills/brainstorm/SKILL.md` | 269 | 6 phases. Phase 1 makes a session UUID and writes memory (lines 27–70). Phase 4 has container-mode polling (145–185). Phase 6 writes a `summary` to memory and offers `/planning` (224–269). The conversational guidance in Phases 4–5 (133–220) is good and should be kept. | Rewritten (Slice 2) |
| `skills/planning/SKILL.md` | 626 | 13 phases: session UUID and memory (33–77), parse with `--plan-only` (81–98), research with an "Allowed APIs" list (102–121), clarify with container mode (125–167), complexity tiers (171–183), issue breakdown and epic rules (187–234), plan doc with code (238–392), review subagent (396–414), approval (418–484), create issues, epic and board (488–535), Linear (539–559), memory write (563–604), done (608–626). | Rewritten as the wrapper (Slice 6) |
| `skills/planning/references/blueprint.md` | 161 | Complex-tier multi-PR blueprint | Deleted (Slice 6); content absorbed by the routing matrix and slice anatomy |
| `skills/planning/references/plan-writing.md` | 191 | TDD task format with code | Deleted (Slice 6) |
| `skills/planning/references/plan-review.md` | 110 | Checklist reviewer prompt | Deleted (Slice 6); replaced by `cold-read` |
| `skills/planning/references/ux-checklist.md` | 159 | UI/UX plan section | Kept; becomes the UI modifier's reference |

**Keep from `planning`:**

- The "Allowed APIs" idea (lines 110–119). It becomes `context.md`'s citation list.
- The epic and hierarchy rules (201–216, 492–518).
- Board operations (520–535).
- The label guidance (198).
- The Linear handling (539–559).

These are tracker behaviours the wrapper's Publish phase still needs.

## 3. The execution skills being extended

### `skills/work-issue/SKILL.md` (549 lines, 12 phases)

| Lines | Section | Relevance |
|---|---|---|
| 49–64 | Phase 1, parse input | Add nothing; the marker is read from the issue body in Phase 3 |
| 68–89 | Phase 2, route multiple issues (unified wave vs sequential) | Pack slices must force `sequential` |
| 93–132 | Phase 3, repo and issue context, hierarchy check | The pack is read here from `origin/{integration}`; preflight runs later, in Phase 6, once the branch exists |
| 134–199 | Phase 3, **Load session context** (SESSION_UUID, memory, `.ai/session` fallback) | **Deleted** |
| 203–216 | Phase 4, complexity | A pack slice skips the question; complexity comes from the route |
| 364–376 | Phase 6, plan | With a pack, preflight runs, then the slice *is* the plan |
| 380–399 | Phase 7, implement; blocker rules at 393–395 | Stop conditions join the blocker rules |
| 403–411 | Phase 8, verify | Add the acceptance-ID trace |
| 445–449 | Phase 10, "never name the session fallback directory" | **Deleted** with the session section |
| 480–524 | Phase 12, **Write the session result** | **Deleted**; replaced by the progress file, which is committed in Phase 10, so it must be written before then |
| 526–539 | Phase 12, final JSON `{status, pr, pr_url, branch, issues}` | Shape unchanged; `ship-issue` and `wave` depend on it |

### `skills/ship-issue/SKILL.md` (178 lines, 6 phases)

| Lines | Section | Relevance |
|---|---|---|
| 33–51 | Phase 1, parse input | Accepts a pack path as well |
| 55–70 | Phase 2, fetch issues and comments | Unchanged |
| 74–87 | Phase 3, group by relatedness | Pack mode makes each slice its own group |
| 91–109 | Phase 4, order by `Depends on #N` | Pack mode orders by `plan.md` |
| 113–139 | Phase 5, per group: `work-issue --auto` then `ship-pr` | Unchanged mechanics |
| 143–166 | Phase 6, final JSON | Gains `"pack"` when one was given |
| 170–179 | Error handling: this skill "does not touch git directly" | Preserve this; the pack-on-integration check uses `git ls-tree`, which is read-only |

### Not changing

`skills/wave/SKILL.md` stays unchanged. It is reached only through `work-issue`'s unified strategy,
which pack slices never use (ADR-008).

## 4. Shared mechanics the new skills reuse

- **Bootstrap block.** Every workflow skill opens with `## Bootstrap`, loading `init`, `session`
  and `core` in order. Copy it from `skills/ship-issue/SKILL.md:24-29`.
- **Phase headings.** Use `## Phase N — Title`, numbered 1..N with no gaps. Check 7 enforces this.
  If you state a count in prose ("the seven phases"), it must match.
- **Frontmatter.** Use `name`, `description`, `license: MIT`, `compatibility: opencode`. A
  read-only skill may add `allowed-tools`, as `skills/review-pr/SKILL.md:4-14` does.
- **Composition.** "Load the X skill" means invoke it fresh even if it already ran this session
  (`skills/core/SKILL.md`, the Skill Composition section). Composed skills return a final JSON
  object as their entire last response. `ship-issue` is the pattern for a wrapper.
- **Tracker commands.** The provider references are `skills/session/references/{github,gitlab,linear}.md`.
  In `github.md`, issue commands are headed **List**, **Get**, **Create** and **Close** (lines
  9–45). Sub-issues start at line 46, and **Create PR** is at line 216.
- **Labels.** Use `skills/init/references/labels.md`, reached from a skill as
  `$CLAUDE_SKILL_DIR/../init/references/labels.md`. `$CLAUDE_SKILL_DIR` is always available, so
  don't guard it.
- **Config.** The keys are `.hivrr.json` `issues.hierarchy`, `issues.epicThreshold` and `project`,
  documented in `skills/init/references/config.md`. This repo sets none of them.
- **Staging.** `skills/core/SKILL.md`, **Staging**: stage explicitly by name, and run
  `git status --short` before committing. Line 70 lists `.ai/session/` as expected scratch; that
  bullet goes away in Slice 9.
- **`.gitignore`.** Line 4 comments `.ai/` as the "memory fallback written by the planning and
  work-issue skills". Reword it in Slice 9, but keep `.ai/` ignored.

## 5. How verification works here

- **Structural checks.** There are 13 checks in the fenced block in `docs/verification.md` (check 7,
  phase sequence, is at line 78; check 13, `.agents` symlinks, at line 156). Run them with
  `eval "$(jq -r .verify.test .hivrr.json)"`; the expected output is `structural checks pass`.
  `.hivrr.json` is gitignored, so on a fresh checkout scaffold it as described in
  `docs/verification.md` § "Bootstrapping `.hivrr.json` on a fresh checkout".
- **Adding a check.** Add a `# ` comment at column 0 inside the fence, and extend the
  "Thirteen checks: …" sentence at `CLAUDE.md:215`. Check 8 fails if you forget.
- **Adding a skill.** In the same PR, add it to `marketplace.json`, to the plugin's `**Skills:**`
  line in `CLAUDE.md`, to the plugin's table in `README.md`, and as an `.agents/skills/<name>`
  symlink. Checks 6 and 13 fail otherwise.
- **Behaviour.** No test runner executes skills. A slice proves a behavioural criterion with a
  **dry run**: read the changed skill as an executor would, against a named scenario, and record
  in the progress file which phase and line satisfies the criterion ID. Prove a removal with
  `grep` returning nothing.

## 6. Glossary

| Term | Meaning |
|---|---|
| **Plan pack** (pack) | The folder `docs/plans/<slug>/`, committed. Its README is the entry point. |
| **Slug** | Kebab-case folder name, unique under `docs/plans/`. |
| **Route** | Type, size and modifiers for a pack, confirmed by the developer. |
| **Type** | The kind of work: Change, Bug, Spike, Feature, Refactor, Migration, Greenfield or Rewrite. Decides which files a pack has. |
| **Size** | S (1 slice), M (2–6), L (7–12) or XL (split into child packs). Decides depth. |
| **Modifier** | A cross-cutting concern that adds a section to `design.md`: data, integration, performance, security, ui, public-api, infra or observability. |
| **Slice** | A vertical, independently mergeable unit of work: one issue, one PR. |
| **Marker** | The line `Plan: docs/plans/<slug> · Slice: N` in an issue body. |
| **Mandatory / guide** | The two halves of a slice. Mandatory items must hold; guide items are a default route. |
| **Stop condition** | A declared situation in which the executor must stop and report rather than improvise. |
| **Preflight** | The executor checks that the citations in `context.md` its slice depends on still hold. |
| **Deviation** | A recorded difference between the plan and reality: plan said / reality / why. |
| **Cold read** | A review of a pack by a fresh subagent on the smallest model, given no conversation. |
| **Criterion** | A PRD acceptance criterion, ID `S-NN.k`, or a slice-local one, ID `N.k`. |
| **Issue** | The tracker issue a slice is published as, carrying its marker. |
| **Progress file** | `progress/slice-NN.md`, written by the executor of slice NN. |
| **Example row** | One concrete case under a rule in the PRD, ID `S-NN.k.eN`. Executors prove each one. |
| **Blocking question** | A cold-read question the executor could not resolve from the pack and the repo. |

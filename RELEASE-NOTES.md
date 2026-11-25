# Agent Plugins Release Notes

## v1.6.0 (2026-11-25)

### Planning team — role-based subagents for the planner

- **Role cards and a dispatch contract (#264–#269).** Each planning role is a card in `skills/planning/references/roles/`, dispatched by `dispatch.md` with its own model, tree and guard. `cold-read` now runs a review panel before the reader (Fact-checker, Editor, Test engineer and Trust reviewer), re-checks each fix only with the role it affects, and asks the developer one decision batch. Round 1 runs parallel cold readers over every slice, each miss is traced back to a role, and the Result records an honest `Pass after N rounds`.
- **Role gates in `spec` and `slice` (#275–#280).** A Scout drafts `context.md` and the Fact-checker gates it. The Analyst drafts the PRD behind an acceptance gate and assumption probes, the Architect drafts the design and ADRs, and the Planner drafts `plan.md` behind the slice gate. Gate items wait for the next checkpoint's **Checkpoint batch** in `gates.md`, and a role runs only when its stage writes its file.
- **Discovery research in `brainstorm` (#286–#291).** Before the opening, a research Scout, a Historian (past packs, retros and cold-read records) and a Skeptic read the repository in parallel in a read-only research tree, and the Facilitator brings their findings into the conversation. Phase 4 starts a new research step on ground no earlier step covered. A Skeptic case against building is a challenge the developer decides, never a ruled-out option on its own. With no subagent tool, the Facilitator works through the cards itself and says the research was not independent.
- **XL parent packs can close (#293, #295).** `pack-format.md` adds `routed → done` for an XL parent once every child is `done` or marked `(closed, not planned)`, with its Retro rolled up from the children's. `planning` offers the close when it resumes such a parent.

## v1.5.0 (2026-11-17)

### Planner follow-ups, safer merges and shell-safe bodies

- **`merge-pr` blocks on unplayed manual CI jobs (#243).** Phase 4 now reads job-level state on GitLab and a new `manual` class blocks like failed and unfinished jobs, so an `allow_failure: true` manual job nobody played no longer passes as a green pipeline. `.hivrr.json` `ci.optionalManualJobs` (default `[]`) lists jobs that may stay unplayed; they are still named in the CI line.
- **`merge-pr` keeps Branch Deletion Safety on the already-merged path (#257).** Phase 9 now evaluates the rules itself when Phase 6 was skipped, so re-running `merge-pr`, `ship-pr` or `promote` on an already-merged ladder promotion can no longer delete `dev` or another protected branch.
- **Bodies and commit messages go through a file (#240, #245).** PR, MR, comment and commit commands no longer pass `"{B}"` inline, where the shell ran every backticked span and `$(…)`. `core` defines the **Commit** form (`git commit -F`), and the provider references give a stdin form for read-only callers such as `review-pr`.
- **`ship-issue` pack mode (#242)** ships a slice's existing open PR instead of opening a second one, accepts Linear `Issue: ENG-123` lines, and checks every slice issue's `Plan:` marker against `plan.md` before any slice starts.
- **`planning` gains a Revise spec step, and `brainstorm` a distinct `BRAINSTORM NOT ROUTED` result (#241).**
- **`cold-read` runs its reader in a clean worktree (#238)** of `origin/{integration}`, so a dirty checkout or an unmerged branch cannot leak context the pack does not hold.
- **Pack format (#237, #239).** A pack fence opens with exactly three backticks at any indentation, which check 14 now enforces (`PACK FENCE FORM`). ADRs carry a **Proposed by** line, and an accepted ADR is amended or superseded by a new one rather than edited.
- **`work-issue` worktrees resume remote-only branches (#256).** A new worktree for an `issue/{N}` that exists only on origin is re-pointed to `origin/{branch}` instead of the integration branch; `wave` gets the same fix.
- `init`, `work-issue`, `merge-pr` and `spec` moved detail into `references/` to bring every `SKILL.md` under 400 lines (#250–#253), with no change in behaviour.

## v1.4.0 (2026-11-14)

### Planning redesign — plan packs

- **`planner` now produces a plan pack**: a committed folder under `docs/plans/<slug>/` that any model can execute cold in a fresh session. `planning` is a guided wrapper over four phase skills — `brainstorm`, and the new `spec`, `slice` and `cold-read` — routed by type, size and modifiers, and it resumes from the pack's README Status. It publishes one issue per slice, each carrying a `Plan: docs/plans/<slug> · Slice: N` marker, and a pack PR that lands the pack before any slice starts. The format of record is `skills/planning/references/pack-format.md`, with templates beside it.
- **Files are the only state (ADR-002).** Every session UUID, memory MCP read and write, `.ai/session/` fallback and container-mode question channel is gone from `brainstorm`, `planning` and `work-issue`, and the v1.3.1 `.ai/plans/` location is retired in favour of `docs/plans/<slug>/`. A brainstorm you keep becomes the pack's README, and resume works by reading README Status. A headless run that needs an answer now stops at its checkpoint instead of polling.
- **No code in plans (ADR-003).** The old plans with failing tests and implementations written in are replaced by contracts, acceptance criteria with examples, stop conditions, Verify commands and **Pattern to follow** pointers to real code. Every fence in a pack must be tagged `bash`, `sh`, `mermaid` or `text`; new structural check 14 rejects any other, and `slice` and `cold-read` reject code inside one.
- **One PR per slice (ADR-008).** `slice` sizes each slice for one PR, and each slice leaves its own `progress/slice-NN.md`, so progress files never conflict. Pack slices never run as a `wave`. The last slice writes the pack's Retro and sets its Status `done`.
- **Work without a pack behaves as before (ADR-011).** `work-issue` enters pack mode only for an issue whose body starts a line with `Plan: docs/plans/`, and `ship-issue` only for such an issue or a `docs/plans/<slug>` path, which ships the pack's slices in order and stops on a `BLOCKED` slice. Without a marker every phase runs as in v1.3.2, minus the removed `Session …` lines.
- The `planner` description, the README tables and the `ship-issue` description now describe the new skills. The design template puts a Rewrite's cutover under **Architecture**, matching `spec`, and `config.md` defines `issues.epicThreshold` as a slice count.

## v1.3.2 (2026-09-28)

### Verification fix and a ship-workflow retrospective

- **Check 12 (`review-pr` read-only / `allowed-tools`) now parses the actual YAML value instead of assuming block-sequence line shape.** The old grep patterns only matched one entry per line and missed the equally valid inline flow form (`allowed-tools: Read, Bash`) entirely — an inline declaration granting bare `Bash` or `Bash(git:*)` would have passed verification silently. The fix extracts the value (inline remainder or indented continuation lines, split on commas) so both YAML forms reduce to the same token stream before the existing patterns test it.
- `ship-issue`'s Phase 3 (grouping) and Phase 4 (ordering) now state an explicit single-issue early-out, matching `work-issue`'s Phase 2, instead of silently reducing to a no-op with no line saying so.
- New "Skill Composition" section in `core`: "load the X skill" means invoke it fresh, even when this session already ran X and its contract is fully remembered. This applies with equal force to a skill loaded through composition (`ship-pr` loading `review-pr`/`merge-pr`, `ship-issue` loading `work-issue`/`ship-pr`), not only one loaded directly by the user.
- `docs/verification.md`'s mechanics notes now lead with: test a detection-logic change against synthetic input before editing the real target.

## v1.3.1 (2026-09-28)

### Documentation cleanup and a config-tracking reversal

- The Verification section moved out of `README.md` into a dedicated `docs/verification.md` — `README.md` now carries a two-line pointer instead of the full 13-check fence and its reference material.
- `README.md`'s per-check documentation was condensed from a ~410-line narrative (issue-number history, per-check "how to re-run it" walkthroughs) into a compact 13-row reference table.
- Removed four historical, fully-shipped plan documents from tracked `docs/plans/`; the one still-unimplemented plan was preserved by moving it to the gitignored `.ai/plans/` instead of deleting it. New plans are now written to `.ai/plans/prd-{NNN}.md`, not `docs/plans/`.
- **`.hivrr.json` is now gitignored, not committed.** It was committed by an earlier decision; that's reversed here. `init` Phase 6 now keeps it out of git (adding the `.gitignore` line and untracking it if it was ever committed) instead of staging and committing it. Every teammate, agent, and CI run is expected to derive its own copy by running `init`, the same way each already has its own `~/.claude/settings.json`. This is a behavior change for every repo using this plugin, not just this one.
- Retired the `dispatcher` plugin (`score-issues`, `group-issues`, `diagnose-failure`) — built for another project's work-allocation workflow and no longer needed. `init` and `session` are untouched, since `dev` and `planner` still ship them.

## v1.3.0 (2026-09-27)

### Multi-vendor distribution

- Skills are discoverable and explicitly invocable from Codex CLI and Google Antigravity, alongside the existing Claude Code marketplace. No auto-trigger bootstrapping — skills are invoked by name in every vendor, the same as Claude Code today.
- `skill/` was renamed to `skills/` to match the open Agent Skills standard (https://agentskills.io) that Codex and Antigravity both implement.
- Codex CLI and Antigravity both discover skills through `.agents/skills/<name>`, a symlink tree pointing at the same `skills/<name>` directories Claude Code's marketplace uses — verified against live instances of both. Neither vendor needed a separate plugin manifest.
- No unified version-lockstep mechanism was added: with no per-vendor manifest carrying its own version field, `.claude-plugin/marketplace.json`'s `metadata.version` remains the repo's only version, so there is nothing to keep in sync.

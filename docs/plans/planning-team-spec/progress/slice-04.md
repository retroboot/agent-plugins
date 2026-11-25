# Slice 4 — The Architect

| | |
|---|---|
| **Status** | done |
| **Issue** | #273 |
| **PR** | this PR |
| **Executor model** | Opus 5.5 (`claude-opus-5-5`) |
| **Date** | 2026-11-24 |

## Preflight

Checked on branch `issue/273`, forked from `origin/main` at `8ad80b6` (Slice 3 merged).

| Citation | Holds? |
|---|---|
| `skills/spec/SKILL.md` Phase 7 **design.md**, **Self-check** and Phase 8, 395 lines, 10 `## Phase` headings | holds |
| `skills/spec/references/design.md`, design.md sections and Modifier sections | holds |
| `skills/planning/references/roles/scout.md` and `analyst.md`, the drafting card shape | holds |
| `skills/planning/references/roles/dispatch.md` **Drafting frame**, **Completeness check**, **Drafting line** | holds |
| `skills/planning/references/gates.md` **Held**, **Checkpoint batch**, **Handoff** (Resume: "For `design.md`, which has no gate, it goes straight to the design checkpoint") | holds; S-03.5 needs no `gates.md` text |

## Acceptance

Every dry run followed the checkout's `skills/` text, with `$CLAUDE_SKILL_DIR` resolved to this
checkout (see Deviations). The live dispatch ran in a new tree by
`skills/cold-read/references/tree.md` from `{base}` `origin/main` (`8ad80b6`), with the guard before
and after; the guard was identical. The card was pasted from the checkout. Fixtures were under
`docs/plans/zz-dryrun-*`, and all were removed before commit. The executor played the developer at
each fixture checkpoint.

**fresh** (`zz-dryrun-arch`) is a Feature at size M with no modifiers, at `routed` past the
acceptance checkpoint: Slice 3's seeded-prd fixture after its gate, its open points answered in
place, an accepted ADR-001, and Read order through `decisions/`.

| Id | Result |
|---|---|
| S-05.1 | pass — shown by S-05.1.e1 and S-05.1.e2 |
| S-05.1.e1 | pass — **fresh**: Drafted by the Architect, Opus (Agent tool, model: opus, Explore); the transcript names `claude-opus-5-5`. Both `design.md` markers and `## Open points` present: accepted and written. Sections: Architecture, Contracts, Flows, Test strategy, Risks, Pre-mortem, each its Feature trigger requires; no Domain model or State machines, whose triggers do not apply; no `## Modifier:` section on a route with none. README Read order gained `design.md` |
| S-05.1.e2 | pass — **bugs** (`zz-dryrun-bugs`), Bug at size S with no modifiers, desk walk of Phase 7: the required rule does not apply, the optional design is proposed and declined, no `design.md` is written, so no Architect is dispatched and no Gate pending entry is made |
| S-05.2 | pass — shown by S-05.2.e1 to S-05.2.e3 |
| S-05.2.e1 | pass — **fresh**, the written draft replaced with a copy whose first `mermaid` fence opened untagged: the Phase 7 Self-check found an untagged opening fence; the Facilitator put the tagged draft back, and the Self-check passed before the checkpoint |
| S-05.2.e2 | pass — **fresh**: the design checkpoint showed `Drafted by the Architect, Opus (Agent tool, model: opus, Explore).` above `design.md` |
| S-05.2.e3 | pass — **fresh**, one developer-only open point (DR6, whether `work-issue` also prints the line) added to the Architect's live report (Agent tool, model: opus, Explore) before it was accepted: held in the Gate pending entry and asked in the checkpoint's one batch with DR1; deferred, it became `Deferred at the design checkpoint on 2026-11-24: DR6 — …` under Open questions |
| S-03.5 | pass — **fresh** (`design.md` stage), the session ended after the draft and its `## Gate pending: design.md` entry were written; `spec` run again found the entry, dispatched no Architect and ran no gate, and showed the design checkpoint from the entry's drafting line and held points. On approve the entry was removed and `handoff.md` deleted |
| 4.1 | pass — `architect.md` headings `Letter|Model|Kind|Job|Inputs|Checklist|Output|`, `Letter=R Model=opus Kind=draft`; no letter shared with another card |
| 4.2 | pass — **fresh**: DR1 (blocking) and DR6 (developer-only) were asked with the design checkpoint in one message; DR2 to DR5, non-blocking with a stated default, were settled by it |

Skill dir, per dry run:

- **fresh:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec
- **bugs:** Skill dir: /home/retroboot/projects/agent-plugins/skills/spec

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Live runs: "the session with the planner plugin loaded from this checkout" (`design.md` §6) | As in Slices 1 to 3: each dry run followed the checkout's skill text, with `$CLAUDE_SKILL_DIR` resolved to the checkout | The session's `Skill` tool loads the cached plugin | n |
| Four separate **fresh** runs | One live Architect dispatch served all four: the untagged-fence copy, the resume and the seeded open point were each applied to that dispatch's written draft or report, in the order the plan lists | Each seed acts after the draft is written, so a second dispatch would add nothing the first did not prove | n |
| Files: `architect.md` and `spec` | `gates.md` also changed: one line Slice 3's review fix left over 100 characters was rewrapped. `dispatch.md` gained the review's new-file rule | Wording unchanged in `gates.md`; the rule belongs to every drafter | n |

## Decisions

- **The Architect's pointer sits in Phase 7, the batch in Phase 8.** Phase 7 says the Architect
  drafts `design.md` "as Phase 3 says for the Analyst", with a Gate pending entry and no gate, and
  that the Facilitator then adds the modifier sections and any `ux.md`. ADRs and `inventory.md` come
  from Phases 5 and 6, before the Architect runs. Phase 8 shows the drafting line, asks the held
  points as one batch, and removes the entry on approve. `spec` is 398 lines.
- **Drafters draft only new files (PR #279 review).** `dispatch.md` **Drafting frame** now says a
  drafter is dispatched only for a file the run writes new; in a Re-route or Revise spec, an
  existing file is revised in place by the Facilitator, per `spec/references/reroute.md`. One rule
  covers the Scout, the Analyst and the Architect, and costs `spec` no lines. No dry run covers a
  re-route.
- **The Checklist holds only R1 to R4**: criterion trace-back, citing `context.md`, following
  accepted ADRs, and developer-only choices as open points. Phase 7 and the design reference already
  hold every section rule.

## Discoveries

- **For the retro: the Architect caught a fixture defect.** DR1 named a `context.md` bullet still
  giving the old wording, which the fixture rebuild missed; it was not a seed.
- **For Slice 5: `spec` has 1 line left** under 400 (398 lines). `planning` is 386.

---
name: planning
description: Triage a feature or problem into sized, actionable GitHub and Linear issues — then write a comprehensive implementation plan with TDD tasks, complexity-aware blueprints, UI/UX coverage, and an automated plan review.
license: MIT
compatibility: opencode
---

# Planning

Transform a feature request, problem description, or rough idea into a concrete set of sized, actionable issues and a comprehensive implementation plan ready for execution. Creates issues in GitHub and Linear (if configured), informed by the project's existing memory and architecture.

Keep moving through phases. Only stop at the marked checkpoint.

---

## Phase 1 — Initialize Session

### Accept or Generate Session UUID

If a `SESSION_UUID` is provided (via environment variable, task spec, or inline argument from brainstorm output), use it. Otherwise generate one:

```bash
SESSION_UUID="${SESSION_UUID:-$(uuidgen 2>/dev/null | tr '[:upper:]' '[:lower:]' || python3 -c 'import uuid; print(uuid.uuid4())')}"
```

Store: `session_uuid`

Display: `Session: {session_uuid}`

### Read Brainstorm Context from Memory

If a session UUID was provided, attempt to read the brainstorm intent from memory:

**Memory read (primary):**
```
session/{session_uuid}/intent
```

**Local file fallback:**
```
.ai/session/{session_uuid}/intent.md
```

If intent is found, use it as starting context — the topic, framing, constraints, non-goals, and open questions from the brainstorm session inform the planning process. Skip or shorten Phase 5 (Clarify) if the intent already resolves ambiguity.

If no intent is found, continue normally — the planning skill works standalone.

### Write Initial Phase

**Memory write:**
```
session/{session_uuid}/phase = "planning"
```

**Local file fallback:**
```
.ai/session/{session_uuid}/phase.md → "planning"
```

Log a warning if falling back: `WARNING: Memory unavailable, using local file fallback at .ai/session/{session_uuid}/`

---

## Phase 2 — Parse the Input

The input can be:
- A freeform description: "add email verification to signup"
- A problem statement: "users keep losing their session after 5 minutes"
- A reference to an existing GitHub issue: `#123` or multiple: `#123 #124`
- A vague concept: "improve the onboarding flow"
- No input — open triage session

Extract:
- `topic` — what this is about in plain terms
- `source` — freeform, issue ref, or empty
- `scope_hint` — any explicit size or priority signal in the input
- `plan_only` — true if `--plan-only` flag is present (skip issue triage and creation; only write the plan doc)

If the input contains one or more issue references, fetch each one using the **Get issue** command from the loaded reference. Aggregate the results — all fetched issues inform the topic, scope, and acceptance criteria.

If `--plan-only` is set, display: `Mode: plan-only — will write plan doc without creating issues`

---

## Phase 3 — Research the Codebase

Before proposing anything, understand what already exists.

- Read the relevant areas of the codebase related to the topic
- Check for existing open issues that overlap using the **List issues** command from the loaded reference
- Look for existing patterns, conventions, APIs, and test structures in the codebase

Build an **Allowed APIs list**: note the actual functions, types, test helpers, and conventions found, citing exact file paths. This prevents inventing APIs that don't exist when writing the plan later.

Example format:
```
Allowed APIs:
- auth.createSession(userId, ttl) — src/auth/session.ts:42
- db.users.findById(id) — src/db/users.ts:18
- Test helper: createTestUser(overrides) — tests/helpers.ts:5
- Convention: all handlers return Result<T, AppError> — src/types.ts:12
```

You are not planning yet — you are building enough understanding to plan well.

---

## Phase 4 — Clarify

Skip this phase if `--plan-only` is set (the work is already scoped).

### Interactivity Model

**Live terminal mode (default when running in Claude Code):**
Ask the user directly and wait for their response in the conversation.

**Container mode (when running headlessly or in a container):**
Write each question to the question channel and wait for an answer to be injected:

1. Write the question:
```json
// .ai/session/{session_uuid}/question.json
{
  "session_uuid": "{session_uuid}",
  "phase": "clarify",
  "question": "concise question text",
  "context": "what you understand so far",
  "options": ["A: description", "B: description"],
  "posted_at": "{ISO 8601 timestamp}"
}
```

2. Poll for the answer at `.ai/session/{session_uuid}/answer.json`. Check every 2 seconds. If no answer arrives within 5 minutes, write an error and exit gracefully.

3. When the answer arrives:
   - Read the answer
   - Delete both question and answer files
   - Continue with the answer as context

Detect container mode by checking: no TTY attached, or `PLANNING_CONTAINER_MODE=true` environment variable is set.

### Questions

Ask the user 2-3 focused questions to resolve genuine ambiguity before proposing a breakdown. Do not ask for information you can infer from the codebase or memory. Do not ask more than 3 questions.

Good questions resolve: scope boundaries, priority ordering, acceptance criteria that aren't obvious, constraints you can't see in the code.

If brainstorm intent was loaded in Phase 2 and already resolves these questions, skip this phase.

Wait for answers before continuing.

---

## Phase 5 — Complexity Assessment

Classify the work as one of three tiers. This controls the depth of the plan document.

| Tier | Criteria | Plan depth |
|------|----------|------------|
| **Simple** | Single file/component, <1 day, no cross-cutting concerns | Brief plan: goal + key files + issue links |
| **Medium** | Multiple files, 1-3 days, single PR | Full plan: TDD task breakdown with actual code and commands |
| **Complex** | Multiple subsystems, multiple PRs, >3 days, or cross-team dependencies | Blueprint: multi-PR dependency graph + per-PR plan summaries |

See [references/blueprint.md](references/blueprint.md) for detailed Complex classification criteria.

Display: `Complexity: {tier} — {one-line rationale}`

---

## Phase 6 — Draft the Breakdown

**If `--plan-only` mode:** Skip the issue proposal. What remains depends on the tier resolved in Phase 5:

- **Medium and Complex** — jump directly to the file structure map section below and produce it. Phase 7 consumes it.
- **Simple** — skip this phase entirely. The file structure map is gated to Medium and Complex, and a Simple plan doc lists key files instead, so this phase has nothing to produce. Go straight to Phase 7.

Propose a set of issues. For each issue:
- **Title**: concise, action-oriented ("Add email verification token generation")
- **Body**: why this is needed, what done looks like, acceptance criteria
- **Size**: XS (< 1 hour) / S (half day) / M (1 day) / L (2-3 days) / XL (needs splitting)
- **Labels**: choose from the label reference loaded by init (`$CLAUDE_SKILL_DIR/../init/references/labels.md`). Common picks: `bug`, `feature`, `enhancement`, `refactor`, `documentation`, `chore`, `security`. Add a priority label (`P0`–`P3`) and a size label (`size:xs`–`size:xl`) to each issue.
- **Dependencies**: which issues must be completed first

**Propose a parent epic** when `issues.hierarchy` is enabled **and** either the complexity tier is
Complex or the breakdown contains at least `issues.epicThreshold` issues (default `4`). Below that
bar, emit a flat set — a parent wrapping two issues is bookkeeping with no board benefit.

The epic is an issue like any other, with:
- **Title**: the feature name, not an action ("Email verification", not "Add email verification")
- **Body**: the goal, the architecture summary, and a link to the plan doc — no acceptance criteria
  of its own, because its children carry those
- **Labels**: the feature/priority labels, **no size label** — an epic has no size
- **Size**: none

At Complex tier the epic corresponds to the Blueprint as a whole, and each Blueprint step maps to
one child.

Skip this entirely when `issues.hierarchy` is disabled or absent, or when the resolved tracker is
not `github`.

Rules:
- No issue larger than L — split XL issues
- Prefer fewer, clearer issues over many small ones
- Each issue should be implementable independently where possible

**For Medium and Complex:** also produce a **file structure map** before writing any tasks:

```
FILE STRUCTURE
──────────────
Create:  src/auth/token.ts         — email verification token generation and validation
Modify:  src/auth/signup.ts:45-80  — add verification step to signup handler
Modify:  src/db/schema.ts          — add email_tokens table migration
Create:  tests/auth/token.test.ts  — token generation and validation tests
```

Each file has one clear responsibility. Lock in decomposition decisions here — they govern all tasks that follow.

---

## Phase 7 — Write the Plan Document

Save to: `docs/plans/YYYY-MM-DD-<feature-name>.md`
(If `docs/plans/` does not exist, create it.)

See [references/plan-writing.md](references/plan-writing.md) for the full task structure and no-placeholders rules.

### Plan Document Header (all tiers)

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** Use the `work-issue` skill to implement this plan task-by-task.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries used]

---
```

### Simple tier
Brief plan doc: goal, architecture, key files, linked issues. No TDD task breakdown. 1-2 pages.
In `--plan-only` mode there are no issues to link — omit that section rather than leaving it empty.

### Medium tier
Full implementation plan with TDD task breakdown. For each task:

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.ts`
- Modify: `exact/path/to/existing.ts:45-80`
- Test: `tests/exact/path/to/test.ts`

- [ ] **Step 1: Write the failing test**

  ```typescript
  // tests/auth/token.test.ts
  describe('generateVerificationToken', () => {
    it('returns a 32-byte hex string', () => {
      const token = generateVerificationToken()
      expect(token).toMatch(/^[a-f0-9]{64}$/)
    })
  })
  ```

- [ ] **Step 2: Run test to verify it fails**

  Run: `npm test tests/auth/token.test.ts`
  Expected: FAIL — "generateVerificationToken is not defined"

- [ ] **Step 3: Write minimal implementation**

  ```typescript
  // src/auth/token.ts
  import { randomBytes } from 'crypto'

  export function generateVerificationToken(): string {
    return randomBytes(32).toString('hex')
  }
  ```

- [ ] **Step 4: Run test to verify it passes**

  Run: `npm test tests/auth/token.test.ts`
  Expected: PASS

- [ ] **Step 5: Commit**

  ```bash
  git add tests/auth/token.test.ts src/auth/token.ts
  git commit -m "feat: add email verification token generation"
  ```
```

Apply the Allowed APIs list from Phase 4 — every type, function, and import used in code blocks must cite a source from the codebase or be defined in this plan.

**No-placeholders pass:** Before moving on, scan the draft for these red flags and fix every one:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" without actual test code
- "Similar to Task N" without repeating the actual code
- References to types or functions not defined in any task

### Complex tier

Lead with a **Blueprint section** (see [references/blueprint.md](references/blueprint.md)):

```markdown
## Blueprint

**Steps:** 4 | **Parallel:** Steps 2 and 3

Step 1 ──> Step 2 ──> Step 4
            └──> Step 3 (PARALLEL) ──┘

### Step 1: [Name] — [branch: feat/step-1]

**Context brief:** [Everything a fresh agent needs to execute this step cold. Include relevant architecture decisions, file locations, and constraints — no prior context assumed.]

**Exit criteria:** [How you know this step is done]

**Tasks:**
- [ ] ...

**Verification:**
Run: `{exact command}`
Expected: `{expected output}`
```

Then include a per-step plan summary (Medium-depth TDD tasks for each step).

**Sprint capacity (optional):** If the user provided team size and sprint length, include:

```
Capacity estimate: {team_size} engineers × {days} days × 6h/day × 0.7 focus = {points} available
Estimated: {n} story points ({XS=1, S=2, M=3, L=5})
```

### UI/UX section (conditional)

Trigger: any issue body or user description contains keywords like: UI, UX, frontend, page, screen, component, dashboard, form, modal, button, design, layout, responsive, user interface.

Append a **UX section** to the plan document (see [references/ux-checklist.md](references/ux-checklist.md)):

```markdown
## UI/UX Plan

### Information Hierarchy
[What the user sees first, second, third on each affected screen]

### Interaction States
| Feature | Loading | Empty | Error | Success | Partial |
|---------|---------|-------|-------|---------|---------|
| [feature] | [spec] | [spec] | [spec] | [spec] | [spec] |

### Responsive Behavior
[Intentional layout decisions per viewport — not "stacks on mobile"]

### Accessibility
[Keyboard nav, ARIA landmarks, touch targets, contrast requirements]
```

---

## Phase 8 — Plan Review

Dispatch a subagent using the reviewer template from [references/plan-review.md](references/plan-review.md).

The subagent receives the plan file path and the original spec/issues as context. It checks:
- **Completeness**: every requirement/issue has a task
- **Spec alignment**: no scope creep, no missing requirements
- **Task decomposition**: steps are actionable, have clear done criteria
- **Buildability**: an engineer could follow this without getting stuck
- **No-placeholders**: TBD/TODO/vague steps flagged
- **Type consistency**: function names and signatures match across all tasks

The reviewer outputs: `Status: Approved | Issues Found` with a list of specific issues (task ref + why it matters) and advisory recommendations.

**If Issues Found:** fix them in the plan doc and re-save before continuing.

**If the subagent fails or returns no output:** log a warning and continue — `Plan Review: skipped — subagent error`.

Display: `Plan Review: {status} | {n} issues found and fixed`

---

## Phase 9 — Checkpoint: User Approval

**Stop here.** Present the proposed breakdown to the user:

```
PLANNING DRAFT
──────────────
Complexity: {tier}
Topic: {topic}
Plan doc: docs/plans/{filename}.md

Issues:
  1. [{size}] {title}
     {one-line summary}
     depends on: none

  2. [{size}] {title}
     {one-line summary}
     depends on: #1
  ...

Ready to create {n} issues in GitHub{linear_note}.
Approve, adjust, or cancel?
```

**When an epic was proposed in Phase 6**, show the hierarchy here so the user approves it rather
than discovering it after creation:

```
Issues:
  EPIC {epic_title}
    1. [{size}] {title}
       {one-line summary}
       depends on: none

    2. [{size}] {title}
       {one-line summary}
       depends on: #1
  ...

Ready to create 1 epic + {n} issues in GitHub{linear_note}.
Approve, adjust, or cancel?
```

When no epic was proposed, the display is unchanged.

Do not proceed until the user explicitly approves or provides changes. If they provide changes, revise the draft and show it again. Do not create any issues until approved.

**If `--plan-only` mode:** Skip this checkpoint after plan review — the plan doc is already saved. Display: `Plan saved to {path}. Review it and run /work-issue when ready.`

### Container mode

Write the plan draft to the question channel for approval:

```json
// .ai/session/{session_uuid}/question.json
{
  "session_uuid": "{session_uuid}",
  "phase": "approval",
  "question": "Approve this plan?",
  "context": "{ full plan draft }",
  "options": ["approve", "adjust", "cancel"],
  "posted_at": "{ISO 8601 timestamp}"
}
```

Wait for the answer before proceeding. If "adjust", revise and re-post. If "cancel", exit gracefully.

---

## Phase 10 — Create Issues in Tracker

Skip if `--plan-only` mode.

Create every approved issue in this order. **There is exactly one creation path here** whether or
not hierarchy is enabled — the epic steps wrap the loop rather than preceding a second copy of it.

1. **When an epic was approved, create it first**, using the **Create issue** command from the
   loaded reference. Its number is needed to attach the children, and a child created before its
   parent cannot be linked without a second pass. The epic is **not** part of the loop in step 2.

2. **Create each remaining approved issue** with the **Create issue** command. Collect the created
   issue numbers/identifiers and URLs, and display each as it is created:
   `Created: #{number} — {title}`

3. **Resolve node IDs** for the epic and every child in **one** aliased query, using the
   **Resolve node IDs** command from the loaded reference.

4. **Attach each child** using the **Link a child to a parent** command — check-then-add, not
   blind-add. A child that already reports the intended parent is already linked; skip it silently.

**When no epic was approved, run step 2 only.** Steps 1, 3, and 4 are skipped, and step 2 alone is
this phase's behavior before hierarchy existed — unchanged.

**Each attach warns and continues on failure.** The issues are the deliverable and they already
exist by step 4; a hierarchy outage must not lose a planning session's output. This is the same
rule the board operations follow.

Track how many children attached for the Phase 13 summary.

Display: `Hierarchy: {n}/{total} children attached to #{epic}` or nothing when disabled.

**Then add it to the project board.** Issues that never reach the board are invisible to anyone working from the project view, which defeats the point of planning them.

Read `project` from `.hivrr.json`. **When `project` is absent, skip this silently** — most repos have no board, and saying so for every issue is noise. See **Board operations** in [`config.md`](../init/references/config.md) for the commands and the shared rules.

For each created issue — **including the epic**, which must reach the board alongside its children
or the rollup that motivates creating it has nothing to display on:

1. Add it: `gh project item-add {project.number} --owner {project.owner} --url {issue_url}`
2. Resolve its item ID
3. Set Status to Todo using `project.statusFieldId` and `project.status.todo`

**Every one of these warns and continues on failure.** Never abort issue creation because a board update failed — the issues are the deliverable and they already exist by this point. A board outage must not lose a planning session's output.

Track how many landed on the board for the Phase 13 summary.

Display: `Board: {n}/{total} issues added as Todo` or `Board: not configured — skipped`

---

## Phase 11 — Create Linear Issues (if ISSUE_TRACKER=linear)

Skip if `--plan-only` mode or `ISSUE_TRACKER != linear`.

If `ISSUE_TRACKER=linear` and issues were created in a separate repo provider in Phase 10, also create matching Linear issues using the **Create issue** command from the linear reference. Otherwise, if Linear was the primary tracker in Phase 10, skip this phase.

**Legacy fallback:** If `ISSUE_TRACKER` is not set but `LINEAR_API_KEY` is in the environment or a `.linear.yaml` file exists in the project root, treat as `ISSUE_TRACKER=linear` and create issues here.

If configured via `.linear.yaml`, read team ID and project defaults:

```yaml
teamId: ENG
projectId: proj_abc123
defaultLabels: [feature]
```

Size → story points: XS=1, S=2, M=3, L=5

Link the repo issue number/identifier in the Linear issue description.

Display each: `Linear: {identifier} — {title}`

---

## Phase 12 — Write to Memory

After issue creation — or, in `--plan-only` mode, after the plan document is written — persist the planning output to memory before exiting.

**Memory write:**
```
session/{session_uuid}/prd         = full PRD text
session/{session_uuid}/plan_only   = true when --plan-only was set, false otherwise
session/{session_uuid}/plan        = [{ task_id, title, repo,
                                        dependencies, acceptance_criteria,
                                        github_issue_url }]
session/{session_uuid}/plan_doc    = path to plan document file
session/{session_uuid}/decisions   = architectural choices made during decomposition
session/{session_uuid}/constraints = discovered constraints and non-goals
session/{session_uuid}/phase       = "executing"
```

### `plan_only` in plan-only mode

`--plan-only` creates no issues, so `plan` has nothing to hold. Write it as an **empty array** and
write `plan_only = true` alongside it. Write both keys in both modes.

The discriminator is the point. Without it a consumer reading `plan` alone cannot tell "this session
deliberately created no issues" from "the plan write failed" or "this key was never written" — all
three look like an empty array. `plan_only = true` says which, and tells the consumer to read
`plan_doc` instead.

**Local file fallback:**
If memory is unavailable, write to `.ai/session/{session_uuid}/plan.md` containing the full plan and PRD content. Log a warning: `WARNING: Memory unavailable, plan written to .ai/session/{session_uuid}/plan.md`

Open that file with a mode line, so the discriminator survives the fallback path too:

```markdown
Mode: plan-only     ← or: Mode: standard
```

Without it a plan-only session leaves a `plan.md` holding no issues and nothing saying that was
deliberate — the same ambiguity `plan_only` exists to remove, one layer down. A reader that finds no
`Mode:` line at all should assume standard mode; that is what every `plan.md` written before this
line existed means.

Do not fail if memory write fails — log the warning and continue.

---

## Phase 13 — Done

Display:

```
WORKFLOW COMPLETE
─────────────────
Session:   {session_uuid}
Plan doc:  docs/plans/{filename}.md
GitHub:    {issue_numbers or 'plan-only mode — no issues created'}
Epic:      #{epic_number} — {n}/{total} children attached | not applicable
Linear:    {linear_ids or 'not configured'}
Board:     {n}/{total} added as Todo | not configured | {n} failed — see warnings above

Next: /work-issue {first_issue_number}    ← standard mode
Next: review docs/plans/{filename}.md     ← plan-only mode (no issues created)
```

Return control to the user.

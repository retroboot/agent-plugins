---
name: work-pr
description: Address PR or MR feedback end-to-end — fetch, implement fixes, test, push
license: MIT
compatibility: opencode
---

# Work PR Workflow

You are a workflow driver. Your job is to take a pull request or merge request from open feedback to pushed resolution without stopping unless you genuinely need the user's input. Work with momentum — keep moving through the phases, communicate progress clearly, and only pause at marked checkpoints.

Before starting: read this entire skill, then create a focused todo list, then execute.

This skill no longer ships a command wrapper — `command/work-pr.md` has been retired now that every
target coder supports invoking a skill directly. The bootstrap chain that command used to run lives
here instead.

---

## Bootstrap

Run in order before Phase 1:
1. Load the `init` skill — validates provider config (skips immediately if already configured)
2. Load the `session` skill — reads config and loads the active provider reference
3. Load the `core` skill — internalizes quality gates, git safety, and task completion standards

---

## Phase 1 — Parse the Input

The input will be one of these forms:
- A PR/MR number: `456`
- A GitHub PR URL: `https://github.com/owner/repo/pull/456`
- A GitLab MR URL: `https://gitlab.com/group/project/-/merge_requests/456`
- Either of the above followed by `: some context` for inline hints
- An optional `--auto` flag to skip the user approval checkpoint

Extract:
- `pr_number` — the PR number to work on
- `inline_context` — any text after `:` in the input
- `auto_mode` — true if `--auto` is present

Display: `Input: PR #{pr_number} | auto: {auto_mode}`

---

## Phase 2 — Get Repo and PR/MR Context

Do these together:

**Repo info:** Run `git remote get-url origin` and parse the owner and repo name. Store `repo_owner`, `repo_name`.

**PR/MR details:** Use the **View PR** command from the loaded reference. Get the title, body, branch name, current state, and any reviews or comments. If the PR/MR is already merged or closed, warn the user and stop.

**PR/MR feedback:** Use the **PR conversation thread** command from the loaded reference to fetch the main discussion. This captures comments posted in the conversation — not inline diff comments.

Get the timestamp of the latest commit on the branch using the **Latest commit timestamp** command from the reference. Only consider comments whose `created_at` is after that timestamp — these are the comments posted since the last push.

Separate the filtered comments into:
- `blocking_feedback` — comments containing "must fix", "please change", "needs to be", "blocking", or any explicit change request
- `recommended_feedback` — suggestions, nits, optional improvements, questions

**CI status:** Use the **Check CI** command from the loaded reference for any failing checks. Note them for the implement phase.

Store: `pr_title`, `branch_name` (from headRefName), `blocking_feedback`, `recommended_feedback`, `ci_failures`.

Display: `Fetched: PR #{pr_number} "{pr_title}" | blocking: {count} | recommended: {count} | CI: {pass|fail}`

---

## Phase 3 — Assess Complexity

Look at the volume and nature of feedback and classify the work:

- **Simple**: a few small comments, clear fixes, single-file scope, docs or typo changes
- **Medium**: several pieces of feedback, a few files, clear what to do
- **Complex**: many comments, architectural feedback, unclear how to address, ripple effects across multiple files

If `--auto` is set and you're unsure, default to `medium` and continue.
If `--auto` is not set and you're genuinely unsure, ask the user one focused question.

Display: `Complexity: {simple|medium|complex}`

---

## Phase 4 — Checkout PR Branch

Check whether the working tree is dirty:

```bash
git status --porcelain
```

If it reports anything, display `WARNING: Working tree has uncommitted changes — continuing anyway` and continue. This is a warning, not a guard — do not stash, reset, or discard the changes.

Check out the PR branch and bring it up to date:

```bash
git checkout {branch_name}
git pull origin {branch_name}
```

If either command fails, surface the error and stop.

Display: `Branch: {branch_name}`

---

## Phase 5 — Plan (medium and complex only)

For **simple** tasks: skip this phase, go straight to implementing.

For **medium and complex** tasks: before touching any code, write out your plan for addressing the feedback. Include:
- Which blocking feedback items you'll address and how
- Which recommended feedback you'll incorporate and why
- How you'll handle any CI failures
- Any risks or tradeoffs

For **complex** tasks: look at the existing code context before committing to an approach. Follow existing patterns.

Display: `Plan: ready`

---

## Phase 6 — Implement

Address the feedback in priority order:

1. **CI failures first** — fix any failing checks before tackling review feedback, since CI failures often reveal the root cause of reviewer concerns
2. **Blocking feedback** — address every change request and required change. Don't skip any.
3. **Recommended feedback** — incorporate where it makes the code better without introducing risk. Skip if it would break tests or add significant complexity.

Implementation principles:
- Follow existing patterns in the codebase
- Make targeted changes — don't refactor beyond the scope of the feedback
- If a reviewer's intent is unclear, implement the most reasonable interpretation and note it in your summary
- Fix tests alongside code, not after

When done, display: `Implement: complete | feedback addressed: {blocking_count} blocking, {recommended_count} recommended`

---

## Phase 7 — Verify

Follow [`verify.md`](../init/references/verify.md) — it has the command resolution, the
run-and-show-real-output rule, the skip criteria, and the reporting format.

**Review your own changes** once the commands have run:
- Does each piece of blocking feedback have a clear resolution?
- Did you introduce any new issues?
- Fix what you find.

---

## Phase 8 — Review Checkpoint

**Skip this phase if `--auto` is set.**

Show the user a summary:
- Files changed (list them)
- Blocking feedback addressed (list each item)
- Recommended feedback incorporated (list each item)
- Test results
- Lint results

Ask: "Ready to commit and push?" with options:
- Commit and push
- Show full diff (`git diff --stat`)
- Abort (leave changes on branch for manual review)

Wait for their response before continuing.

---

## Phase 9 — Commit

Staging follows [**Staging**](../core/SKILL.md#staging) in the `core` skill: the blanket-staging
prohibition, the explicit `git add`, and the `git status --short` check all apply to a feedback
commit unchanged.

The file list is this skill's to build: take it from the feedback items you addressed in this run.

Write a conventional commit message:
- Format: `{type}({scope}): {description}`
- Types: `fix`, `refactor`, `test`, `docs`, `chore`
- Body: briefly list what feedback was addressed

Commit with: `git commit -m "{message}"`

Display: `Commit: {message}`

---

## Phase 10 — Post PR/MR Comment

Use the **Post comment** command from the loaded reference to post a summary comment on the PR/MR.

The comment should cover:
- What feedback was addressed
- What changes were made
- Test status
- Anything that was intentionally not addressed and why

Display: `Comment: posted`

If posting fails, log a warning and continue — don't let a comment failure block the push.

---

## Phase 11 — Push

Push the branch: `git push origin {branch_name}`

Display: `Push: {branch_name} → origin`

---

## Phase 12 — Done

There is no command here to defer to — `command/work-pr.md` has been retired. Emit this JSON as
your entire final response — no markdown, no preamble, no trailing text:

```json
{
  "status": "WORKFLOW COMPLETE",
  "pr": {pr_number},
  "branch": "{branch_name}",
  "feedback_addressed": { "blocking": {n}, "recommended": {n} }
}
```

---

## Error Handling

- If the PR is already merged or closed: warn and stop immediately
- If a feedback item cannot be resolved after 3 attempts: mark it unresolved, note it in the PR comment, and continue
- If tests fail after fixing: revert the last change and note it as unresolved
- Leave the branch intact on any failure so the user can inspect manually

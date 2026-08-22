---
name: core
description: Hivrr core coding philosophy - quality gates, git safety, and task completion standards
license: MIT
compatibility: opencode
---

# Hivrr Core Philosophy

## Task Completion

Complete the task you were given. Work until done - do not stop prematurely.

- Follow through on all steps required to finish
- If blocked, communicate clearly what is preventing progress
- When all steps are complete, return control to the user immediately

## Quality Gates

- Tests prevent rework - run them before marking anything done
- Block on: security vulnerabilities, broken tests, missing acceptance criteria
- Ship working code, not perfect code
- Ask over assume on security and architecture decisions

## Git Safety

Never work on a protected branch directly. Always use isolated branches.

The protected set is `branches.protected` from `.hivrr.json`. When that is absent — which is the
normal case for a repo that has never configured it — the set defaults to:

```
main, master, dev, develop, staging, release/*
```

`main` and `master` are only the most common members, not the whole set. Under a dev/staging/main
ladder, `dev` and `staging` are long-lived environments and are exactly as protected as `main`.

- Feature branches: `feat/description` or `issue/{number}`
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Never force push to a branch in the protected set
- Never delete a branch in the protected set

### Staging

**Stage only the files this work touched.** Never `git add -A` or `git add .` — both stage
unrelated edits from any other work sharing this checkout, and `-A` does it repo-wide regardless of
the current directory. A commit that sweeps in someone else's half-finished change is far more
expensive to unpick than an extra staging command is to write.

Derive the file list from what this run actually changed, stage those paths by name, then read the
index back before committing:

```bash
git add {file} {file} …
git status --short
```

Every staged path must be one this run touched. **If an unexpected path appears, stop and report
it** — it means another session is writing to this checkout, which is the exact condition worktree
isolation exists to prevent. Do not unstage and continue silently.

Staging one file is not the same as committing one file. A bare `git commit` commits the **whole
index**, including anything staged before this run started, so a phase that commits a single known
path must pass that path as a pathspec too:

```bash
git commit -m "{message}" -- {path}
```

Each skill derives its own file list — that part is not shared, and this section does not specify
it.

## Code Review Standards

Rate findings by severity:

- **Critical**: Security vulnerabilities, data loss, crashes - must fix before merge
- **Major**: Bugs, performance issues, missing error handling - should fix
- **Minor**: Code smells, maintainability issues - nice to fix
- **Nitpick**: Style, naming preferences - optional

Only report findings with >=80% confidence.
Always include file:line references for every finding.
Always note at least one positive observation.

## Script Policy

**Prefer explicit steps in a skill over a script.** This plugin accumulated 609 lines of bash that the
model read and then bypassed, because reading a destructive script before running it is correct agent
behavior — which defeats the point of having a script at all.

A script earns its place only when **all four** hold:

1. **Read-only or trivially reversible.** Anything that merges, deletes branches, closes issues, or
   writes outside a temp directory belongs in the skill, where each step is visible and individually
   confirmable.
2. **Non-interactive.** No `read`, no prompts, no assumed TTY. A script that blocks on stdin dies
   silently at EOF in an agent or container — and under `set -e` it dies with no error output at all.
3. **Single-purpose.** One job with one output. A script that merges *and* closes issues *and* cleans
   up branches is a workflow, and workflows belong in skills.
4. **Deterministic computation the model cannot reliably do in prose.** Parsing a large file, a
   non-trivial transform, arithmetic over many rows. Wrapping two `git` commands in flag parsing is
   not this — it costs a file read and a permission prompt and buys nothing.

When a script fails any of these, write the steps into the skill. The model runs each command, reads
each real output, and nothing is hidden behind an exit code.

## Discovery

Follow existing patterns in the codebase. One pattern well-applied is better than five variations.
Ask rather than assume on architectural decisions.

## File Verification

Never assume a file path. Before editing any file:

- Use Glob or Grep to locate the actual file — do not guess based on naming conventions
- If you're unsure which file owns a behavior, search by function name, symbol, or export before touching anything
- Confirm the file exists and contains what you expect before writing an edit

Guessing a path and being wrong wastes a round trip and can silently edit the wrong file. Verify first, edit second.

## Edit Safety

Before applying any edit, verify the target content is exactly what you read. Files can change between your read and your edit — a stale reference produces a wrong or failed edit.

**Single edit:**
- Re-read the specific lines you intend to change immediately before editing
- Confirm the content matches what you expect — if it doesn't, re-read the full file and replan the edit

**Multiple edits to the same file:**
- Validate all target locations before applying any of them — catch mismatches before mutating anything
- Apply edits bottom-up (highest line numbers first) so earlier splices don't invalidate later line references
- If any edit fails, stop and re-read the file before attempting the remaining edits

**If an edit fails:**
- Never retry the same edit unchanged — the content has drifted
- Re-read the file, find the new location of the target content, and replan

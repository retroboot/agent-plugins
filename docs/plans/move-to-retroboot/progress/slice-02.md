# Slice 2 — Config file renamed, with the init migration

| | |
|---|---|
| **Status** | done |
| **Issue** | #298 |
| **PR** | this PR |
| **Executor model** | claude-opus-5-5 |
| **Date** | 2026-11-25 |

## Preflight

Checked on `issue/298`, forked from `origin/main` at `44e9153` (Slice 1 merged).

| Citation | Holds? |
|---|---|
| `context.md` §2.2, `skills/init/SKILL.md` lines 3, 14, 113-172, 184, 228, 230, 241, 261-354, 360 | holds: `git grep -n .hivrr.json` gave exactly the lines `inventory.md` lists |
| `context.md` §2.2, `skills/init/references/config.md` 1, 3, 7, 18, 42, 108, 191, 205, 273-340, 350, 425-460; `git-hygiene.md` 3, 10-16, 41; `verify.md` 13, 16, 31 | holds |
| `context.md` §2.3, every reader file and line | holds: each file and line number matched |
| `context.md` §2.5, `.gitignore:8-10`, `CLAUDE.md:140…215`, `README.md:29, 76, 78, 92, 128, 170, 172`, `docs/verification.md:6, 226, 267, 269, 273` | holds |
| `context.md` §3, Phase headings at 20, 60, 113, 176, 236, 261, 358 and the count word "seven" at `skills/init/SKILL.md:12`, `CLAUDE.md:140` | holds |
| `design.md` §7 R6: the pathspec in `skills/init/SKILL.md:322` fails on an untracked path | holds: `git commit -q -m c -- .gitignore .hivrr.json` in a scratch repo printed `error: pathspec '.hivrr.json' did not match any file(s) known to git`, exit 1 (git 2.43.0) |
| Stop: `git grep -n -i hivrr -- . ':!docs/plans'` lists a `.hivrr.json` site that `inventory.md` does not | did not trigger: no extra site |

## Acceptance

Static proofs were run on the branch. Dry runs were run in scratch repos made with `mktemp -d`
under the session scratchpad, outside the checkout. Each had `HOME` set to a scratch directory whose
`.claude/settings.json` holds only `repoProvider` and `issueTracker`, no remote, and a non-root user
(`id -u` printed `1000`). The real `~/.claude/settings.json` was copied first, and
`cmp ~/.claude/settings.json {copy}` afterwards printed nothing. Every valid fixture is
`{"branches":{"integration":"dev"},"verify":{"detectedFrom":["manual"]}}`, as F-scratch says.

| ID | How it was shown |
|---|---|
| S-03.1 | Static: the reader loop over the 17 files of `context.md` §2.3 printed nothing; in `init`, `.hivrr.json` appears only in Phases 3 and 6 and in the frontmatter (awk printed `3`, `6`, `frontmatter`); the `load-bearing` sentence names only the new file (0) |
| S-03.1.e1 | D10a: `.agent-plugins.json` with `integration: dev`; the config.md Read steps gave `work-issue {integration} = dev` |
| S-03.1.e2 | D10b: same repo, no `worktree` key; the read resolved empty, so `merge-pr` Phase 9's worktree step is skipped |
| S-03.2 | D11 and S-03.2.e2 |
| S-03.2.e1 | D11: `.hivrr.json` only, no `init`; the `dispatch.md` read found `.agent-plugins.json` absent, so the fallback chain applies and `{base}` falls back to the default branch; `.hivrr.json` was never read |
| S-03.2.e2 | `git grep -l '\.hivrr\.json' -- . ':!docs/plans'` printed exactly `RELEASE-NOTES.md`, `skills/init/SKILL.md`, `skills/init/references/config.md` |
| S-03.3 | Pre-merge: `git diff --name-only origin/main...HEAD` holds all five readers checked (count 5), and `git show HEAD:skills/init/SKILL.md` holds the migration line. The PR is squash-merged only. The two post-merge checks are recorded in `progress/slice-03.md`, as Slice 2's Verify says |
| S-03.3.e1 | the same two pre-merge commands: 5, then 1 or more |
| S-03.3.e2 | the second command prints 0 on a branch without the migration; this branch prints 1 or more, so it is not that case |
| S-03.4 | `grep -cxF '.agent-plugins.json' .gitignore` → 1; `grep -cxF '.hivrr.json' .gitignore` → 0 |
| S-03.4.e1 | `git check-ignore -q .agent-plugins.json && echo ignored` → `ignored` |
| S-03.4.e2 | `grep -c '"owner": "your-org"'` → `README.md:1`, `skills/init/references/config.md:1`; `git grep -n '"owner": "hivrr"'` on both printed nothing |
| S-04.1 | D1 |
| S-04.1.e1 | D1: `INIT: upgraded .hivrr.json to .agent-plugins.json`, `INIT: .agent-plugins.json ok`; `cmp` against the pre-run copy printed nothing; `ls -A` shows only `.agent-plugins.json` |
| S-04.1.e2 | D1 again under `--auto`: the same two lines and `cmp` result. Step 1 holds no prompt in either mode (`skills/init/SKILL.md` Phase 3 Step 1: "asks no question, in any mode") |
| S-04.2 | D2 |
| S-04.2.e1 | D2: both files, different content, new valid → `INIT: removed .hivrr.json (.agent-plugins.json kept)`, then `ok`; `cmp` of the new file against its copy printed nothing; only `.agent-plugins.json` is left |
| S-04.2.e2 | D3: both files, new `{` → no migration line; `INIT: .agent-plugins.json is malformed — jq: parse error: …` and `init` stops; `cmp` shows `.hivrr.json` kept unchanged |
| S-04.3 | D4 |
| S-04.3.e1 | D4: neither file → Step 3 absent, continue to Step 4; the scaffold is written, `INIT: .agent-plugins.json scaffolded (integration: dev, ladder: [main])`, no migration line |
| S-04.3.e2 | D4, scaffold declined: no line from Step 1, no file (`ls -A` empty) |
| S-04.4 | D5 |
| S-04.4.e1 | D5: `.agent-plugins.json` only → `INIT: .agent-plugins.json ok` alone; `cmp` unchanged |
| S-04.4.e2 | D5 second run on D1's repo → `INIT: .agent-plugins.json ok` alone; `cmp` unchanged |
| S-04.5 | D6 |
| S-04.5.e1 | D6: `.hivrr.json` = `{` → renamed (`cmp` identical), then `INIT: .agent-plugins.json is malformed — …` and stop; not repaired or deleted |
| S-04.5.e2 | D6 with `PATH` lacking `jq` → upgraded line, then `INIT: .agent-plugins.json present (unvalidated — jq not installed)`; `cmp` identical |
| S-04.6 | S-04.6.e1 and e2; the count word at `skills/init/SKILL.md:12` still reads "seven" |
| S-04.6.e1 | `grep -c '^## Phase' skills/init/SKILL.md` → 7 |
| S-04.6.e2 | `eval "$(grep -m1 '^bash -c ' docs/verification.md)"` → `structural checks pass` |
| S-04.7 | D9 |
| S-04.7.e1 | D9a: `.hivrr.json` only with `integration: dev`; the `init` bootstrap migrated first, then the work-issue Phase 5 read gave `dev` |
| S-04.7.e2 | D9b: `.hivrr.json` only with `worktree` set; the migration ran in Phase 3, before Phase 7, and the worktree gate read `worktree` from `.agent-plugins.json` (present → the gate runs) |
| S-04.8 | D7 |
| S-04.8.e1 | D7 with `PATH` lacking `jq`: no migration line, `INIT: .agent-plugins.json present (unvalidated — jq not installed)`; `cmp` shows both files kept |
| S-04.8.e2 | D2 (both files, `jq` present, new valid → old removed) |
| S-04.9 | D8 |
| S-04.9.e1 | D8a: root `chmod a-w`, non-root → `INIT: migration stopped — rename .hivrr.json to .agent-plugins.json failed: mv: cannot move '.hivrr.json' to '.agent-plugins.json': Permission denied`; `.hivrr.json` still there |
| S-04.9.e2 | D8b: `.hivrr.json` a directory → `INIT: migration stopped — type check failed: .hivrr.json is not a regular file`; nothing moved. D8c: a symlink to a valid file → the same type-check line. D8d: `.agent-plugins.json` a directory → `… type check failed: .agent-plugins.json is not a regular file` |
| S-05.1 | D12 S-05.1.e1 |
| S-05.1.e1 | D12: `.gitignore` = `node_modules/`, blank line, two comment lines, `.hivrr.json`. The line was swapped **with the Edit tool**, as Step 1 says. `diff` against the copy shows only line 5 changed; `git check-ignore -q .agent-plugins.json` succeeds |
| S-05.1.e2 | same fixture: `node_modules/` untouched (the `diff` shows line 5 only) |
| S-05.2 | D12 below |
| S-05.2.e1 | no `.gitignore` → created holding the one line `.agent-plugins.json`; committed `.gitignore | 1 +` |
| S-05.2.e2 | `.gitignore` = `*.json` → nothing appended; `INIT: .agent-plugins.json gitignored` |
| S-05.3 | D12 below |
| S-05.3.e1 | both lines → `INIT: .gitignore line .hivrr.json removed (.agent-plugins.json already listed)`; the file is the one line `.agent-plugins.json` |
| S-05.3.e2 | `.agent-plugins.json` twice → nothing added or removed (`cmp` unchanged) |
| S-05.4 | D12 below |
| S-05.4.e1 | the S-05.1.e1 run on `feat/x`: one commit `chore(config): keep .agent-plugins.json out of git` carrying only `.gitignore | 2 +-`; no remote, no push |
| S-05.4.e2 | on `main`: `.gitignore` staged (`M  .gitignore`), no new commit, `INIT: .agent-plugins.json gitignored — main is protected, commit deliberately` |
| S-05.5 | S-05.5.e1 |
| S-05.5.e1 | `.gitignore` holds `.agent-plugins.json`, config untracked → no change, `INIT: .agent-plugins.json gitignored` |
| S-05.6 | D12 below |
| S-05.6.e1 | `.hivrr.json` committed, `.gitignore` holds the new line, an unrelated `other.txt` staged → Phase 3 renamed it, and Step 2 ran `git rm --cached -- .hivrr.json`. The commit carries only `.hivrr.json | 1 -`, and `other.txt` stays staged, outside the commit |
| S-05.6.e2 | the same on `main` → `D  .hivrr.json` staged, no commit, protected line |
| S-05.7 | D7 |
| S-05.7.e1 | D7 with no `jq`, both files kept: the probe printed `old-present`, so the `.hivrr.json` line stayed. `.agent-plugins.json` was appended; `git check-ignore -q` succeeds for both files |
| S-05.7.e2 | D7 with `jq` restored → `INIT: removed .hivrr.json (.agent-plugins.json kept)`, then `INIT: .gitignore line .hivrr.json removed (.agent-plugins.json already listed)`; `.gitignore` = comment plus `.agent-plugins.json`; committed `.gitignore | 1 -` |
| 2.1 | `grep -n '^## Phase [36] '` → ``## Phase 3 — Scaffold `.agent-plugins.json` `` and ``## Phase 6 — Keep `.agent-plugins.json` Out of Git`` |
| 2.2 | `git grep -n -i hivrr -- .gitignore skills/init/references/git-hygiene.md skills/init/references/verify.md` and `git grep -n '\.hivrr\.json' -- CLAUDE.md README.md` both printed nothing; `CLAUDE.md` (Repo configuration) and `README.md` (Configuration, "Upgrading from the old config file") describe the migration without the old name |
| 2.3 | the Read steps awk over `config.md` counted 0; the old name appears only under `## Migrating from .hivrr.json` |
| 2.4 | the loop over the 12 strings printed nothing; `grep -c 'INIT: \.hivrr\.json gitignored'` → 0 |
| 2.5 | `grep -c 'matches nothing extra'` → 0; `grep -c 'names only the paths that changed'` → 1 |

The `design.md` §8 P7 check (`git diff --name-only 749feb9 -- docs/plans/` plus untracked files,
filtered to paths outside this pack) printed nothing, exit 1.

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| Dry runs: "an agent session follows the changed `init`" | The agent ran the Phase 3 Step 1, Phase 3 Step 3 and Phase 6 commands from a shell transcription of the changed steps (a sourced file in the session scratchpad, not in the tree), reading each output. Phase 6's line edit was made with the Edit tool for S-05.1.e1, and with an exact-line `sed`/`awk` equivalent for the other `.gitignore` fixtures | Over 25 fixtures; the transcription keeps each command identical to the skill. The byte effect of an exact-line edit is the same, and S-05.1.e1 shows the Edit-tool path itself | n |
| — | `CLAUDE.md` and `README.md` each gained a short migration paragraph | Acceptance 2.2 asks both to describe the migration without the old name, and neither did | n |

## Decisions

- The migration is split into **1a — Type probe** and **1b — Which files are there**, so the
  type check runs first, as C2.a requires.
- A malformed `.agent-plugins.json` and a missing `jq` (exit 127) both take C2.e. Neither emits a
  migration line, and Step 3's existing lines report the state.
- Phase 6 detects the C4.a "old file still on disk" case with
  `{ test -e .hivrr.json || test -L .hivrr.json; }`, matching C2's definition of **present**.
- Step 3 runs `git add .gitignore` only when Step 1 changed it, on both the feature and the
  protected path. That way an unchanged `.gitignore` is never staged.

## Discoveries

- **For Slice 3:** record the two post-merge S-03.3 checks from Slice 2's Verify in
  `progress/slice-03.md` first. A result other than `2` and `5` means reverting Slice 2.
- **This checkout:** once `.gitignore` names `.agent-plugins.json`, the maintainer's local
  `.hivrr.json` shows as `??` until `init` migrates it. The next `init`-loading run on `main` does
  that. Its `verify.test` still exports `HIVRR_VERIFY_BLOCK`, which Slice 3 replaces by hand
  (S-06.4).
- `README.md:29` (the `init` table row) and `CLAUDE.md:140` name the scaffold and the gitignore
  phases but not the migration. Their lists still match the headings, so nothing checks or needs
  this; a later edit may add it.

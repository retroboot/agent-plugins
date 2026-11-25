# Slice 3 — Internal markers renamed

| | |
|---|---|
| **Status** | done |
| **Issue** | #299 |
| **PR** | this PR |
| **Executor model** | claude-opus-5-5 |
| **Date** | 2026-11-25 |

## Slice 2's post-merge checks (S-03.3)

Run on `main` straight after Slice 2 merged as `3966b52` (PR #305), before any other change:

| Check | Result |
|---|---|
| `c=$(git log -1 --format=%H -G 'INIT: upgraded .hivrr.json' origin/main -- skills/init/SKILL.md) && git rev-list --parents -n1 "$c" \| wc -w` | `c` = `3966b52f45029dcd5288001c56d59e24ede17802`; prints `2`: one parent, so it landed as a squash (S-03.3) |
| `git show --name-only --format= "$c" \| grep -cxE '<the five readers>'` | `5`: the readers landed in that same commit (S-03.3.e1) |

Both are the expected values, so the stop condition does not trigger and Slice 2 stays.

## Preflight

| Citation | Holds? |
|---|---|
| `context.md` §2.4, every site in `skills/session/references/github.md` (14, 16, 19, 264, 266), `gitlab.md` (18, 20, 23, 108, 110), `linear.md` (32), `skills/core/SKILL.md` (92, 94, 99, 100), `skills/promote/SKILL.md` (153, 157, 159), `skills/audit/SKILL.md` (129, 131, 136), `skills/review-pr/SKILL.md` (252), `skills/planning/references/publish.md` (17), `docs/verification.md` (96, 97, 101, 277) | holds: `git grep -n -o 'HIVRR_…'` outside `docs/plans` gave exactly these lines |
| `context.md` §2.4, `CLAUDE.md` 215, 217 | differs (line numbers only): the two sites are now at 221 and 223, because Slice 2 added a six-line paragraph above them. The text is unchanged, and no contract is affected |
| `design.md` §2 C7.b, the bootstrap string below the checks fence (`docs/verification.md:280-285` at `749feb9`) | holds: the string is the first `^bash -c ` line, after three fence lines |

## Acceptance

| ID | How it was shown |
|---|---|
| S-06.1 | `git grep -l 'AGENT_PLUGINS_' -- . ':!docs/plans'` listed exactly the 10 expected files: `CLAUDE.md`, `docs/verification.md`, `skills/audit/SKILL.md`, `skills/core/SKILL.md`, `skills/planning/references/publish.md`, `skills/promote/SKILL.md`, `skills/review-pr/SKILL.md`, `skills/session/references/github.md`, `skills/session/references/gitlab.md`, `skills/session/references/linear.md` |
| S-06.1.e1 | `git grep -n 'HIVRR_' -- . ':!docs/plans'` printed nothing |
| S-06.1.e2 | `grep -n 'AGENT_PLUGINS_' skills/core/SKILL.md` printed four lines (92, 94, 99, 100); 99-100 name `AGENT_PLUGINS_COMMIT_7f3a` and `AGENT_PLUGINS_BODY_7f3a` |
| S-06.2 | opener and closer counts: audit `1 1`, core `1 1`, promote `1 1`, github `2 2`, gitlab `2 2`; the ordered pair `diff` loop printed nothing |
| S-06.2.e1 | `sed -n '14p;16p' skills/session/references/github.md` → `cat > "$file" <<'AGENT_PLUGINS_BODY_7f3a'` and `AGENT_PLUGINS_BODY_7f3a` |
| S-06.2.e2 | the forbidden state is ruled out by the same pair `diff` loop (no `pair mismatch` line) |
| S-06.3 | `grep -m1 '^bash -c ' docs/verification.md \| grep -c 'export AGENT_PLUGINS_VERIFY_BLOCK'` → 1 |
| S-06.3.e1 | the bootstrap string printed `structural checks pass`, exit 0, both on the branch and in a fresh detached worktree of the commit (see Discoveries) |
| S-06.3.e2 | the checks block run bare under `env -u AGENT_PLUGINS_VERIFY_BLOCK` printed `CHECK COUNT UNCHECKED AGENT_PLUGINS_VERIFY_BLOCK unset, so nothing counted the block that ran` |
| S-06.4 | e2 and then e1 below, in the maintainer's own checkout. The maintainer authorised the executor to run the steps there (2026-11-25) |
| S-06.4.e2 | before the replacement: `eval "$(jq -r .verify.test .agent-plugins.json)" 2>&1 \| grep -c '^CHECK COUNT UNCHECKED'` → `1`, `exit 1`. The checkout had just been migrated by `init`'s new Phase 3 (`INIT: upgraded .hivrr.json to .agent-plugins.json`, `cmp` identical to the old file) |
| S-06.4.e1 | after `jq --arg t "$(grep -m1 '^bash -c ' docs/verification.md)" '.verify.test = $t'`: `jq -r '.verify.detectedFrom[0]'` → `manual`; `eval "$(jq -r .verify.test .agent-plugins.json)"` → `structural checks pass`, exit 0 |
| 3.1 | the fence counter awk printed `3` before the `bash -c` line |

The `design.md` §8 P7 check printed nothing, exit 1.

## Deviations

| Plan said | Reality | Why | Contract affected |
|---|---|---|---|
| S-06.4 steps are run by the maintainer | The executor ran them in the maintainer's checkout, with the maintainer's explicit go-ahead, and kept a backup of the local config in the session scratchpad | This session runs in the maintainer's own checkout, not in an executor worktree | n |
| `CLAUDE.md:215,217` | `CLAUDE.md:221,223` | Slice 2's migration paragraph shifted the lines | n |

## Decisions

None beyond the above.

## Discoveries

- This checkout went through the real migration: `init` Phase 3 renamed `.hivrr.json` to
  `.agent-plugins.json` with identical bytes, and Phase 6 found the file already ignored and
  untracked (`INIT: .agent-plugins.json gitignored`).
- Between this slice's merge and the moment each other checkout replaces its local `verify.test`,
  that checkout's verification exits 1 with `CHECK COUNT UNCHECKED` (R10). The v2.0.0 release entry
  in Slice 5 should tell any other checkout of this repo to replace its `verify.test` the same way.

# Every skill's bootstrap names a skill its plugin ships

| | |
|---|---|
| **Status** | published |
| **Type** | Bug |
| **Size** | S — 1 slice |
| **Modifiers** | none |
| **Issues** | #310 |
| **Owner** | retroboot |
| **Opened** | 2026-11-25 |

## Brief

Six skills tell the agent to load the `core` skill in their bootstrap, but the plugins that ship
them do not include `core` (#310). They are `planning`, `brainstorm`, `spec`, `slice` and
`cold-read` in `planner`, and `audit` in `auditor`. `.claude-plugin/marketplace.json` lists `core`
under `dev` only, and a plugin install carries only the skills its entry names. A user who installs
`planner` or `auditor` without `dev` gets a bootstrap step naming a skill that does not exist. The
step then fails or is skipped without a word, and the quality gates and git-safety rules `core`
holds never load. `skills/init/references/git-hygiene.md` already records this for `init`: "only
`dev` ships `core`". The setup works today only because both installing users also have `dev`.

**Outcome wanted (#310 Acceptance):** no skill's bootstrap names a skill its plugin does not ship,
ideally held by a structural check so the gap cannot return; `marketplace.json`, the `CLAUDE.md`
**Skills:** lines and `README.md` agree (check 6); the structural checks pass.

**Scope.** The bootstrap steps of the skills in `planner` and `auditor`, the plugin skill lists that
ship them, and the docs and checks that hold those lists. #310 names three options without choosing:
ship `core` in `planner` and `auditor`; drop the `core` step and restate inline what each skill
relies on, as `init` does for the pathspec rule; or make the step conditional, which #310 calls the
weakest because it keeps the silent skip. A related gap is in scope to decide, not necessarily to
fix: `spec`, `slice`, `cold-read`, `brainstorm` and `audit` load `core` but not `init`, so run first
in a repo that still holds `.hivrr.json` they resolve config as if there were none. v2.0.0 accepted
that (`docs/plans/move-to-retroboot`, ADR-002, design R8).

## Repro and root cause

**Repro.** Install `planner` (or `auditor`) from the `agent-plugins` marketplace without `dev`, then
run `planning`, `brainstorm`, `spec`, `slice`, `cold-read` or `audit`. The skill's Bootstrap
reaches `Load the \`core\` skill`. Statically, the same gap shows in the repo: for each plugin in
`.claude-plugin/marketplace.json`, compare every `N. Load the \`{skill}\` skill` step in its skills'
`SKILL.md` with that plugin's `skills` array. On 2026-11-25 that comparison lists exactly six gaps:
`auditor/audit`, `planner/brainstorm`, `planner/spec`, `planner/slice`, `planner/cold-read` and
`planner/planning`, each loading `core`.

**Expected:** every skill a bootstrap step names is installed with the plugin, so the step loads
it. **Actual:** `core` is absent from `planner` and `auditor`, so the step names a skill that is not
there. It fails or is skipped silently, and `core`'s quality gates and git-safety rules never load.
Both installing users also have `dev`, which ships `core`, so neither has seen it.

**Root cause.** `core` is registered only in `dev`'s `skills` array (`.claude-plugin/marketplace.json`),
while `init` and `session`, the other shared skills, are registered in both `dev` and `planner`.
Nothing checks that a bootstrap step names a skill its own plugin ships, so the gap was never
caught: check 6 compares the skill lists across `marketplace.json`, `CLAUDE.md` and `README.md`,
not against the skills' own bootstrap steps.

## Slice

Issue: #310 · Depends on: none

### Outcome

With `planner` or `auditor` installed without `dev`, every skill a bootstrap step names is shipped by the same plugin, so no bootstrap step points at a missing skill. A structural check now catches any such gap, so it cannot come back unnoticed. The skill lists in `marketplace.json`, `CLAUDE.md` and `README.md` still agree, and the structural checks pass.

### Acceptance

These are the regression criteria for the Bug route. "The comparison" means the first command in **Verify** below (described in `context.md` §4), which prints one `GAP {plugin}/{skill} loads {name}` line per gap (it printed exactly six at `d05a4ab`). "The checks" means `eval "$(grep -m1 '^bash -c ' docs/verification.md)"`, run from the repository root (`context.md` §4). The fix is ADR-001 (ship `core` in `planner` and `auditor`), ADR-002 (the five `core`-only skills load `init` and `session`) and ADR-003 (the check's scope and tag).

- **1.1** For every plugin in `.claude-plugin/marketplace.json`, each skill named by a line starting `N. Load the \`{skill}\` skill` anywhere in one of that plugin's skills' `SKILL.md` is in that plugin's `skills` array (ADR-003; `context.md` §1, §5 "bootstrap step", "gap").

| ID | Given | When | Then |
|---|---|---|---|
| 1.1.e1 | `auditor` ships `audit`, whose Bootstrap (`skills/audit/SKILL.md:20-23` before the fix) names `core` (`context.md` §2.1) | the comparison runs | no `GAP auditor/audit …` line |
| 1.1.e2 | `planner` ships `brainstorm`, `spec`, `slice` and `cold-read`, each of which loads `core` (before the fix its only step; after it the third, 1.6) | the comparison runs | no `GAP planner/{brainstorm,spec,slice,cold-read} …` line |
| 1.1.e3 | `skills/planning/SKILL.md:46-51` loads `init`, `session` and `core` in order, and `planner` ships `init` and `session` (`context.md` §1) | the comparison runs | no `GAP planner/planning …` line, for any of its three steps |
| 1.1.e4 | edge: `dev` ships `core`, and `work-issue` loads `init`, `session` and `core` (`skills/work-issue/SKILL.md:16-21`) | the comparison runs | no `GAP dev/…` line, before or after the fix |
| 1.1.e5 | edge: a `Load the …` sentence that is not a numbered line, as at `skills/planning/SKILL.md:183` (`context.md` §4) | the comparison, or check 15, runs | it is not counted as a step. Proven by the dry run that appends an unnumbered `debug` sentence to `skills/spec/SKILL.md`, and its numbered control, since the sentence at `:183` names a skill `planner` ships |
| 1.1.e6 | failure: the tree at `d05a4ab`, before the fix | the comparison runs | exactly the six lines listed in `context.md` §4, one per gap |
| 1.1.e7 | whole tree, after the fix | the comparison runs | no output |
| 1.1.e8 | edge: `skills/ship-pr/SKILL.md:57` is a numbered `Load the \`review-pr\` skill` step under Phase 2, not under `## Bootstrap`, and `dev` ships `review-pr` | the comparison runs | it is scanned, and gives no `GAP` line |

- **1.2** `core` is shipped by `planner` and `auditor` as well as `dev`, from the one `skills/core/` directory, so each of the six skills gets `core`'s rules when its plugin is installed without `dev` (ADR-001; `context.md` §2.3).

| ID | Given | When | Then |
|---|---|---|---|
| 1.2.e1 | the fix | `jq -r '.plugins[] \| select(.name == "planner" or .name == "auditor") \| .name + " " + (.skills \| index("./skills/core") != null \| tostring)' .claude-plugin/marketplace.json` runs | `auditor true`, then `planner true` |
| 1.2.e2 | edge: `dev` | the same query for `dev` runs | `dev true`, as before the fix |
| 1.2.e3 | failure: a fix that copies `core` into a second skill directory | `ls -d skills/*core*` runs | it lists more than `skills/core`: two sources of `core`'s rules, which ADR-001 rules out |

- **1.3** `.claude-plugin/marketplace.json`, the `CLAUDE.md` `**Skills:**` lines and the `README.md` per-plugin tables name the same skills for every plugin. This is check 6, which stays as it is (`context.md` §2.3, §2.4; `docs/verification.md:61-76`).

| ID | Given | When | Then |
|---|---|---|---|
| 1.3.e1 | the fix leaves the `dev` and `data-platform` `skills` arrays unchanged | the checks run | check 6 reports nothing for either |
| 1.3.e2 | the fix adds `core` to `planner`, and `init`, `session` and `core` to `auditor`, in `marketplace.json`, on `CLAUDE.md:118`/`:125` and in the `README.md` tables at `:42-50`/`:52-62` | the checks run | check 6 reports nothing |
| 1.3.e3 | failure: a skill added to `planner` in `marketplace.json` but not on `CLAUDE.md:125` | the checks run | check 6 prints `SKILLS DRIFT planner claude` and the block exits 1 (`docs/verification.md:73-75`) |

- **1.4** The structural checks include one that fails when any skill's bootstrap step names a skill its own plugin does not ship. It prints `BOOTSTRAP GAP {plugin}/{skill} loads {name}` for each one, and is silent otherwise (ADR-003). The README Route ("the fix and one structural check that keeps it fixed") makes it part of this slice. It follows the existing check shape and the fence-editing rules (`context.md` §3), and the check count in `CLAUDE.md:221` matches the fence (check 8, `context.md` §1, §2.4).

| ID | Given | When | Then |
|---|---|---|---|
| 1.4.e1 | the tree after the fix | the checks run | the single line `structural checks pass`, exit status 0 |
| 1.4.e2 | failure: constructed input (`docs/verification.md:219-225`) with the six gaps of `d05a4ab` restored | the new check runs | one report line for each of the six gaps, naming plugin, skill and `core`, and the block exits 1 |
| 1.4.e3 | edge: constructed input in which a `dev` skill's bootstrap names a skill `dev` does not ship | the new check runs | it reports that gap, so the check covers every plugin and not just `planner` and `auditor` |
| 1.4.e4 | edge: a `Load the \`{skill}\` skill` sentence that is not a numbered bootstrap step, as at `skills/planning/SKILL.md:183` | the new check runs | no report for it |
| 1.4.e5 | failure: the check added but `CLAUDE.md:221` still says "Fourteen checks:" instead of "Fifteen checks:" | the checks run | check 8 prints `CHECK COUNT DRIFT CLAUDE.md says …` and the block exits 1 (`docs/verification.md:95-102`) |
| 1.4.e6 | edge: the checks run with stdin closed (`docs/verification.md:228-239`) | the block runs | same result as e1 |
| 1.4.e7 | edge: constructed input with `./skills/review-pr` removed from `dev` | the new check runs | it reports `BOOTSTRAP GAP dev/ship-pr loads review-pr` (the step at `skills/ship-pr/SKILL.md:57`, outside `## Bootstrap`) among its lines, and the block exits 1 |

- **1.5** Every current statement in the repository about which plugins ship `core`, `init` and `session`, or about what the `core`-only skills load, matches `marketplace.json` and the bootstrap steps after the fix. Records of past decisions and releases are not edited (`context.md` §2.3, §2.4, §2.5).

| ID | Given | When | Then |
|---|---|---|---|
| 1.5.e1 | the fix | `skills/init/references/git-hygiene.md:64-72` and `skills/init/SKILL.md:425-434` are read | neither says that only `dev` ships `core`, or (lines 433-434) that `planner` is the plugin "which has no `core`" |
| 1.5.e2 | the fix | `skills/init/references/config.md:344-352` is read | it names no skill as loading only `core`, since none does (ADR-002) |
| 1.5.e3 | the fix | `README.md:21` and `CLAUDE.md:138` are read | each names `auditor` among the plugins that include `init` and `session` |
| 1.5.e4 | edge: the closed pack and the release record | `docs/plans/move-to-retroboot/` and `RELEASE-NOTES.md` are diffed against `d05a4ab` | no change (an accepted ADR is never edited; `context.md` §2.5) |

- **1.6** `spec`, `slice`, `cold-read`, `brainstorm` and `audit` load `init`, then `session`, then `core`, as the `dev` workflow skills do, and every plugin that ships one of them ships all three (ADR-002; `skills/work-issue/SKILL.md:16-21`).

| ID | Given | When | Then |
|---|---|---|---|
| 1.6.e1 | the fix | the numbered `Load the` lines under `## Bootstrap` in each of the five `SKILL.md` files are read | `init`, `session`, `core`, in that order, in each |
| 1.6.e2 | the fix | `jq -r '.plugins[] \| select(.name == "auditor") \| .skills[]' .claude-plugin/marketplace.json` runs | it lists `./skills/init`, `./skills/session` and `./skills/core` with the five `audit` skills |
| 1.6.e3 | failure: `audit` loads `init` but `auditor` does not ship it | the checks run | the new check prints `BOOTSTRAP GAP auditor/audit loads init` and the block exits 1 |
| 1.6.e4 | edge: `planning` | its Bootstrap is read | unchanged: `init`, `session`, `core` (`skills/planning/SKILL.md:46-51`) |

**Failure note:** A user with `planner` or `auditor` but not `dev` runs one of the six skills. Its bootstrap names `core`, which is not installed, so `core`'s quality gates and git-safety rules never load. The pack takes it, as the Brief does, that the user sees no error (unverified; **Open questions**).

### Contracts

**C1 — plugin skill lists** (`.claude-plugin/marketplace.json`, ADR-001, ADR-002). Each entry stays a
directory path with no extension (`context.md` §3).

| Plugin | `skills` after the fix | Change |
|---|---|---|
| `dev` | unchanged | none |
| `planner` | `init`, `session`, `core`, `brainstorm`, `spec`, `slice`, `cold-read`, `planning` | adds `./skills/core` |
| `auditor` | `init`, `session`, `core`, then the five `audit` skills in their current order (`.claude-plugin/marketplace.json:38-42`) | adds `./skills/init`, `./skills/session`, `./skills/core` |
| `data-platform` | unchanged | none |

The `CLAUDE.md` **Skills:** line and the `README.md` table for each changed plugin list the same
names. A shared skill's `README.md` row reads `Shared setup skill — see \`dev\``, as `init` and
`session` already do in `planner` (`README.md:56-57`).

**C2 — bootstrap of the five `core`-only skills** (ADR-002). Under `## Bootstrap`, the lead-in
`Run in order before Phase 1:` (as `skills/planning/SKILL.md:48`), then steps 1 and 2 copied from
`skills/work-issue/SKILL.md:19-20` (`init` and `session`, purpose text included), then the skill's
existing `core` line as step 3, its own purpose text kept. This is the exact form of ADR-002's "same
wording" and ADR-001's "leave every existing `core` step": the `core` line's text stays, and only
its number changes. `init` runs exactly as it does for the `dev` skills, so an `audit` run
now meets `init`'s own outcomes unchanged: the one-time provider prompt and settings write when
`providerConfig` is missing, `gh` label calls, and the Phase 6 `.gitignore` commit
(`skills/init/SKILL.md`, Phases 1, 2 and 6). This slice changes no `init` text about them; ADR-002
records the effect.

The **Do not stage or commit** rule in `spec`, `slice`, `cold-read` and `brainstorm`
(`skills/spec/SKILL.md:34`, `skills/slice/SKILL.md:36`, `skills/cold-read/SKILL.md:38`,
`skills/brainstorm/SKILL.md:235`) is about the pack folder, and still holds: `init`'s Phase 6 commit
names only `.gitignore` and the config paths it untracked in its pathspec, never another path
(`skills/init/SKILL.md:415-426`). `planning` already loads `init` under the same rule
(`skills/planning/SKILL.md:42`). Leave those rules unchanged.

**C3 — the new structural check** (check 15, ADR-003).

| Name | Inputs | Output | Errors | Invariants |
|---|---|---|---|---|
| bootstrap gap check | `.claude-plugin/marketplace.json`; the `SKILL.md` of every skill each plugin ships | nothing when every numbered `Load the \`{name}\` skill` line names a skill its plugin ships; otherwise one line `BOOTSTRAP GAP {plugin}/{skill} loads {name}` per gap | a missing `SKILL.md` is left to check 2 (`BAD SKILL`) | one column-0 `# ` comment; reads no stdin; no fence-shaped line; covers every plugin, not only `planner` and `auditor` |

It goes at the end of the fence, after check 14. It also gets a row 15, after row 14, in the table under the fence (`docs/verification.md:200-215`), and
`CLAUDE.md:221` says `Fifteen checks:` and describes it in the same sentence as the others.

### Stop conditions

- Stop if a contract this slice depends on has drifted from `context.md` (preflight).
- Stop if, before any edit, the comparison (the first Verify command) prints anything other than its six
  expected `GAP` lines: the gap set has changed and the slice's scope with it.
- Stop if making the checks pass needs any existing check's logic changed. This slice adds check 15
  to the fence, a row to the check table and edits the count sentence in `CLAUDE.md:221`; nothing
  else in the checks changes.
- Stop if `audit` loading `init` needs any change to `init`'s phases beyond the sentences 1.5
  names: ADR-002 assumes `init` runs as it is.
- Stop if a file under `docs/plans/move-to-retroboot/`, or `RELEASE-NOTES.md`, would have to change
  (1.5.e4).

### Verify

Run from the repository root after the fix is committed. Before the fix, each command gives the
unfixed value instead: the six `GAP` lines, `dev true`, `auditor false`, `planner false`, and so on.

```bash
command -v jq >/dev/null || echo 'NO JQ'; jq -r '.plugins[] | .name as $n | .skills[]? | "\($n) \(. | sub(".*/";""))"' .claude-plugin/marketplace.json | while read p s; do sed -n 's/^[0-9][0-9]*\. Load the `\([a-z-]*\)` skill.*/\1/p' "skills/$s/SKILL.md" | while read l; do jq -e --arg p "$p" --arg l "./skills/$l" '.plugins[] | select(.name == $p) | .skills | index($l)' .claude-plugin/marketplace.json >/dev/null || echo "GAP $p/$s loads $l"; done; done
# expected: no output after the fix (1.1, 1.1.e1 to e4, e7, e8); before it, the six GAP lines context.md §4 lists (stop condition 2)
eval "$(grep -m1 '^bash -c ' docs/verification.md)"
# expected: structural checks pass, exit 0 (1.3.e1, 1.3.e2, 1.4.e1, 1.4.e4, 1.4.e6)
jq -r '.plugins[] | select(.name == "planner" or .name == "auditor" or .name == "dev") | .name + " " + (.skills | index("./skills/core") != null | tostring)' .claude-plugin/marketplace.json
# expected: dev true, auditor true, planner true, in marketplace order (1.2.e1, 1.2.e2)
ls -d skills/*core*
# expected: skills/core only (1.2.e3)
jq -r '.plugins[] | select(.name == "auditor") | .skills[]' .claude-plugin/marketplace.json
# expected, in this order: ./skills/init, ./skills/session, ./skills/core, then the five audit skills as today (1.6.e2, C1)
for s in spec slice cold-read brainstorm audit planning; do printf '%s: ' "$s"; awk '/^## Bootstrap/ { b = 1; next } b && /^## / { exit } b' "skills/$s/SKILL.md" | sed -n 's/^[0-9][0-9]*\. Load the `\([a-z-]*\)` skill.*/\1/p' | tr '\n' ' '; echo; done
# expected: each of the six lines ends "init session core " (1.6.e1, 1.6.e4)
grep -c 'Fifteen checks:' CLAUDE.md; grep -c '^| 15 |' docs/verification.md
# expected: 1, then 1 (1.4, C3)
grep -c '^| `core` | Shared setup skill — see `dev` |' README.md; grep -c '^| `init` | Shared setup skill — see `dev` |' README.md; grep -c '^| `session` | Shared setup skill — see `dev` |' README.md
# expected: 2, 2, 2: the `planner` and `auditor` tables (C1)
git grep -n -e 'only `dev` ships `core`' -e 'which has no `core`' -- skills
# expected: no output, exit 1 (1.5.e1)
grep -c 'loads only `core`' skills/init/references/config.md
# expected: 0 (1.5.e2). These greps catch only the old phrasing: also read the sentences at
# git-hygiene.md:64-72, init/SKILL.md:425-434 and config.md:344-352; a paraphrase that keeps a claim fails 1.5
grep -c 'shared setup skills included by.*auditor' README.md; grep -c 'are included by.*auditor' CLAUDE.md
# expected: 1, then 1 (1.5.e3)
git diff --name-only d05a4ab -- docs/plans/move-to-retroboot RELEASE-NOTES.md
# expected: no output (1.5.e4)
```

The first command is the comparison. Without its `jq` guard it would print nothing when `jq` is
missing, so it prints `NO JQ` then; run it from the repository root. Check 15 (1.4.e1) is its
guarded form.

**Dry runs on constructed input** (`docs/verification.md:219-225`). Each runs in a scratch detached
worktree, so the real tree is never edited. `{w}` and `{o}` are the paths the `mktemp` lines print;
write them into the later lines by hand. Each line reverts its edit only after `cd` succeeds, so a
mistyped path does nothing rather than touching this checkout.

```bash
mktemp -d "${TMPDIR:-/tmp}/bootstrap-gap.XXXXXX"
git worktree add -q --detach "{w}" HEAD
(cd "{w}" && jq '(.plugins[] | select(.name == "planner" or .name == "auditor") | .skills) -= ["./skills/core"]' .claude-plugin/marketplace.json > m.json && mv m.json .claude-plugin/marketplace.json && { eval "$(grep -m1 '^bash -c ' docs/verification.md)" | grep -c '^BOOTSTRAP GAP .* loads core$'; git checkout -q -- .; })
# expected: 6, one per gap of d05a4ab (1.4.e2)
(cd "{w}" && jq '(.plugins[] | select(.name == "dev") | .skills) -= ["./skills/review-pr"]' .claude-plugin/marketplace.json > m.json && mv m.json .claude-plugin/marketplace.json && { eval "$(grep -m1 '^bash -c ' docs/verification.md)" | grep -cx 'BOOTSTRAP GAP dev/ship-pr loads review-pr'; git checkout -q -- .; })
# expected: 1, from the step outside ## Bootstrap (1.4.e3, 1.4.e7)
(cd "{w}" && jq '(.plugins[] | select(.name == "auditor") | .skills) -= ["./skills/init"]' .claude-plugin/marketplace.json > m.json && mv m.json .claude-plugin/marketplace.json && { eval "$(grep -m1 '^bash -c ' docs/verification.md)" | grep -cx 'BOOTSTRAP GAP auditor/audit loads init'; git checkout -q -- .; })
# expected: 1 (1.6.e3)
(cd "{w}" && printf '\nThen Load the `debug` skill for a root cause.\n' >> skills/spec/SKILL.md && { eval "$(grep -m1 '^bash -c ' docs/verification.md)" | grep -c '^BOOTSTRAP GAP'; git checkout -q -- .; })
# expected: 0: an unnumbered sentence naming a skill planner does not ship is not reported (1.1.e5, 1.4.e4)
(cd "{w}" && printf '\n9. Load the `debug` skill for a root cause.\n' >> skills/spec/SKILL.md && { eval "$(grep -m1 '^bash -c ' docs/verification.md)" | grep -cx 'BOOTSTRAP GAP planner/spec loads debug'; git checkout -q -- .; })
# expected: 1: the same line numbered is reported, the control for the run above (1.4.e4)
(cd "{w}" && sed -i 's/Fifteen checks:/Fourteen checks:/' CLAUDE.md && { eval "$(grep -m1 '^bash -c ' docs/verification.md)" | grep -c '^CHECK COUNT DRIFT'; git checkout -q -- .; })
# expected: 1 (1.4.e5)
(cd "{w}" && jq '(.plugins[] | select(.name == "planner") | .skills) += ["./skills/debug"]' .claude-plugin/marketplace.json > m.json && mv m.json .claude-plugin/marketplace.json && { eval "$(grep -m1 '^bash -c ' docs/verification.md)" | grep -cx 'SKILLS DRIFT planner claude'; git checkout -q -- .; })
# expected: 1 (1.3.e3)
git worktree remove --force "{w}"
mktemp -d "${TMPDIR:-/tmp}/bootstrap-base.XXXXXX"
git worktree add -q --detach "{o}" d05a4ab
(cd "{o}" && jq -r '.plugins[] | .name as $n | .skills[]? | "\($n) \(. | sub(".*/";""))"' .claude-plugin/marketplace.json | while read p s; do sed -n 's/^[0-9][0-9]*\. Load the `\([a-z-]*\)` skill.*/\1/p' "skills/$s/SKILL.md" | while read l; do jq -e --arg p "$p" --arg l "./skills/$l" '.plugins[] | select(.name == $p) | .skills | index($l)' .claude-plugin/marketplace.json >/dev/null || echo "GAP $p/$s loads $l"; done; done)
# expected: exactly the six GAP lines context.md §4 lists (1.1.e6)
git worktree remove --force "{o}"
```

Record every result against its ID in `progress/slice-01.md`.

### Pattern to follow

- Check shape: check 6, `docs/verification.md:61-76` — `jq` over `marketplace.json`, a per-plugin
  loop, one upper-case report line per failure.
- Bootstrap wording: `skills/work-issue/SKILL.md:16-21`.
- A skill shared by two plugins: `init` and `session` in `dev` and `planner`
  (`.claude-plugin/marketplace.json:16-29,51-59`; `README.md:56-57`).

### Suggested path

Default route. You may deviate if every mandatory item still holds; record why.

1. Preflight, and run the comparison (the first Verify command) to confirm the six gaps.
2. Write check 15 first, before touching the real lists, and run the checks: on the unfixed lists it
   must print exactly the six `BOOTSTRAP GAP … loads core` lines (the real-tree form of 1.4.e2),
   beside check 8's `CHECK COUNT DRIFT` until step 3 changes the count. The
   dry runs run after the commit, against `HEAD`.
3. Add it to the fence, the table row 15 and `CLAUDE.md:221` (`Fifteen checks:`).
4. Register the skills (C1) in `marketplace.json`, then the `CLAUDE.md` **Skills:** lines and the
   `README.md` tables.
5. Give the five skills the three-step bootstrap (C2).
6. Correct the stale sentences. `skills/init/SKILL.md:433-434` and `skills/init/references/git-hygiene.md:64-72`:
   keep the inline pathspec rule, and give as its reason that `init` runs before any `core` load and
   keeps the rule in its own file, naming no plugin as lacking `core`.
   `skills/init/references/config.md:344-352`: drop the list of `core`-only skills and say every skill
   that reads config loads `init` first. `README.md:21` and `CLAUDE.md:138`: add `auditor`.
7. Run Verify and the dry runs, and record each ID.

### Files

- Create: `docs/plans/bootstrap-skills-shipped/progress/slice-01.md`
- Modify: `docs/plans/bootstrap-skills-shipped/README.md` (Status, Retro: rules 7 and 8), distinct from the root `README.md` below
- Modify: `.claude-plugin/marketplace.json`, `CLAUDE.md`, `README.md`, `docs/verification.md`
- Modify: `skills/audit/SKILL.md`, `skills/brainstorm/SKILL.md`, `skills/spec/SKILL.md`,
  `skills/slice/SKILL.md`, `skills/cold-read/SKILL.md`
- Modify: `skills/init/SKILL.md`, `skills/init/references/git-hygiene.md`,
  `skills/init/references/config.md`

## Route

- **Bug:** a packaging defect with a known root cause, so no `debug` run is needed.
- **S:** the fix and one structural check that keeps it fixed fit one PR.
- **No modifiers:** no data, API, security or UI surface; the change is plugin packaging and Markdown.

## Read order

1. This file, including **How to execute this pack** below
2. [`context.md`](context.md): what exists today, with file citations, conventions and glossary
3. [`decisions/`](decisions/): the decisions and the options rejected
4. `progress/`: one file per slice once execution starts
5. [`cold-read.md`](cold-read.md): results of the cold-read review of this pack

## How to execute this pack

These rules are the same in every pack. They live here so an executor needs nothing but this
folder and the repository.

1. **Work one slice at a time.** A slice is one issue and one PR. Its issue body carries a line
   `Plan: docs/plans/bootstrap-skills-shipped · Slice: N`.
2. **Preflight before editing.** Confirm that every path and symbol `context.md` cites, and that
   your slice touches, still exists as described. Record anything that differs in your slice's
   progress file as a deviation. If the difference touches your slice's **Contracts**, stop.
3. **Mandatory beats guide.** In `plan.md`, every slice's **Outcome**, **Acceptance**,
   **Contracts**, **Stop conditions** and **Verify** are mandatory. **Pattern to follow**,
   **Suggested path** and **Files** are guidance. You may leave the suggested path if every
   mandatory item still holds. Record why in your progress file.
4. **Trace acceptance.** Every acceptance criterion ID in your slice (for example `S-04.2`), and
   every example row under it in the PRD's **Rules and examples** (for example `S-04.3.e1`), must be
   shown to hold. Use a test that names the ID or, where the repo has no test runner, a verification
   step recorded against the ID in your progress file. Follow the levels in the design's **Test
   strategy**.
5. **Stop conditions are hard stops.** When one triggers, stop, leave the branch intact, write the
   blocking question into your progress file with status `blocked`, and report. Do not work around it.
6. **Do not silently edit the plan.** If the PRD, an ADR, `design.md` or another slice turns out to
   be wrong, record it as a deviation. If it changes a contract, that is a stop.
7. **Write your progress file** at `progress/slice-NN.md` (`NN` is the slice number, zero-padded)
   and commit it in the same PR as the slice. Give it these sections, in order:
   - **Header:** Status (`in-progress`, `blocked` or `done`), Issue, PR, Executor model if known,
     Date.
   - **Preflight:** each citation checked, and whether it holds.
   - **Acceptance:** each criterion ID and example ID, and how it was shown.
   - **Deviations:** a table of plan said / reality / why / contract affected (y/n).
   - **Decisions:** choices the plan left open.
   - **Discoveries:** what the next slice or the retro should know.
   - **Blocked on:** only when blocked; the question and the stop condition that triggered.

   If this README's Status is `published`, change it to `executing` in the same commit.
8. **Close the pack when you finish the last slice.** If every other slice's progress file says
   `done`, add a **Retro** section to this README in the same PR and set **Status** to `done`.

## Open questions

- Decided at the acceptance checkpoint on 2026-11-25: the fix (ADR-001), `init` loading (ADR-002) and the check's scope and tag (ADR-003).
- Kept as the Brief's claims, not verified in the repository (DN6, DS4, GF3, GF6, GT1, GT6): that a plugin install carries only the skills its entry names, that a missing skill is skipped silently, that both installing users have `dev`, and #310's own text.

## Retro

_Written by the final slice. Guidance: compare what the cold read predicted with what really
diverged, using the deviations in every progress file._

| Cold read predicted | What diverged | Slice | Lesson for the next pack |
|---|---|---|---|

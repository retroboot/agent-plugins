# Git Hygiene — the reasoning behind `init` Phases 6 and 7

`init` Phase 6 (keep `.agent-plugins.json` out of git) and Phase 7 (report orphan worktrees) keep their
steps, commands, gates and report strings in [`SKILL.md`](../SKILL.md). This file holds the reasoning
behind them. Read it when a step there names a section here — typically when a result looks
surprising, or before changing either phase.

---

## Phase 6 — why `.agent-plugins.json` stays out of git

`.agent-plugins.json` is per-checkout, not shared — each teammate, agent, and CI run derives its own copy by
running `init`, the same way each of them has their own `~/.claude/settings.json`. A copy that leaks
into git via a missing `.gitignore` entry gives every clone a stale, silently-inherited config
instead of one derived from that machine's actual repo state — which is exactly how this plugin's own
repo ended up with a committed config file before this phase existed. This phase exists to make
that failure mode structurally impossible rather than something a `.gitignore` review might catch.
[`config.md`](config.md) (**Why repo-local, and why gitignored**) has the longer history.

## Phase 6 — why the old ignore line is swapped, and when it is kept

Before v2.0.0 the config file had another name, and a repo `init` set up then has a `.gitignore`
line for that name. Step 1 replaces that exact line with `.agent-plugins.json` instead of appending
a second line, so the file keeps one ignore line, under the name the skills read, and every other
line keeps its bytes. When `.agent-plugins.json` is already listed, the old line is deleted instead.
Only lines that are exactly the old name change: a variant such as a leading `/` is left alone, and
Step 1's ignore check still adds the new line.

The swap is skipped while the old file is still on disk. That happens only when Phase 3 kept it,
because `.agent-plugins.json` could not be validated. Removing the line then would leave the kept
file untracked and unignored, where one `git add .` commits it. A later run, once Phase 3 has
removed the old file, swaps the line.

## Phase 6 — why an ignored file still goes to Step 2

Being ignored going forward does not untrack something git already knows about. The file may still
be tracked from before this phase existed, or from before `.gitignore` had the line at all.

## Phase 6 — why append to `.gitignore`

Append rather than overwrite — `.gitignore` routinely already excludes `node_modules/`, `.env`, or
this plugin's own `.claude/` entry, and this phase's job is one more line, not a rewrite.

## Phase 6 — what `git rm --cached` does

It stages a deletion *from the index only* — the file stays on disk with its current content, so no
config is lost. The commit in Step 3 is what actually removes it from the repo's history going
forward (past commits still have it; that is expected and not this phase's job to rewrite).

## Phase 6 — the commit's trailing pathspec

**The trailing pathspec is required, not decoration**, for the same reason it always is in this
plugin: a bare `git commit` commits the **whole index**, including anything staged before `init` ran
by the user or an interrupted workflow, and `init` runs as the first bootstrap step of every command
— so it routinely executes mid-workflow in a checkout with a populated index. Naming a config file
in the pathspec commits its *removal* (from Step 2) when that happened; git accepts a pathspec for a
staged deletion the same way it does for a staged addition.

The commit names only the paths that changed: `.gitignore` when Step 1 changed it, and each config
file Step 2 untracked. Never name a path that did not change. A pathspec naming an untracked file is
not harmless: `git commit` fails with `error: pathspec '…' did not match any file(s) known to git`,
and nothing is committed.

## Phase 6 — why the pathspec rule is restated in `init`, not linked

`core` states it once, under **Staging**, and `work-issue` and `work-pr` link to it. `init` cannot:
it ships in **both** `dev` and `planner`, and only `dev` ships `core` — a plugin install carries just
the skills its `marketplace.json` entry names, so `../core/SKILL.md` resolves to nothing in one
install out of two. Reordering the bootstrap so `core` loads before `init` would not change that; the
constraint is packaging, not load order. Keep the copy inline in `SKILL.md`, and keep it
phase-agnostic — the phase numbers in the other two skills are hand-maintained and nothing verifies a
prose reference to them.

---

## Phase 7 — why it is not gated on `project`

Like Phase 6, Phase 7 is a **sibling of Phase 5, not a step inside it.** Phase 5 skips entirely when
`project` is absent, and a repo that configures `worktree` without a board would then never hear
about its orphans. The two keys are independent.

An abandoned or crashed session leaves a worktree that nothing else will notice, and each one holds
a branch that cannot be deleted while it exists. `init` runs on every command, which makes it the
cheapest place to surface them.

## Phase 7 — why `: gone]`, not `git branch --merged`

Under squash merges — this plugin's default strategy, and what `merge-pr` documents at length where
it cleans up branches — a merged branch shares no commit with the base, so `--merged` returns nothing
for exactly the branches this phase most needs to find. The failure is silent: an empty result is
indistinguishable from "no merged orphans".

`: gone]` means the remote ref disappeared, **not** that the work landed — a closed-unmerged PR and a
force-pushed rename produce the same signature. `merge-pr` treats that ambiguity as a reason to
verify before deleting. Here it is not a problem: this phase only reports, and a worktree worth a
second look is worth reporting either way. That is why the report says `branch gone from remote`
rather than `merged` — it claims only what it checked.

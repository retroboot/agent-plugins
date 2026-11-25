# Move to retroboot and drop the hivrr name

| | |
|---|---|
| **Status** | executing |
| **Type** | Migration |
| **Size** | M — 6 slices |
| **Modifiers** | infra, public-api |
| **Issues** | #297–#302 (Slices 1–6) |
| **Owner** | retroboot |
| **Opened** | 2026-11-25 |

## Brief

This repo lives at `hivrr/agent-plugins`, a private repository in the `hivrr` GitHub organization.
The `hivrr` org is being repurposed and needs none of this repo's history. The repo moves to the
owner's personal account as `retroboot/agent-plugins` by a **GitHub transfer**, which keeps git
history, branches, tags, releases, issues, pull requests, labels and milestones, and redirects the
old URLs.

The `hivrr` name goes with it, everywhere except the historical plan packs under `docs/plans/`:

- The marketplace `hivrr-agent-plugins` becomes **`agent-plugins`**. Installs become
  `dev@agent-plugins`, `planner@agent-plugins`, `auditor@agent-plugins` and
  `data-platform@agent-plugins`.
- The per-repo config file `.hivrr.json` becomes **`.agent-plugins.json`**. It keeps the same
  schema, stays gitignored, and is read by every skill that reads `.hivrr.json` today.
- The internal markers `HIVRR_BODY_7f3a`, `HIVRR_COMMIT_7f3a` and `HIVRR_VERIFY_BLOCK` become
  `AGENT_PLUGINS_BODY_7f3a`, `AGENT_PLUGINS_COMMIT_7f3a` and `AGENT_PLUGINS_VERIFY_BLOCK`.
- "Hivrr" prose and titles in `README.md`, `CLAUDE.md`, `RELEASE-NOTES.md` going forward,
  `.env.example`, skill descriptions and headings, and the `marketplace.json` metadata
  description are rewritten for the new name.
- The unused Claude GitHub workflows, `.github/workflows/claude.yml` and
  `.github/workflows/claude-code-review.yml`, are deleted.

`init` grows an automatic migration. Dozens of repos may hold a `.hivrr.json`, so when `init` finds
one it renames it to `.agent-plugins.json` and prints a line such as
`Upgrading old config file to new format`. When both files exist, `.agent-plugins.json` wins and
`.hivrr.json` is removed once the new file validates;
otherwise both are kept. The `.hivrr.json` line in that repo's `.gitignore` is replaced by
`.agent-plugins.json`, once the old file is gone (prd S-05.7). The migration folds into `init` Phase 3 (scaffold), which already owns
whether the config file exists, and Phase 6 swaps the `.gitignore` line; `init` stays at seven
phases, so structural checks 7 and 10 do not move. Every skill that loads `init` (all the `dev`
workflows, and `planning`) migrates a repo on its first run after the upgrade, with no separate
rollout. `spec`, `slice`, `cold-read`, `brainstorm` and `audit` load only `core`: run first in an
unmigrated repo, they resolve config as if none existed until an `init`-loading skill runs, which
the developer accepted (answered at the acceptance checkpoint, 2026-11-25).

After the transfer the repository becomes **public**, and its collaborators other than `retroboot`
(`cedwards-plk`, then `bschappaugh-plk` after a clean history scan, ADR-010) are removed: they had access only to see the private plugin
(answered at the acceptance checkpoint, 2026-11-25). Before it is made public, its full history is checked for secrets. There are two
installing users, `retroboot` and `cedwards-plk`. Each uninstalls the old plugins, removes the `hivrr-agent-plugins`
marketplace and adds `agent-plugins` from `retroboot/agent-plugins` once; a clean cut is acceptable, so no skill keeps a
fallback that reads `.hivrr.json`.

## Ruled out

- **Copying the repo to the new account instead of transferring it.** A copy (`git push --mirror`)
  keeps history and tags but loses issues, pull requests, comments, labels, milestones and GitHub
  Releases, and leaves no URL redirect. The `hivrr` org needs no copy kept, so transfer gives
  everything a copy would and more.
- **A branding-only rename, or branding plus the config file only.** The developer chose to remove
  every `hivrr` string, internal markers included.
- **A dual-read fallback in every skill (read `.agent-plugins.json`, else `.hivrr.json`).** The repo
  has no config loader, so a fallback would be prose in every reading skill. With two users and
  `init` running first in every workflow, the one-time migration in `init` is enough.
- **`.retroboot.json` as the new config name.** It ties the file to an owner again, the mistake
  being undone here.
- **`.claude/agent-plugins.json` as the new config name.** Many repos commit `.claude/`, which works
  against keeping the file out of git.
- **Removing the `init` migration in this work.** It stays for now; removing it is a later release
  outside this plan.

## Key insights

- **What a transfer leaves behind is org-level only:** teams, org secrets and org Projects boards.
  This repo uses none of them: it has no project board by decision (`CLAUDE.md`), and the
  developer does not use the Claude GitHub workflows in this repo, so the
  `CLAUDE_CODE_OAUTH_TOKEN` secret they reference is a repository secret that travels with the
  repository and is deleted before it goes public.
- **The redirect from `hivrr/agent-plugins` lasts only until the org creates a repo with that
  name.** Local remotes and the marketplace source should be updated to `retroboot/agent-plugins`
  rather than relying on the redirect.
- **Every `init`-loading skill migrates first**, so the config migration reaches each repo on its
  first `dev` workflow or `planning` run. That is what makes a clean cut safe without a fallback in
  the reading skills. The five `core`-only skills are the accepted gap.
- **The rename of the config filename and the `init` migration must land together.** A release
  where skills read `.agent-plugins.json` but `init` cannot migrate would silently drop every
  repo's config to defaults (verification included), because an absent config is not an error.
- **Historical plan packs keep their `hivrr` strings.** `docs/plans/*/progress/` and `cold-read.md`
  record commands that actually ran (for example `--repo hivrr/agent-plugins`). Rewriting them
  would falsify the record, so any "no `hivrr` left" check excludes the past packs under
  `docs/plans/`.
- **`bootstrappedRepos` in global settings stores `hivrr/agent-plugins`.** After the move, `init`
  Phase 2 sees `retroboot/agent-plugins` as new and re-creates labels with `--force`, which is
  harmless.
- **The README Setup section and `.env.example` are already wrong**: they describe a GitHub
  Packages registry and `hivrr/manager-plugin`, `hivrr/data-platform-plugin` repos that are not how
  the plugins ship. The rename rewrites them rather than carrying the errors over under a new name.
- **Structural checks hold several of the files this touches.** Check 5 compares `CLAUDE.md`
  plugin descriptions with `marketplace.json`; checks 7 and 10 hold `init`'s phase count; check 8
  reads the `HIVRR_VERIFY_BLOCK` variable, which the bootstrap `verify.test` string in
  `docs/verification.md` exports. The local `.hivrr.json` in this checkout carries that string too
  and is migrated by `init` like any other repo's.
- **Heredoc delimiters come in pairs.** Each opening and closing `HIVRR_*_7f3a` line must change
  together, or the shell runs the rest of a body as commands.

## Route

- **Migration:** renames two contracts that installing repos depend on (the config filename and
  the marketplace name) and moves the repository's home.
- **M — 2–6 slices:** roughly the transfer and remotes; the `init` migration with the config rename
  across every skill, landing together; the marketplace rename and branding prose; the internal
  markers and verification.
- **infra, public-api:** infra for the GitHub transfer and remote changes; public-api because the
  install IDs and the config filename are contracts every installing repo relies on.

## Read order

1. This file, including **How to execute this pack** below
2. [`prd.md`](prd.md): problem, goals, non-goals, stories and acceptance criteria
3. [`context.md`](context.md): what exists today, with file citations, conventions and glossary
4. [`decisions/`](decisions/): the decisions and the options rejected
5. [`design.md`](design.md): architecture, contracts and modifier sections
6. [`inventory.md`](inventory.md): usage sites, or behaviour inventory and parity
7. [`plan.md`](plan.md): the slices, their order and acceptance criteria per slice
8. `progress/`: one file per slice once execution starts
9. [`cold-read.md`](cold-read.md): results of the cold-read review of this pack

## How to execute this pack

These rules are the same in every pack. They live here so an executor needs nothing but this
folder and the repository.

1. **Work one slice at a time.** A slice is one issue and one PR. Its issue body carries a line
   `Plan: docs/plans/move-to-retroboot · Slice: N`.
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

None.

## Retro

_Written by the final slice. Guidance: compare what the cold read predicted with what really
diverged, using the deviations in every progress file._

| Cold read predicted | What diverged | Slice | Lesson for the next pack |
|---|---|---|---|

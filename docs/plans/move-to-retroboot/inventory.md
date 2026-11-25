# Inventory

Every place that uses what this pack migrates, from `git grep -n -i hivrr -- . ':!docs/plans'` at
commit `749feb9` (2026-11-25), plus the non-`hivrr` sites the Brief changes. "Reads the new name
only" breaks a repository `init` has not migrated, which ADR-004 makes the first run's job. The
Slice column names the slice that covers each site.

Outside the tree: the `origin` remote (`hivrr/agent-plugins`), each user's marketplace registration
(`hivrr-agent-plugins`), the GitHub collaborators and the `CLAUDE_CODE_OAUTH_TOKEN` repository
secret (`context.md` §1). Each is handled by the transfer and switch steps of prd S-01 and S-02.

## Usage sites

| path:line | Usage | Breaking change | Slice |
|---|---|---|---|
| `.claude-plugin/marketplace.json:2` | marketplace `name`, the suffix of every install ID | yes: every install ID changes; each user re-adds the marketplace once (ADR-002, ADR-003) | 5 |
| `.claude-plugin/marketplace.json:4` | `owner.name` `hivrr` | no | 5 |
| `.claude-plugin/marketplace.json:7` | `metadata.description` "Hivrr Agent Plugin …" | no: check 5 does not read it (`context.md` §1) | 5 |
| `.claude-plugin/marketplace.json:8` | `metadata.version` `1.6.0`, no hivrr string | no: bumped to `2.0.0` (ADR-008) | 5 |
| `.env.example:1` | header `hivrr-agent-plugin configuration` | no | 5 |
| `.env.example:4-6` | GitHub Packages `GITHUB_TOKEN` comment, no hivrr string | no: dropped (prd S-02.3) | 5 |
| `.gitignore:10` | ignore line `.hivrr.json` | yes: until swapped, a new `.agent-plugins.json` in this repo would be untracked and unignored | 2 |
| `.github/workflows/claude.yml:37` | uses `secrets.CLAUDE_CODE_OAUTH_TOKEN`, no hivrr string | no: file deleted (ADR-009) | 1 |
| `.github/workflows/claude-code-review.yml:40` | uses `secrets.CLAUDE_CODE_OAUTH_TOKEN`, no hivrr string | no: file deleted (ADR-009) | 1 |
| `CLAUDE.md:3` | title `# Hivrr Claude Plugin` | no | 4 |
| `CLAUDE.md:140, 145, 149, 157, 165, 170, 174, 190, 209, 215` | names the config file in project instructions agents act on | yes: agents in this repo would look for the old file | 2 |
| `CLAUDE.md:215, 217` | names `HIVRR_VERIFY_BLOCK` | no: prose; must match `docs/verification.md` | 3 |
| `README.md:1, 3, 92, 144` | title, intro, `"owner": "hivrr"` example, GitHub Packages sentence | no | 2 (92), 4 (1, 3), 5 (144) |
| `README.md:29, 76, 78, 128, 170, 172` | names the config file in the `init` row, Configuration and Verification | no: docs; wrong name misleads users | 2 |
| `README.md:149, 150, 151` | Setup lists `hivrr/agent-plugin`, `hivrr/manager-plugin`, `hivrr/data-platform-plugin` | no: already wrong; rewritten (prd S-02.3) | 5 |
| `RELEASE-NOTES.md:16, 53` | past entries naming `.hivrr.json` | no: kept as history (ADR-007) | 5 (kept unchanged, ADR-007; S-07.2 allowed file) |
| `docs/verification.md:6, 226, 267, 269, 273` | names the config file that holds `verify.test` | no: docs | 2 |
| `docs/verification.md:96, 97, 101` | check 8 tests and counts `HIVRR_VERIFY_BLOCK` | yes: a loader exporting the other name makes check 8 report `CHECK COUNT UNCHECKED` | 3 |
| `docs/verification.md:277` | bootstrap `verify.test` string exporting `HIVRR_VERIFY_BLOCK` | yes: must change with lines 96-101; local copies are replaced by hand (prd S-06.4) | 3 |
| `skills/audit/SKILL.md:129, 131, 136` | `HIVRR_BODY_7f3a` heredoc pair and prose | yes: a half-renamed pair runs body text as shell | 3 |
| `skills/core/SKILL.md:3, 8` | description and heading "Hivrr Core Philosophy" | no | 4 |
| `skills/core/SKILL.md:29` | protected set read from the config file | yes: reads the new name only | 2 |
| `skills/core/SKILL.md:92, 94, 99, 100` | `HIVRR_COMMIT_7f3a` pair and prose naming both markers | yes: a half-renamed pair runs body text as shell | 3 |
| `skills/init/SKILL.md:3, 14` | description and phase-contract wording name the config file | no | 2 (14), 4 (3) |
| `skills/init/SKILL.md:113, 125, 131, 134, 135, 136, 167, 172` | Phase 3 heading, existence test, validation, emits and scaffold | yes: gains the migration (ADR-004, ADR-005); keeps `.hivrr.json` only in the migration step | 2 |
| `skills/init/SKILL.md:184, 228, 230` | Phase 4 reads and writes `verify.*` | yes: reads the new name only | 2 |
| `skills/init/SKILL.md:241` | Phase 5 skips when `project` is absent | yes: reads the new name only | 2 |
| `skills/init/SKILL.md:261, 263, 273, 276, 286, 289, 292, 299, 305, 310, 322, 327, 332, 352, 353, 354` | Phase 6 ignore check, append, untrack, protected-set read, commit and emits | yes: swaps the `.gitignore` line and untracks a still-tracked `.hivrr.json` (prd S-05) | 2 |
| `skills/init/SKILL.md:360` | Phase 7 skips when `worktree` is absent | yes: reads the new name only | 2 |
| `skills/init/references/config.md:1, 3, 7, 18, 108, 191, 205, 273, 276, 290, 298, 305, 331, 333, 335, 340, 350, 425, 430, 441, 460` | schema, read steps, failure modes and scaffolding name the config file | no: reference; may also document the migration (allowed by prd S-07.2) | 2 |
| `skills/init/references/config.md:42` | schema example `"owner": "hivrr"` | no | 2 |
| `skills/init/references/git-hygiene.md:3, 10, 12, 16, 41` | Phase 6 reasoning and pathspec example | no: reference | 2 |
| `skills/init/references/verify.md:13, 16, 31` | reads `verify.test` and `verify.lint` | yes: reads the new name only | 2 |
| `skills/merge-pr/SKILL.md:52, 109, 171, 312, 337` | protected set, ladder, manual jobs, project and worktree gates | yes: reads the new name only | 2 |
| `skills/merge-pr/references/board.md:3` | board gate on `project` | yes: reads the new name only | 2 |
| `skills/merge-pr/references/cleanup.md:6, 23, 100` | worktree gates | yes: reads the new name only | 2 |
| `skills/planning/SKILL.md:368` | integration-branch resolution | yes: reads the new name only | 2 |
| `skills/planning/references/publish.md:17` | `HIVRR_BODY_7f3a` in a prose example | no: prose; must match the session references | 3 |
| `skills/planning/references/publish.md:134` | board gate on `project` | yes: reads the new name only | 2 |
| `skills/planning/references/roles/dispatch.md:66` | `{base}` resolution for `spec`, `slice`, `brainstorm` | yes: reads the new name only; unmigrated repos fall back (ADR-002) | 2 |
| `skills/planning/references/roles/test-engineer.md:33` | example of git-ignored config | no | 2 |
| `skills/promote/SKILL.md:39, 202` | ladder and `ci.optionalManualJobs` reads | yes: reads the new name only | 2 |
| `skills/promote/SKILL.md:153, 157, 159` | `HIVRR_BODY_7f3a` prose and heredoc pair | yes: a half-renamed pair runs body text as shell | 3 |
| `skills/review-pr/SKILL.md:252` | `HIVRR_BODY_7f3a` in a stdin heredoc | yes: opener and closer are on this one line's instruction | 3 |
| `skills/session/SKILL.md:19, 25, 31, 35` | Phase 1 reads the config file first | yes: reads the new name only | 2 |
| `skills/session/references/github.md:14, 16, 19, 264, 266` | `HIVRR_BODY_7f3a` pairs and prose | yes: a half-renamed pair runs body text as shell | 3 |
| `skills/session/references/github.md:222, 275` | hierarchy gate and `{base}` resolution | yes: reads the new name only | 2 |
| `skills/session/references/gitlab.md:18, 20, 23, 108, 110` | `HIVRR_BODY_7f3a` pairs and prose | yes: a half-renamed pair runs body text as shell | 3 |
| `skills/session/references/gitlab.md:119` | `{base}` resolution | yes: reads the new name only | 2 |
| `skills/session/references/linear.md:32` | `HIVRR_BODY_7f3a` named in prose | no: prose | 3 |
| `skills/ship-issue/SKILL.md:69` | integration-branch resolution | yes: reads the new name only | 2 |
| `skills/wave/SKILL.md:44, 51` | integration branch and worktree reads | yes: reads the new name only | 2 |
| `skills/work-issue/SKILL.md:163, 175, 211, 342` | worktree, integration-branch and project reads | yes: reads the new name only | 2 |
| `skills/work-issue/references/hierarchy.md:3` | gate on `issues.hierarchy` | yes: reads the new name only | 2 |
| `skills/work-issue/references/worktree.md:3, 21` | worktree gate and warning string | yes: reads the new name only | 2 |

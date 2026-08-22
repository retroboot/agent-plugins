# GitHub Reference

All operations use the `gh` CLI.

Variables: `{OWNER}` = repo owner, `{REPO}` = repo name, `{N}` = issue or PR number, `{B}` = body text, `{T}` = title.

---

## Issues

**List**
```
gh issue list --repo {OWNER}/{REPO} --state open --json number,title,labels,state
```

**Get**
```
gh issue view {N} --repo {OWNER}/{REPO} --json number,title,body,labels,state
```

**Always pass `--json`.** A bare `gh issue view {N}` renders the human-readable view, which on
`gh` 2.45.0 queries the sunset Projects (classic) `projectCards` field and fails outright:

```
GraphQL: Projects (classic) is being deprecated in favor of the new Projects experience.
```

The `--json` form takes a different code path and works on every version. Never drop the flag to
"just look at" an issue — the failure names GraphQL and Projects and gives no hint that the real
cause is the `gh` version.

**Create**
```
gh issue create --repo {OWNER}/{REPO} --title "{T}" --body "{B}" --label "{labels}"
```

Use labels from the label reference loaded by init. Pick one or more that fit the issue type and priority.

**Close**
```
gh issue close {N} --repo {OWNER}/{REPO}
```

---

## Pull Requests

**Get diff**
```
gh pr diff {N} --repo {OWNER}/{REPO}
```

**View PR**
```
gh pr view {N} --repo {OWNER}/{REPO} --json title,body,headRefName,state,baseRefName,reviews
```

**PR conversation thread** (issue-style comments, not inline diff comments)
```
gh api repos/{OWNER}/{REPO}/issues/{N}/comments
```

**Post comment**
```
gh pr comment {N} --repo {OWNER}/{REPO} --body "{B}"
```

**Create PR**
```
gh pr create --repo {OWNER}/{REPO} --title "{T}" --body "{B}" --base {base}
```

`--base` is **required**, not optional. Without it `gh` silently targets the repository default branch — which on a ladder repo means aiming a feature PR at production. Resolve `{base}` from `branches.integration` in `.hivrr.json`, falling back to the repo default branch.

**Edit a PR's title or body**
```
gh api --method PATCH repos/{OWNER}/{REPO}/pulls/{N} -f title="{T}" -f body="{B}"
```

**Use this rather than `gh pr edit`.** On `gh` 2.45.0 `gh pr edit` fails the same way a bare
`gh issue view` does — it queries the sunset Projects (classic) `projectCards` field:

```
GraphQL: Projects (classic) is being deprecated in favor of the new Projects experience.
See https://github.blog/changelog/... (repository.pullRequest.projectCards)
```

Upgrading `gh` is the real fix; the field was dropped from these code paths in later releases. The
`gh api` form above is version-independent, so it is what this reference specifies. Hit twice while
preparing #128, where the PR title and body had to be set this way.

**Merge PR** (squash)
```
gh pr merge {N} --repo {OWNER}/{REPO} --squash --delete-branch
```

Apply the branch-deletion safety rules in `merge-pr/SKILL.md` before passing `--delete-branch`.

**Check CI**
```
gh pr checks {N} --repo {OWNER}/{REPO}
```

**Latest commit timestamp**
```
gh pr view {N} --repo {OWNER}/{REPO} --json commits --jq '.commits[-1].committedDate'
```

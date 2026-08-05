# GitLab Reference

All operations use the `glab` CLI.

**Terminology:** MR (Merge Request) = PR. Issues and MRs use `iid` (project-scoped internal ID), not a global number. Branch fields are `source_branch` / `target_branch` (snake_case from the raw API).

Variables: `{PROJECT}` = `group/project` path, `{PROJECT_ENCODED}` = `group%2Fproject`, `{N}` = issue iid or MR iid, `{B}` = body/description, `{T}` = title.

---

## Issues

**List**
```
glab issue list --repo {PROJECT}
```

**Get**
```
glab issue view {N} --repo {PROJECT}
```

**Create**
```
glab issue create --repo {PROJECT} --title "{T}" --description "{B}" --label "{labels}"
```

Use labels from the label reference loaded by init. Pick one or more that fit the issue type and priority.

**Close**
```
glab issue close {N} --repo {PROJECT}
```

---

## Merge Requests

**Get diff**
```
glab mr diff {N} --repo {PROJECT}
```

**View MR**
```
glab api projects/{PROJECT_ENCODED}/merge_requests/{N}
     (glab mr view lacks --output json in older versions)
```

**MR discussion notes** (conversation thread)
```
glab api projects/{PROJECT_ENCODED}/merge_requests/{N}/notes
```

**Post comment**
```
glab mr comment {N} --repo {PROJECT} --message "{B}"
```

**Create MR**
```
glab mr create --repo {PROJECT} --title "{T}" --description "{B}" --target-branch {base}
```

`--target-branch` is **required**, not optional — without it `glab` targets the project's default branch. Resolve `{base}` from `branches.integration` in `.hivrr.json`, falling back to the default branch.

**Merge MR** (squash)
```
glab mr merge {N} --repo {PROJECT} --squash --remove-source-branch
```

Apply the branch-deletion safety rules in `merge-pr/SKILL.md` before passing `--remove-source-branch`.

**Check CI**
```
glab api projects/{PROJECT_ENCODED}/merge_requests/{N}/pipelines | jq -r '.[0].status // "none"'
     # Returns: "success" | "failed" | "canceled" | "running" | "pending" | "none" (no pipeline)
```

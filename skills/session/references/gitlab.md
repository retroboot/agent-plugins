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
glab issue create --repo {PROJECT} --title "{T}" --description "$(cat {file})" --label "{labels}"
```

Write the description to `{file}` first, outside the checkout (`mktemp`), with a single-quoted heredoc (`cat > {file} <<'EOF'`).
The output of `$(cat …)` is not expanded again, so backticks in it survive; a literal `"{B}"` would
run them as command substitutions.

Use labels from the label reference loaded by init. Pick one or more that fit the issue type and priority.

**Edit** (replace an issue's description)
```
glab issue update {N} --repo {PROJECT} --description "$(cat {file})"
```

The description comes from `{file}`, written as for **Create**.

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

---

## Sub-Issues

**Not supported.** GitLab has no free-tier equivalent of GitHub sub-issues; the nearest analogue
is Premium-tier epics, which have a different data model and are out of scope.

When the resolved provider is `gitlab`, treat `issues.hierarchy` as `false` regardless of its
configured value. Every hierarchy operation is a silent no-op, and skills that consume hierarchy
fall back to their documented pre-hierarchy behavior — parsing `Depends on #N` and `Part of #N`
from issue bodies (see `ship-issue`).

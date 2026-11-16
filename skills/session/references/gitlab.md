# GitLab Reference

All operations use the `glab` CLI.

**Terminology:** MR (Merge Request) = PR. Issues and MRs use `iid` (project-scoped internal ID), not a global number. Branch fields are `source_branch` / `target_branch` (snake_case from the raw API).

Variables: `{PROJECT}` = `group/project` path, `{PROJECT_ENCODED}` = `group%2Fproject`, `{N}` = issue iid or MR iid, `{T}` = title, `{file}` = a file holding the body/description text.

**Bodies always go through a file.** Never pass a description or comment inline: in
`--description "…"` or `--message "…"` the shell runs every backticked span and every `$(…)` as a
command substitution, and every issue, MR and comment body these skills write holds backticks.
Write the body to `{file}` first, outside the checkout (`mktemp`), with a single-quoted heredoc,
then pass it as `"$(cat {file})"`. The output of `$(cat …)` is not expanded again, so backticks in
it survive.

```
file=$(mktemp)
cat > "$file" <<'HIVRR_BODY_7f3a'
…body text, verbatim…
HIVRR_BODY_7f3a
```

The delimiter is `HIVRR_BODY_7f3a`, not `EOF`: a body that quotes one of these snippets holds a line `EOF`,
which would end the heredoc early and run the rest of the body as shell commands. If the body
contains a line equal to the delimiter, choose another. Remove the file once the command has run;
each command below ends with `rm -f {file}`.

**Titles stay inline, so a title must be safe in double quotes.** Drop any backtick, `$`, `"` or
`\` from `{T}` before substituting it into `--title "{T}"`. A title is one line of prose, so this
costs nothing, and `planning` builds its Publish titles by the same rule.

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
glab issue create --repo {PROJECT} --title "{T}" --description "$(cat "{file}")" --label "{labels}"
rm -f "{file}"
```

The description comes from `{file}`, written as **Bodies always go through a file** says above.

Use labels from the label reference loaded by init. Pick one or more that fit the issue type and priority.

**Edit** (replace an issue's description)
```
glab issue update {N} --repo {PROJECT} --description "$(cat "{file}")"
rm -f "{file}"
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
glab mr comment {N} --repo {PROJECT} --message "$(cat "{file}")"
rm -f "{file}"
```

The comment comes from `{file}`, as for every body. **A caller that may not write files** —
`review-pr` is read-only — posts through the notes API instead, with the body on stdin from the
same single-quoted heredoc and no scratch file: `-F body=@-` reads standard input.

```
glab api --method POST projects/{PROJECT_ENCODED}/merge_requests/{N}/notes -F body=@- <<'HIVRR_BODY_7f3a'
…body text, verbatim…
HIVRR_BODY_7f3a
```

**Create MR**
```
glab mr create --repo {PROJECT} --title "{T}" --description "$(cat "{file}")" --target-branch {base}
rm -f "{file}"
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

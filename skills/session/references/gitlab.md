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

**Check CI** — two calls: the MR's latest pipeline, then every job in it.

```
glab api projects/{PROJECT_ENCODED}/merge_requests/{N}/pipelines | jq -r '.[0] | if . == null then "none" else "\(.id) \(.status)" end'
     # Returns: "{PIPELINE_ID} {STATUS}", or "none" when the MR has no pipeline
```

Unless that printed `none`, list the pipeline's jobs, trigger jobs (`/bridges`) included, and classify them:

```
{ glab api --paginate "projects/{PROJECT_ENCODED}/pipelines/{PIPELINE_ID}/jobs?per_page=100"
  glab api --paginate "projects/{PROJECT_ENCODED}/pipelines/{PIPELINE_ID}/bridges?per_page=100"
} | jq -s -r --arg pipeline '{STATUS}' '
  map(if type == "array" then .[] else error("not a job list: \(tostring)") end)
  | (if length > 0 and ($pipeline == "success" or $pipeline == "skipped") then empty
     else {name: "(pipeline)", status: $pipeline, class: (
       if $pipeline == "failed" or $pipeline == "canceled" then "failed"
       elif $pipeline == "manual" then "manual" else "unfinished" end)} end),
    (.[] | {name, status, class: (.status as $s
       | if $s == "success" or $s == "skipped" or ($s == "failed" and .allow_failure) then "passed"
         elif $s == "failed" or $s == "canceled" or $s == "canceling" then "failed"
         elif $s == "manual" or ($s == "created" and ($pipeline == "success" or $pipeline == "manual")) then "manual"
         else "unfinished" end)}
     | select(.class != "passed"))
  | "\(.class)\t\(.name)\t\(.status)"'
     # Prints one "{class}<TAB>{name}<TAB>{status}" line per job that is not finished and passing;
     # no output means every job passed. {class} is failed | unfinished | manual.
```

The pipeline status alone is not enough: a `manual` job with `allow_failure: true` that nobody
played leaves the pipeline `success`, which is how unsigned bundles once merged. So:

- **`manual`** — a job waiting to be played. A job still `created` in a pipeline at rest (`success`
  or `manual`) is waiting behind one, so it is reported as `manual` too.
- **`unfinished`** — `created`, `pending`, `running`, `preparing`, `waiting_for_resource`,
  `scheduled` (a delayed job), and any status not listed here.
- **`failed`** — `failed` without `allow_failure`, `canceled`, `canceling`. A failed job with
  `allow_failure: true` already lets the pipeline pass, and passes here.
- **`(pipeline)`** — a row for the pipeline itself whenever its status is not `success` or
  `skipped`, or no jobs came back. It fails closed: a `running` pipeline whose listed jobs all
  passed is still unfinished, a `manual` (blocked) pipeline is still manual, and a failed job
  fetch never reads as a clean pipeline. A non-JSON error body stops `jq` with `not a job list`.

`/jobs` omits retried attempts by default, so a job retried to success reads as passed.

---

## Sub-Issues

**Not supported.** GitLab has no free-tier equivalent of GitHub sub-issues; the nearest analogue
is Premium-tier epics, which have a different data model and are out of scope.

When the resolved provider is `gitlab`, treat `issues.hierarchy` as `false` regardless of its
configured value. Every hierarchy operation is a silent no-op, and skills that consume hierarchy
fall back to their documented pre-hierarchy behavior — parsing `Depends on #N` and `Part of #N`
from issue bodies (see `ship-issue`).

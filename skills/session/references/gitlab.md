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
cat > "$file" <<'AGENT_PLUGINS_BODY_7f3a'
…body text, verbatim…
AGENT_PLUGINS_BODY_7f3a
```

The delimiter is `AGENT_PLUGINS_BODY_7f3a`, not `EOF`: a body that quotes one of these snippets holds a line `EOF`,
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

**Find open MR for a branch**
```
glab api "projects/{PROJECT_ENCODED}/merge_requests?state=opened&source_branch={branch}" | jq '[.[] | {number: .iid, url: .web_url}]'
```

Returns a JSON array: `[]` when the branch has no open MR, otherwise one `{number, url}` per open MR.
Skills call this **Find open PR for a branch**; the MR is the same thing.

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
glab api --method POST projects/{PROJECT_ENCODED}/merge_requests/{N}/notes -F body=@- <<'AGENT_PLUGINS_BODY_7f3a'
…body text, verbatim…
AGENT_PLUGINS_BODY_7f3a
```

**Create MR**
```
glab mr create --repo {PROJECT} --title "{T}" --description "$(cat "{file}")" --target-branch {base}
rm -f "{file}"
```

`--target-branch` is **required**, not optional — without it `glab` targets the project's default branch. Resolve `{base}` from `branches.integration` in `.agent-plugins.json`, falling back to the default branch.

**Merge MR** (squash)
```
glab mr merge {N} --repo {PROJECT} --squash --remove-source-branch
```

Apply the branch-deletion safety rules in `merge-pr/SKILL.md` before passing `--remove-source-branch`.

**Check CI** — three calls, run in order, because the second and third need the first's output:
the MR's latest pipeline, then its jobs, then its trigger jobs (`/bridges`). Each starts with
`glab` and pipes only into `jq`, so a skill granted `Bash(glab:*)` and `Bash(jq:*)` can run all
three; `review-pr` runs them as dependent steps rather than in parallel with its other fetches.

```
glab api projects/{PROJECT_ENCODED}/merge_requests/{N}/pipelines | jq -r '.[0] | if . == null then "none" else "\(.id) \(.status)" end'
     # Returns: "{PIPELINE_ID} {STATUS}", or "none" when the MR has no pipeline
```

Unless that printed `none`, classify the pipeline's jobs:

```
glab api --paginate "projects/{PROJECT_ENCODED}/pipelines/{PIPELINE_ID}/jobs?per_page=100" | jq -s -r --arg pipeline '{STATUS}' '
  map(if type == "array" then .[] else error("not a job list: \(tostring)") end)
  | if length == 0 then "unknown\t(no jobs returned)\t\($pipeline)" else
      ((if $pipeline == "success" or $pipeline == "skipped" then empty
        else {name: "(pipeline)", status: $pipeline, class: (
          if $pipeline == "failed" or $pipeline == "canceled" then "failed"
          elif $pipeline == "manual" then "manual" else "unfinished" end)} end),
       (.[] | {name, status, class: (.status as $s
          | if $s == "success" or $s == "skipped" or ($s == "failed" and .allow_failure) then "passed"
            elif $s == "failed" or $s == "canceled" or $s == "canceling" then "failed"
            elif $s == "manual" or ($s == "created" and ($pipeline == "success" or $pipeline == "manual")) then "manual"
            else "unfinished" end)}
        | select(.class != "passed")))
      | "\(.class)\t\(.name)\t\(.status)" end'
     # Prints one "{class}<TAB>{name}<TAB>{status}" line per job that has not passed;
     # no output means every job passed. {class} is failed | unfinished | manual | unknown.
```

Then classify its trigger jobs the same way. An empty list is normal here — most pipelines trigger
nothing — so this call prints no `unknown` or `(pipeline)` row:

```
glab api --paginate "projects/{PROJECT_ENCODED}/pipelines/{PIPELINE_ID}/bridges?per_page=100" | jq -s -r --arg pipeline '{STATUS}' '
  map(if type == "array" then .[] else error("not a job list: \(tostring)") end)
  | .[] | {name, status, class: (.status as $s
      | if $s == "success" or $s == "skipped" or ($s == "failed" and .allow_failure) then "passed"
        elif $s == "failed" or $s == "canceled" or $s == "canceling" then "failed"
        elif $s == "manual" or ($s == "created" and ($pipeline == "success" or $pipeline == "manual")) then "manual"
        else "unfinished" end)}
  | select(.class != "passed") | "\(.class)\t\(.name)\t\(.status)"'
```

The pipeline status alone is not enough: a `manual` job with `allow_failure: true` that nobody
played leaves the pipeline `success`, which is how unsigned bundles once merged. So:

- **`manual`** — a job waiting to be played. A job still `created` in a pipeline at rest (`success`
  or `manual`) is waiting behind one, so it is reported as `manual` too.
- **`unfinished`** — `created`, `pending`, `running`, `preparing`, `waiting_for_resource`,
  `scheduled` (a delayed job), and any status not listed here.
- **`failed`** — `failed` without `allow_failure`, `canceled`, `canceling`. A failed job with
  `allow_failure: true` already lets the pipeline pass, and passes here.
- **`unknown`** — the jobs call returned no jobs, so nothing was checked. A pipeline always has at
  least one job, so this means the fetch failed; it is never a pass.
- **`(pipeline)`** — a row for the pipeline itself whenever its status is not `success` or
  `skipped`. It fails closed: a `running` pipeline whose listed jobs all passed is still
  unfinished, and a `manual` (blocked) pipeline is still manual.

Each call is classified on its own, so a failed jobs fetch cannot hide behind trigger jobs that came
back. A non-JSON error body stops `jq` with `not a job list`, and an error `glab` prints on either
call is a stop, not an empty list — read stderr before trusting silence.

`/jobs` omits retried attempts by default, so a job retried to success reads as passed.

**Child pipelines are not inspected.** A trigger job reports its own status, not its child's. With
`trigger: strategy: depend` the trigger job mirrors the child pipeline, so an unplayed manual job
in the child keeps the parent from reading as passed. Without it, the trigger job succeeds once the
child is created, and a manual job inside the child is invisible here. Use `strategy: depend` on
any trigger whose child holds a job that must run before merge.

---

## Sub-Issues

**Not supported.** GitLab has no free-tier equivalent of GitHub sub-issues; the nearest analogue
is Premium-tier epics, which have a different data model and are out of scope.

When the resolved provider is `gitlab`, treat `issues.hierarchy` as `false` regardless of its
configured value. Every hierarchy operation is a silent no-op, and skills that consume hierarchy
fall back to their documented pre-hierarchy behavior — parsing `Depends on #N` and `Part of #N`
from issue bodies (see `ship-issue`).

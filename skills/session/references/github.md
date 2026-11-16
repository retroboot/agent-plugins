# GitHub Reference

All operations use the `gh` CLI.

Variables: `{OWNER}` = repo owner, `{REPO}` = repo name, `{N}` = issue or PR number, `{T}` = title, `{file}` = a file holding the body text.

**Bodies always go through a file.** Never pass a body's text inline: in `--body "…"` or
`-f body="…"` the shell runs every backticked span and every `$(…)` as a command substitution, and
every issue, PR and comment body these skills write holds backticks. Write the body to `{file}`
first, outside the checkout (`mktemp`), with a single-quoted heredoc, then pass the file:

```
file=$(mktemp)
cat > "$file" <<'EOF'
…body text, verbatim…
EOF
```

**Titles stay inline, so a title must be safe in double quotes.** Drop any backtick, `$`, `"` or
`\` from `{T}` before substituting it into `--title "{T}"` or `-f title="{T}"`. A title is one line
of prose, so this costs nothing, and `planning` builds its Publish titles by the same rule.

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
gh issue create --repo {OWNER}/{REPO} --title "{T}" --body-file {file} --label "{labels}"
```

The body comes from `{file}`, written as **Bodies always go through a file** says above.

Use labels from the label reference loaded by init. Pick one or more that fit the issue type and priority.

**Edit** (replace an issue's body)
```
gh api --method PATCH repos/{OWNER}/{REPO}/issues/{N} -F body=@{file}
```

The body comes from `{file}`, written as for **Create**; `-F body=@{file}` reads it verbatim.

Use this rather than `gh issue edit`, for the same reason as **Edit a PR's title or body** below:
the `gh api` form is version-independent.

**Close**
```
gh issue close {N} --repo {OWNER}/{REPO}
```

---

## Sub-Issues

`gh` has **no** first-class support for sub-issues — there is no `gh issue` subcommand, no
`--parent` flag on `gh issue create`, and `parent`/`subIssues` are absent from the
`gh issue view --json` field list. Every operation here is `gh api`.

**GraphQL is the canonical path.** It resolves every identifier in one query and returns the
updated summary from each mutation, so a successful call is self-verifying. REST is documented at
the end as a fallback.

### The three identifiers

One issue carries three. Using the wrong one is the most common failure here:

| Kind | Example | Used by |
|---|---|---|
| number | `126` | `gh issue` commands, issue bodies |
| `databaseId` | `5218577347` | REST `sub_issue_id`, `before_id`, `after_id` |
| node `id` | `I_kwDORlvmmc8AAAABNw0r_g` | GraphQL `issueId`, `subIssueId` |

Passing a **number** where REST wants a `databaseId` returns a bare `404 Not Found` — it does not
say the identifier was the wrong kind. The GraphQL path avoids `databaseId` entirely.

### Resolve node IDs

Resolve every issue you intend to link in **one** query using aliases, rather than one query per
issue:

```
gh api graphql -f query='
  query($o:String!,$r:String!,$p:Int!,$c:Int!){
    repository(owner:$o,name:$r){
      parent: issue(number:$p){ id }
      child:  issue(number:$c){ id }
    } }' -f o={OWNER} -f r={REPO} -F p={PARENT} -F c={CHILD}
```

### Read hierarchy

```
gh api graphql -f query='
  query($o:String!,$r:String!,$n:Int!){
    repository(owner:$o,name:$r){
      issue(number:$n){
        parent { number title state }
        subIssues(first:100){ totalCount nodes{ number title state } }
        subIssuesSummary { total completed percentCompleted }
      } } }' -f o={OWNER} -f r={REPO} -F n={N}
```

`parent` is `null` for a top-level issue. `subIssuesSummary.total` is `0` for a leaf.
These two facts are how every consumer distinguishes an epic from a workable issue.

**`subIssues` is capped at 100.** Compare `totalCount` against the length of `nodes`; if they
differ, the list is truncated — page with `after`, or warn and say the list is partial. Never treat
the short list as complete. This is the same trap `gh project item-list` sets with its default of
30, documented in [`config.md`](../../init/references/config.md), and it fails the same way: silently,
looking exactly like an issue that was never a child.

### Link a child to a parent

**Check first — this is not idempotent.** Re-adding an already-linked child returns `422`
(`Issue may not contain duplicate sub-issues and Sub issue may only have one parent`), unlike
`gh project item-add`, which is safe to repeat. Assuming idempotence produces spurious failures on
every resume path.

**Linking is three calls, in this order.**

**1 — Read the child's current parent.** Use this minimal query rather than **Read hierarchy**; the
children list and summary are not needed here:

```
gh api graphql -f query='
  query($o:String!,$r:String!,$n:Int!){
    repository(owner:$o,name:$r){ issue(number:$n){ parent { number } } } }' \
  -f o={OWNER} -f r={REPO} -F n={CHILD}
```

**2 — Branch on the result.** Only the first case continues to step 3:

- `parent` is `null` → not linked. Continue.
- `parent.number` is already the intended parent → **already linked, skip.** Not an error, and the
  normal outcome on a resumed run.
- `parent.number` is a *different* issue → warn and skip. A sub-issue has exactly one parent;
  re-parenting is an explicit remove-then-add, never an implicit overwrite.

**3 — Resolve both node IDs** with **Resolve node IDs** above, then mutate:

```
gh api graphql -f query='
  mutation($p:ID!,$c:ID!){
    addSubIssue(input:{issueId:$p, subIssueId:$c}){
      issue { number subIssuesSummary { total completed } }
      subIssue { number title }
    } }' -f p={PARENT_NODE_ID} -f c={CHILD_NODE_ID}
```

The response names both issues and the updated summary — use it as the confirmation. Do not
re-query to verify.

Linking several children to one parent: do step 1 per child, then **one** aliased **Resolve node
IDs** query covering the parent and every child that reached step 3, then one mutation each.

### Unlink a child

```
gh api graphql -f query='
  mutation($p:ID!,$c:ID!){
    removeSubIssue(input:{issueId:$p, subIssueId:$c}){
      issue { number subIssuesSummary { total completed } }
    } }' -f p={PARENT_NODE_ID} -f c={CHILD_NODE_ID}
```

### Reorder children

`reprioritizeSubIssue` moves one child relative to another. Order is display-only — it does not
imply dependency, and no skill should read it as one.

### Closing behavior

**Closing every child does not close the parent.** Verified: with both children closed the parent
reported `{total:2, completed:2, percentCompleted:100}` and remained `state: OPEN` with
`stateReason: null`. The rollup is a display value; nothing acts on it. A skill that wants the
parent closed must close it explicitly with the **Close** command in `## Issues` above.

### REST fallback

Use only when GraphQL is unavailable. These take `databaseId`, not numbers:

```
gh api repos/{OWNER}/{REPO}/issues/{N}/sub_issues                                  # list
gh api --method POST repos/{OWNER}/{REPO}/issues/{N}/sub_issues -F sub_issue_id={DB_ID}
gh api --method DELETE repos/{OWNER}/{REPO}/issues/{N}/sub_issue -F sub_issue_id={DB_ID}
```

Note the asymmetry: `GET`/`POST` use plural `sub_issues`; `DELETE` uses **singular** `sub_issue`.
A typo there returns the same bare `404` as a wrong identifier. `POST` returns the **parent**
issue, not the child, so it cannot confirm which child was linked.

### Gating

Every operation in this section is gated on `issues.hierarchy` in `.hivrr.json`. When it is
`false` or absent, these commands are **not run at all** and the calling skill continues silently.
Every failure here warns and continues — hierarchy is a reporting surface, and the issue or PR is
the deliverable.

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
gh pr comment {N} --repo {OWNER}/{REPO} --body-file {file}
```

The body comes from `{file}`, as for every body. **A caller that may not write files** — `review-pr`
is read-only — passes the body on stdin instead, with the same single-quoted heredoc and no scratch
file: `--body-file -` reads standard input.

```
gh pr comment {N} --repo {OWNER}/{REPO} --body-file - <<'EOF'
…body text, verbatim…
EOF
```

**Create PR**
```
gh pr create --repo {OWNER}/{REPO} --title "{T}" --body-file {file} --base {base}
```

`--base` is **required**, not optional. Without it `gh` silently targets the repository default branch — which on a ladder repo means aiming a feature PR at production. Resolve `{base}` from `branches.integration` in `.hivrr.json`, falling back to the repo default branch.

**Edit a PR's title or body**
```
gh api --method PATCH repos/{OWNER}/{REPO}/pulls/{N} -f title="{T}" -F body=@{file}
```

Drop either field to change only the other. `-F body=@{file}` reads the body verbatim, as in the
issue **Edit** above.

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

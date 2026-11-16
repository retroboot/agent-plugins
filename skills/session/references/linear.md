# Linear Reference

Issue tracker only. For PR/MR operations, use the repo provider reference (github.md or gitlab.md).

All operations use the `linear` CLI.

Variables: `{TEAM}` = team key from `providerConfig.linearTeam` (e.g. `ENG`), `{ID}` = Linear issue identifier (e.g. `ENG-123`), `{T}` = title, `{file}` = a file holding the description text.

**Titles stay inline, so a title must be safe in double quotes.** Drop any backtick, `$`, `"` or
`\` from `{T}` before substituting it into `--title "{T}"`, as `planning` does for its Publish titles.

---

## Issues

**List**
```
linear issue list --team {TEAM}
```

**Get**
```
linear issue view {ID}
```

**Create**
```
linear issue create --team {TEAM} --title "{T}" --description "$(cat {file})"
rm -f {file}
```

Write the description to `{file}` first, outside the checkout (`mktemp`), with a single-quoted heredoc (`cat > {file} <<'HIVRR_BODY_7f3a'`, the delimiter `github.md` and `gitlab.md` explain), so
backticks in it are not run as command substitutions.

**Label**
```
linear issue update {ID} --label "{label}"
```

**Edit** (replace an issue's description)
```
linear issue update {ID} --description "$(cat {file})"
rm -f {file}
```

**Untested:** the `--description` flag on `linear issue update` is assumed from `create`, and has
not been run. Check `linear issue update --help` before relying on it. The description comes from
`{file}`, written as for **Create**.

**Close** (transition to Done state)
```
linear issue update {ID} --state Done
```

---

## Notes

- Linear identifiers follow the pattern `[A-Z]+-[0-9]+` (e.g. `ENG-123`). Include them in PR/MR descriptions to link issues.
- Linear does not support PR/MR operations — branch and merge via the repo provider.
- To list the workflow states for a team: `linear team states --team {TEAM}`.

---

## Sub-Issues

Linear has a **native** parent/sub-issue model. It does not route through the GitHub commands in
`github.md`, and `issues.hierarchy` does not govern it.

Wiring Linear hierarchy into the hierarchy-consuming skills is deliberately out of scope. Until it
is done, treat `issues.hierarchy` as `false` when `ISSUE_TRACKER=linear` so that no skill emits
GitHub-shaped commands against a Linear tracker.

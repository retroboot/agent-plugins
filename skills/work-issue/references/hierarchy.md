# Check for hierarchy

Read this file only when `issues.hierarchy` is enabled in `.hivrr.json` (see
[`config.md`](../../init/references/config.md); it is GitHub-only). `work-issue` Phase 3 sends you
here after fetching the issues. When `issues.hierarchy` is disabled or absent, skip all of it.

Run the **Read hierarchy** command from the loaded reference for each issue and keep all three fields
it returns — they answer different questions:

- `subIssuesSummary.total` — *is this an epic?*
- `subIssues.nodes[].state` — *which children are still open?* The summary cannot answer this; it
  carries counts, not per-child state.
- `subIssues.nodes[].number` — *which children to name and, under `--auto`, to substitute.*

`subIssues` is capped at 100. Compare `totalCount` against the number of nodes returned, and if
they differ, say the child list is partial rather than substituting a truncated set.

If the query fails, warn and continue treating every issue as workable — losing the check degrades
the run, aborting destroys it.

If an issue has `subIssuesSummary.total > 0` with at least one child still open, it is an epic.
Implementing it directly produces one oversized PR that closes a container rather than its
contents. Display:

`Epic: #{number} has {open}/{total} open sub-issues — work those instead: {child_numbers}`

Then stop and ask which children to work, unless `--auto` is set. Under `--auto`, substitute the
**open children** for the epic in `issue_numbers` and continue — do not abort, and do not
implement the epic. Substituting several children for one issue can change the routing decision
made in Phase 2, so re-run that routing on the new list before continuing.

An epic whose children are all closed is workable as an ordinary issue; it is likely a
documentation or wrap-up task.

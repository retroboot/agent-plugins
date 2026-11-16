# Capture follow-up work

The full procedure behind `merge-pr` Phase 10. It runs on every merge, after branch cleanup, and its
result feeds `followup_issues` in the Phase 11 completion JSON.

After merge, collect any unaddressed PR/MR feedback that should become future issues. This prevents
good suggestions from being lost.

Use the **PR conversation thread** command from the loaded reference to fetch the main discussion
thread.

Use the **Latest commit timestamp** command from the loaded reference. Only consider comments whose
`created_at` is after that timestamp — these are the most recent round of feedback posted since the
last push.

Look for:
- Suggestions that were acknowledged but deferred ("will do in a follow-up")
- Ideas that weren't addressed in the PR/MR
- TODO or FIXME comments added during the review
- Any feedback that doesn't have a clear resolution in the thread

**If `--auto` is set:** Create an issue for every unaddressed suggestion automatically using the
**Create issue** command from the loaded reference. Load the label reference from
`$CLAUDE_SKILL_DIR/../init/references/labels.md` and use it to select appropriate labels — label
critical ones `P1` and optional ones `P2`. The philosophy: capture everything now, triage during
implementation.

**If `--auto` is not set:** List the unaddressed suggestions and ask which ones to create issues for.

**If there is no unaddressed feedback:** display "Follow-up: nothing to capture" and skip issue
creation.

For each issue created:
- Title: a clear, actionable summary of the suggestion
- Body: context from the PR/MR comment, link back to the PR/MR

Display: `Follow-up: {count} issues created {issue_numbers.join(', ') || ''}`

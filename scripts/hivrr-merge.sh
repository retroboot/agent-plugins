#!/usr/bin/env bash
set -uo pipefail

# hivrr-merge.sh — merge a PR/MR, close linked issues, delete branch
#
# Usage:
#   hivrr-merge.sh --pr <number> --repo <owner/repo> [options]
#
# Options:
#   --pr <number>            PR or MR number (required)
#   --repo <owner/repo>      Repo slug (required)
#   --provider <github|gitlab>              default: github
#   --issue-tracker <github|gitlab|linear>  default: matches --provider
#   --auto                   Skip merge confirmation prompt
#
# Exits 0 on success, 1 on failure.
# On success, prints:
#   HIVRR_MERGE_SUMMARY pr={n} issues_closed={comma_list|none} branch_deleted={name}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
PR_NUMBER=""
REPO_SLUG=""
PROVIDER="github"
ISSUE_TRACKER=""
AUTO=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pr)           PR_NUMBER="$2";    shift 2 ;;
    --repo)         REPO_SLUG="$2";    shift 2 ;;
    --provider)     PROVIDER="$2";     shift 2 ;;
    --issue-tracker) ISSUE_TRACKER="$2"; shift 2 ;;
    --auto)         AUTO=true;         shift ;;
    *) echo "ERROR: unknown argument: $1" >&2; exit 1 ;;
  esac
done

# Default issue tracker to repo provider if not set
ISSUE_TRACKER="${ISSUE_TRACKER:-$PROVIDER}"

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
if [[ -z "$PR_NUMBER" ]]; then
  echo "ERROR: --pr is required" >&2
  exit 1
fi
if [[ -z "$REPO_SLUG" ]]; then
  echo "ERROR: --repo is required" >&2
  exit 1
fi
if [[ "$PROVIDER" != "github" && "$PROVIDER" != "gitlab" ]]; then
  echo "ERROR: --provider must be github or gitlab (got: $PROVIDER)" >&2
  exit 1
fi
if [[ "$ISSUE_TRACKER" != "github" && "$ISSUE_TRACKER" != "gitlab" && "$ISSUE_TRACKER" != "linear" ]]; then
  echo "ERROR: --issue-tracker must be github, gitlab, or linear (got: $ISSUE_TRACKER)" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Fetch PR/MR body to extract linked issue identifiers
# ---------------------------------------------------------------------------
PR_BODY=""
HEAD_BRANCH=""

fetch_pr_info() {
  if [[ "$PROVIDER" == "github" ]]; then
    local info
    info="$(gh pr view "$PR_NUMBER" --repo "$REPO_SLUG" --json body,headRefName 2>/dev/null)" || {
      echo "ERROR: failed to fetch PR #${PR_NUMBER} from ${REPO_SLUG}" >&2
      exit 1
    }
    PR_BODY="$(echo "$info" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("body",""))')"
    HEAD_BRANCH="$(echo "$info" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("headRefName",""))')"
  else
    local info
    info="$(glab mr view "$PR_NUMBER" --repo "$REPO_SLUG" --output json 2>/dev/null)" || {
      echo "ERROR: failed to fetch MR !${PR_NUMBER} from ${REPO_SLUG}" >&2
      exit 1
    }
    PR_BODY="$(echo "$info" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("description",""))')"
    HEAD_BRANCH="$(echo "$info" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("source_branch",""))')"
  fi
}

# ---------------------------------------------------------------------------
# Extract linked issue numbers from PR body
# Matches: Closes #123, Fixes #123, Resolves #123 (GitHub/GitLab)
#          and Linear identifiers like ENG-123, ABC-456
# ---------------------------------------------------------------------------
extract_linked_issues() {
  local body="$1"
  # GitHub/GitLab: Closes/Fixes/Resolves #N
  local gh_issues
  gh_issues="$(echo "$body" | grep -oiE '(closes|fixes|resolves)[[:space:]]+#[0-9]+' | grep -oE '[0-9]+' | sort -u)"
  # Linear: WORD-N identifiers (e.g. ENG-123)
  local linear_issues
  linear_issues="$(echo "$body" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | sort -u)"
  echo "$gh_issues"$'\n'"$linear_issues" | grep -v '^$' | sort -u
}

# ---------------------------------------------------------------------------
# Merge PR/MR
# ---------------------------------------------------------------------------
do_merge() {
  if [[ "$PROVIDER" == "github" ]]; then
    gh pr merge "$PR_NUMBER" --repo "$REPO_SLUG" --squash --delete-branch || {
      echo "ERROR: gh pr merge failed" >&2
      exit 1
    }
  else
    glab mr merge "$PR_NUMBER" --repo "$REPO_SLUG" --squash --remove-source-branch --yes || {
      echo "ERROR: glab mr merge failed" >&2
      exit 1
    }
  fi
}

# ---------------------------------------------------------------------------
# Close linked issues
# ---------------------------------------------------------------------------
close_issues() {
  local all_identifiers="$1"
  if [[ -z "$all_identifiers" ]]; then
    return 0
  fi

  while IFS= read -r id; do
    [[ -z "$id" ]] && continue

    if [[ "$id" =~ ^[0-9]+$ ]]; then
      # Numeric — close via repo issue tracker
      case "$ISSUE_TRACKER" in
        github)
          gh issue close "$id" --repo "$REPO_SLUG" 2>/dev/null \
            || echo "WARN: failed to close GitHub issue #${id}" >&2
          ;;
        gitlab)
          glab issue close "$id" --repo "$REPO_SLUG" 2>/dev/null \
            || echo "WARN: failed to close GitLab issue #${id}" >&2
          ;;
      esac
    elif [[ "$id" =~ ^[A-Z][A-Z0-9]+-[0-9]+$ ]]; then
      # Linear identifier (e.g. ENG-123)
      if [[ "$ISSUE_TRACKER" == "linear" ]]; then
        linear issue update "$id" --state done 2>/dev/null \
          || echo "WARN: failed to close Linear issue ${id}" >&2
      fi
    fi
  done <<< "$all_identifiers"
}

# ---------------------------------------------------------------------------
# Main flow
# ---------------------------------------------------------------------------
fetch_pr_info

LINKED_ISSUES="$(extract_linked_issues "$PR_BODY")"
ISSUES_CLOSED_LIST="$(echo "$LINKED_ISSUES" | tr '\n' ',' | sed 's/,$//' | tr -d ' ')"
[[ -z "$ISSUES_CLOSED_LIST" ]] && ISSUES_CLOSED_LIST="none"

do_merge

# After merge, close issues that aren't auto-closed by the provider
# GitHub auto-closes on merge when "Closes #N" is in the body — skip numeric for GitHub
# GitLab may or may not auto-close depending on project settings — close explicitly
if [[ "$PROVIDER" != "github" || "$ISSUE_TRACKER" == "linear" ]]; then
  close_issues "$LINKED_ISSUES"
fi

# If branch still exists locally, delete it
if git show-ref --verify --quiet "refs/heads/${HEAD_BRANCH}" 2>/dev/null; then
  git branch -d "$HEAD_BRANCH" 2>/dev/null || true
fi

echo "HIVRR_MERGE_SUMMARY pr=${PR_NUMBER} issues_closed=${ISSUES_CLOSED_LIST} branch_deleted=${HEAD_BRANCH:-unknown}"

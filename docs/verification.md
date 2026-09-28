# Verification

This repo ships no shell scripts — see the script policy in `skills/core/SKILL.md`. Its product is
JSON and Markdown, so verification is structural.

**This file is not documentation of `verify.test` — it *is* `verify.test`.** `.hivrr.json` extracts
the fenced block below at run time and pipes it to `bash`. There is no second copy to keep in sync;
editing a check here changes what runs, immediately.

Skills and commands resolve by different rules, so check them separately — a single `[ -e ]` test
passes on a command entry that has lost its `.md`, and that command then fails to load silently.
Let git enumerate the JSON files rather than listing them, so the check cannot drift from the repo:

```bash
# every JSON file parses
json_files=$(git ls-files '*.json')
if [ -n "$json_files" ]; then
  # unquoted on purpose: word splitting is what passes each path as its own argument
  jq empty $json_files
else
  echo "NO JSON FILES TRACKED"
fi

# every registered skill is a directory holding a SKILL.md
jq -r '.plugins[] | (.skills // [])[]' .claude-plugin/marketplace.json | sort -u \
  | while read -r p; do [ -f "$p/SKILL.md" ] || echo "BAD SKILL $p"; done

# every registered command is an existing .md file
jq -r '.plugins[] | (.commands // [])[]' .claude-plugin/marketplace.json | sort -u \
  | while read -r p; do
      case "$p" in *.md) ;; *) echo "NO .md EXTENSION $p"; continue ;; esac
      [ -f "$p" ] || echo "MISSING $p"
    done

# work-issue and work-pr do not duplicate each other's verify procedure
grep -Fxf skills/work-pr/SKILL.md skills/work-issue/SKILL.md \
  | awk 'length > 60' \
  | grep -vFxf docs/shared-lines-allowlist.txt \
  | grep . && echo "DUPLICATED — extract to a shared reference" || true

# CLAUDE.md plugin descriptions match marketplace.json verbatim
jq -r '.plugins[] | select(.description | endswith(".")) | "DESC TERMINAL PERIOD \(.name)"' \
  .claude-plugin/marketplace.json
jq -r '.plugins[] | "\(.name)\t\(.description)"' .claude-plugin/marketplace.json \
  | while IFS="$(printf '\t')" read -r name desc; do
      grep -qxF "### \`$name\`" CLAUDE.md || { echo "DESC NO HEADING $name"; continue; }
      line=$(awk -v h="### \`$name\`" 'p { print; exit } $0 == h { p = 1 }' CLAUDE.md)
      [ -n "$line" ] || { echo "DESC BLANK AFTER HEADING $name"; continue; }
      [ "$line" = "$desc." ] || echo "DESC DRIFT $name"
    done
grep -oE '^### `[^`]+`' CLAUDE.md | tr -d '#` ' \
  | while read -r name; do
      jq -e --arg n "$name" 'any(.plugins[]; .name == $n)' .claude-plugin/marketplace.json \
        >/dev/null || echo "DESC NO PLUGIN $name"
    done

# README and CLAUDE.md skill and command lists match marketplace.json
jq -r '.plugins[].name' .claude-plugin/marketplace.json | while read -r p; do
    h="### \`$p\`"
    mk_s=$(jq -r --arg p "$p" '.plugins[] | select(.name == $p) | (.skills // [])[]' \
             .claude-plugin/marketplace.json | sed 's|.*/||' | sort -u)
    mk_c=$(jq -r --arg p "$p" '.plugins[] | select(.name == $p) | (.commands // [])[]' \
             .claude-plugin/marketplace.json | sed 's|.*/||; s|\.md$||' | sort -u)
    sec_c=$(awk -v h="$h" '$0 == h { p = 1; next } p && /^#/ { exit } p' CLAUDE.md)
    sec_r=$(awk -v h="$h" '$0 == h { p = 1; next } p && /^#/ { exit } p' README.md)
    cl_s=$(printf '%s\n' "$sec_c" | sed -n 's/^\*\*Skills:\*\* *//p'   | tr ',' '\n' | tr -d '` ' | grep . | sort -u)
    cl_c=$(printf '%s\n' "$sec_c" | sed -n 's/^\*\*Commands:\*\* *//p' | tr ',' '\n' | tr -d '` ' | grep . | sort -u)
    rd_s=$(printf '%s\n' "$sec_r" | sed -n 's/^| *`\([^`]*\)` *|.*/\1/p' | sort -u)
    [ "$mk_s" = "$cl_s" ] || echo "SKILLS DRIFT $p claude"
    [ "$mk_s" = "$rd_s" ] || echo "SKILLS DRIFT $p readme"
    [ "$mk_c" = "$cl_c" ] || echo "COMMANDS DRIFT $p claude"
  done

# every skill's phase headings run 1..N, and any stated count matches them
w2n() { case "$1" in one) echo 1;; two) echo 2;; three) echo 3;; four) echo 4;; five) echo 5;;
        six) echo 6;; seven) echo 7;; eight) echo 8;; nine) echo 9;; ten) echo 10;;
        eleven) echo 11;; twelve) echo 12;; thirteen) echo 13;; *) echo 0;; esac; }
for f in skills/*/SKILL.md; do
    nums=$(grep '^## Phase [0-9]' "$f" | sed 's/^## Phase *\([0-9][0-9]*\).*/\1/' | sort -n -u)
    cnt=$(printf '%s\n' "$nums" | grep -c .)
    [ "$cnt" -eq 0 ] && continue
    [ "$nums" = "$(seq 1 "$cnt")" ] \
      || echo "PHASE SEQUENCE $f (numbered $(echo $nums | tr '\n' ' ')- expected 1 to $cnt)"
    said=$(sed -n 's/.*[Tt]he \**\(one\|two\|three\|four\|five\|six\|seven\|eight\|nine\|ten\|eleven\|twelve\|thirteen\)\** phases.*/\1/p' "$f" | head -1)
    [ -n "$said" ] || continue
    [ "$(w2n "$said")" = "$cnt" ] || echo "PHASE COUNT DRIFT $f (says $said, has $cnt)"
  done

# CLAUDE.md's stated check count matches the number of checks in this block
if [ -n "${HIVRR_VERIFY_BLOCK:-}" ]; then
    n=$(printf '%s\n' "$HIVRR_VERIFY_BLOCK" | grep -c '^# ')
    said=$(sed -n 's/.*[^A-Za-z]\([A-Za-z][a-z]*\) checks:.*/\1/p' CLAUDE.md | head -1 | tr 'A-Z' 'a-z')
    [ "$(w2n "$said")" = "$n" ] || echo "CHECK COUNT DRIFT CLAUDE.md says $said, verification doc has $n"
  else
    echo "CHECK COUNT UNCHECKED HIVRR_VERIFY_BLOCK unset, so nothing counted the block that ran"
  fi

# README's command usage block names exactly the registered commands
reg_c=$(jq -r '.plugins[] | (.commands // [])[]' .claude-plugin/marketplace.json \
          | sed 's|.*/||; s|\.md$||' | sort -u)
doc_c=$(awk '/^## Commands/ { v = 1; next } v && /^## / { exit } v' README.md \
          | sed -n 's|^/\([A-Za-z0-9_-][A-Za-z0-9_-]*\).*|\1|p' | sort -u)
printf '%s\n' "$reg_c" | grep . | while read -r c; do
    printf '%s\n' "$doc_c" | grep -qxF "$c" || echo "COMMAND UNDOCUMENTED $c"
  done
printf '%s\n' "$doc_c" | grep . | while read -r c; do
    printf '%s\n' "$reg_c" | grep -qxF "$c" || echo "COMMAND NOT REGISTERED $c"
  done

# CLAUDE.md's init phase count matches skills/init/SKILL.md's phase headings
ip_n=$(grep '^## Phase [0-9]' skills/init/SKILL.md \
         | sed 's/^## Phase *\([0-9][0-9]*\).*/\1/' | sort -n -u | grep -c .)
ip_said=$(sed -n 's/.*[^A-Za-z]\([A-Za-z][a-z]*\) ordered phases.*/\1/p' CLAUDE.md \
            | head -1 | tr 'A-Z' 'a-z')
[ "$(w2n "$ip_said")" = "$ip_n" ] \
  || echo "INIT PHASE COUNT DRIFT CLAUDE.md says $ip_said, skills/init/SKILL.md has $ip_n"

# README's Overview table names exactly the registered plugins
reg_p=$(jq -r '.plugins[].name' .claude-plugin/marketplace.json | sort -u)
ov_p=$(awk '/^## Overview/ { v = 1; next } v && /^#/ { exit } v' README.md \
         | sed -n 's/^| *`\([^`]*\)` *|.*/\1/p' | sort -u)
printf '%s\n' "$reg_p" | grep . | while read -r p; do
    printf '%s\n' "$ov_p" | grep -qxF "$p" || echo "PLUGIN UNDOCUMENTED $p"
  done
printf '%s\n' "$ov_p" | grep . | while read -r p; do
    printf '%s\n' "$reg_p" | grep -qxF "$p" || echo "PLUGIN NOT REGISTERED $p"
  done

# the PR review declares itself read-only and grants no unrestricted tool
rfm=$(awk 'NR == 1 && $0 == "---" { p = 1; next } p && $0 == "---" { exit } p' \
        skills/review-pr/SKILL.md)
if ! printf '%s\n' "$rfm" | grep -q '^allowed-tools:'; then
    echo "REVIEW NOT READ-ONLY skills/review-pr/SKILL.md (no allowed-tools)"
  else
    printf '%s\n' "$rfm" | grep -qE '^ *-? *(Edit|Write|NotebookEdit|Bash) *$' \
      && echo "REVIEW MAY WRITE skills/review-pr/SKILL.md (allowed-tools grants an unrestricted tool)"
    # Bash(git:*) covers checkout, stash, commit, and clean; Bash(git remote:*) keeps a space
    printf '%s\n' "$rfm" | grep -qE '^ *-? *Bash\(git[:)]' \
      && echo "REVIEW MAY WRITE skills/review-pr/SKILL.md (allowed-tools grants unscoped git)"
  fi

# every skills/ directory has a matching, valid .agents/skills/ symlink, and no dangling extras
skill_dirs=$(find skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -u)
agent_links=$(find .agents/skills -mindepth 1 -maxdepth 1 -exec basename {} \; 2>/dev/null | sort -u)
printf '%s\n' "$skill_dirs" | while read -r name; do
    printf '%s\n' "$agent_links" | grep -qxF "$name" || echo "AGENTS SKILL MISSING $name"
  done
printf '%s\n' "$agent_links" | grep . | while read -r name; do
    p=".agents/skills/$name"
    [ -L "$p" ] || { echo "AGENTS SKILL NOT SYMLINK $name"; continue; }
    [ -d "$p" ] || echo "AGENTS SKILL DANGLING $name"
  done
```

Silence from all of them means everything registered resolves, nothing is duplicated, the phase
numbering holds, and the counts and lists that describe the plugins agree with `marketplace.json`.
See **Path resolution** in `CLAUDE.md` for the contract the first three checks enforce.

| # | Checks | Reports |
|---|---|---|
| 1 | Every tracked JSON file parses | `NO JSON FILES TRACKED` |
| 2 | Every registered skill is a directory holding `SKILL.md` | `BAD SKILL {path}` |
| 3 | Every registered command is an existing `.md` file | `NO .md EXTENSION {path}`, `MISSING {path}` |
| 4 | `work-issue` and `work-pr` don't duplicate their verify procedure outside `docs/shared-lines-allowlist.txt` | `DUPLICATED` |
| 5 | `CLAUDE.md` plugin descriptions match `marketplace.json` verbatim | `DESC DRIFT`, `DESC NO HEADING`, `DESC BLANK AFTER HEADING`, `DESC NO PLUGIN`, `DESC TERMINAL PERIOD` |
| 6 | `README.md` and `CLAUDE.md`'s skill/command lists match `marketplace.json` | `SKILLS DRIFT {plugin} claude\|readme`, `COMMANDS DRIFT {plugin} claude` |
| 7 | Every skill's phase headings run `1..N`, and any stated count matches | `PHASE SEQUENCE`, `PHASE COUNT DRIFT` |
| 8 | `CLAUDE.md`'s stated check count matches the number of checks that actually ran | `CHECK COUNT DRIFT`, `CHECK COUNT UNCHECKED` |
| 9 | `README.md`'s command usage block names exactly the registered commands | `COMMAND UNDOCUMENTED`, `COMMAND NOT REGISTERED` |
| 10 | `CLAUDE.md`'s `init` phase count matches `skills/init/SKILL.md`'s headings | `INIT PHASE COUNT DRIFT` |
| 11 | `README.md`'s Overview table names exactly the registered plugins | `PLUGIN UNDOCUMENTED`, `PLUGIN NOT REGISTERED` |
| 12 | `review-pr` declares itself read-only and grants no unrestricted tool | `REVIEW NOT READ-ONLY`, `REVIEW MAY WRITE` |
| 13 | Every `skills/` directory has a matching, non-dangling `.agents/skills/` symlink | `AGENTS SKILL MISSING`, `AGENTS SKILL NOT SYMLINK`, `AGENTS SKILL DANGLING` |

A few mechanics worth knowing before editing this block:

- **This fence *is* `verify.test`.** `.hivrr.json` extracts it at run time and pipes it to `bash` —
  there is no second copy to keep in sync. Editing a check here changes what runs, immediately.
- **Run with stdin closed, always.** The loader passes the block as an argument and runs it with
  `</dev/null`. A check that reads stdin would otherwise swallow the rest of the block silently —
  none does today, but no check may depend on stdin being open.
- **This must be the only fence in this file.** The loader takes the *first* fenced block after the
  `# Verification` heading and stops at its closing fence — a stray fence-shaped line at column 0
  inside a check would truncate the block silently.
- **`$json_files` in the first check is deliberately unquoted** — that's what splits multiple paths
  into separate `jq` arguments. No filename in this repo has whitespace.
- **One column-0 `# ` comment per check.** The eighth check counts these to keep `CLAUDE.md`'s stated
  count honest; a comment inside a check is indented so it doesn't inflate the count.
- **The digit anchor `^## Phase [0-9]` (check 7) must stay anchored** — an unanchored `^## Phase`
  would also match a heading like `## Phase Contract` and miscount.
- **The duplication check (4) covers one pair, deliberately.** Other same-named skills share lines
  over the threshold today (`planning`/`brainstorm`, `score-issues`/`group-issues`); widening it needs
  a per-pair allowlist since some sharing is required rather than accidental.
- **Checks 6, 9, and 11 read sections of `README.md`** (the per-plugin skill tables, the `## Commands`
  usage block, and the `## Overview` table) even though this fence lives here — those are checks on
  README's own content, not on this file, so they stay pointed at README.md.

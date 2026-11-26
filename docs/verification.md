# Verification

This repo ships no shell scripts — see the script policy in `skills/core/SKILL.md`. Its product is
JSON and Markdown, so verification is structural.

**This file is not documentation of `verify.test` — it *is* `verify.test`.** `.agent-plugins.json` extracts
the fenced block below at run time and pipes it to `bash`. There is no second copy to keep in sync;
editing a check here changes what runs, immediately.

**The loader takes the *first* fenced block in this file** — see the mechanics notes below the check
table — so nothing before the checks fence may itself be a fenced block, including the bootstrap
value documented at the end of this file.

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
        eleven) echo 11;; twelve) echo 12;; thirteen) echo 13;; fourteen) echo 14;;
        fifteen) echo 15;; sixteen) echo 16;; seventeen) echo 17;; eighteen) echo 18;;
        nineteen) echo 19;; twenty) echo 20;; *) echo 0;; esac; }
for f in skills/*/SKILL.md; do
    nums=$(grep '^## Phase [0-9]' "$f" | sed 's/^## Phase *\([0-9][0-9]*\).*/\1/' | sort -n -u)
    cnt=$(printf '%s\n' "$nums" | grep -c .)
    [ "$cnt" -eq 0 ] && continue
    [ "$nums" = "$(seq 1 "$cnt")" ] \
      || echo "PHASE SEQUENCE $f (numbered $(echo $nums | tr '\n' ' ')- expected 1 to $cnt)"
    said=$(sed -n 's/.*[Tt]he \**\(one\|two\|three\|four\|five\|six\|seven\|eight\|nine\|ten\|eleven\|twelve\|thirteen\|fourteen\|fifteen\|sixteen\|seventeen\|eighteen\|nineteen\|twenty\)\** phases.*/\1/p' "$f" | head -1)
    [ -n "$said" ] || continue
    [ "$(w2n "$said")" = "$cnt" ] || echo "PHASE COUNT DRIFT $f (says $said, has $cnt)"
  done

# CLAUDE.md's stated check count matches the number of checks in this block
if [ -n "${AGENT_PLUGINS_VERIFY_BLOCK:-}" ]; then
    n=$(printf '%s\n' "$AGENT_PLUGINS_VERIFY_BLOCK" | grep -c '^# ')
    said=$(sed -n 's/.*[^A-Za-z]\([A-Za-z][a-z]*\) checks:.*/\1/p' CLAUDE.md | head -1 | tr 'A-Z' 'a-z')
    [ "$(w2n "$said")" = "$n" ] || echo "CHECK COUNT DRIFT CLAUDE.md says $said, verification doc has $n"
  else
    echo "CHECK COUNT UNCHECKED AGENT_PLUGINS_VERIFY_BLOCK unset, so nothing counted the block that ran"
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
    # Match the value, not the line shape — YAML allows both a block sequence
    # (allowed-tools:\n  - Read) and an inline flow list (allowed-tools: Read, Bash),
    # and a line-shaped grep only ever matched the first. Extract the inline
    # remainder plus every indented continuation line, then split on commas so
    # both forms reduce to one trimmed tool name per line.
    tools=$(printf '%s\n' "$rfm" | awk '
        /^allowed-tools:/ { sub(/^allowed-tools:[ \t]*/, ""); if (length($0)) print; v = 1; next }
        v && /^[ \t]/ { print; next }
        v { exit }
      ' | tr ',' '\n' | sed -e 's/^[ \t]*-\{0,1\}[ \t]*//' -e 's/[ \t]*$//' | grep .)
    printf '%s\n' "$tools" | grep -qE '^(Edit|Write|NotebookEdit|Bash)$' \
      && echo "REVIEW MAY WRITE skills/review-pr/SKILL.md (allowed-tools grants an unrestricted tool)"
    # Bash(git:*) covers checkout, stash, commit, and clean; Bash(git remote:*) keeps a space
    printf '%s\n' "$tools" | grep -qE '^Bash\(git[:)]' \
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

# every plan pack under docs/plans/ has a README, and opens each fence with exactly three backticks tagged bash, sh, mermaid or text
if [ -d docs/plans ]; then
  for d in docs/plans/*/ docs/plans/.[!.]*/; do
    [ -d "$d" ] || continue
    [ -f "${d}README.md" ] || echo "PACK NO README ${d%/}"
  done
  # the backtick is built with printf so this block never holds a fence-shaped line of its own
  pack_bt=$(printf '\140')
  find docs/plans -type f -name '*.md' | sort | while read -r f; do
      awk -v bt="$pack_bt" -v file="$f" '
        BEGIN { run_re = "^(" bt bt bt "+|~~~+)"; three = bt bt bt }
        { s = $0; pre = 0; sub(/^[ \t]+/, "", s)
          while (sub(/^(>|[-*+][ \t]|[0-9]+[.)][ \t])[ \t]*/, "", s)) pre = 1 }
        !match(s, run_re) { next }
        { n = RLENGTH; run = substr(s, 1, n); info = substr(s, n + 1); sub(/[ \t\r]+$/, "", info) }
        open { if (substr(run, 1, 1) != oc || n < on || info != "") print "PACK FENCE NESTED " file ":" NR
               else { open = 0; if (good && (run != three || pre)) print "PACK FENCE FORM " file ":" NR }
               next }
        { open = 1; oc = substr(run, 1, 1); on = n; good = (run == three && !pre)
          if (!good) print "PACK FENCE FORM " file ":" NR
          if (info !~ /^(bash|sh|mermaid|text)$/) print "PACK CODE FENCE " file ":" NR }
        END { if (open) print "PACK FENCE UNCLOSED " file }' "$f"
    done
fi

# every numbered Load the {name} skill step in a skill names a skill its own plugin ships
jq -r '.plugins[].name' .claude-plugin/marketplace.json | while read -r p; do
    shipped=$(jq -r --arg p "$p" '.plugins[] | select(.name == $p) | (.skills // [])[]' \
                .claude-plugin/marketplace.json)
    printf '%s\n' "$shipped" | grep . | while read -r path; do
        # a missing SKILL.md is check 2's report (BAD SKILL), not this one's
        [ -f "$path/SKILL.md" ] || continue
        s=${path##*/}
        sed -n 's/^[0-9][0-9]*\. Load the `\([a-z-]*\)` skill.*/\1/p' "$path/SKILL.md" \
          | while read -r l; do
              printf '%s\n' "$shipped" | sed 's|.*/||' | grep -qxF "$l" \
                || echo "BOOTSTRAP GAP $p/$s loads $l"
            done
      done
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
| 14 | Every folder directly under `docs/plans/` has a `README.md`, and every opening fence in `docs/plans/**/*.md`, at any indentation, is exactly three backticks tagged `bash`, `sh`, `mermaid` or `text`, not on a `>` or list-marker line, with no fence inside it and a closing fence of its own | `PACK NO README {dir}`, `PACK FENCE FORM {file}:{line}`, `PACK CODE FENCE {file}:{line}`, `PACK FENCE NESTED {file}:{line}`, `PACK FENCE UNCLOSED {file}` |
| 15 | Every line of a shipped skill's `SKILL.md` that starts `N. Load the \`{name}\` skill`, under `## Bootstrap` or not, names a skill the same plugin ships | `BOOTSTRAP GAP {plugin}/{skill} loads {name}` |

A few mechanics worth knowing before editing this block:

- **Test a detection-logic change against synthetic input before editing the real target.**
  Construct the true-positive and true-negative cases a check needs to tell apart — as literal
  strings in a scratch file, or a temporary edit to the real target that you revert before
  committing — and confirm the new logic distinguishes them *before* touching the file the check
  actually inspects (e.g. `skills/review-pr/SKILL.md`'s frontmatter, for check 12 above). A fix
  validated against constructed cases first needs zero review rounds to find what it missed; one
  written straight against the real file and reviewed after routinely needs at least one.
- **This fence *is* `verify.test`.** `.agent-plugins.json` extracts it at run time and pipes it to `bash` —
  there is no second copy to keep in sync. Editing a check here changes what runs, immediately.
- **Run with stdin closed, always.** The loader passes the block as an argument and runs it with
  `</dev/null`. A check that reads stdin would otherwise swallow the rest of the block silently —
  none does today, but no check may depend on stdin being open.
- **No fence may appear before this one.** The loader takes the *first* fenced block after the
  `# Verification` heading and stops at its closing fence — a stray fence-shaped line at column 0
  inside a check would truncate the block silently, and a fence placed earlier in the file (like the
  bootstrap example at the end of this document) would be extracted *instead of* the real checks. A
  fence *after* this one is safe; the loader has already exited by the time it would reach it.
- **`$json_files` in the first check is deliberately unquoted** — that's what splits multiple paths
  into separate `jq` arguments. No filename in this repo has whitespace.
- **One column-0 `# ` comment per check.** The eighth check counts these to keep `CLAUDE.md`'s stated
  count honest; a comment inside a check is indented so it doesn't inflate the count.
- **The digit anchor `^## Phase [0-9]` (check 7) must stay anchored** — an unanchored `^## Phase`
  would also match a heading like `## Phase Contract` and miscount.
- **The duplication check (4) covers one pair, deliberately.** Other same-named skills share lines
  over the threshold today (`planning`/`brainstorm`); widening it needs a per-pair allowlist since
  some sharing is required rather than accidental.
- **Check 14 builds its backtick with `printf`**, exactly as the loader does, so the block never
  holds a line that starts with three backticks. A literal one would end the extracted block early
  and silently drop every check after it. It prints nothing when `docs/plans/` is absent. A fence
  line is any line whose first non-blank characters, after any `>` blockquote and list markers
  (`-`, `*`, `+`, `1.`, `1)`) are stripped, are three or more backticks or tildes. So a fence
  indented under a list item is read like one at column 0, and a fence on a marker line is read
  too; a backtick run mid-line is not a fence. An opening fence that is not exactly three backticks
  — `~~~`, four or more backticks, or any fence on a `>` or list-marker line — reports
  `PACK FENCE FORM`; one whose info string is not `bash`, `sh`, `mermaid` or `text` reports
  `PACK CODE FENCE`, and `~~~python` reports both. Tracking follows rendering: a fence closes on a
  line holding nothing but a run of its opener's character at least as long as the opener's run.
  When a three-backtick fence closes on any other form, that closer reports `PACK FENCE FORM`. Any
  other fence line while a fence is open reports `PACK FENCE NESTED` and leaves the fence open, so
  a fence that a mis-pairing would hide — such as a four-space-indented line that Markdown renders
  as indented code, followed by a real `python` fence — is still reported. A fence still open at
  the end of a file reports `PACK FENCE UNCLOSED`. Trailing spaces, tabs and `\r` after the info
  string are ignored. The rule it enforces is the plan-pack fence rule in
  `skills/planning/references/pack-format.md` §6.
- **Checks 6, 9, and 11 read sections of `README.md`** (the per-plugin skill tables, the `## Commands`
  usage block, and the `## Overview` table) even though this fence lives here — those are checks on
  README's own content, not on this file, so they stay pointed at README.md.

## Bootstrapping `.agent-plugins.json` on a fresh checkout

**`.agent-plugins.json` is gitignored, not committed** (see `skills/init/references/config.md`), so a fresh
checkout has none, and `init` Phase 4's generic detection tables have no row for "structural checks
documented in a Markdown fence" — left undetected, Phase 4 would write `verify.test: null`, which
means "checked, there is nothing" and makes `work-issue`/`work-pr` silently skip verification on a
repo that has it. When scaffolding `.agent-plugins.json` here, set `verify.detectedFrom` to `["manual"]` and
`verify.test` to exactly this:

```
bash -c 'cd "$(git rev-parse --show-toplevel)" || exit 1; FENCE=$(printf "\140\140\140"); AGENT_PLUGINS_VERIFY_BLOCK=$(awk -v fence="$FENCE" "/^# Verification/ { v = 1; next } v && !f && /^## / { exit } v && index(\$0, fence) == 1 { if (f) exit; f = 1; next } v && f" docs/verification.md 2>/dev/null); export AGENT_PLUGINS_VERIFY_BLOCK; bad=$( { for f in .claude-plugin/marketplace.json docs/shared-lines-allowlist.txt docs/verification.md skills/work-pr/SKILL.md skills/work-issue/SKILL.md skills/init/SKILL.md CLAUDE.md README.md; do [ -f "$f" ] || echo "MISSING INPUT $f"; done; if [ -n "$AGENT_PLUGINS_VERIFY_BLOCK" ]; then bash -c "$AGENT_PLUGINS_VERIFY_BLOCK" </dev/null; else echo "NO VERIFY BLOCK docs/verification.md has no fenced bash block under # Verification"; fi; } 2>&1 ); [ -z "$bad" ] && echo "structural checks pass" || { echo "$bad"; exit 1; }'
```

**This fence must stay below the checks fence, never above it.** It contains a triple-backtick
sequence nowhere in its own text, but it *is itself* the loader command — if it were extracted and
run instead of the real checks, it would re-run this same extraction against this same file, find
this same bootstrap fence again (nothing changed), and recurse without bound, forking until the
process limit is exhausted. That is not hypothetical: it happened once, while this section briefly
sat above the checks fence during this very rewrite.

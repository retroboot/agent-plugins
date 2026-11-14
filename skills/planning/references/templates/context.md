# Context — what exists today

Every citation below was checked on <YYYY-MM-DD> at commit `<sha>`. Preflight (README rule 2) means
re-checking the ones your slice touches.

_Guidance: this file is the executor's map of the repository. Cite `path:line` for every claim, so
preflight can check it. For Greenfield, this file records the chosen stack and conventions instead,
and seeds the new project's `CLAUDE.md`._

## 1. Repository shape

_Guidance: languages, build, test runner, layout, and how the pieces this work touches fit together._

## 2. What this work changes

_Guidance: one table per area, with the current behaviour and its fate._

| File | Lines | What it does now | Fate |
|---|---|---|---|
| `<path>` | <n–m> | <behaviour> | <kept \| changed in Slice N \| deleted in Slice N> |

## 3. Shared mechanics to reuse

_Guidance: existing helpers, patterns and conventions the slices should follow, each with
`path:line`. This is the "allowed APIs" list: an executor should not invent what is listed here._

## 4. How verification works here

_Guidance: the exact commands that run tests, lint and any structural checks, their expected
output, and how a behavioural criterion is proven when there is no test for it._

## 5. Glossary

_Guidance: every domain term the pack uses, with one meaning each. Names in design diagrams must
match these entries._

| Term | Meaning |
|---|---|
| <term> | <meaning> |

# Verify — Running a Repo's Tests and Linter

The shared procedure for `work-issue` and `work-pr`. Both run the same commands under the same
rules; only their review questions differ, and those stay in the skills.

`init` Phase 4 detects and records these commands. [`config.md`](config.md) documents the keys and
the precedence chain.

---

## Resolving the commands

Read `verify.test` and `verify.lint` from `.hivrr.json` and run each command directly. See
[`config.md`](config.md) for the read steps and per-key precedence.

**If `verify` is absent from config** (or there is no `.hivrr.json`), detect the commands yourself
using the detection tables in `init` Phase 4, run them, and then offer to record what you found so
the next run does not repeat the guesswork.

**If a key is recorded as `null`**, that repo genuinely has no such command — report `skipped`, and
do not go looking.

---

## Running the commands

Run each command and **show its real output**. Never reduce a failure to a bare status word: "tests
fail" with no output tells you nothing about what to fix and forces another round trip. Do not pipe
through `--silent`, do not capture into a variable you then discard, and do not swallow stderr.

On failure, fix the cause and retry — up to 3 attempts. If it still fails, stop and report the
actual output.

---

## When to skip tests

Skip tests only when the changed files **cannot affect behavior**. Judge this by what each file
does, not by its extension.

```bash
git diff --name-only HEAD
```

**Extension is not the test.** Whether a file affects behavior depends on what reads it in *this*
repository — the one the workflow is running in, which is usually not the repo that ships these
skills.

- **Affects behavior** — source files, configuration that programs read, CI workflow definitions,
  schema and manifest files, and any markdown a tool consumes as instructions
- **Does not affect behavior** — prose documentation, `README`, `CHANGELOG`, `LICENSE`, comments

For a worked example: in a plugin repository whose product *is* JSON and Markdown, a manifest that
declares which skills load and a `SKILL.md` that is a skill's implementation both affect behavior,
and treating them as docs is how a change to either ships unverified. In a repository whose product
is compiled code, the same two extensions may genuinely be documentation. Ask what reads the file.

When in doubt, run the tests. The cost of running them unnecessarily is far below the cost of
skipping them when they mattered.

---

## Reporting

```
Verify: tests {pass|fail|skipped} | lint {pass|fail|skipped}
```

Each of `pass`, `fail`, and `skipped` is a distinct outcome. `skipped` means the command was not
run — because the key is `null` or the change cannot affect behavior — and must never be reported
as `pass`.

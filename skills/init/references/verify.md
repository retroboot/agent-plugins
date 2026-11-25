# Verify — Running a Repo's Tests and Linter

The shared procedure for `work-issue` and `work-pr`. Both run the same commands under the same
rules; only their review questions differ, and those stay in the skills.

`init` Phase 4 detects and records these commands. [`config.md`](config.md) documents the keys and
the precedence chain.

---

## Resolving the commands

Read `verify.test` and `verify.lint` from `.agent-plugins.json` and run each command directly. See
[`config.md`](config.md) for the read steps and per-key precedence.

**If `verify` is absent from config** (or there is no `.agent-plugins.json`), detect the commands yourself
using **Detecting the commands** below, run them, and then offer to record what you found so the
next run does not repeat the guesswork.

**If a key is recorded as `null`**, that repo genuinely has no such command — report `skipped`, and
do not go looking.

---

## Detecting the commands

The detection tables `init` Phase 4 Step 2 runs, and the fallback above uses when `verify` is
absent. Detection can only find what these tables know about; a repo whose verification is real but
unconventional records it by hand with the `["manual"]` sentinel (see [`config.md`](config.md)).
Recording what the tables find is `init` Phase 4 Step 4's job; a caller using the fallback only
offers to record it, and never creates `.agent-plugins.json` for it.

Look for a test command, in this order, and stop at the first match:

| Source | Command |
|---|---|
| `package.json` with a `scripts.test` entry | `npm test` |
| `Makefile` with a `test:` target | `make test` |
| `pyproject.toml` with `[tool.pytest…]`, or `pytest.ini` | `pytest` |
| `jest.config.{js,ts,mjs,cjs}` | `npx jest` |
| `go.mod` | `go test ./...` |
| `Cargo.toml` | `cargo test` |
| A CI workflow that runs a test step | the command that workflow runs |

Then a lint command, same rule:

| Source | Command |
|---|---|
| `package.json` with a `scripts.lint` entry | `npm run lint` |
| `eslint.config.{js,mjs,cjs,ts}` — **flat config** | `npx eslint .` |
| `.eslintrc`, `.eslintrc.{js,cjs,json,yaml,yml}` — legacy config | `npx eslint .` |
| `ruff.toml`, or `pyproject.toml` with `[tool.ruff]` | `ruff check .` |
| `.flake8`, or `setup.cfg` with `[flake8]` | `flake8 .` |
| `Makefile` with a `lint:` target | `make lint` |
| A CI workflow that runs a lint step | the command that workflow runs |

Check flat config **and** legacy config. Matching only `.eslintrc*` is how a repo on
`eslint.config.js` silently reports `lint skipped`.

Record the file and key that justified each command in `verify.detectedFrom`, e.g.
`["package.json:scripts.test", "eslint.config.js"]`. This is the fingerprint, not decoration —
`init` Phase 4 Step 3 compares against it to tell a stale command from a current one.

If a repo genuinely has no test or lint setup, record the key as `null` rather than omitting it.
`null` means "checked, there is nothing"; absent means "never checked".

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

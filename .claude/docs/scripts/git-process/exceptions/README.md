# Per-repository test exceptions

This folder centralizes the test exception files for the `git-process` flow.
Each file corresponds to one repository and overrides `GS_TEST_SUITES` to
exclude tests that should not be validated during the PR flow.

A repository whose stack is not covered by the default `GS_TEST_SUITES` in
`lib/config.sh` — or that needs extra checks such as a build or lint — also uses
this file to declare its own validation suites. `git-process` runs them before
every commit, so they are the gate that keeps a broken build out of the history.

## File convention

```
exceptions/<repository-name>.sh
```

The file name must be the exact repository folder name (the result of
`basename $(git rev-parse --show-toplevel)`).

## Script behavior

- If the file **exists**: `git-run-tests.sh` loads it before running the tests.
- If the file **does not exist** and the tests fail: the script returns
  `TESTS_FAILED_NO_EXCEPTIONS` and the agent must ask the user whether the tests
  should be skipped before continuing.

## Exception file structure

```bash
#!/usr/bin/env bash
# exceptions/<repo>.sh — test exceptions for the <repo> repository.
#
# Skipped tests (justification mandatory):
#
#   TestName
#     Reason: <clear, objective reason>. Created on YYYY-MM-DD.

GS_TEST_SUITES=(
  # One entry per suite in the "name:::detection:::command" format.
  # Add --filter to the command to exclude specific tests.
  "csharp:::find . -name '*.sln' | grep -q .:::dotnet test \$(find . -name '*.sln' | head -1) --filter 'FullyQualifiedName!~ClassName'"
)
```

## Declaring extra validation suites

For a repository that also needs a build (or lint) check before committing,
list each suite under a `Suites defined:` header and keep the test suite in the
array, since the file replaces the defaults:

```bash
#!/usr/bin/env bash
# exceptions/<repo>.sh — validation suites for the <repo> repository.
#
# Suites defined:
#
#   build
#     `pnpm build` (typecheck + bundle). Output is printed only on failure,
#     with ANSI colors stripped. Created on YYYY-MM-DD.

GS_TEST_SUITES=(
  "build:::[ -f package.json ]:::out=\$(pnpm build 2>&1) || { printf '%s\n' \"\$out\" | sed 's/\x1b\[[0-9;]*m//g'; exit 1; }"
  "node:::test -f package.json && grep -q '\"test\"' package.json:::pnpm test"
)
```

Capturing the output and printing it only on failure keeps a successful build
from flooding the JSON result with chunk tables or pre-existing warnings.

## Filters by framework

| Framework | Exclusion syntax |
|---|---|
| `dotnet test` | `--filter 'FullyQualifiedName!~ClassName'` |
| `jest` | `--testPathIgnorePatterns='ClassName'` |
| `vitest` | `--exclude '**/FileName.test.ts'` |
| `pytest` | `-k 'not test_name'` |

## Rules

- **Justification is mandatory** — every skipped test must have a documented reason in the file.
- **Prefer fixing over skipping** — use exceptions only for outdated tests that no longer reflect current behavior, or that depend on infrastructure unavailable locally.
- **Creation date** — record the date to make future audits easier.
- **Declared suites replace the defaults** — the file overrides `GS_TEST_SUITES` entirely, so a repository that adds a build suite must also keep its test suite in the list.
- **Avoid side effects** — a validation suite must not bump versions or write tracked files; call the underlying tool directly when a package script has such hooks (e.g. a `prebuild` that increments the version).

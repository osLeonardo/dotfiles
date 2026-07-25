# Per-repository test exceptions

This folder centralizes the test exception files for the `git-process` flow.
Each file corresponds to one repository and overrides `GS_TEST_SUITES` to
exclude tests that should not be validated during the PR flow.

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

# Verification (`verify`)

Used by: `implement-task`, `refactor`, `bug-fix`, `step-agent`.

In each affected repository, from its root, run `bash {root}/.claude/docs/scripts/git-process/git-run-tests.sh` in the foreground (never with `run_in_background`), with a timeout of up to 10 minutes. It is the same check `git-process` runs before committing, and the script produces no output when run in the background.

Branch on the `code` field of the JSON output:

- `TESTS_PASSED` → proceed
- `TESTS_FAILED` or `TESTS_FAILED_NO_EXCEPTIONS` → fix and repeat the verification. IF the failure does not come from your change → stop and present it to the user; never create or change an exceptions file (`exceptions/<repo>.sh`) on your own
- `NO_TESTS_APPLICABLE` with `status: success` → proceed, and state in the code review gate that the repository has no automated verification
- `NO_TESTS_APPLICABLE` with `status: blocked` (`GS_REQUIRE_TESTS=1`) → stop and present it to the user

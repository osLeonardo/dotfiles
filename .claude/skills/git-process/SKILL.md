---
name: git-process
description: Manages the git lifecycle of an issue using deterministic scripts: creates the working branch, commits, runs tests and pushes to the remote for Pull Request creation. Use when the user wants to create a branch, commit, run tests or push following the standard process.
---

## Configuration

All parameters are centralized in `{root}/.claude/docs/scripts/git-process/lib/config.sh`. No configuration file is needed inside the repositories. Environment variables override the defaults when necessary.

---

## Prerequisites

Check the fields below before starting. For any missing field that cannot be inferred, **stop and ask the user** before continuing.

| Field | Source | If missing |
|---|---|---|
| Target repository | Conversation context or active zoom-in | Ask the user |
| Flow (`normal` or `hotfix`) | The type of work described in the PRD or by the user | Assume `normal`; confirm in the case of a hotfix |
| Issue number | PRD, step or user instruction | Ask the user — it is optional, but must be requested explicitly before proceeding without it |
| Slug | User instruction or the issue title | Ask the user |

---

## How to invoke the scripts

All scripts live in `{root}/.claude/docs/scripts/git-process/`. Run them with `bash` from the target repository's directory:

```bash
cd <repository-path> && bash {root}/.claude/docs/scripts/git-process/<script>.sh [args]
```

The output is always a JSON object on stdout. Interpret `status` and `code` to decide the next step.

> **Important:** every `git` command the agent runs directly (e.g. `git add`, `git restore`, `git status`) must also be prefixed with `cd <repository-path> &&`. Never run git commands without making sure the working directory is the correct repository.

---

## Execution flow

### Stage 1 — Update the base (if needed)

Invoked **only** when another stage returns `BASE_BEHIND` or `PUSH_BEHIND`.

```bash
git-pull-rebase.sh [--branch <name>]
```

| Code | Action |
|---|---|
| `PULLED` | Return to the stage that raised the signal and retry |
| `REBASE_CONFLICT` | Resolve each file in `data.conflicts` → `git rebase --continue` → retry |
| `DIRTY_WORKTREE` | Tell the user to commit or stash first |

---

### Stage 2 — Create the working branch

The user must be on the repository's main branch (`main` or `master` — the script detects which exists).

```bash
git-create-branch.sh --flow <flow> [--issue <num>] --slug <description>
```

| Code | Action |
|---|---|
| `BRANCH_CREATED` | Confirm to the user and move to Stage 3 |
| `BASE_BEHIND` | Run Stage 1 and retry this stage |
| `NOT_ON_BASE` | Tell the user to switch to the main branch |
| `BRANCH_EXISTS` | Ask the user whether to use the existing branch and, if so, run `git switch <branch>` manually |
| `BASE_NOT_FOUND` | No branch among `GS_MAIN_CANDIDATES` exists; confirm the main branch name with the user |
| `OP_IN_PROGRESS` | Tell the user to finish or abort the operation in progress |

---

### Stage 3 — Commit changes

The agent is responsible for selecting and staging the files (`git add`) before invoking the script.

```bash
git-commit.sh -m "#<issue> - <description>"
```

> **Format:** the issue number is optional and, when present, must be prefixed only with `#`, with no enclosing symbols.
> With an issue: `#42 - Description of the change`
> Without an issue: `Description of the change`
>
> See `{root}/.claude/docs/knowledge/git-commit-rules.md` for the full standard.

| Code | Action |
|---|---|
| `COMMITTED` | Confirm the commit (SHA in `data.sha`) and move to Stage 4 |
| `NOTHING_STAGED` | Warn the user; wait for instructions on what should be staged |
| `PROTECTED_BRANCH` | You are on `main`/`master`; go back to Stage 2 and create the working branch |
| `MSG_FORMAT_INVALID` | Fix the message to match the standard and retry |
| `MSG_TOO_LONG` | Shorten the subject and retry |
| `COMMIT_FAILED` | Read `data.git_output`; if a pre-commit hook reformatted files and aborted, re-stage the files listed in `data.staged` and retry; otherwise investigate git's output |

This stage may repeat for multiple commits on the same branch.

---

### Stage 4 — Run tests

```bash
git-run-tests.sh
```

> **Note:** always run this in the foreground (no `run_in_background`). The script produces no output when run in the background.

| Code | Action |
|---|---|
| `TESTS_PASSED` | Move to Stage 5 |
| `NO_TESTS_APPLICABLE` | Move to Stage 5 (blocking only if `GS_REQUIRE_TESTS=1` in `config.sh`) |
| `TESTS_FAILED` | Fix the code → go back to Stage 3 (commit the fix) → retry this stage |
| `TESTS_FAILED_NO_EXCEPTIONS` | The repository has no exceptions file; ask the user which tests should be skipped and why → if confirmed, create `exceptions/<repo>.sh` per `exceptions/README.md` → retry this stage |

> The script automatically loads `exceptions/<repo>.sh` when present, overriding `GS_TEST_SUITES`. See `{root}/.claude/docs/scripts/git-process/exceptions/README.md` to create exception files.

---

### Stage 5 — Push to the remote

Protected branches (`main`/`master`) are never pushed from here — they only receive code via Pull Request.

```bash
git-push.sh [--branch <name>]
```

| Code | Action |
|---|---|
| `PUSHED` | Tell the user and move to Stage 6 |
| `PUSH_BEHIND` | Run Stage 1 (`git-pull-rebase.sh`) and retry this stage |
| `PUSH_REJECTED` | Read `data.git_output` and advise the user |
| `NOT_PUSHABLE` | You are on a protected branch; confirm the correct branch |

---

### Stage 6 — Open the Pull Request

Only do this with explicit user confirmation — opening a PR is an external, outward-facing action.

```bash
gh pr create --base <main|master> --title "<title>" --body "<body>"
```

Include `Closes #<issue>` in the body when there is a linked issue, so it closes automatically on merge.

---

## Branch reference by flow

| Flow | Base branch | Working branch | Destination |
|---|---|---|---|
| `normal` | `main` (or `master`) | `feature/<issue>-<slug>` | Pull Request to the base |
| `hotfix` | `main` (or `master`) | `hotfix/<issue>-<slug>` | Pull Request to the base |

Without a linked issue, the name becomes `feature/<slug>` / `hotfix/<slug>`.

---

## Constraints

- Never skip Stage 4 (tests) before pushing
- Never use `--no-verify` on commits — the hooks are part of the process
- Never push to `main`/`master` — the main branch only receives code via PR
- Never run `push --force` without explicit user approval
- Never open or merge a Pull Request without explicit user confirmation
- Rebase conflicts always require the agent to resolve and continue manually — the scripts do not continue automatically

#!/usr/bin/env bash
# scripts/git-commit.sh — creates ONE commit using only the files ALREADY staged.
#
# Separation of responsibilities:
#   - Claude (semantic): runs `git add` on the files and defines the message.
#   - Script (deterministic): validates preconditions + message format and
#     performs the commit WITH hooks (bypassing via --no-verify is forbidden).
#
# Output: ALWAYS a single JSON object on stdout (see lib/json.sh).
#
# Usage:
#   git-commit.sh -m "#42 - description of the changes"
#   git-commit.sh -m "description of the changes"        (issue optional)
#
# NOTE on hooks that reformat files:
#   If a pre-commit hook alters files and aborts the commit, this script only
#   REPORTS the failure (status=error, code=COMMIT_FAILED) along with git's
#   output. Re-staging and fixing the code are up to Claude — the script does
#   not mutate anything on its own. No repository has active hooks today; this
#   handling is defensive for when they are added.

set -uo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../lib/json.sh
source "$here/lib/json.sh"
# shellcheck source=../lib/config.sh
source "$here/lib/config.sh"
# shellcheck source=../lib/git_common.sh
source "$here/lib/git_common.sh"
# shellcheck source=../lib/validate.sh
source "$here/lib/validate.sh"

MESSAGE=""
while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--message) MESSAGE=${2:-}; shift 2 ;;
    -h|--help)
      emit_json "success" "USAGE" "Usage: git-commit.sh -m \"[#<issue> - ]<description>\""
      exit 0 ;;
    *) emit_error "ARGS_INVALID" "Unknown argument: $1" ;;
  esac
done

[[ -z $MESSAGE ]] && emit_error "MSG_EMPTY" "No commit message provided (use -m)."

gc_require_repo || emit_error "NOT_A_REPO" "The current directory is not a git repository."
config_load

if op=$(gc_inprogress_op); then
  emit_blocked "OP_IN_PROGRESS" "Operation '$op' in progress; finish or abort it before committing." \
    "$(printf '{"operation":"%s"}' "$(json_escape "$op")")"
fi

gc_has_unmerged && emit_blocked "UNMERGED_PATHS" "There are files with unresolved conflicts."

gc_is_detached && emit_blocked "DETACHED_HEAD" "Detached HEAD; check out a branch before committing."

branch=$(gc_current_branch)
if gc_is_protected_branch "$branch"; then
  emit_blocked "PROTECTED_BRANCH" "Committing directly to protected branch '$branch' is not allowed." \
    "$(printf '{"branch":"%s"}' "$(json_escape "$branch")")"
fi

gc_has_staged_changes || emit_blocked "NOTHING_STAGED" "There are no staged files to commit."

validate_commit_message "$MESSAGE"; vrc=$?
if (( vrc == 1 )); then
  emit_blocked "MSG_FORMAT_INVALID" \
    "Message does not match the '[#<issue> - ]<description>' format." \
    "$(printf '{"message":"%s"}' "$(json_escape "$MESSAGE")")"
elif (( vrc == 2 )); then
  emit_blocked "MSG_TOO_LONG" \
    "The subject exceeds the $GS_SUBJECT_MAX character limit." \
    "$(printf '{"length":%d,"max":%d}' "${#MESSAGE}" "$GS_SUBJECT_MAX")"
fi

staged=$(gc_staged_files | json_string_array)

# Commit WITH hooks (no --no-verify). Output captured for diagnostics.
commit_out=$(git commit -m "$MESSAGE" 2>&1)
commit_rc=$?

if (( commit_rc != 0 )); then
  emit_error "COMMIT_FAILED" "Commit failed (pre-commit hook rejected it or git errored)." \
    "$(printf '{"git_output":"%s","staged":%s}' "$(json_escape "$commit_out")" "$staged")"
fi

sha=$(git rev-parse HEAD)
emit_success "COMMITTED" "Commit created successfully." \
  "$(printf '{"sha":"%s","branch":"%s","staged":%s}' \
     "$(json_escape "$sha")" "$(json_escape "$branch")" "$staged")"

#!/usr/bin/env bash
# scripts/git-pull-rebase.sh — fetch + pull --rebase (separate responsibility).
#
# Not called automatically by other scripts: it runs when create/push signal
# that the branch/base is behind the remote. On a rebase conflict it stops and
# returns the conflicting files for Claude to resolve.
#
# Usage:
#   git-pull-rebase.sh [--branch <name>]   (default: current branch)
#
# JSON output.
set -uo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../lib/json.sh
source "$here/lib/json.sh"
# shellcheck source=../lib/config.sh
source "$here/lib/config.sh"
# shellcheck source=../lib/git_common.sh
source "$here/lib/git_common.sh"

BRANCH=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --branch) BRANCH=${2:-}; shift 2 ;;
    *) emit_error "ARGS_INVALID" "Unknown argument: $1" ;;
  esac
done

gc_require_repo || emit_error "NOT_A_REPO" "The current directory is not a git repository."
config_load

if op=$(gc_inprogress_op); then
  emit_blocked "OP_IN_PROGRESS" "Operation '$op' in progress; finish or abort it first."
fi

# Rebase requires a clean working tree.
if ! git diff --quiet || ! git diff --cached --quiet; then
  emit_blocked "DIRTY_WORKTREE" "There are uncommitted changes; commit or stash them before pull --rebase."
fi

[[ -z $BRANCH ]] && BRANCH=$(gc_current_branch)
[[ -z $BRANCH ]] && emit_blocked "DETACHED_HEAD" "Detached HEAD; provide --branch."

if [[ $(gc_current_branch) != "$BRANCH" ]]; then
  git switch --quiet "$BRANCH" || emit_error "SWITCH_FAILED" "Failed to switch to '$BRANCH'."
fi

git fetch --quiet "$GS_REMOTE" 2>/dev/null || true

if ! out=$(git pull --rebase "$GS_REMOTE" "$BRANCH" 2>&1); then
  conflicts=$(git diff --name-only --diff-filter=U 2>/dev/null | json_string_array)
  emit_action_required "REBASE_CONFLICT" \
    "Rebase conflict on '$BRANCH'. Claude must resolve it and run 'git rebase --continue'." \
    "$(printf '{"branch":"%s","conflicts":%s,"git_output":"%s"}' \
       "$(json_escape "$BRANCH")" "$conflicts" "$(json_escape "$out")")"
fi

emit_success "PULLED" "pull --rebase completed." \
  "$(printf '{"branch":"%s"}' "$(json_escape "$BRANCH")")"

#!/usr/bin/env bash
# scripts/git-push.sh — pushes the working branch to the remote.
#
# Protected branches (main/master, see GS_PROTECTED_BRANCHES) are never pushed
# from here: they only receive code via Pull Request on GitHub.
#
# Before pushing it fetches and, if the branch is behind the remote, it does NOT
# pull automatically — it returns action_required so pull --rebase can run
# (separate script) and the push can then be retried.
#
# Usage:
#   git-push.sh [--branch <name>]   (default: current branch)
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
# shellcheck source=../lib/flow.sh
source "$here/lib/flow.sh"

BRANCH=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --branch) BRANCH=${2:-}; shift 2 ;;
    *) emit_error "ARGS_INVALID" "Unknown argument: $1" ;;
  esac
done

gc_require_repo || emit_error "NOT_A_REPO" "The current directory is not a git repository."
config_load

[[ -z $BRANCH ]] && BRANCH=$(gc_current_branch)
[[ -z $BRANCH ]] && emit_blocked "DETACHED_HEAD" "Detached HEAD; provide --branch."

# Protected branches only receive code via PR.
if gc_is_protected_branch "$BRANCH"; then
  emit_blocked "NOT_PUSHABLE" "'$BRANCH' is a protected branch; it only receives code via Pull Request." \
    "$(printf '{"branch":"%s"}' "$(json_escape "$BRANCH")")"
fi

git fetch --quiet "$GS_REMOTE" "$BRANCH" 2>/dev/null || true

# If it already exists on the remote and we are behind, require pull --rebase first.
if git show-ref --verify --quiet "refs/remotes/$GS_REMOTE/$BRANCH"; then
  behind=$(git rev-list --count "$BRANCH..$GS_REMOTE/$BRANCH" 2>/dev/null || echo 0)
  if (( behind > 0 )); then
    emit_action_required "PUSH_BEHIND" \
      "'$BRANCH' is $behind commit(s) behind '$GS_REMOTE/$BRANCH'. Run pull --rebase and retry the push." \
      "$(printf '{"branch":"%s","behind":%d}' "$(json_escape "$BRANCH")" "$behind")"
  fi
fi

if ! out=$(git push -u "$GS_REMOTE" "$BRANCH" 2>&1); then
  emit_action_required "PUSH_REJECTED" "Push rejected by the remote." \
    "$(printf '{"branch":"%s","git_output":"%s"}' "$(json_escape "$BRANCH")" "$(json_escape "$out")")"
fi

emit_success "PUSHED" "Branch pushed to the remote." \
  "$(printf '{"branch":"%s","remote":"%s"}' "$(json_escape "$BRANCH")" "$(json_escape "$GS_REMOTE")")"

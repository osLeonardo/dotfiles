#!/usr/bin/env bash
# scripts/git-create-branch.sh — creates the flow's WORKING branch.
#
# Flow premise: you develop on top of the main branch (main/master) and, when
# done, create the working branch from it, carrying along any still-uncommitted
# changes. That is why the script requires you to BE on the main branch.
#
# Usage:
#   git-create-branch.sh --flow normal --issue 42 --slug rest-timer-fix
#   git-create-branch.sh --flow normal --slug rest-timer-fix     (without issue)
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

FLOW="normal"; ISSUE=""; SLUG=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --flow)  FLOW=${2:-};  shift 2 ;;
    --issue) ISSUE=${2:-}; shift 2 ;;
    --slug)  SLUG=${2:-};  shift 2 ;;
    *) emit_error "ARGS_INVALID" "Unknown argument: $1" ;;
  esac
done

[[ -z $SLUG ]] && emit_error "ARGS_INVALID" "Provide --slug <branch-name>."

gc_require_repo || emit_error "NOT_A_REPO" "The current directory is not a git repository."
config_load

[[ ${GS_REQUIRE_ISSUE:-0} == 1 && -z $ISSUE ]] && \
  emit_error "ARGS_INVALID" "Provide --issue <number> (GS_REQUIRE_ISSUE=1)."

label=$(flow_label "$FLOW") || emit_error "FLOW_UNKNOWN" "Unknown flow: '$FLOW'."
base=$(flow_base) || emit_error "BASE_NOT_FOUND" \
  "No main branch found among: $GS_MAIN_CANDIDATES."

if op=$(gc_inprogress_op); then
  emit_blocked "OP_IN_PROGRESS" "Operation '$op' in progress; finish or abort it first."
fi

current=$(gc_current_branch)
if [[ $current != "$base" ]]; then
  emit_blocked "NOT_ON_BASE" "You must be on the main branch '$base' (current: '${current:-<detached>}')." \
    "$(printf '{"expected_base":"%s","current":"%s"}' "$(json_escape "$base")" "$(json_escape "$current")")"
fi

branch=$(flow_branch_name "$label" "$ISSUE" "$SLUG")
if gc_branch_exists "$branch"; then
  emit_blocked "BRANCH_EXISTS" "Branch '$branch' already exists." \
    "$(printf '{"branch":"%s"}' "$(json_escape "$branch")")"
fi

# Freshness check of the base against the remote (does not pull automatically).
if [[ $GS_CHECK_BASE_FRESHNESS == 1 ]]; then
  git fetch --quiet "$GS_REMOTE" "$base" 2>/dev/null || true
  if git show-ref --verify --quiet "refs/remotes/$GS_REMOTE/$base"; then
    behind=$(git rev-list --count "$base..$GS_REMOTE/$base" 2>/dev/null || echo 0)
    if (( behind > 0 )); then
      emit_action_required "BASE_BEHIND" \
        "Base '$base' is $behind commit(s) behind '$GS_REMOTE/$base'. Run pull --rebase first." \
        "$(printf '{"base":"%s","behind":%d}' "$(json_escape "$base")" "$behind")"
    fi
  fi
fi

# Creates the branch from the current HEAD (= base), carrying along whatever is
# in the working tree / staging area.
if ! out=$(git switch -c "$branch" 2>&1); then
  emit_error "CREATE_FAILED" "Failed to create the branch." \
    "$(printf '{"git_output":"%s"}' "$(json_escape "$out")")"
fi

emit_success "BRANCH_CREATED" "Working branch created." \
  "$(printf '{"branch":"%s","base":"%s","flow":"%s"}' \
     "$(json_escape "$branch")" "$(json_escape "$base")" "$(json_escape "$FLOW")")"

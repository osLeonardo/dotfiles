#!/usr/bin/env bash
# lib/git_common.sh — reusable git state checks.
# All functions return via exit code (0 = true/ok) and/or stdout.
# None of them print JSON or exit the process — the caller decides.

# Are we inside a git working tree?
gc_require_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Current branch name (empty if detached).
gc_current_branch() {
  git symbolic-ref --quiet --short HEAD 2>/dev/null
}

# Is HEAD detached?
gc_is_detached() {
  ! git symbolic-ref --quiet HEAD >/dev/null 2>&1
}

# Is the given branch in the protected list?
gc_is_protected_branch() {
  local b=$1 p
  for p in $GS_PROTECTED_BRANCHES; do
    [[ $b == "$p" ]] && return 0
  done
  return 1
}

# Is an operation in progress? Echoes the name (merge/cherry-pick/revert/rebase)
# and returns 0 if so; returns 1 (no echo) otherwise.
gc_inprogress_op() {
  local gitdir
  gitdir=$(git rev-parse --git-dir 2>/dev/null) || return 1
  [[ -f "$gitdir/MERGE_HEAD" ]]        && { echo "merge";       return 0; }
  [[ -f "$gitdir/CHERRY_PICK_HEAD" ]]  && { echo "cherry-pick"; return 0; }
  [[ -f "$gitdir/REVERT_HEAD" ]]       && { echo "revert";      return 0; }
  [[ -d "$gitdir/rebase-merge" || -d "$gitdir/rebase-apply" ]] && { echo "rebase"; return 0; }
  return 1
}

# Are there paths with unresolved conflicts?
gc_has_unmerged() {
  [[ -n $(git diff --name-only --diff-filter=U 2>/dev/null) ]]
}

# Lists (one per line) the currently staged files.
gc_staged_files() {
  git diff --cached --name-only --diff-filter=ACMRD 2>/dev/null
}

# Are there staged changes?
gc_has_staged_changes() {
  ! git diff --cached --quiet 2>/dev/null
}

# Does the local branch exist?
gc_branch_exists() {
  git show-ref --verify --quiet "refs/heads/$1"
}

# Detects the main branch (main vs master) among the candidates. Echoes the name.
gc_detect_main_branch() {
  local c
  for c in $GS_MAIN_CANDIDATES; do
    if gc_branch_exists "$c"; then echo "$c"; return 0; fi
  done
  return 1
}

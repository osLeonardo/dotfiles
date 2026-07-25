#!/usr/bin/env bash
# lib/flow.sh — defines the branch flows and naming.
#
# Name pattern:  <label>/<issue>-<slug>   (or <label>/<slug> without an issue)
#
# The flow is linear: the working branch is created from the main branch
# (main/master), commits are made on it, and it is pushed to the remote to open
# the PR. There are no consolidation branches and no cherry-pick propagation.
#
# ── Edit/adjust the labels here to your preference ──────────────────────────
flow_label() {
  local flow=$1
  case $flow in
    normal|feature) printf 'feature' ;;
    hotfix)         printf 'hotfix'  ;;
    *)              return 1 ;;
  esac
}
# ────────────────────────────────────────────────────────────────────────────

# flow_base -> detected main branch (main or master), per GS_MAIN_CANDIDATES.
# Requires config_load to have run first.
flow_base() {
  gc_detect_main_branch
}

# flow_branch_name <label> <issue> <slug>
#   with issue:     <label>/<issue>-<slug>
#   without issue:  <label>/<slug>
flow_branch_name() {
  local label=$1 issue=$2 slug=$3
  if [[ -n $issue ]]; then
    printf '%s/%s-%s' "$label" "$issue" "$slug"
  else
    printf '%s/%s' "$label" "$slug"
  fi
}

# flow_branch_label <branch>  ->  extracts the <label> from <label>/...
flow_branch_label() {
  printf '%s' "${1%%/*}"
}

# flow_is_work_branch <branch> -> 0 if the label is a known working label
# (feature/hotfix), 1 otherwise.
flow_is_work_branch() {
  local label
  label=$(flow_branch_label "$1")
  [[ $label == "feature" || $label == "hotfix" ]]
}

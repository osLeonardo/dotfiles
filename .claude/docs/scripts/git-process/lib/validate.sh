#!/usr/bin/env bash
# lib/validate.sh — deterministic commit message validation.
#
# Format (1st line / subject):  [#<issue> - ]<description>
# The GitHub issue number is optional by default; make it mandatory with
# GS_REQUIRE_ISSUE=1 in config.sh.
# e.g. "#42 - fix set volume calculation — it was rounding down"
GS_MSG_REGEX_STRICT='^#[0-9]+ - [^[:space:]].*$'
GS_MSG_REGEX_LOOSE='^(#[0-9]+ - )?[^[:space:]].*$'

# validate_commit_message <msg> -> 0 = valid | 1 = format | 2 = length
validate_commit_message() {
  local msg=$1
  local subject=${msg%%$'\n'*}
  local regex=$GS_MSG_REGEX_LOOSE
  [[ ${GS_REQUIRE_ISSUE:-0} == 1 ]] && regex=$GS_MSG_REGEX_STRICT
  [[ $subject =~ $regex ]] || return 1
  if [[ $GS_SUBJECT_MAX_ENABLED == 1 ]] && (( ${#subject} > GS_SUBJECT_MAX )); then
    return 2
  fi
  return 0
}

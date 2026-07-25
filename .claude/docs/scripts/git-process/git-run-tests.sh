#!/usr/bin/env bash
# scripts/git-run-tests.sh — runs the configured validation/test suites.
#
# Suites are defined in GS_TEST_SUITES (config.sh or an exceptions file),
# one per entry: "name:::detection:::command"
#   detection : bash command; rc 0 => suite applicable (empty => always runs)
#   command   : runs the tests; rc 0 => passed
#
# Exception files: exceptions/<repo>.sh — override GS_TEST_SUITES for that
# repository. If tests fail with no exceptions file present, emits
# TESTS_FAILED_NO_EXCEPTIONS so the agent asks the user.
#
# JSON output. Codes: TESTS_PASSED | TESTS_FAILED | TESTS_FAILED_NO_EXCEPTIONS | NO_TESTS_APPLICABLE
set -uo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/json.sh
source "$here/lib/json.sh"
# shellcheck source=lib/config.sh
source "$here/lib/config.sh"
# shellcheck source=lib/git_common.sh
source "$here/lib/git_common.sh"

gc_require_repo || emit_error "NOT_A_REPO" "The current directory is not a git repository."
config_load

repo_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
exceptions_file="$here/exceptions/${repo_name}.sh"
has_exceptions=0
if [[ -f "$exceptions_file" ]]; then
  # shellcheck source=/dev/null
  source "$exceptions_file"
  has_exceptions=1
fi

SEP=":::"
results="["
first=1
applicable=0
failed=0

for entry in "${GS_TEST_SUITES[@]}"; do
  name=${entry%%"$SEP"*}
  rest=${entry#*"$SEP"}
  detect=${rest%%"$SEP"*}
  command=${rest#*"$SEP"}

  if [[ -n $detect ]]; then
    bash -c "$detect" >/dev/null 2>&1 || continue
  fi
  applicable=$((applicable + 1))

  out=$(bash -c "$command" 2>&1); rc=$?
  status="passed"
  if (( rc != 0 )); then status="failed"; failed=$((failed + 1)); fi

  (( first )) && first=0 || results+=","
  results+=$(printf '{"name":"%s","status":"%s","exit_code":%d,"command":"%s","output":"%s"}' \
    "$(json_escape "$name")" "$status" "$rc" \
    "$(json_escape "$command")" "$(json_escape "$out")")
done
results+="]"

has_exceptions_str=$( [[ $has_exceptions -eq 1 ]] && echo "true" || echo "false" )
data=$(printf '{"applicable":%d,"failed":%d,"has_exceptions_file":%s,"suites":%s}' \
  "$applicable" "$failed" "$has_exceptions_str" "$results")

if (( applicable == 0 )); then
  if [[ $GS_REQUIRE_TESTS == 1 ]]; then
    emit_blocked "NO_TESTS_APPLICABLE" "No applicable suite and GS_REQUIRE_TESTS=1." "$data"
  fi
  emit_success "NO_TESTS_APPLICABLE" "No applicable test suite in this repository." "$data"
fi

if (( failed > 0 )); then
  if [[ $has_exceptions -eq 0 ]]; then
    emit_action_required "TESTS_FAILED_NO_EXCEPTIONS" \
      "$failed suite(s) failed and repository '${repo_name}' has no exceptions file (exceptions/${repo_name}.sh); ask the user which tests should be skipped and, if confirmed, create the exceptions file before continuing." \
      "$data"
  fi
  emit_action_required "TESTS_FAILED" "$failed suite(s) failed; Claude must fix the code." "$data"
fi

emit_success "TESTS_PASSED" "All applicable suites passed." "$data"

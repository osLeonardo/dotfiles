#!/usr/bin/env bash
# lib/config.sh — centralized skill configuration.
#
# All values live here. Environment variables override the defaults
# (precedence: environment variable > value below).

config_load() {
  : "${GS_PROTECTED_BRANCHES:=main master}"
  : "${GS_REMOTE:=origin}"
  : "${GS_MAIN_CANDIDATES:=main master}"
  : "${GS_REQUIRE_TESTS:=0}"
  : "${GS_REQUIRE_ISSUE:=0}"
  : "${GS_CHECK_BASE_FRESHNESS:=1}"
  : "${GS_SUBJECT_MAX_ENABLED:=0}"
  : "${GS_SUBJECT_MAX:=72}"

  if [[ -z ${GS_TEST_SUITES+x} ]]; then
    GS_TEST_SUITES=(
      "node:::test -f package.json && grep -q '\"test\"' package.json:::pnpm test"
      "csharp:::find . -name '*.sln' | grep -q .:::dotnet test \$(find . -name '*.sln' | head -1)"
    )
  fi
}

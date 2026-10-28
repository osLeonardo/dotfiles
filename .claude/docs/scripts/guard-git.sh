#!/usr/bin/env bash
# guard-git.sh — PreToolUse hook: asks for confirmation on any write-type git
# command the agent runs directly, i.e. OUTSIDE the `git-process` scripts.
#
# Reinforces the workflow in docs/knowledge/development-process.md: `git-process`
# is the git handler — it creates the branch, commits, runs tests and pushes,
# validating the protected branch, the message format and the preconditions.
# Other skills do not run write-type git commands on their own.
#
# It lives in settings.json (versioned) on purpose: the permission allowlist in
# settings.local.json is per-machine, so a broad `Bash(git *)` allow there would
# leave nothing but prose behind. A hook "ask" wins over an "allow" rule, so this
# layer holds on every machine.
#
# Because the hook "ask" beats "allow", the read-only forms of `branch`, `remote`
# and `tag` are let through here:
#   branch  no arguments, or a listing flag (--show-current, -a, -r, --list, -v,
#           --contains, --merged...) and no write flag
#   remote  no arguments, -v, get-url or show
#   tag     no arguments, or -l/--list and no write flag
# `rebase --continue` is also let through: it is the documented manual step of
# git-process Stage 1 after the agent resolves a rebase conflict.
# Every other verb in the list always asks. Global options before the verb
# (`git -C <dir>`, `git -c k=v`) do not hide the verb.
#
# Does NOT affect `git-process` or `sync-main`, for two independent reasons:
#   1. The regex requires `git` followed by whitespace; `bash .../git-commit.sh`
#      and `bash .../sync-main.sh` do not match.
#   2. The scripts' internal `git` calls are subprocesses and never go through
#      the Bash tool.
#
# `git add` / `git restore` are left out: git-process Stage 3 relies on the agent
# staging files before invoking the commit script.
#
# Emits "ask", never "deny" — a hard block of destructive commands belongs in
# `permissions.deny` of settings.json, which is cheaper and more robust.
#
# Fail-open: a parse error (or a missing jq) allows.

set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

payload=$(cat)

# Cheap pre-filter: no `git` anywhere in the payload → leave before running jq.
printf '%s' "$payload" | grep -q 'git' || exit 0

read -r -d '' PROGRAM <<'JQ'
def verbs: ["commit", "push", "reset", "checkout", "switch", "branch",
            "merge", "rebase", "cherry-pick", "tag", "remote"];
def arg: "(?:\"[^\"]*\"|'[^']*'|\\S+)";
def pattern:
  "(?:^|[;&|(]|\\s)git((?:\\s+-[Cc]\\s+" + arg + ")*)\\s+("
  + (verbs | join("|")) + ")\\b([^;&|)\\n]*)";

def branch_list: "^(--show-current|-a|--all|-r|--remotes|--list|-l|-v|-vv|--verbose|--contains|--no-contains|--merged|--no-merged|--points-at|--sort=.*|--format=.*)$";
def branch_write: "^(-d|-D|--delete|-m|-M|--move|-c|-C|--copy|-f|--force|-u|--set-upstream-to(=.*)?|--unset-upstream|--edit-description|-t|--track(=.*)?|--no-track)$";
def tag_write: "^(-d|--delete|-a|--annotate|-s|--sign|-u|-f|--force|-m|-F)$";

def words: [splits("\\s+")] | map(select(length > 0));

# true when the occurrence does not need confirmation
def exempt($verb; $rest):
  ($rest | words) as $a
  | if $verb == "branch" then
      ($a | length) == 0
      or (any($a[]; test(branch_list)) and (any($a[]; test(branch_write)) | not))
    elif $verb == "remote" then
      ($a | length) == 0 or ($a[0] | IN("-v", "--verbose", "get-url", "show"))
    elif $verb == "tag" then
      ($a | length) == 0
      or (any($a[]; . == "-l" or . == "--list") and (any($a[]; test(tag_write)) | not))
    elif $verb == "rebase" then
      $a == ["--continue"]
    else
      false
    end;

if .tool_name != "Bash" then empty else
  (.tool_input.command // "")
  | [ scan(pattern) | select(exempt(.[1]; .[2] // "") | not) | .[1] ]
  | .[0] // empty
  | {
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "ask",
        permissionDecisionReason: (
          "git \(.) outside git-process. The git handler is the /git-process " +
          "skill, which validates the protected branch, the message format and " +
          "the preconditions. Confirm only if this one-off operation was agreed on."
        )
      }
    }
end
JQ

printf '%s' "$payload" | jq -c "$PROGRAM" 2>/dev/null

exit 0

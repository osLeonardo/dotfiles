#!/usr/bin/env bash
# protect-claude-dir.sh — PreToolUse hook: requires user confirmation before
# writing to the structural areas of `{root}/.claude/`.
#
# Enforces, deterministically, the rule from the global CLAUDE.md:
#   "Never create, modify or remove folders and files in this directory without
#    consulting the user."
#
# Discriminates by PATH, not by skill: the hook payload does not say which skill
# is active (its fields are session_id, transcript_path, cwd, permission_mode,
# hook_event_name, tool_name, tool_input, tool_use_id, ...).
#
# SCOPE — only the workspace's own `.claude/` (`$CLAUDE_PROJECT_DIR/.claude`, or
#   the directory this script lives in when the variable is unset). Other
#   `.claude/` directories (`~/.claude` memory and plans, a repository's local
#   `.claude/`, dependencies) are not this rule's concern and pass through.
#   Both sides are resolved with `realpath -m`, so a symlinked `.claude/` and
#   `..` segments cannot dodge the check.
#
# FREE ZONE — artifacts the skills produce in the normal workflow:
#   docs/handoffs/  docs/issues/  docs/prd/  docs/tasks/  docs/bugs/
# PROTECTED ZONE — everything else in `.claude/`: CLAUDE.md, settings*.json,
#   skills/, agents/, docs/knowledge/, docs/scripts/, docs/templates/
#
# Emits "ask" (prompts for confirmation), never "deny". A hard block would also
# stop the sessions whose purpose is to maintain `.claude/`.
#
# Fail-open: any parse error (or a missing jq) results in allowing. A
# confirmation hook that breaks because of a bug is worse than the prose rule it
# reinforces.

set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

payload=$(cat)

IFS=$'\t' read -r tool file < <(printf '%s' "$payload" | jq -r '
  [ (.tool_name // "-"),
    (.tool_input.file_path // .tool_input.notebook_path // "-") ] | @tsv
' 2>/dev/null) || exit 0

[[ -z ${file:-} || $file == "-" ]] && exit 0

# Normalize to an absolute path without requiring the file to exist.
case $file in
  /*) abs=$file ;;
  *)  abs="$(pwd)/$file" ;;
esac
abs=$(realpath -m -- "$abs" 2>/dev/null) || exit 0

if [[ -n ${CLAUDE_PROJECT_DIR:-} ]]; then
  claude_dir="$CLAUDE_PROJECT_DIR/.claude"
else
  claude_dir="$(dirname "${BASH_SOURCE[0]}")/../.."
fi
claude_dir=$(realpath -m -- "$claude_dir" 2>/dev/null) || exit 0

# Outside the workspace's `.claude/` → nothing to do.
[[ $abs != "$claude_dir/"* ]] && exit 0

rel=${abs#"$claude_dir/"}

case $rel in
  docs/handoffs/*|docs/issues/*|docs/prd/*|docs/tasks/*|docs/bugs/*) exit 0 ;;
esac

jq -cn --arg rel "$rel" --arg tool "$tool" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: (
      "\($tool) on a structural area of .claude/ (\($rel)). The global CLAUDE.md " +
      "requires consulting the user before creating, modifying or removing files " +
      "here. Confirm only if this change was agreed on."
    )
  }
}' 2>/dev/null

exit 0

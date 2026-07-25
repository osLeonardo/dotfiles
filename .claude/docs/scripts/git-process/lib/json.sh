#!/usr/bin/env bash
# lib/json.sh — standardized JSON output emission (dependency-free, no jq).
#
# Output contract (stdout): ALWAYS a single JSON object:
#   { "status": "...", "code": "...", "message": "...", "data": {...} }
#
# status ∈ success | error | blocked | action_required
# code   : stable, uppercase event identifier (e.g. PROTECTED_BRANCH)
# message: human-readable text
# data   : optional JSON object/array with details
#
# Exit codes:
#   0 = success
#   1 = error            (unexpected failure / git returned an error)
#   2 = blocked          (precondition violated; human/Claude action required)
#   3 = action_required  (expected state requiring a next step, e.g. behind the remote)

# Escapes a string for use as a JSON VALUE (without the surrounding quotes).
json_escape() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

# Reads lines from stdin and returns a JSON array of strings: ["a","b"]
# Empty lines are ignored.
json_string_array() {
  local first=1 line out="["
  while IFS= read -r line; do
    [[ -z $line ]] && continue
    if (( first )); then first=0; else out+=","; fi
    out+="\"$(json_escape "$line")\""
  done
  out+="]"
  printf '%s' "$out"
}

# emit_json <status> <code> <message> [data_json]
# data_json, if provided, must be a valid JSON fragment (object or array).
emit_json() {
  local status=$1 code=$2 message=$3 data=${4:-}
  printf '{"status":"%s","code":"%s","message":"%s"' \
    "$(json_escape "$status")" \
    "$(json_escape "$code")" \
    "$(json_escape "$message")"
  [[ -n $data ]] && printf ',"data":%s' "$data"
  printf '}\n'
}

# Convenience helpers: emit the JSON and exit with the correct exit code.
emit_success()         { emit_json "success"         "$1" "$2" "${3:-}"; exit 0; }
emit_error()           { emit_json "error"           "$1" "$2" "${3:-}"; exit 1; }
emit_blocked()         { emit_json "blocked"         "$1" "$2" "${3:-}"; exit 2; }
emit_action_required() { emit_json "action_required" "$1" "$2" "${3:-}"; exit 3; }

#!/bin/bash
cd "$CLAUDE_PROJECT_DIR" || exit 0
LOCAL_FILE=".claude/settings.local.json"

# Create the file if it does not exist
if [ ! -f "$LOCAL_FILE" ]; then
  echo '{}' > "$LOCAL_FILE"
fi

# Nothing to inject without a source settings.json
SOURCE_FILE=".claude/settings.json"
[ ! -f "$SOURCE_FILE" ] && exit 0

# Inject statusLine into settings.local.json only if not already present there,
# and only if the source settings.json actually defines one (avoids writing null)
HAS_STATUS=$(jq 'has("statusLine")' "$LOCAL_FILE")
SOURCE_HAS_STATUS=$(jq 'has("statusLine") and .statusLine != null' "$SOURCE_FILE")

if [ "$HAS_STATUS" = "false" ] && [ "$SOURCE_HAS_STATUS" = "true" ]; then
  STATUS_LINE=$(jq '.statusLine' "$SOURCE_FILE")
  TMP_FILE=$(mktemp "${TMPDIR:-/tmp}/settings_tmp.XXXXXX.json")
  if jq --argjson sl "$STATUS_LINE" '. + {statusLine: $sl}' "$LOCAL_FILE" > "$TMP_FILE"; then
    mv "$TMP_FILE" "$LOCAL_FILE"
  else
    rm -f "$TMP_FILE"
  fi
fi
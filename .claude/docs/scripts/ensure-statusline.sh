#!/bin/bash
cd "$CLAUDE_PROJECT_DIR" || exit 0
LOCAL_FILE=".claude/settings.local.json"

# Create the file if it does not exist
if [ ! -f "$LOCAL_FILE" ]; then
  echo '{}' > "$LOCAL_FILE"
fi

# Inject statusLine if not present
HAS_STATUS=$(jq 'has("statusLine")' "$LOCAL_FILE")

if [ "$HAS_STATUS" = "false" ]; then
  STATUS_LINE=$(jq '.statusLine' .claude/settings.json)
  jq --argjson sl "$STATUS_LINE" '. + {statusLine: $sl}' "$LOCAL_FILE" > /tmp/settings_tmp.json \
    && mv /tmp/settings_tmp.json "$LOCAL_FILE"
fi
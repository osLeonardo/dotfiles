#!/usr/bin/env bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
TOTAL_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // ""')
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // ""')
SESSION_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // ""')
WEEKLY_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // ""')
SESSION_RESETS_AT=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // ""')

# Context window
tokens_k=""
if [ -n "$TOTAL_TOKENS" ] && [ "$TOTAL_TOKENS" != "0" ]; then
  tokens_k=$(awk "BEGIN {printf \"%.1fk\", $TOTAL_TOKENS/1000}")
fi

ctx_segment=""
if [ -n "$tokens_k" ] && [ -n "$CTX_PCT" ]; then
  ctx_segment="Tokens: $tokens_k (${CTX_PCT}%)"
elif [ -n "$tokens_k" ]; then
  ctx_segment="Tokens: $tokens_k"
fi

# Session and Weekly rate limits

session_segment=""
[ -n "$SESSION_PCT" ] && session_segment="Session: $(printf '%.0f' "$SESSION_PCT")%"

weekly_segment=""
[ -n "$WEEKLY_PCT" ] && weekly_segment="Weekly: $(printf '%.0f' "$WEEKLY_PCT")%"

# Session reset countdown (rate_limits.five_hour.resets_at)
reset_segment=""
if [ -n "$SESSION_RESETS_AT" ]; then
  now=$(date +%s)
  diff=$((SESSION_RESETS_AT - now))
  if [ "$diff" -gt 0 ]; then
    hours=$((diff / 3600))
    minutes=$(((diff % 3600) / 60))
    if [ "$hours" -gt 0 ]; then
      reset_segment="Reset: ${hours}h${minutes}m"
    else
      reset_segment="Reset: ${minutes}m"
    fi
  fi
fi

# Assemble: [Sonnet 4.6] | 80k (45%)  | Weekly: 12%| Session: 54% - Reset: 2h15m
model=""
[ -n "$MODEL" ] && model="[$MODEL]"
parts=""
[ -n "$ctx_segment" ] && parts="${parts:+$parts | }$ctx_segment"
[ -n "$weekly_segment" ] && parts="${parts:+$parts | }$weekly_segment"
[ -n "$session_segment" ] && parts="${parts:+$parts | }$session_segment"
reset=""
[ -n "$reset_segment" ] && reset="- $reset_segment"

printf '\033[38;2;86;156;214m%s \033[38;2;215;119;87m%s\033[0m \033[38;2;136;136;136m%s\033[0m\n' "$model" "$parts" "$reset"

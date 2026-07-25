#!/usr/bin/env bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
TOTAL_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // ""')
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // ""')
SESSION_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // ""')
WEEKLY_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // ""')

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

# Assemble: [Sonnet 4.6] | 80k (45%) | Session: 54% | Weekly: 12%
model=""
[ -n "$MODEL" ] && model="[$MODEL]"
parts=""
[ -n "$ctx_segment" ]     && parts="${parts:+$parts | }$ctx_segment"
[ -n "$session_segment" ] && parts="${parts:+$parts | }$session_segment"
[ -n "$weekly_segment" ]  && parts="${parts:+$parts | }$weekly_segment"

printf '\033[38;2;86;156;214m%s \033[38;2;215;119;87m%s\033[0m\n' "$model" "$parts"

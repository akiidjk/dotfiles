#!/usr/bin/env bash
# Claude Code status line: keeps the plan limits for the Dynamic Island, then prints ponytail's line.
# ~/.claude/settings.json → "statusLine": { "type": "command", "command": "bash ~/.config/hypr-macshell/scripts/claude-statusline.sh" }
in=$(cat)
d="${XDG_CACHE_HOME:-$HOME/.cache}/macshell"
mkdir -p "$d"
# only when the limits are there (API-key sessions have none), written whole so the island never reads half a file
if printf '%s' "$in" | jq -e '.rate_limits | objects' >/dev/null 2>&1; then
    printf '%s' "$in" | jq -c '{at: (now | floor), rate_limits}' > "$d/claude-limits.json.tmp" && mv "$d/claude-limits.json.tmp" "$d/claude-limits.json"
fi
pt=$(printf '%s\n' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/ponytail/ponytail/*/hooks/ponytail-statusline.sh | sort -V | tail -1)
[ -f "$pt" ] && printf '%s' "$in" | bash "$pt"

#!/usr/bin/env bash
# Claude Code hooks → Dynamic Island (~/.claude/settings.json, "hooks"):
#   UserPromptSubmit   remembers when the turn started
#   Stop               a turn that ran CLAUDE_ISLAND_MIN seconds or more (default 20) reports back: "✓ Claude · project"
#   Notification       Claude is waiting for you (a permission, or idle input)
# Falls back to notify-send when the island is off (MacShell's `island notify` does that itself).
ev=$1
in=$(cat)
sid=$(jq -r '.session_id // "x"' <<<"$in")
dir="${XDG_RUNTIME_DIR:-/tmp}/claude-island"
mkdir -p "$dir"
say() { qs -c MacShell ipc call island notify "$1" "$2" "$3" >/dev/null 2>&1 || notify-send -a Claude "$1" "$2"; }

case $ev in
    start) date +%s > "$dir/$sid" ;;
    stop)
        [ -f "$dir/$sid" ] || exit 0
        t0=$(<"$dir/$sid")
        rm -f "$dir/$sid"
        d=$(( $(date +%s) - t0 ))
        (( d >= ${CLAUDE_ISLAND_MIN:-20} )) || exit 0
        say "✓ Claude · $(basename "$(jq -r '.cwd // empty' <<<"$in")")" "$(( d / 60 ))m $(( d % 60 ))s" "󰚩"
        ;;
    notify) say "Claude needs you" "$(jq -r '.message // "Waiting for input"' <<<"$in")" "󰚩" ;;
esac
exit 0

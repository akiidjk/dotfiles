#!/usr/bin/env bash
# Claude Code → Dynamic Island: adds the hooks (claude-island.sh) and the status line (claude-statusline.sh) to
# ~/.claude/settings.json. Safe to run again: a hook already there is not added twice, and a status line of your own
# (anything but ponytail's, which the wrapper chains) is left alone. Skips quietly without Claude Code or jq.
command -v claude >/dev/null || [ -d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" ] || exit 0
command -v jq >/dev/null || { echo "claude-setup: jq is needed"; exit 0; }

dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
f="$dir/settings.json"
mkdir -p "$dir"
[ -s "$f" ] || echo '{}' > "$f"
cp "$f" "$f.bak"

s='bash ~/.config/hypr-macshell/scripts/claude-island.sh'
jq --arg s "$s" '
  def hook($ev; $arg):
    if any(.hooks[$ev][]?.hooks[]?; .command == ($s + " " + $arg)) then .
    else .hooks[$ev] = ((.hooks[$ev] // []) + [{ hooks: [{ type: "command", command: ($s + " " + $arg) }] }]) end;
  hook("UserPromptSubmit"; "start") | hook("Stop"; "stop") | hook("Notification"; "notify")
  | if (.statusLine.command // "") == "" or ((.statusLine.command // "") | test("ponytail-statusline"))
    then .statusLine = { type: "command", command: "bash ~/.config/hypr-macshell/scripts/claude-statusline.sh" } else . end
' "$f.bak" > "$f.tmp" && mv "$f.tmp" "$f" && echo "Claude Code hooks set in $f (previous: $f.bak)"

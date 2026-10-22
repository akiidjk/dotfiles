#!/usr/bin/env bash
# One-shot deploy of the MacShell merge (dotfiles -> live ~/.config) and switch of the running session.
# Backup of the old live config: ~/.local/share/macshell-merge-backup/live-config-<date>.tgz
# Rollback: stop qs, untar that file over ~ (tar xzf … -C ~), hyprctl reload, start `quickshell -d` + mako again.
set -euo pipefail
D="$HOME/WorkSpace/dotfiles/.config"
B="$HOME/.local/share/macshell-merge-backup"

echo "==> backup"
mkdir -p "$B"
tar czf "$B/live-config-$(date +%Y%m%d-%H%M%S).tgz" -C "$HOME" \
    .config/hypr .config/quickshell .config/matugen .config/mako .config/swaylock 2>/dev/null || true

echo "==> sync dotfiles -> ~/.config"
rsync -a --delete "$D/quickshell/MacShell/" "$HOME/.config/quickshell/MacShell/"
rsync -a --delete "$D/quickshell/MacLock/"  "$HOME/.config/quickshell/MacLock/"
rsync -a "$D/hypr-macshell/" "$HOME/.config/hypr-macshell/"
rsync -a "$D/hypr/"          "$HOME/.config/hypr/"
rsync -a "$D/matugen/"       "$HOME/.config/matugen/"

echo "==> remove what the merge replaced (old island shell, hyprlock, swaylock, mako, legacy wallpaper scripts)"
cd "$HOME/.config"
rm -rf quickshell/shell.qml quickshell/island quickshell/keybindings quickshell/wallpicker quickshell/lib \
       quickshell/now_playing quickshell/Appearance.qml quickshell/Config.qml quickshell/config.js \
       quickshell/theme.js quickshell/colors.js quickshell/.cache \
       hypr/hyprlock.conf hypr/scripts/playerctlock.sh \
       hypr/scripts/wallpapers/set.sh hypr/scripts/wallpapers/set-random.sh \
       hypr/scripts/wallpapers/random.sh hypr/scripts/wallpapers/set-wallpaper.sh \
       matugen/templates/mako-colors.conf matugen/templates/quickshell-colors \
       swaylock mako

echo "==> seed the wallpaper accent + UI sounds"
mkdir -p "$HOME/.config/macshell"
grep -m1 '^primary ' "$HOME/.config/hypr/colors.lua" | grep -oE '#[0-9a-fA-F]{6}' > "$HOME/.config/macshell/accent" || true
python3 "$HOME/.config/hypr-macshell/scripts/macshell-make-sounds.py" >/dev/null 2>&1 || echo "   (sounds skipped: needs python-numpy)"

echo "==> switch the running session"
pkill -x mako || true
pkill -x quickshell || true                 # old island shell + the upstream MacShell started from the clone
sleep 0.5
hyprctl reload >/dev/null                   # loads macshell.lua: binds, layer rules, allow_session_lock_restore
setsid -f qs -c MacShell >/dev/null 2>&1
pkill -x hypridle || true
setsid -f hypridle >/dev/null 2>&1
pgrep -f spotify-notify.sh >/dev/null || setsid -f "$HOME/.config/hypr/scripts/spotify-notify.sh" >/dev/null 2>&1

echo "==> move the upstream clone out of the dotfiles tree (apply-dotfiles would copy it to ~/MacShell)"
if [ -d "$HOME/WorkSpace/dotfiles/MacShell" ] && [ ! -e "$HOME/WorkSpace/MacShell-upstream" ]; then
    mv "$HOME/WorkSpace/dotfiles/MacShell" "$HOME/WorkSpace/MacShell-upstream"
fi

echo "done. Settings: Super+comma -> General -> Top bar (Menu Bar / Dynamic Island)."

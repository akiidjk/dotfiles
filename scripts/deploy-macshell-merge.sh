#!/usr/bin/env bash
# One-shot deploy of the MacShell merge (dotfiles -> live ~/.config) and switch of the running session.
# Every live file this script overwrites or removes is first saved, with its path under ~/.config kept, to
#   ~/.local/share/macshell-merge-backup/<date>/      (e.g. …/<date>/hypr/keybinds.lua)
# Rollback: stop qs, `cp -a ~/.local/share/macshell-merge-backup/<date>/. ~/.config/`, hyprctl reload,
# start `quickshell -d` + mako again. Files the merge only added (macshell.lua, MacShell/, …) can then be deleted.
set -euo pipefail
D="$HOME/WorkSpace/dotfiles/.config"
B="$HOME/.local/share/macshell-merge-backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$B"

echo "==> sync dotfiles -> ~/.config (replaced / deleted files go to $B)"
# rsync --backup: a file is copied into the backup dir right before it is overwritten or deleted
sync_dir() { rsync -a --backup --backup-dir="$B/$2" "${@:3}" "$D/$1/" "$HOME/.config/$2/"; }
sync_dir quickshell/MacShell quickshell/MacShell --delete
sync_dir quickshell/MacLock  quickshell/MacLock  --delete
sync_dir hypr-macshell       hypr-macshell
sync_dir hypr                hypr
sync_dir matugen             matugen

echo "==> move what the merge replaced into the backup (old island shell, hyprlock, swaylock, mako, legacy wallpaper scripts)"
cd "$HOME/.config"
for p in quickshell/shell.qml quickshell/island quickshell/keybindings quickshell/wallpicker quickshell/lib \
         quickshell/now_playing quickshell/Appearance.qml quickshell/Config.qml quickshell/config.js \
         quickshell/theme.js quickshell/colors.js quickshell/.cache \
         hypr/hyprlock.conf hypr/scripts/playerctlock.sh \
         hypr/scripts/wallpapers/set.sh hypr/scripts/wallpapers/set-random.sh \
         hypr/scripts/wallpapers/random.sh hypr/scripts/wallpapers/set-wallpaper.sh \
         matugen/templates/mako-colors.conf matugen/templates/quickshell-colors \
         swaylock mako; do
    [ -e "$p" ] || continue
    mkdir -p "$B/$(dirname "$p")"
    mv "$p" "$B/$p"
done

echo "==> seed the wallpaper accent + UI sounds"
mkdir -p "$HOME/.config/macshell"
if [ -e "$HOME/.config/macshell/accent" ]; then mkdir -p "$B/macshell"; cp -a "$HOME/.config/macshell/accent" "$B/macshell/"; fi
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

echo "backed up (replaced or removed) files:"
(cd "$B" && find . -type f | sed 's|^\./|   |' | head -50)
echo "done. Backup: $B"
echo "Settings: Super+comma -> General -> Top bar (Menu Bar / Dynamic Island)."

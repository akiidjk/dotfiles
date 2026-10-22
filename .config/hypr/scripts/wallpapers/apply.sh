#!/usr/bin/env bash
# Single wallpaper apply path (MacShell wallpaperCmd, the Super+W picker, init_wallpapers.sh).
# matugen sets it with awww ([config.wallpaper]) and re-themes kitty / hypr / btop / spicetify / MacShell accent.
set -e
[ -f "$1" ] || { echo "usage: apply.sh <image>" >&2; exit 1; }
matugen image -t scheme-fidelity --source-color-index 0 -m dark "$1" --fallback-color "#000000"
[ "$1" -ef ~/.current_wallpaper ] || cp "$1" ~/.current_wallpaper

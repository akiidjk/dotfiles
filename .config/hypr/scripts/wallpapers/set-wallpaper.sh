#!/bin/bash
set -eu

WALL_DIR="$HOME/.config/wallpapers"

if [ ! -d "$WALL_DIR" ]; then
    echo "Wallpaper folder not found: $WALL_DIR"
    exit 1
fi

FILE_LIST=$(find "$WALL_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" \) -printf "%f\n")

SELECTED_FILE=$(echo "$FILE_LIST" | wofi --dmenu --prompt "Select wallpaper")

[ -z "$SELECTED_FILE" ] && exit 1

WALL="$WALL_DIR/$SELECTED_FILE"

cp "$WALL" "$HOME/.current_wallpaper"

echo "Setting wallpaper: $SELECTED_FILE"

# Set wallpaper via hyprpaper
echo "Setting $WALL as wallpaper"
matugen image -t scheme-fidelity -m dark $WALL  --show-colors --verbose --fallback-color "#000000"
echo "Wallpaper set successfully"

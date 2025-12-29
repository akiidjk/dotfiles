#!/bin/bash
# 💫 https://github.com/akiidjk 💫 #
# Setup and apply dotfiles for the user

# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp -r . ~/
rm -r ~/install-scripts ~/install.sh

# Set execute permissions for scripts
chmod +x ~/scripts/*.sh
chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.config/hypr/scripts/hyprpicker
chmod +x ~/.config/hypr/scripts/wallpapers/*.sh

#Install others fonts
mkdir -p ~/.local/share/fonts
cp -r ~/.config/fonts/* ~/.local/share/fonts/
fc-cache -fv

# Set zen default browser
xdg-settings set default-web-browser zen-browser.desktop

# Post install path fix
grep -rl '/home/user' ~/.config | while read file; do
    awk '{gsub("/home/user","'"$HOME"'"); print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

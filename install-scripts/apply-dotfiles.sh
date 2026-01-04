#!/bin/bash
# 💫 https://github.com/akiidjk 💫 #
# Setup and apply dotfiles for the user

# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp -r . ~/
rm -r ~/install-scripts ~/install.sh *.log Install-Logs dotfiles

# Set execute permissions for scripts
chmod +x ~/scripts/*.sh
chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.config/hypr/scripts/hyprpicker
chmod +x ~/.config/hypr/scripts/wallpapers/*.sh

#Install others fonts
mkdir -p ~/.local/share/fonts
cp -r ~/.config/fonts/* ~/.local/share/fonts/
fc-cache -fv

# Installing zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Installing Spicetify
curl -fsSL https://raw.githubusercontent.com/khanhas/spicetify-cli/main/install.sh | bash
sudo chmod a+wr .local/share/spotify-launcher/install/usr/share/spotify/
sudo chmod a+wr .local/share/spotify-launcher/install/usr/share/spotify/ -R

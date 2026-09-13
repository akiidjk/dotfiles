#!/bin/bash
# 💫 https://github.com/akiidjk 💫 #
# Setup and apply dotfiles for the user

# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Back up any existing files/dirs that this repo is about to overwrite in $HOME
backup_dotfiles() {
	local backup_dir="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
	local backed_up=false

	for item in .[!.]* *; do
		[ -e "$HOME/$item" ] || continue
		mkdir -p "$backup_dir"
		cp -r "$HOME/$item" "$backup_dir/"
		backed_up=true
	done

	if [ "$backed_up" = true ]; then
		echo "Existing dotfiles backed up to $backup_dir"
	fi
}

backup_dotfiles
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

# Install SDDM and dependencies for SDDM themes
sudo pacman -S sddm qt6-5compat qt6-svg qqc2-desktop-style inter-font ttf-nerd-fonts-symbols
sudo systemctl enable sddm.service
sudo cp -r ~/.config/sddm/faces /usr/share/sddm/
sudo cp -r ~/.config/sddm/themes/pixel /usr/share/sddm/themes/
echo -e "[Theme]\nCurrent=pixel" | sudo tee /etc/sddm.conf

# Create Spotify icon symlink
mkdir -p ~/.icons/hicolor/32x32/apps
ln -s ~/.local/share/spotify-launcher/install/usr/share/spotify/icons/spotify-linux-32.png \
      ~/.icons/hicolor/32x32/apps/spotify-linux-32.png

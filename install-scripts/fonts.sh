#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Fonts #

# These fonts are minimun required for pre-configured dots to work. You can add here as required
# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in AUR and official Arch Repo

fonts=(
  adobe-source-code-pro-fonts
  noto-fonts-emoji
  otf-font-awesome
  ttf-droid
  ttf-fira-code
  ttf-fantasque-nerd
  ttf-jetbrains-mono
  ttf-jetbrains-mono-nerd
  ttf-nerd-fonts-symbols-mono
  ttf-victor-mono
  ttf-nerd-fonts-symbols
  noto-fonts
  fontconfig
)

if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_fonts.log"
SET_LOG_FILE "$LOG_FILE"

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi



# Installation of main components
NOTE "Installing necessary fonts...."

for PKG1 in "${fonts[@]}"; do
  install_package "$PKG1"
done

printf "\n%.0s" {1..2}

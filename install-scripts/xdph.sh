#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# XDG-Desktop-Portals hyprland #

xdg=(
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    umockdev
)

if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_xdph.log"
SET_LOG_FILE "$LOG_FILE"

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi



# XDG-DESKTOP-PORTAL-HYPRLAND
NOTE "Installing xdg-desktop-portal-hyprland"
for xdgs in "${xdg[@]}"; do
  install_package "$xdgs" "$LOG_FILE"
done

printf "\n%.0s" {1..2}

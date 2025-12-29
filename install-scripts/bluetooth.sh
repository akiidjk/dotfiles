#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Bluetooth Stuff #

blue=(
  bluez
  bluez-utils
  blueman
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source logger and global functions scripts
if ! source "$PARENT_DIR/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOGFILE="Install-Logs/install-$(date +%d-%H%M%S)_bluetooth.log"

# Bluetooth
NOTE "Installing Bluetooth Packages..."
for BLUE in "${blue[@]}"; do
  install_package "$BLUE" "$LOGFILE"
done

ACTION "Activating Bluetooth Services..."
if sudo systemctl enable --now bluetooth.service >>"$LOGFILE" 2>&1; then
  OK "Bluetooth service enabled and started"
else
  ERROR "Failed to enable/start bluetooth.service"
fi

printf "\n%.0s" {1..2}

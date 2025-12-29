#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Main Hyprland Package #

hypr_eco=(
  hypridle
  hyprlock
)

hypr=(
  hyprland
)

if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_hyprland.log"
SET_LOG_FILE "$LOG_FILE"

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi



# Check if Hyprland is installed
if command -v Hyprland >/dev/null 2>&1; then
  NOTE "Hyprland is already installed. No action required."
else
  INFO "Hyprland not found. Installing Hyprland..."
  for HYPRLAND in "${hypr[@]}"; do
    install_package "$HYPRLAND"
  done
fi

# Hyprland -eco packages
NOTE "Installing other Hyprland-eco packages..."
for HYPR in "${hypr_eco[@]}"; do
  if ! command -v "$HYPR" >/dev/null 2>&1; then
    INFO "$HYPR not found. Installing $HYPR..."
    install_package "$HYPR"
  else
    NOTE "$HYPR is already installed. No action required."
  fi
done

printf "\n%.0s" {1..2}

#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Yay AUR Helper #
# NOTE: If paru is already installed, yay will not be installed #

pkg="yay-bin"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Set the name of the log file to include the current date and time
LOG_FILE="install-$(date +%d-%H%M%S)_yay.log"

# Source the logger script
if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir -p Install-Logs
fi

# Check for AUR helper and install if not found
ISAUR=$(command -v yay)
if [ -n "$ISAUR" ]; then
  OK "AUR helper already installed, moving on."
else
  NOTE "Installing $pkg from AUR"

  # Check if directory exists and remove it
  if [ -d "$pkg" ]; then
      rm -rf "$pkg"
  fi

  if ! git clone "https://aur.archlinux.org/$pkg.git"; then
    ERROR "Failed to clone $pkg from AUR"
    exit 1
  fi

  if ! cd "$pkg"; then
    ERROR "Failed to enter $pkg directory"
    exit 1
  fi

  if ! makepkg -si --noconfirm 2>&1 | tee -a "$LOG_FILE"; then
    ERROR "Failed to install $pkg from AUR"
    exit 1
  fi

  # moving install logs in to Install-Logs directory
  mv install*.log ../Install-Logs/ || true
  cd ..
fi

# Update system before proceeding
NOTE "Performing a full system update to avoid issues...."
ISAUR=$(command -v yay || command -v paru)

if ! $ISAUR -Syu --noconfirm 2>&1 | tee -a "$LOG_FILE"; then
  ERROR "Failed to update system"
  exit 1
fi

printf "\n%.0s" {1..2}

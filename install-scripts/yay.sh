#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Yay AUR Helper #
# NOTE: If paru is already installed, yay will not be installed #

pkg="yay-bin"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Set the name of the log file to include the current date and time
LOG="install-$(date +%d-%H%M%S)_yay.log"

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
  printf "\n%s - ${SKY_BLUE}AUR helper${RESET} already installed, moving on.\n" "${OK}"
else
  printf "\n%s - Installing ${SKY_BLUE}$pkg${RESET} from AUR\n" "${NOTE}"

# Check if directory exists and remove it
if [ -d "$pkg" ]; then
    rm -rf "$pkg"
fi
  git clone https://aur.archlinux.org/$pkg.git || { printf "%s - Failed to clone ${YELLOW}$pkg${RESET} from AUR\n" "${ERROR}"; exit 1; }
  cd $pkg || { printf "%s - Failed to enter $pkg directory\n" "${ERROR}"; exit 1; }
  makepkg -si --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to install ${YELLOW}$pkg${RESET} from AUR\n" "${ERROR}"; exit 1; }

  # moving install logs in to Install-Logs directory
  mv install*.log ../Install-Logs/ || true
  cd ..
fi

# Update system before proceeding
printf "\n%s - Performing a full system update to avoid issues.... \n" "${NOTE}"
ISAUR=$(command -v yay || command -v paru)

$ISAUR -Syu --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to update system\n" "${ERROR}"; exit 1; }

printf "\n%.0s" {1..2}

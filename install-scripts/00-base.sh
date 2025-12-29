#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# base-devel + archlinux-keyring #

base=(
  base-devel
  archlinux-keyring
  findutils
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source logger and global functions script
if ! source "$PARENT_DIR/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_base.log"

# Installation of main components with pacman
INFO "Installing base-devel, archlinux-keyring and related base packages..."

for PKG1 in "${base[@]}"; do
  INFO "Installing $PKG1 with pacman..."
  install_package_pacman "$PKG1" "$LOG"
done

printf "\n%.0s" {1..1}

#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# base-devel + archlinux-keyring #

base=(
  base-devel
  archlinux-keyring
  findutils
)

if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_base.log"
SET_LOG_FILE "$LOG_FILE"

if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi


# Installation of main components with pacman
INFO "Installing base-devel, archlinux-keyring and related base packages..."

for PKG1 in "${base[@]}"; do
  INFO "Installing $PKG1 with pacman..."
  install_package_pacman "$PKG1"
done

printf "\n%.0s" {1..1}

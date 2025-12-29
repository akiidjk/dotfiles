#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# pacman adding up extra-spices #


# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_pacman.log"
SET_LOG_FILE "$LOG_FILE"

if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  ERROR "Failed to source logger.sh"
  exit 1
fi

if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi

NOTE "Adding ${MAGENTA}Extra Spice${RESET} in pacman.conf ..."
pacman_conf="/etc/pacman.conf"

# Remove comments '#' from specific lines
lines_to_edit=(
    "Color"
    "CheckSpace"
    "VerbosePkgLists"
    "ParallelDownloads"
)

# Uncomment specified lines if they are commented out
for line in "${lines_to_edit[@]}"; do
    if grep -q "^#$line" "$pacman_conf"; then
        sudo sed -i "s/^#$line/$line/" "$pacman_conf"
        ACTION "Uncommented: $line"
    else
        ACTION "$line is already uncommented."
    fi
done

# Add "ILoveCandy" below ParallelDownloads if it doesn't exist
if grep -q "^ParallelDownloads" "$pacman_conf" && ! grep -q "^ILoveCandy" "$pacman_conf"; then
    sudo sed -i "/^ParallelDownloads/a ILoveCandy" "$pacman_conf"
    ACTION "Added ${MAGENTA}ILoveCandy${RESET} after ${MAGENTA}ParallelDownloads${RESET}."
else
    ACTION "It seems ${YELLOW}ILoveCandy${RESET} already exists, moving on.."
fi

ACTION "${MAGENTA}Pacman.conf${RESET} spicing up completed"

# updating pacman.conf
INFO "Synchronizing Pacman Repo"
sudo pacman -Sy

printf "\n%.0s" {1..2}

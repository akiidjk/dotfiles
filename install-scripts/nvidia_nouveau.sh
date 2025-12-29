#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Nvidia Blacklist #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "[ERROR] Failed to change directory to $PARENT_DIR"; exit 1; }

# Source logger
if ! source "$PARENT_DIR/logger.sh"; then
  echo "[ERROR] Failed to source logger.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_nvidia.log"

INFO "blacklist nouveau..."

# Blacklist nouveau
NOUVEAU="/etc/modprobe.d/nouveau.conf"
if [ -f "$NOUVEAU" ]; then
  OK "Seems like nouveau is already blacklisted..moving on."
else
  echo "blacklist nouveau" | sudo tee -a "$NOUVEAU" 2>&1 | tee -a "$LOG"

  # To completely blacklist nouveau (See wiki.archlinux.org/title/Kernel_module#Blacklisting 6.1)
  if [ -f "/etc/modprobe.d/blacklist.conf" ]; then
    echo "install nouveau /bin/true" | sudo tee -a "/etc/modprobe.d/blacklist.conf" 2>&1 | tee -a "$LOG"
  else
    echo "install nouveau /bin/true" | sudo tee "/etc/modprobe.d/blacklist.conf" 2>&1 | tee -a "$LOG"
  fi
fi

printf "\n%.0s" {1..2}

#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Adding users into input group #

if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_input.log"

# Check if the 'input' group exists
if grep -q '^input:' /etc/group; then
    OK "input group exists."
else
    NOTE "input group doesn't exist. Creating input group..."
    if sudo groupadd input; then
        INFO "input group created"
        INFO "input group created" >> "$LOG_FILE"
    else
        ERROR "Failed to create input group"
        exit 1
    fi
fi

# Add the user to the 'input' group
if sudo usermod -aG input "$(whoami)"; then
    OK "user added to the input group. Changes will take effect after you log out and log back in."
    OK "user added to the input group. Changes will take effect after you log out and log back in." >> "$LOG_FILE"
else
    ERROR "Failed to add user to the input group"
    ERROR "Failed to add user to the input group" >> "$LOG_FILE"
    exit 1
fi

printf "\n%.0s" {1..2}

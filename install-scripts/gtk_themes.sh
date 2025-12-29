#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# GTK Themes & ICONS and  Sourcing from a different Repo #

engine=(
    unzip
    gtk-engine-murrine
)

if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_themes.log"
SET_LOG_FILE "$LOG_FILE"

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi

# installing engine needed for gtk themes
for PKG1 in "${engine[@]}"; do
    install_package "$PKG1"
done

# Check if the directory exists and delete it if present
if [ -d "GTK-themes-icons" ]; then
    NOTE "GTK themes and Icons directory exist..deleting..."
    rm -rf "GTK-themes-icons"
fi

NOTE "Cloning GTK themes and Icons repository..."
if git clone --depth=1 https://github.com/JaKooLit/GTK-themes-icons.git >>"$LOG_FILE" 2>&1; then
    cd GTK-themes-icons || { ERROR "Failed to enter GTK-themes-icons directory"; exit 1; }
    chmod +x auto-extract.sh
    ./auto-extract.sh >>"$LOG_FILE" 2>&1
    cd ..
    OK "Extracted GTK Themes & Icons to ~/.icons & ~/.themes directories"
else
    ERROR "Download failed for GTK themes and Icons.."
fi

printf "\n%.0s" {1..2}

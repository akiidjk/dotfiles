#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Final checking if packages are installed
# NOTE: These package check are only the essentials

packages=(
  cliphist
  kvantum
  rofi-wayland
  imagemagick
  swaync
  cmake
  wallust
  waybar
  wl-clipboard
  wlogout
  kitty
  hypridle
  hyprlock
  hyprland
)

# Local packages that should be in /usr/local/bin/
local_pkgs_installed=(

)



if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/00_CHECK-$(date +%d-%H%M%S)_installed.log"
SET_LOG_FILE "$LOG_FILE"

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

NOTE "Final Check if all Essential packages were installed"
# Initialize an empty array to hold missing packages
missing=()
local_missing=()

# Function to check if a packages are installed using pacman
is_installed_pacman() {
    pacman -Qi "$1" &>/dev/null
}

# Loop through each package
for pkg in "${packages[@]}"; do
    # Check if the packages are installed
    if ! is_installed_pacman "$pkg"; then
        missing+=("$pkg")
    fi
done

# Check for local packages
for pkg1 in "${local_pkgs_installed[@]}"; do
    if ! [ -f "/usr/local/bin/$pkg1" ]; then
        local_missing+=("$pkg1")
    fi
done

# Log missing packages
if [ ${#missing[@]} -eq 0 ] && [ ${#local_missing[@]} -eq 0 ]; then
    OK "GREAT! All essential packages have been successfully installed."
else
    if [ ${#missing[@]} -ne 0 ]; then
        WARN "The following packages are not installed and will be logged:"
        for pkg in "${missing[@]}"; do
            WARNING "$pkg"
            echo "$pkg" >> "$LOG_FILE"
        done
    fi

    if [ ${#local_missing[@]} -ne 0 ]; then
        WARN "The following local packages are missing from /usr/local/bin/ and will be logged:"
        for pkg1 in "${local_missing[@]}"; do
            WARNING "$pkg1 is not installed. Can't find it in /usr/local/bin/"
            echo "$pkg1" >> "$LOG_FILE"
        done
    fi

    NOTE "Missing packages logged at $(date)"
fi

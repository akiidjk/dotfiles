#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Global Functions for Scripts #

set -e

# Source the logger script
if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_global.log"

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir -p Install-Logs
fi

# Show progress function
show_progress() {
    local pid=$1
    local package_name=$2
    local spin_chars=("●○○○○○○○○○" "○●○○○○○○○○" "○○●○○○○○○○" "○○○●○○○○○○" "○○○○●○○○○" \
                      "○○○○○●○○○○" "○○○○○○●○○○" "○○○○○○○●○○" "○○○○○○○○●○" "○○○○○○○○○●")
    local i=0

    tput civis
    NOTE "Installing ${YELLOW}${package_name}${RESET} ..."

    while ps -p "$pid" &> /dev/null; do
        printf "\r${NOTE} Installing ${YELLOW}%s${RESET} %s" "$package_name" "${spin_chars[i]}"
        i=$(( (i + 1) % 10 ))
        sleep 0.3
    done

    printf "\r${NOTE} Installing ${YELLOW}%s${RESET} ... Done!%-20s \n" "$package_name" ""
    tput cnorm
}

# Function to install packages with pacman
install_package_pacman() {
  local pkg="$1"

  # Check if package is already installed
  if pacman -Q "$pkg" &>/dev/null ; then
    INFO "${MAGENTA}${pkg}${RESET} is already installed. Skipping..."
  else
    # Run pacman and redirect all output to a log file
    (
      stdbuf -oL sudo pacman -S --noconfirm "$pkg" 2>&1
    ) >> "$LOG_FILE" 2>&1 &
    PID=$!
    show_progress "$PID" "$pkg"

    # Double check if package is installed
    if pacman -Q "$pkg" &>/dev/null ; then
      OK "Package ${YELLOW}${pkg}${RESET} has been successfully installed!"
    else
      ERROR "${YELLOW}${pkg}${RESET} failed to install. Please check the ${LOG_FILE}. You may need to install manually."
    fi
  fi
}

ISAUR=$(command -v yay)
# Function to install packages with either yay or paru
install_package() {
  local pkg="$1"

  if "$ISAUR" -Q "$pkg" &>> /dev/null ; then
    INFO "${MAGENTA}${pkg}${RESET} is already installed. Skipping..."
  else
    (
      stdbuf -oL "$ISAUR" -S --noconfirm "$pkg" 2>&1
    ) >> "$LOG_FILE" 2>&1 &
    PID=$!
    show_progress "$PID" "$pkg"

    # Double check if package is installed
    if "$ISAUR" -Q "$pkg" &>> /dev/null ; then
      OK "Package ${YELLOW}${pkg}${RESET} has been successfully installed!"
    else
      # Something is missing, exiting to review log
      ERROR "${YELLOW}${pkg}${RESET} failed to install :( , please check the ${LOG_FILE}. You may need to install manually! Sorry I have tried :("
    fi
  fi
}

# Function to just install packages with either yay or paru without checking if installed
install_package_f() {
  local pkg="$1"

  (
    stdbuf -oL "$ISAUR" -S --noconfirm "$pkg" 2>&1
  ) >> "$LOG_FILE" 2>&1 &
  PID=$!
  show_progress "$PID" "$pkg"

  # Double check if package is installed
  if "$ISAUR" -Q "$pkg" &>> /dev/null ; then
    OK "Package ${YELLOW}${pkg}${RESET} has been successfully installed!"
  else
    # Something is missing, exiting to review log
    ERROR "${YELLOW}${pkg}${RESET} failed to install :( , please check the ${LOG_FILE}. You may need to install manually! Sorry I have tried :("
  fi
}

# Function for removing packages
uninstall_package() {
  local pkg="$1"

  # Checking if package is installed
  if pacman -Qi "$pkg" &>/dev/null; then
    NOTE "removing ${pkg} ..."
    sudo pacman -R --noconfirm "$pkg" 2>&1 | tee -a "$LOG_FILE" | grep -v "error: target not found"

    if ! pacman -Qi "$pkg" &>/dev/null; then
      echo -e "\e[1A\e[K"
      OK "$pkg removed."
    else
      echo -e "\e[1A\e[K"
      ERROR "$pkg Removal failed. No actions required."
      return 1
    fi
  else
    INFO "Package ${pkg} not installed, skipping."
  fi
  return 0
}

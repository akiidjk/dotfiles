#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SDDM Log-in Manager #

sddm=(
  qt6-declarative
  qt6-svg
  qt6-virtualkeyboard
  qt6-multimedia-ffmpeg
  qt5-quickcontrols2
  sddm
)

# login managers to attempt to disable
login=(
  lightdm
  gdm3
  gdm
  lxdm
  lxdm-gtk3
)

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_sddm.log"
SET_LOG_FILE "$LOG_FILE"

if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  ERROR "Failed to source logger.sh"
  exit 1
fi

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi

# Install SDDM and SDDM theme
NOTE "Installing sddm and dependencies........"
for package in "${sddm[@]}"; do
  install_package "$package"
done

printf "\n%.0s" {1..1}

# Check if other login managers installed and disabling its service before enabling sddm
for login_manager in "${login[@]}"; do
  if pacman -Qs "$login_manager" >/dev/null 2>&1; then
    if sudo systemctl disable "$login_manager.service" >>"$LOG_FILE" 2>&1; then
      INFO "$login_manager disabled."
    else
      WARN "Failed to disable $login_manager.service"
    fi
  fi
done

# Double check with systemctl
for manager in "${login[@]}"; do
  if systemctl is-active --quiet "$manager" >/dev/null 2>&1; then
    WARN "$manager is active, disabling it..."
    if ! sudo systemctl disable "$manager" --now >>"$LOG_FILE" 2>&1; then
      ERROR "Failed to disable $manager"
    fi
  fi
done

printf "\n%.0s" {1..1}
INFO "Activating sddm service........"
if ! sudo systemctl enable sddm >>"$LOG_FILE" 2>&1; then
  ERROR "Failed to enable sddm service"
fi

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && {
  ACTION "$wayland_sessions_dir not found, creating..."
  if ! sudo mkdir -p "$wayland_sessions_dir" >>"$LOG_FILE" 2>&1; then
    ERROR "Failed to create $wayland_sessions_dir"
  fi
}

printf "\n%.0s" {1..2}

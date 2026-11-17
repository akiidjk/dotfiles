#!/bin/bash
# MacGreeter (greetd) Log-in Manager for MacShell #

greetd_pkgs=(
  greetd
  jq
)

# login managers to attempt to disable
login=(
  sddm
  lightdm
  gdm3
  gdm
  lxdm
  lxdm-gtk3
)

if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_greetd.log"
SET_LOG_FILE "$LOG_FILE"

if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi

NOTE "Installing greetd and dependencies........"
for package in "${greetd_pkgs[@]}"; do
  install_package "$package"
done

printf "\n%.0s" {1..1}

# Disable other display managers
for login_manager in "${login[@]}"; do
  if systemctl is-enabled --quiet "$login_manager.service" 2>/dev/null; then
    INFO "Disabling $login_manager.service..."
    sudo systemctl disable "$login_manager.service" >>"$LOG_FILE" 2>&1 || true
  fi
  if systemctl is-active --quiet "$login_manager" 2>/dev/null; then
    WARN "$login_manager is active, stopping..."
    sudo systemctl stop "$login_manager" >>"$LOG_FILE" 2>&1 || true
  fi
done

printf "\n%.0s" {1..1}
INFO "Setting up MacGreeter for greetd..."
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")"/.. && pwd)"
if [ -f "$SCRIPT_DIR/.config/hypr-macshell/scripts/macgreeter.sh" ]; then
  sh "$SCRIPT_DIR/.config/hypr-macshell/scripts/macgreeter.sh" apply >>"$LOG_FILE" 2>&1 || {
    WARN "macgreeter.sh apply returned non-zero. Trying direct apply..."
  }
fi

INFO "Enabling greetd service........"
if ! sudo systemctl enable greetd.service >>"$LOG_FILE" 2>&1; then
  ERROR "Failed to enable greetd service"
fi

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && {
  ACTION "$wayland_sessions_dir not found, creating..."
  sudo mkdir -p "$wayland_sessions_dir" >>"$LOG_FILE" 2>&1 || true
}

printf "\n%.0s" {1..2}

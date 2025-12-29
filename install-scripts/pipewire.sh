#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Pipewire and Pipewire Audio Stuff #

pipewire=(
    pipewire
    wireplumber
    pipewire-audio
    pipewire-alsa
    pipewire-pulse
    sof-firmware
)

# added this as some reports script didnt install this.
# basically force reinstall
pipewire_2=(
    pipewire-pulse
)

if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_pipewire.log"
SET_LOG_FILE "$LOG_FILE"

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Disabling pulseaudio to avoid conflicts and logging output
NOTE "Disabling pulseaudio to avoid conflicts..."
systemctl --user disable --now pulseaudio.socket pulseaudio.service >> "$LOG_FILE" 2>&1 || true

# Pipewire
NOTE "Installing Pipewire Packages..."
for PIPEWIRE in "${pipewire[@]}"; do
    install_package "$PIPEWIRE" "$LOG_FILE"
done

for PIPEWIRE2 in "${pipewire_2[@]}"; do
    install_package_pacman "$PIPEWIRE2" "$LOG_FILE"
done

NOTE "Activating Pipewire Services..."
# Redirect systemctl output to log file
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>&1 | tee -a "$LOG_FILE"
systemctl --user enable --now pipewire.service 2>&1 | tee -a "$LOG_FILE"

OK "Pipewire Installation and services setup complete!"

printf "\n%.0s" {1..2}

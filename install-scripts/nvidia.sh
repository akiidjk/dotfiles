#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Nvidia Stuffs #

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=/dev/null
source "$SCRIPT_DIR/logger.sh"

nvidia_pkg=(
  nvidia-dkms
  nvidia-settings
  nvidia-utils
  libva
  libva-nvidia-driver
)


## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { ERROR "Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_nvidia.log"

# nvidia stuff
INFO "Checking for other hyprland packages and remove if any.."
if pacman -Qs hyprland > /dev/null; then
  INFO "Hyprland detected. removing to install Hyprland from official repo..."
  for hyprnvi in hyprland-git hyprland-nvidia hyprland-nvidia-git hyprland-nvidia-hidpi-git; do
    sudo pacman -R --noconfirm "$hyprnvi" 2>/dev/null | tee -a "$LOG" || true
  done
fi

# Install additional Nvidia packages
INFO "Installing Nvidia Packages and Linux headers..."
for krnl in $(cat /usr/lib/modules/*/pkgbase); do
  for NVIDIA in "${krnl}-headers" "${nvidia_pkg[@]}"; do
    install_package "$NVIDIA" "$LOG"
  done
done

# Check if the Nvidia modules are already added in mkinitcpio.conf and add if not
if grep -qE '^MODULES=.*nvidia. *nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
  INFO "Nvidia modules already included in /etc/mkinitcpio.conf" 2>&1 | tee -a "$LOG"
else
  sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf 2>&1 | tee -a "$LOG"
  OK "Nvidia modules added in /etc/mkinitcpio.conf"
fi

printf "\n%.0s" {1..1}
INFO "Rebuilding Initramfs..." 2>&1 | tee -a "$LOG"
sudo mkinitcpio -P 2>&1 | tee -a "$LOG"

printf "\n%.0s" {1..1}

# Additional Nvidia steps
NVEA="/etc/modprobe.d/nvidia.conf"
if [ -f "$NVEA" ]; then
  INFO "Seems like nvidia_drm modeset=1 fbdev=1 is already added in your system..moving on."
  printf "\n"
else
  printf "\n"
  INFO "Adding options to $NVEA..."
  sudo echo -e "options nvidia_drm modeset=1 fbdev=1" | sudo tee -a /etc/modprobe.d/nvidia.conf 2>&1 | tee -a "$LOG"
  printf "\n"
fi

# Additional for GRUB users
if [ -f /etc/default/grub ]; then
    INFO "GRUB bootloader detected" 2>&1 | tee -a "$LOG"

    # Check if nvidia-drm.modeset=1 is present
    if ! sudo grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
        sudo sed -i -e 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia-drm.modeset=1"/' /etc/default/grub
        OK "nvidia-drm.modeset=1 added to /etc/default/grub" 2>&1 | tee -a "$LOG"
    fi

    # Check if nvidia_drm.fbdev=1 is present
    if ! sudo grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
        sudo sed -i -e 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.fbdev=1"/' /etc/default/grub
        OK "nvidia_drm.fbdev=1 added to /etc/default/grub" 2>&1 | tee -a "$LOG"
    fi

    # Regenerate GRUB configuration
    if sudo grep -q "nvidia-drm.modeset=1" /etc/default/grub || sudo grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
       sudo grub-mkconfig -o /boot/grub/grub.cfg
       INFO "GRUB configuration regenerated" 2>&1 | tee -a "$LOG"
    fi

    OK "Additional steps for GRUB completed" 2>&1 | tee -a "$LOG"
fi

# Additional for systemd-boot users
if [ -f /boot/loader/loader.conf ]; then
    INFO "systemd-boot bootloader detected" 2>&1 | tee -a "$LOG"

    backup_count=$(find /boot/loader/entries/ -type f -name "*.conf.bak" | wc -l)
    conf_count=$(find /boot/loader/entries/ -type f -name "*.conf" | wc -l)

    if [ "$backup_count" -ne "$conf_count" ]; then
        find /boot/loader/entries/ -type f -name "*.conf" | while read imgconf; do
            # Backup conf
            sudo cp "$imgconf" "$imgconf.bak"
            INFO "Backup created for systemd-boot loader: $imgconf" 2>&1 | tee -a "$LOG"

            # Clean up options and update with NVIDIA settings
            sdopt=$(grep -w "^options" "$imgconf" | sed 's/\b nvidia-drm.modeset=[^ ]*\b//g' | sed 's/\b nvidia_drm.fbdev=[^ ]*\b//g')
            sudo sed -i "/^options/c${sdopt} nvidia-drm.modeset=1 nvidia_drm.fbdev=1" "$imgconf" 2>&1 | tee -a "$LOG"
        done

        OK "Additional steps for systemd-boot completed" 2>&1 | tee -a "$LOG"
    else
        NOTE "systemd-boot is already configured..." 2>&1 | tee -a "$LOG"
    fi
fi

printf "\n%.0s" {1..2}

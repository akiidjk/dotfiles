#!/bin/bash
# https://github.com/JaKooLit + a little bit of @akiidjk

clear

# Source the logger script
if ! source "$(dirname "$(readlink -f "$0")")/install-scripts/logger.sh"; then
	echo "Failed to source logger.sh"
	exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/01-Hyprland-Install-Scripts-$(date +%d-%H%M%S).log"
SET_LOG_FILE "$LOG_FILE"

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
	mkdir -p Install-Logs
fi



# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
	ERROR "This script should ${WARNING}NOT${RESET} be executed as root!! Exiting......."
	printf "\n%.0s" {1..2}
	exit 1
fi

# Check if PulseAudio package is installed
if pacman -Qq | grep -qw '^pulseaudio$'; then
	ERROR "PulseAudio is detected as installed. Uninstall it first or edit install.sh on line 211 (execute_script 'pipewire.sh')."
	printf "\n%.0s" {1..2}
	exit 1
fi

# Check if base-devel is installed
if pacman -Q base-devel &>/dev/null; then
	INFO "base-devel is already installed."
else
	NOTE "Install base-devel..."

	if sudo pacman -S --noconfirm base-devel; then
		OK "👌 base-devel has been installed successfully."
	else
		ERROR "❌ base-devel not found nor cannot be installed."
		ACTION "Please install base-devel manually before running this script... Exiting"
		exit 1
	fi
fi

# install whiptails if detected not installed. Necessary for this version
if ! command -v whiptail >/dev/null; then
	NOTE "- whiptail is not installed. Installing..."
	sudo pacman -S --noconfirm libnewt
	printf "\n%.0s" {1..1}
fi

clear

printf "\n%.0s" {1..2}
printf "\e[35m
	╦╔═┌─┐┌─┐╦    ╦ ╦┬ ┬┌─┐┬─┐┬  ┌─┐┌┐┌┌┬┐
	╠╩╗│ ││ │║    ╠═╣└┬┘├─┘├┬┘│  ├─┤│││ ││ 2026
	╩ ╩└─┘└─┘╩═╝  ╩ ╩ ┴ ┴  ┴└─┴─┘┴ ┴┘└┘─┴┘ Arch Linux
	Custom version by @akiidjk
\e[0m"
printf "\n%.0s" {1..1}

# Welcome message using whiptail (for displaying information)
whiptail --title "Custom KooL Arch-Hyprland (2026) Install Script by @akiidjk" \
	--msgbox "Welcome to KooL Arch-Hyprland (2026) Install Script!!!\n\n\
ATTENTION: Run a full system update and Reboot first !!! (Highly Recommended)\n\n\
NOTE: If you are installing on a VM, ensure to enable 3D acceleration else Hyprland may NOT start!" \
	15 80

# Ask if the user wants to proceed
if ! whiptail --title "Proceed with Installation?" \
	--yesno "Would you like to proceed?" 7 50; then
	printf "\n"
	INFO "You chose ${YELLOW}NOT${RESET} to proceed. ${YELLOW}Exiting...${RESET}"
	printf "\n"
	exit 1
fi

OK "${MAGENTA}KooL..${RESET} ${SKY_BLUE}lets continue with the installation...${RESET}"

sleep 1
printf "\n%.0s" {1..1}

# install pciutils if detected not installed. Necessary for detecting GPU
if ! pacman -Q pciutils >/dev/null; then
	NOTE "- pciutils is not installed. Installing..."
	sudo pacman -S --noconfirm pciutils
	printf "\n%.0s" {1..1}
fi

# Path to the install-scripts directory
script_directory=install-scripts

# Function to execute a script if it exists and make it executable
execute_script() {
	local script="$1"
	local script_path="$script_directory/$script"

	if [ -f "$script_path" ]; then
		chmod +x "$script_path"
		if [ -x "$script_path" ]; then
			env "$script_path"
		else
			ERROR "Failed to make script '$script' executable."
		fi
	else
		WARN "Script '$script' not found in '$script_directory'."
	fi
}

aur_helper="yay"
# List of services to check for active login managers
services=("gdm.service" "gdm3.service" "lightdm.service" "lxdm.service")

# Function to check if any login services are active
check_services_running() {
	active_services=()

	for svc in "${services[@]}"; do
		if systemctl is-active --quiet "$svc"; then
			active_services+=("$svc")
		fi
	done

	if [ ${#active_services[@]} -gt 0 ]; then
		return 0
	else
		return 1
	fi
}

if check_services_running; then
	active_list=$(printf "%s\n" "${active_services[@]}")

	whiptail --title "Active non-SDDM login manager(s) detected" \
		--msgbox "The following login manager(s) are active:\n\n$active_list\n\nIf you want to install SDDM and SDDM theme, stop and disable the active services above, reboot before running this script\n\nYour option to install SDDM and SDDM theme has now been removed\n\n- Ja " \
		23 80
fi

# Check if NVIDIA GPU is detected
nvidia_detected=false
if lspci | grep -i "nvidia" &>/dev/null; then
	nvidia_detected=true
fi

printf "\n%.0s" {1..1}

# Ensuring base-devel is installed
execute_script "00-base.sh"
sleep 1
execute_script "pacman.sh"
sleep 1
execute_script "yay.sh"

sleep 1

INFO "Installing ${SKY_BLUE}KooL Hyprland additional packages...${RESET}"
sleep 1
execute_script "01-hypr-pkgs.sh"

INFO "Installing ${SKY_BLUE}pipewire and pipewire-audio...${RESET}"
sleep 1
execute_script "pipewire.sh"

INFO "Installing ${SKY_BLUE}necessary fonts...${RESET}"
sleep 1
execute_script "fonts.sh"

INFO "Installing ${SKY_BLUE}Hyprland...${RESET}"
sleep 1
execute_script "hyprland.sh"

INFO "Setup ${SKY_BLUE}some XDG Mime...${RESET}"
sleep 1
execute_script "xdg-setup.sh"

if check_services_running; then
	active_list=$(printf "%s\n" "${active_services[@]}")
	whiptail --title "Error" \
		--msgbox "One of the following login services is running:\n$active_list\n\nPlease stop & disable it or DO not choose SDDM." \
		12 60
	exec "$0"
else
	INFO "Installing and configuring ${SKY_BLUE}SDDM...${RESET}"
	execute_script "sddm.sh"
fi

if [ "$nvidia_detected" == "true" ]; then
	INFO "Configuring ${SKY_BLUE}nvidia stuff${RESET}"
	execute_script "nvidia.sh"
fi

INFO "Installing ${SKY_BLUE}GTK themes...${RESET}"
execute_script "gtk_themes.sh"

INFO "Adding user into ${SKY_BLUE}input group...${RESET}"
execute_script "InputGroup.sh"

INFO "Installing ${SKY_BLUE}xdg-desktop-portal-hyprland...${RESET}"
execute_script "xdph.sh"

INFO "Configuring ${SKY_BLUE}Bluetooth...${RESET}"
execute_script "bluetooth.sh"

INFO "Downloading & Installing ${SKY_BLUE}Additional SDDM theme...${RESET}"
execute_script "sddm_theme.sh"

INFO "Installing ${SKY_BLUE}zsh with Oh-My-Zsh...${RESET}"
execute_script "zsh.sh"

sleep 1
clear

execute_script "02-Final-Check.sh"

INFO "Applying ${SKY_BLUE}dotfiles...${RESET}"
execute_script "apply-dotfiles.sh"

printf "\n%.0s" {1..1}

if pacman -Q hyprland &>/dev/null || pacman -Q hyprland-git &>/dev/null; then
	printf "\n ${OK} Hyprland is installed. However, some essential packages may not be installed. Please see above!"
	printf "\n${CAT} Ignore this message if it states ${YELLOW}All essential packages${RESET} are installed as per above\n"
	sleep 2

	printf "${SKY_BLUE}Thank you${RESET} for using ${MAGENTA}Custom KooL's Hyprland Dots by @akiidjk${RESET}. ${YELLOW}Enjoy and Have a good day!${RESET}\n\n"
	printf "\n${NOTE} You can start Hyprland by typing ${SKY_BLUE}Hyprland${RESET} (IF SDDM is not installed) (note the capital H!).\n"
	printf "\n${NOTE} However, it is ${YELLOW}highly recommended to reboot${RESET} your system.\n\n"

	while true; do
		printf "%s" "${CAT} Would you like to reboot now? (y/n): "
		read -r HYP
		HYP=$(echo "$HYP" | tr '[:upper:]' '[:lower:]')

		if [[ "$HYP" == "y" || "$HYP" == "yes" ]]; then
			INFO "Rebooting now..."
			systemctl reboot
			break
		elif [[ "$HYP" == "n" || "$HYP" == "no" ]]; then
			OK "You chose NOT to reboot"
			if lspci | grep -i "nvidia" &>/dev/null; then
				INFO "HOWEVER ${YELLOW}NVIDIA GPU${RESET} detected. Reminder that you must REBOOT your SYSTEM..."
			fi
			break
		else
			WARN "Invalid response. Please answer with 'y' or 'n'."
		fi
	done
else
	printf "\n${WARN} Hyprland is NOT installed. Please check 00_CHECK-time_installed.log and other files in the Install-Logs/ directory...\n"
	exit 1
fi

printf "\n%.0s" {1..2}

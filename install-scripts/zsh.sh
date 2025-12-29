#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# zsh and oh my zsh#

zsh_pkg=(
  lsd
  mercurial
  zsh
  zsh-completions
)

zsh_pkg2=(
  fzf
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=/dev/null
. "$SCRIPT_DIR/logger.sh"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { ERROR "Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_zsh.log"

# Installing core zsh packages
NOTE "Installing ${SKY_BLUE}zsh packages${RESET} ...."
for ZSH in "${zsh_pkg[@]}"; do
  install_package "$ZSH" "$LOG_FILE"
done

# Check if the zsh-completions directory exists
if [ -d "zsh-completions" ]; then
    rm -rf zsh-completions
fi

# Install Oh My Zsh, plugins, and set zsh as default shell
if command -v zsh >/dev/null; then
  NOTE "Installing ${SKY_BLUE}Oh My Zsh and plugins${RESET} ..."
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://install.ohmyz.sh)" "" --unattended
  else
    INFO "Directory .oh-my-zsh already exists. Skipping re-installation."
  fi

  # Check if the directories exist before cloning the repositories
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
      git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  else
      INFO "Directory zsh-autosuggestions already exists. Cloning Skipped."
  fi

  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
  else
      INFO "Directory zsh-syntax-highlighting already exists. Cloning Skipped."
  fi

  # Check if ~/.zshrc and .zprofile exists, create a backup, and copy the new configuration
  if [ -f "$HOME/.zshrc" ]; then
      cp -b "$HOME/.zshrc" "$HOME/.zshrc-backup" || true
  fi

  if [ -f "$HOME/.zprofile" ]; then
      cp -b "$HOME/.zprofile" "$HOME/.zprofile-backup" || true
  fi

  # Copying the preconfigured zsh themes and profile
  cp -r 'assets/.zshrc' ~/
  cp -r 'assets/.zprofile' ~/

  # Check if the current shell is zsh
  current_shell=$(basename "$SHELL")
  if [ "$current_shell" != "zsh" ]; then
    NOTE "Changing default shell to ${MAGENTA}zsh${RESET}..."
    printf "\n%.0s" {1..2}

    # Loop to ensure the chsh command succeeds
    while ! chsh -s "$(command -v zsh)"; do
      ERROR "Authentication failed. Please enter the correct password."
      sleep 1
    done

    INFO "Shell changed successfully to ${MAGENTA}zsh${RESET}"
  else
    NOTE "Your shell is already set to ${MAGENTA}zsh${RESET}."
  fi

fi

# Installing core zsh packages
NOTE "Installing ${SKY_BLUE}fzf${RESET} ...."
for ZSH2 in "${zsh_pkg2[@]}"; do
  install_package "$ZSH2" "$LOG_FILE"
done

# copy additional oh-my-zsh themes from assets
if [ -d "$HOME/.oh-my-zsh/themes" ]; then
    cp -r assets/add_zsh_theme/* ~/.oh-my-zsh/themes >> "$LOG_FILE" 2>&1
fi

printf "\n%.0s" {1..2}

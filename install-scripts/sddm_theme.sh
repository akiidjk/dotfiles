#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SDDM themes #

source_theme="https://github.com/JaKooLit/simple-sddm-2.git"
theme_name="simple_sddm_2"

if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_sddm_theme.log"
SET_LOG_FILE "$LOG_FILE"

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi


# SDDM-themes
INFO "Installing Additional SDDM Theme"

# Check if /usr/share/sddm/themes/$theme_name exists and remove if it does
if [ -d "/usr/share/sddm/themes/$theme_name" ]; then
  sudo rm -rf "/usr/share/sddm/themes/$theme_name"
  OK "Removed existing $theme_name directory."
fi

# Check if $theme_name directory exists in the current directory and remove if it does
if [ -d "$theme_name" ]; then
  rm -rf "$theme_name"
  OK "Removed existing $theme_name directory from the current location."
fi

# Clone the repository
if git clone --depth=1 "$source_theme" "$theme_name"; then
  if [ ! -d "$theme_name" ]; then
    ERROR "Failed to clone the repository."
  fi

  # Create themes directory if it doesn't exist
  if [ ! -d "/usr/share/sddm/themes" ]; then
    sudo mkdir -p /usr/share/sddm/themes
    OK "Directory '/usr/share/sddm/themes' created."
  fi

  # Move cloned theme to the themes directory
  if sudo mv "$theme_name" "/usr/share/sddm/themes/$theme_name"; then
    INFO "Moved theme to /usr/share/sddm/themes/$theme_name"
  else
    ERROR "Failed to move theme to /usr/share/sddm/themes/$theme_name"
  fi

  # setting up SDDM theme
  sddm_conf="/etc/sddm.conf"
  BACKUP_SUFFIX=".bak"

  NOTE "Setting up the login screen."

  # Backup the sddm.conf file if it exists
  if [ -f "$sddm_conf" ]; then
    INFO "Backing up $sddm_conf"
    if sudo cp "$sddm_conf" "$sddm_conf$BACKUP_SUFFIX"; then
      OK "Backup created at $sddm_conf$BACKUP_SUFFIX"
    else
      WARN "Failed to create backup at $sddm_conf$BACKUP_SUFFIX"
    fi
  else
    INFO "$sddm_conf does not exist, creating a new one."
    if sudo touch "$sddm_conf"; then
      OK "Created new $sddm_conf"
    else
      ERROR "Failed to create $sddm_conf"
    fi
  fi

  # Check if the [Theme] section exists
  if grep -q '^\[Theme\]' "$sddm_conf"; then
    # Update the Current= line under [Theme]
    if sudo sed -i "/^\[Theme\]/,/^\[/{s/^\s*Current=.*/Current=$theme_name/}" "$sddm_conf"; then
      INFO "Processed [Theme] section in $sddm_conf"
    else
      WARN "Failed to process [Theme] section in $sddm_conf"
    fi

    # If no Current= line was found and replaced, append it after the [Theme] section
    if ! grep -q '^\s*Current=' "$sddm_conf"; then
      if sudo sed -i "/^\[Theme\]/a Current=$theme_name" "$sddm_conf"; then
        INFO "Appended Current=$theme_name under [Theme] in $sddm_conf"
      else
        WARN "Failed to append Current=$theme_name under [Theme] in $sddm_conf"
      fi
    else
      INFO "Updated Current=$theme_name in $sddm_conf"
    fi
  else
    # Append the [Theme] section at the end if it doesn't exist
    if echo -e "\n[Theme]\nCurrent=$theme_name" | sudo tee -a "$sddm_conf" > /dev/null; then
      INFO "Added [Theme] section with Current=$theme_name in $sddm_conf"
    else
      WARN "Failed to add [Theme] section in $sddm_conf"
    fi
  fi

  # Add [General] section with InputMethod=qtvirtualkeyboard if it doesn't exist
  if ! grep -q '^\[General\]' "$sddm_conf"; then
    if echo -e "\n[General]\nInputMethod=qtvirtualkeyboard" | sudo tee -a "$sddm_conf" > /dev/null; then
      INFO "Added [General] section with InputMethod=qtvirtualkeyboard in $sddm_conf"
    else
      WARN "Failed to add [General] section in $sddm_conf"
    fi
  else
    # Update InputMethod line if section exists
    if grep -q '^\s*InputMethod=' "$sddm_conf"; then
      if sudo sed -i '/^\[General\]/,/^\[/{s/^\s*InputMethod=.*/InputMethod=qtvirtualkeyboard/}' "$sddm_conf"; then
        INFO "Updated InputMethod to qtvirtualkeyboard in $sddm_conf"
      else
        WARN "Failed to update InputMethod in $sddm_conf"
      fi
    else
      if sudo sed -i '/^\[General\]/a InputMethod=qtvirtualkeyboard' "$sddm_conf"; then
        INFO "Appended InputMethod=qtvirtualkeyboard under [General] in $sddm_conf"
      else
        WARN "Failed to append InputMethod under [General] in $sddm_conf"
      fi
    fi
  fi

  # Replace current background from assets
  if sudo cp -r assets/sddm.png "/usr/share/sddm/themes/$theme_name/Backgrounds/default"; then
    INFO "Copied assets/sddm.png to theme background"
  else
    WARN "Failed to copy assets/sddm.png to theme background"
  fi

  if sudo sed -i 's|^wallpaper=".*"|wallpaper="Backgrounds/default"|' "/usr/share/sddm/themes/$theme_name/theme.conf"; then
    INFO "Updated wallpaper path in theme.conf"
  else
    WARN "Failed to update wallpaper path in theme.conf"
  fi

  OK "Additional $theme_name SDDM Theme successfully installed."

else

  ERROR "Failed to clone the sddm theme repository. Please check your internet connection."
fi

printf "\n%.0s" {1..2}

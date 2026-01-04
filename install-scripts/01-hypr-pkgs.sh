#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland Packages #

# edit your packages desired here.
# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in AUR and official Arch Repo

# add packages wanted here
Extra=(
  wl-clip-persist
  hyprsunset
  starship
  tmux
  nautilus
  yazi
  vim
  neovim
  zed
  python-pywal16
  wofi
  fzf
  ripgrep
  bat
  zen-browser-bin
  awww
  cava
  hyprpicker
  vicinae-bin
  eza
  jless
  spotify-launcher
  spicetify-cli
)

hypr_package=(
  #aylurs-gtk-shell
  bc
  cliphist
  curl
  grim
  gvfs
  cmake
  gvfs-mtp
  hyprpolkitagent
  imagemagick
  inxi
  jq
  kitty
  kvantum
  libspng
  network-manager-applet
  pamixer
  pavucontrol
  playerctl
  python-requests
  python-pyquery
  qt5ct
  qt6ct
  qt6-svg
  slurp
  swappy
  swaync
  unzip # needed later
  wallust
  waybar
  wget
  wl-clipboard
  wlogout
  xdg-user-dirs
  xdg-utils
  yad
)

# the following packages can be deleted. however, dotfiles may not work properly
hypr_package_2=(
  brightnessctl
  btop
  cava
  loupe
  fastfetch
  gnome-system-monitor
  mpv
  mpv-mpris
  nwg-look
  nwg-displays
  pacman-contrib
  qalculate-gtk
  yt-dlp
)

# List of packages to uninstall as it conflicts some packages
uninstall=(
  aylurs-gtk-shell
  dunst
  cachyos-hyprland-settings
  mako
  rofi
  wallust-git
  rofi-lbonn-wayland
  rofi-lbonn-wayland-git
)



if ! source "$(dirname "$(readlink -f "$0")")/logger.sh"; then
  echo "Failed to source logger.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG_FILE="Install-Logs/install-$(date +%d-%H%M%S)_hypr-pkgs.log"
SET_LOG_FILE "$LOG_FILE"

if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  ERROR "Failed to source Global_functions.sh"
  exit 1
fi


# conflicting packages removal
overall_failed=0
NOTE "Removing some packages as it conflicts with KooL's Hyprland Dots"

for PKG in "${uninstall[@]}"; do
  uninstall_package "$PKG" 2>&1 | tee -a "$LOG_FILE"
  if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    overall_failed=1
  fi
done

if [ $overall_failed -ne 0 ]; then
  ERROR "Some packages failed to uninstall. Please check the log."
fi

printf "\n%.0s" {1..1}

# Installation of main components
NOTE "Installing KooL's Hyprland necessary packages ...."

for PKG1 in "${hypr_package[@]}" "${hypr_package_2[@]}" "${Extra[@]}"; do
  install_package "$PKG1"
done

printf "\n%.0s" {1..2}

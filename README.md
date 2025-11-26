# Dotfiles
Personal Dotfiles Configuration

## Overview
This repository contains my personal configuration files for Hyprland and various applications on Arch Linux.

## Dependencies

### Core System
```bash
# Update system first
sudo pacman -Syu

# Install Hyprland and core dependencies
sudo pacman -S hyprland hyprpaper hypridle hyprlock hyprshade xdg-desktop-portal-hyprland swaync

# Display and graphics
sudo pacman -S wl-clipboard wl-clip-persist cliphist grim slurp swappy

# Audio
sudo pacman -S pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol

# Notifications
sudo pacman -S swaync libnotify

# Terminal and shell
sudo pacman -S kitty starship tmux

# File managers and utilities
sudo pacman -S nautilus yazi

# Status bar
sudo pacman -S waybar

# Text editor
sudo pacman -S neovim zed

# Color management
sudo pacman -S python-pywal

# Other utilities
sudo pacman -S fastfetch brightnessctl playerctl pamixer wofi
```

### AUR Packages
```bash
# Install yay (AUR helper) if not installed
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

# Install AUR packages
yay -S hyprpicker
yay -S vicinae-bin  # If using vicinae
yay -S cava  # Audio visualizer (if needed)
```

### Fonts Installation
```bash
# Install font dependencies
sudo pacman -S fontconfig

# Create fonts directory if it doesn't exist
mkdir -p ~/.local/share/fonts

# Copy custom fonts to system fonts directory
cp -r ~/.config/fonts/* ~/.local/share/fonts/

# Or install via package manager
sudo pacman -S ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono

# Refresh font cache
fc-cache -fv
```

## Installation

### Quick Install
```bash
# Clone the repository
git clone https://github.com/akiidjk/dotfiles.git ~/.config

# Make scripts executable
chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.config/hypr/scripts/wallpapers/*.sh

# Install fonts
cp -r ~/.config/fonts/* ~/.local/share/fonts/
fc-cache -fv
```

### Hyprland Installation
For a complete Hyprland setup, you can use JaKooLit's script:
```bash
git clone --depth=1 https://github.com/JaKooLit/Arch-Hyprland.git
cd Arch-Hyprland
chmod +x install.sh
./install.sh
```

## Configuration Structure

- **swaync/** - Notification daemon and notification center configuration
- **fastfetch/** - System information tool config
- **fonts/** - Custom Nerd Fonts (JetBrains Mono, Iosevka, etc.)
- **hypr/** - Hyprland window manager configuration
  - `hyprland.conf` - Main config file
  - `keybinds.conf` - Keyboard shortcuts
  - `animations.conf` - Animation settings
  - `monitors.conf` - Monitor configuration
  - `scripts/` - Utility scripts
- **kitty/** - Terminal emulator configuration
- **nvim/** - Neovim configuration with Lazy.vim
- **starship.toml** - Shell prompt configuration
- **tmux/** - Terminal multiplexer config
- **vicinae/** - Window management tool config
- **wal/** - Pywal color scheme templates
- **waybar/** - Status bar configuration
- **yazi/** - Terminal file manager config
- **zed/** - Zed editor configuration

## Post-Installation

### Set up user directories
```bash
xdg-user-dirs-update
```

### Start Hyprland
```bash
# From TTY
Hyprland

# Or enable display manager
sudo systemctl enable sddm
sudo systemctl start sddm
```

## Keybindings

### Applications & Scripts
| Keybind | Action |
|---------|--------|
| `SUPER + RETURN` | Open terminal (Kitty) |
| `SUPER + E` | Open file manager (Nautilus) |
| `ALT + L` | Lock screen (swaylock) |
| `SUPER + R` | Reload Waybar |
| `SUPER + W` | Set wallpaper + color schema |
| `SUPER + SHIFT + C` | Open color picker (hyprpicker) |
| `SUPER + SHIFT + S` | Screenshot area (grim + slurp + swappy) |
| `SUPER + K` | Hide waybar |

### Media Controls
| Keybind | Action |
|---------|--------|
| `CTRL + SHIFT + A` | Play/Pause media |
| `CTRL + SHIFT + D` | Next track |
| `CTRL + SHIFT + S` | Previous track |

### Window Management
| Keybind | Action |
|---------|--------|
| `SUPER + Q` | Close active window |
| `SUPER + F` | Fullscreen (keep bar visible) |
| `SUPER + SHIFT + F` | Fullscreen (hide everything) |
| `SUPER + T` | Toggle floating mode |
| `SUPER + J` | Toggle split direction |
| `SUPER + Arrow Keys` | Move focus between windows |
| `SUPER + SHIFT + Arrow Keys` | Resize active window |

### Workspace Management
| Keybind | Action |
|---------|--------|
| `SUPER + [1-9,0]` | Switch to workspace 1-10 |
| `SUPER + SHIFT + [1-9,0]` | Move window to workspace 1-10 |
| `SUPER + TAB` | Switch to previous workspace |
| `SUPER + ALT + Left/Right` | Switch to prev/next workspace |
| `SUPER + Left/Right` | Switch to prev/next workspace |
| `SUPER + Mouse Wheel` | Scroll through workspaces |

### Mouse Actions
| Keybind | Action |
|---------|--------|
| `SUPER + LMB (drag)` | Move window |
| `SUPER + RMB (drag)` | Resize window |

### System Controls (Laptop)
| Keybind | Action |
|---------|--------|
| `XF86AudioRaiseVolume` | Increase volume by 5% |
| `XF86AudioLowerVolume` | Decrease volume by 5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86MonBrightnessUp` | Increase brightness by 30% |
| `XF86MonBrightnessDown` | Decrease brightness by 30% |

For the complete keybinding configuration, see `~/.config/hypr/keybinds.conf`

## Resources

- **Hyprland Installation**: https://github.com/JaKooLit/Arch-Hyprland.git
- **Nerd Fonts**: https://www.nerdfonts.com/
- **Hyprland Wiki**: https://wiki.hyprland.org/
- **Arch Wiki**: https://wiki.archlinux.org/

## Credits

Based on various dotfile configurations and customized for personal use.

- [JaKooLit - Arch Hyprland Installer](https://github.com/JaKooLit/Arch-Hyprland)
- [Invincible-Dots by mkhmtolzhas](https://github.com/mkhmtolzhas/Invincible-Dots)
- [dots by 1amSimp1e (Hyprland section)](https://github.com/1amSimp1e/dots?tab=readme-ov-file#hypr)

## License

Feel free to use and modify as needed.

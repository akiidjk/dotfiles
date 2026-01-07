https://github.com/user-attachments/assets/62f05d78-2d2d-497f-88f0-93c0326aff3a

# Hyprland Dotfiles for Arch based distro
This repository contains my personal configuration files for Hyprland on Arch.

<img width="1920" height="1080" alt="img1" src="https://github.com/user-attachments/assets/5dc2aa3e-436f-4930-ad90-bf7a8b87f3b6" />

## Quick Install

> [!Warning]
> This script do a full installation of the dotfiles and required packages included Hyprland and SDDM.
> It will overwrite existing configuration files in your home directory.

```bash
# Clone the repository
git clone https://github.com/akiidjk/dotfiles.git

# Copy dotfiles to home directory
cd dotfiles

chmod +x install.sh
./install.sh
```

## Manual Installation Steps

### Dependencies

> [!Warning]
>
> Also note that some packages may have additional dependencies that need to be installed separately.
> Please refer to the official documentation of each package for more details.
> This setup is tailored for Arch Linux; adjustments may be needed for other distributions.
> Some packages are installed via AUR, so ensure you have an AUR helper like `yay` installed.
> This setup assumes you have basic knowledge of Linux command line and package management.
> Make sure to back up your existing configuration files before applying these dotfiles.

<img width="1919" height="1080" alt="img2" src="https://github.com/user-attachments/assets/4202681a-0c3f-46de-9b15-c2c2554fbe16" />

### Core System dependencies
```bash
# Update system first
sudo pacman -Syu

# Install Hyprland and core dependencies
sudo pacman -S hyprland hypridle hyprlock xdg-desktop-portal-hyprland hyprpolkitagent
# Display and graphics
sudo pacman -S wl-clipboard wl-clip-persist cliphist grim slurp swappy

# Audio
sudo pacman -S pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol

# Blue light filter
sudo pacman -S hyprsunset

# Notifications
sudo pacman -S mako libnotify

# Terminal and shell
sudo pacman -S kitty starship tmux

# File managers and utilities
sudo pacman -S nautilus yazi

# Shell
sudo pacman -S quickshell

# Text editor
sudo pacman -S vim neovim zed

# Color management
yay -S matugen

# Other utilities
sudo pacman -S fastfetch brightnessctl playerctl pamixer wofi fzf ripgrep bat eza jless
```

### AUR Packages
```bash
# Install yay (AUR helper) if not installed

# Browser
yay -S zen-browser-bin

# Install AUR packages
yay -S hyprpicker vicinae-bin cava awww
```

### Fonts Installation
```bash
# Install font dependencies
sudo pacman -S adobe-source-code-pro-fonts \
  noto-fonts-emoji \
  otf-font-awesome \
  ttf-droid \
  ttf-fira-code \
  ttf-fantasque-nerd \
  ttf-jetbrains-mono \
  ttf-jetbrains-mono-nerd \
  ttf-nerd-fonts-symbols-mono \
  ttf-victor-mono \
  ttf-nerd-fonts-symbols \ 
  noto-fonts \
  fontconfig \

mkdir -p ~/.local/share/fonts
cp -r ~/.config/fonts/* ~/.local/share/fonts/

# Refresh font cache
fc-cache -fv
```

### Spicitify setup
```bash
# Install
sudo pacman -S spotify-launcher spicetify-cli

# Installing marketplace
curl -fsSL https://raw.githubusercontent.com/khanhas/spicetify-cli/main/install.sh | bash

# Permission fixes (I am not sure is this required)
sudo chmod a+wr .local/share/spotify-launcher/install/usr/share/spotify/
sudo chmod a+wr .local/share/spotify-launcher/install/usr/share/spotify/ -R
```
### SDDM setup
```bash
# Install SDDM
sudo pacman -S sddm qt6-5compat qt6-svg qqc2-desktop-style inter-font ttf-nerd-fonts-symbols

# Enable SDDM service
sudo systemctl enable sddm.service

# Set SDDM theme
sudo cp -r ~/.config/sddm/faces /usr/share/sddm/
sudo cp -r ~/.config/sddm/themes/pixel /usr/share/sddm/themes/
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=pixel" | sudo tee /etc/sddm.conf
```

## Post installation

### Hyprplugin download
```bash
sudo pacman -S cmake # Required for hyprpm
hyprpm update
hyprpm add https://github.com/virtcode/hypr-dynamic-cursors
hyprpm enable dynamic-cursors
```

### Zen Browser setup

Once installed via yay, you can set Zen Browser as your default browser and import your previous settings.

### Setup: 
  - import your bookmarks and settings from your previous browser.
  - customize Zen Browser settings to your preference.
  - import zen mods from .config/.zen/zen-mods-export.json

<img width="1919" height="1078" alt="image" src="https://github.com/user-attachments/assets/88f133a2-45ae-4d2a-95f5-6a4537753ef9" />


<img width="1918" height="1080" alt="image" src="https://github.com/user-attachments/assets/4063159a-4010-4fd1-b877-88e3917ef7af" />

### Setup default mime apps
```bash
# PDF → Zen Browser
xdg-mime default zen.desktop application/pdf

# Images → loupe
xdg-mime default loupe.desktop image/jpeg
xdg-mime default loupe.desktop image/png
xdg-mime default loupe.desktop image/webp
xdg-mime default loupe.desktop image/gif

# SVG → Zen Browser
xdg-mime default zen.desktop image/svg+xml

# Video → mpv
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/x-msvideo

# Audio → mpv
xdg-mime default mpv.desktop audio/mpeg
xdg-mime default mpv.desktop audio/mp3
xdg-mime default mpv.desktop audio/wav
xdg-mime default mpv.desktop audio/flac
xdg-mime default mpv.desktop audio/ogg
xdg-mime default mpv.desktop audio/aac
xdg-mime default mpv.desktop audio/x-m4a
xdg-mime default mpv.desktop audio/webm

# Source code (generic) → Zed
xdg-mime default zed.desktop text/x-source
xdg-mime default zed.desktop text/x-script

# Common programming languages → Zed
xdg-mime default zed.desktop text/x-python
xdg-mime default zed.desktop text/x-c
xdg-mime default zed.desktop text/x-csrc
xdg-mime default zed.desktop text/x-chdr
xdg-mime default zed.desktop text/x-c++
xdg-mime default zed.desktop text/x-c++src
xdg-mime default zed.desktop text/x-java
xdg-mime default zed.desktop text/x-go
xdg-mime default zed.desktop text/x-rustsrc
xdg-mime default zed.desktop text/x-php
xdg-mime default zed.desktop text/x-shellscript
xdg-mime default zed.desktop application/javascript
xdg-mime default zed.desktop text/javascript
xdg-mime default zed.desktop text/css
xdg-mime default zed.desktop text/html
```

## Shell Configuration (`.zshrc`)

This section documents the complete Zsh configuration including Oh-My-Zsh plugins, custom aliases, and productivity enhancements defined in [`.zshrc`](./dotfiles/.zshrc).

### Oh-My-Zsh Plugins

The configuration uses Oh-My-Zsh with the following plugins enabled:

- **aliases** - Manage and list aliases
- **cp** - Safe copy with progress bar
- **zsh-autosuggestions** - Fish-like autosuggestions
- **zsh-syntax-highlighting** - Syntax highlighting for commands
- **git** - Git aliases and functions
- **docker** - Docker command completion
- **last-working-dir** - Remember last working directory
- **history-substring-search** - Search history with substrings
- **history** - Enhanced history management
- **pylint** - Python linting support
- **pip** - Python package manager completion
- **golang** - Go language support
- **ssh** - SSH completion and helpers
- **encode64** - Base64 encoding/decoding
- **extract** - Universal archive extractor

### Enhanced Shell Tools

- **Starship** - Modern, fast, and customizable prompt
- **Zoxide** - Smarter `cd` command that learns your habits
- **FZF** - Fuzzy finder for history and file search (CTRL+R for history)
  - Configured with `bat` preview in a 60% right split
  - Shows syntax-highlighted previews of files

### Standard Aliases

| Alias           | Command / Description                                                                                   |
|-----------------|-------------------------------------------------------------------------------------------------------|
| `cd`            | `z` - Zoxide replacement for cd (learns frequently used directories)                                   |
| `ls`            | `eza --icons` — List files with icons (modern `ls` replacement)                                        |
| `ll`            | `eza -al --icons` — List all files (including hidden) in long format with icons                       |
| `ltr`           | `eza -a --tree --level=1 --icons` — Tree view of files/folders, one level deep, with icons            |
| `c`             | `clear` — Clear the terminal                                                                          |
| `cat`           | `bat` — Show file contents with syntax highlighting and paging                                         |
| `activate`      | `source ~/.venv/bin/activate` — Activate Python virtual environment                                   |
| `vimage`        | `kitty +kitten icat` — Display images directly in Kitty terminal                                      |
| `cpu`           | `auto-cpufreq --stats` — Show CPU frequency and stats                                                 |
| `zed`           | `zeditor` — Launch Zed editor                                                                         |

### Docker Aliases

| Alias           | Command                                  | Description                    |
|-----------------|------------------------------------------|--------------------------------|
| `docker-start`  | `sudo systemctl start docker.service`    | Start Docker daemon            |
| `docker-stop`   | `sudo systemctl stop docker.service`     | Stop Docker daemon             |
| `docker-status` | `sudo systemctl status docker.service`   | Show Docker service status     |

### VPN Aliases

| Alias           | Command                                                                         | Description                |
|-----------------|---------------------------------------------------------------------------------|----------------------------|
| `start-vpn`     | `sudo openvpn --config <path_to_config> --auth-user-pass <path_to_creds>`      | Start VPN connection       |
| `stop-vpn`      | `sudo killall openvpn`                                                          | Stop all OpenVPN processes |

### Network Forwarding Aliases

| Alias          | Command                              | Description                              |
|----------------|--------------------------------------|------------------------------------------|
| `up_forward`   | `nmcli connection up eth-shared`     | Enable WiFi to Ethernet forwarding       |
| `down_forward` | `nmcli connection down eth-shared`   | Disable WiFi to Ethernet forwarding      |

### Suffix Aliases

Suffix aliases automatically open files with specific extensions using designated programs:

| Extension | Opens With | Description                              |
|-----------|------------|------------------------------------------|
| `.json`   | `jless`    | Interactive JSON viewer                  |
| `.md`     | `mdcat`    | Markdown renderer for terminal           |
| `.go`     | `$EDITOR`  | Go source files in default editor        |
| `.zig`    | `$EDITOR`  | Zig source files in default editor       |
| `.txt`    | `bat`      | Text files with syntax highlighting      |
| `.log`    | `bat`      | Log files with syntax highlighting       |
| `.py`     | `$EDITOR`  | Python files in default editor           |
| `.js`     | `$EDITOR`  | JavaScript files in default editor       |
| `.ts`     | `$EDITOR`  | TypeScript files in default editor       |

**Usage**: Simply type the filename: `example.json` instead of `jless example.json`

### Global Aliases

Global aliases can be used anywhere in a command, not just at the beginning:

| Alias | Expansion                  | Description                                   | Example                          |
|-------|----------------------------|-----------------------------------------------|----------------------------------|
| `NE`  | `2>/dev/null`              | Redirect stderr to /dev/null                  | `command NE`                     |
| `NO`  | `>/dev/null`               | Redirect stdout to /dev/null                  | `command NO`                     |
| `NUL` | `>/dev/null 2>&1`          | Redirect both stdout and stderr to /dev/null  | `command NUL`                    |
| `J`   | `\| jq`                    | Pipe output to jq for JSON formatting         | `curl api.example.com J`         |
| `C`   | `\| wl-copy`               | Copy command output to clipboard              | `cat file.txt C`                 |

### Shell Behavior Enhancements

- **Magic Space**: Press `Space` to expand history expressions (`!!`, `!$`, etc.)
- **Auto-ls**: Automatically runs `ls` when changing directories (via `chpwd` hook)
- **History**: 10,000 commands saved in `~/.zsh_history` with append mode

### Environment Variables

- `EDITOR`: Set to `nvim` locally, `vim` over SSH
- `LANG`: `en_US.UTF-8`
- `XDG_CONFIG_HOME`: `$HOME/.config`

### Startup

- **fastfetch** runs automatically on new shell sessions to display system information

See [`.zshrc`](./dotfiles/.zshrc) for the complete configuration.

## Some utility scripts I use in my configuration

This repository includes several utility scripts and shell aliases to make daily tasks easier and more efficient. Most scripts are located in `~/scripts/` or `~/.config/hypr/scripts/`.

### Aliases

Here are some useful aliases defined in my shell configuration:

| Alias         | Command                                                                                                                         | Description                                               |
|---------------|---------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|
| `upgradesys`    | `~/scripts/upgrade_sys.sh`                                                                                                      | Upgrade the system packages                               |
| `cleansys`      | `~/scripts/clean.sh`                                                                                                            | Clean unnecessary files from the system                   |
| `webtemplate`   | `python3 ~/scripts/webtemplate/main.py`                                                                                         | Generate a basic web template                             |
| `togglemirror`  | `~/scripts/toggle_mirror.sh`                                                                                                    | Toggle display mirror                                     |
| `webup`         | `python3 -m http.server 6969`                                                                                                   | Start a simple web server on port 6969                    |
| `pymain`        | `echo -e "\n\ndef main():\n    pass\n\nif __name__ == \"__main__\":\n    main()" > main.py`                                    | Create a basic Python main function template in main.py   |
| `mp4ToMov`      | `~/scripts/mp4ToMov.sh`                                                                                                         | Convert MP4 files to MOV format                           |
| `movToMp4`      | `~/scripts/movToMp4.sh`                                                                                                         | Convert MOV files to MP4 format                           |

<img width="1692" height="960" alt="img5" src="https://github.com/user-attachments/assets/0140de84-fa86-487f-8d7d-8a5215fcf792" />

## Configuration Structure

- **mako/** - Notification daemon
- **matugent/** - Color scheme generator config
- **fastfetch/** - System information tool config
- **fonts/** - Custom Nerd Fonts (JetBrains Mono, Iosevka, etc.)
- **hypr/** - Hyprland window manager configuration
  - `hyprland.conf` - Main config file
  - `keybinds.conf` - Keyboard shortcuts
  - `animations.conf` - Animation settings
  - `monitors.conf` - Monitor configuration
  - `hypridle.conf` - Config for hypridle
  - `autostart.conf` - All startup script and app to run
  - `hyprcolors.conf` - Color configuration with pywal
  - `hyprlock.conf` - Hyprlock config
  - `vicinae.conf` - Vicinae config
  - `plugins.conf` - Hyprland plugin config
  - `windowrule.conf` - Window rule for hyprland
  - `scripts/` - Utility scripts
- **kitty/** - Terminal emulator configuration
- **nvim/** - Neovim configuration with Lazy.vim
- **starship.toml** - Shell prompt configuration
- **tmux/** - Terminal multiplexer config
- **vicinae/** - Window management tool config
- **quickshell/** - Status bar configuration + hub
- **yazi/** - Terminal file manager config
- **zed/** - Zed editor configuration
- **wallpaper/** - Collection of wallpaper and images used in the configuration

### Start Hyprland
```bash
# From TTY
start-hyprland

# Or enable display manager
sudo systemctl enable sddm
sudo systemctl start sddm
```

## Keybindings

### Applications & Scripts
| Keybind | Action |
|---------|--------|
| `SUPER + RETURN` | Open terminal (kitty) |
| `SUPER + SPACE` | Open launcher (vicinae) |
| `SUPER + E` | Open file manager (nautilus) |
| `SUPER + B` | Open browser (zen-browser) |
| `SUPER + Z` | Open text editor (zed) |
| `ALT + L` | Lock screen (hyprlock) |
| `SUPER + R` | Reload Waybar |
| `SUPER + W` | Set wallpaper + color schema |
| `SUPER + SHIFT + C` | Open color picker (hyprpicker) |
| `SUPER + SHIFT + S` | Screenshot area (grim + slurp + swappy) |
| `SUPER + K` | Hide status bar |
| `SUPER + N` | Show shell hub |

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
| `SUPERSHIFT + Q` | Quit Hyprland |
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
| `SUPERSHIFT + M` | Enable night-mode |

For the complete keybinding configuration, see `~/.config/hypr/keybinds.conf`

<img width="1919" height="1080" alt="image" src="https://github.com/user-attachments/assets/b1737917-ce02-4572-8761-3bb25ea17904" />


## Resources

- **Hyprland Installation**: https://github.com/JaKooLit/Arch-Hyprland.git
- **Nerd Fonts**: https://www.nerdfonts.com/
- **Hyprland Wiki**: https://wiki.hyprland.org/
- **Arch Wiki**: https://wiki.archlinux.org/
- **Oh My Zsh**: https://ohmyz.sh/
- **Starship Prompt**: https://starship.rs/
- **Quickshell**: https://quickshell.org/

## Todo

- [ ] Better Wallpaper selector
- [ ] Keybinds Help menu
- [ ] Check swaync animation

## Credits

Based on various dotfile configurations and customized for personal use.

- [JaKooLit - Arch Hyprland Installer (Base of installer)](https://github.com/JaKooLit/Arch-Hyprland)
- [Invincible-Dots by mkhmtolzhas](https://github.com/mkhmtolzhas/Invincible-Dots)
- [dots by 1amSimp1e (Hyprland section)](https://github.com/1amSimp1e/dots?tab=readme-ov-file#hypr)
- [Surface-dots by snes19xx](https://github.com/snes19xx/surface-dots)

## License

Feel free to use and modify as needed (btw tag me, i want to see the edits).

https://github.com/user-attachments/assets/d4ee26ca-e82c-40df-b5a7-f257a6471f7e


# Hyprland Dotfiles for Arch based distro
This repository contains my personal configuration files for Hyprland on Arch.

<img width="1920" height="1080" alt="swappy-20260913_155508" src="https://github.com/user-attachments/assets/b7f824d9-2e52-4872-89aa-9a981e6f0936" />




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

<img width="1920" height="1080" alt="swappy-20260913_171810" src="https://github.com/user-attachments/assets/c943c8ca-57b1-4801-b4ea-5672378ecaca" />

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
<img width="1918" height="1080" alt="swappy-20260831_222345" src="https://github.com/user-attachments/assets/27a3aed6-d91b-4fe8-91ee-01b0aff19f95" />
<img width="1920" height="1080" alt="swappy-20260913_171941" src="https://github.com/user-attachments/assets/b45a2c1e-1dcf-43c5-a07d-4582f0a88f16" />

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


<img width="1918" height="1077" alt="swappy-20260831_223410" src="https://github.com/user-attachments/assets/405b7e88-a3cc-4ab0-8801-8e09f1c29637" />


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

Simple run `SUPER + K`

<img width="1919" height="1080" alt="swappy-20260913_172045" src="https://github.com/user-attachments/assets/a977171d-145e-4ce8-93eb-542fe580d716" />
## Resources

- **Hyprland Installation**: https://github.com/JaKooLit/Arch-Hyprland.git
- **Nerd Fonts**: https://www.nerdfonts.com/
- **Hyprland Wiki**: https://wiki.hyprland.org/
- **Arch Wiki**: https://wiki.archlinux.org/
- **Oh My Zsh**: https://ohmyz.sh/
- **Starship Prompt**: https://starship.rs/
- **Quickshell**: https://quickshell.org/

## Credits

Based on various dotfile configurations and customized for personal use.

- [JaKooLit - Arch Hyprland Installer (Base of installer)](https://github.com/JaKooLit/Arch-Hyprland)

## License

Feel free to use and modify as needed (btw tag me, i want to see the edits).

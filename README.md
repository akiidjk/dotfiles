https://github.com/user-attachments/assets/d4ee26ca-e82c-40df-b5a7-f257a6471f7e


# Hyprland Dotfiles for Arch based distro
My Hyprland setup for Arch, with the install scripts and my fork of the MacShell desktop shell.

<img width="1920" height="1080" alt="swappy-20260913_155508" src="https://github.com/user-attachments/assets/b7f824d9-2e52-4872-89aa-9a981e6f0936" />




## Quick Install

> [!Warning]
> `install.sh` installs everything, Hyprland and SDDM included, and then copies these configs over the ones in your home.
> Whatever it replaces gets backed up to `~/dotfiles-backup-<date>` first.

```bash
# Clone the repository
git clone https://github.com/akiidjk/dotfiles.git

# Run the installer
cd dotfiles

chmod +x install.sh
./install.sh
```

## Manual Installation Steps

### Dependencies

> [!Warning]
>
> Some packages pull in dependencies you'll have to install yourself, so check their docs when something is missing.
> It's all written for Arch. Other distros will need changes.
> A few packages come from the AUR, which means you need an AUR helper like `yay`.
> Back up your own configs before copying these over.

<img width="1920" height="1080" alt="swappy-20260913_171810" src="https://github.com/user-attachments/assets/c943c8ca-57b1-4801-b4ea-5672378ecaca" />

### Core System dependencies
```bash
# Update system first
sudo pacman -Syu

# Install Hyprland (0.55+, Lua config) and core dependencies
# hyprlock is not the locker: MacLock checks the password through its PAM file (/etc/pam.d/hyprlock)
sudo pacman -S hyprland hypridle hyprlock xdg-desktop-portal-hyprland hyprpolkitagent
# Display and graphics
sudo pacman -S wl-clipboard wl-clip-persist cliphist grim slurp swappy

# Audio
sudo pacman -S pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol

# Blue light filter
sudo pacman -S hyprsunset

# Notifications (the daemon is MacShell itself: do not install mako / dunst / swaync)
sudo pacman -S libnotify

# Terminal and shell
sudo pacman -S kitty starship tmux

# File managers and utilities
sudo pacman -S nautilus yazi

# Desktop shell: MacShell + MacLock (Quickshell)
sudo pacman -S quickshell qt6-declarative qt6-wayland qt6-svg qt6-shadertools \
  ffmpeg zenity inotify-tools power-profiles-daemon wf-recorder wtype python-numpy papirus-icon-theme \
  tesseract tesseract-data-eng zbar pacman-contrib
sudo systemctl enable --now power-profiles-daemon bluetooth

# Text editor
sudo pacman -S vim neovim zed

# Color management
yay -S matugen

# Other utilities
sudo pacman -S fastfetch brightnessctl playerctl pamixer fzf ripgrep bat eza jless
```

### AUR Packages
```bash
# Install yay (AUR helper) if not installed

# Browser
yay -S zen-browser-bin

# Install AUR packages
yay -S hyprpicker vicinae-bin cava awww mpvpaper
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
  fontconfig

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

# Permission fixes (not sure this is still needed)
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

### MacShell first run
```bash
# UI sounds (synthesized into ~/.local/share/sounds/macshell)
python3 ~/.config/hypr-macshell/scripts/macshell-make-sounds.py
# first wallpaper + matugen theme (afterwards just use Super+W)
~/.config/hypr/scripts/wallpapers/apply.sh ~/.config/wallpapers/decline.png
```
Then log in to Hyprland. `hypr/macshell.lua` starts the shell (`qs -c MacShell`).

### Claude Code hooks
Only if you use Claude Code. The installer sets it up when it finds Claude Code, and you can run it yourself with `bash ~/.config/hypr-macshell/scripts/claude-setup.sh`. Running it twice adds nothing twice, and the previous file stays around as `settings.json.bak`. It needs `jq` and puts this in `~/.claude/settings.json`:
```json
{
  "statusLine": { "type": "command", "command": "bash ~/.config/hypr-macshell/scripts/claude-statusline.sh" },
  "hooks": {
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "bash ~/.config/hypr-macshell/scripts/claude-island.sh start" }] }],
    "Stop":             [{ "hooks": [{ "type": "command", "command": "bash ~/.config/hypr-macshell/scripts/claude-island.sh stop" }] }],
    "Notification":     [{ "hooks": [{ "type": "command", "command": "bash ~/.config/hypr-macshell/scripts/claude-island.sh notify" }] }]
  }
}
```
`claude-statusline.sh` writes the plan limits to `~/.cache/macshell/claude-limits.json`, then hands off to the [ponytail](https://github.com/DietrichGebert/ponytail) status line if you have that plugin. Turns shorter than `CLAUDE_ISLAND_MIN` seconds (20 by default) aren't reported.

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

The plugins, aliases and tweaks in [`.zshrc`](./.zshrc).

### Oh-My-Zsh Plugins

I run Oh-My-Zsh with these plugins:

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

- **Starship** - The prompt
- **Zoxide** - A `cd` that remembers the directories you use
- **FZF** - Fuzzy finder for history and file search (CTRL+R for history)
  - Configured with `bat` preview in a 60% right split
  - Shows syntax-highlighted previews of files

### Standard Aliases

| Alias           | Command / Description                                                                                   |
|-----------------|-------------------------------------------------------------------------------------------------------|
| `cd`            | `z` - Zoxide replacement for cd (learns frequently used directories)                                   |
| `ls`            | `eza --icons` - List files with icons (modern `ls` replacement)                                        |
| `ll`            | `eza -al --icons` - List all files (including hidden) in long format with icons                       |
| `ltr`           | `eza -a --tree --level=1 --icons` - Tree view of files/folders, one level deep, with icons            |
| `c`             | `clear` - Clear the terminal                                                                          |
| `cat`           | `bat` - Show file contents with syntax highlighting and paging                                         |
| `activate`      | `source ~/.venv/bin/activate` - Activate Python virtual environment                                   |
| `vimage`        | `kitty +kitten icat` - Display images directly in Kitty terminal                                      |
| `cpu`           | `auto-cpufreq --stats` - Show CPU frequency and stats                                                 |
| `zed`           | `zeditor` - Launch Zed editor                                                                         |

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

Type a file name on its own and zsh opens it with the program for its extension:

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

So `example.json` alone runs `jless example.json`.

### Global Aliases

Global aliases expand anywhere in a command, the end included:

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

- **fastfetch** prints the system info in every new shell

The rest is in [`.zshrc`](./.zshrc).

## Some utility scripts I use in my configuration

A few scripts I use every day. Most of them sit in `~/scripts/` or `~/.config/hypr/scripts/`.

### Aliases

The aliases that run them, plus a couple of extras:

| Alias         | Command                                                                                                                         | Description                                               |
|---------------|---------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|
| `upgradesys`    | `~/scripts/upgrade_sys.sh`                                                                                                      | Upgrade the system packages                               |
| `cleansys`      | `~/scripts/clean.sh`                                                                                                            | Clean unnecessary files from the system                   |
| `webtemplate`   | `python3 ~/scripts/webtemplate/main.py`                                                                                         | Generate a basic web template                             |
| `togglemirror`  | `~/scripts/toggle_mirror.sh`                                                                                                    | Toggle display mirror                                     |
| `webup`         | `python3 -m http.server 6969`                                                                                                   | Start a simple web server on port 6969                    |
| `pymain`        | `echo -e "\n\ndef main():\n    pass\n\nif __name__ == \"__main__\":\n    main()" > main.py`                                    | Create a basic Python main function template in main.py   |


<img width="1918" height="1077" alt="swappy-20260831_223410" src="https://github.com/user-attachments/assets/405b7e88-a3cc-4ab0-8801-8e09f1c29637" />


## Desktop shell: MacShell (akiidjk edition)

The shell is my fork of [MacShell](https://github.com/0-ss/MacShell), a macOS-looking Quickshell shell with Liquid Glass. The Dock, Control Center, notifications, widgets, window switcher, screenshots and the MacLock lock screen (idle, suspend, lid close, `Alt+L`) come from upstream. Everything below is mine.

### Dynamic Island

It takes the middle of the menu bar, where the workspaces used to be. Turn it off and they come back. Settings → Dynamic Island has two styles. **Notch** hangs black from the top edge of the screen, like a MacBook. **Dynamic Island** is the floating pill from the iPhone, and you can park it anywhere from flush with the screen top to 40 px under the bar.

The same page tunes the rest: position, height (10 to 48 px, or auto), idle width, size when open, corner radius, how fast it opens and how hard it bounces, hiding it when there's nothing to show, opening on hover, how long a new track stays up, an outline, synced lyrics and how early each line appears, how long activities last, plus one switch per kind of activity.

Inside it you get the player with synced lyrics, running timers and screen recordings, and short activities like workspace switches, battery, Bluetooth, Wi-Fi, input source, mic and camera, downloads, updates and system alerts. Scripts can post their own with `qs -c MacShell ipc call island notify "title" "subtitle" ""`. The zsh hook does exactly that for any command that ran 15 s or more. Style, position and height have IPC calls too, `island setStyle notch|island`, `island setOffset <px>` and `island setHeight <px>` (0 is auto).

### Claude Code in the island

Once a Claude Code turn has run 20 s or more, the island tells you it's done ("✓ Claude · project 1m 35s"). Permission prompts show up as "Claude needs you". Hover and you get the plan limits for the 5-hour window and the week, each with its reset time. It needs three hooks and a status line, see [Claude Code hooks](#claude-code-hooks).

### Menu bar extras

Three widgets, all off until you switch them on in Settings → Menu Bar (or with `qs -c MacShell ipc call bar setWidget <stats|updates|ports> true`). **Stats** is CPU, RAM and temperature. **Updates** checks pacman and the AUR every hour, only appears when there's something to install, and opens `yay` in a terminal from its popover. **Ports** lists what's listening on TCP, with the process behind each port and a button to kill it. A muted mic (`SUPER + SHIFT + M`) gets a red icon next to the privacy dots.

System alerts live in Settings → Notifications. If the CPU runs hot or memory stays nearly full for a whole minute, or a disk drops under the free-space threshold, the island says so, once every 15 minutes at most.

### Smaller things

`SUPER + SHIFT + N` opens the Scratchpad, a single note saved as you type to `~/.local/share/macshell/scratchpad.md`, with a Markdown preview. `SUPER + SHIFT + T` lets you drag over part of the screen and copies the text in it through tesseract, or the content of a QR code when there is one. Clean URL strips `utm_*`, `fbclid`, `gclid` and the YouTube / Spotify `si` from every link you copy (`hypr/scripts/clean-url.py`, started from `autostart.lua`).

Vicinae is the only launcher, so MacShell's Spotlight is gone along with its clipboard and emoji panels, and the shell is English only. The keybind viewer and the wallpaper picker are mine, drawn in the same Liquid Glass style. Wallpapers and colors go through one script, `hypr/scripts/wallpapers/apply.sh`. It runs matugen and awww and recolors kitty, Hyprland, btop, spicetify and the MacShell accent (Settings → Appearance → Accent, the white-dot swatch) without restarting anything.

Don't run MacShell's own `install.sh` or `macshell-update`. They'd overwrite the fork.

## Configuration Structure

- **matugen/** - Color scheme generator config (templates: kitty, Hyprland, btop, spicetify, MacShell accent)
- **fastfetch/** - System information tool config
- **fonts/** - Custom Nerd Fonts (JetBrains Mono, Iosevka, etc.)
- **hypr/** - Hyprland window manager configuration (Lua, 0.55+)
  - `hyprland.lua` - Main config file (requires the modules below)
  - `keybinds.lua` - Keyboard shortcuts
  - `macshell.lua` - MacShell / MacLock: autostart, shell keybinds, hardware keys, layer and window rules
  - `animation.lua` - Animation settings
  - `monitors.lua` - Monitor configuration (nwg-displays)
  - `input.lua` - Keyboard / mouse / touchpad
  - `hypridle.conf` - Idle + sleep → MacLock
  - `autostart.lua` - Startup scripts and apps
  - `hyprcolors.lua` + `colors.lua` - Colors (`colors.lua` is generated by matugen)
  - `vicinae.lua` - Vicinae launcher
  - `windowrule.lua` - Window rules
  - `hyprland-gui.lua` - Settings managed by HyprMod
  - `hyprshade.toml` - Screen shaders (hyprshade timer)
  - `scripts/` - Utility scripts (`wallpapers/apply.sh`, night mode, color picker, mirror, screensharing, Spotify notifications, `screen-text.sh` OCR / QR, `clean-url.py`)
- **hypr-macshell/scripts/** - MacShell helpers (video wallpapers, UI sound generator, SDDM theme, `claude-island.sh` + `claude-statusline.sh` for Claude Code)
- **quickshell/MacShell/** - The shell, my fork. The island, keybind viewer, wallpaper picker and scratchpad are the `Island*`, `KeybindsPanel`, `WallPickerPanel` and `ScratchpadPanel` files
- **quickshell/MacLock/** - The lock screen
- **kitty/** - Terminal emulator configuration
- **nvim/** - Neovim configuration with Lazy.vim
- **starship.toml** - Shell prompt configuration
- **tmux/** - Terminal multiplexer config
- **vicinae/** - Launcher config
- **yazi/** - Terminal file manager config
- **zed/** - Zed editor configuration
- **wallpapers/** - The wallpapers and images used here

### Start Hyprland
```bash
# From TTY
start-hyprland

# Or enable display manager
sudo systemctl enable sddm
sudo systemctl start sddm
```

## Keybindings

`SUPER + K` (or Help → Hyprland Keybinds in the menu bar) lists every bind. These are the shell ones:

| Keys | Action |
|------|--------|
| `SUPER + Space` | vicinae |
| `SUPER + K` | Keybind viewer |
| `SUPER + W` | Wallpaper picker |
| `SUPER + H` | Show / hide the top bar |
| `SUPER + N` | Island hub (Control Center in menu-bar mode) |
| `SUPER + ,` | MacShell Settings |
| `ALT + L` | Lock (MacLock) |
| `ALT + TAB` | Window switcher |
| `SUPER + SHIFT + S` | Screenshot region (grim + slurp + swappy) |
| `SUPER + SHIFT + T` | Copy text / QR code from a screen area |
| `SUPER + SHIFT + N` | Scratchpad |
| `SUPER + SHIFT + M` | Mute / unmute the microphone |

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

Started from other people's dotfiles and reshaped around how I work. The two I owe the most:

- [JaKooLit - Arch Hyprland Installer (Base of installer)](https://github.com/JaKooLit/Arch-Hyprland)
- [0-ss/MacShell](https://github.com/0-ss/MacShell) - the shell and lock screen this setup forks (Rickky and vSuol)

## License

Feel free to use and modify as needed (btw tag me, i want to see the edits).

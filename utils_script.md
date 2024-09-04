# Utils script

## Install Hyprland

```bash
git clone --depth=1 https://github.com/JaKooLit/Arch-Hyprland.git ~/Arch-Hyprland
cd ~/Arch-Hyprland
chmod +x install.sh
./install.sh
```

## Prerequesite for the STANDARD THEME

```bash
yay -S waybar-hyprland rofi dunst kitty swaybg swaylock-fancy-git swayidle pamixer light brillo nwg-look 
```

## Fonts

```bash
yay -S ttf-font-awesome

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/JetBrainsMono.zip

wget httpscp ://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Iosevka.zip

unzip JetBrainsMono.zip -d JetBrainsMono
unzip Iosevka.zip -d Iosevka

mv JetBrainsMono ~/.local/share/fonts
mv Iosevka ~/.local/share/fonts

rm JetBrainsMono.zip
rm Iosevka.zip

fc-cache -fv
```

## Shell

```bash
chsh -s $(which zsh)
source ~/.zshrc
```

## BlackArch Repo

Script preso da: <https://www.blackarch.org/downloads.html#install-repo>

```bash
curl -O https://blackarch.org/strap.sh
echo 26849980b35a42e6e192c6d9ed8c46f0d6d06047 strap.sh | sha1sum -c
chmod +x strap.sh
sudo ./strap.sh
sudo pacman -Syu
```


git clone 

sudo pacman -Syu

git clone --depth=1 https://github.com/JaKooLit/Arch-Hyprland.git ~/Arch-Hyprland
cd ~/Arch-Hyprland
chmod +x install.sh
./install.sh

sudo pacman -S --noconfirm mdcat bat exa fd ripgrep fzf zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions oh-my-zsh starship neovim cava btop gh mpv ngrok qimgv rofi yazi yay neofetch wget curl 7z 

yay -S waybar-hyprland rofi dunst kitty swaybg swaylock-fancy-git swayidle pamixer light brillo nwg-look

yay -S ttf-font-awesome

chsh -s $(which zsh)
source ~/.zshrc

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/JetBrainsMono.zip

wget httpscp ://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Iosevka.zip


unzip JetBrainsMono.zip -d JetBrainsMono
unzip Iosevka.zip -d Iosevka

mv JetBrainsMono ~/.local/share/fonts
mv Iosevka ~/.local/share/fonts

rm JetBrainsMono.zip
rm Iosevka.zip

fc-cache -fv





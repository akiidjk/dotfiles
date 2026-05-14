if [ ! -f "$HOME/.current_wallpaper" ]; then
    matugen image -t scheme-fidelity -m dark --source-color-index 0 ~/.config/wallpapers/decline.png --show-colors --verbose --fallback-color "#000000"
    cp ~/.config/wallpapers/decline.png ~/.current_wallpaper
fi

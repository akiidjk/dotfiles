#!/bin/bash

set -e
set -u
set -o pipefail

echo -e "\n\033[1;34m📌 Starting full system update...\033[0m\n"

echo -e "\033[1;32m🛠️  Updating system packages...\033[0m"
sudo pacman -Syu --noconfirm || { echo "❌ Pacman update failed!"; exit 1; }

if command -v yay &>/dev/null; then
    echo -e "\n\033[1;32m🛠️  Updating AUR packages...\033[0m"
    yay -Syua --noconfirm || { echo "❌ AUR update failed!"; exit 1; }
else
    echo -e "\n\033[1;33m⚠️  yay not found. Skipping AUR update.\033[0m"
fi

echo -e "\n\033[1;32m🧹 Cleaning up old packages and cache...\033[0m"
sudo paccache -rk 2 || echo "⚠️ Error cleaning pacman cache"
yay -Sc --noconfirm || echo "⚠️ Error cleaning yay cache"
sudo pacman -Rns $(pacman -Qdtq) --noconfirm || echo "✅ No orphan packages found."

echo -e "\n\033[1;34m✅ System update completed successfully!\033[0m"

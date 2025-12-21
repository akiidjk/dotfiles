#! /bin/bash

set -e  # Exit on error
set -u  # Exit on unset variables
set -o pipefail  # Exit on pipe errors

DOCKER_CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --docker)
            DOCKER_CLEAN=true
            shift
            ;;
        *)
            echo "⚠️ Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "\n\033[1;34m📌 Start the cleaning process...\033[0m\n"

# Cleaning package cache
if command -v yay &>/dev/null; then
    echo -e "\033[1;32m🗑️  Cleaning package cache...\033[0m"
    yay -Sc --noconfirm || echo "⚠️ Error cleaning yay cache"
fi
if command -v paccache &>/dev/null; then
    sudo paccache -rk 2 || echo "⚠️ Error cleaning pacman cache"
fi
sudo pacman -Scc --noconfirm || echo "⚠️ Error cleaning pacman cache"

# Cleaning system logs
echo -e "\n\033[1;32m🗑️  Cleaning system logs...\033[0m"
sudo journalctl --vacuum-time=7d || echo "⚠️ Error cleaning journal logs"
sudo find /var/log -type f -name "*.log" -mtime +7 -exec rm -f {} \; || echo "⚠️ Error cleaning old logs"

# Cleaning Docker/Podman
if [[ "$DOCKER_CLEAN" == true ]] && command -v docker &>/dev/null; then
    echo -e "\n\033[1;32m🛠️  Cleaning Docker...\033[0m"
    sudo docker system prune -a -f || echo "⚠️ Error cleaning Docker"
fi
if [[ "$DOCKER_CLEAN" == true ]] && ! command -v docker &>/dev/null; then
    echo -e "\n\033[1;33m⚠️ Docker cleanup requested but Docker is not installed.\033[0m"
fi
if command -v podman &>/dev/null; then
    echo -e "\n\033[1;32m🛠️  Cleaning Podman...\033[0m"
    podman system prune -a -f || echo "⚠️ Error cleaning Podman"
fi

# Cleaning development cache
if command -v npm &>/dev/null; then
    echo -e "\n\033[1;32m🛠️  Cleaning npm cache...\033[0m"
    npm cache clean --force || echo "⚠️ Error cleaning npm cache"
fi
if command -v pip &>/dev/null; then
    echo -e "\n\033[1;32m🛠️  Cleaning pip cache...\033[0m"
    pip cache purge || echo "⚠️ Error cleaning pip cache"
fi
if command -v cargo &>/dev/null; then
    echo -e "\n\033[1;32m🛠️  Cleaning cargo cache...\033[0m"
    rm -rf ~/.cargo/registry ~/.cargo/git || echo "⚠️ Error cleaning cargo cache"
fi

# Cleaning thumbnails
echo -e "\n\033[1;32m🖼️  Cleaning old thumbnails...\033[0m"
rm -rf ~/.cache/thumbnails/* || echo "⚠️ Error cleaning thumbnails"

# Cleaning temporary files
echo -e "\n\033[1;32m🗑️  Cleaning temporary files...\033[0m"
sudo rm -rf /tmp/* || echo "⚠️ Error cleaning /tmp"
rm -rf ~/.cache/* || echo "⚠️ Error cleaning user cache"

# Removing orphan packages
orphans=$(pacman -Qdtq || true)  # Se non ci sono orfani, non fallisce
if [[ -n "$orphans" ]]; then
    echo -e "\n\033[1;32m🔍 Removing orphan packages...\033[0m"
    sudo pacman -Rns $orphans --noconfirm || echo "⚠️ Error removing orphan packages"
else
    echo -e "\n\033[1;33m✅ No orphan packages found.\033[0m"
fi

echo -e "\n\033[1;34m✅ Cleaning process completed!\033[0m"
echo -e "\n\033[1;33m🔍 Now check large files manually using ncdu:\033[0m\n"

if command -v ncdu &>/dev/null; then
    ncdu /home
else
    echo "⚠️ ncdu not found. Install it with: sudo pacman -S ncdu"
fi

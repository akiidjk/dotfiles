#!/usr/bin/env bash

ICON_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/spotify-art"
mkdir -p "$ICON_DIR"

get_art_path() {
  # Get MPRIS art URL from Spotify
  url="$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null || echo "")"
  [ -z "$url" ] && return 1

  # Spotify sometimes uses open.spotify.com/image; map to i.scdn.co CDN if needed
  url="${url/open.spotify.com/i.scdn.co}"

  # Stable filename from URL
  hash="$(printf '%s' "$url" | sha1sum | cut -d' ' -f1)"
  file="$ICON_DIR/$hash.jpg"

  # Download only if not cached
  if [ ! -f "$file" ]; then
    curl -fsSL "$url" -o "$file" || return 1
  fi

  printf '%s\n' "$file"
}

playerctl -p spotify metadata --format '{{artist}} - {{title}}' --follow |
while read -r line; do
  icon_path="$(get_art_path)" || icon_path="spotify"

  notify-send "Spotify" "$line" -i "$icon_path"
done

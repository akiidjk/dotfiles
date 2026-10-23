#!/usr/bin/env bash
# Spotify track-change notification (shown by MacShell's notification server, with the album art).

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

last=""
playerctl -p spotify metadata --format '{{title}}	{{artist}}' --follow |
while IFS=$'\t' read -r title artist; do
  # --follow repeats the same metadata (seek, play/pause): one notification per track
  [ -z "$title" ] || [ "$title	$artist" = "$last" ] && continue
  last="$title	$artist"
  icon_path="$(get_art_path)" || icon_path="spotify"

  # -a Spotify: MacShell groups it under Spotify and keeps it silent (no system "glass" sound)
  notify-send -a Spotify -i "$icon_path" "$title" "$artist"
done

#!/bin/sh
# lyrics.sh <artist> <title> [album] [length s]  ->  {"synced","plain","instrumental"} | {} (nobody has it) | {"retry":true}
# Shared by MacLock (LockScreen.qml) and the MacShell Player widget / Dynamic Island (MacWidgets.qml).
# Sources: NetEase, LRCLIB (both length-checked), syncedlyrics if installed (Musixmatch, Megalobiz), Genius (plain).
# Cached in ~/.cache/maclock/lyrics.
a="$1"; t="$2"; al="$3"; d="${4:-0}"; c="$HOME/.cache/maclock/lyrics"; mkdir -p "$c"
k=$(printf "%s|%s" "$a" "$t" | md5sum | cut -c1-16); f="$c/$k.json"
[ -s "$f" ] && { cat "$f"; exit 0; }
tmp=$(mktemp); answered=0; r=""
bare=$(printf "%s" "$t" | sed -E "s/ *[(\[][^)\]]*[)\]]//g; s/ +- +(.*[Rr]emaster.*|[Ll]ive.*|[Rr]adio [Ee]dit.*)$//")
ne() { code=$(curl -s --max-time 6 -A "Mozilla/5.0" -o "$tmp" -w "%{http_code}" -G "https://music.163.com/api/search/get" --data-urlencode "s=$1" -d type=1 -d limit=10); [ "$code" = 200 ] || return 1; answered=1
  id=$(jq -r --arg t "$bare" --argjson d "$d" 'def n: ascii_downcase | gsub("[^\\p{L}\\p{N}]"; ""); ($t | n) as $q | [.result.songs[]? | select((.name | n) as $nm | ($nm == $q) or ($nm | startswith($q)) or ($q | startswith($nm))) | select($d == 0 or (((.duration / 1000) - $d) | fabs) <= 4)][0].id // empty' "$tmp")
  [ -n "$id" ] || return 1
  curl -s --max-time 6 -A "Mozilla/5.0" -o "$tmp" "https://music.163.com/api/song/lyric?id=$id&lv=1" || return 1
  l=$(jq -r ".lrc.lyric // empty" "$tmp"); case "$l" in *"[0"*|*"[1"*) ;; *) return 1;; esac
  r=$(jq -nc --arg l "$l" "{syncedLyrics: \$l}"); }
ne "$a $bare" || ne "$bare"
ua="MacLock/1.0 (https://github.com/0-ss/Macshell)"; api=https://lrclib.net/api
req() { n=0; while [ $n -lt 2 ]; do code=$(curl -s --max-time 8 -A "$ua" -o "$tmp" -w "%{http_code}" -G "$@"); case "$code" in 200) answered=1; return 0;; 404) answered=1; return 1;; 429) n=$((n+1)); sleep 1.5;; *) return 1;; esac; done; return 1; }
pick='[.[] | select(.syncedLyrics != null or .plainLyrics != null) | select($d == 0 or (((.duration // 0) - $d) | fabs) <= 4)] | ([.[] | select(.syncedLyrics != null)][0] // .[0]) // empty'
lsearch() { req "$api/search" "$@" && r=$(jq -c --argjson d "$d" "$pick" "$tmp"); }
[ -z "$r" ] && lsearch --data-urlencode "track_name=$t" --data-urlencode "artist_name=$a"
[ -z "$r" ] && [ "$bare" != "$t" ] && lsearch --data-urlencode "track_name=$bare" --data-urlencode "artist_name=$a"
[ -z "$r" ] && lsearch --data-urlencode "q=$a $bare"
rm -f "$tmp"
# ── optional: syncedlyrics (AUR python-syncedlyrics), only when nobody above had synced lyrics
if [ "$(printf "%s" "$r" | jq -r ".syncedLyrics // empty" 2>/dev/null)" = "" ] && python3 -c "import syncedlyrics" 2>/dev/null; then
  s=$(timeout 15 python3 -c 'import sys, syncedlyrics; print(syncedlyrics.search(sys.argv[1], providers=["Musixmatch", "Megalobiz"]) or "")' "$a $bare" 2>/dev/null)
  case "$s" in *"[0"*|*"[1"*) r=$(jq -nc --arg l "$s" "{syncedLyrics: \$l}"); answered=1;; esac
fi
if [ -z "$r" ] || [ "$(printf "%s" "$r" | jq -r ".syncedLyrics // empty" 2>/dev/null)" = "" ]; then
  g=$(python3 "$(dirname "$0")/genius-lyrics.py" "$a" "$bare" "$c" 2>/dev/null || true)
  if [ -n "$g" ] && [ "$g" != "{}" ]; then
    gp=$(printf "%s" "$g" | jq -r ".plain // empty" 2>/dev/null)
    if [ -n "$gp" ]; then r=$(jq -nc --arg p "$gp" "{plainLyrics: \$p}"); answered=1; fi
  fi
fi
if [ -n "$r" ]; then printf "%s" "$r" | jq -c "{synced: .syncedLyrics, plain: .plainLyrics, instrumental: .instrumental}" | tee "$f"
elif [ "$answered" = 1 ]; then echo "{}" | tee "$f"
else echo "{\"retry\":true}"; fi

#!/bin/sh
# Builds the "maclock" SDDM theme (MacLock as the login screen) and installs it.
#   maclock-sddm.sh preview      greeter in test mode for 15 s (no real login)
#   maclock-sddm.sh apply        install to /usr/share/sddm/themes/maclock and make it the login screen (polkit prompt)
#   maclock-sddm.sh use <theme>  switch the login screen to another installed theme (polkit prompt)
#   maclock-sddm.sh current      print the login screen in use
# The theme = ~/.config/sddm/themes/maclock (Main.qml) + MacLock's glass components, shaders and fonts + a fixed copy
# of the background + a theme.conf from MacShell's settings (Settings → Lock Screen → Login Screen).
set -eu

src="$HOME/.config/sddm/themes/maclock"
lock="$HOME/.config/quickshell/MacLock"
settings="$HOME/.config/macbar/settings.json"
stage="${XDG_CACHE_HOME:-$HOME/.cache}/maclock-sddm/maclock"
conf=/etc/sddm.conf

# a setting as text, empty when unset (false stays "false")
get() { jq -r --arg k "$1" '.[$k] | if . == null then empty else tostring end' "$settings" 2>/dev/null || true; }

build() {
    rm -rf "$stage"
    mkdir -p "$stage/fonts"
    cp "$src/Main.qml" "$src/metadata.desktop" "$stage/"
    cp "$lock/Glass.qml" "$lock/ContourGlow.qml" "$lock/MorphText.qml" \
       "$lock/liquidglass.frag.qsb" "$lock/contourglow.frag.qsb" "$lock/glasstext.frag.qsb" "$stage/"
    cp "$lock"/fonts/*.otf "$stage/fonts/"

    # fixed background: copied into the theme, the greeter can't read $HOME
    bg=$(get loginBackground)
    [ -f "$bg" ] || bg=$(get wallpaperPath)
    bgname=""
    if [ -f "$bg" ]; then bgname="background.${bg##*.}"; cp "$bg" "$stage/$bgname"; fi

    {
        echo "[General]"
        echo "background=$bgname"
        echo "use24h=$(get use24h)"
        echo "showPower=$(get loginShowPower)"
        echo "showSessions=$(get loginShowSessions)"
        echo "clockFont=$(get lockClockFont)"
        echo "clockWeight=$(get lockClockWeight)"
        echo "clockMaterial=$(get lockClockMaterial)"
        echo "clockIntensity=$(get lockClockIntensity)"
        echo "clockTint=$(get lockClockTint)"
        echo "clockDate=$(get lockClockDate)"
    } > "$stage/theme.conf"
}

# as root: point [Theme] Current= at $1 (sddm.conf wins over sddm.conf.d)
set_current='f=/etc/sddm.conf
if grep -q "^[[:space:]]*Current=" "$f" 2>/dev/null; then sed -i "s/^\([[:space:]]*\)Current=.*/\1Current=$1/" "$f"
else printf "\n[Theme]\nCurrent=%s\n" "$1" >> "$f"; fi'

case "${1:-}" in
    preview)
        build
        timeout 15 sddm-greeter-qt6 --test-mode --theme "$stage" >/dev/null 2>&1 || true
        ;;
    apply)
        build
        pkexec sh -c 'set -e
            d=/usr/share/sddm/themes/maclock
            rm -rf "$d"; cp -r "$2" "$d"
            chown -R root:root "$d"; chmod -R u=rwX,go=rX "$d"
            set -- maclock
            '"$set_current" sh _ "$stage"
        ;;
    use)
        [ -d "/usr/share/sddm/themes/${2:-}" ] || { echo "no such theme: ${2:-}" >&2; exit 1; }
        pkexec sh -c "$set_current" sh "$2"
        ;;
    current)
        sed -n 's/^[[:space:]]*Current=//p' "$conf" 2>/dev/null | tail -n1
        ;;
    *)
        echo "usage: $0 preview | apply | use <theme> | current" >&2; exit 2
        ;;
esac

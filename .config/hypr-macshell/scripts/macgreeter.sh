#!/bin/sh
# Manages MacGreeter (MacLock as a greetd login screen).
#   macgreeter.sh preview      open the login screen in test overlay mode (Ctrl+Shift+Q closes)
#   macgreeter.sh sync         copy current wallpaper, avatar, and lock settings to /var/lib/macshell-greeter
#   macgreeter.sh apply        install greetd & macshell-greeter (polkit prompt)
#   macgreeter.sh remove       disable greetd and restore the previous display manager (SDDM)
#   macgreeter.sh status       output JSON status (used by Settings UI)
set -eu

greeter="$HOME/.config/quickshell/MacGreeter"
lock="$HOME/.config/quickshell/MacLock"
stage="${XDG_CACHE_HOME:-$HOME/.cache}/macgreeter-apply"

build_stage() {
    rm -rf "$stage"
    mkdir -p "$stage/sys"
    # Copy MacLock components
    cp "$lock/LockScreen.qml" "$lock/Glass.qml" "$lock/Glyph.qml" \
       "$lock/ClockGlyph.qml" "$lock/ContourGlow.qml" "$lock/MorphGlyph.qml" \
       "$lock/MorphText.qml" "$lock/I18n.js" "$stage/sys/"
    cp -r "$lock/fonts" "$stage/sys/"
    cp "$lock"/*.frag* "$stage/sys/" 2>/dev/null || true

    # Copy MacGreeter components
    cp "$greeter/shell.qml" "$greeter/run-greeter.sh" "$greeter/net.sh" \
       "$greeter/list.sh" "$greeter/hyprland.lua.in" "$greeter/hyprland.conf.in" "$stage/sys/"
    cp "$greeter/macshell-greeter-sync" "$stage/sys/"

    # Staging root scripts
    cp "$greeter/macshell-greeter" "$stage/macshell-greeter"
    cp "$greeter/macshell-greeter-apply" "$stage/apply.sh"
    chmod +x "$stage/apply.sh" "$stage/macshell-greeter" "$stage"/sys/*.sh 2>/dev/null || true
}

case "${1:-}" in
    preview)
        MACGREETER_PREVIEW=1 qs -p "$greeter"
        ;;
    sync)
        if [ -x "$greeter/macshell-greeter-sync" ]; then
            sh "$greeter/macshell-greeter-sync"
        elif [ -x /usr/local/share/macshell-greeter/macshell-greeter-sync ]; then
            sh /usr/local/share/macshell-greeter/macshell-greeter-sync
        fi
        ;;
    apply)
        build_stage
        pkexec sh "$stage/apply.sh" install "$stage" "$(id -un)"
        if [ -x "$greeter/macshell-greeter-sync" ]; then
            sh "$greeter/macshell-greeter-sync" || true
        fi
        ;;
    remove)
        if [ -x /usr/local/bin/macshell-greeter-apply ]; then
            pkexec /usr/local/bin/macshell-greeter-apply remove
        elif [ -f "$greeter/macshell-greeter-apply" ]; then
            pkexec sh "$greeter/macshell-greeter-apply" remove
        fi
        ;;
    status)
        installed=false
        enabled=false
        dm="sddm"
        [ -x /usr/local/bin/macshell-greeter ] && installed=true
        if systemctl is-enabled --quiet greetd.service 2>/dev/null; then
            enabled=true
            dm="greetd"
        fi
        printf '{"installed":%s,"enabled":%s,"currentDm":"%s"}\n' "$installed" "$enabled" "$dm"
        ;;
    *)
        echo "usage: $0 preview | sync | apply | remove | status" >&2
        exit 2
        ;;
esac

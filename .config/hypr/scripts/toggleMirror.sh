#!/bin/sh
# Toggle mirroring HDMI-A-1 to/from eDP-1 on Hyprland

isMirror=$(hyprctl monitors all -j | jq -r '.[] | select(.name=="HDMI-A-1") | .mirrorOf' 2>/dev/null || echo "none")
echo "Current mirror status: $isMirror"

if [ "$isMirror" == "none" ]; then
    hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@59.95", position = "1920x0", scale = 1.0, mirror = "eDP-1" })'
else
    hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@59.95", position = "1920x0", scale = 1.0, mirror = "none"})'
fi

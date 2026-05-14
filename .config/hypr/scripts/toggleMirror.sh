#!/bin/sh
# Toggle mirroring HDMI-A-1 to/from eDP-1 on Hyprland

isMirror=$(hyprctl monitors all -j | jq -r '.[] | select(.name=="HDMI-A-1") | .mirrorOf' 2>/dev/null || echo "none")
echo "Current mirror status: $isMirror"

if [ "$isMirror" = "none" ]; then
    hyprctl keyword monitor HDMI-A-1,1920x1080@59.95,1920x0,1.0,mirror,eDP-1
else
    hyprctl keyword monitor HDMI-A-1,1920x1080@59.95,1920x0,1.0
fi

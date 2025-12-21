#!/bin/bash

if hyprctl monitors | grep -q "HDMI-A-1.*mirror"; then
    hyprctl keyword monitor "HDMI-A-1, preferred, auto, 1"
else
    hyprctl keyword monitor "HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
fi


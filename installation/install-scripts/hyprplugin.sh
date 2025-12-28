#!/bin/bash
# 💫 https://github.com/akiidjk 💫 #
# Installation of hyprland plugins #

hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
hyprpm add https://github.com/virtcode/hypr-dynamic-cursors
hyprpm enable dynamic-cursors
hyprpm reload

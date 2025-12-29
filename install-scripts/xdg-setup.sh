#!/bin/bash
# 💫 https://github.com/akiidjk 💫 #
# Set of some xdg-mime #

# PDF → Zen Browser
xdg-mime default zen.desktop application/pdf

# Images → loupe
xdg-mime default loupe.desktop image/jpeg
xdg-mime default loupe.desktop image/png
xdg-mime default loupe.desktop image/webp
xdg-mime default loupe.desktop image/gif

# SVG → Zen Browser
xdg-mime default zen.desktop image/svg+xml

# Video → mpv
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/x-msvideo

# Audio → mpv
xdg-mime default mpv.desktop audio/mpeg
xdg-mime default mpv.desktop audio/mp3
xdg-mime default mpv.desktop audio/wav
xdg-mime default mpv.desktop audio/flac
xdg-mime default mpv.desktop audio/ogg
xdg-mime default mpv.desktop audio/aac
xdg-mime default mpv.desktop audio/x-m4a
xdg-mime default mpv.desktop audio/webm

# Source code (generic) → Zed
xdg-mime default zed.desktop text/x-source
xdg-mime default zed.desktop text/x-script

# Common programming languages → Zed
xdg-mime default zed.desktop text/x-python
xdg-mime default zed.desktop text/x-c
xdg-mime default zed.desktop text/x-csrc
xdg-mime default zed.desktop text/x-chdr
xdg-mime default zed.desktop text/x-c++
xdg-mime default zed.desktop text/x-c++src
xdg-mime default zed.desktop text/x-java
xdg-mime default zed.desktop text/x-go
xdg-mime default zed.desktop text/x-rustsrc
xdg-mime default zed.desktop text/x-php
xdg-mime default zed.desktop text/x-shellscript
xdg-mime default zed.desktop application/javascript
xdg-mime default zed.desktop text/javascript
xdg-mime default zed.desktop text/css
xdg-mime default zed.desktop text/html

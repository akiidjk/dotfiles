#!/usr/bin/env bash

dir="$HOME/.config/rofi/filefinder"
theme='style-4'

rofi -modi file-browser-extended                   \
     -theme ${dir}/${theme}.rasi                   \
     -show file-browser-extended                   \
     -file-browser-cmd "xdg-open"                  \
     -file-browser-dir "~"                         \
     -file-browser-depth 0                         \
     -file-browser-path-sep "/"                    \
     -file-browser-up-text "up"                    \
     -file-browser-up-icon "go-previous"           \
     -file-browser-oc-search-path                  \
     -file-browser-exclude workspace               \

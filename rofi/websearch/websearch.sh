#!/usr/bin/env bash

dir="$HOME/.config/rofi/websearch"
theme='style-4'

echo "" | rofi -dmenu -p "Search:" -theme ${dir}/${theme}.rasi  | xargs -I{} xdg-open https://search.brave.com/search?q={}

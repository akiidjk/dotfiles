#!/bin/bash
set -eu

WALL=$1
echo "setting $WALL as wallpaper"
matugen image -t scheme-fidelity -m dark $WALL  --show-colors --verbose --fallback-color "#000000"
echo "set $WALL as wallpaper sucessfuly"

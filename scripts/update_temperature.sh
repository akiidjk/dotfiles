#!/bin/bash

CURRENT_HOUR=$(date +%H)


if [ "$CURRENT_HOUR" -ge 8 ] && [ "$CURRENT_HOUR" -lt 21 ]; then
    busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 7000
fi

if [ "$CURRENT_HOUR" -ge 21 ]; then
    busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 4500
fi

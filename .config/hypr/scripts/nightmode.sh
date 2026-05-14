#!/bin/bash

if pgrep -x "hyprsunset" > /dev/null
then
    killall -9 hyprsunset
    notify-send "🌞 Day Mode Activated" -u "low"
else
    hyprsunset -t 3500 &
    notify-send "🌙 Night Mode Activated" -u "low"
fi

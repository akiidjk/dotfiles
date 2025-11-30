#!/bin/sh
# Toggle rfkill block/unblock all
rfkill_status=$(rfkill list all | grep -m1 "Soft blocked: yes")
if [ -n "$rfkill_status" ]; then
    rfkill unblock all
    echo "All devices unblocked."
else
    rfkill block all
    echo "All devices blocked."
fi

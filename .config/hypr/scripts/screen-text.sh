#!/usr/bin/env bash
# Copy text from a screen area (Super+Shift+T): a QR code is read as-is, anything else goes through OCR.
# Needs grim, slurp, zbar, tesseract + tesseract-data-eng (OCR_LANG=eng+ita once tesseract-data-ita is installed).
img=$(mktemp --suffix=.png)
trap 'rm -f "$img"' EXIT
geo=$(slurp) || exit 0
grim -g "$geo" "$img" || exit 1

if txt=$(zbarimg -q --raw "$img" 2>/dev/null) && [ -n "$txt" ]; then
    what="QR code copied"
else
    txt=$(tesseract "$img" - -l "${OCR_LANG:-eng}" 2>/dev/null | sed -e 's/[[:space:]]*$//' | sed -e '/./,$!d')
    what="Text copied"
fi
if [ -z "${txt//[[:space:]]/}" ]; then
    qs -c MacShell ipc call island notify "No text found" "" "" >/dev/null 2>&1 || notify-send "No text found"
    exit 0
fi
printf '%s' "$txt" | wl-copy
qs -c MacShell ipc call island notify "$what" "$(printf '%s' "$txt" | tr '\n' ' ' | cut -c1-60)" "" >/dev/null 2>&1 \
    || notify-send "$what" "$(printf '%s' "$txt" | head -c 120)"

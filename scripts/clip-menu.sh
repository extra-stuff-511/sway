#!/bin/sh

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

choice=$(
    {
        echo "Clear clipboard history"
        cliphist list
    } | rofi -dmenu -p "Clipboard >"
)

case "$choice" in
    "Clear clipboard history")
        cliphist wipe && wl-copy --clear
        ;;
    *)
        printf '%s' "$choice" | cliphist decode | wl-copy
        ;;
esac

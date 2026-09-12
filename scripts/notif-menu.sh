#!/usr/bin/env bash

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

choice=$(
    {
        echo "Clear notifications"
        makoctl history | awk -F '\t' '{print $2}'
    } | rofi -dmenu -i -p "Notifications >"
)

case "$choice" in
    "Clear notifications")
        makoctl dismiss --all
        ;;
esac

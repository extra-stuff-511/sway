#!/usr/bin/env bash

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

current=$(powerprofilesctl get)

choice=$(
    {
        printf 'Current: %s\n' "$current"
        powerprofilesctl list | awk -F: '/^[* ]+[a-z-]+:/ {gsub(/^[* ]+/, "", $1); print $1}'
    } | rofi -dmenu -p 'Power Profile >'
)

[[ $choice == Current:* || -z $choice ]] || powerprofilesctl set "$choice"

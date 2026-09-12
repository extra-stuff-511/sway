#!/usr/bin/env bash

current=$(powerprofilesctl get)

choice=$(
    {
        printf 'Current: %s\n' "$current"
        powerprofilesctl list | awk -F: '/^[* ]+[a-z-]+:/ {gsub(/^[* ]+/, "", $1); print $1}'
    } | rofi -dmenu -p 'Power Profile > '
)

[[ $choice == Current:* || -z $choice ]] || powerprofilesctl set "$choice"

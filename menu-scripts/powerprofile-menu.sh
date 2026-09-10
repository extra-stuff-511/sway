#!/usr/bin/env bash

choice=$(powerprofilesctl list |
    awk '/^\*|^[[:space:]]+[a-z-]+:/ {
        gsub(/[:*]/, "")
        gsub(/^[[:space:]]+/, "")
        print
    }' |
    rofi -dmenu -p "Power Profile")

[ -n "$choice" ] && powerprofilesctl set "$choice"

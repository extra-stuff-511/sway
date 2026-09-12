#!/usr/bin/env bash

choice=$(
    {
        echo "Clear notifications"
        makoctl history | awk -F '\t' '{print $2}'
    } | rofi -dmenu -i -p "Notifications"
)

case "$choice" in
    "Clear notifications")
        makoctl dismiss --all
        ;;
esac

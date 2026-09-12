#!/bin/sh

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

status=$(playerctl status 2>/dev/null)

if [ "$status" = "Playing" ]; then
    action="Pause"
else
    action="Play"
fi

artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)

if [ -n "$artist" ] && [ -n "$title" ]; then
    current="$artist - $title"
elif [ -n "$title" ]; then
    current="$title"
else
    current="No media playing"
fi

choice=$(printf '%s\n%s\n%s\n%s' \
    "$current" \
    "$action" \
    "Next" \
    "Previous" |
    rofi -dmenu -i -p "Media >" -no-custom)

case "$choice" in
    "$current")
        ;;
    "$action")
        playerctl play-pause
        ;;
    "Next")
        playerctl next
        ;;
    "Previous")
        playerctl previous
        ;;
esac

#!/usr/bin/env bash

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

choice=$(printf "Lock\nLogout\nReboot\nShutdown" | rofi -dmenu -p "Power >")

case "$choice" in
    Lock)     loginctl lock-session ;;
    Logout)   loginctl terminate-user "$USER" ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac

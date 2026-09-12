#!/usr/bin/env bash

choice=$(printf "Lock\nLogout\nReboot\nShutdown" | rofi -dmenu -p "Power > ")

case "$choice" in
    Lock)     loginctl lock-session ;;
    Logout)   loginctl terminate-user "$USER" ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac

#!/usr/bin/env bash

makoctl history | \
    awk -F '\t' '{print $2}' | \
    rofi -dmenu -i -p "Notifications"

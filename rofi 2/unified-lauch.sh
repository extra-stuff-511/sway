#!/bin/sh

LOCK="/tmp/unified-rofi.lock"

if [ -f "$LOCK" ]; then
    rm -f "$LOCK"
    pkill -x rofi
    exit 0
fi

touch "$LOCK"

rofi \
    -theme "$HOME/.config/rofi/unified-menu.rasi" \
    -show unified \
    -modes "unified:$HOME/.config/rofi/unified-menu"

rm -f "$LOCK"

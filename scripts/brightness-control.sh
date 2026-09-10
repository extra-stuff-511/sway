#!/usr/bin/env bash

set -euo pipefail

readonly STEP="1%"

usage() {
    cat <<EOF
Usage:
  brightness up
  brightness down
  brightness get
  brightness set <0-100>
EOF
}

up() {
    brightnessctl set "${STEP}+"
}

down() {
    brightnessctl set "${STEP}-"
}

get() {
    brightnessctl get
}

set_brightness() {
    local value="${1:-}"

    if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value < 0 || value > 100 )); then
        echo "Error: brightness must be an integer between 0 and 100." >&2
        exit 1
    fi

    brightnessctl set "$value"% 
}

case "${1:-}" in
    up)
        up
        ;;

    down)
        down
        ;;

    get)
        get
        ;;

    set)
        set_brightness "${2:-}"
        ;;

    *)
        usage
        exit 1
        ;;
esac

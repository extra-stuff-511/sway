#!/usr/bin/env bash

set -euo pipefail

readonly POWERPROFILESCTL="$(command -v powerprofilesctl || true)"

usage() {
    cat <<EOF
Usage:

  power status
  power list
  power get
  power set <profile>

  power performance
  power balanced
  power power-saver
EOF
}

require_powerprofilesctl() {
    if [[ -z "$POWERPROFILESCTL" ]]; then
        echo "Error: powerprofilesctl not found." >&2
        echo "Make sure power-profiles-daemon is installed and enabled." >&2
        exit 1
    fi
}

status() {
    "$POWERPROFILESCTL" get
}

list() {
    "$POWERPROFILESCTL" list
}

get() {
    "$POWERPROFILESCTL" get
}

set_profile() {
    local profile="${1:-}"

    if [[ -z "$profile" ]]; then
        echo "Error: power profile is required." >&2
        usage
        exit 1
    fi

    "$POWERPROFILESCTL" set "$profile"
}

performance() {
    set_profile performance
}

balanced() {
    set_profile balanced
}

power_saver() {
    set_profile power-saver
}

require_powerprofilesctl

case "${1:-}" in
    status)
        status
        ;;

    list)
        list
        ;;

    get)
        get
        ;;

    set)
        set_profile "${2:-}"
        ;;

    performance)
        performance
        ;;

    balanced)
        balanced
        ;;

    power-saver)
        power_saver
        ;;

    *)
        usage
        exit 1
        ;;
esac

#!/usr/bin/env bash

set -euo pipefail

readonly BLUETOOTHCTL="$(command -v bluetoothctl || true)"

usage() {
    cat <<EOF
Usage:
  bluetooth status

  bluetooth on
  bluetooth off
  bluetooth toggle

  bluetooth devices
  bluetooth paired
  bluetooth scan

  bluetooth connect <MAC>
  bluetooth disconnect <MAC>

  bluetooth trust <MAC>
  bluetooth untrust <MAC>
  bluetooth remove <MAC>
EOF
}

require_bluetoothctl() {
    if [[ -z "$BLUETOOTHCTL" ]]; then
        echo "Error: bluetoothctl not found." >&2
        echo "Make sure BlueZ is installed and bluetoothctl is in PATH." >&2
        exit 1
    fi
}

get_power_state() {
    "$BLUETOOTHCTL" show |
        awk -F': ' '/Powered:/ {print tolower($2); exit}'
}

status() {
    "$BLUETOOTHCTL" show
}

on() {
    "$BLUETOOTHCTL" power on
}

off() {
    "$BLUETOOTHCTL" power off
}

toggle() {
    case "$(get_power_state)" in
        yes)
            off
            ;;
        no)
            on
            ;;
        *)
            echo "Error: unable to determine Bluetooth power state." >&2
            exit 1
            ;;
    esac
}

devices() {
    "$BLUETOOTHCTL" devices
}

paired() {
    "$BLUETOOTHCTL" devices Paired
}

scan() {
    "$BLUETOOTHCTL" scan on
}

connect() {
    local mac="${1:-}"

    if [[ -z "$mac" ]]; then
        echo "Error: MAC address required." >&2
        usage
        exit 1
    fi

    "$BLUETOOTHCTL" connect "$mac"
}

disconnect() {
    local mac="${1:-}"

    if [[ -z "$mac" ]]; then
        echo "Error: MAC address required." >&2
        usage
        exit 1
    fi

    "$BLUETOOTHCTL" disconnect "$mac"
}

trust() {
    local mac="${1:-}"

    if [[ -z "$mac" ]]; then
        echo "Error: MAC address required." >&2
        usage
        exit 1
    fi

    "$BLUETOOTHCTL" trust "$mac"
}

untrust() {
    local mac="${1:-}"

    if [[ -z "$mac" ]]; then
        echo "Error: MAC address required." >&2
        usage
        exit 1
    fi

    "$BLUETOOTHCTL" untrust "$mac"
}

remove() {
    local mac="${1:-}"

    if [[ -z "$mac" ]]; then
        echo "Error: MAC address required." >&2
        usage
        exit 1
    fi

    "$BLUETOOTHCTL" remove "$mac"
}

require_bluetoothctl

case "${1:-}" in
    status)
        status
        ;;

    on)
        on
        ;;

    off)
        off
        ;;

    toggle)
        toggle
        ;;

    devices)
        devices
        ;;

    paired)
        paired
        ;;

    scan)
        scan
        ;;

    connect)
        connect "${2:-}"
        ;;

    disconnect)
        disconnect "${2:-}"
        ;;

    trust)
        trust "${2:-}"
        ;;

    untrust)
        untrust "${2:-}"
        ;;

    remove)
        remove "${2:-}"
        ;;

    *)
        usage
        exit 1
        ;;
esac

#!/usr/bin/env bash

set -euo pipefail

if ! command -v nmcli >/dev/null 2>&1; then
    echo "Error: nmcli is not installed or not in PATH." >&2
    exit 1
fi

readonly NMCLI="$(command -v nmcli || true)"

usage() {
    cat <<EOF
Usage:

  network status

  network wifi on
  network wifi off
  network wifi toggle
  network wifi list
  network wifi current
  network wifi disconnect
  network wifi connect <SSID> [password]

  network ethernet status

  network internet
  network ip
EOF
}

wifi() {
    case "${1:-}" in
        on)
            "$NMCLI" radio wifi on
            ;;

        off)
            "$NMCLI" radio wifi off
            ;;

        toggle)
            if [[ "$("$NMCLI" radio wifi)" == "enabled" ]]; then
                "$NMCLI" radio wifi off
            else
                "$NMCLI" radio wifi on
            fi
            ;;

        list)
            "$NMCLI" device wifi list
            ;;

        current)
            "$NMCLI" -t -f active,ssid,signal device wifi \
                | awk -F: '$1 == "yes" {print $2 " (" $3 "%)"}'
            ;;

        disconnect)
            "$NMCLI" device disconnect "$(wifi_device)"
            ;;

        connect)
            local ssid="${2:-}"
            local password="${3:-}"

            if [[ -z "$ssid" ]]; then
                echo "Error: SSID is required." >&2
                usage
                exit 1
            fi

            if [[ -n "$password" ]]; then
                "$NMCLI" device wifi connect "$ssid" password "$password"
            else
                "$NMCLI" device wifi connect "$ssid"
            fi
            ;;

        *)
            usage
            exit 1
            ;;
    esac
}

wifi_device() {
    "$NMCLI" -t -f DEVICE,TYPE device \
        | awk -F: '$2 == "wifi" {print $1; exit}'
}

ethernet() {
    case "${1:-}" in
        status)
            "$NMCLI" device status \
                | awk '$2 == "ethernet"'
            ;;

        *)
            usage
            exit 1
            ;;
    esac
}

status() {
    "$NMCLI" device status
}

internet() {
    local state

    state="$("$NMCLI" networking connectivity)"

    case "$state" in
        full)
            echo "online"
            ;;

        limited)
            echo "limited"
            ;;

        portal)
            echo "captive-portal"
            ;;

        none)
            echo "offline"
            ;;

        unknown)
            echo "unknown"
            ;;

        *)
            echo "$state"
            ;;
    esac
}

ip() {
    "$NMCLI" -g IP4.ADDRESS device show
}

case "${1:-}" in
    status)
        status
        ;;

    wifi)
        wifi "${2:-}" "${@:3}"
        ;;

    ethernet)
        ethernet "${2:-}"
        ;;

    internet)
        internet
        ;;

    ip)
        ip
        ;;

    *)
        usage
        exit 1
        ;;
esac

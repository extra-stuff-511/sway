#!/usr/bin/env bash

set -euo pipefail

readonly SYSTEMCTL="$(command -v systemctl || true)"
readonly LOGINCTL="$(command -v loginctl || true)"
readonly REBOOT="$(command -v reboot || true)"
readonly SHUTDOWN="$(command -v shutdown || true)"
readonly POWER="$(command -v poweroff || true)"

usage() {
    cat <<EOF
Usage:

  power status

  power shutdown
  power reboot
  power poweroff
  power suspend
  power hibernate
  power hybrid-sleep

  power lock
  power logout
EOF
}

require_command() {
    local command="$1"

    if [[ -z "$command" ]]; then
        echo "Error: required command is not available." >&2
        exit 1
    fi
}

system_action() {
    local action="$1"

    if [[ -n "$SYSTEMCTL" ]]; then
        "$SYSTEMCTL" "$action"
        return
    fi

    case "$action" in
        poweroff)
            require_command "$POWER"
            "$POWER"
            ;;

        reboot)
            require_command "$REBOOT"
            "$REBOOT"
            ;;

        *)
            echo "Error: '$action' requires systemctl." >&2
            exit 1
            ;;
    esac
}

shutdown() {
    system_action poweroff
}

reboot() {
    system_action reboot
}

poweroff() {
    system_action poweroff
}

suspend() {
    if [[ -n "$SYSTEMCTL" ]]; then
        "$SYSTEMCTL" suspend
    else
        echo "Error: suspend requires systemctl." >&2
        exit 1
    fi
}

hibernate() {
    if [[ -n "$SYSTEMCTL" ]]; then
        "$SYSTEMCTL" hibernate
    else
        echo "Error: hibernate requires systemctl." >&2
        exit 1
    fi
}

hybrid_sleep() {
    if [[ -n "$SYSTEMCTL" ]]; then
        "$SYSTEMCTL" hybrid-sleep
    else
        echo "Error: hybrid-sleep requires systemctl." >&2
        exit 1
    fi
}

lock() {
    if [[ -n "$LOGINCTL" ]]; then
        "$LOGINCTL" lock-session
        return
    fi

    if command -v loginctl >/dev/null 2>&1; then
        loginctl lock-session
        return
    fi

    echo "Error: loginctl is not available." >&2
    exit 1
}

logout() {
    if [[ -n "$LOGINCTL" ]]; then
        "$LOGINCTL" terminate-session "$XDG_SESSION_ID"
        return
    fi

    echo "Error: loginctl is not available." >&2
    exit 1
}

status() {
    echo "Power management"

    if [[ -n "$SYSTEMCTL" ]]; then
        echo "  systemd:       available"
    else
        echo "  systemd:       unavailable"
    fi

    if [[ -n "${XDG_SESSION_ID:-}" ]]; then
        echo "  session:       $XDG_SESSION_ID"
    else
        echo "  session:       unknown"
    fi

    if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
        echo "  desktop:       $XDG_CURRENT_DESKTOP"
    else
        echo "  desktop:       unknown"
    fi

    if [[ -n "${XDG_SESSION_TYPE:-}" ]]; then
        echo "  session type:  $XDG_SESSION_TYPE"
    else
        echo "  session type:  unknown"
    fi
}

case "${1:-}" in
    status)
        status
        ;;

    shutdown)
        shutdown
        ;;

    reboot)
        reboot
        ;;

    poweroff)
        poweroff
        ;;

    suspend)
        suspend
        ;;

    hibernate)
        hibernate
        ;;

    hybrid-sleep)
        hybrid_sleep
        ;;

    lock)
        lock
        ;;

    logout)
        logout
        ;;

    *)
        usage
        exit 1
        ;;
esac

#!/usr/bin/env bash

set -euo pipefail

readonly STEP="1%"

usage() {
    cat <<EOF
Usage:
  audio volume up
  audio volume down
  audio volume mute
  audio volume get

  audio mic up
  audio mic down
  audio mic mute
  audio mic get
EOF
}

volume() {
    case "${1:-}" in
        up)
            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "${STEP}+"
            ;;

        down)
            wpctl set-volume @DEFAULT_AUDIO_SINK@ "${STEP}-"
            ;;

        mute)
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            ;;

        get)
            wpctl get-volume @DEFAULT_AUDIO_SINK@
            ;;

        *)
            usage
            exit 1
            ;;
    esac
}

mic() {
    case "${1:-}" in
        up)
            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SOURCE@ "${STEP}+"
            ;;

        down)
            wpctl set-volume @DEFAULT_AUDIO_SOURCE@ "${STEP}-"
            ;;

        mute)
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
            ;;

        get)
            wpctl get-volume @DEFAULT_AUDIO_SOURCE@
            ;;

        *)
            usage
            exit 1
            ;;
    esac
}

case "${1:-}" in
    volume)
        volume "${2:-}"
        ;;

    mic)
        mic "${2:-}"
        ;;

    *)
        usage
        exit 1
        ;;
esac

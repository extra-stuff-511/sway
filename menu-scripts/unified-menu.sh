#!/bin/sh

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit
fi

ROFI="rofi -dmenu -i -no-custom"

# ─────────────────────────────────────────────
# Media
# ─────────────────────────────────────────────

media_menu() {
    while true; do
        status=$(playerctl status 2>/dev/null || true)
        player=$(playerctl metadata --format '{{ artist }} - {{ title }}' 2>/dev/null)

        [ -z "$player" ] && player="Nothing playing"

        case "$status" in
            Playing) state="Playing" ;;
            Paused)  state="Paused" ;;
            *)       state="Stopped" ;;
        esac

        choice=$(printf '%s\n' \
            "$state: $player" \
            "Play / Pause" \
            "Next" \
            "Previous" \
            "Back" |
            $ROFI -p "Media")

        case "$choice" in
            "Play / Pause") playerctl play-pause ;;
            "Next")         playerctl next ;;
            "Previous")     playerctl previous ;;
            "Back"|"")      return ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Volume
# ─────────────────────────────────────────────

volume_menu() {
    while true; do
        volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null |
            awk '{printf "%d", $2 * 100}')

        muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null |
            grep -q MUTED && echo "Muted" || echo "On")

        choice=$(printf '%s\n' \
            "Volume: $volume% ($muted)" \
            "Mute toggle" \
            "Increase" \
            "Decrease" \
            "Back" |
            $ROFI -p "Volume")

        case "$choice" in
            "Mute toggle")
                wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
                ;;
            "Increase")
                wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
                ;;
            "Decrease")
                wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
                ;;
            "Back"|"")
                return
                ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Brightness
# ─────────────────────────────────────────────

brightness_value() {
    brightnessctl -m 2>/dev/null |
        awk -F, '{gsub("%","",$4); print $4}'
}

brightness_menu() {
    while true; do
        current=$(brightness_value)
        [ -z "$current" ] && current="N/A"

        choice=$(printf '%s\n' \
            "Brightness: $current%" \
            "Increase" \
            "Decrease" \
            "Back" |
            $ROFI -p "Brightness")

        case "$choice" in
            "Increase")
                brightnessctl set 5%+
                ;;
            "Decrease")
                brightnessctl set 5%-
                ;;
            "Back"|"")
                return
                ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Mic
# ─────────────────────────────────────────────

mic_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null |
        awk '{printf "%d", $2 * 100}'
}

mic_status() {
    if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null |
        grep -q MUTED; then
        echo "Off"
    else
        echo "On"
    fi
}

mic_menu() {
    while true; do
        volume=$(mic_volume)
        status=$(mic_status)

        [ -z "$volume" ] && volume="N/A"

        choice=$(printf '%s\n' \
            "Mic: $volume% ($status)" \
            "Mute toggle" \
            "Increase" \
            "Decrease" \
            "Back" |
            $ROFI -p "Mic")

        case "$choice" in
            "Mute toggle")
                wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
                ;;
            "Increase")
                wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+
                ;;
            "Decrease")
                wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-
                ;;
            "Back"|"")
                return
                ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Network
# ─────────────────────────────────────────────

network_status() {
    # Get the first actually connected device.
    active=$(nmcli -t \
        -f DEVICE,TYPE,STATE,CONNECTION \
        device status 2>/dev/null |
        awk -F: '$3 == "connected" {print; exit}')

    wifi=$(nmcli -t -f WIFI g 2>/dev/null)

    if [ -n "$active" ]; then
        connection=$(echo "$active" | cut -d: -f4)
        type=$(echo "$active" | cut -d: -f2)

        case "$type" in
            wifi)
                echo "Connected • $connection"
                ;;
            ethernet)
                echo "Connected • Ethernet"
                ;;
            *)
                echo "Connected • $connection"
                ;;
        esac

    elif [ "$wifi" = "enabled" ]; then
        echo "On • Disconnected"
    else
        echo "Off"
    fi
}

network_menu() {
    while true; do
        active=$(nmcli -t \
            -f DEVICE,TYPE,STATE,CONNECTION \
            device status 2>/dev/null |
            awk -F: '$3 == "connected" {print; exit}')

        wifi=$(nmcli -t -f WIFI g 2>/dev/null)

        if [ -n "$active" ]; then
            device=$(echo "$active" | cut -d: -f1)
            type=$(echo "$active" | cut -d: -f2)
            connection=$(echo "$active" | cut -d: -f4)

            network="Connected • $connection"
        else
            network="Disconnected"
        fi

        [ "$wifi" = "enabled" ] &&
            wifi_status="On" ||
            wifi_status="Off"

        choice=$(printf '%s\n' \
            "$network" \
            "Wi-Fi: $wifi_status" \
            "Toggle Wi-Fi" \
            "Open nmtui" \
            "Back" |
            $ROFI -p "Network")

        case "$choice" in
            "Toggle Wi-Fi")
                if [ "$wifi" = "enabled" ]; then
                    nmcli radio wifi off
                else
                    nmcli radio wifi on
                fi
                ;;
            "Open nmtui")
                foot -e nmtui
                ;;
            "Back"|"")
                return
                ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Bluetooth
# ─────────────────────────────────────────────

bluetooth_status() {
    power=$(bluetoothctl show 2>/dev/null |
        awk '/Powered:/ {print $2}')

    device=$(bluetoothctl devices Connected 2>/dev/null |
        head -1 |
        cut -d' ' -f3-)

    if [ "$power" = "yes" ] && [ -n "$device" ]; then
        echo "Connected • $device"
    elif [ "$power" = "yes" ]; then
        echo "On • Disconnected"
    else
        echo "Off"
    fi
}

bluetooth_menu() {
    while true; do
        power=$(bluetoothctl show 2>/dev/null |
            awk '/Powered:/ {print $2}')

        device=$(bluetoothctl devices Connected 2>/dev/null |
            head -1 |
            cut -d' ' -f3-)

        [ -z "$device" ] && device="Disconnected"

        [ "$power" = "yes" ] && power_status="On" || power_status="Off"

        choice=$(printf '%s\n' \
            "Bluetooth: $power_status" \
            "Device: $device" \
            "Toggle Bluetooth" \
            "Open bluetui" \
            "Back" |
            $ROFI -p "Bluetooth")

        case "$choice" in
            "Toggle Bluetooth")
                if [ "$power" = "yes" ]; then
                    bluetoothctl power off
                else
                    bluetoothctl power on
                fi
                ;;
            "Open bluetui")
                foot -e bluetui
                ;;
            "Back"|"")
                return
                ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Power Profiles
# ─────────────────────────────────────────────

power_menu() {
    while true; do
        current=$(powerprofilesctl get 2>/dev/null || echo "unknown")

        choice=$(printf '%s\n' \
            "Current: $current" \
            "Performance" \
            "Balanced" \
            "Power Saver" \
            "Back" |
            $ROFI -p "Power Profile")

        case "$choice" in
            "Performance")
                powerprofilesctl set performance
                ;;
            "Balanced")
                powerprofilesctl set balanced
                ;;
            "Power Saver")
                powerprofilesctl set power-saver
                ;;
            "Back"|"")
                return
                ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Battery
# ─────────────────────────────────────────────

battery_status() {
    battery=""

    # Prefer BAT0/BAT1 directly.
    for bat in /sys/class/power_supply/BAT*; do
        [ -d "$bat" ] || continue
        battery="$bat"
        break
    done

    # No battery found.
    if [ -z "$battery" ]; then
        echo "N/A"
        return
    fi

    capacity=$(cat "$battery/capacity" 2>/dev/null)
    state=$(cat "$battery/status" 2>/dev/null)

    # Current power draw.
    power=""

    if [ -f "$battery/power_now" ]; then
        power_now=$(cat "$battery/power_now" 2>/dev/null)
        [ -n "$power_now" ] && power=$(awk "BEGIN {printf \"%.1fW\", $power_now / 1000000}")
    elif [ -f "$battery/current_now" ] ] && [ -f "$battery/voltage_now" ]; then
        current=$(cat "$battery/current_now" 2>/dev/null)
        voltage=$(cat "$battery/voltage_now" 2>/dev/null)

        [ -n "$current" ] && [ -n "$voltage" ] &&
            power=$(awk "BEGIN {printf \"%.1fW\", ($current * $voltage) / 1000000000000}")
    fi

    [ -z "$power" ] && power=""

    profile=$(powerprofilesctl get 2>/dev/null)
    [ -z "$profile" ] && profile="unknown"

    if [ -n "$power" ]; then
        echo "$capacity% • $state • $power • $profile"
    else
        echo "$capacity% • $state • $profile"
    fi
}

# ─────────────────────────────────────────────
# Clipboard
# ─────────────────────────────────────────────

clipboard_count() {
    cliphist list 2>/dev/null | wc -l
}

clipboard_menu() {
    while true; do
        count=$(clipboard_count)

        choice=$(printf '%s\n' \
            "Clipboard: $count" \
            "Clear history" \
            "Clipboard history" \
            "Back" |
            $ROFI -p "Clipboard")

        case "$choice" in
            "Clear history")
                cliphist wipe
                ;;
            "Clipboard history")
                selected=$(cliphist list 2>/dev/null |
                    rofi -dmenu -i -p "Clipboard")

                [ -n "$selected" ] &&
                    printf '%s\n' "$selected" |
                    cliphist decode |
                    wl-copy
                ;;
            "Back"|"")
                return
                ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Notifications
# ─────────────────────────────────────────────

notification_count() {
    # Mako does not expose a simple notification count command.
    # makoctl list retu
    makoctl list 2>/dev/null |
        grep -c '^Notification' 2>/dev/null
}

notification_menu() {
    while true; do
        count=$(notification_count)

        choice=$(printf '%s\n' \
            "Notifications: $count" \
            "Clear history" \
            "Notification history" \
            "Back" |
            $ROFI -p "Notifications")

        case "$choice" in
            "Clear history")
                makoctl dismiss -a
                ;;
            "Notification history")
                # Mako does not provide persistent notification history.
                # Show currently queued notifications instead.
                makoctl list 2>/dev/null |
                    rofi -dmenu -i -p "Notifications"
                ;;
            "Back"|"")
                return
                ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Main Menu
# ─────────────────────────────────────────────

main_menu() {
    while true; do
        date_time=$(date '+%H:%M • %a, %d %b')

        media=$(playerctl metadata \
            --format '{{ artist }} - {{ title }}' 2>/dev/null)

        [ -z "$media" ] && media="Nothing playing"

        brightness=$(brightness_value)
        [ -z "$brightness" ] && brightness="N/A"

        volume=$(volume_value)
        [ -z "$volume" ] && volume="N/A"

        mic_vol=$(mic_volume)
        [ -z "$mic_vol" ] && mic_vol="N/A"

        mic=$(mic_status)
        network=$(network_status)
        bluetooth=$(bluetooth_status)
        battery=$(battery_status)

        clipboard=$(clipboard_count)
        notifications=$(notification_count)

        choice=$(printf '%s\n' \
            "$date_time" \
            "Media          $media" \
            "Brightness     $brightness%" \
            "Volume         $volume%" \
            "Mic            $mic_vol% ($mic)" \
            "Network        $network" \
            "Bluetooth      $bluetooth" \
            "Battery        $battery" \
            "Clipboard      $clipboard" \
            "Notifications  $notifications" |
            $ROFI -p "System")

        case "$choice" in
            Media*)          media_menu ;;
            Brightness*)     brightness_menu ;;
            Volume*)         volume_menu ;;
            Mic*)            mic_menu ;;
            Network*)        network_menu ;;
            Bluetooth*)      bluetooth_menu ;;
            Battery*)        power_menu ;;
            Clipboard*)      clipboard_menu ;;
            Notifications*) notification_menu ;;
            *)               return ;;
        esac
    done
}

main_menu

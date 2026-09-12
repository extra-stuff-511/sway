#!/bin/sh

# ============================================================
# Unified Rofi Menu
# Rofi 2.0 script mode
# ============================================================

ROFI_THEME="$HOME/.config/rofi/unified-menu.rasi"

# ============================================================
# INFORMATION
# ============================================================

get_brightness() {
    brightnessctl -m 2>/dev/null |
        awk -F, '{gsub("%","",$4); print $4}'
}

get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null |
        awk '{
            for (i = 1; i <= NF; i++)
                if ($i ~ /^[0-9]+\.[0-9]+$/) {
                    printf "%d", $i * 100
                    exit
                }
        }'
}

get_volume_state() {
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null |
        grep -q MUTED; then
        echo "Off"
    else
        echo "On"
    fi
}

get_mic_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null |
        awk '{
            for (i = 1; i <= NF; i++)
                if ($i ~ /^[0-9]+\.[0-9]+$/) {
                    printf "%d", $i * 100
                    exit
                }
        }'
}

get_mic_state() {
    if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null |
        grep -q MUTED; then
        echo "Off"
    else
        echo "On"
    fi
}

get_network() {
    connection=$(nmcli -t \
        -f DEVICE,TYPE,STATE,CONNECTION \
        device status 2>/dev/null |
        awk -F: '$3 == "connected" {print $4; exit}')

    wifi=$(nmcli -t -f WIFI g 2>/dev/null)

    if [ -n "$connection" ]; then
        echo "Connected • $connection"
    elif [ "$wifi" = "enabled" ]; then
        echo "On • Disconnected"
    else
        echo "Off"
    fi
}

get_wifi_state() {
    nmcli -t -f WIFI g 2>/dev/null
}

get_bluetooth() {
    powered=$(bluetoothctl show 2>/dev/null |
        awk '/Powered:/ {print $2}')

    device=$(bluetoothctl devices Connected 2>/dev/null |
        head -1 |
        cut -d' ' -f3-)

    if [ "$powered" = "yes" ] && [ -n "$device" ]; then
        echo "Connected • $device"
    elif [ "$powered" = "yes" ]; then
        echo "On • Disconnected"
    else
        echo "Off"
    fi
}

get_battery() {
    battery=""

    for bat in /sys/class/power_supply/BAT*; do
        [ -d "$bat" ] || continue
        battery="$bat"
        break
    done

    if [ -z "$battery" ]; then
        echo "N/A"
        return
    fi

    capacity=$(cat "$battery/capacity" 2>/dev/null)
    state=$(cat "$battery/status" 2>/dev/null)
    profile=$(powerprofilesctl get 2>/dev/null)

    [ -z "$profile" ] && profile="unknown"

    power=""

    if [ -f "$battery/power_now" ]; then
        power_now=$(cat "$battery/power_now" 2>/dev/null)

        if [ -n "$power_now" ]; then
            power=$(awk \
                "BEGIN {printf \"%.1fW\", $power_now / 1000000}")
        fi
    fi

    if [ -n "$power" ]; then
        echo "$capacity% • $state • $power • $profile"
    else
        echo "$capacity% • $state • $profile"
    fi
}

get_clipboard_count() {
    cliphist list 2>/dev/null | wc -l
}

get_notification_count() {
    makoctl list 2>/dev/null |
        grep -c '^Notification'
}

# ============================================================
# MAIN MENU
# ============================================================

main_menu() {
    echo -en "\0prompt\x1fSystem\n"
    echo -en "\0data\x1fmain\n"
    echo -en "\0no-custom\x1ftrue\n"

    time_date=$(date '+%H:%M • %a, %d %b')

    media=$(playerctl metadata \
        --format '{{ artist }} - {{ title }}' 2>/dev/null)

    [ -z "$media" ] && media="Nothing playing"

    brightness=$(get_brightness)
    [ -z "$brightness" ] && brightness="N/A"

    volume=$(get_volume)
    [ -z "$volume" ] && volume="N/A"

    mic_volume=$(get_mic_volume)
    [ -z "$mic_volume" ] && mic_volume="N/A"

    mic_state=$(get_mic_state)

    network=$(get_network)
    bluetooth=$(get_bluetooth)
    battery=$(get_battery)

    clipboard=$(get_clipboard_count)
    notifications=$(get_notification_count)

    # Information-only row
    echo -en "$time_date\0nonselectable\x1ftrue\n"

    # Main menu
    echo -en "Media          $media\0info\x1fmedia\n"
    echo -en "Brightness     $brightness%\0info\x1fbrightness\n"
    echo -en "Volume         $volume%\0info\x1fvolume\n"
    echo -en "Mic            $mic_volume% ($mic_state)\0info\x1fmic\n"

    echo -en "Network        $network\0info\x1fnetwork\n"
    echo -en "Bluetooth      $bluetooth\0info\x1fbluetooth\n"
    echo -en "Battery        $battery\0info\x1fbattery\n"

    echo -en "Clipboard      $clipboard\0info\x1fclipboard\n"
    echo -en "Notifications  $notifications\0info\x1fnotifications\n"

    echo -en "Power\0info\x1fpower\n"
}

# ============================================================
# MEDIA
# ============================================================

media_menu() {
    echo -en "\0prompt\x1fMedia\n"
    echo -en "\0data\x1fmedia\n"
    echo -en "\0no-custom\x1ftrue\n"

    media=$(playerctl metadata \
        --format '{{ artist }} - {{ title }}' 2>/dev/null)

    [ -z "$media" ] && media="Nothing playing"

    echo -en "$media\0nonselectable\x1ftrue\n"
    echo -en "Play / Pause\0info\x1fplaypause\n"
    echo -en "Next\0info\x1fnext\n"
    echo -en "Previous\0info\x1fprevious\n"
    echo -en "Back\0info\x1fback\n"
}

# ============================================================
# BRIGHTNESS
# ============================================================

brightness_menu() {
    value=$(get_brightness)
    [ -z "$value" ] && value="N/A"

    echo -en "\0prompt\x1fBrightness\n"
    echo -en "\0data\x1fbrightness\n"
    echo -en "\0no-custom\x1ftrue\n"

    echo -en "Brightness: $value%\0nonselectable\x1ftrue\n"
    echo -en "Increase\0info\x1fincrease\n"
    echo -en "Decrease\0info\x1fdecrease\n"
    echo -en "Back\0info\x1fback\n"
}

# ============================================================
# VOLUME
# ============================================================

volume_menu() {
    value=$(get_volume)
    [ -z "$value" ] && value="N/A"

    state=$(get_volume_state)

    echo -en "\0prompt\x1fVolume\n"
    echo -en "\0data\x1fvolume\n"
    echo -en "\0no-custom\x1ftrue\n"

    echo -en "Volume: $value% ($state)\0nonselectable\x1ftrue\n"
    echo -en "Mute toggle\0info\x1fmute\n"
    echo -en "Increase\0info\x1fincrease\n"
    echo -en "Decrease\0info\x1fdecrease\n"
    echo -en "Back\0info\x1fback\n"
}

# ============================================================
# MIC
# ============================================================

mic_menu() {
    value=$(get_mic_volume)
    [ -z "$value" ] && value="N/A"

    state=$(get_mic_state)

    echo -en "\0prompt\x1fMic\n"
    echo -en "\0data\x1fmic\n"
    echo -en "\0no-custom\x1ftrue\n"

    echo -en "Mic: $value% ($state)\0nonselectable\x1ftrue\n"
    echo -en "Mute toggle\0info\x1fmute\n"
    echo -en "Increase\0info\x1fincrease\n"
    echo -en "Decrease\0info\x1fdecrease\n"
    echo -en "Back\0info\x1fback\n"
}

# ============================================================
# NETWORK
# ============================================================

network_menu() {
    wifi=$(get_wifi_state)

    if [ "$wifi" = "enabled" ]; then
        wifi_text="On"
    else
        wifi_text="Off"
    fi

    echo -en "\0prompt\x1fNetwork\n"
    echo -en "\0data\x1fnetwork\n"
    echo -en "\0no-custom\x1ftrue\n"

    echo -en "$(get_network)\0nonselectable\x1ftrue\n"
    echo -en "Wi-Fi: $wifi_text\0nonselectable\x1ftrue\n"
    echo -en "Toggle Wi-Fi\0info\x1fwifi\n"
    echo -en "Open nmtui\0info\x1fnmtui\n"
    echo -en "Back\0info\x1fback\n"
}

# ============================================================
# BLUETOOTH
# ============================================================

bluetooth_menu() {
    echo -en "\0prompt\x1fBluetooth\n"
    echo -en "\0data\x1fbluetooth\n"
    echo -en "\0no-custom\x1ftrue\n"

    echo -en "$(get_bluetooth)\0nonselectable\x1ftrue\n"
    echo -en "Toggle Bluetooth\0info\x1ftoggle\n"
    echo -en "Open bluetui\0info\x1fbluetui\n"
    echo -en "Back\0info\x1fback\n"
}

# ============================================================
# BATTERY / POWER PROFILE
# ============================================================

battery_menu() {
    profile=$(powerprofilesctl get 2>/dev/null)
    [ -z "$profile" ] && profile="unknown"

    echo -en "\0prompt\x1fPower Profile\n"
    echo -en "\0data\x1fbattery\n"
    echo -en "\0no-custom\x1ftrue\n"

    echo -en "Current: $profile\0nonselectable\x1ftrue\n"
    echo -en "Performance\0info\x1fperformance\n"
    echo -en "Balanced\0info\x1fbalanced\n"
    echo -en "Power Saver\0info\x1fsaver\n"
    echo -en "Back\0info\x1fback\n"
}

# ============================================================
# CLIPBOARD
# ============================================================

clipboard_menu() {
    count=$(get_clipboard_count)

    echo -en "\0prompt\x1fClipboard\n"
    echo -en "\0data\x1fclipboard\n"
    echo -en "\0no-custom\x1ftrue\n"

    echo -en "Clipboard: $count\0nonselectable\x1ftrue\n"
    echo -en "Clear history\0info\x1fclear\n"

    # Current cliphist entries
    cliphist list 2>/dev/null |
    while IFS= read -r line; do
        [ -n "$line" ] || continue

        printf '%s\0info\x1fclip:%s\n' "$line" "$line"
    done

    echo -en "Back\0info\x1fback\n"
}

clipboard_history() {
    selected=$(
        cliphist list 2>/dev/null |
        rofi -dmenu -i \
            -p "Clipboard" \
            -theme "$ROFI_THEME"
    )

    if [ -n "$selected" ]; then
        printf '%s\n' "$selected" |
            cliphist decode |
            wl-copy
    fi
}

# ============================================================
# NOTIFICATIONS
# ============================================================

notifications_menu() {
    count=$(get_notification_count)

    echo -en "\0prompt\x1fNotifications\n"
    echo -en "\0data\x1fnotifications\n"
    echo -en "\0no-custom\x1ftrue\n"

    echo -en "Notifications: $count\0nonselectable\x1ftrue\n"
    echo -en "Clear history\0info\x1fclear\n"

    makoctl list 2>/dev/null |
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        echo -en "$line\0nonselectable\x1ftrue\n"
    done

    echo -en "Back\0info\x1fback\n"
}

notification_history() {
    makoctl list 2>/dev/null |
        rofi -dmenu -i \
            -p "Notifications" \
            -theme "$ROFI_THEME"
}

# ============================================================
# POWER
# ============================================================

power_menu() {
    echo -en "\0prompt\x1fPower\n"
    echo -en "\0data\x1fpower\n"
    echo -en "\0no-custom\x1ftrue\n"

    echo -en "Lock\0info\x1flock\n"
    echo -en "Logout\0info\x1flogout\n"
    echo -en "Reboot\0info\x1freboot\n"
    echo -en "Shutdown\0info\x1fshutdown\n"
    echo -en "Back\0info\x1fback\n"
}

# ============================================================
# ACTION HANDLER
# ============================================================

handle_action() {

    menu="$1"
    action="$2"

    case "$menu" in

        media)
            case "$action" in
                playpause)
                    playerctl play-pause
                    media_menu
                    ;;
                next)
                    playerctl next
                    media_menu
                    ;;
                previous)
                    playerctl previous
                    media_menu
                    ;;
                back)
                    main_menu
                    ;;
            esac
            ;;

        brightness)
            case "$action" in
                increase)
                    brightnessctl set 5%+ >/dev/null 2>&1
                    brightness_menu
                    ;;
                decrease)
                    brightnessctl set 5%- >/dev/null 2>&1
                    brightness_menu
                    ;;
                back)
                    main_menu
                    ;;
            esac
            ;;

        volume)
            case "$action" in
                mute)
                    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
                    volume_menu
                    ;;
                increase)
                    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
                    volume_menu
                    ;;
                decrease)
                    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
                    volume_menu
                    ;;
                back)
                    main_menu
                    ;;
            esac
            ;;

        mic)
            case "$action" in
                mute)
                    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
                    mic_menu
                    ;;
                increase)
                    wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+
                    mic_menu
                    ;;
                decrease)
                    wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-
                    mic_menu
                    ;;
                back)
                    main_menu
                    ;;
            esac
            ;;

        network)
            case "$action" in
                wifi)
                    if [ "$(get_wifi_state)" = "enabled" ]; then
                        nmcli radio wifi off
                    else
                        nmcli radio wifi on
                    fi
                    network_menu
                    ;;

                nmtui)
                    foot -e nmtui &
                    ;;

                back)
                    main_menu
                    ;;
            esac
            ;;

        bluetooth)
            case "$action" in
                toggle)
                    powered=$(bluetoothctl show 2>/dev/null |
                        awk '/Powered:/ {print $2}')

                    if [ "$powered" = "yes" ]; then
                        bluetoothctl power off >/dev/null 2>&1
                    else
                        bluetoothctl power on >/dev/null 2>&1
                    fi

                    bluetooth_menu
                    ;;

                bluetui)
                    foot -e bluetui & >/dev/null 2>&1
                    ;;

                back)
                    main_menu
                    ;;
            esac
            ;;

        battery)
            case "$action" in
                performance)
                    powerprofilesctl set performance
                    battery_menu
                    ;;
                balanced)
                    powerprofilesctl set balanced
                    battery_menu
                    ;;
                saver)
                    powerprofilesctl set power-saver
                    battery_menu
                    ;;
                back)
                    main_menu
                    ;;
            esac
            ;;

        clipboard)
            case "$action" in

               clear)
                    cliphist wipe >/dev/null 2>&1
                    clipboard_menu
                    ;;

               back)
                   main_menu
                   ;;

               clip:*)
                   selected="${action#clip:}"

                   printf '%s\n' "$selected" |
                       cliphist decode |
                       wl-copy

                   clipboard_menu
                   ;;

            esac
            ;;


        notifications)

            case "$action" in
                clear)
                    makoctl dismiss -a >/dev/null 2>&1
                    notifications_menu
                    ;;

                back)
                    main_menu
                    ;;
            esac
            ;;

        power)
            case "$action" in
                lock)
                    swaylock -f
                    ;;

                logout)
                    swaymsg exit
                    ;;

                reboot)
                    systemctl reboot
                    ;;

                shutdown)
                    systemctl poweroff
                    ;;

                back)
                    main_menu
                    ;;
            esac
            ;;

    esac
}

# ============================================================
# ROFI SCRIPT ENTRY
# ============================================================

if [ "$ROFI_RETV" = "0" ]; then

    main_menu
    exit 0

fi

if [ "$ROFI_RETV" = "1" ]; then

    current_menu="$ROFI_DATA"
    selected_action="$ROFI_INFO"

    case "$current_menu" in

        main)
            case "$selected_action" in
                media)
                    media_menu
                    ;;
                brightness)
                    brightness_menu
                    ;;
                volume)
                    volume_menu
                    ;;
                mic)
                    mic_menu
                    ;;
                network)
                    network_menu
                    ;;
                bluetooth)
                    bluetooth_menu
                    ;;
                battery)
                    battery_menu
                    ;;
                clipboard)
                    clipboard_menu
                    ;;
                notifications)
                    notifications_menu
                    ;;
                power)
                    power_menu
                    ;;
            esac
            ;;

        media)
            handle_action media "$selected_action"
            ;;

        brightness)
            handle_action brightness "$selected_action"
            ;;

        volume)
            handle_action volume "$selected_action"
            ;;

        mic)
            handle_action mic "$selected_action"
            ;;

        network)
            handle_action network "$selected_action"
            ;;

        bluetooth)
            handle_action bluetooth "$selected_action"
            ;;

        battery)
            handle_action battery "$selected_action"
            ;;

        clipboard)
            handle_action clipboard "$selected_action"
            ;;

        notifications)
            handle_action notifications "$selected_action"
            ;;

        power)
            handle_action power "$selected_action"
            ;;

    esac

fi

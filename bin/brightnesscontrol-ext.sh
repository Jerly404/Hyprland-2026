#!/usr/bin/env bash

# Import globalcontrol.sh from Hyde to inherit environment and variables (like iconsDir)
scrDir="/home/jerly404/.local/lib/hyde"
if [[ -f "$scrDir/globalcontrol.sh" ]]; then
    source "$scrDir/globalcontrol.sh"
fi

CACHE_FILE="/tmp/brightness-ext-cache"
STEP="${2:-1}"

# Function to detect bus dynamically and cache it
get_bus_arg() {
    local bus_file="/tmp/brightness-ext-bus"
    local bus=""
    if [[ -f "$bus_file" ]]; then
        bus=$(cat "$bus_file")
    else
        bus=$(ddcutil detect --brief 2>/dev/null | awk '/Display/ { is_valid=1 } /Invalid display/ { is_valid=0 } /I2C bus:/ && is_valid { split($0, a, "-"); print a[2]; exit }')
        if [[ -n "$bus" ]]; then
            echo "$bus" > "$bus_file"
        fi
    fi
    if [[ -n "$bus" ]]; then
        echo "--bus $bus"
    fi
}

BUS_ARG=$(get_bus_arg)
DDCUTIL_CMD="ddcutil $BUS_ARG --sleep-multiplier 0.1"

# Function to detect if an external monitor is connected
has_external_monitor() {
    # Check if there is any monitor connected that is not eDP or LVDS (laptop displays)
    hyprctl monitors | grep "Monitor " | grep -q -v -E "eDP-|LVDS-"
}

# Function to get the actual brightness from the monitor (fallback)
query_monitor() {
    # If ddcutil fails or returns empty, default to 50
    local val
    val=$($DDCUTIL_CMD getvcp 10 --brief 2>/dev/null | awk '{print $4}')
    if [[ -z "$val" ]]; then
        val=50
    fi
    echo "$val" > "$CACHE_FILE"
    echo "$val"
}

# If no external monitor is connected, handle gracefully
if ! has_external_monitor; then
    if [[ "$1" == "g" || "$1" == "get" ]]; then
        echo '{"text": "", "alt": "", "tooltip": "No external monitor connected", "class": "disconnected", "percentage": 0}'
    fi
    exit 0
fi

# Ensure cache file exists
if [[ ! -f "$CACHE_FILE" ]]; then
    query_monitor >/dev/null
fi

CURRENT_VAL=$(cat "$CACHE_FILE")

# Validate CURRENT_VAL is a number, otherwise query monitor
if ! [[ "$CURRENT_VAL" =~ ^[0-9]+$ ]]; then
    CURRENT_VAL=$(query_monitor)
fi

send_notification() {
    local val=$1
    local angle="$((((val + 2) / 5) * 5))"
    if [ "$angle" -gt 100 ]; then angle=100; fi
    if [ "$angle" -lt 0 ]; then angle=0; fi
    
    # Use iconsDir from Hyde, fallback if not defined
    local base_icons="${iconsDir:-$HOME/.local/share/icons}"
    local ico="$base_icons/Wallbash-Icon/media/knob-$angle.svg"
    local bar
    bar=$(seq -s "." $((val / 15)) 2>/dev/null | sed 's/[0-9]//g')
    
    notify-send -a "HyDE Notify" -r 8 -t 800 -i "$ico" "$val$bar" "External Monitor"
}

apply_brightness() {
    (
        exec 9>"/tmp/brightness-ext.lock"
        if flock -n 9; then
            local last_written
            if [[ -f "/tmp/brightness-ext-last" ]]; then
                last_written=$(cat "/tmp/brightness-ext-last")
            else
                last_written=-1
            fi
            
            while true; do
                local target
                target=$(cat "$CACHE_FILE" 2>/dev/null || echo "50")
                if [[ "$target" == "$last_written" ]]; then
                    break
                fi
                $DDCUTIL_CMD setvcp 10 "$target" >/dev/null 2>&1
                last_written="$target"
                echo "$last_written" > "/tmp/brightness-ext-last"
            done
        fi
    ) &
}

case "$1" in
    set)
        NEW_VAL="${2:-$CURRENT_VAL}"
        if [ "$NEW_VAL" -gt 100 ]; then NEW_VAL=100; fi
        if [ "$NEW_VAL" -lt 0 ]; then NEW_VAL=0; fi
        echo "$NEW_VAL" > "$CACHE_FILE"
        apply_brightness
        ;;
    g|get)
        echo '{"text": "'"$CURRENT_VAL"'", "alt": "'"$CURRENT_VAL"'", "tooltip": "<span foreground=\"#f0c995\" size=\"small\" letter_spacing=\"1300\">BRILLO MONITOR</span>\n<span foreground=\"#ffe2b9\" size=\"large\"><b>'"$CURRENT_VAL"'%</b></span>\n<span foreground=\"#c4cbe0\" size=\"small\">Gigabyte GS27QA</span>\n\n<span foreground=\"#9babc4\" size=\"small\">↑↓ ajustar  ·  clic sincronizar</span>", "class": "connected", "percentage": '"$CURRENT_VAL"'}'
        ;;
    i|inc)
        NEW_VAL=$((CURRENT_VAL + STEP))
        if [ "$NEW_VAL" -gt 100 ]; then NEW_VAL=100; fi
        echo "$NEW_VAL" > "$CACHE_FILE"
        apply_brightness
        send_notification "$NEW_VAL"
        ;;
    d|dec)
        NEW_VAL=$((CURRENT_VAL - STEP))
        if [ "$NEW_VAL" -lt 0 ]; then NEW_VAL=0; fi
        echo "$NEW_VAL" > "$CACHE_FILE"
        apply_brightness
        send_notification "$NEW_VAL"
        ;;
    s|sync)
        # Force sync cache from physical monitor
        NEW_VAL=$(query_monitor)
        echo "$NEW_VAL" > "/tmp/brightness-ext-last"
        send_notification "$NEW_VAL"
        ;;
    *)
        echo "Usage: $0 {get|inc|dec|sync} [step]"
        exit 1
        ;;
esac

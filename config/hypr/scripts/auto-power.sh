#!/usr/bin/env bash
set -u

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hyde"
power_state="$state_dir/ac_power_state"
mode_file="$state_dir/desktop_mode"
mkdir -p "$state_dir"

online=0
for supply in /sys/class/power_supply/AC*/online /sys/class/power_supply/ADP*/online; do
    [[ -r "$supply" ]] || continue
    [[ $(<"$supply") == 1 ]] && online=1
done

previous=$(cat "$power_state" 2>/dev/null || printf 'unknown')
current_mode=$(cat "$mode_file" 2>/dev/null || printf 'balanced')
[[ "$previous" == "$online" ]] && exit 0

printf '%s\n' "$online" > "$power_state"
if [[ "$online" == 0 ]]; then
    "$HOME/.config/hypr/scripts/desktop-mode.sh" battery
elif [[ "$current_mode" == battery ]]; then
    "$HOME/.config/hypr/scripts/desktop-mode.sh" balanced
fi

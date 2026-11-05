#!/usr/bin/env bash
set -u

if hyprctl clients -j | jq -e '.[] | select(.class == "dev-scratch")' >/dev/null; then
    hyprctl dispatch togglespecialworkspace dev >/dev/null
else
    kitty --class dev-scratch --title "Dev Console" >/dev/null 2>&1 &
    for _ in {1..20}; do
        if hyprctl clients -j | jq -e '.[] | select(.class == "dev-scratch")' >/dev/null; then
            hyprctl dispatch togglespecialworkspace dev >/dev/null
            exit 0
        fi
        sleep 0.05
    done
fi

#!/usr/bin/env bash
set -u

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hyde"
state_file="$state_dir/desktop_mode"
mkdir -p "$state_dir"

notify_mode() {
    notify-send -a "Modo de escritorio" -t 2500 "$1" "$2"
}

static_wallpaper() {
    local current_wall
    pkill -x mpvpaper 2>/dev/null || true
    current_wall=$(readlink -f "${XDG_CACHE_HOME:-$HOME/.cache}/hyde/wall.set" 2>/dev/null || true)
    if [[ -n "$current_wall" ]]; then
        "$HOME/.local/lib/hyde/wallpaper.awww.sh" "$current_wall" >/dev/null 2>&1 &
    fi
}

resume_animated_wallpaper() {
    local current_wall
    current_wall=$(readlink -f "${XDG_CACHE_HOME:-$HOME/.cache}/hyde/wall.set" 2>/dev/null || true)
    if [[ -f "$current_wall" ]] && file --mime-type -b "$current_wall" | grep -q '^video/'; then
        "$HOME/.local/lib/hyde/wallpaper.mpvpaper.sh" "$current_wall" >/dev/null 2>&1 &
    fi
}

apply_mode() {
    local mode="$1"
    case "$mode" in
        focus)
            hyprctl --batch "keyword general:gaps_in 2; keyword general:gaps_out 0; keyword general:border_size 1; keyword decoration:blur:enabled false; keyword animations:enabled false" >/dev/null
            dunstctl set-paused true >/dev/null 2>&1 || true
            static_wallpaper
            notify_mode "󰈙 Concentración" "Animaciones, blur y notificaciones pausadas."
            ;;
        battery)
            powerprofilesctl set power-saver 2>/dev/null || true
            hyprctl --batch "keyword general:gaps_in 2; keyword general:gaps_out 0; keyword general:border_size 1; keyword decoration:blur:enabled false; keyword decoration:shadow:enabled false; keyword animations:enabled false" >/dev/null
            static_wallpaper
            notify_mode "󰁹 Ahorro de batería" "Efectos reducidos y fondo estático."
            ;;
        performance)
            powerprofilesctl set performance 2>/dev/null || true
            hyprctl --batch "keyword decoration:blur:enabled false; keyword decoration:shadow:enabled false; keyword animations:enabled false" >/dev/null
            static_wallpaper
            notify_mode "󰓅 Rendimiento" "Máxima respuesta para juegos y trabajo pesado."
            ;;
        balanced|*)
            powerprofilesctl set balanced 2>/dev/null || true
            dunstctl set-paused false >/dev/null 2>&1 || true
            hyprctl reload >/dev/null
            resume_animated_wallpaper
            notify_mode "󰾅 Equilibrado" "Diseño, fluidez y consumo balanceados."
            mode="balanced"
            ;;
    esac
    printf '%s\n' "$mode" > "$state_file"
}

case "${1:-menu}" in
    menu)
        choice=$(printf '%s\n' \
            "󰾅  Equilibrado" \
            "󰈙  Concentración" \
            "󰁹  Batería" \
            "󰓅  Rendimiento" | rofi -dmenu -i -p "Modo de escritorio") || exit 0
        case "$choice" in
            *Equilibrado) apply_mode balanced ;;
            *Concentración) apply_mode focus ;;
            *Batería) apply_mode battery ;;
            *Rendimiento) apply_mode performance ;;
        esac
        ;;
    current) cat "$state_file" 2>/dev/null || printf 'balanced\n' ;;
    *) apply_mode "$1" ;;
esac

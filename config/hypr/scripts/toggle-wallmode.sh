#!/usr/bin/env bash

# Script para alternar entre Modo Fondo Extendido (Dual Span) y Modo Individual (Por Pantalla)
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/hyde/wall_mode"
mkdir -p "$(dirname "$STATE_FILE")"

# Estado por defecto: span (dividido)
if [ ! -f "$STATE_FILE" ]; then
    echo "span" > "$STATE_FILE"
fi

get_mode() {
    cat "$STATE_FILE" 2>/dev/null || echo "span"
}

status_wallmode() {
    mode=$(get_mode)
    if [ "$mode" == "span" ]; then
        echo '{"text": "󰹑", "tooltip": "Modo Wallpaper: Extendido (Dual Span)\nClick para cambiar a Individual", "class": "span"}'
    else
        echo '{"text": "󰍹", "tooltip": "Modo Wallpaper: Individual (Por Pantalla)\nClick para cambiar a Extendido", "class": "individual"}'
    fi
}

toggle_wallmode() {
    current_mode=$(get_mode)
    if [ "$current_mode" == "span" ]; then
        new_mode="individual"
        echo "individual" > "$STATE_FILE"
        notify-send -a "Wallpaper Mode" -i preferences-desktop-wallpaper "Fondo de Pantalla" "Modo cambiado a: Individual (Completo en cada pantalla)"
    else
        new_mode="span"
        echo "span" > "$STATE_FILE"
        notify-send -a "Wallpaper Mode" -i preferences-desktop-wallpaper "Fondo de Pantalla" "Modo cambiado a: Extendido (Dividido horizontal)"
    fi

    # Re-aplicar el fondo actual inmediatamente con la nueva configuración respetando videos e imágenes
    apply_current_wallpaper
}

apply_current_wallpaper() {
    local cur_wall
    cur_wall=$(readlink -f "${XDG_CACHE_HOME:-$HOME/.cache}/hyde/wall.set" 2>/dev/null)
    if [ -f "$cur_wall" ] && file --mime-type -b "$cur_wall" | grep -q '^video/'; then
        /home/jerly404/.local/lib/hyde/wallpaper.mpvpaper.sh "$cur_wall" &
    else
        /home/jerly404/.local/lib/hyde/wallpaper.awww.sh &
    fi
}

case "$1" in
    status)
        status_wallmode
        ;;
    toggle)
        toggle_wallmode
        ;;
    get)
        get_mode
        ;;
    set)
        if [ -n "$2" ]; then
            echo "$2" > "$STATE_FILE"
            apply_current_wallpaper
        fi
        ;;
    *)
        toggle_wallmode
        ;;
esac

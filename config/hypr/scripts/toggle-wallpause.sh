#!/usr/bin/env bash

# toggle-wallpause.sh
# Alterna entre wallpaper animado (mpvpaper) y wallpaper estático (awww)
# para ahorrar 100% de CPU/GPU cuando se requiera máximo rendimiento o ahorro de batería.

current_wall=$(readlink -f "${XDG_CACHE_HOME:-$HOME/.cache}/hyde/wall.set" 2>/dev/null)

if pgrep -x mpvpaper >/dev/null; then
    # Pausar / Detener animación: matar mpvpaper y aplicar la versión estática mediante awww
    pkill -x mpvpaper || true
    if [ -n "$current_wall" ]; then
        /home/jerly404/.local/lib/hyde/wallpaper.awww.sh "$current_wall" &
    fi
    notify-send -a "Wallpaper" -i media-playback-pause "Fondo de Pantalla" "Modo estático activado (Ahorro de batería / GPU) 󰏤"
else
    # Reanudar animación: si el fondo actual es un video, lanzarlo con mpvpaper
    if [ -f "$current_wall" ] && file --mime-type -b "$current_wall" | grep -q '^video/'; then
        /home/jerly404/.local/lib/hyde/wallpaper.mpvpaper.sh "$current_wall" &
        notify-send -a "Wallpaper" -i media-playback-start "Fondo de Pantalla" "Wallpaper en movimiento reanudado 󰐊"
    else
        notify-send -a "Wallpaper" -i video-x-generic "Fondo de Pantalla" "El wallpaper actual no es un archivo de video."
    fi
fi

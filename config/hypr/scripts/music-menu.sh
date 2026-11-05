#!/usr/bin/env bash
set -u

player="${PLAYERCTL_PLAYER:-spotify,%any}"
status=$(playerctl -p "$player" status 2>/dev/null || true)
artist=$(playerctl -p "$player" metadata artist 2>/dev/null || true)
title=$(playerctl -p "$player" metadata title 2>/dev/null || true)
now="${artist:+$artist — }${title:-Sin reproducción}"

choice=$(printf '%s\n' \
    "󰎈  $now" \
    "󰒮  Anterior" \
    "󰐎  Reproducir / Pausar" \
    "󰒭  Siguiente" \
    "󰝝  Bajar volumen" \
    "󰕾  Subir volumen" \
    "󰓇  Abrir Spotify" | rofi -dmenu -i -p "Música · ${status:-Detenida}") || exit 0

case "$choice" in
    *Anterior) playerctl -p "$player" previous ;;
    *Pausar) playerctl -p "$player" play-pause ;;
    *Siguiente) playerctl -p "$player" next ;;
    *Bajar*) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    *Subir*) wpctl set-volume -l 1.10 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    *Spotify) "$HOME/.local/bin/spotify-optimized" >/dev/null 2>&1 & ;;
esac

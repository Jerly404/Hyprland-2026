#!/usr/bin/env bash
set -u

choice=$(printf '%s\n' \
    "󰀻  Aplicaciones" \
    "󰆍  Terminal de desarrollo" \
    "󰨞  Visual Studio Code" \
    "󰝚  Archivos" \
    "󰎈  Música" \
    "󰉋  Portapapeles" \
    "󰌌  Atajos" \
    "󰔎  Modo de escritorio" \
    "󰌾  Bloquear" \
    "󰐥  Energía" | rofi -dmenu -i -p "Centro rápido") || exit 0

case "$choice" in
    *Aplicaciones) hyde-shell rofilaunch d ;;
    *Terminal*) kitty --class dev-scratch --title "Dev Console" ;;
    *Visual*) code ;;
    *Archivos) dolphin ;;
    *Música) "$HOME/.config/hypr/scripts/music-menu.sh" ;;
    *Portapapeles) hyde-shell cliphist ;;
    *Atajos) hyde-shell keybinds_hint c ;;
    *escritorio) "$HOME/.config/hypr/scripts/desktop-mode.sh" menu ;;
    *Bloquear) hyde-shell lock-session ;;
    *Energía) hyde-shell logoutlaunch ;;
esac

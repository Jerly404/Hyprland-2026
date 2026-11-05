#!/usr/bin/env bash
set -e
hyprctl reload
"$HOME/.local/bin/macos-desktop" restart
dunstctl reload
notify-send "Escritorio actualizado" "Barra, dock y configuración recargados."

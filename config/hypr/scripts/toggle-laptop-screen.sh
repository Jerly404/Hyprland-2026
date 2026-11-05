#!/usr/bin/env bash

# Configuración de los nombres de los monitores
INTERNAL_MONITOR="eDP-2"
INTERNAL_CONF="1920x1080@144,2560x0,1"

# Función para enviar notificaciones
send_notification() {
    local title="$1"
    local message="$2"
    local icon="$3"
    if command -v notify-send >/dev/null; then
        notify-send -u normal -t 3000 -i "$icon" "$title" "$message"
    fi
}

# 1. Detectar si el monitor externo (DP-1 o HDMI-A-1) está activo/conectado
EXTERNAL_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select((.description | contains("GS27QA")) or .name == "HDMI-A-1") | .name' | head -n1)

if [ -z "$EXTERNAL_MONITOR" ]; then
    send_notification "Pantallas" "No se puede apagar la pantalla interna porque no hay monitor externo conectado." "dialog-warning"
    exit 1
fi


# 2. Comprobar si el monitor interno está activo actualmente
if hyprctl monitors -j | jq -e ".[] | select(.name == \"$INTERNAL_MONITOR\")" >/dev/null; then
    # Está activo, proceder a desactivarlo
    hyprctl keyword monitor "$INTERNAL_MONITOR,disable"
    send_notification "Pantallas" "Pantalla de la laptop desactivada (Modo Juego)" "video-display"
else
    # Está inactivo, proceder a activarlo
    hyprctl keyword monitor "$INTERNAL_MONITOR,$INTERNAL_CONF"
    send_notification "Pantallas" "Pantalla de la laptop activada (Modo Trabajo)" "video-display"
fi

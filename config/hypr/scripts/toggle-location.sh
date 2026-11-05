#!/usr/bin/env bash

# Script para activar y desactivar la visualización de la ubicación en la barra (Waybar / HyDE)
CONFIG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/hyde/config"
mkdir -p "$(dirname "$CONFIG_FILE")"

get_status() {
    local val
    val=$(grep "^export WEATHER_SHOW_LOCATION=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2- | tr -d '"' | tr '[:upper:]' '[:lower:]')
    if [ "$val" = "true" ] || [ "$val" = "1" ] || [ "$val" = "yes" ]; then
        echo "active"
    else
        echo "inactive"
    fi
}

get_location_name() {
    local loc
    loc=$(grep "^export WEATHER_LOCATION=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2- | tr -d '"')
    if [ -z "$loc" ]; then
        echo "Auto (IP)"
    else
        echo "$loc"
    fi
}

status_output() {
    local status
    local loc
    status=$(get_status)
    loc=$(get_location_name)

    if [ "$status" = "active" ]; then
        printf '{"text": "󰍎", "tooltip": "Ubicación: Activada (%s)\\nClick izquierdo: Desactivar\\nClick derecho: Menú de ubicación", "class": "active"}\n' "$loc"
    else
        printf '{"text": "󰍍", "tooltip": "Ubicación: Desactivada\\nClick izquierdo: Activar\\nClick derecho: Menú de ubicación", "class": "inactive"}\n'
    fi
}

toggle_location() {
    local current
    current=$(get_status)

    if [ "$current" = "active" ]; then
        # Desactivar
        sed -i 's|^export WEATHER_SHOW_LOCATION=.*|export WEATHER_SHOW_LOCATION="False"|' "$CONFIG_FILE"
        notify-send -a "Ubicación" -i find-location "Ubicación Desactivada" "Se ha ocultado la ubicación en la barra de estado."
    else
        # Activar
        sed -i 's|^export WEATHER_SHOW_LOCATION=.*|export WEATHER_SHOW_LOCATION="True"|' "$CONFIG_FILE"
        notify-send -a "Ubicación" -i find-location "Ubicación Activada" "Se muestra la ubicación en la barra de estado."
    fi

    # Recargar Waybar
    systemctl --user restart hyde-Hyprland-bar.service
}

menu_location() {
    local current_status
    local current_loc
    current_status=$(get_status)
    current_loc=$(get_location_name)

    local toggle_label="󰍎 Activar Ubicación"
    [ "$current_status" = "active" ] && toggle_label="󰍍 Desactivar Ubicación"

    local options="$toggle_label\n🌐 Detección automática por IP (actual: $current_loc)\n✏️ Establecer ciudad manualmente..."
    local choice
    choice=$(echo -e "$options" | rofi -dmenu -p "Ubicación" -theme-str 'window {width: 400px;}')

    case "$choice" in
        *"Activar"*)
            sed -i 's|^export WEATHER_SHOW_LOCATION=.*|export WEATHER_SHOW_LOCATION="True"|' "$CONFIG_FILE"
            notify-send -a "Ubicación" -i find-location "Ubicación Activada" "Visible en la barra."
            systemctl --user restart hyde-Hyprland-bar.service
            ;;
        *"Desactivar"*)
            sed -i 's|^export WEATHER_SHOW_LOCATION=.*|export WEATHER_SHOW_LOCATION="False"|' "$CONFIG_FILE"
            notify-send -a "Ubicación" -i find-location "Ubicación Desactivada" "Oculta de la barra."
            systemctl --user restart hyde-Hyprland-bar.service
            ;;
        *"automática"*)
            sed -i 's|^export WEATHER_LOCATION=.*|export WEATHER_LOCATION=""|' "$CONFIG_FILE"
            sed -i 's|^export WEATHER_SHOW_LOCATION=.*|export WEATHER_SHOW_LOCATION="True"|' "$CONFIG_FILE"
            notify-send -a "Ubicación" -i find-location "Ubicación Automática" "Detectando por IP."
            systemctl --user restart hyde-Hyprland-bar.service
            ;;
        *"manualmente"*)
            local city
            city=$(rofi -dmenu -p "Ingresa tu ciudad" -theme-str 'window {width: 350px;}')
            if [ -n "$city" ]; then
                sed -i "s|^export WEATHER_LOCATION=.*|export WEATHER_LOCATION=\"$city\"|" "$CONFIG_FILE"
                sed -i 's|^export WEATHER_SHOW_LOCATION=.*|export WEATHER_SHOW_LOCATION="True"|' "$CONFIG_FILE"
                notify-send -a "Ubicación" -i find-location "Ubicación Configurada" "Ciudad establecida a: $city"
                systemctl --user restart hyde-Hyprland-bar.service
            fi
            ;;
    esac
}

case "$1" in
    status)
        status_output
        ;;
    toggle)
        toggle_location
        ;;
    menu)
        menu_location
        ;;
    *)
        toggle_location
        ;;
esac

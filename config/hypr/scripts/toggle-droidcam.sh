#!/usr/bin/env bash
service=droidcam-webcam.service
runtime="${XDG_RUNTIME_DIR:-/run/user/$UID}"
state=$(systemctl --user show "$service" -p ActiveState --value)

if [[ "${1:-}" == status ]]; then
    case "$state" in
        active) label='Activo · clic para apagar'; class=active ;;
        activating) label='Conectando…'; class=starting ;;
        deactivating) label='Apagando…'; class=starting ;;
        *) label='Apagado · clic para detectar teléfono USB'; class=inactive ;;
    esac
    jq -cn --arg label "$label" --arg class "$class" \
        '{text:"󰕧",tooltip:("DroidCam: " + $label),class:$class}'
    exit 0
fi

exec 9>"$runtime/droidcam-toggle-$UID.lock"
flock -n 9 || exit 0
state=$(systemctl --user show "$service" -p ActiveState --value)
if [[ "$state" == active || "$state" == activating ]]; then
    if systemctl --user stop "$service"; then
        notify-send -a DroidCam -i camera-web DroidCam 'Cámara desactivada'
    else
        notify-send -a DroidCam -u critical DroidCam 'No se pudo detener la cámara.'
        exit 1
    fi
else
    notify-send -a DroidCam -i camera-web DroidCam 'Detectando teléfono USB…'
    if systemctl --user start "$service"; then
        notify-send -a DroidCam -i camera-web DroidCam 'Cámara del teléfono disponible'
    else
        detail='No se pudo iniciar la cámara. Revisa la conexión USB y la app DroidCam.'
        [[ ! -s "$runtime/droidcam-error" ]] || detail=$(cat "$runtime/droidcam-error")
        notify-send -a DroidCam -u critical -i camera-web DroidCam "$detail"
        exit 1
    fi
fi

#!/usr/bin/env bash
# Idempotent startup for the migrated desktop; also safe after a live recovery.
export PATH="$HOME/.local/bin:$HOME/.local/lib/hyde:$PATH"
state="${XDG_STATE_HOME:-$HOME/.local/state}/hypr-migration-20261029"
mkdir -p "$state" "${XDG_RUNTIME_DIR}/hyde" "$HOME/.cache/hyde/wallbash"
exec >>"$state/startup.log" 2>&1
exec 9>"${XDG_RUNTIME_DIR}/hypr-desktop-start-v2.lock"
flock -n 9 || exit 0
# Do not pass the startup lock to background services.
start_once() {
    local process="$1"; shift
    (pgrep -u "$UID" -x "$process" >/dev/null || exec "$@") 9>&- &
}
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP PATH
start_once dunst dunst
start_once hypridle hypridle
start_once hyprsunset hyprsunset
start_once nm-applet nm-applet --indicator
start_once udiskie udiskie --no-automount --smart-tray
start_once blueman-applet blueman-applet
if ! pgrep -u "$UID" -f 'polkit.*(agent|authentication)|polkit-kde' >/dev/null; then
    hyde-shell polkitkdeauth.sh 9>&- &
fi
if ! pgrep -u "$UID" -f 'wl-paste --type text --watch cliphist store' >/dev/null; then
    wl-paste --type text --watch cliphist store 9>&- &
fi
if ! pgrep -u "$UID" -f 'wl-paste --type image --watch cliphist store' >/dev/null; then
    wl-paste --type image --watch cliphist store 9>&- &
fi
"$HOME/.local/bin/macos-desktop" start 9>&- &
"$HOME/.local/bin/wallpaper" --restore 9>&- &
systemctl --user start hyde-config.service
if ! pgrep -u "$UID" -f '/hyde/batterynotify.sh' >/dev/null; then
    hyde-shell batterynotify 9>&- &
fi
hyprctl setcursor Bibata-Modern-Ice 24

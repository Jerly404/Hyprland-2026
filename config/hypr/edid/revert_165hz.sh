#!/usr/bin/env bash
set -euo pipefail

MKINITCPIO_CONF="/etc/mkinitcpio.conf"
BOOT_ENTRIES_DIR="/boot/loader/entries"
NEW_ENTRY="$BOOT_ENTRIES_DIR/arch-linux-165hz.conf"
LOADER_CONF="/boot/loader/loader.conf"
FIRMWARE_DEST="/usr/lib/firmware/edid/gs27qa_165.bin"
MONITORS_CONF="/home/jerly404/.config/hypr/monitors.conf"

if [[ $EUID -ne 0 ]]; then
    echo "[-] Este script requiere permisos de root. Ejecútalo con: sudo bash $0"
    exit 1
fi

echo "[+] 1. Eliminando entrada secundaria de arranque..."
rm -f "$NEW_ENTRY"

echo "[+] 2. Restaurando /boot/loader/loader.conf..."
if [[ -f "$LOADER_CONF" ]]; then
    sed -i 's|^default arch-linux-165hz.conf.*|#default arch-linux-165hz.conf|' "$LOADER_CONF"
fi

echo "[+] 3. Restaurando /etc/mkinitcpio.conf..."
if [[ -f "${MKINITCPIO_CONF}.bak-edid" ]]; then
    cp -pf "${MKINITCPIO_CONF}.bak-edid" "$MKINITCPIO_CONF"
    echo "    Restaurado desde backup."
else
    sed -i 's| /usr/lib/firmware/edid/gs27qa_165.bin||' "$MKINITCPIO_CONF"
fi

echo "[+] 4. Eliminando firmware custom..."
rm -f "$FIRMWARE_DEST"

echo "[+] 5. Restaurando monitors.conf a 120Hz..."
if [[ -f "$MONITORS_CONF" ]]; then
    sed -i 's|monitor = DP-1,.*|monitor = DP-1, 2560x1440@120, 0x0, 1, vrr, 0|' "$MONITORS_CONF"
fi

echo "[+] 6. Regenerando initramfs con mkinitcpio..."
mkinitcpio -P

echo "[✓] Reversión completada. Tu sistema ha vuelto al estado original."

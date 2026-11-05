#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EDID_SOURCE="$SCRIPT_DIR/gs27qa_165.bin"
FIRMWARE_DIR="/usr/lib/firmware/edid"
FIRMWARE_DEST="$FIRMWARE_DIR/gs27qa_165.bin"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
BOOT_ENTRIES_DIR="/boot/loader/entries"
NEW_ENTRY="$BOOT_ENTRIES_DIR/arch-linux-165hz.conf"
LOADER_CONF="/boot/loader/loader.conf"
MONITORS_CONF="/home/jerly404/.config/hypr/monitors.conf"

if [[ $EUID -ne 0 ]]; then
    echo "[-] Este script requiere permisos de root. Ejecútalo con: sudo bash $0"
    exit 1
fi

if [[ ! -f "$EDID_SOURCE" ]]; then
    echo "[-] Error: No se encontró el archivo $EDID_SOURCE"
    exit 1
fi

echo "[+] 1. Instalando binario EDID 165Hz en $FIRMWARE_DEST..."
mkdir -p "$FIRMWARE_DIR"
cp -f "$EDID_SOURCE" "$FIRMWARE_DEST"
chmod 644 "$FIRMWARE_DEST"

echo "[+] 2. Configurando /etc/mkinitcpio.conf..."
if [[ ! -f "${MKINITCPIO_CONF}.bak-edid" ]]; then
    cp -p "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.bak-edid"
    echo "    Backup creado en ${MKINITCPIO_CONF}.bak-edid"
fi

if ! grep -q "gs27qa_165.bin" "$MKINITCPIO_CONF"; then
    sed -i 's|^FILES=(\(.*\))|FILES=(\1 /usr/lib/firmware/edid/gs27qa_165.bin)|' "$MKINITCPIO_CONF"
    sed -i 's|FILES=( |FILES=(|' "$MKINITCPIO_CONF"
    echo "    Añadido gs27qa_165.bin a FILES en $MKINITCPIO_CONF"
fi

echo "[+] 3. Creando entrada secundaria de arranque en systemd-boot..."
cat > "$NEW_ENTRY" << 'ENTRY_EOF'
title   Arch Linux (linux - 165Hz EDID)
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=33dff43a-e908-4e3f-9fc4-62c93859514d zswap.enabled=0 rw rootfstype=ext4 quiet splash nvidia_drm.modeset=1 drm.edid_firmware=DP-1:edid/gs27qa_165.bin
ENTRY_EOF
chmod 644 "$NEW_ENTRY"
echo "    Entrada creada: $NEW_ENTRY"

echo "[+] 4. Configurando loader.conf (timeout 5s)..."
if [[ -f "$LOADER_CONF" ]]; then
    if ! grep -q "^timeout" "$LOADER_CONF"; then
        echo "timeout 5" >> "$LOADER_CONF"
    else
        sed -i 's|^timeout .*|timeout 5|' "$LOADER_CONF"
    fi
    if ! grep -q "^default" "$LOADER_CONF"; then
        echo "default arch-linux-165hz.conf" >> "$LOADER_CONF"
    else
        sed -i 's|^default .*|default arch-linux-165hz.conf|' "$LOADER_CONF"
    fi
fi

echo "[+] 5. Actualizando monitors.conf para 165Hz..."
if [[ -f "$MONITORS_CONF" ]]; then
    sed -i 's|monitor = DP-1,.*|monitor = DP-1, 2560x1440@165, 0x0, 1, vrr, 0|' "$MONITORS_CONF"
fi

echo "[+] 6. Regenerando initramfs con mkinitcpio..."
mkinitcpio -P

echo ""
echo "================================================================"
echo "[✓] ¡Proceso completado con éxito!"
echo "    - Entrada creada: Arch Linux (linux - 165Hz EDID)"
echo "    - Tu entrada original de Arch Linux permanece intacta."
echo "    - Puedes reiniciar ahora con: sudo reboot"
echo "================================================================"

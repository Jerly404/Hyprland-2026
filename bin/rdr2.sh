#!/bin/bash
echo "🎮 MODO GAMING ACTIVADO"

echo "[1/8] Matando navegadores..."
killall -9 chrome chromium brave firefox 2>/dev/null

echo "[2/8] Matando Discord..."
killall -9 discord 2>/dev/null

echo "[3/8] Matando VSCode..."
killall -9 code code-oss 2>/dev/null

echo "[4/8] Matando terminals..."
killall -9 kitty alacritty 2>/dev/null

echo "[5/8] Desactivando Polybar..."
killall -9 polybar 2>/dev/null

echo "[6/8] Desactivando sombras (Picom)..."
killall -9 picom 2>/dev/null

echo "[7/8] Desactivando compositor..."
killall -9 compton 2>/dev/null

echo "[8/8] Limpiando caché..."
sync

echo ""
free -h

echo ""
echo "🚀 Lanzando Red Dead Redemption 2..."

export STEAM_COMPAT_CLIENT_INSTALL_PATH=~/.steam/steam
export STEAM_COMPAT_DATA_PATH=~/.steam/steam/compatdata/1174180
export DRI_PRIME=1
export __GLX_THREADED_OPTIMIZATION=1
export PROTON_ENABLE_NVAPI=1
export PROTON_USE_WINED3D=0
export WINEDEBUG=-all
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
export VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d

~/.steam/steam/compatibilitytools.d/GE-Proton9-27/proton run \
  ~/.steam/steam/steamapps/common/Red\ Dead\ Redemption\ 2/RDR2.exe

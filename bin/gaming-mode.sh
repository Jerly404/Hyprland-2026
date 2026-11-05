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
echo "✅ Listo para jugar!"

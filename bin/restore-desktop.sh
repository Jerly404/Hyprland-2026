#!/bin/bash
echo "🔄 Restaurando escritorio..."

bspwm &
sleep 1
polybar emi-bar &
sleep 0.5
picom --config ~/.config/bspwm/picom.conf &

echo "✅ Escritorio restaurado"

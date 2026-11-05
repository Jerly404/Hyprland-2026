#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="$HOME/.config/hyprland-2026-backups/$STAMP"

mkdir -p "$BACKUP_ROOT/config" "$HOME/.config" "$HOME/.local/bin"

backup_path() {
  local source="$1" destination="$2"
  if [[ -e "$source" ]]; then
    mkdir -p "$(dirname -- "$destination")"
    cp -a "$source" "$destination"
  fi
}

backup_path "$HOME/.config/hypr" "$BACKUP_ROOT/config/hypr"
backup_path "$HOME/.config/macos-desktop" "$BACKUP_ROOT/config/macos-desktop"

if compgen -G "$REPO_DIR/bin/*" >/dev/null; then
  mkdir -p "$BACKUP_ROOT/bin"
  for file in "$REPO_DIR"/bin/*; do
    name="$(basename -- "$file")"
    backup_path "$HOME/.local/bin/$name" "$BACKUP_ROOT/bin/$name"
  done
fi

rm -rf "$HOME/.config/hypr" "$HOME/.config/macos-desktop"
mkdir -p "$HOME/.config"
cp -a "$REPO_DIR/config/hypr" "$HOME/.config/hypr"
cp -a "$REPO_DIR/config/macos-desktop" "$HOME/.config/macos-desktop"

if compgen -G "$REPO_DIR/bin/*" >/dev/null; then
  for file in "$REPO_DIR"/bin/*; do
    name="$(basename -- "$file")"
    cp -a "$file" "$HOME/.local/bin/$name"
    chmod u+x "$HOME/.local/bin/$name" 2>/dev/null || true
  done
fi

# Hacer portables las rutas que pertenecían al equipo original.
grep -RIl --exclude='*.bin' '/home/jerly404' "$HOME/.config/hypr" "$HOME/.config/macos-desktop" "$HOME/.local/bin" 2>/dev/null \
  | xargs -r sed -i "s#/home/jerly404#${HOME}#g"

printf 'Configuración restaurada. Copia anterior: %s\n' "$BACKUP_ROOT"
printf 'Recarga Hyprland con Super+Shift+R o ejecuta: hyprctl reload\n'


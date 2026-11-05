# Hyprland-2026

Copia reproducible de mi configuración actual de Hyprland y del escritorio con estilo macOS.

## Restaurar en otra instalación

```bash
git clone https://github.com/Jerly404/Hyprland-2026.git
cd Hyprland-2026
./install.sh
```

El instalador hace una copia de seguridad con fecha antes de reemplazar `~/.config/hypr`, `~/.config/macos-desktop` y los scripts incluidos en `~/.local/bin`. Las rutas antiguas `/home/jerly404` se adaptan automáticamente al usuario que ejecute el script.

El archivo EDID de `config/hypr/edid` queda guardado como referencia, pero no se aplica automáticamente porque depende del monitor. El instalador tampoco instala paquetes del sistema: primero hay que tener Hyprland, Waybar, Rofi, Kitty, hyprlock, hypridle y las herramientas usadas por los scripts.

La imagen de fondo no se incluye: la copia original era un enlace absoluto a una ruta local. Configura tu propio fondo después de instalar.

## Contenido

- `config/hypr`: configuración, reglas, animaciones, temas, shaders y scripts.
- `config/macos-desktop`: barra, dock y preferencias del tema.
- `bin`: scripts personales usados por la configuración.
- `install.sh`: restauración segura y portable.

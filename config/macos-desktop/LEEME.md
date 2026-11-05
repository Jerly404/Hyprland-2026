# Escritorio inspirado en macOS

Perfil oscuro con opción clara, barra superior de 36 px en ambas pantallas y controles de ventana rojo, amarillo y verde. Usa iconos Tela-circle-dracula, cursor Bibata-Modern-Ice, tipografía Inter, animaciones breves y sombras suaves. El terminal conserva su fondo grafito opaco. El fondo de pantalla se gestiona por separado.

Tu sistema sigue siendo Arch Linux con Hyprland. Las aplicaciones que dibujan su propia interfaz pueden mantener sus colores y botones. Algunas necesitan cerrarse y abrirse de nuevo para tomar la tipografía y el tema nuevos.

## Uso diario

Super es la tecla Windows del teclado.

| Atajo | Acción |
| --- | --- |
| Super + Espacio | Buscar aplicaciones |
| Super + Tab | Seleccionar una ventana |
| Super + M | Minimizar la ventana |
| Super + Ctrl + F | Maximizar o restaurar |
| Super + W | Alternar ventana flotante y mosaico |
| Super + Ctrl + Espacio | Centro de control |
| Super + coma | Centro de control |
| Super + L / Super + Ctrl + Q | Bloquear |
| Super + Shift + 3 | Capturar el monitor |
| Super + Shift + 4 | Capturar una región |
| Super + T | Terminal |
| Super + E | Archivos |

El botón rojo cierra la ventana, el amarillo la minimiza y el verde maximiza o restaura. También puedes maximizar con doble clic en el título. Recupera las ventanas minimizadas con Super + Tab o pulsando el nombre de la aplicación en la barra superior. El dock está desactivado en este perfil.

La lupa abre el buscador; el icono de controles abre sonido, conectividad, energía y brillo. La campana recupera la última notificación y su clic derecho alterna No molestar. El reloj abre el calendario. La rueda sobre el icono de sonido ajusta el volumen.

La barra se oculta cuando una aplicación ocupa la pantalla completa. Se mantienen los modos de ahorro de batería, concentración y rendimiento existentes. No se han modificado las frecuencias de las pantallas ni los controladores.

## Archivos y servicios

- `~/.config/macos-desktop/`: barra, dock y documentación.
- `~/.config/hypr/lua/macos.lua`: apariencia, animaciones y atajos.
- `~/.config/rofi/macos.rasi`: buscador.
- `~/.config/kitty/macos.conf`: terminal.
- `~/.config/hypr/hyprlock.conf`: bloqueo.
- `~/.config/dunst/dunstrc.d/zz-macos.conf`: notificaciones.
- `macos-bar.service`: servicio de la barra, iniciado por la sesión de Hyprland.
- `~/.local/lib/hypr-plugins/hyprbars.so`: controles de ventana, cargados desde Lua.

Para reiniciar la barra: `macos-desktop restart`. Para cambiar el tema: `macos-desktop theme dark` o `macos-desktop theme light` (también Super + Shift + T). La configuración Lua y las preferencias GTK/Kvantum comparten el modo guardado.

Mientras exista `~/.config/macos-desktop/enabled`, la generación automática de colores de HyDE queda suspendida para que cambiar el fondo no sobrescriba este perfil. El gestor de fondos continúa funcionando. No mezcles el selector de temas de HyDE con este perfil; restaura primero si quieres volver a ese flujo.

## Restaurar la configuración anterior

Ejecuta `macos-desktop-restore` desde tu sesión. No requiere sudo. Comprueba la copia, recupera las ventanas minimizadas, detiene los dos servicios y restaura los archivos y ajustes guardados antes del cambio. Conserva el estado que reemplaza en otra carpeta de recuperación.

La copia original está en `~/.local/state/macos-desktop/backups/20261103-095748`. Puedes comprobarla sin restaurar con `macos-desktop-restore --check`.

Los iconos WhiteSur y el tema Kvantum instalados permanecen disponibles tras restaurar, sin activarse.

## Comprobación de la reparación

El informe de las pruebas está en `~/.local/state/macos-desktop/repair-verification.json`. Se verificaron la configuración Lua completa, la recarga desde HyDE, el complemento, ambos monitores, la barra, los atajos, ambos temas, minimizar/maximizar/restaurar/cerrar una ventana temporal y el buscador.

La versión instalada de Rofi falla en `display_cleanup` al ejecutar `-rasi-validate`; el buscador real abrió correctamente durante la prueba. No se reinició la sesión del usuario.

## Créditos

- [WhiteSur GTK](https://github.com/vinceliuice/WhiteSur-gtk-theme), tema ya instalado localmente como MacOS.
- [WhiteSur Icons](https://github.com/vinceliuice/WhiteSur-icon-theme).
- [WhiteSur KDE / Kvantum](https://github.com/vinceliuice/WhiteSur-kde).
- Fondo MacTahoe-Light ya disponible en tu colección local.

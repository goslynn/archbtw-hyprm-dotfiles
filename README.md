# dotfiles

Setup minimalista de Hyprland (Wayland) en Arch. Toda la configuración vive
aquí y se aplica al `$HOME` con [GNU stow](https://www.gnu.org/software/stow/).

---

## Índice

- [Flujo stow](#flujo-stow)
- [Paquetes incluidos](#paquetes-incluidos)
- [Cómo modificar cada herramienta](#cómo-modificar-cada-herramienta)
- [Theming (Catppuccin Mocha)](#theming-catppuccin-mocha)
- [Wallpaper](#wallpaper)
- [Keybindings](#keybindings)
- [Screenshots](#screenshots)
- [Servicios en autostart](#servicios-en-autostart)
- [Troubleshooting](#troubleshooting)

---

## Flujo stow

Cada subdirectorio de `~/.dotfiles/` es un **paquete stow** con la estructura
que reproduce su destino en `$HOME`:

```
~/.dotfiles/
├── hypr/
│   └── .config/
│       └── hypr/
│           ├── hyprland.conf
│           └── hyprpaper.conf
├── waybar/
│   └── .config/
│       └── waybar/
│           ├── config.jsonc
│           └── style.css
└── ...
```

Al correr `stow -t ~ hypr`, stow crea el symlink `~/.config/hypr →
~/.dotfiles/hypr/.config/hypr`. Editar los archivos en `~/.dotfiles/` o en
`~/.config/` es equivalente: son el mismo archivo.

**Aplicar todos los paquetes:**

```bash
cd ~/.dotfiles
for p in */; do stow -t "$HOME" "${p%/}"; done
```

**Re-aplicar un paquete (tras añadir archivos):**

```bash
cd ~/.dotfiles && stow -R -t "$HOME" hypr
```

**Desaplicar:**

```bash
cd ~/.dotfiles && stow -D -t "$HOME" hypr
```

**Añadir una nueva herramienta** (ejemplo `foo`):

```bash
mkdir -p ~/.dotfiles/foo/.config/foo
mv ~/.config/foo/* ~/.dotfiles/foo/.config/foo/
rmdir ~/.config/foo
cd ~/.dotfiles && stow -t "$HOME" foo
```

---

## Paquetes incluidos

| Paquete       | Qué contiene                                       |
|---------------|----------------------------------------------------|
| `hypr`        | Hyprland (`hyprland.conf`, `hyprpaper.conf`)       |
| `waybar`      | Barra superior (`config.jsonc`, `style.css`)       |
| `mako`        | Daemon de notificaciones                           |
| `fuzzel`      | App launcher (`fuzzel.ini`)                        |
| `scripts`     | `~/.local/bin/screenshot.sh` — pipeline unificado (grim + slurp + satty) |
| `themes`      | Paleta Catppuccin Mocha (fuente única)             |
| `kitty`       | Terminal                                           |
| `nvim`        | Editor                                             |
| `git`         | Git config                                         |
| `starship`    | Prompt                                             |
| `btop` `mpv`  | Monitor de sistema, reproductor                    |
| `easyeffects` | Procesador de audio                                |
| `gtk-3.0` `gtk-4.0` `qt5ct` `qt6ct` `xdg-misc` | Theming/MIME de toolkits |

---

## Cómo modificar cada herramienta

### Hyprland — `~/.config/hypr/`

La config está **modularizada** en `conf.d/`. El entry point `hyprland.conf`
solo hace `source` en el orden correcto (las variables y tokens deben definirse
antes de sus consumidores):

```
hyprland.conf            # entry point (solo sources)
hyprpaper.conf           # wallpaper daemon
conf.d/
├── monitors.conf        # monitor=
├── env.conf             # env vars
├── programs.conf        # $terminal, $menu, $fileManager, $browser
├── style.conf           # general/decoration/animations
├── layout.conf          # dwindle/master/misc
├── input.conf           # input/touchpad/gestures
├── autostart.conf       # exec-once
├── rules.conf           # windowrule
└── keybinds.conf        # bind/binde/bindel/bindl/bindm
```

Edita el archivo correspondiente al área que vas a modificar. Aplicar cambios
sin reiniciar: `hyprctl reload`. Ver errores: `hyprctl configerrors`.

### Waybar — `~/.config/waybar/`

- `config.jsonc`: módulos visibles y su contenido. Editar `modules-left/center/right`
  para reordenar; cada módulo tiene su bloque con `format`, `on-click`, etc.
- `style.css`: estética. Colores vienen del `@import` a `themes/catppuccin/mocha/waybar.css`.

Recargar tras cambios: `pkill waybar && setsid -f waybar &`.

### Mako — `~/.config/mako/config`

- `default-timeout`: ms antes de auto-cerrar (5000 por defecto).
- `anchor`: posición (`top-right` por defecto).
- `width` / `height` / `padding`: dimensiones.

Recargar: `makoctl reload`.

Probar: `notify-send "Título" "Cuerpo"`.

### Fuzzel — `~/.config/fuzzel/fuzzel.ini`

- `font`: tipografía y tamaño.
- `width` / `lines`: tamaño del popup.
- `prompt`: el `❯ ` que aparece a la izquierda.
- `terminal=kitty`: qué emulador abre cuando un .desktop pide terminal.

Sin daemon — relanza solo cuando lo invocas.

### Kitty / Nvim / btop / mpv

Configuraciones tuyas pre-existentes; ya están bajo stow sin modificar.

---

## Theming (Catppuccin Mocha)

Todos los colores viven en `~/.config/themes/catppuccin/mocha/`. Cada
herramienta hace `source`/`include`/`@import` desde ahí:

| Archivo          | Lo consume                                          |
|------------------|------------------------------------------------------|
| `tokens.conf`    | Referencia humana — paleta canónica (no la lee nadie)|
| `hyprland.conf`  | `~/.config/hypr/hyprland.conf` vía `source =`        |
| `waybar.css`     | `~/.config/waybar/style.css` vía `@import`           |
| `mako.conf`      | `~/.config/mako/config` vía `include=`               |
| `fuzzel.ini`     | `~/.config/fuzzel/fuzzel.ini` vía `include=`         |

**Para cambiar a otro theme:** reemplaza el contenido de estos archivos
manteniendo los nombres y formatos. Después: `hyprctl reload`, `pkill -USR2 waybar`
(o `pkill waybar && setsid -f waybar &`), `makoctl reload`.

No hay multi-theming ni cambio en vivo — el switch es manual y único.

---

## Wallpaper

El wallpaper activo se resuelve siempre vía el symlink fijo
**`/home/vgonz/Pictures/Wallpapers/bgwp.jpg`** — repuntar el symlink es el
único paso para cambiar de fondo.

> hyprpaper 0.8.4 (Arch repo) ignora silenciosamente las directivas
> `preload`/`wallpaper` en `hyprpaper.conf`. Se driveva por IPC desde
> `conf.d/autostart.conf` después de lanzar el daemon.

### Cambiar wallpaper

```bash
ln -sfn /ruta/a/nueva-imagen.jpg /home/vgonz/Pictures/Wallpapers/bgwp.jpg
hyprctl hyprpaper reload ,/home/vgonz/Pictures/Wallpapers/bgwp.jpg
```

(Hyprpaper detecta el formato por la **extensión** del path, no por el
contenido. Mantén `.jpg`/`.png`/`.webp` en el nombre del symlink aunque el
archivo destino tenga otro nombre.)

---

## Keybindings

`SUPER` = tecla Windows.

### Apps

| Bind                | Acción                          |
|---------------------|---------------------------------|
| `SUPER + SPACE`     | **App launcher (fuzzel)**       |
| `SUPER + T`         | Terminal (kitty)                |
| `SUPER + F`         | File manager (yazi en kitty — default system-wide) |
| `SUPER + B`         | Browser (brave)                 |
| `SUPER + C`         | Clipboard history (cliphist+fuzzel) |
| `SUPER + M`         | Salir de Hyprland               |

Yazi está registrado como default de `inode/directory` vía `~/.config/mimeapps.list`,
así que `xdg-open <dir>` desde cualquier app también lo abre.

### Ventanas

| Bind                       | Acción                          |
|----------------------------|---------------------------------|
| `SUPER + Q`                | Cerrar ventana activa           |
| `SUPER + V`                | Toggle floating                 |
| `SUPER + SHIFT + F`        | Fullscreen (con barras)         |
| `SUPER + CTRL + F`         | Fullscreen total                |
| `SUPER + J`                | Toggle split direction (dwindle)|
| `SUPER + P`                | Pseudotile                      |
| `SUPER + LMB` (drag)       | Mover ventana                   |
| `SUPER + RMB` (drag)       | Redimensionar                   |
| `SUPER + CTRL + flechas`   | Redimensionar 30px              |

### Focus / movimiento

| Bind                          | Acción                       |
|-------------------------------|------------------------------|
| `SUPER + h/j/k/l` o flechas   | Mover foco                   |
| `SUPER + SHIFT + flechas`     | Mover ventana en el tile     |

### Workspaces

| Bind                       | Acción                          |
|----------------------------|---------------------------------|
| `SUPER + 1..9, 0`          | Ir a workspace 1..10            |
| `SUPER + SHIFT + 1..9, 0`  | Mover ventana a workspace       |
| `SUPER + mouse wheel`      | Ciclar workspaces               |
| `SUPER + ` ` (backtick)    | Scratchpad toggle               |
| `SUPER + SHIFT + ` `       | Mover ventana al scratchpad     |

### Screenshots

Ver sección [Screenshots](#screenshots).

### Multimedia (teclas dedicadas)

| Tecla                         | Acción                       |
|-------------------------------|------------------------------|
| `XF86AudioRaise/Lower/Mute`   | Volumen sistema              |
| `XF86AudioMicMute`            | Mute micrófono               |
| `XF86MonBrightnessUp/Down`    | Brillo pantalla              |
| `XF86AudioNext/Prev/Play`     | Control reproductor          |

---

## Screenshots

Pipeline unificado: todos guardan a `~/Pictures/Screenshots/{YYYYMMDD-HHMMSS}-ss.png`
y copian al portapapeles.

| Bind                          | Modo                                    |
|-------------------------------|-----------------------------------------|
| `SUPER + SHIFT + S`           | Selección rápida (sin editor)           |
| `SUPER + S` o `Print`         | Fullscreen                              |
| `SUPER + SHIFT + CTRL + S`    | Selección + editor satty (anotaciones)  |
| `SUPER + SHIFT + ALT + S`     | Ventana activa (workaround grim+hyprctl)|

Script: `~/.local/bin/screenshot.sh {selection|full|window|edit}`.

Modificar comportamiento (formato, paths, notificación): editar
`~/.dotfiles/scripts/.local/bin/screenshot.sh`.

---

## Servicios en autostart

Lanzados por `exec-once` en `hyprland.conf`:

| Proceso                      | Función                              |
|------------------------------|--------------------------------------|
| `waybar`                     | Barra superior                       |
| `mako`                       | Notificaciones                       |
| `nm-applet --indicator`      | Tray de NetworkManager               |
| `hyprpaper`                  | Wallpaper                            |
| `polkit-gnome-...agent-1`    | Diálogos de autenticación            |
| `wl-paste ... cliphist`      | Captura clipboard a histórico        |

Los `exec-once` solo se disparan al **inicio de sesión**, no en `hyprctl reload`.
Para relanzar uno manualmente: `pkill <proc> && setsid -f <proc> &`.

---

## Troubleshooting

- **Errores de config Hyprland**: `hyprctl configerrors`.
- **Waybar no aparece**: `pkill waybar; waybar` (corre en foreground para ver el error).
- **Notificaciones no llegan**: `pgrep mako` debe devolver PID. Test: `notify-send hola`.
- **Pantalla negra al loguear**: Hyprland no encontró ningún `exec-once`. Revisa el
  log en `$XDG_RUNTIME_DIR/hypr/*/Hyprland.log`.
- **Backup pre-rice**: `~/dotfiles-backup-20260527-230822.tar.gz` — restaurar con
  `tar -xzf ... -C ~`.

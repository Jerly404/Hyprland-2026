-- Personal profile, loaded after HyDE. Disable by removing this dofile from hyprland.lua.
local home = os.getenv("HOME")
-- Load through the native Lua configuration so this also works on login.
-- Hyprland loads plugins after the first pass, then reloads the configuration.
local hyprbars_path = home .. "/.local/lib/hypr-plugins/hyprbars.so"
local hyprbars_file = io.open(hyprbars_path, "rb")
if hyprbars_file then
  hyprbars_file:close()
  hl.plugin.load(hyprbars_path)
end
local has_hyprbars = hl.plugin.hyprbars and hl.plugin.hyprbars.add_button
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
-- Keep toolkit defaults after HyDE regenerates its Lua from an existing session.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_SCALE", "1")

-- Determine theme mode (dark or light)
local theme_file = io.open(home .. "/.config/macos-desktop/theme-mode", "r")
local theme_mode = "dark"
if theme_file then
  theme_mode = theme_file:read("*l") or "dark"
  theme_file:close()
end

local is_dark = theme_mode == "dark"
local bar_bg = is_dark and "rgb(24, 32, 44)" or "rgb(241, 247, 255)"
local bar_fg = is_dark and "rgba(226, 232, 240, 1.0)" or "rgba(32, 42, 59, 1.0)"
local border_act = is_dark and "rgba(255, 255, 255, 0.14)" or "rgba(0, 0, 0, 0.14)"
local border_inact = is_dark and "rgba(255, 255, 255, 0.05)" or "rgba(0, 0, 0, 0.06)"
local shadow_col = is_dark and "rgba(0, 0, 0, 0.38)" or "rgba(0, 0, 0, 0.18)"

hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 1,
    resize_on_border = true,
    ["col.active_border"] = border_act,
    ["col.inactive_border"] = border_inact,
  },
  decoration = {
    rounding = 12,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,
    dim_inactive = false,
    shadow = {
      enabled = true,
      range = 22,
      render_power = 3,
      color = shadow_col,
      offset = "0 8",
    },
    blur = {
      enabled = false,
    },
    wobble = { enabled = false },
    motion_blur = { enabled = false },
    glow = { enabled = false },
  },
  animations = { enabled = true },
  input = {
    follow_mouse = 1,
    mouse_refocus = true,
    touchpad = {
      natural_scroll = true,
      tap_to_click = true,
      disable_while_typing = true,
    },
  },
  misc = {
    font_family = "Inter",
    focus_on_activate = true,
  },
  group = {
    ["col.border_active"] = border_act,
    groupbar = {
      font_family = "Inter",
      font_size = 11,
      ["col.active"] = border_act,
      ["col.inactive"] = border_inact,
      text_color = "rgba(ffffffff)",
      text_color_inactive = "rgba(a6adc8ff)",
    },
  },
})

-- Plugin settings and rules must wait until its Lua API is available.
if has_hyprbars then
hl.config({
  plugin = {
    hyprbars = {
      bar_height = 34,
      bar_color = bar_bg,
      bar_text_size = 12,
      bar_text_font = "Inter",
      bar_text_weight = "semibold",
      bar_text_align = "center",
      bar_buttons_alignment = "left",
      bar_part_of_window = true,
      bar_precedence_over_border = true,
      bar_padding = 14,
      bar_button_padding = 8,
      icon_on_hover = true,
      ["col.text"] = bar_fg,
      on_double_click = home .. "/.local/bin/macos-desktop maximize",
    },
  },
})

  hl.plugin.hyprbars.add_button({
    bg_color = "rgb(ff5f56)",
    fg_color = "rgb(800000)",
    size = 12,
    icon = "✕",
    action = "/usr/bin/hyprctl dispatch 'hl.dsp.window.close()'",
  })
  hl.plugin.hyprbars.add_button({
    bg_color = "rgb(ffbd2e)",
    fg_color = "rgb(805500)",
    size = 12,
    icon = "−",
    action = home .. "/.local/bin/macos-desktop minimize",
  })
  hl.plugin.hyprbars.add_button({
    bg_color = "rgb(27c93f)",
    fg_color = "rgb(005500)",
    size = 12,
    icon = "+",
    action = home .. "/.local/bin/macos-desktop maximize",
  })
end

hl.curve("macEase", { type = "bezier", points = {{0.16, 1.0}, {0.3, 1.0}} })
for _, leaf in ipairs({"windows", "windowsIn", "windowsMove"}) do
  hl.animation({ leaf = leaf, enabled = true, speed = 3.5, bezier = "macEase", style = "popin 96%" })
end
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "macEase", style = "popin 98%" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "macEase" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "macEase", style = "slide" })
hl.animation({ leaf = "borderangle", enabled = false })
hl.layer_rule({ name = "macos_bar_blur", match = { namespace = "macos" }, blur = false })

-- macOS floating window behavior: all windows float by default and center at a clean desktop size
hl.window_rule({ name = "macos_desktop_float_all", match = { class = ".*" }, float = true })
hl.window_rule({ name = "macos_desktop_windows", match = {
  class = "^(org\\.kde\\.dolphin|google-chrome|brave-browser|zen|code-oss|Code|obsidian|Spotify|spotify|kitty)$"
}, float = true, size = "82% 85%", center = true })

-- Opacity override: force 100% solid opacity on all windows (no transparency)
hl.window_rule({ name = "macos_solid_opacity", match = { class = ".*" }, opacity = 1.0 })

-- Do not show duplicate hyprbars on windows that already draw their own CSD tab bar
if has_hyprbars then
  hl.window_rule({ name = "browser_csd_nobar", match = { class = "^(google-chrome|brave-browser|zen|firefox)$" }, ["hyprbars:no_bar"] = true })
  hl.window_rule({ name = "gamescope_nobar", match = { class = "^(gamescope)$" }, ["hyprbars:no_bar"] = true })
end

-- Eliminate gaps if a window is tiled alone on a workspace
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })

local function bind(keys, cmd, description)
  hl.unbind(keys)
  hl.bind(keys, hl.dsp.exec_cmd(home .. "/.local/bin/macos-desktop " .. cmd), { description = description })
end
bind("Super + Space", "spotlight", "Buscar aplicaciones · Spotlight")
bind("Super + A", "spotlight", "Aplicaciones")
bind("Super + Tab", "windows", "Cambiar de ventana")
bind("Super + Control + Space", "control", "Centro de control")
bind("Super + Shift + 3", "capture-screen", "Capturar pantalla")
bind("Super + Shift + 4", "capture-region", "Capturar selección")
bind("Super + Control + Q", "lock", "Bloquear pantalla")
bind("Super + L", "lock", "Bloquear pantalla")
bind("Super + comma", "control", "Ajustes del escritorio")
bind("Super + M", "minimize", "Minimizar ventana · recuperar con Super + Tab")
bind("Super + Control + F", "maximize", "Maximizar o restaurar ventana")
bind("Super + Shift + T", "toggle-theme", "Alternar modo oscuro / claro")

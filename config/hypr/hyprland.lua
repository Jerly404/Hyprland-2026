-- Hyprland 0.57: personal HyDE configuration migrated on 2026-10-29.
-- Legacy theme selectors remain usable through ~/.local/bin/hyprctl.
-- Add native Lua overrides below the dofile line.
local home = os.getenv("HOME")
hl.env("PATH", home .. "/.local/bin:" .. home .. "/.local/lib/hyde:" .. os.getenv("PATH"))

-- Protect gestures from shadowing errors during reload or re-exec
local raw_gesture = hl.gesture
hl.gesture = function(t) pcall(raw_gesture, t) end

dofile(home .. "/.config/hypr/lua/migrated.lua")
-- Keep the established low-overhead profile.
hl.config({decoration={wobble={enabled=false}, motion_blur={enabled=false}, glow={enabled=false}}})

-- Keep the monitor signal/profile stable when videos enter fullscreen.
-- Content-type signalling can make displays blank while switching picture modes.
hl.config({render={send_content_type=false, cm_auto_hdr=0}})

-- macOS-inspired desktop profile
dofile(home .. "/.config/hypr/lua/macos.lua")

-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

-- This table will hold the configuration
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
config.native_macos_fullscreen_mode = false
config.window_decorations = 'RESIZE'

config.color_scheme = 'Tokyo Night'
config.color_scheme_dirs = { '~/.config/wezterm/colors' }
config.window_background_opacity = 1 -- 0.9

-- Font
config.font = wezterm.font 'Iosevka Fixed SS15'
config.font_size = 14
config.underline_position = -6
config.underline_thickness = 2

config.adjust_window_size_when_changing_font_size = false
config.use_dead_keys = false

config.keys = {
    {
        key = 'LeftArrow',
        mods = 'ALT',
        action = act.ActivatePaneDirection 'Left',
    },
    {
        key = 'RightArrow',
        mods = 'ALT',
        action = act.ActivatePaneDirection 'Right',
    },
    {
        key = 'UpArrow',
        mods = 'ALT',
        action = act.ActivatePaneDirection 'Up',
    },
    {
        key = 'DownArrow',
        mods = 'ALT',
        action = act.ActivatePaneDirection 'Down',
    },
    {
        key = 'Z',
        mods = 'CTRL',
        action = act.TogglePaneZoomState,
    },
}

config.inactive_pane_hsb = {
    saturation = 0.75,
    brightness = 0.5,
}

-- Decide whether cmd represents a default startup invocation
function is_default_startup(cmd)
    if not cmd then
        -- we were started with `wezterm` or `wezterm start` with
        -- no other arguments
        return true
    end
    if cmd.domain == "DefaultDomain" and not cmd.args then
        -- Launched via `wezterm start --cwd something`
        return true
    end
    -- we were launched some other way
    return false
end

wezterm.on('gui-startup', function(cmd)
    if is_default_startup(cmd) then
        -- for the default startup case, we want to switch to the unix domain instead
        local domain = mux.get_domain("local")
        mux.set_default_domain(domain)
        -- ensure that it is attached
        domain:attach()
    end

    -- local tab, pane, window = mux.spawn_window(cmd or {})
    -- window:gui_window():toggle_fullscreen()
end)

-- and finally, return the configuration to wezterm
return config

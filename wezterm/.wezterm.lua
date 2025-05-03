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
-- config.native_macos_fullscreen_mode = true
config.window_decorations = 'RESIZE'

config.color_scheme = 'Tokyo Night'
config.color_scheme_dirs = { '~/.config/wezterm/colors' }
config.window_background_opacity = 0.9

-- Font
config.font = wezterm.font 'Iosevka Term SS15'
config.font_size = 14
config.freetype_load_target = 'Light'
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
}

config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

config.inactive_pane_hsb = {
    saturation = 0.75,
    brightness = 0.5,
}

-- and finally, return the configuration to wezterm
return config

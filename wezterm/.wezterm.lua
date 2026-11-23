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
config.window_background_opacity = 0.95
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

-- Font
config.font = wezterm.font 'Iosevka Term SS15'
config.font_size = 14
config.freetype_load_target = 'Light'
config.underline_position = -6
config.underline_thickness = 2

config.adjust_window_size_when_changing_font_size = false
config.use_dead_keys = false

local workspaces = {
    {
        name = 'afm-master',
        cwd = wezterm.home_dir .. '/atlassian/afm/master',
        layout = function(window, pane)
            pane:split({ direction = 'Left', size = 0.8 })
            -- pane:split({ direction = 'Top', size = 0.5, cwd = pane:get_current_working_dir().file_path .. '/jira' })
            local right_pane = pane:split({ direction = 'Top', size = 0.5 })
            right_pane:split({ direction = 'Top', size = 0.5 })
        end,
    },
}

function get_workspace(name)
    for _, item in ipairs(workspaces) do
        if item['name'] == name then
            return item
        end
    end
end

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
    {
        key = 'S',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            local choices = {}
            for _, item in ipairs(workspaces) do
                table.insert(choices, { id = item.cwd, label = item.name })
            end

            window:perform_action(
                act.InputSelector({
                    action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
                        if id and label then
                            local workspace = get_workspace(label)

                            wezterm.log_info('Switching to workspace name = ' .. label .. ', cwd = ' .. id)

                            inner_window:perform_action(
                                act.SwitchToWorkspace({
                                    name = label,
                                    spawn = {
                                        label = 'Workspace: ' .. label,
                                        cwd = id,
                                    },
                                }),
                                inner_pane
                            )

                            if #inner_window:active_tab():panes() == 1 then
                                workspace.layout(inner_window, inner_window:active_pane())
                            end
                        end
                    end),
                    title = 'Choose Workspace',
                    choices = choices,
                }),
                pane
            )
        end),
    },
}

config.inactive_pane_hsb = {
    saturation = 0.75,
    brightness = 0.5,
}

wezterm.on('gui-startup', function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

local function resize_tab_panes(window, tab)
    local panes = tab:panes_with_info()
    if #panes ~= 4 then
        return
    end

    for _, info in ipairs(panes) do
        if info.is_zoomed then
            return
        end
    end

    -- Order: large left pane, then right panes from top to bottom.
    table.sort(panes, function(a, b)
        if a.left == b.left then
            return a.top < b.top
        end
        return a.left < b.left
    end)

    local left, top, middle, bottom = panes[1], panes[2], panes[3], panes[4]
    local size = tab:get_size()

    -- Only handle the layout created by the afm-master workspace function.
    if left.height ~= size.rows
        or top.left <= left.left
        or top.left ~= middle.left
        or middle.left ~= bottom.left
        or size.cols < 10
        or size.rows < 8
    then
        return
    end

    local original = tab:active_pane()

    local function move_divider(pane, delta, positive, negative)
        if delta == 0 then
            return
        end
        pane:activate()
        window:perform_action(
            act.AdjustPaneSize {
                delta > 0 and positive or negative,
                math.abs(delta),
            },
            pane
        )
    end

    -- Restore 80/20 widths, allowing one column for the divider.
    local left_width = math.floor((size.cols - 1) * 0.8)
    move_divider(left.pane, left_width - left.width, 'Right', 'Left')

    -- Target the bottom pane to adjust the split above it.
    local upper_height = math.floor((size.rows - 1) * 0.5)
    move_divider(bottom.pane, upper_height + 1 - bottom.top, 'Down', 'Up')

    -- Divide the upper pair equally, using its updated dimensions.
    local top_height = math.floor((upper_height - 1) * 0.5)
    move_divider(
        top.pane,
        top_height - top.pane:get_dimensions().viewport_rows,
        'Down',
        'Up'
    )

    original:activate()
end

local function resize_workspace_panes(window)
    local mux_window = window:mux_window()
    if mux_window:get_workspace() ~= 'afm-master' then
        return
    end

    local original_tab = mux_window:active_tab()
    if not original_tab then
        return
    end

    -- Pane activation also selects its tab, so restore the selected tab last.
    for _, tab in ipairs(mux_window:tabs()) do
        local original_pane = tab:active_pane()
        local ok, err = pcall(resize_tab_panes, window, tab)
        if not ok then
            if original_pane then
                original_pane:activate()
            end
            wezterm.log_error('Unable to resize tab ' .. tab:tab_id() .. ': ' .. tostring(err))
        end
    end

    original_tab:activate()
end

wezterm.on('window-resized', resize_workspace_panes)

-- Best-effort display detection: the active screen follows input focus.
local last_screen = {}
config.status_update_interval = 500

wezterm.on('update-status', function(window)
    if not window:is_focused() then
        return
    end

    local screen = wezterm.gui.screens().active
    if not screen then
        return
    end

    local id = window:window_id()
    local signature = table.concat({
        screen.name,
        screen.x,
        screen.y,
        screen.width,
        screen.height,
    }, ':')

    local previous = last_screen[id]
    last_screen[id] = signature

    if previous
        and previous ~= signature
        and not window:get_dimensions().is_full_screen
    then
        window:maximize()
    end
end)

-- and finally, return the configuration to wezterm
return config

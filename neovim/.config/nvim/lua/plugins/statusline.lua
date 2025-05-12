---@module 'lazy'
---@type LazySpec
return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'folke/tokyonight.nvim',
            'utils',
        },
        config = function()
            local colors = require('tokyonight.colors').setup()

            ---@param fname string
            local function format_winbar(fname, context)
                local ok, oil = pcall(require, 'oil')
                if ok and vim.bo.filetype == 'oil' then
                    return 'oil: ' .. vim.fn.fnamemodify(oil.get_current_dir() or '', ':~')
                end

                local metadata = require('utils').get_file_metadata(vim.api.nvim_get_current_buf())
                if metadata.package_name ~= nil then
                    return metadata.relative_path .. (vim.bo.modified and ' [+]' or '')
                end

                return fname
            end

            require('lualine').setup({
                options = {
                    theme = 'tokyonight',
                    globalstatus = false,
                    component_separators = { left = '', right = '' },
                    section_separators = { left = '', right = '' },
                },
                sections = {
                    lualine_a = {},
                    lualine_b = {
                        {
                            'lsp_status',
                            icon = '🮲🮳',
                            symbols = {
                                spinner = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻', '🭺', '🭹', '🭸', '🭷' },
                                done = '✔',
                                separator = '⌇',
                            },
                        },
                    },
                    lualine_c = { 'filetype' },
                    lualine_x = { 'fileformat', 'encoding' },
                    lualine_y = { 'location' },
                    lualine_z = {},
                },
                tabline = {
                    lualine_a = {
                        {
                            'tabs',
                            mode = 2,
                            tab_max_length = 64,
                            use_mode_colors = true,
                            max_length = function()
                                return vim.o.columns / 2
                            end,
                        },
                    },
                    lualine_y = { 'branch' },
                    lualine_z = { 'mode' },
                },
                winbar = {
                    lualine_a = {
                        {
                            'filename',
                            path = 1,
                            color = { gui = 'bold', fg = colors.fg, bg = colors.fg_gutter },
                            icon = { '⬤', color = { fg = colors.green } },
                            fmt = format_winbar,
                        },
                    },
                },
                inactive_winbar = {
                    lualine_a = {
                        {
                            'filename',
                            path = 1,
                            color = { fg = colors.fg_gutter, bg = colors.bg },
                            icon = '◯',
                        },
                    },
                },
            })
        end,
    },

    {
        'b0o/incline.nvim',
        dependencies = {
            'folke/tokyonight.nvim',
            'utils',
        },
        event = 'VeryLazy',
        opts = {
            hide = {
                cursorline = 'focused_win',
            },
            window = {
                margin = {
                    horizontal = 0,
                    vertical = 0,
                },
                padding = 0,
                zindex = 100,
            },
            render = function(props)
                if not props.focused then return nil end

                local colors = require('tokyonight.colors').setup()
                local metadata = require('utils').get_file_metadata(props.buf)

                if metadata.package_name == nil then return nil end

                return {
                    { '', guifg = colors.fg_gutter, guibg = 'none', blend = 0 },
                    { '♦ ', guifg = colors.purple, guibg = colors.fg_gutter, blend = 0 },
                    {
                        metadata.package_name .. ' ',
                        gui = 'bold',
                        guifg = colors.fg,
                        guibg = colors.fg_gutter,
                        blend = 0,
                    },
                }
            end,
        },
    },
}

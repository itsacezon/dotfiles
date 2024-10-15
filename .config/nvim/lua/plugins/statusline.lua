local function format_winbar(fname, context)
    local metadata = require('utils').get_file_metadata(vim.api.nvim_buf_get_name(0))
    return metadata.package_name ~= nil and metadata.relative_path or fname
end

return {
    'itchyny/vim-gitbranch',

    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'folke/tokyonight.nvim',
            'utils',
        },
        opts = {
            options = {
                theme = 'tokyonight',
                globalstatus = true,
                section_separators = '',
                component_separators = '',
                disabled_filetypes = {
                    winbar = { 'netrw', 'NvimTree' },
                },
            },
            sections = {
                lualine_c = {
                    {
                        'filename',
                        path = 1,
                    },
                },
            },
            tabline = {
                lualine_a = {
                    {
                        'tabs',
                        mode = 2,
                    },
                },
            },
        },
        config = function(_, opts)
            local colors = require('tokyonight.colors').setup()

            require('lualine').setup(vim.tbl_deep_extend('error', opts, {
                winbar = {
                    lualine_a = {
                        {
                            'filename',
                            path = 1,
                            color = { gui = 'bold', fg = colors.fg, bg = colors.terminal_black },
                            icon = '😍',
                            fmt = format_winbar,
                        }
                    },
                },
                inactive_winbar = {
                    lualine_a = {
                        {
                            'filename',
                            path = 1,
                            color = { fg = colors.fg_gutter, bg = 'dark' },
                        }
                    },
                },
            }))
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
                    ' ' .. metadata.package_name .. ' ',
                    gui = 'bold',
                    guifg = colors.fg,
                    guibg = colors.terminal_black,
                    blend = 0,
                    -- guifg = props.focused and colors.fg or colors.fg_gutter,
                    -- guibg = props.focused and colors.terminal_black or colors.bg,
                }
            end,
        },
    },
}

---@module 'lazy'
---@type LazySpec
return {
    --  Core
    'nvim-lua/plenary.nvim',

    -- Custom utilities
    {
        name = 'utils',
        dir = vim.fn.stdpath('config') .. '/lua',
    },

    --  Colour scheme
    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
        ---@module 'tokyonight'
        ---@type tokyonight.Config
        opts = {
            style = 'night',
            dim_inactive = true,
            transparent = true,
            styles = {
                sidebars = 'transparent',
                floats = 'transparent',
            },
            on_colors = function(colors)
                colors.comment = '#6272a4'
            end,
            on_highlights = function(hl, colors)
                hl.DiagnosticUnnecessary = { fg = colors.comment }
                hl.LineNrAbove = { fg = colors.comment }
                hl.LineNrBelow = { fg = colors.comment }
                hl.StatusLineActive = { bold = true, bg = colors.fg_gutter }
                hl.WinSeparatorActive = { bold = true, fg = colors.fg_gutter }
            end,
        },
        config = function(_, opts)
            require('tokyonight').setup(opts)
            vim.cmd([[ colorscheme tokyonight-night ]])
        end,
    },
    {
        'catgoose/nvim-colorizer.lua',
        event = 'BufReadPost',
        opts = {},
    },

    --  Syntax highlighting
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        ---@module 'nvim-treesitter.configs'
        ---@type TSConfig
        opts = {
            auto_install = true,
            sync_install = false,
            ensure_installed = {},
            highlight = { enable = true },
            ignore_install = { 'jinja', 'jinja_inline' }, -- See custom jinja parsers
            modules = {},
        },
        config = function(_, opts)
            require('nvim-treesitter.configs').setup(opts)
        end,
    },

    -- Git
    {
        'tpope/vim-fugitive',
        keys = {
            { 'gw', '<Cmd>Gwrite<CR>',    mode = 'n', noremap = true },
            { 'gb', '<Cmd>Git blame<CR>', mode = 'n', noremap = true },
        },
    },
    {
        'lewis6991/gitsigns.nvim',
        event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            numhl = false,
            signs = {
                add = { text = '▎' },
                change = { text = '▎' },
                delete = { text = '▁' },
                topdelete = { text = '▔' },
                changedelete = { text = '▎' },
                untracked = { text = '▎' },
            },
            signs_staged = {
                add = { text = '▎' },
                change = { text = '▎' },
                delete = { text = '▁' },
                topdelete = { text = '▔' },
                changedelete = { text = '▎' },
            },
        },
    },

    --  Quality-of-life
    'tpope/vim-obsession',
    {
        'nvim-focus/focus.nvim',
        version = '*',
        event = 'VeryLazy',
        opts = {
            autoresize = { enable = false },
            ui = {
                number = true,
                relativenumber = true,
                hybridnumber = true,
                absolutenumber_unfocussed = true,
                signcolumn = false,
            },
        },
    },
    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        ---@module 'snacks'
        ---@type snacks.Config
        opts = {
            bigfile = { enabled = true },
            dashboard = { enabled = false },
            explorer = { enabled = false },
            image = { enabled = true },
            indent = {
                enabled = true,
                animate = { enabled = false },
                indent = {
                    char = '▏',
                },
                scope = {
                    char = '▏',
                    only_current = true,
                    hl = 'LineNrAbove',
                },
            },
            input = { enabled = true },
            notifier = { enabled = true },
            picker = { enabled = false },
            quickfile = { enabled = true },
            scope = { enabled = false },
            scroll = {
                enabled = true,
                animate = {
                    duration = { step = 10 },
                },
            },
            statuscolumn = {
                enabled = true,
                left = { 'git', 'fold' },
                right = { 'mark', 'sign' },
            },
            words = { enabled = true },
        },
        keys = {
            { '<Leader>n', function() Snacks.notifier.show_history() end,   desc = 'Notification History' },
            { ']]',        function() Snacks.words.jump(vim.v.count1) end,  desc = 'Next Reference',      mode = { 'n', 't' } },
            { '[[',        function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev Reference',      mode = { 'n', 't' } },
        },
    },
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        opts = {},
        keys = {
            {
                '<Leader>?',
                function()
                    require('which-key').show({ global = false })
                end,
                desc = 'Buffer Local Keymaps (which-key)',
            },
        },
    },

    --  File browser
    {
        'stevearc/oil.nvim',
        cmd = 'Oil',
        dependencies = {
            { 'echasnovski/mini.icons', opts = {} },
            'folke/snacks.nvim',
        },
        init = function()
            -- Disable netrw
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
        end,
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            keymaps = {
                ['<Leader>v'] = '<Cmd>q<CR>',
                ['<Space>'] = function()
                    local util = require('oil.util')
                    local entry = require('oil').get_cursor_entry()

                    if entry and entry.type == 'file' then
                        util.get_edit_path(0, entry, function(url)
                            vim.fn.system({ 'qlmanage', '-p', url })
                        end)
                    end
                end,
            },
            delete_to_trash = true,
            view_options = {
                show_hidden = true,
            },
        },
        config = function(_, opts)
            require('oil').setup(opts);

            -- Set autocommands
            vim.api.nvim_create_autocmd('User', {
                pattern = 'OilActionsPost',
                callback = function(event)
                    if event.data.actions.type == 'move' then
                        Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
                    end
                end,
            })

            -- Set keymaps
            -- vim.keymap.set('', '<Leader>v', '<Cmd>vsplit | Oil<CR>')
            -- vim.keymap.set('n', '-', '<Cmd>Oil<CR>')
        end,
        keys = {
            { '<Leader>v', '<Cmd>vsplit | Oil<CR>' },
            { '-',         '<Cmd>Oil<CR>' },
        },
    },

    --  Fuzzy file searching
    {
        'junegunn/fzf',
        build = './install --bin',
    },
    {
        'ibhagwan/fzf-lua',
        branch = 'main',
        dependencies = {
            { 'echasnovski/mini.icons', opts = {} },
            'folke/snacks.nvim',
        },
        init = function()
            vim.env.FZF_DEFAULT_OPTS = ''
        end,
        opts = {
            defaults = {
                file_icons = 'mini',
                git_icons = false,
            },
            files = {
                prompt = '❯ ',
                cwd_header = true,
                cwd_prompt = false,
            },
            grep = {
                prompt = '❯ ',
                hidden = true,
                rg_glob = true,
            },
            winopts = {
                height = 0.6,
                width = 0.8,
                preview = {
                    horizontal = 'right:40%',
                },
                on_close = function()
                    -- Make lualine return to normal mode immediately
                    vim.api.nvim_input('<Ignore>')
                end,
            },
        },
        keys = {
            -- Use `rg`
            { '<Leader><Space>', '<Cmd>FzfLua live_grep_glob<CR>' },
            -- Use `fd`
            { '<C-p>',           '<Cmd>FzfLua files<CR>' },
        },
    },

    -- Formatting
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = true,
    },

    -- Commenting
    {
        'JoosepAlviste/nvim-ts-context-commentstring',
        lazy = true,
        opts = {
            enable_autocmd = false,
        },
    },
    {
        'numToStr/Comment.nvim',
        dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
        config = function()
            require('Comment').setup({
                pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
            })
        end,
    },
}

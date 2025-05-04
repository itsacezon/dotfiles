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
        opts = {
            style = 'night',
            dim_inactive = true,
            transparent = true,
            styles = {
                sidebars = 'transparent',
                floats = 'transparent',
            },
        },
        config = function(_, opts)
            require('tokyonight').setup(opts)
            vim.cmd([[ colorscheme tokyonight-night ]])
        end,
    },
    {
        'catgoose/nvim-colorizer.lua',
        event = 'BufReadPre',
        opts = {},
    },

    --  Syntax highlighting
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        opts = {
            auto_install = true,
            highlight = { enable = true },
        },
        config = function(_, opts)
            require('nvim-treesitter.configs').setup(opts)
        end,
    },

    --  Quality-of-life
    'tpope/vim-obsession',
    {
        'nvim-focus/focus.nvim',
        version = '*',
        event = 'VeryLazy',
        opts = {
            autoresize = { enable = false },
        },
    },
    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            bigfile = { enabled = true },
            dashboard = { enabled = false },
            explorer = { enabled = false },
            image = { enabled = false },
            indent = {
                enabled = true,
                char = '▏',
                animate = { enabled = false },
            },
            input = { enabled = true },
            notifier = { enabled = true },
            picker = { enabled = false },
            quickfile = { enabled = true },
            scope = { enabled = true },
            scroll = {
                enabled = true,
                animate = {
                    duration = { step = 10 },
                },
            },
            statuscolumn = { enabled = true },
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
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
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
        dependencies = {
            { 'echasnovski/mini.icons', opts = {} },
            'folke/snacks.nvim',
        },
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
            vim.keymap.set('', '<Leader>v', '<Cmd>vsplit | Oil<CR>')
            vim.keymap.set('n', '-', '<Cmd>Oil<CR>')
        end,
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
        },
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

    {
        'JoosepAlviste/nvim-ts-context-commentstring',
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
                delete = { text = '' },
                topdelete = { text = '' },
                changedelete = { text = '▎' },
                untracked = { text = '▎' },
            },
            signs_staged = {
                add = { text = '▎' },
                change = { text = '▎' },
                delete = { text = '' },
                topdelete = { text = '' },
                changedelete = { text = '▎' },
            },
        },
    },
}

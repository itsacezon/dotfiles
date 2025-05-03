return {
    --  Core
    'nvim-lua/plenary.nvim',

    -- Custom utilities
    {
        name = 'utils',
        dir = '~/.config/nvim/lua',
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
            { '<Leader>n', function() Snacks.notifier.show_history() end, desc = 'Notification History' },
            { ']]', function() Snacks.words.jump(vim.v.count1) end, desc = 'Next Reference', mode = { 'n', 't' } },
            { '[[', function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev Reference', mode = { 'n', 't' } },
        },
    },

    --  Syntax highlighting
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        opts = {
            ensure_installed = all,
            auto_install = true,
            highlight = { enable = true },
        },
        config = function(_, opts)
            require('nvim-treesitter.configs').setup(opts)
        end,
    },

    -- Git
    {
        'tpope/vim-fugitive',
        keys = {
            { 'gw', '<Cmd>Gwrite<CR>', mode = 'n', noremap = true },
            { 'gb', '<Cmd>Git blame<CR>', mode = 'n', noremap = true },
        },
    },
    {
        'lewis6991/gitsigns.nvim',
        event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
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

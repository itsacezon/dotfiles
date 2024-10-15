return {
    --  Core
    'nvim-lua/plenary.nvim',

    -- Custom utilities
    {
        name = 'utils',
        dir = './utils',
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
        'norcalli/nvim-colorizer.lua',
        config = true,
    },

    --  Quality-of-life
    'tpope/vim-obsession',
    {
        'zegervdv/nrpattern.nvim',
        event = 'VeryLazy',
        config = function()
            require('nrpattern').setup()
        end,
    },
    {
        'nvim-focus/focus.nvim',
        version = '*',
        event = 'VeryLazy',
        opts = {
            autoresize = {
                enable = false,
            },
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
}

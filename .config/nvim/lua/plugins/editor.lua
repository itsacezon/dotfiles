return {
    --  File browser
    'tpope/vim-eunuch',
    'tpope/vim-vinegar',
    {
        'stevearc/oil.nvim',
        dependencies = { { 'echasnovski/mini.icons', opts = {} } },
        opts = {
            float = {
                max_width = 120,
                max_height = 40,
            },
            keymaps = {
                ['<Leader>v'] = '<Cmd>q<CR>',
            },
        },
        config = function(_, opts)
            require('oil').setup(opts);
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
        opts = {
            'fzf-vim',
            grep = {
                rg_glob = true,
            },
            winopts = {
                height = 0.6,
                width = 0.8,
                preview = {
                    hidden = 'nohidden',
                    horizontal = 'right:50%',
                    { default = 'bat' },
                },
                on_close = function()
                    -- Make lualine return to normal mode immediately
                    vim.api.nvim_input('<Ignore>')
                end,
            },
            defaults = {
                git_icons = false,
                file_icons = false,
            },
        },
        keys = {
            { '<Leader><Space>', '<Cmd>lua require("fzf-lua").grep({ search = "" })<CR>' },
            { '<C-p>', '<Cmd>FzfLua files multiline=1<CR>' },
        },
    },
}

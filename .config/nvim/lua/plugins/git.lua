return {
    {
        'tpope/vim-fugitive',
        keys = {
            { 'gw', '<Cmd>Gwrite<CR>', mode = 'n', noremap = true },
            { 'gb', '<Cmd>Git blame<CR>', mode = 'n', noremap = true },
        },
    },

    {
        'lewis6991/gitsigns.nvim',
        opts = {
            numhl = true,
        },
    },
}

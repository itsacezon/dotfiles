return {
    'cohama/lexima.vim',
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        opts = {
            indent = { char = '▏' },
        },
    },

    'tpope/vim-commentary',
    'tpope/vim-endwise',

    {
        'stevearc/conform.nvim',
        events = { 'BufWritePost', 'InsertLeave' },
        opts = {
            formatters_by_ft = {
                json = { 'prettier' },
                typescript = { 'prettier' },
                typescriptreact = { 'prettier' },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        },
    },
}

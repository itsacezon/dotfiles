return {
    --  File browser
    'tpope/vim-eunuch',
    'tpope/vim-vinegar',
    {
        'stevearc/oil.nvim',
        dependencies = {
            { 'echasnovski/mini.icons', opts = {} },
            'folke/snacks.nvim',
        },
        opts = {
            float = {
                max_width = 120,
                max_height = 40,
            },
            keymaps = {
                ['<Leader>v'] = '<Cmd>q<CR>',
                ['<Space>'] = function ()
                    local util = require('oil.util')
                    local entry = require('oil').get_cursor_entry()

                    if entry and entry.type == 'file' then
                        util.get_edit_path(0, entry, function (url)
                            vim.fn.system({ 'qlmanage', '-p', url })
                        end)
                    end
                end,
            },
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

    {
        'stevearc/conform.nvim',
        events = { 'BufWritePost', 'InsertLeave' },
        opts = {
            formatters_by_ft = {
                json = { 'prettier' },
                svg = { 'svgo' },
                typescript = { 'prettier' },
                typescriptreact = { 'prettier' },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
            formatters = {
                svgo = {
                    command = 'svgo',
                    args = { '-i', '-', '-o', '-' },
                    stdin = true,
                    -- cwd = require('conform.util').root_file({ 'package.json' }),
                    -- condition = function(self, ctx)
                    --     local buf_lang = vim.bo[ctx.buf].filetype
                    --     return buf_lang == 'svg'
                    -- end,
                },
            },
        },
    },

    -- Utilities
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
}

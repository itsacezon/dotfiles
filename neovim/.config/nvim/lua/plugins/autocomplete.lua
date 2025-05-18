---@module 'lazy'
---@type LazySpec
return {
    {
        'saghen/blink.cmp',
        dependencies = {
            'rafamadriz/friendly-snippets',
        },
        build = 'cargo build --release',
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            keymap = {
                preset = 'default',
                ['<CR>'] = { 'select_and_accept', 'fallback' },
            },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = 'normal',
            },
            completion = {
                menu = {
                    border = 'rounded',
                    draw = {
                        columns = {
                            { 'label',     'label_description', gap = 1 },
                            { 'kind_icon', 'kind' },
                        },
                    },
                },
                documentation = {
                    window = {
                        border = 'rounded',
                        winhighlight = 'FloatBorder:boolean',
                    },
                },
            },
            cmdline = {
                keymap = {
                    -- recommended, as the default keymap will only show and select the next item
                    ['<Tab>'] = { 'show', 'accept' },
                },
                completion = { menu = { auto_show = true } },
            },
            fuzzy = { implementation = 'prefer_rust_with_warning' },
            sources = {
                per_filetype = {
                    lua = { inherit_defaults = true, 'lazydev' },
                },
                providers = {
                    lazydev = {
                        name = 'LazyDev',
                        module = 'lazydev.integrations.blink',
                    },
                },
            },
        },
        opts_extend = { 'sources.default' },
    },

    -- Testing alternative to blink.cmp
    {
        'brianaung/compl.nvim',
        enabled = false,
        dependencies = {
            'rafamadriz/friendly-snippets',
        },
        init = function()
            -- A set of options for better completion experience. See `:h completeopt`
            vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }

            -- Hides the ins-completion-menu messages. See `:h shm-c`
            vim.opt.shortmess:append('c')

            -- Completions
            vim.keymap.set('i', '<CR>', function()
                if vim.fn.complete_info()['selected'] ~= -1 then return '<C-y>' end
                if vim.fn.pumvisible() ~= 0 then return '<C-e><CR>' end
                return '<CR>'
            end, { expr = true })

            vim.keymap.set('i', '<Down>', function()
                if vim.fn.pumvisible() ~= 0 then return '<C-n>' end
                return '<Down>'
            end, { expr = true })

            vim.keymap.set('i', '<Up>', function()
                if vim.fn.pumvisible() ~= 0 then return '<C-p>' end
                return '<Up>'
            end, { expr = true })
        end,
        opts = {
            snippet = {
                enable = true,
                paths = {
                    vim.fn.stdpath 'data' .. '/lazy/friendly-snippets',
                },
            },
        },
    },
}

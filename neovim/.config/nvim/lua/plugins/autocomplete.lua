---@module 'lazy'
---@type LazySpec
return {
    {
        'saghen/blink.cmp',
        dependencies = {
            'rafamadriz/friendly-snippets',
            'Fildo7525/pretty_hover',
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
                    draw = function(opts)
                        if opts.item and opts.item.documentation then
                            local out = require('pretty_hover.parser').parse(opts.item.documentation.value)
                            opts.item.documentation.value = out:string()
                        end

                        opts.default_implementation()
                    end,
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
}

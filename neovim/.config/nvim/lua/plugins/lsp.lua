local function lsp_split_to(command)
    return function()
        vim.cmd.vsplit()
        if command ~= nil then command() end
    end
end

---@module 'lazy'
---@type LazySpec
return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'lewis6991/hover.nvim',
            'utils',
        },
        config = function()
            vim.diagnostic.config({
                underline = true,
                update_in_insert = true,
                virtual_text = false,
                float = {
                    border = 'rounded',
                    scope = 'cursor',
                },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = '▶',
                        [vim.diagnostic.severity.WARN] = '!',
                        [vim.diagnostic.severity.HINT] = '?',
                        [vim.diagnostic.severity.INFO] = 'i',
                    },
                },
            })

            local hover = require('hover')

            hover.setup({
                init = function()
                    require('hover.providers.lsp')
                    require('hover.providers.diagnostic')
                end,
                preview_opts = {
                    border = 'rounded',
                },
                preview_window = true,
            })

            vim.keymap.set('n', 'K', hover.hover)
        end,
    },

    {
        'pmizio/typescript-tools.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'neovim/nvim-lspconfig',
            'dmmulroy/ts-error-translator.nvim',
            'utils',
            {
                'saghen/blink.cmp',
                lazy = false,
                priority = 1000,
            },
        },
        ft = { 'astro', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
        ---@module 'lspconfig'
        ---@type lspconfig.Config
        ---@diagnostic disable-next-line:missing-fields
        opts = {
            -- Should always be the same as spec `ft`
            filetypes = { 'astro', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
            root_dir = function(_, bufnr)
                return require('utils').root_dir(bufnr)
            end,
            handlers = {
                ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
                    if result.diagnostics == nil then return end

                    require('ts-error-translator').translate_diagnostics(err, result, ctx)

                    -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
                    local filter = require('typescript-tools.api').filter_diagnostics({ 80001 })
                    filter(err, result, ctx, config)
                end,
            },
            on_attach = function(client)
                -- Use conform.nvim
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false

                local api = require('typescript-tools.api')

                vim.keymap.set('n', 'gd', lsp_split_to(api.go_to_source_definition))
                vim.keymap.set('n', 'gr', api.file_references)
            end,
            ---@type Settings
            ---@diagnostic disable-next-line:missing-fields
            settings = {
                ---@diagnostic disable-next-line:assign-type-mismatch
                expose_as_code_action = 'all',
                publish_diagnostic_on = 'change',
                tsserver_max_memory = 18432,
                tsserver_file_preferences = {
                    importModuleSpecifierPreference = 'relative',
                    includeCompletionsForModuleExports = true,
                    includeInlayParameterNameHints = 'all',
                },
                tsserver_plugins = {
                    '@astrojs/ts-plugin',
                    '@typescript-eslint/eslint-plugin',
                    '@vue/typescript-plugin',
                },
                jsx_close_tag = {
                    enable = true,
                    filetypes = { 'typescriptreact' },
                },
            },
        },
    },

    {
        'mfussenegger/nvim-lint',
        dependencies = { 'utils' },
        event = 'VeryLazy',
        ---@class lint.CmdContext
        ---@field cwd string

        ---@class lint.CustomLinter: lint.Linter
        ---@field cmd string | fun(bufnr: integer, ctx: lint.CmdContext):string Command to executre
        ---@field cwd string | fun(bufnr: integer):string? Current working directory
        ---@field name string? Name of the linter (define if not existing)
        ---@field parser lint.Parser? Parse function for a linter

        ---@class lint.Config
        ---@field events string | string[] Event(s) that will trigger the handler
        ---@field linters_by_ft table<string, string[]> Linters to run via `try_lint`. The key is the filetype. The values are a list of linter names
        ---@field linters table<string, lint.CustomLinter|fun():lint.CustomLinter>
        opts = {
            events = { 'BufWritePost', 'InsertLeave' },
            linters_by_ft = {
                typescript = { 'eslint' },
                typescriptreact = { 'eslint' },
            },
            linters = {
                eslint = {
                    cmd = function(_, ctx)
                        local local_binary = vim.fn.fnamemodify(ctx.cwd .. '/node_modules/.bin/eslint', ':p')
                        return vim.uv.fs_stat(local_binary) and local_binary or 'eslint'
                    end,
                    cwd = function(bufnr)
                        return require('utils').root_dir(bufnr)
                    end,
                },
            },
        },
        ---@overload fun(plugin: LazyPlugin, opts: lint.Config)
        config = function(_, opts)
            local lint = require('lint')

            for name, linter in pairs(opts.linters) do
                local existing_linter = lint.linters[name]
                if type(linter) == 'table' and type(existing_linter) == 'table' then
                    lint.linters[name] = vim.tbl_deep_extend('force', existing_linter, linter)
                else
                    lint.linters[name] = linter
                end
            end

            lint.linters_by_ft = opts.linters_by_ft

            ---@param event vim.api.keyset.create_autocmd.callback_args
            local function try_lint(event)
                local names = lint._resolve_linter_by_ft(vim.bo.filetype)

                for _, name in ipairs(names) do
                    local linter = lint.linters[name]

                    if linter then
                        -- Allow `cwd` to take a function
                        if type(linter.cwd) == 'function' then
                            linter.cwd = linter.cwd(event.buf)
                        end

                        local ctx = { cwd = linter.cwd or vim.fn.getcwd() }

                        -- Pass context to `cmd`
                        if type(linter.cmd) == 'function' then
                            linter.cmd = linter.cmd(event.buf, ctx)
                        end
                    end
                end

                lint.try_lint(names)
            end

            vim.api.nvim_create_autocmd(opts.events, {
                callback = try_lint,
            })
        end,
    },

    {
        'stevearc/conform.nvim',
        event = 'VeryLazy',
        ---@type conform.setupOpts
        opts = {
            formatters_by_ft = {
                json = { 'prettier' },
                svg = { 'svgo' },
                typescript = { 'prettier' },
                typescriptreact = { 'prettier' },
            },
            format_after_save = {
                lsp_fallback = 'fallback',
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

    -- For Neovim configs
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        ---@module 'lazydev'
        opts = {
            ---@type lazydev.Library.spec[]
            library = {
                'lazy.nvim',
                -- Load luvit types when the `vim.uv` word is found
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
        ---@overload fun(plugin: LazyPlugin, opts: lazydev.Config)
        config = function(_, opts)
            require('lazydev').setup(opts)

            vim.lsp.config('lua_ls', {
                settings = {
                    Lua = {
                        format = {
                            enable = true,
                            defaultConfig = {
                                indent_style = 'space',
                                indent_size = '4',
                                quote_style = 'single',
                                trailing_table_separator = 'smart',
                            },
                        },
                    },
                },
            })

            vim.lsp.enable({ 'lua_ls' })

            vim.keymap.set('n', 'gd', lsp_split_to(vim.lsp.buf.definition))
        end,
    },
}

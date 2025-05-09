local function lsp_split_to(command)
    return function()
        vim.cmd.vsplit()
        if command ~= nil then command() end
    end
end

local function format_ts_error(diagnostic)
    local formatter = require('format-ts-errors')[diagnostic.code]
    local message = formatter and formatter(diagnostic.message) or diagnostic.message

    return string.format(
        "%s (%s) [%s]",
        message,
        diagnostic.source,
        diagnostic.code or diagnostic.user_data.lsp.code
    )
end

return {
    {
        'neovim/nvim-lspconfig',
        dependencies = { 'utils' },
        -- config = function(_, opts)
        --     local util = require('lspconfig.util')
        --
        --     require('lspconfig/quick_lint_js').setup({
        --         root_dir = util.root_pattern('yarn.lock', 'package.json', '.git')
        --     })
        -- end,
    },

    {
        'davidosomething/format-ts-errors.nvim',
        opts = {
            add_markdown = true,
            start_indent_level = 1,
        },
    },

    {
        'Fildo7525/pretty_hover',
        event = 'LspAttach',
        opts = {},
    },

    {
        'folke/trouble.nvim',
        cmd = 'Trouble',
        opts = {
            modes = {
                diagnostics_buffer = {
                    mode = 'diagnostics',
                    filter = {
                        buf = 0,
                        -- Turn on if you want cursor-level filtering
                        -- function(diagnostic)
                        --     local cursor = vim.api.nvim_win_get_cursor(0)
                        --     local within_line = cursor[1] - 1 == diagnostic.item.lnum
                        --     local within_col = cursor[2] < diagnostic.item.end_col
                        --     return within_line and within_col
                        -- end,
                    },
                },
            },
        },
    },

    {
        'pmizio/typescript-tools.nvim',
        event = 'BufReadPost',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'neovim/nvim-lspconfig',
            'artemave/workspace-diagnostics.nvim',
            'davidosomething/format-ts-errors.nvim',
            'Fildo7525/pretty_hover',
            'folke/snacks.nvim',
            'folke/trouble.nvim',
            'utils',
            {
                'saghen/blink.cmp',
                lazy = false,
                priority = 1000,
            },
        },
        opts = {
            -- on_attach = function(client, bufnr)
            --     require('workspace-diagnostics').populate_workspace_diagnostics(client, bufnr)
            -- end,
            handlers = {
                ['textDocument/publishDiagnostics'] = function(_, result, ctx, config)
                    if result.diagnostics == nil then return end

                    -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
                    local filter = require('typescript-tools.api').filter_diagnostics({ 80001 })
                    filter(_, result, ctx, config)
                end
            },
            root_dir = function(_, bufnr)
                return require('utils').root_dir(bufnr)
            end,
            filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
            settings = {
                expose_as_code_action = 'all',
                publish_diagnostic_on = 'change',
                tsserver_max_memory = 18432,
                tsserver_file_preferences = {
                    importModuleSpecifierPreference = 'relative',
                    includeCompletionsForModuleExports = true,
                    includeInlayParameterNameHints = 'all',
                },
                tsserver_plugins = {
                    '@typescript-eslint/eslint-plugin',
                    '@vue/typescript-plugin',
                },
                jsx_close_tag = {
                    enable = true,
                    filetypes = { 'typescriptreact' },
                }
            },
        },
        config = function(_, opts)
            require('typescript-tools').setup(opts)

            local api = require('typescript-tools.api')

            vim.diagnostic.config({
                underline = true,
                update_in_insert = true,
                virtual_text = false,
                float = {
                    border = 'rounded',
                    scope = 'cursor',
                    format = format_ts_error,
                },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = '●',
                        [vim.diagnostic.severity.WARN] = '!',
                        [vim.diagnostic.severity.HINT] = '?',
                        [vim.diagnostic.severity.INFO] = 'i',
                    },
                },
            })

            vim.keymap.set('n', 'gd', lsp_split_to(api.go_to_source_definition))
            vim.keymap.set('n', 'gr', api.file_references)
            vim.keymap.set('n', 'K', require('pretty_hover').hover)
            -- vim.keymap.set('n', 'K', vim.lsp.buf.hover)
            vim.keymap.set('n', 'L', '<Cmd>Trouble diagnostics_buffer toggle<CR>')
        end,
    },

    {
        'mfussenegger/nvim-lint',
        dependencies = { 'utils' },
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
        config = function(_, opts)
            local lint = require('lint')

            for name, linter in pairs(opts.linters) do
                if type(linter) == 'table' and type(lint.linters[name]) == 'table' then
                    lint.linters[name] = vim.tbl_deep_extend('force', lint.linters[name], linter)
                else
                    lint.linters[name] = linter
                end
            end

            lint.linters_by_ft = opts.linters_by_ft

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


    -- For Neovim configs
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                'lazy.nvim',
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
}

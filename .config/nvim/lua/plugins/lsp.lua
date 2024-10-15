return {
    'neovim/nvim-lspconfig',
    'davidosomething/format-ts-errors.nvim',

    {
        'pmizio/typescript-tools.nvim',
        dependencies = {
            'neovim/nvim-lspconfig',
            'davidosomething/format-ts-errors.nvim',
            'utils',
        },
        opts = {
            handlers = {
                ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
                    border = 'rounded',
                }),
                ['textDocument/publishDiagnostics'] = function(_, result, ctx, config)
                    if result.diagnostics == nil then
                        return
                    end

                    -- ignore some tsserver diagnostics
                    local idx = 1
                    while idx <= #result.diagnostics do
                        local entry = result.diagnostics[idx]

                        local formatter = require('format-ts-errors')[entry.code]
                        entry.message = formatter and formatter(entry.message) or entry.message

                        -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
                        if entry.code == 80001 then
                            -- { message = "File is a CommonJS module; it may be converted to an ES module.", }
                            table.remove(result.diagnostics, idx)
                        else
                            idx = idx + 1
                        end
                    end

                    vim.lsp.diagnostic.on_publish_diagnostics(
                        _,
                        result,
                        ctx,
                        config
                    )
                end
            },
            root_dir = function(_, bufnr)
                return require('utils').yarn_lock_root_dir(bufnr)
            end,
            settings = {
                expose_as_code_action = 'all',
                publish_diagnostic_on = 'change',
                tsserver_max_memory = 18432,
                tsserver_file_preferences = {
                    includeCompletionsForModuleExports = true,
                    includeInlayParameterNameHints = 'all',
                },
                jsx_close_tag = {
                    enable = true,
                    filetypes = { 'typescriptreact' },
                }
            },
        },
    },

    -- {
    --     'Fildo7525/pretty_hover',
    --     event = 'LspAttach',
    --     opts = {},
    -- },
}

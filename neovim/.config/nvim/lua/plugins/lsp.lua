local function close_all_floats()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative ~= '' then
            vim.api.nvim_win_close(win, true)
        end
    end
end

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

local function open_diagnostic_float()
    close_all_floats()

    -- Limit diagnostic to cursor
    local pos = vim.api.nvim_win_get_cursor(0)
    local diagnostics = vim.diagnostic.get(0, { lnum = pos[1] - 1 })

    diagnostics = vim.tbl_filter(function(diagnostic)
        return pos[2] < diagnostic.end_col
    end, diagnostics)

    if vim.tbl_isempty(diagnostics) then return end

    local lines = {}
    for i, diagnostic in ipairs(diagnostics) do
        table.insert(lines, format_ts_error(diagnostic))
    end

    local float_bufnr, winnr = vim.lsp.util.open_floating_preview(lines, 'markdown', {
        border = 'rounded',
        focus_id = 'cursor',
    })
    vim.bo[float_bufnr].path = vim.bo[0].path
end

local function open_pretty_hover()
    require('pretty_hover').hover()
end

return {
    'neovim/nvim-lspconfig',

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
            on_attach = function(client, bufnr)
                require('workspace-diagnostics').populate_workspace_diagnostics(client, bufnr)
            end,
            handlers = {
                ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
                    border = 'rounded',
                }),
                ['textDocument/publishDiagnostics'] = function(_, result, ctx, config)
                    if result.diagnostics == nil then return end

                    -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
                    local filter = require('typescript-tools.api').filter_diagnostics({ 80001 })
                    filter(_, result, ctx, config)
                end
            },
            root_dir = function(_, bufnr)
                return require('utils').root_dir_from_pattern(bufnr, 'package.json')
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
                        [vim.diagnostic.severity.ERROR] = '✘',
                        [vim.diagnostic.severity.WARN] = '!',
                        [vim.diagnostic.severity.HINT] = '?',
                        [vim.diagnostic.severity.INFO] = 'i',
                    },
                },
            })

            vim.keymap.set('n', 'gd', lsp_split_to(api.go_to_source_definition))
            vim.keymap.set('n', 'gr', api.file_references)
            vim.keymap.set('n', 'K', open_pretty_hover)
            vim.keymap.set('n', 'L', '<Cmd>Trouble diagnostics_buffer toggle<CR>')
        end,
    },
}

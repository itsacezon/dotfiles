return {
    {
        'mfussenegger/nvim-lint',
        opts = {
            events = { 'BufWritePost', 'InsertLeave' },
            linters_by_ft = {},
            linters = {},
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
}

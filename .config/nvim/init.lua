local vim = vim -- Prevents undefined vim when overridden somewhere else

-- Smart search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Tabs / spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.showtabline = 2 -- Always show tabline
vim.opt.expandtab = true

-- Line break
-- vim.opt.textwidth = 79
vim.opt.colorcolumn = { 80, 120 }
vim.opt.breakindent = true
vim.opt.linebreak = true

-- List characters
vim.opt.listchars = {
    space = '⋅',
    tab = '→ ',
    eol = '↲',
    nbsp = '␣',
    trail = '•',
    extends = '⟩',
    precedes = '⟨',
}
vim.opt.list = true
vim.opt.showbreak = '↪'

-- Built-in completion & tag search
vim.opt.completeopt = 'menu'
-- vim.opt.completeopt:append({ 'menuone', 'noinsert' })
-- vim.opt.complete:remove({ 't' })
-- vim.opt.completefunc = "v:lua.require'snipcomp'"

-- Show line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Mouse / clipboard
vim.opt.clipboard = 'unnamed'
vim.opt.mouse = 'a'

-- UI settings
-- vim.opt.autochdir = true
vim.opt.hlsearch = false
vim.opt.laststatus = 3
vim.opt.scrolloff = 10
vim.opt.showmode = false
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.virtualedit = 'block'
vim.opt.visualbell = true
vim.opt.pumblend = 20
vim.opt.winblend = 20

-- Globals
vim.g.mapleader = ','

-- Netrw - Disable; prefer `nvim-tree.lua`
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- vim.g.netrw_altv = 1
-- vim.g.netrw_banner = 0
-- vim.g.netrw_browse_split = 0
-- vim.g.netrw_bufsettings = 'noma nomod nu nowrap ro nobl'
-- vim.g.netrw_fastbrowse = 0 -- Sync current directory and browsing directory
-- vim.g.netrw_liststyle = 3 -- Tree style
-- vim.g.netrw_localcopydircmd = 'cp -r' -- Better copy command
-- vim.g.netrw_special_syntax = 1
-- vim.g.netrw_sort_options = 'i'

-- Python
vim.g.python3_host_prog = vim.fn.exepath('python')

-- Load plugins
require('config.lazy')

-- Autocommands
local au = require('autocmd')

-- Window autocommands
local window = au({ 'user_window',
    pattern = '*',
    Resize = { 'BufWinEnter', 'VimResized' },
})
function window.Resize()
    -- Equally resize splits
    vim.cmd([[ wincmd = ]])
end

-- Jump to last position when opening a file
local open = au('user_open')
function open.BufReadPost()
    local last_cursor_pos, last_line = vim.fn.line([['"]]), vim.fn.line('$')
    if last_cursor_pos > 1 and last_cursor_pos <= last_line then
        vim.fn.cursor(last_cursor_pos, 1)
    end
end

-- Formatting autocommands
local format = au({ 'user_format', pattern = '*' })

format.create_autocmd('BufWritePre', {
    desc = 'Remove trailing whitespace',
    command = [[ :%s/\s\+$//e ]],
})

format.create_autocmd('BufWritePre', {
    desc = 'Remove newlines at the end of file',
    command = [[ :%s/\($\n\s*\)\+\%$//e ]],
})

-- Highlight selection on yank
local yank = au('user_yank')
function yank.TextYankPost()
    vim.highlight.on_yank({ timeout = 200 })
end

-- Automatically toggle between absolute/relative line numbering
local number = au({ 'user_number',
    Relative = { 'BufEnter', 'FocusGained', 'InsertLeave', 'TermLeave', 'WinEnter' },
    Absolute = { 'BufLeave', 'FocusLost', 'InsertEnter', 'TermEnter', 'WinLeave' },
})

function number.Relative()
    if vim.opt_local.number:get() and vim.fn.mode() ~= 'i' then
        vim.opt_local.relativenumber = true
    end
end

function number.Absolute()
    if vim.opt_local.number:get() then
        vim.opt_local.relativenumber = false
    end
end

-- Automatically create missing directories
local dir = au('user_directories')
function dir.BufWritePre(event)
    if event.match:match('^%w%w+://') then
        return
    end

    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
end

-- Netrw autocommands
-- local netrw = au({ 'user_netrw', pattern = 'netrw' })
-- function netrw.FileType(event)
--     -- Always wipe netrw buffer when hidden
--     vim.api.nvim_command('setlocal buftype=nofile')
--     vim.api.nvim_command('setlocal bufhidden=wipe')

--     -- Close netrw
--     vim.keymap.set('n', '<Leader>v', '<Cmd>bd<CR>', { buffer = event.buf })

--     -- Close the preview window
--     vim.keymap.set('n', 'P', '<C-w>z', { buffer = event.buf })
-- end

-- Diagnostics
vim.diagnostic.config({
    float = {
        border = 'rounded',
        format = function(diagnostic)
            return string.format(
                "%s (%s) [%s]",
                diagnostic.message,
                diagnostic.source,
                diagnostic.code or diagnostic.user_data.lsp.code
            )
        end,
    },
    update_in_insert = true,
    virtual_text = false,
})

local signs = { Error = '❌', Warn = '❕', Hint = '💡', Info = '📍' }
for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Custom keymaps
local function on_list(options)
    vim.fn.setqflist({}, ' ', options)
    vim.api.nvim_command('cfirst')
end

local function lsp_split_to(command)
    return function()
        vim.cmd.vsplit()
        if command ~= nil then command({ on_list = on_list }) end
    end
end

local function open_float()
    -- If we find a floating window, close it.
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative ~= '' then
            vim.api.nvim_win_close(win, true)
            found_float = true
        end
    end

    vim.diagnostic.open_float(nil, { focus = false, scope = 'cursor' })
end

-- Custom key mappings
local map, opts = vim.keymap.set, { noremap = true, silent = true }

-- LSP
map('n', 'gd', lsp_split_to(vim.lsp.buf.definition), opts)
map('n', 'gy', lsp_split_to(vim.lsp.buf.type_definition), opts)
map('n', 'gi', lsp_split_to(vim.lsp.buf.implementation), opts)
map('n', 'gr', vim.lsp.buf.references, opts)
map('n', 'K', vim.lsp.buf.hover, opts)
map('n', 'L', open_float, opts)

-- Move through wrapped lines
map('i', '<Down>', '<C-o>gj', opts)
map('i', '<Up>', '<C-o>gk', opts)
map('n', '<Down>', 'gj', opts)
map('n', '<Up>', 'gk', opts)
map('n', '<Down>', 'v:count == 0 ? "gj" : "\\<Esc>".v:count."j"', { expr = true, noremap = true })
map('n', '<Up>', 'v:count == 0 ? "gk" : "\\<Esc>".v:count."k"', { expr = true, noremap = true })

-- Get filepaths
map('n', '<Leader>cf', '<Cmd>let @*=expand("%")<CR>', { noremap = true }) -- Relative path
map('n', '<Leader>cF', '<Cmd>let @*=expand("%:p")<CR>', { noremap = true }) -- Absolute path
map('n', '<Leader>ct', '<Cmd>let @*=expand("%:t")<CR>', { noremap = true }) -- Just the filename
map('n', '<Leader>ch', '<Cmd>let @*=expand("%:h")<CR>', { noremap = true }) -- Relative directory
map('n', '<Leader>cH', '<Cmd>let @*=expand("%:p:h")<CR>', { noremap = true }) -- Absolute directory

-- Splits / tabs
map('', '<Leader>,', '<C-w>=')
map('', '<Tab>', '<C-w>w')
map('', '\\', '<Cmd>vnew<CR>')
map('', '<Leader>\\', '<Cmd>vsplit<CR>')
map('', '-', '<Cmd>new<CR>')
map('', '<Leader>-', '<Cmd>split<CR>')
map('n', '<C-t>', '<Cmd>tabnew<CR>', { noremap = true })

-- Better redo
map('n', 'q', '<C-r>', { noremap = true })

-- Find and replace
map('', '<Leader>h', ':%s/')

-- Add semicolon at end during insert
map('i', '<Leader>;', '<C-o>A;', { noremap = true })

-- File explorer
-- map('', '<Leader>v', '<Cmd>Vexplore!<CR>')
map('', '<Leader>v', '<Cmd>vsplit | Oil<CR>')

-- Terminal
map('t', '<Esc>', '<C-\\><C-n>')

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

-- Show line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Mouse / clipboard
vim.opt.clipboard = 'unnamed'
vim.opt.mouse = 'a'

-- UI settings
vim.opt.laststatus = 3
vim.opt.scrolloff = 10
vim.opt.showmode = false
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.virtualedit = 'block'
vim.opt.visualbell = true
vim.opt.pumblend = 20
vim.opt.winblend = 20
vim.opt.winborder = 'rounded'

-- Globals
vim.g.mapleader = ','

-- Python
vim.g.python3_host_prog = vim.fn.exepath('python')

-- Sass
vim.g.sass_recommended_style = 0

-- Set default keymap options
local keymap_set = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false   -- Always true
    opts.noremap = opts.noremap ~= false -- Always true
    return keymap_set(mode, lhs, rhs, opts)
end

-- Load plugins
require('config.lazy')

-- Autocommands
local au = require('autocmd')

-- Window autocommands
local window = au({
    'user_window',
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

-- Automatically create missing directories
local dir = au('user_directories')
function dir.BufWritePre(event)
    if event.match:match('^%w%w+://') then
        return
    end

    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
end

-- Clear search highlight
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>')

-- Move through wrapped lines
vim.keymap.set('i', '<Down>', '<C-o>gj')
vim.keymap.set('i', '<Up>', '<C-o>gk')
vim.keymap.set('n', '<Down>', 'gj')
vim.keymap.set('n', '<Up>', 'gk')
vim.keymap.set('n', '<Down>', 'v:count == 0 ? "gj" : "\\<Esc>".v:count."j"', { expr = true })
vim.keymap.set('n', '<Up>', 'v:count == 0 ? "gk" : "\\<Esc>".v:count."k"', { expr = true })

-- Get filepaths
vim.keymap.set('n', '<Leader>cf', '<Cmd>let @*=expand("%")<CR>')     -- Relative path
vim.keymap.set('n', '<Leader>cF', '<Cmd>let @*=expand("%:p")<CR>')   -- Absolute path
vim.keymap.set('n', '<Leader>ct', '<Cmd>let @*=expand("%:t")<CR>')   -- Just the filename
vim.keymap.set('n', '<Leader>ch', '<Cmd>let @*=expand("%:h")<CR>')   -- Relative directory
vim.keymap.set('n', '<Leader>cH', '<Cmd>let @*=expand("%:p:h")<CR>') -- Absolute directory

-- Splits / tabs
vim.keymap.set('', '<Leader>,', '<C-w>=')
vim.keymap.set('n', '<Tab>', '<C-w>w')
vim.keymap.set('n', '<Shift><Tab>', '<C-w>p')
vim.keymap.set('n', '\\', '<Cmd>vnew<CR>')
vim.keymap.set('n', '<Leader>\\', '<Cmd>vsplit<CR>')
vim.keymap.set('n', '<C-t>', '<Cmd>tabnew<CR>')

-- Better redo
vim.keymap.set('n', 'q', '<C-r>')

-- Find and replace
vim.keymap.set('', '<Leader>h', ':%s/')

-- Add semicolon at end during insert
vim.keymap.set('i', '<Leader>;', '<C-o>A;')

-- Terminal
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

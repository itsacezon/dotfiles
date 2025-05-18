-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
            { out,                            'WarningMsg' },
            { '\nPress any key to exit...' },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Globals
vim.g.mapleader = ','
vim.g.maplocalleader = ';'
vim.g.python3_host_prog = vim.fn.exepath('python')
vim.g.sass_recommended_style = 0

-- Settings
vim.opt.breakindent = true
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.fillchars = {
    horiz = '━',
    horizup = '┻',
    horizdown = '┳',
    -- vert = '┃',
    vert = '█',
    vertleft = '┫',
    vertright = '┣',
    verthoriz = '╋',
}
vim.opt.laststatus = 3
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = {
    space = '⋅',
    tab = '→ ',
    eol = '↲',
    nbsp = '␣',
    trail = '•',
    extends = '⟩',
    precedes = '⟨',
}
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.pumblend = 10
vim.opt.relativenumber = true
vim.opt.scrolloff = 10
vim.opt.shiftwidth = 4
vim.opt.showbreak = '↪'
vim.opt.showmode = false
vim.opt.showtabline = 2 -- Always show tabline
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.smartcase = true
vim.opt.softtabstop = 4
vim.opt.splitright = true
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.virtualedit = 'block'
vim.opt.visualbell = true
vim.opt.winblend = 10
vim.opt.winborder = 'rounded'

vim.schedule(function()
    -- load later to avoid bad performance for "xsel" and "pbcopy"
    vim.opt.clipboard = 'unnamed'
end)

-- Override vim.keymap.set with default options
local keymap_set = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false   -- Always true
    opts.noremap = opts.noremap ~= false -- Always true
    return keymap_set(mode, lhs, rhs, opts)
end

-- Load plugins
require('lazy').setup({
    checker = { enabled = true },
    install = { colorscheme = { 'tokyonight' } },
    spec = {
        -- Use the `plugins` folder
        { import = 'plugins' },
    },
    ui = { border = 'rounded' },
})

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
vim.keymap.set('n', '<S-Tab>', '<C-w>p')
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

-- Autocommands
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'VimResized' }, {
    pattern = '*',
    command = [[ wincmd = ]],
    desc = 'Equally resize splits',
});

vim.api.nvim_create_autocmd('WinEnter', {
    callback = function()
        local left_win = vim.fn.win_getid(vim.fn.winnr('h'))
        local current_win = vim.fn.win_getid(vim.fn.winnr())

        vim.wo[left_win].winhighlight =
        'WinSeparator:WinSeparatorActive,StatusLine:StatusLineActive,StatusLineNC:StatusLineActive'
        vim.wo[current_win].winhighlight =
        'WinSeparator:WinSeparatorActive,StatusLine:StatusLineActive,StatusLineNC:StatusLineActive'
    end,
})

vim.api.nvim_create_autocmd('WinLeave', {
    callback = function()
        local left_win = vim.fn.win_getid(vim.fn.winnr('h'))
        local right_win = vim.fn.win_getid(vim.fn.winnr('l'))
        local current_win = vim.fn.win_getid(vim.fn.winnr())

        vim.wo[left_win].winhighlight = 'WinSeparator:WinSeparator,StatusLine:StatusLine,StatusLineNC:StatusLineNC'
        vim.wo[right_win].winhighlight = 'WinSeparator:WinSeparator,StatusLine:StatusLine,StatusLineNC:StatusLineNC'
        vim.wo[current_win].winhighlight = 'WinSeparator:WinSeparator,StatusLine:StatusLine,StatusLineNC:StatusLineNC'
    end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function()
        local last_cursor_pos, last_line = vim.fn.line([['"]]), vim.fn.line('$')
        if last_cursor_pos > 1 and last_cursor_pos <= last_line then
            vim.fn.cursor(last_cursor_pos, 1)
        end
    end,
    desc = 'Jump to last position when opening a file',
});

vim.api.nvim_create_autocmd('BufWritePre', {
    command = [[ :%s/\s\+$//e ]],
    desc = 'Remove trailing whitespace',
});

vim.api.nvim_create_autocmd('BufWritePre', {
    command = [[ :%s/\($\n\s*\)\+\%$//e ]],
    desc = 'Remove newlines at the end of file',
});

vim.api.nvim_create_autocmd('BufWritePre', {
    callback = function(event)
        if event.match:match('^%w%w+://') then
            return
        end

        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
    end,
    desc = 'Automatically create missing directories',
});

vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.hl.on_yank({ timeout = 200 })
    end,
    desc = 'Highlight selection on yank',
});

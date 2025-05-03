local vim = vim -- Prevents undefined vim when overridden somewhere else

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    spec = {
        -- Use the `plugins` folder
        { import  = 'plugins' }
    },
    ui = { border = 'rounded' },
    install = { colorscheme = { 'tokyonight' } },
    checker = { enabled = true },
})

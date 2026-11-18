if vim.fn.has('nvim-0.12') ~= 1 then
    error('此配置需要 Neovim 0.12 或更新版本')
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.loader.enable()

require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.projects').setup()
require('config.lazy')

local settings = require('config.settings')
local opt = vim.opt
local toolbin = vim.fn.stdpath('data') .. '/tools/bin'
if vim.uv.fs_stat(toolbin) and not (vim.env.PATH or ''):find(toolbin, 1, true) then
    vim.env.PATH = toolbin .. ':' .. (vim.env.PATH or '')
end

for _, provider in ipairs({ 'node', 'python', 'python3', 'ruby', 'perl' }) do
    vim.g['loaded_' .. provider .. '_provider'] = 0
end

opt.termguicolors = true
opt.background = 'dark'
opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.signcolumn = 'yes'
opt.laststatus = 3
opt.showmode = false
opt.cmdheight = 1
opt.winborder = 'rounded'
opt.pumheight = 10
opt.mouse = settings.mouse and 'a' or ''
opt.clipboard = require('config.clipboard').setup() and 'unnamedplus' or ''

opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.autoindent = true
opt.smartcase = true
opt.ignorecase = true
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = 'split'
opt.wrap = false
opt.hidden = true
opt.scrolloff = 5
opt.sidescrolloff = 5
opt.splitright = true
opt.splitbelow = true
opt.timeoutlen = 400
opt.ttimeoutlen = 50
opt.updatetime = 250
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.wildmode = 'longest:full,full'
opt.wildoptions = 'pum'
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.fillchars = { eob = ' ' }
opt.synmaxcol = 300
opt.foldmethod = 'manual'
opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'folds', 'help', 'skiprtp' }
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true
local undo = vim.fn.stdpath('state') .. '/undo'
vim.fn.mkdir(undo, 'p')
opt.undodir = undo
-- shell 保留 Neovim 根据环境检测的默认值, 不强制指定 Bash。

vim.diagnostic.config({
    severity_sort = true,
    update_in_insert = false,
    underline = true,
    virtual_text = { spacing = 2, prefix = '●' },
    float = { border = 'rounded', source = 'if_many' },
    signs = { text = { [1] = '', [2] = '', [3] = '', [4] = '󰌵' } },
})

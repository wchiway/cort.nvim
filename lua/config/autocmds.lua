local group = vim.api.nvim_create_augroup('PersonalConfig', { clear = true })
local bigfile = require('config.bigfile')

-- 使用 Neovim 自带 parser / ftplugin, 第三方 Treesitter 留到阶段三。

vim.api.nvim_create_autocmd('BufReadPre', {
    group = group,
    callback = function(args)
        local stat = vim.uv.fs_stat(args.file)
        bigfile.apply(args.buf, stat ~= nil and stat.size > require('config.settings').large_file.bytes)
    end,
})
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWinEnter', 'TextChanged', 'TextChangedI', 'TextChangedP' }, {
    group = group, callback = function(args) bigfile.update(args.buf) end,
})
vim.api.nvim_create_autocmd('BufWipeout', {
    group = group, callback = function(args) bigfile.clear(args.buf) end,
})
vim.api.nvim_create_autocmd('TextYankPost', {
    group = group,
    callback = function(args)
        if not bigfile.is_large(args.buf) then vim.hl.on_yank({ timeout = 150 }) end
    end,
})
vim.api.nvim_create_autocmd('BufReadPost', {
    group = group,
    callback = function(args)
        if vim.bo[args.buf].filetype == 'gitcommit' or bigfile.is_large(args.buf) then return end
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})
vim.api.nvim_create_autocmd('BufWritePre', {
    group = group,
    callback = function(args)
        local name = vim.api.nvim_buf_get_name(args.buf)
        if vim.bo[args.buf].buftype ~= '' or vim.bo[args.buf].readonly or name == '' or name:match('^%w+://') then return end
        local dir = vim.fs.dirname(name)
        if dir and not vim.uv.fs_stat(dir) then vim.fn.mkdir(dir, 'p') end
    end,
})
vim.api.nvim_create_autocmd('VimResized', { group = group, command = 'wincmd =' })
vim.api.nvim_create_autocmd('TermOpen', {
    group = group,
    callback = function()
        vim.wo.number = false
        vim.wo.relativenumber = false
    end,
})

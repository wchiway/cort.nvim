local path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(path .. '/lua/lazy/init.lua') then
    if vim.uv.fs_stat(path) then
        error('lazy.nvim 缓存目录不完整; 请先备份/移走该目录再重试: ' .. path)
    end
    if vim.fn.executable('git') ~= 1 then error('缺少 Git, 无法安装 lazy.nvim') end
    local result = vim.system({
        'git', 'clone', '--filter=blob:none', '--branch=stable',
        'https://github.com/folke/lazy.nvim.git', path,
    }, { text = true, timeout = 120000 }):wait()
    if result.code ~= 0 then
        error('lazy.nvim 下载失败: ' .. (result.stderr or result.stdout or '未知错误'))
    end
end
vim.opt.rtp:prepend(path)

require('lazy').setup({
    spec = { { import = 'plugins' } },
    defaults = { lazy = true },
    local_spec = false,
    rocks = { enabled = false },
    install = { missing = false, colorscheme = { 'habamax' } },
    checker = { enabled = false },
    change_detection = { notify = false },
    ui = { border = 'rounded' },
    git = { timeout = 120 },
})
-- Git 继承已有代理环境变量; 不在 Lua 中设置代理地址。

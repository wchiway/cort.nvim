local map = vim.keymap.set

map('n', '<Space>', '<Nop>', { silent = true })
map({ 'n', 'i', 'x' }, '<C-s>', '<Cmd>update<CR>', { desc = '保存文件' })
map('n', '<leader>w', '<Cmd>write<CR>', { desc = '保存文件' })
map('n', '<leader>qq', '<Cmd>confirm quit<CR>', { desc = '确认后退出窗口' })
map('n', '<Esc>', '<Cmd>nohlsearch<CR>', { desc = '清除搜索高亮' })

for key, direction in pairs({ h = 'h', j = 'j', k = 'k', l = 'l' }) do
    map('n', '<C-' .. key .. '>', '<C-w>' .. direction, { desc = '切换窗口' })
end
map('n', '<leader>sv', '<Cmd>vsplit<CR>', { desc = '垂直分屏' })
map('n', '<leader>sh', '<Cmd>split<CR>', { desc = '水平分屏' })
map('n', '<leader>se', '<C-w>=', { desc = '等分窗口' })
map('n', '<leader>sc', '<Cmd>close<CR>', { desc = '关闭窗口' })
map('n', '<leader>bn', '<Cmd>bnext<CR>', { desc = '下一个 Buffer' })
map('n', '<leader>bp', '<Cmd>bprevious<CR>', { desc = '上一个 Buffer' })
map('x', '<', '<gv', { desc = '减少缩进并保留选区' })
map('x', '>', '>gv', { desc = '增加缩进并保留选区' })
map('x', '<C-c>', '"+y', { desc = '复制选区到系统剪贴板' })
map('s', '<C-c>', '<C-o>"+y', { desc = '复制选区到系统剪贴板' })
map('n', '<leader>p', '"+p', { desc = '粘贴系统剪贴板' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = '离开终端输入模式' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = '当前行诊断' })
map('n', '<leader>cl', vim.diagnostic.setloclist, { desc = '诊断位置列表' })
-- 插件功能键由对应 lazy spec / LspAttach 注册, 此处只保留基础操作。

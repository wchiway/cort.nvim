return {
    {
        'lewis6991/gitsigns.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        keys = {
            { '<leader>gg', function()
                if vim.fn.executable('lazygit') == 1 then
                    vim.cmd('tabnew')
                    vim.cmd.terminal('lazygit')
                    vim.cmd.startinsert()
                else require('telescope.builtin').git_status() end
            end, desc = 'Git 工作流' },
        },
        opts = {
            max_file_length = 20000,
            preview_config = { border = 'rounded' },
            on_attach = function(buf)
                if vim.b[buf].bigfile or require('config.bigfile').is_large(buf) then return false end
                local gs = require('gitsigns')
                local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc }) end
                map('n', ']c', function() if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gs.nav_hunk('next') end end, '下一处 Git 改动')
                map('n', '[c', function() if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gs.nav_hunk('prev') end end, '上一处 Git 改动')
                map('n', '<leader>hs', gs.stage_hunk, '暂存 Hunk')
                map('n', '<leader>hr', gs.reset_hunk, '撤销 Hunk')
                map('x', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, '暂存选区 Hunk')
                map('x', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, '撤销选区 Hunk')
                map('n', '<leader>hp', gs.preview_hunk, '预览 Hunk')
                map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, '当前行 Git 归属')
                map('n', '<leader>gd', gs.diffthis, '文件 Git 差异')
                map('n', '<leader>hS', gs.stage_buffer, '暂存整个 Buffer')
            end,
        },
    },
}

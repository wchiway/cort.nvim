return {
    {
        'folke/persistence.nvim',
        event = 'BufReadPre',
        opts = { dir = vim.fn.stdpath('state') .. '/sessions/', need = 1, branch = true },
        keys = {
            { '<leader>qs', function() require('persistence').load() end, desc = '恢复当前项目会话' },
            { '<leader>ql', function() require('persistence').load({ last = true }) end, desc = '恢复最近会话' },
            { '<leader>qd', function() require('persistence').stop() end, desc = '停止自动保存会话' },
        },
        config = function(_, opts)
            require('persistence').setup(opts)
            if not require('config.settings').session_autosave or vim.g.nvim_test then require('persistence').stop() end
        end,
    },
}

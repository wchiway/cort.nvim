return {
    {
        'windwp/nvim-autopairs',
        version = '0.10.0',
        event = 'InsertEnter',
        opts = {
            enabled = function(buf) return not require('config.bigfile').is_large(buf) end,
            disable_filetype = { 'TelescopePrompt', 'neo-tree' },
            check_ts = false,
        },
    },
    {
        'numToStr/Comment.nvim',
        keys = { { 'gc', mode = { 'n', 'x' } }, { 'gcc', mode = 'n' }, { 'gb', mode = { 'n', 'x' } }, { 'gbc', mode = 'n' } },
        opts = { mappings = { basic = true, extra = false } },
    },
    {
        'kylechui/nvim-surround',
        version = 'v4.0.5',
        event = 'VeryLazy',
        opts = {},
    },
    {
        'folke/todo-comments.nvim',
        event = { 'BufReadPost', 'BufNewFile' },
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false, highlight = { comments_only = false, max_line_len = 300, multiline = false } },
        keys = {
            { ']t', function() require('todo-comments').jump_next() end, desc = '下一条 TODO' },
            { '[t', function() require('todo-comments').jump_prev() end, desc = '上一条 TODO' },
            { '<leader>ft', '<cmd>TodoTelescope<cr>', desc = '搜索 TODO' },
        },
    },
    {
        'folke/flash.nvim',
        version = 'v2.1.0',
        keys = {
            { 's', function() require('flash').jump() end, mode = { 'n', 'x', 'o' }, desc = 'Flash 跳转' },
            { 'S', function() require('flash').treesitter() end, mode = { 'n', 'x', 'o' }, desc = 'Flash 语法选择' },
        },
        opts = { modes = { char = { enabled = false }, search = { enabled = false } } },
    },
    {
        'nvim-mini/mini.bufremove',
        branch = 'stable',
        keys = {
            { '<leader>bd', function() require('mini.bufremove').delete(0, false) end, desc = '安全关闭 Buffer' },
        },
        opts = { silent = true },
        main = 'mini.bufremove',
    },
}

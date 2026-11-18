return {
    {
        'nvim-tree/nvim-web-devicons',
        lazy = true,
        opts = { default = true },
    },
    {
        'nvim-lualine/lualine.nvim',
        event = 'VeryLazy',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            options = {
                theme = 'onedark', globalstatus = true,
                component_separators = '', section_separators = '',
                disabled_filetypes = { statusline = { 'dashboard' } },
            },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = { { 'filename', path = 1 } },
                lualine_x = { 'lsp_status', 'encoding', 'filetype' },
                lualine_y = { 'progress' },
                lualine_z = { 'location' },
            },
            tabline = { lualine_a = { { 'buffers', show_filename_only = true, show_modified_status = true, mode = 2 } } },
            extensions = { 'neo-tree', 'trouble', 'lazy' },
        },
    },
    {
        'folke/which-key.nvim',
        version = 'v3.17.0',
        event = 'VeryLazy',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            preset = 'modern', delay = 250, win = { border = 'rounded' },
            spec = {
                { '<leader>f', group = '搜索' }, { '<leader>b', group = 'Buffer' },
                { '<leader>c', group = '代码' }, { '<leader>d', group = '调试' },
                { '<leader>g', group = 'Git' }, { '<leader>h', group = 'Hunk' },
                { '<leader>q', group = '会话/退出' }, { '<leader>s', group = '窗口/搜索' },
                { '<leader>x', group = '诊断' }, { '<leader>m', group = 'CMake' },
            },
        },
        keys = { { '<leader>?', function() require('which-key').show({ global = false }) end, desc = '当前 Buffer 快捷键' } },
    },
    {
        'folke/trouble.nvim',
        version = 'v3.7.1',
        cmd = 'Trouble',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = { focus = true, warn_no_results = false },
        keys = {
            { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = '工作区诊断' },
            { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = '当前 Buffer 诊断' },
            { '<leader>xq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix' },
            { '<leader>xl', '<cmd>Trouble loclist toggle<cr>', desc = '位置列表' },
            { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = '文档符号' },
        },
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = {
            indent = { char = '│' },
            scope = { enabled = false },
            exclude = { filetypes = { 'help', 'neo-tree', 'Trouble', 'lazy', 'mason', 'dashboard' }, buftypes = { 'terminal', 'nofile', 'quickfix', 'prompt' } },
        },
        config = function(_, opts)
            require('ibl').setup(opts)
            local hooks = require('ibl.hooks')
            hooks.register(hooks.type.ACTIVE, function(buf)
                return not vim.b[buf].bigfile and not require('config.bigfile').is_large(buf)
            end)
        end,
    },
}

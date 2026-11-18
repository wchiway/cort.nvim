local function builtin(name)
    return function() require('telescope.builtin')[name]() end
end

return {
    {
        'nvim-telescope/telescope.nvim',
        version = 'v0.2.1',
        cmd = 'Telescope',
        dependencies = {
            'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        keys = {
            { '<leader>ff', builtin('find_files'), desc = '查找文件' },
            { '<leader>fg', builtin('live_grep'), desc = '全局文本搜索' },
            { '<leader>fb', builtin('buffers'), desc = '查找 Buffer' },
            { '<leader>fr', builtin('oldfiles'), desc = '最近文件' },
            { '<leader>fw', builtin('grep_string'), desc = '搜索当前词' },
            { '<leader>gc', builtin('git_commits'), desc = 'Git 提交' },
            { '<leader>gb', builtin('git_branches'), desc = 'Git 分支' },
            { '<leader>fk', builtin('keymaps'), desc = '快捷键搜索' },
        },
        config = function()
            require('telescope').setup({
                defaults = {
                    border = true,
                    sorting_strategy = 'ascending',
                    layout_config = { horizontal = { prompt_position = 'top' } },
                    prompt_prefix = '   ', selection_caret = '❯ ',
                    file_ignore_patterns = { '%.git/', 'node_modules/', 'target/', '%.venv/' },
                    mappings = { i = { ['<C-j>'] = 'move_selection_next', ['<C-k>'] = 'move_selection_previous' } },
                },
                pickers = { find_files = { hidden = true }, live_grep = { additional_args = { '--hidden' } } },
                extensions = { fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true } },
            })
            local ok, err = pcall(require('telescope').load_extension, 'fzf')
            if not ok then vim.notify('fzf-native 未构建, 使用 Lua 排序: ' .. tostring(err), vim.log.levels.WARN) end
        end,
    },
}

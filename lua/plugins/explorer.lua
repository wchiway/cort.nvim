return {
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        tag = '3.42.0',
        lazy = false, -- 按官方建议让 Neo-tree 自行懒加载, 正确接管目录参数。
        cmd = 'Neotree',
        dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim', 'nvim-tree/nvim-web-devicons' },
        keys = {
            { '<leader>e', function() require('neo-tree.command').execute({ toggle = true, source = 'filesystem', position = 'left', reveal = true }) end, desc = '文件树' },
        },
        opts = {
            close_if_last_window = true,
            popup_border_style = 'rounded',
            enable_git_status = true,
            enable_diagnostics = true,
            filesystem = {
                follow_current_file = { enabled = true },
                filtered_items = { hide_dotfiles = false, hide_gitignored = true },
                use_libuv_file_watcher = true,
            },
            window = { position = 'left', width = 32, mappings = { ['<space>'] = 'none', ['H'] = 'toggle_hidden' } },
        },
    },
}

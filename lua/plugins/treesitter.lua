return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false, -- 当前维护分支不支持懒加载。
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter').setup({ install_dir = vim.fn.stdpath('data') .. '/site' })
            local group = vim.api.nvim_create_augroup('PersonalTreesitter', { clear = true })
            vim.api.nvim_create_autocmd('FileType', {
                group = group,
                callback = function(args)
                    if vim.bo[args.buf].buftype ~= '' or require('config.bigfile').is_large(args.buf) then return end
                    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                    if lang and vim.treesitter.language.add(lang) then
                        vim.treesitter.start(args.buf, lang)
                    elseif lang and require('config.settings').treesitter.install_missing then
                        require('nvim-treesitter').install({ lang })
                    end
                end,
            })
            vim.api.nvim_create_user_command('TSInstallConfigured', function()
                require('nvim-treesitter').install(require('config.settings').treesitter.parsers)
            end, {})
        end,
    },
}

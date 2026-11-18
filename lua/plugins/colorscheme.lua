return {
    {
        'olimorris/onedarkpro.nvim',
        version = 'v2.29.0',
        lazy = false,
        priority = 1000,
        config = function()
            require('onedarkpro').setup({
                caching = true,
                styles = { comments = 'italic' },
                plugins = {
                    all = false, nvim_lsp = true, lsp_semantic_tokens = true, treesitter = true,
                    neo_tree = true, telescope = true, blink_cmp = true, gitsigns = true,
                    nvim_dap = true, nvim_dap_ui = true, trouble = true, which_key = true, indentline = true,
                },
                options = {
                    cursorline = true,
                    transparency = false,
                    terminal_colors = true,
                    highlight_inactive_windows = true,
                },
            })
            vim.cmd.colorscheme('onedark')
        end,
    },
}

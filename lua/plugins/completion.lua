-- 插入模式补全。
return {
    {
        'saghen/blink.cmp',
        version = 'v1.10.2',
        event = { 'InsertEnter', 'CmdlineEnter' },
        opts = {
            enabled = function() return not require('config.bigfile').is_large(0) and vim.bo.buftype ~= 'prompt' end,
            fuzzy = {
                implementation = 'lua',
            },
            keymap = {
                preset = 'default',
            },
            appearance = {
                nerd_font_variant = 'mono',
            },
            completion = {
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                    window = { border = 'rounded' },
                },
                menu = {
                    auto_show = true,
                    border = 'rounded',
                },
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },
            cmdline = {
                keymap = {
                    preset = 'cmdline',
                },
                completion = {
                    menu = {
                        auto_show = true,
                    },
                },
            },
            signature = {
                enabled = true,
                window = { border = 'rounded' },
            },
        },
    },
}

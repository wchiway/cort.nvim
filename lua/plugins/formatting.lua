-- 保存格式化由 config.settings.format_on_save 控制，默认关闭。
local formatters_by_ft = {
    c = { 'clang_format', lsp_format = 'fallback' },
    cpp = { 'clang_format', lsp_format = 'fallback' },
    objc = { 'clang_format', lsp_format = 'fallback' },
    objcpp = { 'clang_format', lsp_format = 'fallback' },
    rust = { 'rustfmt', lsp_format = 'fallback' },
    lua = { 'stylua', lsp_format = 'fallback' },
    python = { 'ruff_format', lsp_format = 'fallback' },
    go = { 'goimports', 'gofmt', lsp_format = 'fallback' },
    javascript = { 'prettier', lsp_format = 'fallback' },
    javascriptreact = { 'prettier', lsp_format = 'fallback' },
    typescript = { 'prettier', lsp_format = 'fallback' },
    typescriptreact = { 'prettier', lsp_format = 'fallback' },
    json = { 'prettier', lsp_format = 'fallback' },
    jsonc = { 'prettier', lsp_format = 'fallback' },
    yaml = { 'prettier', lsp_format = 'fallback' },
    markdown = { 'prettier', lsp_format = 'fallback' },
    html = { 'prettier', lsp_format = 'fallback' },
    css = { 'prettier', lsp_format = 'fallback' },
    scss = { 'prettier', lsp_format = 'fallback' },
    sh = { 'shfmt', lsp_format = 'fallback' },
    bash = { 'shfmt', lsp_format = 'fallback' },
    cmake = { 'gersemi', lsp_format = 'fallback' },
}

return {
    {
        'stevearc/conform.nvim',
        version = 'v9.1.0',
        cmd = { 'ConformInfo' },
        event = { 'BufWritePre' },
        keys = {
            {
                '<leader>cf',
                function()
                    if require('config.bigfile').is_large(0) then
                        vim.notify('大文件跳过格式化', vim.log.levels.INFO)
                        return
                    end
                    require('conform').format({ async = false, lsp_format = 'fallback' })
                end,
                mode = { 'n', 'v' },
                desc = '格式化当前缓冲区',
            },
        },
        opts = {
            formatters_by_ft = formatters_by_ft,
            default_format_opts = {
                lsp_format = 'fallback',
                timeout_ms = 1500,
            },
            format_on_save = function(buf)
                local ok, settings = pcall(require, 'config.settings')
                if not ok or not settings.format_on_save or vim.bo[buf].readonly or vim.bo[buf].buftype ~= '' or require('config.bigfile').is_large(buf) then
                    return nil
                end
                return {
                    lsp_format = 'fallback',
                    timeout_ms = 1500,
                }
            end,
            notify_no_formatters = false,
        },
    },
}

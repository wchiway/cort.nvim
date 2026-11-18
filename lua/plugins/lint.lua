-- 外部检查器仅在启用保存检查且本机命令可用时运行。
local linters_by_ft = {
    python = { 'ruff' },
    sh = { 'shellcheck' },
    bash = { 'shellcheck' },
    markdown = { 'markdownlint' },
    yaml = { 'yamllint' },
    cmake = { 'cmakelint' },
}

local function available_linters(lint, filetype)
    local available = {}
    for _, name in ipairs(linters_by_ft[filetype] or {}) do
        local linter = lint.linters[name]
        local command = linter and linter.cmd
        if type(command) == 'function' then
            command = command()
        end
        if type(command) == 'string' and vim.fn.executable(command) == 1 then
            available[#available + 1] = name
        end
    end
    return available
end

return {
    {
        'mfussenegger/nvim-lint',
        commit = '52107ce2076a27a285af781248e2c59bad817cd0',
        event = { 'BufReadPost', 'BufNewFile' },
        keys = {
            { '<leader>cL', function()
                if require('config.bigfile').is_large(0) then return end
                local lint = require('lint')
                local available = available_linters(lint, vim.bo.filetype)
                if #available > 0 then lint.try_lint(available)
                else vim.notify('当前文件没有已安装的外部检查器', vim.log.levels.INFO) end
            end, desc = '运行外部 Lint' },
        },
        config = function()
            local lint = require('lint')
            lint.linters_by_ft = linters_by_ft

            vim.api.nvim_create_autocmd('BufWritePost', {
                group = vim.api.nvim_create_augroup('ConfigLintOnSave', { clear = true }),
                callback = function(event)
                    local ok, settings = pcall(require, 'config.settings')
                    if not ok or not settings.lint_on_save or require('config.bigfile').is_large(event.buf) or vim.bo[event.buf].buftype ~= '' then
                        return
                    end
                    local filetype = vim.bo[event.buf].filetype
                    local available = available_linters(lint, filetype)
                    if #available > 0 then
                        lint.try_lint(available)
                    end
                end,
            })
        end,
    },
}

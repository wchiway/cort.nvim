local M = {}
local saved = {}

function M.is_large(buf)
    buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
    if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= '' then return false end
    local limits = require('config.settings').large_file
    local lines = vim.api.nvim_buf_line_count(buf)
    return lines > limits.lines or vim.api.nvim_buf_get_offset(buf, lines) > limits.bytes
end

function M.apply(buf, large)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    vim.b[buf].bigfile = large
    if large then
        -- stop() 可能恢复 syntax, 必须先停止再禁用大文件高亮。
        if package.loaded['vim.treesitter'] then vim.treesitter.stop(buf) end
        if not saved[buf] then
            saved[buf] = { syntax = vim.bo[buf].syntax, undofile = vim.bo[buf].undofile }
        end
        if saved[buf].syntax == '' and vim.bo[buf].syntax ~= '' then saved[buf].syntax = vim.bo[buf].syntax end
        vim.bo[buf].syntax = ''
        vim.bo[buf].undofile = false
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do vim.lsp.buf_detach_client(buf, client.id) end
    elseif saved[buf] then
        vim.bo[buf].syntax = saved[buf].syntax
        vim.bo[buf].undofile = saved[buf].undofile
        saved[buf] = nil
    end
end

function M.update(buf)
    M.apply(buf, M.is_large(buf))
end

function M.clear(buf)
    saved[buf] = nil
end

return M

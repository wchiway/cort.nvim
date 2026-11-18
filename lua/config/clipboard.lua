local M = { native = nil, active = nil }

local function windows_provider(powershell)
    local copy_command = {
        powershell, '-NoLogo', '-NoProfile', '-NonInteractive', '-STA', '-Command',
        '$ErrorActionPreference="Stop"; [Console]::InputEncoding=[System.Text.UTF8Encoding]::new($false); '
            .. '[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false); '
            .. 'Add-Type -AssemblyName System.Windows.Forms; $text=[Console]::In.ReadToEnd(); '
            .. 'if ($text.Length -eq 0) { [System.Windows.Forms.Clipboard]::Clear() } '
            .. 'else { [System.Windows.Forms.Clipboard]::SetText($text, [System.Windows.Forms.TextDataFormat]::UnicodeText) }',
    }
    local function copy(lines)
        local result = vim.system(copy_command, { stdin = table.concat(lines, '\n'), text = true }):wait(5000)
        if result.code ~= 0 then error('Windows 剪贴板写入失败, 退出码 ' .. result.code) end
    end
    local paste = {
        powershell, '-NoLogo', '-NoProfile', '-NonInteractive', '-STA', '-Command',
        '$ErrorActionPreference="Stop"; [Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false); '
            .. '$text=Get-Clipboard -Raw; if ($null -ne $text) { [Console]::Out.Write($text.Replace("`r`n","`n")) }',
    }
    return {
        name = 'WSL Windows Clipboard',
        copy = { ['+'] = copy, ['*'] = copy },
        paste = { ['+'] = paste, ['*'] = paste },
        cache_enabled = 0,
    }
end

function M.setup()
    local settings = require('config.settings')
    local mode = settings.clipboard
    assert(vim.tbl_contains({ 'auto', 'native', 'windows', 'osc52', 'off' }, mode), '无效 clipboard 模式')
    if mode == 'off' then M.active = 'off'; return false end
    if vim.g.clipboard ~= nil and vim.g.clipboard ~= false then
        M.active = type(vim.g.clipboard) == 'table' and vim.g.clipboard.name or tostring(vim.g.clipboard)
        return true
    end
    local ok, native = pcall(vim.fn['provider#clipboard#Executable'])
    M.native = ok and native or ''
    local wsl = vim.env.WSL_DISTRO_NAME ~= nil and vim.env.WSL_DISTRO_NAME ~= ''
    -- 原生 Windows / OSC52 通道优先; WSLg 曾无法同步 Windows 时提供平台回退。
    local needs_windows = mode == 'windows'
        or (mode == 'auto' and wsl and not vim.tbl_contains({ 'win32yank', 'WslClipboard', 'OSC 52' }, M.native))
    local powershell = settings.windows_powershell or vim.fn.exepath('powershell.exe')
    if powershell == '' and wsl then
        powershell = '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe'
    end
    if mode == 'osc52' then
        vim.g.clipboard = 'osc52'
    elseif needs_windows and vim.fn.executable(powershell) == 1 then
        vim.g.clipboard = windows_provider(powershell)
    elseif mode == 'windows' then
        vim.notify('未找到 Windows PowerShell, 回退到原生剪贴板', vim.log.levels.WARN)
    end
    if vim.g.clipboard ~= nil and vim.g.loaded_clipboard_provider ~= nil then
        vim.g.loaded_clipboard_provider = nil
        vim.cmd('runtime autoload/provider/clipboard.vim')
    end
    M.active = vim.g.clipboard == 'osc52' and 'OSC 52'
        or (type(vim.g.clipboard) == 'table' and vim.g.clipboard.name) or M.native
    return M.active ~= ''
end

return M

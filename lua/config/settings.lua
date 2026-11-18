return {
    mouse = true,
    -- auto 优先原生可用通道; WSLg 通道不可靠时回退到 Windows。
    -- 可选: auto / native / windows / osc52 / off。
    clipboard = 'auto',
    -- 非标准 Windows 安装路径可显式指定, 默认先搜索 PATH。
    windows_powershell = nil,
    large_file = { bytes = 1024 * 1024, lines = 20000 },
    format_on_save = false,
    lint_on_save = false,
    auto_install_lsp = false,
    session_autosave = true,
    treesitter = {
        install_missing = false,
        parsers = { 'c', 'cpp', 'rust', 'lua', 'python', 'go', 'javascript', 'typescript', 'tsx', 'json', 'yaml', 'bash', 'cmake', 'markdown', 'markdown_inline', 'vim', 'vimdoc' },
    },
}

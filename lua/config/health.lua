local M = {}

function M.check()
    vim.health.start('个人 Neovim IDE')
    if vim.fn.has('nvim-0.12') == 1 then vim.health.ok('Neovim ' .. tostring(vim.version()))
    else vim.health.error('需要 Neovim 0.12+') end
    if vim.g.colors_name == 'onedark' then vim.health.ok('OneDarkPro / onedark')
    else vim.health.error('未加载 onedark 主题') end
    for _, tool in ipairs({ 'git', 'rg', 'fd', 'cc', 'make', 'tar', 'curl', 'tree-sitter' }) do
        if vim.fn.executable(tool) == 1 then vim.health.ok(tool .. ': ' .. vim.fn.exepath(tool))
        else vim.health.error('缺少依赖: ' .. tool) end
    end
    local plugins = require('lazy.core.config').plugins
    local missing = {}
    for name, plugin in pairs(plugins) do if not plugin._.installed then missing[#missing + 1] = name end end
    if #missing == 0 then vim.health.ok('全部 ' .. vim.tbl_count(plugins) .. ' 个插件已安装')
    else vim.health.error('插件缺失: ' .. table.concat(missing, ', ') .. '; :Lazy install') end
    if vim.fn.executable(vim.o.shell) == 1 then vim.health.ok('环境检测的 Shell: ' .. vim.o.shell)
    else vim.health.warn('Shell 不可执行, 检查 SHELL 环境变量') end
    local proxy = false
    for _, key in ipairs({ 'http_proxy', 'https_proxy', 'all_proxy', 'HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY' }) do
        if vim.env[key] and vim.env[key] ~= '' then proxy = true end
    end
    vim.health.info(proxy and '代理环境变量已设置 (不输出敏感值)' or '未设置代理, Git 下载失败时检查启动环境')
    local clipboard = require('config.clipboard')
    vim.health.info('原生剪贴板: ' .. tostring(clipboard.native or '自定义'))
    vim.health.info('活动剪贴板: ' .. tostring(clipboard.active or '未启用'))
    vim.health.info('真实剪贴板写入验证必须另获授权, 检测 provider 不等于 Windows 同步已验证')

    vim.health.start('语言工具: 缺失项按需安装, 不批量自动下载')
    local servers = {
        clangd = 'clangd', rust_analyzer = 'rust-analyzer', lua_ls = 'lua-language-server',
        basedpyright = 'basedpyright-langserver', gopls = 'gopls', ts_ls = 'typescript-language-server',
        jsonls = 'vscode-json-language-server', yamlls = 'yaml-language-server', bashls = 'bash-language-server', neocmake = 'neocmakelsp',
    }
    for server, command in pairs(servers) do
        if vim.fn.executable(command) == 1 then vim.health.ok(server .. ' 可用')
        else vim.health.warn(server .. ' 未安装; :Mason 安装后 :LspEnableAvailable 或重启') end
    end
    for _, tool in ipairs({ 'clang-format', 'rustfmt', 'stylua', 'ruff', 'gofmt', 'goimports', 'prettier', 'shfmt' }) do
        if vim.fn.executable(tool) == 1 then vim.health.ok('格式化工具: ' .. tool)
        else vim.health.info(tool .. ' 未安装; 项目本地工具也可能由 Conform 识别') end
    end
    vim.health.info('格式化 :ConformInfo / Space cf; Lint Space cL; 自动开关在 config.settings')
    for _, lang in ipairs(require('config.settings').treesitter.parsers) do
        if vim.treesitter.language.add(lang) then vim.health.ok('Parser: ' .. lang)
        else vim.health.warn('Parser 缺失: ' .. lang .. '; :TSInstallConfigured') end
    end
    vim.health.start('调试')
    local available, reason = require('config.dap_helpers').gdb_available()
    if available then vim.health.ok('GDB 14+ 且含 Python, 可提供 C/C++/Rust DAP')
    else vim.health.warn(reason) end
    local debugpy = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python'
    if vim.fn.executable(debugpy) == 1 then vim.health.ok('Mason debugpy 已安装')
    else vim.health.info('debugpy 按需安装到项目 .venv, 或 :MasonInstall debugpy') end
end

return M

-- 原生 LSP 配置；语言服务器仅在本机命令存在时启动。
local servers = {
    clangd = { 'clangd' },
    rust_analyzer = { 'rust-analyzer' },
    lua_ls = { 'lua-language-server' },
    basedpyright = { 'basedpyright-langserver', '--stdio' },
    gopls = { 'gopls' },
    ts_ls = { 'typescript-language-server', '--stdio' },
    jsonls = { 'vscode-json-language-server', '--stdio' },
    yamlls = { 'yaml-language-server', '--stdio' },
    bashls = { 'bash-language-server', 'start' },
    neocmake = { 'neocmakelsp', 'stdio' },
}

local function executable(command)
    return vim.fn.executable(command[1]) == 1
end

local function is_big_buffer(bufnr)
    return vim.b[bufnr].bigfile or require('config.bigfile').is_large(bufnr)
end

local function on_attach(client, bufnr)
    if is_big_buffer(bufnr) then
        vim.lsp.buf_detach_client(bufnr, client.id)
        return
    end

    local map = function(lhs, rhs, desc, mode)
        vim.keymap.set(mode or 'n', lhs, rhs, {
            buffer = bufnr,
            silent = true,
            desc = desc,
        })
    end

    map('gd', vim.lsp.buf.definition, '跳转到定义')
    map('gD', vim.lsp.buf.declaration, '跳转到声明')
    map('gI', vim.lsp.buf.implementation, '跳转到实现')
    map('gr', vim.lsp.buf.references, '查找引用')
    map('<leader>cr', vim.lsp.buf.rename, '重命名')
    map('<leader>ca', vim.lsp.buf.code_action, '代码操作', { 'n', 'v' })
    map('K', vim.lsp.buf.hover, '悬浮文档')
    map('<leader>ch', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
    end, '切换 Inlay Hints')
    map('<leader>cR', vim.lsp.codelens.run, '执行 CodeLens')
    map('<C-k>', vim.lsp.buf.signature_help, '签名帮助', 'i')
    map('<leader>ss', function() require('telescope.builtin').lsp_workspace_symbols() end, '工作区符号')
end

local function configure_servers()
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    local common = {
        capabilities = capabilities,
        on_attach = on_attach,
    }

    local configs = {
        clangd = {
            cmd = function(dispatchers, config)
                local root_dir = config.root_dir or vim.fn.getcwd()
                local command = vim.deepcopy(servers.clangd)
                local candidates = {
                    root_dir,
                    vim.fs.joinpath(root_dir, 'build'),
                    vim.fs.joinpath(root_dir, 'cmake-build-debug'),
                    vim.fs.joinpath(root_dir, 'cmake-build-release'),
                }
                for name, kind in vim.fs.dir(root_dir) do
                    if kind == 'directory' and name:match('^cmake%-build') then candidates[#candidates + 1] = vim.fs.joinpath(root_dir, name) end
                end
                for _, directory in ipairs(candidates) do
                    if vim.uv.fs_stat(vim.fs.joinpath(directory, 'compile_commands.json')) then
                        command[#command + 1] = '--compile-commands-dir=' .. directory
                        break
                    end
                end
                return vim.lsp.rpc.start(command, dispatchers, { cwd = root_dir })
            end,
            root_markers = { 'compile_commands.json', 'CMakeLists.txt', 'Makefile', '.git' },
        },
        rust_analyzer = {
            cmd = servers.rust_analyzer,
            root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
        },
        lua_ls = {
            cmd = servers.lua_ls,
            root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', '.git' },
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    diagnostics = { globals = { 'vim' } },
                    workspace = {
                        checkThirdParty = false,
                        library = { vim.env.VIMRUNTIME },
                    },
                    telemetry = { enable = false },
                },
            },
        },
        basedpyright = {
            cmd = servers.basedpyright,
            root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
            settings = {
                basedpyright = {
                    analysis = {
                        typeCheckingMode = 'standard',
                        diagnosticMode = 'workspace',
                        autoSearchPaths = true,
                    },
                },
            },
            before_init = function(_, config)
                local root_dir = config.root_dir or vim.fn.getcwd()
                for _, directory in ipairs({ '.venv', 'venv' }) do
                    local python = vim.fs.joinpath(root_dir, directory, 'bin', 'python')
                    if vim.fn.executable(python) == 1 then
                        config.settings.python = { pythonPath = python }
                        break
                    end
                end
            end,
        },
        gopls = {
            cmd = servers.gopls,
            root_markers = { 'go.work', 'go.mod', '.git' },
            settings = {
                gopls = {
                    gofumpt = true,
                    analyses = { unusedparams = true, shadow = true },
                    staticcheck = true,
                },
            },
        },
        ts_ls = {
            cmd = servers.ts_ls,
            root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
        },
        jsonls = {
            cmd = servers.jsonls,
            root_markers = { 'package.json', '.git' },
        },
        yamlls = {
            cmd = servers.yamlls,
            root_markers = { '.yamllint', '.git' },
        },
        bashls = {
            cmd = servers.bashls,
            root_markers = { '.git' },
        },
        neocmake = {
            cmd = servers.neocmake,
            root_markers = { '.neocmake.toml', 'CMakeLists.txt', '.git' },
        },
    }

    for name, config in pairs(configs) do
        config.capabilities = common.capabilities
        config.on_attach = common.on_attach
        local defaults = vim.lsp.config[name]
        local root_callback = config.root_dir or defaults.root_dir
        local markers = config.root_markers or defaults.root_markers or { '.git' }
        config.root_dir = function(buf, on_dir)
            if is_big_buffer(buf) then return end
            if type(root_callback) == 'function' then root_callback(buf, on_dir)
            else on_dir(vim.fs.root(buf, markers)) end
        end
        vim.lsp.config(name, config)
        if executable(servers[name]) then vim.lsp.enable(name) end
    end
    vim.api.nvim_create_user_command('LspEnableAvailable', function()
        for name, command in pairs(servers) do if executable(command) then vim.lsp.enable(name) end end
    end, {})
end

return {
    {
        'neovim/nvim-lspconfig',
        version = 'v2.12.0',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'mason-org/mason.nvim', version = 'v2.3.1', cmd = 'Mason', opts = { ui = { border = 'rounded' } } },
            {
                'mason-org/mason-lspconfig.nvim',
                version = 'v2.3.0',
                opts = function()
                    local ensure = {}
                    if require('config.settings').auto_install_lsp then
                        for name, command in pairs(servers) do if not executable(command) then ensure[#ensure + 1] = name end end
                    end
                    return { ensure_installed = ensure, automatic_enable = false }
                end,
            },
            'saghen/blink.cmp',
        },
        config = configure_servers,
    },
}

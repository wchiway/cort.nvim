-- nvim --headless -i NONE -u tests/integration.lua
-- 只使用临时项目/剪贴板替身, 不写真实 Git 或剪贴板, 不运行用户项目。
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.rtp:prepend(root)
vim.g.nvim_test = true
vim.g.clipboard = { name = 'integration-only', copy = { ['+'] = function() end, ['*'] = function() end }, paste = { ['+'] = function() return { { '' }, 'v' } end, ['*'] = function() return { { '' }, 'v' } end }, cache_enabled = 0 }
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, 'p')
local checked, failed = 0, 0
local function check(name, fn)
    checked = checked + 1
    local ok, err = xpcall(fn, debug.traceback)
    if not ok then failed = failed + 1; print('FAIL ' .. name .. ': ' .. tostring(err)) end
end
local function edit(name, lines)
    local path = tmp .. '/' .. name
    vim.fn.mkdir(vim.fs.dirname(path), 'p')
    vim.fn.writefile(lines, path)
    vim.cmd.edit(path)
    return vim.api.nvim_get_current_buf()
end
local function keys(value)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(value, true, false, true), 'xt', false)
end
local function run()
    vim.cmd.cd(tmp)
    check('完整插件均已安装', function()
        local plugins = require('lazy.core.config').plugins
        assert(vim.tbl_count(plugins) >= 28)
        for name, plugin in pairs(plugins) do assert(plugin._.installed, name) end
        assert(vim.g.colors_name == 'onedark')
    end)
    check('所有模块可以配置加载', function()
        require('lazy').load({ plugins = { 'lualine.nvim', 'which-key.nvim', 'trouble.nvim', 'telescope.nvim', 'nvim-autopairs', 'Comment.nvim', 'nvim-surround', 'todo-comments.nvim', 'flash.nvim', 'mini.bufremove', 'nvim-lspconfig', 'conform.nvim', 'nvim-lint', 'gitsigns.nvim', 'nvim-dap', 'persistence.nvim' } })
        assert(type(require('blink.cmp').get_lsp_capabilities) == 'function')
        assert(type(require('dap').continue) == 'function')
        assert(type(require('conform').format) == 'function')
    end)
    check('编辑窗口使用连续的实际行号', function()
        edit('line-numbers.txt', vim.fn['repeat']({ 'line' }, 200))
        for _, row in ipairs({ 1, 181, 200 }) do
            vim.api.nvim_win_set_cursor(0, { row, 0 })
            assert(vim.wo.number and not vim.wo.relativenumber)
        end
        vim.cmd.vsplit()
        assert(vim.wo.number and not vim.wo.relativenumber)
        vim.cmd.only()
    end)
    check('所有语言 parser 和查询可用', function()
        for _, lang in ipairs(require('config.settings').treesitter.parsers) do
            assert(vim.treesitter.language.add(lang), lang)
            assert(vim.treesitter.query.get(lang, 'highlights'), lang .. ' highlights')
        end
    end)
    check('原生 LSP 注册完整且具备补全能力', function()
        for _, name in ipairs({ 'clangd', 'rust_analyzer', 'lua_ls', 'basedpyright', 'gopls', 'ts_ls', 'jsonls', 'yamlls', 'bashls', 'neocmake' }) do
            local config = vim.lsp.config[name]
            assert(config and config.cmd, name)
            assert(config.capabilities.textDocument.completion.completionItem.snippetSupport, name)
        end
        assert(vim.fn.exists(':Mason') == 2)
        assert(vim.fn.exists(':LspEnableAvailable') == 2)
        assert(require('config.settings').auto_install_lsp == false)
    end)
    check('打开各语言文件有 Treesitter 高亮', function()
        for _, item in ipairs({ { 'sample.lua', 'return 1' }, { 'sample.py', 'value = 1' }, { 'sample.go', 'package main' }, { 'sample.ts', 'const value = 1;' }, { 'sample.json', '{}' }, { 'sample.yaml', 'value: 1' }, { 'sample.sh', '#!/bin/sh' }, { 'CMakeLists.txt', 'cmake_minimum_required(VERSION 3.10)' } }) do
            vim.v.errmsg = ''
            local buf = edit(item[1], { item[2] })
            assert(vim.v.errmsg == '', vim.v.errmsg)
            assert(vim.treesitter.highlighter.active[buf], item[1])
        end
    end)
    check('系统 clangd 可以真实附着临时 C 项目', function()
        edit('CMakeLists.txt', { 'cmake_minimum_required(VERSION 3.10)', 'project(test C)' })
        local buf = edit('main.c', { 'int add(int a,int b){return a+b;}', 'int main(void){return add(1,2);}' })
        assert(vim.wait(10000, function()
            for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf, name = 'clangd' })) do if client.initialized then return true end end
            return false
        end, 50), 'clangd 未完成初始化')
        assert(vim.fn.maparg('gd', 'n', false, true).buffer == 1)
        assert(vim.fn.maparg('<leader>cr', 'n', false, true).buffer == 1)
        require('conform').format({ async = false, lsp_format = 'fallback' })
        assert(vim.api.nvim_get_current_line():find('int add', 1, true))
        vim.bo.modified = false
    end)
    check('系统 rust-analyzer 可以附着临时 Cargo 项目', function()
        vim.fn.mkdir(tmp .. '/rust/src', 'p')
        vim.fn.writefile({ '[package]', 'name = "nvim_verify"', 'version = "0.1.0"', 'edition = "2021"' }, tmp .. '/rust/Cargo.toml')
        local buf = edit('rust/src/lib.rs', { 'pub fn add(a: i32, b: i32) -> i32 { a + b }' })
        assert(vim.wait(10000, function()
            for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf, name = 'rust_analyzer' })) do if client.initialized then return true end end
            return false
        end, 50), 'rust-analyzer 未完成初始化')
    end)
    check('Comment 和 Surround 操作临时文本', function()
        edit('editor.lua', { 'local value = 1' })
        keys('gcc')
        assert(vim.api.nvim_get_current_line():find('--', 1, true))
        keys('gcc')
        assert(not vim.api.nvim_get_current_line():find('--', 1, true))
        vim.api.nvim_win_set_cursor(0, { 1, 6 })
        keys('ysiw)')
        assert(vim.api.nvim_get_current_line():find('(value)', 1, true))
        vim.bo.modified = false
    end)
    check('自动括号可以工作', function()
        edit('pairs.lua', { '' })
        keys('i(<Esc>')
        assert(vim.api.nvim_get_current_line() == '()')
        vim.bo.modified = false
    end)
    check('文件图标和状态栏配置', function()
        local icon = require('nvim-web-devicons').get_icon('sample.py', 'py', { default = true })
        assert(icon and icon ~= '')
        local config = require('lualine').get_config()
        assert(config.options.globalstatus)
        assert(config.options.theme == 'onedark')
    end)
    check('Telescope 能打开临时项目文件搜索', function()
        require('telescope.builtin').find_files({ cwd = tmp })
        assert(vim.bo.filetype == 'TelescopePrompt')
        require('telescope.actions').close(vim.api.nvim_get_current_buf())
    end)
    check('Neo-tree 能显示临时项目', function()
        require('neo-tree.command').execute({ source = 'filesystem', dir = tmp, action = 'focus', position = 'left' })
        assert(vim.bo.filetype == 'neo-tree')
        vim.cmd('Neotree close')
    end)
    check('诊断 UI 可以打开关闭', function()
        local buf = edit('diagnostic.lua', { 'local value = 1' })
        vim.diagnostic.set(vim.api.nvim_create_namespace('test-diagnostic'), buf, { { lnum = 0, col = 0, message = 'synthetic diagnostic', severity = vim.diagnostic.severity.ERROR } })
        vim.cmd('Trouble diagnostics open')
        require('trouble').close('diagnostics')
    end)
    check('GDB DAP 已配置, 未启动用户程序', function()
        assert(require('config.dap_helpers').gdb_available())
        local dap = require('dap')
        assert(dap.adapters.gdb and dap.configurations.c and dap.configurations.rust)
        assert(dap.configurations.python)
        require('dapui').open()
        require('dapui').close()
        assert(not dap.session())
    end)
    check('格式化和 Lint 缺失工具不会自动报错', function()
        local config = require('conform').list_formatters(0)
        assert(type(config) == 'table')
        assert(require('config.settings').format_on_save == false)
        assert(require('config.settings').lint_on_save == false)
    end)
    check('大文件关闭高亮/补全/LSP', function()
        local limits = require('config.settings').large_file
        local buf = edit('large.lua', { '-- ' .. string.rep('x', limits.bytes) })
        assert(vim.b[buf].bigfile and vim.bo[buf].syntax == '')
        assert(not vim.treesitter.highlighter.active[buf])
        assert(#vim.lsp.get_clients({ bufnr = buf }) == 0)
    end)
    check('安全 Buffer 关闭保持窗口布局', function()
        local buf = edit('remove.lua', { 'return 1' })
        vim.cmd.vsplit()
        local windows = #vim.api.nvim_list_wins()
        require('mini.bufremove').delete(buf, false)
        assert(#vim.api.nvim_list_wins() == windows)
        vim.cmd.only()
    end)
    check('插件快捷键之间无冲突', function()
        local seen = {}
        for name, plugin in pairs(require('lazy.core.config').plugins) do
            for _, key in ipairs(type(plugin.keys) == 'table' and plugin.keys or {}) do
                if type(key) == 'table' then
                    local modes = type(key.mode) == 'table' and key.mode or { key.mode or 'n' }
                    for _, mode in ipairs(modes) do
                        local id = mode .. ':' .. key[1]
                        assert(not seen[id] or seen[id] == name, '快捷键冲突: ' .. id)
                        seen[id] = name
                    end
                end
            end
        end
    end)
    check('CMake 命令和核心快捷键已注册', function()
        assert(vim.fn.exists(':CMakeConfigure') == 2 and vim.fn.exists(':CMakeBuild') == 2)
        for _, key in ipairs({ '<leader>e', '<leader>ff', '<leader>fg', '<leader>fb', '<leader>fr', '<leader>gg', '<leader>cf', '<leader>xx', '<leader>db', '<leader>dc', '<leader>du', '<leader>qs', '<leader>bd' }) do assert(vim.fn.maparg(key, 'n') ~= '', key) end
    end)
    for _, client in ipairs(vim.lsp.get_clients()) do client:stop() end
    vim.wait(3000, function() return #vim.lsp.get_clients() == 0 end, 50)
    pcall(require('persistence').stop)
    pcall(vim.api.nvim_del_augroup_by_name, 'PersonalConfig')
    vim.fn.delete(tmp, 'rf')
    print(string.format('integration: checked=%d failed=%d', checked, failed))
    vim.cmd(failed == 0 and 'qa!' or 'cquit 1')
end
local ok, err = xpcall(function()
    dofile(root .. '/init.lua')
    vim.api.nvim_create_autocmd('VimEnter', { once = true, callback = function() vim.schedule(run) end })
end, debug.traceback)
if not ok then print(err); vim.cmd('cquit 1') end

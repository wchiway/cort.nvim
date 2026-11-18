local M = {}

local function execute(command, root, title)
    if vim.fn.executable(command[1]) ~= 1 then
        vim.notify('缺少工具: ' .. command[1], vim.log.levels.WARN)
        return
    end
    vim.system(command, { cwd = root, text = true }, function(result)
        vim.schedule(function()
            local output = (result.stdout or '') .. (result.stderr or '')
            vim.fn.setqflist({}, ' ', { title = title, lines = vim.split(output, '\n'), efm = vim.o.errorformat })
            vim.notify(title .. (result.code == 0 and ' 完成' or ' 失败: :copen 查看输出'), result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
        end)
    end)
end

local function cmake_root()
    local root = vim.fs.root(0, 'CMakeLists.txt')
    if not root then vim.notify('当前文件不在 CMake 项目中', vim.log.levels.WARN) end
    return root
end

function M.configure()
    local root = cmake_root()
    if root then execute({ 'cmake', '-S', root, '-B', root .. '/build', '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON' }, root, 'CMake configure') end
end

function M.build()
    local root = cmake_root()
    if root then execute({ 'cmake', '--build', root .. '/build' }, root, 'CMake build') end
end

function M.setup()
    vim.api.nvim_create_user_command('CMakeConfigure', M.configure, {})
    vim.api.nvim_create_user_command('CMakeBuild', M.build, {})
    vim.keymap.set('n', '<leader>mc', M.configure, { desc = 'CMake 配置/生成编译数据库' })
    vim.keymap.set('n', '<leader>mb', M.build, { desc = 'CMake 构建' })
end

return M

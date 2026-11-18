local M = {}

function M.project_root()
    return vim.fs.root(0, { 'Cargo.toml', 'CMakeLists.txt', 'pyproject.toml', '.git' }) or vim.fn.getcwd()
end

function M.program()
    local path = vim.fn.input({ prompt = 'Executable: ', default = M.project_root() .. '/', completion = 'file' })
    if path == '' then return require('dap').ABORT end
    path = vim.fn.fnamemodify(path, ':p')
    if vim.fn.executable(path) ~= 1 then
        vim.notify('文件不存在或不可执行: ' .. path, vim.log.levels.WARN)
        return require('dap').ABORT
    end
    return path
end

function M.gdb_available()
    local gdb = vim.fn.exepath('gdb')
    if gdb == '' then return false, '未安装 GDB' end
    local version = vim.system({ gdb, '--version' }, { text = true }):wait(2000)
    local major = tonumber((version.stdout or ''):match('(%d+)%.'))
    local build = vim.system({ gdb, '--configuration' }, { text = true }):wait(2000)
    if version.code ~= 0 or not major or major < 14 then return false, 'GDB DAP 需要 14+' end
    if build.code ~= 0 or not (build.stdout or ''):find('with%-python') then return false, 'GDB 需要 Python 支持才能提供 DAP' end
    return true, gdb
end

function M.debugpy_python(root)
    root = root or M.project_root()
    local candidates = {
        root .. '/.venv/bin/python', root .. '/venv/bin/python',
        vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python',
        vim.fn.exepath('python3'),
    }
    for _, python in ipairs(candidates) do
        if python ~= '' and vim.fn.executable(python) == 1 then
            local result = vim.system({ python, '-I', '-c', 'import debugpy' }, { text = true }):wait(2000)
            if result.code == 0 then return python end
        end
    end
end

function M.python_path()
    local root = M.project_root()
    for _, python in ipairs({ root .. '/.venv/bin/python', root .. '/venv/bin/python' }) do
        if vim.fn.executable(python) == 1 then return python end
    end
    return vim.fn.exepath('python3')
end

return M

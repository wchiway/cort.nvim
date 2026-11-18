return {
    {
        'mfussenegger/nvim-dap',
        dependencies = { 'rcarriga/nvim-dap-ui', 'nvim-neotest/nvim-nio' },
        keys = {
            { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = '调试断点' },
            { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = '条件断点' },
            { '<leader>dc', function() require('dap').continue() end, desc = '启动/继续调试' },
            { '<leader>du', function() require('dapui').toggle() end, desc = '调试界面' },
            { '<leader>dr', function() require('dap').repl.toggle() end, desc = '调试 REPL' },
            { '<leader>dx', function() require('dap').terminate() end, desc = '停止调试' },
            { '<F5>', function() require('dap').continue() end, desc = '调试继续' },
            { '<F10>', function() require('dap').step_over() end, desc = '单步跳过' },
            { '<F11>', function() require('dap').step_into() end, desc = '单步进入' },
            { '<S-F11>', function() require('dap').step_out() end, desc = '单步跳出' },
        },
        config = function()
            local dap, ui = require('dap'), require('dapui')
            local helper = require('config.dap_helpers')
            ui.setup({ floating = { border = 'rounded' } })
            dap.listeners.after.event_initialized.personal_ui = function() ui.open() end
            dap.listeners.before.event_terminated.personal_ui = function() ui.close() end
            dap.listeners.before.event_exited.personal_ui = function() ui.close() end
            local available, gdb = helper.gdb_available()
            if available then
                dap.adapters.gdb = { type = 'executable', command = gdb, args = { '--quiet', '--nx', '--interpreter=dap' } }
                local launch = { name = 'GDB: Launch executable', type = 'gdb', request = 'launch', program = helper.program, cwd = helper.project_root, stopAtBeginningOfMainSubprogram = true }
                dap.configurations.c = { launch }
                dap.configurations.cpp = vim.deepcopy(dap.configurations.c)
                dap.configurations.rust = vim.deepcopy(dap.configurations.c)
            else
                vim.notify(gdb .. '; C/C++/Rust 调试未启用', vim.log.levels.WARN)
            end
            dap.adapters.python = function(callback, config)
                local python = helper.debugpy_python(config.cwd)
                if not python then
                    vim.notify('缺少 debugpy: 在项目 .venv 安装, 或 :MasonInstall debugpy', vim.log.levels.WARN)
                    return
                end
                callback({ type = 'executable', command = python, args = { '-I', '-m', 'debugpy.adapter' } })
            end
            dap.configurations.python = {
                { name = 'Python: Current file', type = 'python', request = 'launch', program = '${file}', cwd = helper.project_root, pythonPath = helper.python_path, console = 'integratedTerminal' },
            }
        end,
    },
}

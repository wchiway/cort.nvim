-- nvim --headless -u NONE -i NONE -l tests/dap.lua
-- 只初始化/断开 GDB DAP, 不启动任何被调试程序。
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.rtp:prepend(root)
local available, gdb = require('config.dap_helpers').gdb_available()
if not available then print('DAP unavailable: ' .. gdb); vim.cmd('cquit 1') end
local function packet(value)
    local body = vim.json.encode(value)
    return 'Content-Length: ' .. #body .. '\r\n\r\n' .. body
end
local input = packet({ seq = 1, type = 'request', command = 'initialize', arguments = { clientID = 'nvim-verify', adapterID = 'gdb', pathFormat = 'path', linesStartAt1 = true, columnsStartAt1 = true } })
    .. packet({ seq = 2, type = 'request', command = 'disconnect', arguments = {} })
local result = vim.system({ gdb, '--quiet', '--nx', '--interpreter=dap' }, { stdin = input }):wait(5000)
local output, pos, initialized = result.stdout or '', 1, false
while true do
    local start, finish, size = output:find('Content%-Length: (%d+)\r?\n\r?\n', pos)
    if not start then break end
    local body = output:sub(finish + 1, finish + tonumber(size))
    local ok, message = pcall(vim.json.decode, body)
    if ok and message.type == 'response' and message.request_seq == 1 and message.success then initialized = true end
    pos = finish + tonumber(size) + 1
end
if initialized then print('GDB DAP initialize: PASS (no inferior launched)'); vim.cmd('qa!')
else print('GDB DAP initialize failed, exit=' .. tostring(result.code)); print(result.stderr or ''); vim.cmd('cquit 1') end

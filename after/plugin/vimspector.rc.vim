

lua << EOF
-- mapping
vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")
vim.keymap.set("n", "<F10>", ":lua require'dap'.step_over()<CR>")
vim.keymap.set("n", "<F11>", ":lua require'dap'.step_into()<CR>")
vim.keymap.set("n", "<F12>", ":lua require'dap'.step_out()<CR>")
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint'))<CR>")
vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakpoint(nil,nil, vim.fn.input('Lorem')))<CR>")
vim.keymap.set("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>")

local dap = require('dap')

dap.adapters.coreclr = {
  type = 'executable',
  command = 'C:/Install/netcoredbg/netcoredbg',
  args = {'--interpreter=vscode'}
}

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
        return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    end,
  },
}

local dapui = require('dapui')
dapui.setup()
vim.keymap.set("n", "<leader>ui", ":lua require'dapui'.open()<CR>")

require("nvim-dap-virtual-text").setup()

EOF

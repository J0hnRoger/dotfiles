if !exists('g:loaded_telescope') | finish | endif

nnoremap <silent> ;f <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <silent> ;r <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <silent> \\ <cmd>Telescope buffers<cr>
nnoremap <silent> ;; <cmd>Telescope help_tags<cr>
nnoremap <leader>dd <cmd>Telescope lsp_document_diagnostics<cr>
nnoremap <leader>dD <cmd>Telescope lsp_workspace_diagnostics<cr>
nnoremap <leader>xx <cmd>Telescope lsp_code_actions<cr>
nnoremap <leader>fu'<cmd> Telescope lsp_references<cr>
nnoremap <leader>gd'<cmd> Telescope lsp_definitions<cr>

lua << EOF
function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup{
  defaults = {
    file_ignore_patterns = {
      "node_modules/*",
      "Library/*",
      "obj/*",
      "Temp/*"
    },
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
  }
}
EOF


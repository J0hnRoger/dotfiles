" let g:OmniSharp_server_path = 'C:\Install\OmniSharp.exe'

let s:using_snippets = 1

let g:OmniSharp_popup_position = 'peek'
let g:OmniSharp_popup_options = {
      \'winblend': 30,
      \'winhl': 'Normal:Normal,FloatBorder:ModeMsg',
      \'border': 'rounded', }

let g:OmniSharp_popup_mappings = {
      \'sigNext': '<C-n>',
      \'sigPrev': '<C-p>',
      \'pageDown': ['<C-f>', '<PageDown>'],
      \'pageUp': ['<C-b>', '<PageUp>'], }

if s:using_snippets
  let g:OmniSharp_want_snippet = 1
endif

let g:OmniSharp_highlight_groups = {
      \'ExcludedCode': 'NonText' }


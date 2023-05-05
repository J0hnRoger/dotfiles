
lua << EOF
require('nvim-test').setup{
  term = "terminal",
  direction = "horizontal",
  width = 48,
  keep_one = false
}
EOF

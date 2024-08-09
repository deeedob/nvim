local utils = require "ddob.utils"

-- don't inden't labels (fixes indenting on '::')
vim.opt_local.cinoptions:append "L0"

vim.opt_local.commentstring = "// %s"

vim.keymap.set("n", "<leader>cDq", function()
  utils.search_current_web "https://doc.qt.io/qt-6/search-results.html?q="
end, { desc = "Code Docs [Q]t", buffer = 0 })

vim.keymap.set("n", "<leader>cDr", function()
  utils.search_current_web "https://en.cppreference.com/mwiki/index.php?title=Special%%3ASearch&search="
end, { desc = "Code Docs Cpp[R]eference", buffer = 0 })

vim.keymap.set(
  "n",
  "<leader>ll",
  "<cmd>ClangdSwitchSourceHeader<cr>",
  { desc = "Switch Source/Header (C/C++)", buffer = 0 }
)

vim.keymap.set(
  "n",
  "<leader>lA",
  "<cmd>ClangdAST<cr>",
  { desc = "AST toggle (C/C++)", buffer = 0 }
)

vim.keymap.set(
  "n",
  "<leader>ui",
  "<cmd>ClangdToggleInlayHints<cr>",
  { desc = "LSP Toggle Inlay Hints (C/C++)", buffer = 0 }
)


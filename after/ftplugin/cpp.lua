vim.api.nvim_set_option_value("tabstop", 4, {})

-- don't inden't labels (fixes indenting on '::')
vim.opt_local.cinoptions:append "L0"

vim.opt_local.commentstring = "// %s"

vim.keymap.set("n", "<leader>cDq", function()
  require("utils.functions").search_current_web "https://doc.qt.io/qt-6/search-results.html?q=%s"
end, { desc = "Code Docs [Q]t", buffer = 0 })

vim.keymap.set("n", "<leader>cDr", function()
  require("utils.functions").search_current_web "https://duckduckgo.com/?q=%s+site:en.cppreference.com"
end, { desc = "Code Docs Cpp[R]eference", buffer = 0 })

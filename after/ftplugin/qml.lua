vim.api.nvim_set_option_value("tabstop", 4, {})

vim.keymap.set("n", "<leader>cDq", function()
  require("utils.functions").search_current_web("https://doc.qt.io/qt-6/search-results.html?q=%s")
end, { desc = "Qt docs search", buffer = 0, silent = true })

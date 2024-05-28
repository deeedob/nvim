local utils = require("next.utils")

-- don't inden't labels (fixes indenting on '::')
vim.opt.cinoptions:append("L0")

vim.keymap.set("n", "<leader>cDq", function()
	utils.search_current_web("https://doc.qt.io/qt-6/search-results.html?q=")
end, { desc = "Code Docs [Q]t", buffer = 0 })

vim.keymap.set("n", "<leader>cDr", function()
	utils.search_current_web("https://en.cppreference.com/mwiki/index.php?title=Special%%3ASearch&search=")
end, { desc = "Code Docs Cpp[R]eference", buffer = 0 })


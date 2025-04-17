local utils = require("shared.utils")

vim.api.nvim_set_option_value('tabstop', 4, {})

vim.keymap.set("n", "<leader>cDq", function()
	utils.search_current_web("https://doc.qt.io/qt-6/search-results.html?q=")
end, { desc = "Code Docs [Q]t", buffer = 0 })

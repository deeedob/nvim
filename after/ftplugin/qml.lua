local utils = require("ddob.utils")

vim.keymap.set("n", "<leader>cDq", function()
	utils.search_current_web("https://doc.qt.io/qt-6/search-results.html?q=")
end, { desc = "Code Docs [Q]t", buffer = 0 })

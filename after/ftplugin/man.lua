vim.wo.number = false
vim.wo.relativenumber = false
vim.wo.list = false
vim.wo.wrap = false
vim.bo.buflisted = true

vim.keymap.set('n', '<CR>', '<C-]>', { noremap = true, silent = true, nowait = true, buffer = true })

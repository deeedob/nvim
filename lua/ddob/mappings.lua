local utils = require("ddob.utils")
local map = vim.keymap.set

map("t", "jk", "<c-\\><c-n>", { desc = "Enter normal mode" })
map("i", "jk", "<ESC>", { desc = "Enter normal mode" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Focus left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window", remap = true })

-- Terminal navigation
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Focus left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Focus lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Focus upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Focus right window" })

-- Resize
map("n", "<S-Up>", "<cmd>resize +3<cr>", { desc = "Increase window height" })
map("n", "<S-Down>", "<cmd>resize -3<cr>", { desc = "Decrease window height" })
map("n", "<S-Left>", "<cmd>vertical resize -3<cr>", { desc = "Decrease window width" })
map("n", "<S-Right>", "<cmd>vertical resize +3<cr>", { desc = "Increase window width" })

-- Better up/down (deals with word wrap)
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move lines
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move up" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move down" })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move up" })
map("x", "<A-j>", ":move '>+1<CR>gv-gv", { desc = "Move up" })
map("x", "<A-k>", ":move '<-2<CR>gv-gv", { desc = "Move down" })

-- Stay in indent mode, move text up and down
map("v", "<", "<gv", { desc = "Increase indent" })
map("v", ">", ">gv", { desc = "Decrease indent" })

-- cycle through buffers
map("n", "H", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "L", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Lazy left - right
-- map("n", "H", "^", { desc = "Lazy left" })
-- map("n", "L", "$", { desc = "Lazy right" })

-- various
map("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit all buffers" })
map("n", "C", ":b#|bd#<cr>", { desc = "Close current buffer" })
map("n", "D", ":bd<cr>", { desc = "Delete current buffer" })
map("i", "<C-BS>", "<C-W>", { desc = "Remove word before", noremap = true })
map("n", "<leader>w", "<cmd>silent write<cr>", { desc = "Save the current file" })

-- TODO: Enable ft specific.
map(
    "n", "<leader>kq",
    function()
        utils.search_current_web("https://doc.qt.io/qt-6/search-results.html?q=")
    end,
    { desc = "Search in Qt docs", silent = true }
)

map(
    "n", "<leader>kr",
    function()
        utils.search_current_web("https://en.cppreference.com/mwiki/index.php?title=Special%%3ASearch&search=")
    end,
    { desc = "Search in CppReference docs", silent = true }
)

-- Delete into blackhole register
-- vim.keymap.set({ "n", "x" }, "x", '"_x')
-- vim.keymap.set({ "n", "x" }, "X", '"_d')

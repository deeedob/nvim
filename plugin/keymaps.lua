local map = vim.keymap.set
local utils = require("ddob.utils")

-- normal mode
map("t", "<Esc><Esc>", "<c-\\><c-n>", { desc = "Enter normal mode" })
map("i", "jk", "<ESC>", { desc = "Enter normal mode" })

-- window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Focus left window", remap = true, silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window", remap = true, silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window", remap = true, silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window", remap = true, silent = true })

-- terminal navigation
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Focus left window", silent = true })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Focus lower window", silent = true })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Focus upper window", silent = true })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Focus right window", silent = true })

-- Resize
map({ "n" }, "<S-Left>", function()
	utils.change_width("left")
end, { desc = "Increase Left", silent = true })
map({ "n" }, "<S-Right>", function()
	utils.change_width("right")
end, { desc = "Increase Right", silent = true })
map({ "n" }, "<S-Up>", function()
	utils.change_width("up")
end, { desc = "Increase Up", silent = true })
map({ "n" }, "<S-Down>", function()
        utils.change_width("down")
end, { desc = "Increase Down", silent = true })

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

-- Better up/down (deals with word wrap)
if vim.opt.wrap:get() then
  map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
  map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
  map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
  map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
end

map("n", "<CR>", function()
  ---@diagnostic disable-next-line: undefined-field
  if vim.opt.hlsearch:get() then
    vim.cmd.nohl()
    return ""
  else
    return "<CR>"
  end
end, { expr = true })

map("n", "]d", vim.diagnostic.goto_next)
map("n", "[d", vim.diagnostic.goto_prev)

-- buffers
map("n", "H", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "L", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bm", ":tabnew %<cr>", { desc = "Buffer fullscreen" })
map("n", "C", ":b#|bd#<cr>", { desc = "Close current buffer" })
map("n", "D", ":bd<cr>", { desc = "Delete current buffer" })
map("n", "+", "<C-w>=", { desc = "Equalize buffers" })

-- various
map("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit all buffers" })
map("i", "<C-BS>", "<C-W>", { desc = "Remove word before", noremap = true })
map("n", "<leader>w", "<cmd>silent write<cr>", { desc = "Save the current file" })

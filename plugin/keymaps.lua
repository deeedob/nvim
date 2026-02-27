local map = vim.keymap.set
local buf = require("utils.buffer")

-- ── Mode escape ───────────────────────────────────────────────────────────────
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Enter normal mode" })
map("i", "jk", "<Esc>", { desc = "Enter normal mode" })

-- ── Window navigation ─────────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Focus left window", remap = true, silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window", remap = true, silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window", remap = true, silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window", remap = true, silent = true })

map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Focus left window", silent = true })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Focus lower window", silent = true })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Focus upper window", silent = true })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Focus right window", silent = true })

-- ── Window resize ─────────────────────────────────────────────────────────────
map("n", "<S-Left>", function()
  require("utils.window").change_width("left")
end, { desc = "Resize window left", silent = true })
map("n", "<S-Right>", function()
  require("utils.window").change_width("right")
end, { desc = "Resize window right", silent = true })
map("n", "<S-Up>", function()
  require("utils.window").change_width("up")
end, { desc = "Resize window up", silent = true })
map("n", "<S-Down>", function()
  require("utils.window").change_width("down")
end, { desc = "Resize window down", silent = true })

map("n", "+", "<C-w>=", { desc = "Equalize windows", silent = true })

-- ── Navigation ────────────────────────────────────────────────────────────────

-- Wrap-aware j/k (expr; honours count for jumplist-friendly moves)
map(
  { "n", "x" },
  "j",
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, silent = true, desc = "Down (wrap-aware)" }
)
map(
  { "n", "x" },
  "k",
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, silent = true, desc = "Up (wrap-aware)" }
)
map(
  { "n", "x" },
  "<Down>",
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, silent = true, desc = "Down (wrap-aware)" }
)
map(
  { "n", "x" },
  "<Up>",
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, silent = true, desc = "Up (wrap-aware)" }
)

-- Keep cursor centred when scrolling or jumping through search matches
map("n", "n", "nzzzv", { desc = "Next match (centred)", silent = true })
map("n", "N", "Nzzzv", { desc = "Prev match (centred)", silent = true })

-- Goto file under cursor (supports path:line:col notation)
map(
  "n",
  "gf",
  buf.goto_file_under_cursor,
  { desc = "Goto file (path:line:col)", noremap = true, silent = true }
)

-- ── Search ────────────────────────────────────────────────────────────────────

-- <CR> clears hlsearch when active; otherwise behaves normally
map("n", "<CR>", function()
  if vim.v.hlsearch == 1 then
    vim.cmd.nohlsearch()
    return ""
  end
  return "<CR>"
end, { expr = true, desc = "Clear hlsearch / confirm" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear hlsearch", silent = true })

-- Search/replace word under cursor (pre-filled, cursor before flags)
map(
  "n",
  "<leader>rw",
  ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
  { desc = "Replace word under cursor" }
)

-- ── Editing ───────────────────────────────────────────────────────────────────

-- Line movement
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down", silent = true })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up", silent = true })
map("i", "<A-j>", "<Esc><cmd>m .+1<cr>==gi", { desc = "Move line down", silent = true })
map("i", "<A-k>", "<Esc><cmd>m .-2<cr>==gi", { desc = "Move line up", silent = true })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up", silent = true })
map("x", "<A-j>", ":move '>+1<cr>gv-gv", { desc = "Move selection down", silent = true })
map("x", "<A-k>", ":move '<-2<cr>gv-gv", { desc = "Move selection up", silent = true })

-- Indent and stay in visual mode
map("v", "<", "<gv", { desc = "Indent left", silent = true })
map("v", ">", ">gv", { desc = "Indent right", silent = true })

-- Join line without moving cursor
map("n", "J", "mzJ`z", { desc = "Join line (keep cursor position)", silent = true })

-- Delete word before cursor in insert mode (mirrors <C-w> but for terminal users)
map("i", "<C-BS>", "<C-W>", { desc = "Delete word before cursor", noremap = true })

-- ── Diagnostics ───────────────────────────────────────────────────────────────
map("n", "]d", function()
  buf.diag_jump(1)
end, { desc = "Next diagnostic", silent = true })
map("n", "[d", function()
  buf.diag_jump(-1)
end, { desc = "Prev diagnostic", silent = true })
map("n", "D", function()
  buf.diag_open("line")
end, { desc = "Diagnostic (line)", silent = true })

-- ── Folds ─────────────────────────────────────────────────────────────────────
map("n", "F", function()
  if vim.fn.foldlevel(".") > 0 then
    vim.cmd("normal! za")
  end
end, { desc = "Toggle fold", noremap = true, silent = true })

-- ── Quickfix ──────────────────────────────────────────────────────────────────
map("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix", silent = true })
map("n", "[q", "<cmd>cprev<cr>zz", { desc = "Prev quickfix", silent = true })
map("n", "]Q", "<cmd>clast<cr>zz", { desc = "Last quickfix", silent = true })
map("n", "[Q", "<cmd>cfirst<cr>zz", { desc = "First quickfix", silent = true })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Open quickfix list", silent = true })

-- ── Buffer management ─────────────────────────────────────────────────────────
map("n", "H", "<cmd>bprevious<cr>", { desc = "Prev buffer", silent = true })
map("n", "L", "<cmd>bnext<cr>", { desc = "Next buffer", silent = true })
map("n", "C", "<cmd>b#|bd#<cr>", { desc = "Close current buffer", silent = true })
map("n", "<leader>bm", "<cmd>tabnew %<cr>", { desc = "Buffer monocle (new tab)", silent = true })
map("n", "<leader>be", buf.open_in_file_explorer, {
  desc = "Explore file location",
  silent = true,
})
map(
  "n",
  "<leader>by",
  buf.copy_file_to_clipboard,
  { desc = "Yank file to clipboard", silent = true }
)

-- ── Misc ──────────────────────────────────────────────────────────────────────
map("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit all", silent = true })
map("n", "<leader>w", "<cmd>silent write<cr>", { desc = "Save file", silent = true })
map("n", "dd", function()
  return vim.api.nvim_get_current_line():match("^%s*$") and '"_dd' or "dd"
end, { expr = true, desc = "Delete line (skip register if blank)" })

map("n", "<leader>ur", function()
  local name = vim.g.colors_name or "ddob-kanagawa"
  vim.cmd("silent! colorscheme " .. name)
  vim.notify("Reloaded colorscheme: " .. name)
end, { desc = "Reload colorscheme", silent = true })

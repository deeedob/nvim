local map = vim.keymap.set

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

map("n", "gf", function ()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  col = col + 1 -- nvim_win_get_cursor is 0-indexed for columns
  -- Get current line and next line (for wrapped text)
  local lines = vim.api.nvim_buf_get_lines(0, row - 1, row + 1, false)
  local text = table.concat(lines, "\n")
  -- Find the word/path under cursor by expanding outward
  -- Look for continuous non-whitespace that might be a path
  local line = lines[1]
  -- Find start of path (go backward from cursor)
  local start_pos = col
  while start_pos > 1 and line:sub(start_pos - 1, start_pos - 1):match("[^%s]") do
    start_pos = start_pos - 1
  end
  -- Find end of path (go forward from cursor)
  local end_pos = col
  while end_pos <= #line and line:sub(end_pos, end_pos):match("[^%s]") do
    end_pos = end_pos + 1
  end
  -- Extract the token under cursor
  local token = line:sub(start_pos, end_pos - 1)
  -- Try to parse "path:line:col" or "path:line" or just "path"
  local path, lnum, cnum
  -- Pattern 1: path:line:col
  path, lnum, cnum = token:match("^(.+):(%d+):(%d+)")
  -- Pattern 2: path:line
  if not path then
    path, lnum = token:match("^(.+):(%d+)")
  end
  -- Pattern 3: just path
  if not path then
    path = token:match("^(.+)$")
  end
  if not path or path == "" then
    vim.notify("No file path found under cursor", vim.log.levels.WARN)
    return
  end
  -- Expand path (handles ~, ., .., $VAR)
  path = vim.fn.expand(path)
  -- If path is not absolute, try to find it relative to current file or cwd
  if not vim.startswith(path, "/") then
    local current_file_dir = vim.fn.expand("%:p:h")
    local candidates = {
      path,  -- relative to cwd
      current_file_dir .. "/" .. path,  -- relative to current file
    }
    local found = false
    for _, candidate in ipairs(candidates) do
      if vim.fn.filereadable(candidate) == 1 then
        path = candidate
        found = true
        break
      end
    end
    if not found then
      vim.notify("File not found: " .. path, vim.log.levels.WARN)
      return
    end
  else
    -- Absolute path - check if it exists
    if vim.fn.filereadable(path) == 0 then
      vim.notify("File not readable: " .. path, vim.log.levels.WARN)
      return
    end
  end
  -- Find the best window to open the file in
  local current_buf = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
  local is_terminal = vim.bo[current_buf].buftype == "terminal"

  if is_terminal then
    -- Jump to the previous window (usually your main editor)
    vim.cmd("wincmd p")
  end
  -- Open the file
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  -- Jump to line and column if specified
  if lnum then
    local line_num = tonumber(lnum)
    local col_num = cnum and (tonumber(cnum) - 1) or 0  -- columns are 0-indexed
    -- Ensure we don't go past the end of the file
    local line_count = vim.api.nvim_buf_line_count(0)
    if line_num > line_count then
      line_num = line_count
    end
    vim.api.nvim_win_set_cursor(0, { line_num, col_num })
    -- Center the screen on the target line
    vim.cmd("normal! zz")
  end
end, { desc = "Goto file", noremap = true, silent = true } )

-- Resize
map({ "n" }, "<S-Left>", function()
  require("utils.window").change_width "left"
end, { desc = "Increase Left", silent = true })
map({ "n" }, "<S-Right>", function()
  require("utils.window").change_width "right"
end, { desc = "Increase Right", silent = true })
map({ "n" }, "<S-Up>", function()
  require("utils.window").change_width "up"
end, { desc = "Increase Up", silent = true })
map({ "n" }, "<S-Down>", function()
  require("utils.window").change_width "down"
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
  if vim.opt.hlsearch:get() then
    vim.cmd.nohl()
    return ""
  else
    return "<CR>"
  end
end, { expr = true })

-- Diagnostics

local diag_focus_id = "diagnostic_float"
local function diag_open(scope)
  vim.diagnostic.open_float(nil, {
    scope = scope or "cursor",
    focusable = true,
    focus_id = diag_focus_id,
    source = "if_many",
    close_events = { "CursorMoved", "CursorMovedI", "InsertEnter", "InsertEnter" },
  })
end

local function diag_jump(count)
  local jumped = vim.diagnostic.jump({ count = count, wrap = true })
  if jumped then
    vim.schedule(function() diag_open("cursor") end)
  end
end

map("n", "]d", function()
  diag_jump(1)
end, { desc = "Next diagnostic" }
)
map("n", "[d", function()
  diag_jump(-1)
end, { desc = "Prev diagnostic" }
)
map("n", "D", function()
  diag_open("line")
end, { desc = "[D]iagnostic Line"}
)

map("n", "F", function()
  if vim.fn.foldlevel(".") > 0 then
    vim.cmd("normal! za")
  end
end, { noremap = true, silent = true })

-- buffers
map("n", "H", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "L", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bm", ":tabnew %<cr>", { desc = "Buffer fullscreen" })
map("n", "C", ":b#|bd#<cr>", { desc = "Close current buffer" })
-- map("n", "D", ":bd<cr>", { desc = "Delete current buffer" })
map("n", "+", "<C-w>=", { desc = "Equalize buffers" })

-- various
map("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit all buffers" })
map("i", "<C-BS>", "<C-W>", { desc = "Remove word before", noremap = true })
map("n", "<leader>w", "<cmd>silent write<cr>", { desc = "Save the current file" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Stop highlighting"})

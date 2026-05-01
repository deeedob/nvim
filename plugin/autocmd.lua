local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup("config", { clear = true })

-- ── Quick close with q ────────────────────────────────────────────────────────
-- A buffer-local `q` mapping that closes the window without writing changes.
autocmd("FileType", {
  group = augroup,
  pattern = {
    "help",
    "man",
    "lspinfo",
    "checkhealth",
    "qf",
    "query",
    "notify",
    "dap-float",
    "dap-view",
    "dap-view-term",
    "dap-repl",
    "fugitive",
  },
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>q!<cr>", {
      silent = true,
      nowait = true,
      buffer = args.buf,
      desc = "Close window",
    })
  end,
})

-- ── Fugitive buffers should not appear in the buffer list ─────────────────────
autocmd("FileType", {
  group = augroup,
  pattern = { "fugitive", "fugitiveblame" },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
  end,
})

-- ── Strip trailing whitespace before saving ───────────────────────────────────
autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    -- Preserve cursor position across the substitution
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[silent! %s/\s\+$//e]])
    pcall(vim.api.nvim_win_set_cursor, 0, pos)
  end,
})

-- ── Prevent 'o' from continuing comments on new lines ────────────────────────
-- formatoptions is reset by many ftplugins; enforce our preference everywhere.
autocmd("BufWinEnter", {
  group = augroup,
  callback = function()
    vim.opt_local.formatoptions:remove("o")
  end,
})

-- ── Equalise splits on terminal resize ───────────────────────────────────────
autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.cmd("wincmd =")
  end,
})

-- ── Re-read files that may have changed when Neovim regains focus ─────────────
autocmd({ "FocusGained", "VimResume" }, {
  group = augroup,
  callback = function()
    vim.cmd("checktime")
  end,
})

-- ── Briefly highlight yanked text ────────────────────────────────────────────
autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ timeout = 175 })
  end,
})

-- ── Restore last cursor position when opening a buffer ───────────────────────
autocmd("BufReadPost", {
  group = augroup,
  callback = function(event)
    local excluded = { "gitcommit", "NeogitCommitMessage" }
    local buf = event.buf
    if vim.tbl_contains(excluded, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Notify when a macro recording starts / finishes ──────────────────────────
autocmd("RecordingEnter", {
  group = augroup,
  callback = function()
    vim.notify("Recording macro @ [" .. vim.fn.reg_recording() .. "]")
  end,
})

autocmd("RecordingLeave", {
  group = augroup,
  callback = function()
    vim.notify("Finished macro @ [" .. vim.fn.reg_recording() .. "]")
  end,
})

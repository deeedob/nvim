local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup("config", { clear = false })

-- Quick close
autocmd("FileType", {
  group = augroup,
  pattern = { "help", "man", "lspinfo", "checkhealth", "qf", "query", "notify" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set(
      "n",
      "q",
      "<cmd>close<cr>",
      { buffer = event.buf, silent = true }
    )
  end,
})

-- Remove trailing whitespaces
autocmd("BufWritePre", { group = augroup, command = "%s/\\s\\+$//e" })

autocmd("BufWinEnter", {
  group = augroup,
  command = "setlocal formatoptions-=o",
})

-- Check if buffers changes upon regaining focus
vim.api.nvim_create_autocmd(
  { "FocusGained", "VimResume" },
  { command = "checktime", group = augroup }
)

-- Fancy yank
autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank {
      timeout = 175,
    }
  end,
})

-- Go to the last loc when opening a buffer
autocmd("BufReadPost", {
  group = augroup,
  callback = function(event)
    local exclude = { "gitcommit", "NeogitCommitMessage" }
    local buf = event.buf
    if
      vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc
    then
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

-- Sync syntax when not editing text
autocmd("CursorHold", {
  callback = function(event)
    if vim.api.nvim_get_option_value("syntax", { buf = event.buf }) ~= "" then
      vim.api.nvim_command "syntax sync fromstart"
    end

    if vim.lsp.semantic_tokens then
      vim.lsp.semantic_tokens.force_refresh(event.buf)
    end
  end,
  group = augroup,
})

autocmd("RecordingEnter", {
  group = augroup,
  callback = function(event)
    local msg = "Recording macro at reg[" .. vim.fn.reg_recording() .. "]"
    vim.notify(msg)
  end,
})

autocmd("RecordingLeave", {
  group = augroup,
  callback = function(event)
    local msg = "Finished recording at reg[" .. vim.fn.reg_recording() .. "]"
    vim.notify(msg)
  end,
})

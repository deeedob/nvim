-- ── ToggleListChars ───────────────────────────────────────────────────────────
vim.api.nvim_create_user_command("ToggleListChars", function()
  local enabled = not vim.opt.list:get()
  vim.opt.list = enabled
  if enabled then
    vim.opt.listchars = "trail:·,tab:»·,space:·,lead:·"
  end
end, { desc = "Toggle list characters" })

vim.keymap.set("n", "<leader>uc", "<cmd>ToggleListChars<cr>", {
  desc = "Toggle list chars",
  silent = true,
})

-- ── CompactSpaces ───────────────────────────────────────────────────────────
vim.api.nvim_create_user_command("CompactSpaces", function(opts)
  local start_line = opts.line1 - 1
  local end_line = opts.line2

  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)

  for i, line in ipairs(lines) do
    -- collapse multiple spaces into one
    line = line:gsub("%s+", " ")

    -- remove space before parentheses
    line = line:gsub("%s*%(", "(")

    -- remove space before commas
    line = line:gsub("%s*,%s*", ", ")

    -- trim leading/trailing spaces
    line = line:gsub("^%s+", ""):gsub("%s+$", "")

    lines[i] = line
  end

  vim.api.nvim_buf_set_lines(0, start_line, end_line, false, lines)
end, {
  range = true,
  desc = "Compact spaces in selected lines",
})

vim.keymap.set("v", "<leader>us", ":CompactSpaces<CR>", {
  desc = "Compact spaces in selection",
  silent = true,
})

-- ── WipeWindowlessBufs ────────────────────────────────────────────────────────
vim.api.nvim_create_user_command("WipeWindowlessBufs", function()
  local count = 0
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = true })) do
    if info.changed == 0 and #info.windows == 0 then
      vim.api.nvim_buf_delete(info.bufnr, { force = false, unload = false })
      count = count + 1
    end
  end
  if count > 0 then
    vim.notify(("Wiped %d windowless buffer(s)"):format(count))
  end
end, { desc = "Wipe all buffers not shown in a window" })

vim.keymap.set("n", "<leader>bo", "<cmd>WipeWindowlessBufs<cr>", {
  desc = "Wipe windowless buffers",
  silent = true,
})

-- ── I: inspect/print a Lua expression ────────────────────────────────────────
vim.api.nvim_create_user_command("I", function(args)
  vim.print(vim.fn.luaeval(args.args))
end, { nargs = 1, desc = "Inspect a Lua expression" })

-- ── Redir: capture ex-command output into a new buffer ───────────────────────
vim.api.nvim_create_user_command("Redir", function(ctx)
  local lines =
    vim.split(vim.api.nvim_exec2(ctx.args, { output = true }).output, "\n", { plain = true })
  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.opt_local.modified = false
end, { nargs = "+", complete = "command", desc = "Capture command output into buffer" })

-- ── SpellLang: get/set the spell language for the current buffer ──────────────
vim.api.nvim_create_user_command("SpellLang", function(opts)
  if opts.args ~= "" then
    vim.bo.spelllang = opts.args
  end
  vim.print(vim.bo.spelllang)
end, { nargs = "?", desc = "Get/set spell language" })

-- ── VerboseToggle: toggle Neovim verbose output ───────────────────────────────
vim.api.nvim_create_user_command("VerboseToggle", function(opts)
  local val = opts.args ~= "" and tonumber(opts.args) or nil
  if val then
    vim.o.verbose = val
  else
    vim.o.verbose = vim.o.verbose > 0 and 0 or 1
  end
  vim.lsp.log.set_level(vim.o.verbose > 0 and vim.log.levels.INFO or vim.log.levels.WARN)
  vim.print("Verbose: " .. (vim.o.verbose > 0 and "on" or "off"))
end, { desc = "Toggle verbose output", nargs = "*" })

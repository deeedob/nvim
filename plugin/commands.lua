-- Toggle List Characters Command
vim.api.nvim_create_user_command("ToggleListChars", function()
  vim.opt.list = not vim.opt.list:get()
  if vim.opt.list then
    vim.opt.listchars = "trail:·,tab:»·,space:·,lead:·"
  end
end, { desc = "Toggle list characters" })

vim.keymap.set(
  "n",
  "<leader>uc",
  ":ToggleListChars<cr>",
  { desc = "List Chars Toggle", remap = true }
)

vim.api.nvim_create_user_command("WipeWindowlessBufs", function()
  local bufinfos = vim.fn.getbufinfo { buflisted = true }
  vim.tbl_map(function(bufinfo)
    if
      bufinfo.changed == 0 and (not bufinfo.windows or #bufinfo.windows == 0)
    then
      vim.api.nvim_buf_delete(bufinfo.bufnr, { force = false, unload = false })
    end
  end, bufinfos)
end, { desc = "Wipeout all buffers not shown in a window" })
vim.keymap.set(
  "n",
  "<leader>bo",
  ":WipeWindowlessBufs<cr>",
  { desc = "Other Buffs close", remap = true }
)

vim.api.nvim_create_user_command("I", function(args)
  local evaluated_obj = vim.fn.luaeval(args.args)
  vim.print(evaluated_obj)
end, { nargs = 1 })

vim.api.nvim_create_user_command("Redir", function(ctx)
  local lines =
    vim.split(vim.api.nvim_exec(ctx.args, true), "\n", { plain = true })
  vim.cmd "new"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.opt_local.modified = false
end, { nargs = "+", complete = "command" })

vim.api.nvim_create_user_command("SpellLang", function(opts)
  local lang = opts.args
  if lang and lang ~= "" then
    vim.bo.spelllang = lang
  end
  vim.print(vim.bo.spelllang)
end, { nargs = "?", desc = "Enable/Disable spelling" })

vim.api.nvim_create_user_command("VerboseToggle", function(opts)
  local val = opts.args ~= "" and tonumber(opts.args) or nil
  if val then
    vim.o.verbose = val
  else
    vim.o.verbose = vim.o.verbose > 0 and 0 or 1
  end
  vim.lsp.log.set_level(vim.o.verbose > 0 and vim.log.levels.INFO or vim.log.levels.WARN)
  vim.print(" Verbose: " .. (vim.o.verbose > 0 and "true" or "false"))
end, { desc = "Enable/Disable verbose output", nargs = "*" })

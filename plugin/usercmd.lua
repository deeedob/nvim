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


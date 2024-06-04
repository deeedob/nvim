require("dapui").setup {}
require("nvim-dap-virtual-text").setup {}

local dap = require "dap"
local dapui = require "dapui"

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end
dap.listeners.after["event_initialized"]["me"] = function()
  -- TODO: Sync with lsp.lua
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_clear_autocmds {
      buffer = buf,
      group = lsp_hover_augroup,
    }

    local keymaps = vim.api.nvim_buf_get_keymap(buf, "n")
    for _, keymap in pairs(keymaps) do
      if keymap.lhs == "K" then
        table.insert(keymap_restore, keymap)
        vim.api.nvim_buf_del_keymap(buf, "n", "K")
      end
    end
  end
  vim.api.nvim_set_keymap(
    "n",
    "K",
    '<Cmd>lua require("dap.ui.widgets").hover()<CR>',
    { silent = true }
  )
end

local sc = vim.api.nvim_get_hl(0, { name = "SignColumn", create = false })
local ap = vim.api.nvim_get_hl(0, { name = "PreProc", create = false })
vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
vim.api.nvim_set_hl(0, "DapIconGutter", { fg = ap.fg, bg = sc.bg })
local icons = {
  dap = {
    Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = { " " },
    BreakpointCondition = " ",
    BreakpointRejected = { " ", "DiagnosticError" },
    LogPoint = ".>",
  },
}
for name, sign in pairs(icons.dap) do
  sign = type(sign) == "table" and sign or { sign }
  vim.fn.sign_define("Dap" .. name, {
    text = sign[1],
    texthl = sign[2] or "DapIconGutter",
    linehl = "",
    numhl = "",
  })
end

local routes = {}
local hidden_text = {
  "%[w%]",
  "written",
  "fewer lines",
  "line less",
  "%d+ changes?;",
  "more lines?",
  "yanked",
  "%d+ lines?",
}
for _, msg in ipairs(hidden_text) do
  table.insert(routes, {
    filter = {
      event = "msg_show",
      kind = "",
      find = msg,
    },
    opts = { skip = true },
  })
end

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {
    presets = {
      lsp_doc_border = true,
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    views = {
      cmdline_popup = {
        position = { row = 10, col = "50%" },
        size = { width = 60, height = "auto" },
      },
      popupmenu = {
        relative = "editor",
        position = { row = 12, col = "50%" },
        size = { width = 60, height = 10 },
        border = { style = "rounded", padding = { 0, 1 } },
        win_options = {
          winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
        },
      },
    },
    routes = routes,
  },
}

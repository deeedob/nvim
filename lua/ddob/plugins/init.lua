return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
    end,
    config = function()
      local wk = require "which-key"
      wk.add {
        { "<leader>f", group = "[F]ind" },
        { "<leader>l", group = "[L]sp" },
        { "<leader>g", group = "[G]it" },
        { "<leader>u", group = "[U]ser Interface" },
        { "<leader>ug", group = "[G]it" },
        { "<leader>e", group = "[E]xplorer" },
        { "<leader>t", group = "[T]erminal" },
        { "<leader>d", group = "[D]debug" },
        { "<leader>b", group = "[B]buffer" },

        { "<leader>c", name = "[C]ode" },
        { "<leader>cD", name = "[D]ocs" },
      }
    end,
  },
}

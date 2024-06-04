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
      wk.setup {
        window = {
          winblend = 30,
          margin = { 0, 0, 0, 0 },
          padding = { 1, 1, 1, 1 },
        },
      }
      wk.register {
        ["<leader>f"] = { name = "[F]ind" },
        ["<leader>l"] = { name = "[L]sp" },
        ["<leader>g"] = { name = "[G]it" },
        ["<leader>u"] = { name = "[U]ser Interface" },
        ["<leader>ug"] = { name = "[G]it" },
        ["<leader>e"] = { name = "[E]xplorer" },
        ["<leader>t"] = { name = "[T]erminal" },
        ["<leader>d"] = { name = "[D]debug" },
        ["<leader>b"] = { name = "[B]buffer" },

        ["<leader>c"] = { name = "[C]ode" },
        ["<leader>cD"] = { name = "[D]ocs" },
      }
    end,
  },
  {
    "tjdevries/colorbuddy.nvim",
    config = function()
      require "ddob.colorscheme"
    end,
  },
}

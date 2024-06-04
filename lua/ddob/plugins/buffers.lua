return {
  {
    "nanozuki/tabby.nvim",
    event = "VimEnter",
    dependencies = {
      -- buffers are bound to tabs
      "tiagovla/scope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>bta", ":$tabnew<cr>", desc = "Add Tab" },
      { "<leader>bto", ":tabonly<cr>", desc = "Other Tabs Close" },
      { "<leader>btc", ":tabclose<cr>", desc = "Current Tab Close" },

      { "}", ":tabn<cr>", desc = "Tab Next" },
      { "{", ":tabp<cr>", desc = "Tab Prev" },

      { "]b", ":+tabmove<cr>", desc = "Tab Move Next" },
      { "[b", ":-tabmove<cr>", desc = "Tab Move Prev" },
    },
    config = function()
      require "ddob.tabby"
    end,
  },

  {
    "caenrique/swap-buffers.nvim",
    keys = {
      {
        "<leader>bh",
        function()
          require("swap-buffers").swap_buffers "h"
        end,
        desc = "Buffer Swap Left",
      },
      {
        "<leader>bj",
        function()
          require("swap-buffers").swap_buffers "j"
        end,
        desc = "Buffer Swap Down",
      },
      {
        "<leader>bk",
        function()
          require("swap-buffers").swap_buffers "k"
        end,
        desc = "Buffer Swap Top",
      },
      {
        "<leader>bl",
        function()
          require("swap-buffers").swap_buffers "l"
        end,
        desc = "Buffer Swap Right",
      },
    },
    opts = {
      ignore_filetypes = { "neo-tree", "toggleterm", "Trouble" },
    },
  },
}

return {

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require "ddob.lualine"
    end,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
  },

  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    config = function()
      require("incline").setup {
        window = {
          padding = 0,
          margin = { horizontal = 0, vertical = 0 },
        },
      }
    end,
  },
  -- Highlight other
  {
    "RRethy/vim-illuminate",
    opts = {
      delay = 750,
      large_filie_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
      min_count_to_highlight = 2,
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      vim.keymap.set("n", "[r", function()
        require("illuminate").goto_prev_reference()
      end, { desc = "Prev [r]eference" })
      vim.keymap.set("n", "]r", function()
        require("illuminate").goto_next_reference()
      end, { desc = "Next [r]eference" })
    end,
  },
  -- Smoth scrolling
  {
    "psliwka/vim-smoothie",
    event = "BufRead",
  },

  {
    "stevearc/dressing.nvim",
    opts = {},
  },
}

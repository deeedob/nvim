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
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    config = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "" })

      require("ufo").setup {
        provider_selector = function(bufnr, filetype, buftype)
          return { "treesitter", "indent" }
        end,
      }
    end,
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

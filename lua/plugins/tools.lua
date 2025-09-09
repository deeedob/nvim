return {
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      spec = {
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
      },
    },
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    opts = {
      mode = "exact",
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "flash treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "remote flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "treesitter search",
      },
    },
  },

  -- Buffer quick-access
  {
    "otavioschwanck/arrow.nvim",
    keys = {
      {
        ";",
        function()
          require("arrow.ui").openMenu()
        end,
        desc = "Flash",
      },
    },
    opts = {
      show_icons = true,
      separate_by_branch = true,
      separate_save_and_remove = true,
    },
  },

  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup {
        user_default_options = {
          names = false,
        },
      }
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  {
    "gbprod/yanky.nvim",
    dependencies = {
      { "kkharji/sqlite.lua" },
    },
    opts = {
      ring = { storage = "sqlite" },
      highlight = {
        timer = 250,
      },
    },
    keys = {
      {
        "<leader>y",
        function()
          require("telescope").extensions.yank_history.yank_history {}
        end,
        desc = "Yank History",
      },
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      {
        "p",
        "<Plug>(YankyPutAfter)",
        mode = { "n", "x" },
        desc = "Put yanked text after cursor",
      },
      {
        "P",
        "<Plug>(YankyPutBefore)",
        mode = { "n", "x" },
        desc = "Put yanked text before cursor",
      },
      {
        "<c-p>",
        "<Plug>(YankyPreviousEntry)",
        desc = "Select previous entry through yank history",
      },
      {
        "<c-n>",
        "<Plug>(YankyNextEntry)",
        desc = "Select next entry through yank history",
      },
      {
        "=p",
        "<Plug>(YankyPutAfterFilter)",
        desc = "Put after applying a filter",
      },
      {
        "=P",
        "<Plug>(YankyPutBeforeFilter)",
        desc = "Put before applying a filter",
      },
    },
  },

  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup {
        chunk = {
          enable = true,
        },
      }
    end,
  },

  {
    "NMAC427/guess-indent.nvim",
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

  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup()
      require("mini.pairs").setup {
        mappings = {
          ["`"] = {
            action = "closeopen",
            pair = "``",
            neigh_pattern = "[^\\`].",
            register = { cr = false },
          },
        },
      }
    end,
  },
}

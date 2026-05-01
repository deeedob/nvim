return {
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      spec = {
        { "<leader>f", group = "[F]ind" },
        { "<leader>l", group = "[L]SP" },
        { "<leader>g", group = "[G]it" },
        { "<leader>u", group = "[U]I" },
        { "<leader>ug", group = "[G]it signs" },
        { "<leader>t", group = "[T]erminal" },
        { "<leader>d", group = "[D]ebug" },
        { "<leader>b", group = "[B]uffer" },
        { "<leader>bt", group = "[T]abs" },
        { "<leader>c", group = "[C]ode" },
        { "<leader>cD", group = "[D]ocs" },
        { "<leader>cs", group = "[S]elect" },
      },
    },
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
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
        desc = "Arrow menu",
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
    lazy = false,
    config = function()
      require("colorizer").setup({
        user_default_options = {
          names = false,
        },
      })
    end,
  },

  -- {
  --   "folke/todo-comments.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {
  --     signs = true,
  --     keywords = {
  --       FIX = {
  --         icon = " ", -- icon used for the sign, and in search results
  --         color = "error", -- can be a hex color, or a named color (see below)
  --         alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
  --         -- signs = false, -- configure signs for some keywords individually
  --       },
  --       TODO = { icon = " ", color = "info" },
  --       HACK = { icon = " ", color = "warning" },
  --       WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
  --       PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
  --       NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
  --       TEST = {
  --         icon = "⏲ ",
  --         color = "test",
  --         alt = { "TESTING", "PASSED", "FAILED" },
  --       },
  --       Qt7 = { icon = "Q", color = "info", alt = { "### Qt7", "QTBUG-" }}
  --     },
  --   },
  -- },

  {
    "gbprod/yanky.nvim",
    lazy = true,
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
        "<cmd>YankyRingHistory<cr>",
        mode = { "n", "x" },
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
      require("hlchunk").setup({
        chunk = {
          enable = true,
        },
      })
    end,
  },

  {
    "NMAC427/guess-indent.nvim",
  },

  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    config = function()
      require("incline").setup({
        window = {
          padding = 0,
          margin = { horizontal = 0, vertical = 0 },
        },
      })
    end,
  },
  -- Highlight other
  {
    "RRethy/vim-illuminate",
    lazy = false,
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
          require("swap-buffers").swap_buffers("h")
        end,
        desc = "Buffer Swap Left",
      },
      {
        "<leader>bj",
        function()
          require("swap-buffers").swap_buffers("j")
        end,
        desc = "Buffer Swap Down",
      },
      {
        "<leader>bk",
        function()
          require("swap-buffers").swap_buffers("k")
        end,
        desc = "Buffer Swap Top",
      },
      {
        "<leader>bl",
        function()
          require("swap-buffers").swap_buffers("l")
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
      require("mini.pairs").setup({
        mappings = {
          ["`"] = {
            action = "closeopen",
            pair = "``",
            neigh_pattern = "[^\\`].",
            register = { cr = false },
          },
        },
      })
    end,
  },
  {
    "t-troebst/perfanno.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
      "PerfAnnotate",
      "PerfLoadFlameGraph",
    },
    keys = {
      {
        "<leader>cp",
        function()
          require("utils.cmake_profile").profile_current_target()
        end,
        desc = "Code Profile",
      },
    },
    config = function()
      local perfanno = require("perfanno")
      local util = require("perfanno.util")

      perfanno.setup({
        line_highlights = util.make_bg_highlights(nil, "#ff6e40", 10),
        vt_highlight = util.make_fg_highlight("#ff6e40"),

        annotate_after_load = true,
        annotate_on_open = true,

        telescope = { enabled = false }, -- avoid telescope
      })

      vim.keymap.set("n", "<leader>pa", "<cmd>PerfAnnotate<cr>")
      vim.keymap.set("n", "<leader>pt", "<cmd>PerfToggleAnnotations<cr>")
    end,
  },
}

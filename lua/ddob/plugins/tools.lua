return {
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

}

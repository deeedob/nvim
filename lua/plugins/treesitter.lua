return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = "FileType",
    config = function()
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter.configs").setup({
        auto_install = true,
        ensure_installed = {
          "markdown",
          "markdown_inline",
          "html",
          "latex",
          "yaml",
          "regex",
          "bash",
        },
        modules = {},
        highlight = {
          enable = true,
          disable = function(lang, buf)
            local disabled_langs = {
              make = true,
              comment = require("utils.plugin").exists("todo-comments.nvim") and true or nil,
              cpp = true, -- treesitter can't work on macros w/o ';' ...
            }

            if disabled_langs[lang] then
              return true
            end

            local stats = vim.F.npcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            -- Disable for files larger than 1MB.
            return stats and stats.size > (1024 * 1024)
          end,
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<Enter>",
            node_incremental = "<Enter>",
            node_decremental = "<BS>",
          },
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "FileType",
    dependencies = { "nvim-treesitter" },
    cmd = { "TSContext" },
    keys = {
      {
        "<leader>uC",
        "<cmd>TSContext toggle<cr>",
        desc = "Treesitter Context Toggle",
      },
    },
    opts = {
      mode = "cursor",
      max_lines = 3,
    },
  },

  -- {
  --   "MeanderingProgrammer/render-markdown.nvim",
  --   -- dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
  --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
  --   dependencies = {
  --     "nvim-treesitter/nvim-treesitter",
  --     "nvim-tree/nvim-web-devicons",
  --   }, -- if you prefer nvim-web-devicons
  --   enabled = true,
  --   opts = {
  --     -- completions = { lsp = { enabled = true } },
  --     render_modes = true,
  --     --   heading = {
  --     --     left_pad = 1,
  --     --     right_pad = 1,
  --     -- },
  --   anti_conceal = {
  --       enabled = false,
  --     },
  --     overrides = {
  --       buftype = {
  --         nofile = {
  --           code = { left_pad = 0, right_pad = 0 },
  --         },
  --       },
  --     },
  --   },
  -- },
}

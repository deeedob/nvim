return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "c",
          "vimdoc",
          "lua",
          "markdown",
          "markdown_inline",
          "regex",
        },
        auto_install = true,
        sync_install = false,
        ignore_install = {},
        modules = {},
        highlight = {
          enable = true,
          disable = function(lang, buf)
            if lang == "cpp" or lang == "markdown" then
              return true
            end
            local max_filesize = 150 * 1024 -- 150 KB
            local ok, stats =
              pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
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
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    cmd = { "TSContextToggle" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
        "<leader>uC",
        "<cmd>TSContextToggle<cr>",
        desc = "Treesitter Context Toggle",
      },
    },
    init = function()
      -- TODO: update
      -- vim.cmd("highlight link TreesitterContext Comment")
      -- vim.cmd("highlight link TreesitterContextLineNumber Comment")
      -- vim.cmd("highlight link TreesitterContextSeparator Comment")
      -- vim.cmd("highlight link TreesitterContextBottom Comment")
    end,
    opts = {
      mode = "cursor",
      max_lines = 3,
    },
  },
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = "FileType",
    lazy = false,
    config = function()
      require("nvim-treesitter.install").prefer_git = true

      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.zsh = {
        install_info = {
          url = "https://github.com/georgeharker/tree-sitter-zsh",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "main",
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
        },
        filetype = "zsh",
      }

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
          "zsh",
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
}

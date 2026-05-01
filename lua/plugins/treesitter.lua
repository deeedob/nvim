return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    main = "nvim-treesitter",
    opts = {
      auto_install = true,
      ensure_installed = {
        "markdown",
        "markdown_inline",
        "html",
        -- "latex",
        "yaml",
        "regex",
        "bash",
        "zsh",
      },
    },
    init = function()
      require("nvim-treesitter.install").prefer_git = true

      local parser_config = require("nvim-treesitter.parsers")
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

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local buf = args.buf
          local lang = vim.bo[buf].filetype

          local disabled = {
            make = true,
            comment = require("utils.plugin").exists("todo-comments.nvim") and true or nil,
            cpp = true, -- treesitter can't work on macros w/o ';' ...
          }
          if disabled[lang] then
            return
          end

          local stats = vim.F.npcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if stats and stats.size > (1024 * 1024) then
            return
          end

          pcall(vim.treesitter.start, buf)
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
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

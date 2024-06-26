return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  config = function()
    local lint = require "lint"
    lint.linters.luacheck.args = {
      "--globals",
      "vim",
      "--formatter",
      "plain",
      "--codes",
      "--ranges",
      "-",
    }
    lint.linters_by_ft = {
      -- python = { "ruff" },
      cmake = { "cmakelint" },
      proto = { "buf_lint" },
      sh = { "shellcheck" },
      markdown = { "markdownlint" },
    }
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd(
      { "BufEnter", "BufWritePost", "BufNewFile", "InsertLeave" },
      {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      }
    )
  end,
}

return {

  {
    "stevearc/conform.nvim",
    opts = {
      format = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
      },
      formatters = {
        clang_format = {
          args = function()
            local default_clang = "file"
            local has_local_clang = vim.uv.fs_stat(".clang-format")
            if not has_local_clang then
              default_clang = "file:"
                .. os.getenv "HOME"
                .. "/.config/clangd/.clang-format"
            end
            return {
              "--assume-filename",
              "$FILENAME",
              "--style",
              default_clang,
            }
          end,
        },
      },
      formatters_by_ft = {
        lua = { "stylua" },
        cpp = { "clang_format" },
        cmake = { "cmake_format" },
        sh = { "shfmt" },
        rust = { "rustfmt" },
        proto = { "buf" },

        html = { "prettier" },
        htmldjango = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      },
    },
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format {
            async = true,
            lsp_fallback = false,
          }
        end,
        mode = { "n", "v" },
        desc = "[f]ormat buffer",
      },
      {
        "<leader>lg",
        function()
          local ignore_filetypes = { "lua" }
          if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.notify(
              "range formatting for "
                .. vim.bo.filetype
                .. " not working properly."
            )
            return
          end

          local hunks = require("gitsigns").get_hunks()
          if hunks == nil or next(hunks) == nil then
            vim.notify(
              "no git hunks to format",
              vim.log.levels.INFO,
              { title = "formating" }
            )
            return
          end

          local format = require("conform").format
          local function format_range()
            if next(hunks) == nil then
              vim.notify(
                "done formatting git hunks",
                vim.log.levels.INFO,
                { title = "formatting" }
              )
              return
            end
            local hunk = nil
            while
              next(hunks) ~= nil and (hunk == nil or hunk.type == "delete")
            do
              hunk = table.remove(hunks)
            end

            if hunk ~= nil and hunk.type ~= "delete" then
              local start = hunk.added.start
              local last = start + hunk.added.count
              -- nvim_buf_get_lines uses zero-based indexing -> subtract from last
              local last_hunk_line =
                vim.api.nvim_buf_get_lines(0, last - 2, last - 1, true)[1]
              local range = {
                start = { start, 0 },
                ["end"] = { last - 1, last_hunk_line:len() },
              }
              format(
                { range = range, async = true, lsp_fallback = true },
                function()
                  vim.defer_fn(function()
                    format_range()
                  end, 1)
                end
              )
            end
          end

          format_range()
        end,
        mode = { "n", "v" },
        desc = "Format [g]it hunks",
      },
    },
  },
}

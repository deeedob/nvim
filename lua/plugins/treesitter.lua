return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = function()
      -- main branch dropped ensure_installed / auto_install from setup().
      -- Install core parsers here; the FileType autocmd handles on-demand installs.
      require("nvim-treesitter.install").install({
        "cpp", "c", "markdown", "markdown_inline",
        "html", "yaml", "regex", "bash", "zsh",
      })
      vim.cmd("TSUpdate")
    end,
    lazy = false,
    main = "nvim-treesitter",
    opts = {},
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

      -- Incremental selection using native nvim 0.12 vim.treesitter._select API.
      -- Identical logic to the built-in `an`/`in` text objects (defaults.lua),
      -- just rebound to <Enter>/<BS>.
      -- Keymaps are set buffer-local in the FileType callback so they always
      -- win over any global <Enter> mapping set by other plugins.
      local sel = require("vim.treesitter._select")

      local function expand()
        if vim.treesitter.get_parser(nil, nil, { error = false }) then
          sel.select_parent(vim.v.count1)
        elseif #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/selectionRange" }) > 0 then
          vim.lsp.buf.selection_range(vim.v.count1)
        end
      end

      local function shrink()
        if vim.treesitter.get_parser(nil, nil, { error = false }) then
          sel.select_child(vim.v.count1)
        elseif #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/selectionRange" }) > 0 then
          vim.lsp.buf.selection_range(-vim.v.count1)
        end
      end

      local function ts_start(buf)
        local ok = pcall(vim.treesitter.start, buf)
        return ok
      end

      local function set_selection_keymaps(buf)
        local enter = vim.api.nvim_replace_termcodes("<Enter>", true, false, true)
        vim.keymap.set("n", "<Enter>", function()
          vim.api.nvim_feedkeys("v" .. enter, "m", false)
        end, { buffer = buf, desc = "TS/LSP: init node selection" })
        vim.keymap.set("x", "<Enter>", expand, { buffer = buf, desc = "TS/LSP: expand selection" })
        vim.keymap.set("x", "<BS>",    shrink, { buffer = buf, desc = "TS/LSP: shrink selection" })
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local buf = args.buf
          local lang = vim.bo[buf].filetype

          local disabled = {
            make = true,
            comment = require("utils.plugin").exists("todo-comments.nvim") and true or nil,
          }
          if disabled[lang] then
            return
          end

          local stats = vim.F.npcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if stats and stats.size > (1024 * 1024) then
            return
          end

          local parsers = require("nvim-treesitter.parsers")
          if ts_start(buf) then
            set_selection_keymaps(buf)
          elseif parsers[lang] then
            -- Parser not installed yet; auto-install and set keymaps after
            local task = require("nvim-treesitter.install").install({ lang })
            task:await(function(err)
              if not err then
                vim.schedule(function()
                  if vim.api.nvim_buf_is_valid(buf) and ts_start(buf) then
                    set_selection_keymaps(buf)
                  end
                end)
              end
            end)
          end
          -- Unknown filetype (fugitive, oil, etc.): no keymaps, no warning
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

-- https://cmp.saghen.dev

local DISABLED_FILETYPES = {
  "DiffviewFileHistory",
  "DiffviewFiles",
  "checkhealth",
  "copilot-chat",
  "fugitive",
  "git",
  "gitcommit",
  "help",
  "lspinfo",
  "man",
  "neo-tree",
  "oil",
  "qf",
  "query",
  "scratch",
  "startuptime",
}

return {
  "saghen/blink.cmp",
  version = "1.*",
  opts_extended = { "sources.default" },
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = function(plugin)
        local cmd = { "make", "install_jsregexp" }
        vim.system(cmd, { cwd = plugin.dir }):wait()
      end,
      config = function(_, opts)
        require("luasnip").setup(opts)
        require("luasnip.loaders.from_lua").load {
          paths = { vim.fn.stdpath "config" .. "/lua/snippets" },
        }
      end,
      opts = {
        updateevents = "TextChanged,TextChangedI",
        override_builtin = true,
        enable_autosnippets = false,
      },
    },
    "lazydev.nvim",
  },

  opts = {
    keymap = {
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },

      ["<C-n>"] = { "select_next", "show", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-k>"] = { "snippet_forward", "fallback" },
      ["<C-j>"] = { "snippet_backward", "fallback" },

      ["<C-i>"] = { "accept", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },

      ["<A-1>"] = {
        function(cmp)
          cmp.accept { index = 1 }
        end,
      },
      ["<A-2>"] = {
        function(cmp)
          cmp.accept { index = 2 }
        end,
      },
      ["<A-3>"] = {
        function(cmp)
          cmp.accept { index = 3 }
        end,
      },
      ["<A-4>"] = {
        function(cmp)
          cmp.accept { index = 4 }
        end,
      },
      ["<A-5>"] = {
        function(cmp)
          cmp.accept { index = 5 }
        end,
      },
      ["<A-6>"] = {
        function(cmp)
          cmp.accept { index = 6 }
        end,
      },
      ["<A-7>"] = {
        function(cmp)
          cmp.accept { index = 7 }
        end,
      },
      ["<A-8>"] = {
        function(cmp)
          cmp.accept { index = 8 }
        end,
      },
      ["<A-9>"] = {
        function(cmp)
          cmp.accept { index = 9 }
        end,
      },
    },
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono",
    },

    completion = {
      accept = {
        auto_brackets = { enabled = false },
      },

      documentation = {
        auto_show = true,
        auto_show_delay_ms = 250,
        treesitter_highlighting = true,
        window = {
          border = "rounded",
        },
      },

      ghost_text = {
        enabled = true,
      },

      menu = {
        border = "rounded",
        draw = {
          treesitter = { "lsp" },
          columns = {
            { "item_idx" },
            { "kind_icon" },
            { "label", "label_description", gap = 1 },
          },
          components = {
            item_idx = {
              text = function(ctx)
                return tostring(ctx.idx)
              end,
              highlight = "BlinkCmpItemIdx",
            },
          },
        },
      },

      list = {
        selection = {
          auto_insert = false,
        },
      },
    },

    cmdline = {
      keymap = { preset = "inherit" },
      sources = function()
        local type = vim.fn.getcmdtype()
        if type == "/" or type == "?" then
          return { "buffer" }
        end
        if type == ":" or type == "@" then
          return { "cmdline", "buffer" }
        end
        return {}
      end,
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },

    enabled = function()
      local buftype = vim.bo.buftype
      local filetype = vim.bo.filetype
      return not (
        buftype == "nofile"
        or buftype == "nowrite"
        or buftype == "prompt"
        or vim.tbl_contains(DISABLED_FILETYPES, filetype)
      )
    end,

    fuzzy = {
      implementation = "prefer_rust_with_warning",
      sorts = { "exact", "score", "sort_text" },
    },

    snippets = {
      preset = "luasnip",
    },

    sources = {
      -- min_keywoard_length = 2,

      default = function(ctx)
        local success, node = pcall(vim.treesitter.get_node)
        if
          success
          and node
          and vim.tbl_contains(
            { "comment", "line_comment", "block_comment" },
            node:type()
          )
        then
          return { "buffer" }
        else
          return { "lsp", "snippets", "buffer", "path" }
        end
      end,

      per_filetype = {
        lua = { inherit_defaults = true, "lazydev" },
      },

      providers = {
        lsp = {
          fallbacks = {}
        },
        path = {
          opts = {
            trailing_slash = true,
            label_trailing_slash = true,
            get_cwd = function(context)
              return vim.fn.getcwd()
            end,
            show_hidden_files_by_default = true,
          },
        },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
      },
    },

    signature = {
      enabled = true,
      window = { border = "rounded" },
    },
  },
}

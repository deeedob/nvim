return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        config = function()
          for _, ft_path in
            ipairs(
              vim.api.nvim_get_runtime_file("lua/custom/snippets/*.lua", true)
            )
          do
            loadfile(ft_path)()
          end
        end,
      },
    },
    version = "v0.*",
    opts = {
      keymap = {
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },

        ["<C-n>"] = { "select_next", "fallback" },
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
          auto_brackets = { enabled = true },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          treesitter_highlighting = true,
          window = {
            border = "rounded",
          },
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
      },

      snippets = {
        preset = "luasnip"
      },

      sources = {

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
            return { "lazydev", "lsp", "path", "snippets", "buffer" }
          end
        end,

        providers = {
          path = {
            min_keyword_length = 0,
          },
          buffer = {
            min_keyword_length = 5,
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
    opts_extended = { "sources.default" },
  },
}

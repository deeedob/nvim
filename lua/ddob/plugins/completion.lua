return {
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = {
      { "rafamadriz/friendly-snippets" },
      { "L3MON4D3/LuaSnip", version = "v2.*" },
    },
    version = "v0.*",
    opts = {
      keymap = {
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },

        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        -- ["<S-n>"] = { "snippet_forward", "fallback" },
        -- ["<S-p>"] = { "snippet_backward", "fallback" },

        ["<C-i>"] = { "accept", "fallback" },
        ["<C-j>"] = { "scroll_documentation_down", "fallback" },
        ["<C-k>"] = { "scroll_documentation_up", "fallback" },

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
        -- use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      completion = {
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
                  print(vim.inspect(ctx.label_detail))
                  return tostring(ctx.idx)
                end,
                highlight = "BlinkCmpItemIdx",
              },
            },
          },
        },
        documentation = {
          auto_show = true,
          window = {
            border = "rounded"
          }
        },
      },
      snippets = {
        expand = function(snippet)
          require("luasnip").lsp_expand(snippet)
        end,
        active = function(filter)
          if filter and filter.direction then
            return require("luasnip").jumpable(filter.direction)
          end
          return require("luasnip").in_snippet()
        end,
        jump = function(direction)
          require("luasnip").jump(direction)
        end,
      },
      sources = {
        default = { "lsp", "path", "luasnip", "buffer" },
      },
      signature = {
        enabled = true,
      },
    },
    opts_extended = { "sources.default" },
  },
}

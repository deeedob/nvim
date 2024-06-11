---@diagnostic disable: missing-fields
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append "c"

local lspkind = require "lspkind"
lspkind.init {}

local cmp = require "cmp"
local compare = cmp.config.compare
-- @type lsp.CompletionItemKind
local kind = require("cmp.types").lsp.CompletionItemKind

cmp.setup {
  sources = {
    {
      name = "nvim_lsp",
      entry_filter = function(entry)
        return kind[entry:get_kind()] ~= "Text"
      end,
    },
    { name = "luasnip", keyword_length = 2 },
    { name = "path" },
    -- { name = "buffer" },
  },
  mapping = {
    ["<C-n>"] = cmp.mapping.select_next_item {
      behavior = cmp.SelectBehavior.Insert,
    },
    ["<C-p>"] = cmp.mapping.select_prev_item {
      behavior = cmp.SelectBehavior.Insert,
    },
    ["<C-i>"] = cmp.mapping(
      cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      },
      { "i", "c" }
    ),
    ["<C-Space>"] = cmp.mapping.complete(),
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  sorting = {
    priority_weight = 2,
    compare.order,
    -- priority_weight =
    comparators = {
      compare.exact,
      compare.score,
      compare.recently_used,
      compare.locality,
      compare.offset,
    },
  },

  performance = {
    max_view_entries = 18,
  },

  experimental = {
    ghost_text = { hl_group = "Comment" },
  },

  enabled = function()
    local context = require "cmp.config.context"
    if vim.api.nvim_get_mode().mode == "c" then
      return true
    else
      return not context.in_treesitter_capture "comment"
        and not context.in_syntax_group "Comment"
    end
  end,

  window = {
    completion = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
  },
  view = {
    entries = {
      name = "custom",
    },
  },
  formatting = {
    expandable_indicator = false,
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      local kind = require("lspkind").cmp_format {
        mode = "symbol_text",
        ellipsis_char = "~~",
        maxwidth = 50,
      }(entry, vim_item)
      local strings = vim.split(kind.kind, "%s", { trimempty = true })
      kind.kind = " " .. (strings[1] or "") .. " "
      kind.menu = " " .. (strings[2] or "") .. " "
      kind.concat = kind.abbr
      return kind
    end,
  },
}

cmp.event:on("confirm_done", function(event)
  -- clangd already adds parentheses
  local excluded_filetypes = { "cpp", "c", "cuda" }
  local ft = vim.bo.filetype
  for _, f in ipairs(excluded_filetypes) do
    if ft == f then
      return
    end
  end
  require("ddob.utils").auto_brackets(event.entry)
end)

cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources(
    { { name = "path", option = { trailing_slash = true } } },
    { { name = "cmdline" } }
  ),
})

cmp.setup.filetype({ "markdown" }, {
  completion = {
    autocomplete = false,
  },
})

local ls = require "luasnip"
ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
  override_builtin = true,
}

for _, ft_path in
  ipairs(vim.api.nvim_get_runtime_file("lua/ddob/snippets/*.lua", true))
do
  loadfile(ft_path)()
end

vim.keymap.set({ "i", "s" }, "<c-k>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-j>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

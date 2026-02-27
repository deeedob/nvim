-- ~/.config/nvim/colors/ddob-base-legacy.lua
-- Minimal structural mapping (legacy groups per :h group-name)

local M = {}

local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

local function blend(fg, bg, alpha)
  local fr, fg_, fb = hex_to_rgb(fg)
  local br, bg_, bb = hex_to_rgb(bg)
  local r = math.floor((alpha * fr) + ((1 - alpha) * br) + 0.5)
  local g = math.floor((alpha * fg_) + ((1 - alpha) * bg_) + 0.5)
  local b = math.floor((alpha * fb) + ((1 - alpha) * bb) + 0.5)
  return rgb_to_hex(r, g, b)
end

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.setup()
  vim.o.termguicolors = true
  vim.o.background = "dark"

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "ddob-kanagawa"

  -- Base palette (few anchors)
  local c = {
    bg = "#181616",
    fg = "#c5c9c5",

    comment = "#a6a69c",
    string = "#8a9a7b",
    constant = "#c4b28a",

    structure = "#A6BFC9",
    type = "#949fb5",

    keyword = "#938AA9",
    control = "#c4746e",

    func = "#B3A7B4",
    operator = "#b6927b",
  }

  local d = {
    meta = blend(c.structure, c.fg, 0.40),
    -- keyword_dim = blend(c.keyword, c.fg, 0.30),
  }

  hl("Comment", { fg = c.comment })
  hl("SpecialComment", { fg = c.comment })

  -- 2) Data literals
  hl("String", { fg = c.string })
  hl("Character", { fg = c.string })

  hl("Constant", { fg = c.constant })
  hl("Number", { fg = c.constant })
  hl("Boolean", { fg = c.constant })
  hl("Float", { fg = c.constant })

  -- 3) Names
  hl("Identifier", { fg = c.fg })
  hl("Function", { fg = c.func })

  -- 4) Control / flow / intent
  -- Keep this simple: "things that steer execution" are control colored.
  hl("Statement", { fg = c.control })
  hl("Conditional", { fg = c.control })
  hl("Repeat", { fg = c.control })
  hl("Exception", { fg = c.control })

  -- Language glue / labels
  hl("Keyword", { fg = c.keyword })
  hl("Label", { fg = c.keyword })

  -- 5) Types / shapes (static cluster)
  hl("Type", { fg = c.type })
  hl("Structure", { fg = c.structure })
  hl("Typedef", { fg = c.type })
  hl("StorageClass", { fg = d.meta })

  -- 6) Mechanics
  hl("Operator", { fg = c.operator })
  hl("Delimiter", { fg = c.operator })

  -- 7) Compile-time / macro layer (static cluster, not control)
  hl("PreProc", { fg = d.meta })
  hl("Include", { fg = d.meta })
  hl("Define", { fg = d.meta })
  hl("Macro", { fg = d.meta })
  hl("PreCondit", { fg = d.meta })

  -- 8) Special / escape hatch (choose one: mechanics vs literal)
  -- Here: "syntax mechanics" (escapes, tags, weird tokens) -> operator family.
  hl("Special", { fg = c.operator })
  -- hl("SpecialChar", { fg = c.operator })
  -- hl("Tag", { fg = c.operator })
  -- hl("Debug", { fg = c.operator })

  -- 9) Attention / diagnostics
  hl("Error", { fg = c.control, bg = c.bg })
  -- hl("Todo", { fg = c.constant }) -- or { fg = c.bg, bg = c.constant } if you want loud

  ---------------------------------------------------------------------------
  -- UI (kept from your file; remove if you truly want syntax-only)
  ---------------------------------------------------------------------------

  local ui_bg2 = blend(c.fg, c.bg, 0.06)
  local ui_bg3 = blend(c.fg, c.bg, 0.09)
  local ui_dim = blend(c.fg, c.bg, 0.65)

  hl("Normal", { fg = c.fg, bg = c.bg })
  hl("NormalNC", { fg = c.fg, bg = c.bg })
  hl("EndOfBuffer", { fg = c.bg, bg = c.bg })
  hl("NonText", { fg = ui_dim, bg = c.bg })
  hl("Whitespace", { fg = ui_dim, bg = c.bg })

  hl("LineNr", { fg = ui_dim, bg = c.bg })
  hl("CursorLineNr", { fg = c.fg, bg = c.bg })
  hl("SignColumn", { fg = ui_dim, bg = c.bg })
  hl("FoldColumn", { fg = ui_dim, bg = c.bg })

  hl("VertSplit", { fg = ui_bg3, bg = c.bg })
  hl("WinSeparator", { fg = ui_bg3, bg = c.bg })

  hl("CursorLine", { bg = ui_bg2 })
  hl("ColorColumn", { bg = ui_bg2 })

  hl("Visual", { bg = ui_bg3 })
  hl("Search", { bg = ui_bg3, fg = c.fg })
  hl("IncSearch", { bg = ui_bg3, fg = c.fg })

  hl("Pmenu", { bg = c.bg, fg = c.fg })
  hl("PmenuSel", { bg = ui_bg3, fg = c.fg })
  hl("PmenuSbar", { bg = ui_bg2 })
  hl("PmenuThumb", { bg = ui_bg3 })

  hl("StatusLine", { bg = c.bg, fg = c.fg })
  hl("StatusLineNC", { bg = c.bg, fg = ui_dim })
  hl("TabLine", { bg = c.bg, fg = ui_dim })
  hl("TabLineSel", { bg = c.bg, fg = c.fg })
  hl("TabLineFill", { bg = c.bg, fg = ui_dim })

  hl("NormalFloat", { bg = c.bg, fg = c.fg })
  hl("FloatBorder", { bg = c.bg, fg = ui_bg3 })
end

M.setup()
return M

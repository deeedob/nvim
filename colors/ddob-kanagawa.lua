local M = {}

-- Helpers -------------------------------------------------------------------
local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local function link(group, target)
  hl(group, { link = target })
end

-- Setup ---------------------------------------------------------------------

function M.setup()
  vim.o.termguicolors = true
  vim.o.background = "dark"

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "ddob-kanagawa"

  -- Palette -----------------------------------------------------------------

  local ui = {
    bg_m2 = "#0d0c0c",
    bg_m1 = "#1D1C19",
    bg = "#181616",
    bg_p1 = "#282727",
    bg_p2 = "#393836",

    fg = "#c5c9c5",
    fg_dim = "#a6a69c",
    special = "#7a8382",
    nontext = "#625e5a",

    bg_visual = "#223249",
    bg_search = "#2D4F67",
  }

  local syn = {
    comment = "#8B8B7E",
    string = "#8a9a7b",
    value = "#D6C396",

    grammar = "#938AA9",
    control = "#c4746e",

    structure = "#7aa880",
    namespace = "#A6BFC9",
    type = "#949fb5",

    identifier = "#C25E78",
    specifier = "#b6927b",
  }

  local vcs = {
    fg = {
      base = "#7B7365",
    },
    bg = {
      add = "#223025",
      change = "#2B2A3A",
      delete = "#3A2226",
      text = "#3C3A55",
    },
    sign = {
      add = "#76946A",
      change = "#DCA561",
      delete = "#C34043",
    },
  }

  local diag = {
    error = "#E82424",
    warning = "#FF9E3B",
    info = "#658594",
    hint = "#6A9589",
    ok = "#98BB6C",
  }

  -- UI ----------------------------------------------------------------------
  -- https://neovim.io/doc/user/syntax.html#highlight-groups
  ----------------------------------------------------------------------------

  -- Base surfaces -----------------------------------------------------------

  hl("Normal", { fg = ui.fg, bg = ui.bg })
  hl("NormalNC", { fg = ui.fg_dim, bg = ui.bg })

  -- Cursor ------------------------------------------------------------------

  hl("Cursor", { fg = ui.bg, bg = syn.type })
  link("lCursor", "Cursor")
  link("CursorIM", "Cursor")
  link("TermCursor", "Cursor")
  hl("TermCursorNC", { fg = ui.bg, bg = ui.fg_dim })

  -- Lines / columns / splits ------------------------------------------------

  hl("CursorLine", { bg = "None" })
  link("CursorColumn", "CursorLine")
  link("CursorLineSign", "CursorLine")
  link("CursorLineFold", "CursorLine")

  hl("ColorColumn", { bg = ui.bg_visual })

  hl("WinSeparator", { fg = ui.bg_p2, bg = ui.bg })
  link("VertSplit", "WinSeparator")

  -- Gutter / numbers / folds ------------------------------------------------

  hl("LineNr", { fg = ui.nontext, bg = "None" })
  hl("CursorLineNr", { fg = syn.grammar, bg = "None", bold = true })
  link("SignColumn", "LineNr")
  link("FoldColumn", "LineNr")

  hl("Folded", { fg = ui.special, bg = ui.bg_p1 })

  -- Invisible / special text ------------------------------------------------

  hl("NonText", { fg = ui.nontext })
  link("Whitespace", "NonText")
  link("SpecialKey", "NonText")

  hl("Conceal", { fg = ui.special, bold = true })
  hl("EndOfBuffer", { fg = ui.bg })

  -- Floats / popups ---------------------------------------------------------

  hl("NormalFloat", { fg = "None", bg = ui.bg })
  hl("FloatBorder", { fg = ui.fg_dim, bg = ui.bg })
  hl("FloatTitle", { fg = ui.special, bg = "None", bold = true })
  link("FloatFooter", "FloatBorder")

  -- Popup menu --------------------------------------------------------------

  hl("Pmenu", { fg = ui.fg_dim, bg = ui.bg })
  hl("PmenuSel", { fg = "None", bg = ui.bg_p1 })
  hl("PmenuSbar", { bg = ui.bg_m1 })
  hl("PmenuThumb", { bg = ui.fg_dim })
  link("WildMenu", "PmenuSel")

  -- Selection / search ------------------------------------------------------

  hl("Visual", { bg = ui.bg_visual })
  link("VisualNOS", "Visual")

  hl("Search", { fg = ui.fg, bg = ui.bg_search })
  hl("IncSearch", { fg = ui.bg, bg = diag.warning, bold = true })
  link("CurSearch", "IncSearch")
  link("Substitute", "IncSearch")

  hl("MatchParen", { fg = diag.warning, bold = true })

  -- Statusline / tabline / winbar ------------------------------------------

  hl("StatusLine", { fg = ui.fg_dim, bg = ui.bg_p1 })
  hl("StatusLineNC", { fg = ui.special, bg = ui.bg_p1 })
  link("StatusLineTerm", "StatusLine")
  link("StatusLineTermNC", "StatusLineNC")

  link("TabLine", "StatusLineNC")
  hl("TabLineSel", { fg = ui.fg, bg = ui.bg_p2, bold = true })
  hl("TabLineFill", { bg = ui.bg })

  hl("WinBar", { fg = ui.fg_dim, bg = ui.bg_m1 })
  hl("WinBarNC", { fg = ui.special, bg = ui.bg_m1 })

  -- Messages / prompts ------------------------------------------------------

  hl("MsgArea", { fg = ui.fg_dim })
  hl("MsgSeparator", { fg = ui.bg_p2, bg = ui.bg })

  hl("ModeMsg", { fg = diag.warning, bold = true })
  hl("MoreMsg", { fg = diag.info })
  link("Question", "MoreMsg")

  hl("ErrorMsg", { fg = diag.error, bold = true })
  hl("WarningMsg", { fg = diag.warning, bold = true })

  -- Common accents ----------------------------------------------------------

  hl("Directory", { fg = ui.fg })
  hl("Title", { fg = ui.fg, bold = true })
  hl("QuickFixLine", { bg = ui.bg_p1 })

  -- Spelling ----------------------------------------------------------------

  hl("SpellBad", { undercurl = true, sp = diag.error })
  hl("SpellCap", { undercurl = true, sp = diag.warning })
  hl("SpellLocal", { undercurl = true, sp = diag.warning })
  hl("SpellRare", { undercurl = true, sp = diag.warning })

  -- Core Syntax -------------------------------------------------------------
  -- https://neovim.io/doc/user/syntax.html#group-name
  ----------------------------------------------------------------------------

  hl("Comment", { fg = syn.comment })
  link("SpecialComment", "Comment")

  hl("String", { fg = syn.string })
  link("Character", "String")

  hl("Number", { fg = syn.value })
  link("Boolean", "Number")
  link("Float", "Number")
  link("StorageClass", "Number")

  hl("Constant", { fg = syn.specifier })

  hl("Identifier", { fg = syn.identifier })
  hl("Function", { fg = syn.identifier })

  hl("Keyword", { fg = syn.grammar })
  link("Statement", "Keyword")
  link("Label", "Keyword")
  link("Exception", "Keyword")

  hl("Conditional", { fg = syn.control })
  link("Repeat", "Conditional")
  link("Include", "Conditional")

  hl("Type", { fg = syn.type })
  link("Typedef", "Type")

  hl("Structure", { fg = syn.structure })

  hl("Operator", { fg = syn.specifier })
  link("Delimiter", "Operator")

  link("PreProc", "Operator")
  link("Define", "PreProc")
  link("Macro", "PreProc")
  link("PreCondit", "PreProc")

  hl("Special", { fg = syn.control })
  link("SpecialChar", "Special")
  link("Tag", "Special")

  hl("Error", { fg = diag.error })
  hl("Todo", { fg = ui.bg, bg = syn.value, bold = true })

  hl("Underlined", { underline = true })
  link("Ignore", "Comment")

  -- LSP ---------------------------------------------------------------------

  hl("@lsp.type.namespace", { fg = syn.namespace })
  link("@lsp.type.parameter", "Identifier")
  link("@lsp.type.property", "Identifier")
  link("@lsp.typemod.variable.globalScope", "Identifier")
  link("@lsp.typemod.variable.fileScope", "Identifier")

  link("@lsp.mod.readonly", "Constant")
  link("@lsp.typemod.function.static", "Constant")
  link("@lsp.typemod.function.globalScope", "Constant")
  link("@lsp.typemod.function.fileScope", "Constant")
  link("@lsp.typemod.variable.readonly", "Constant")

  -- DIAGNOSTIC --------------------------------------------------------------
  -- https://neovim.io/doc/user/diagnostic.html#diagnostic-highlights
  ----------------------------------------------------------------------------

  hl("DiagnosticError", { fg = diag.error })
  hl("DiagnosticWarn", { fg = diag.warning })
  hl("DiagnosticInfo", { fg = diag.info })
  hl("DiagnosticHint", { fg = diag.hint })
  hl("DiagnosticOk", { fg = diag.ok })
  hl("DiagnosticDeprecated", {})

  -- DIFF --------------------------------------------------------------------

  hl("DiffAdd", { bg = vcs.bg.add, bold = true })
  hl("DiffChange", { bg = vcs.bg.change, bold = true })
  hl("DiffDelete", { bg = vcs.bg.delete, fg = vcs.fg.base })
  hl("DiffText", { bg = vcs.bg.text, bold = true })
  hl("Added", { fg = vcs.sign.add })
  hl("Changed", { fg = vcs.sign.change })
  hl("Removed", { fg = vcs.sign.delete })

  ----------------------------------------------------------------------------
  -- PLUGINS -----------------------------------------------------------------
  ----------------------------------------------------------------------------
  link("GitSignsAdd", "Added")
  link("GitSignsChange", "Changed")
  link("GitSignsDelete", "Removed")

  hl("fugitiveHunk", { fg = syn.comment })
  hl("fugitiveHash", { fg = syn.namespace })
  link("fugitiveUnstagedModifier", "Changed")
  link("fugitiveUntrackedSection", "Comment")

  hl("IlluminatedWordWrite", { bg = ui.bg_p2 })
  link("IlluminatedWordText", "IlluminatedWordWrite")
  link("IlluminatedWordRead", "IlluminatedWordWrite")

  link("InclineNormal", "Constant")
  link("InclineNormalNC", "Comment")

  hl("RenderMarkdownCode", { bg = ui.bg_m2 })

  link("TreesitterContext", "Folded")
end

M.setup()
return M

local colorbuddy = require "colorbuddy"
colorbuddy.colorscheme "basedbuddy"

local Color = colorbuddy.Color
local Group = colorbuddy.Group

local c = colorbuddy.colors
local g = colorbuddy.groups
local s = colorbuddy.styles

vim.keymap.set(
  "n",
  "<leader>x",
  "<cmd>.lua<CR>",
  { desc = "Execute the current line" }
)
vim.keymap.set(
  "n",
  "<leader><leader>x",
  "<cmd>source %<CR>",
  { desc = "Execute the current file" }
)

Color.new("black0", "#0d0c0c")
Color.new("black1", "#12120f")
Color.new("black2", "#181616")
Color.new("black3", "#181616")
Color.new("black4", "#282727")
Color.new("black5", "#393836")
Color.new("black6", "#625e5a")

Color.new("oldWhite", "#c8c093")
Color.new("fujiWhite", "#dcd7ba")
Color.new("fujiGray", "#727169")

Color.new("sumiInk6", "#54546D")

-- Popups and Floats
Color.new("waveBlue1", "#223249")
Color.new("waveBlue2", "#54546D")

-- Diff and Git
Color.new("winterGreen", "#2b3328")
Color.new("winterYellow", "#49443c")
Color.new("winterRed", "#43242b")
Color.new("winterBlue", "#252535")
Color.new("autumnGreen", "#76946a")
Color.new("autumnRed", "#c34043")
Color.new("autumnYellow", "#dca561")

-- Diag
Color.new("samuraiRed", "#e82424")
Color.new("roninYellow", "#ff9e3b")
Color.new("waveAqua", "#6a9589")
Color.new("dragonBlue", "#658594")

Color.new("springGreen", "#98bb6c")
Color.new("surimiOrange", "#ffa066")

Color.new("white", "#c5c9c5")
Color.new("green", "#87a987")
Color.new("green2", "#8a9a7b")
Color.new("pink", "#a292a3")
Color.new("orange", "#b6927b")
Color.new("orange2", "#b98d7b")
Color.new("gray", "#a6a69c")
Color.new("gray2", "#9e9b93")
Color.new("gray3", "#7a8382")
Color.new("blue2", "#8ba4b0")
Color.new("violet", "#8992a7")
Color.new("red", "#c4746e")
Color.new("aqua", "#8ea4a2")
Color.new("ash", "#737c73")
Color.new("teal", "#949fb5")
Color.new("yellow", "#c4b28a")

-- # # # Editor # # #
Group.new("NonText", c.white, c.black6)
Group.new("Normal", c.white, c.black3)
Group.new("NormalNC", c.white, c.black1)

Group.new("Cursor", g.Normal.bg, c.teal:dark(), s.bold)
Group.link("lCursor", g.Cursor)
Group.link("CursorIM", g.Cursor)
Group.new("TermCursor", c.bg, c.red:dark(), g.Cursor)
Group.new("TermCursorNC", g.NormalNC.bg, g.Cursor, g.Cursor)

Group.new("NormalFloat", c.oldWhite, c.black0)
Group.new("FloatBoarder", c.sumiInk6, nil)
Group.new("FloatTitle", c.gray3, nil)
Group.new("FloatFooter", c.black6, nil)

Group.new("Pmenu", c.fuhiWhite, c.waveBlue1)
Group.new("PmenuSel", nil, c.waveBlue2)
Group.new("PmenuSbar", nil, c.waveBlue1)
Group.new("PmenuThumb", nil, c.waveBlue2)
Group.link("WildMenu", g.Pmenu)

Group.new("DiffAdd", nil, c.winterGreen)
Group.new("DiffChange", nil, c.winterBlue)
Group.new("DiffDelete", c.autumnRed, c.winterRed)
Group.new("DiffText", nil, c.winterYellow)

Group.new("FoldColumn", c.gray3, nil)
Group.new("SignColumn", nil, nil)
Group.new("ColorColumn", nil, c.black5)
Group.new("CursorColumn", nil, c.black5)

Group.new("LineNr", c.black5, nil)
Group.new("CursorLineNr", c.red, nil)
Group.new("CursorLineFold", c.red, nil)
Group.new("CursorLineSign", nil, nil)
-- Group.new("LineNrAbove", nil, nil)
-- Group.new("LineNrBelow", nil, nil)

Group.new("Search", c.white, c.waveBlue1)
Group.new("CurSearch", c.white, c.waveBlue2, s.bold)
Group.new("IncSearch", c.waveBlue1, c.roninYellow)

Group.new("TabLine", c.gray3, c.black0)
Group.new("TabLineFill", nil, c.black0)
Group.new("TabLineSel", c.oldWhite, c.black0)

Group.new("StatusLine", c.oldWhite, c.black5)
Group.new("StatusLineNC", c.black6, c.black4)

Group.new("Visual", nil, c.waveBlue1)
Group.link("VisualNOS", g.Visual)

Group.new("WinSeparator", c.black5, g.NormalNC.bg)
Group.link("VertSplit", g.Visual)

Group.new("ErrorMsg", c.samuraiRed, nil)

Group.new("Conceal", nil, c.gray3, s.bold)
Group.new("Directory", c.blue2)
Group.new("Folded", c.gray3, c.black4)
Group.new("EndOfBuffer", g.Normal.bg, nil)

Group.new("DiagnosticHint", c.blue, nil)
Group.new("DiagnosticInfo", c.blue, nil)
Group.new("DiagnosticWarn", c.yellow, nil)
Group.new("DiagnosticError", c.red, nil)
-- https://github.com/tjdevries/colorbuddy.nvim/issues/50
-- Group.new("DiagnosticUnderlineHint", c.none, c.none, s.underline, c.blue)
-- Group.new("DiagnosticUnderlineInfo", c.none, c.none, s.underline, c.blue)
-- Group.new("DiagnosticUnderlineWarn", c.none, c.none, s.underline, c.yellow)
-- Group.new("DiagnosticUnderlineError", c.none, c.none, s.underline, c.red)

-- ModeMsg
-- MsgArea
-- MsgSeparator
-- MoreMsg
-- Question
-- QuickFixLine
-- SpecialKey
-- SpellBad
-- SpellCap
-- SpellLocal
-- SpellRare
-- Title
-- WarningMsg
-- Whitespace
-- WinBar
-- WinBarNC
-- debugPC
-- debugBreakpoint
-- LspReferenceText
-- LspReferenceRead
-- LspReferenceWrite
-- LspSignatureActiveParameter
-- LspCodeLens
-- diffAdded
-- diffRemoved
-- diffDeleted
-- diffChanged
-- diffOldFile
-- diffNewFile

-- # # # Syntax # # #

Group.new("Identifier", c.yellow)
Group.new("Comment", c.black6, nil, s.italic)
Group.new("Number", c.pink)
Group.new("String", c.springGreen:dark())
Group.new("Constant", c.surimiOrange)
Group.new("Boolean", g.Constant.fg:dark(), nil, s.bold)
Group.new("Function", c.blue2, nil, s.italic)
Group.new("Statement", c.violet)
Group.new("Operator", c.red)
Group.new("Keyword", c.violet)
Group.link("Character", g.String)
Group.link("SpecialChar", g.String)
Group.link("Float", g.Number)
Group.new("Exception", c.red)

Group.new("PreProc", c.blue2, nil)
Group.new("Macro", c.red, nil, s.bold)
Group.new("Include", c.orange2)
Group.new("PreCondit", c.orange2:light())
Group.new("Define", c.orange2:dark(), c.surimiOrange)

Group.new("Type", c.teal)
Group.new("Structure", c.ash:light(), nil)

-- # # # Plugins # # #

Group.new("GitSignsAdd", c.autumnGreen, nil)
Group.new("GitSignsChange", c.autumnYellow, nil)
Group.new("GitSignsDelete", c.autumnRed, nil)

Group.new("InclineNormal", g.Constant.fg, nil)
Group.new("InclineNormalNC", c.gray2, nil)

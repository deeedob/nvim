-- Thanks to:
-- https://github.com/MariaSolOs/dotfiles/blob/fedora/.config/nvim/colors/miss-dracula.lua
-- https://github.com/rebelot/kanagawa.nvim
-- https://github.com/Iron-E/nvim-highlite

-- Reset highlighting.
vim.cmd.highlight "clear"
if vim.fn.exists "syntax_on" then
  vim.cmd.syntax "reset"
end
vim.o.termguicolors = true
vim.g.colors_name = "ddob-kanagawa"

local function multiply_channel(color, channel_bit, factor)
  --- Shift the value all the way to the right, and mask it.
  local masked_value = bit.band(0xFF, bit.rshift(color, channel_bit))
  -- multiply the value by the factor, ensure it is between 0-FF, and shift it back to where it was before.
  return bit.lshift(
    math.min(0xFF, math.max(0, math.floor(masked_value * factor))),
    channel_bit
  )
end

local function saturate(color, factor)
  if type(color) == "string" then
    local normalized = color:gsub("#", "0x")
    color = tonumber(normalized)
      or error("Could not interpret color " .. vim.inspect(color))
  end

  return multiply_channel(color, 16, factor)
    + multiply_channel(color, 8, factor)
    + multiply_channel(color, 0, factor)
end

local config = {
  transparent = false,
  dimInactive = true,
  gutter = false,

  commentStyle = { italic = true },
  functionStyle = {},
  statementStyle = {},
  keywordStyle = {},
  typeStyle = {},
}

local palette = {
  -- Bg Shades
  sumiInk0 = "#16161D",
  sumiInk1 = "#181820",
  sumiInk2 = "#1a1a22",
  sumiInk3 = "#1F1F28",
  sumiInk4 = "#2A2A37",
  sumiInk5 = "#363646",
  sumiInk6 = "#54546D", --fg

  -- Popup and Floats
  waveBlue1 = "#223249",
  waveBlue2 = "#2D4F67",

  -- Diff and Git
  winterGreen = "#2B3328",
  winterYellow = "#49443C",
  winterRed = "#43242B",
  winterBlue = "#252535",
  autumnGreen = "#76946A",
  autumnRed = "#C34043",
  autumnYellow = "#DCA561",

  -- Diag
  samuraiRed = "#E82424",
  roninYellow = "#FF9E3B",
  waveAqua1 = "#6A9589",
  dragonBlue = "#658594",

  -- Fg and Comments
  oldWhite = "#C8C093",
  fujiWhite = "#DCD7BA",
  fujiGray = "#727169",

  oniViolet = "#957FB8",
  oniViolet2 = "#b8b4d0",
  crystalBlue = "#7E9CD8",
  springViolet1 = "#938AA9",
  springViolet2 = "#9CABCA",
  springBlue = "#7FB4CA",
  lightBlue = "#A3D4D5", -- unused yet
  waveAqua2 = "#7AA89F", -- improve lightness: desaturated greenish Aqua

  -- waveAqua2  = "#68AD99",
  waveAqua4 = "#7AA880",
  waveAqua5 = "#6CAF95",
  -- waveAqua3  = "#68AD99",

  springGreen = "#98BB6C",
  boatYellow1 = "#938056",
  boatYellow2 = "#C0A36E",
  carpYellow = "#E6C384",

  sakuraPink = "#D27E99",
  waveRed = "#E46876",
  peachRed = "#FF5D62",
  surimiOrange = "#FFA066",
  katanaGray = "#717C7C",

  dragonBlack0 = "#0d0c0c",
  dragonBlack1 = "#12120f",
  dragonBlack2 = "#1D1C19",
  dragonBlack3 = "#181616",
  dragonBlack4 = "#282727",
  dragonBlack5 = "#393836",
  dragonBlack6 = "#625e5a",

  dragonWhite = "#c5c9c5",
  dragonGreen = "#87a987",
  dragonGreen2 = "#8a9a7b",
  dragonPink = "#a292a3",
  dragonOrange = "#b6927b",
  dragonOrange2 = "#b98d7b",
  dragonGray = "#a6a69c",
  dragonGray2 = "#9e9b93",
  dragonGray3 = "#7a8382",
  dragonBlue2 = "#8ba4b0",
  dragonViolet = "#8992a7",
  dragonRed = "#c4746e",
  dragonAqua = "#8ea4a2",
  dragonAsh = "#737c73",
  dragonTeal = "#949fb5",
  dragonYellow = "#c4b28a", --"#a99c8b",
  -- "#8a9aa3",
}

local theme = {
  ui = {
    fg = palette.dragonWhite,
    fg_dim = palette.oldWhite,
    fg_reverse = palette.waveBlue1,

    bg_dim = palette.dragonBlack1,
    bg_gutter = config.gutter and palette.dragonBlack4 or "NONE",

    bg_m3 = palette.dragonBlack0,
    bg_m2 = palette.dragonBlack1,
    bg_m1 = palette.dragonBlack2,
    bg = palette.dragonBlack3,
    bg_p1 = palette.dragonBlack4,
    bg_p2 = palette.dragonBlack5,

    special = palette.dragonGray3,
    whitespace = palette.dragonBlack6,
    nontext = palette.dragonBlack6,

    bg_visual = palette.waveBlue1,
    bg_search = palette.waveBlue2,

    pmenu = {
      fg = palette.fujiWhite,
      fg_sel = "none",
      bg = palette.sumiInk2,
      bg_sel = palette.sumiInk5,
      bg_thumb = palette.springViolet1,
      bg_sbar = palette.sumiInk5,
    },

    float = {
      fg = palette.fujiWhite,
      bg = palette.sumiInk2,
      fg_border = palette.sumiInk6,
      bg_border = palette.dragonBlack0,
    },
  },
  syn = {
    number = palette.dragonYellow,
    statement = palette.dragonViolet,
    attribute = palette.dragonOrange2,
    character_special = palette.dragonRed,
    comment_documentation = palette.dragonGray,
    error = palette.samuraiRed,
    info = saturate(palette.dragonTeal, 1.2),
    todo = palette.dragonPink,
    warning = palette.roninYellow,
    constant_builtin = palette.dragonOrange,
    identifier = palette.dragonAqua,
    constructor = saturate(palette.dragonYellow, 1.2),
    event = palette.dragonViolet,
    func_builtin = palette.dragonPink,
    method = saturate(palette.surimiOrange, 0.85),
    keyword = palette.dragonViolet,
    conditional = palette.dragonRed,
    keyword_coroutine = palette.dragonViolet,
    keyword_operator = palette.dragonRed,
    preproc = palette.dragonRed,
    preproc_conditional = saturate(palette.dragonOrange2, 1.2),
    define = palette.dragonOrange2,
    exception = palette.dragonRed,
    keyword_function = palette.dragonOrange2,
    include = palette.dragonOrange2,
    storage_class = saturate(palette.dragonAqua, 1.2),
    repeat_ = palette.dragonRed,
    keyword_return = palette.dragonOrange2,
    label = palette.dragonTeal,
    macro = palette.dragonOrange,
    text = palette.fujiWhite,
    text_environment = palette.fujiWhite,
    string = palette.dragonGreen2,
    type = palette.waveAqua4,
    fold = palette.dragonGray,
    text_reference = palette.dragonAqua,
    text_math = palette.dragonTeal,
    text_literal = palette.dragonGreen,
    namespace = palette.oniViolet2,
    operator = palette.dragonOrange2,
    property = saturate(palette.waveRed, 0.85),
    delimiter = palette.dragonGray2,
    punctuation_bracket = saturate(palette.dragonGray2, 1.2),
    punctuation_delimiter = saturate(palette.dragonGray2, 1.2),
    punctuation_special = saturate(palette.dragonGray2, 1.2),
    string_escape = palette.dragonRed,
    string_regex = palette.dragonBlue2,
    string_special = saturate(palette.dragonGreen, 1.2),
    structure = palette.dragonOrange2,
    tag = palette.dragonViolet,
    tag_attribute = saturate(palette.dragonOrange2, 1.2),
    tag_delimiter = saturate(palette.dragonGray2, 1.2),
    type_definition = saturate(palette.dragonYellow, 1.2),
    parameter = palette.fujiWhite,
    variable = palette.dragonWhite,
    variable_builtin = palette.dragonAqua,
    field = palette.dragonYellow,
    module_builtin = palette.lightBlue,
    annotation = palette.dragonViolet,
    class = saturate(palette.dragonTeal, 1.05),
    decorator = palette.dragonViolet,
    enum = palette.dragonYellow,
    field_enum = palette.dragonYellow,
    interface = palette.dragonTeal,
    type_parameter = palette.dragonYellow,
  },

  diag = {
    error = palette.samuraiRed,
    ok = palette.springGreen,
    warning = palette.roninYellow,
    info = palette.dragonBlue,
    hint = palette.waveAqua1,
  },
  diff = {
    add = palette.winterGreen,
    delete = palette.winterRed,
    change = palette.winterBlue,
    text = palette.winterYellow,
  },
  vcs = {
    added = palette.autumnGreen,
    removed = palette.autumnRed,
    changed = palette.autumnYellow,
  },
  term = {
    col0 = palette.dragonBlack0, -- black
    col1 = palette.dragonRed, -- red
    col2 = palette.dragonGreen2, -- green
    col3 = palette.dragonYellow, -- yellow
    col4 = palette.dragonBlue2, -- blue
    col5 = palette.dragonPink, -- magenta
    col6 = palette.dragonAqua, -- cyan
    col7 = palette.oldWhite, -- white
    col8 = palette.dragonGray, -- bright black
    col9 = palette.waveRed, -- bright red
    col10 = palette.dragonGreen, -- bright green
    col11 = palette.carpYellow, -- bright yellow
    col12 = palette.springBlue, -- bright blue
    col13 = palette.springViolet1, -- bright magenta
    col14 = palette.waveAqua2, -- bright cyan
    col15 = palette.dragonWhite, -- bright white
    bg = palette.dragonOrange, -- extended color 1
    fg = palette.dragonOrange2, -- extended color 2
  },
}

-- Terminal colors.
vim.g.terminal_color_0 = theme.term.col0
vim.g.terminal_color_1 = theme.term.col1
vim.g.terminal_color_2 = theme.term.col2
vim.g.terminal_color_3 = theme.term.col3
vim.g.terminal_color_4 = theme.term.col4
vim.g.terminal_color_5 = theme.term.col5
vim.g.terminal_color_6 = theme.term.col6
vim.g.terminal_color_7 = theme.term.col7
vim.g.terminal_color_8 = theme.term.col8
vim.g.terminal_color_9 = theme.term.col9
vim.g.terminal_color_10 = theme.term.col10
vim.g.terminal_color_11 = theme.term.col11
vim.g.terminal_color_12 = theme.term.col12
vim.g.terminal_color_13 = theme.term.col13
vim.g.terminal_color_14 = theme.term.col14
vim.g.terminal_color_15 = theme.term.col15
vim.g.terminal_color_background = theme.term.bg
vim.g.terminal_color_foreground = theme.term.fg

---@type table<string, vim.api.keyset.highlight>
local editorgroups = {
  ColorColumn = { bg = theme.ui.bg_p1 },
  Conceal = { fg = theme.ui.special, bold = true },
  CurSearch = { fg = theme.ui.fg, bg = theme.ui.bg_search, bold = true },
  Cursor = { fg = theme.ui.bg, bg = palette.dragonTeal },
  lCursor = { link = "Cursor" },
  CursorIM = { link = "Cursor" },
  CursorColumn = { link = "CursorLine" },
  CursorLine = { bg = theme.ui.bg_p2 },
  TermCursor = { fg = theme.ui.bg, bg = palette.dragonRed },
  Directory = { fg = theme.syn.func_builtin },
  DiffAdd = { bg = theme.diff.add },
  DiffChange = { bg = theme.diff.change },
  DiffDelete = { fg = theme.vcs.removed, bg = theme.diff.delete },
  DiffText = { bg = theme.diff.text },
  EndOfBuffer = { fg = theme.ui.bg },
  ErrorMsg = { fg = theme.diag.error },
  WinSeparator = {
    fg = theme.ui.bg_p2,
    bg = config.dimInactive and theme.ui.bg_dim or "NONE",
  },
  VertSplit = { link = "WinSeparator" },
  Folded = { fg = theme.ui.special, bg = theme.ui.bg_p1 },
  FoldColumn = { fg = theme.ui.nontext, bg = theme.ui.bg_gutter },
  SignColumn = { fg = theme.ui.special, bg = theme.ui.bg_gutter },
  IncSearch = { fg = theme.ui.fg_reverse, bg = theme.diag.warning },
  Substitute = { fg = theme.ui.fg, bg = theme.vcs.removed },
  LineNr = { fg = theme.ui.nontext, bg = theme.ui.bg_gutter },
  CursorLineNr = {
    fg = palette.dragonBlue2,
    bg = theme.ui.bg_gutter,
    bold = true,
  },
  CursorLineFold = {
    fg = palette.dragonBlue2,
    bg = theme.ui.bg_gutter,
    bold = true,
  },
  MatchParen = { fg = theme.diag.warning, bold = true },
  ModeMsg = { fg = theme.diag.warning, bold = true },
  MsgArea = vim.o.cmdheight == 0 and { link = "StatusLine" }
    or { fg = theme.ui.fg_dim },
  MsgSeparator = { bg = vim.o.cmdheight == 0 and theme.ui.bg or theme.ui.bg_m3 },
  MoreMsg = { fg = theme.diag.info },
  NonText = { fg = theme.ui.nontext },
  Normal = {
    fg = theme.ui.fg,
    bg = not config.transparent and theme.ui.bg or "NONE",
  },
  NormalFloat = { fg = theme.ui.float.fg, bg = theme.ui.float.bg },
  FloatBorder = { fg = theme.ui.float.fg_border, bg = theme.ui.float.bg_border },
  FloatTitle = {
    fg = theme.ui.special,
    bg = theme.ui.float.bg,
    bold = true,
  },
  FloatFooter = { fg = theme.ui.nontext, bg = theme.ui.float.bg_border },
  NormalNC = config.dimInactive
      and { fg = theme.ui.fg_dim, bg = theme.ui.bg_dim }
    or { link = "Normal" },
  Pmenu = { fg = theme.ui.pmenu.fg, bg = theme.ui.pmenu.bg },
  PmenuSel = { fg = theme.ui.pmenu.fg_sel, bg = theme.ui.pmenu.bg_sel },
  PmenuSbar = { bg = theme.ui.pmenu.bg_sbar },
  PmenuThumb = { bg = theme.ui.pmenu.bg_thumb },
  Question = { link = "MoreMsg" },
  QuickFixLine = { bg = theme.ui.bg_p1 },
  Search = { fg = theme.ui.fg, bg = theme.ui.bg_search },
  SpecialKey = { fg = theme.ui.special },
  SpellBad = {
    undercurl = config.undercurl,
    underline = not config.undercurl,
    sp = theme.diag.error,
  },
  SpellCap = {
    undercurl = config.undercurl,
    underline = not config.undercurl,
    sp = theme.diag.warning,
  },
  SpellLocal = {
    undercurl = config.undercurl,
    underline = not config.undercurl,
    sp = theme.diag.warning,
  },
  SpellRare = {
    undercurl = config.undercurl,
    underline = not config.undercurl,
    sp = theme.diag.warning,
  },
  StatusLine = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
  StatusLineNC = { fg = theme.ui.nontext, bg = theme.ui.bg_m3 },
  TabLine = { bg = theme.ui.bg_m3, fg = theme.ui.special },
  TabLineFill = { bg = theme.ui.bg },
  TabLineSel = { fg = theme.ui.fg_dim, bg = theme.ui.bg_p1 },
  Title = { fg = theme.syn.fun, bold = true },
  Visual = { bg = theme.ui.bg_visual },
  VisualNOS = { link = "Visual" },
  WarningMsg = { fg = theme.diag.warning },
  Whitespace = { fg = theme.ui.whitespace },
  WildMenu = { link = "Pmenu" },
  Winbar = { fg = theme.ui.fg_dim, bg = "NONE" },
  WinbarNC = {
    fg = theme.ui.fg_dim,
    bg = config.dimInactive and theme.ui.bg_dim or "NONE",
  },

  debugPC = { bg = theme.diff.delete },
  debugBreakpoint = { fg = theme.syn.special1, bg = theme.ui.bg_gutter },

  LspReferenceText = { bg = theme.diff.text },
  LspReferenceRead = { link = "LspReferenceText" },
  LspReferenceWrite = { bg = theme.diff.text, underline = true },
  -- LspInlayHint = { link = "NonText"},

  DiagnosticError = { fg = theme.diag.error },
  DiagnosticWarn = { fg = theme.diag.warning },
  DiagnosticInfo = { fg = theme.diag.info },
  DiagnosticHint = { fg = theme.diag.hint },
  DiagnosticOk = { fg = theme.diag.ok },

  DiagnosticSignError = { fg = theme.diag.error, bg = theme.ui.bg_gutter },
  DiagnosticSignWarn = { fg = theme.diag.warning, bg = theme.ui.bg_gutter },
  DiagnosticSignInfo = { fg = theme.diag.info, bg = theme.ui.bg_gutter },
  DiagnosticSignHint = { fg = theme.diag.hint, bg = theme.ui.bg_gutter },

  DiagnosticVirtualTextError = { link = "DiagnosticError" },
  DiagnosticVirtualTextWarn = { link = "DiagnosticWarn" },
  DiagnosticVirtualTextInfo = { link = "DiagnosticInfo" },
  DiagnosticVirtualTextHint = { link = "DiagnosticHint" },

  DiagnosticUnderlineError = {
    undercurl = config.undercurl,
    underline = not config.undercurl,
    sp = theme.diag.error,
  },
  DiagnosticUnderlineWarn = {
    undercurl = config.undercurl,
    underline = not config.undercurl,
    sp = theme.diag.warning,
  },
  DiagnosticUnderlineInfo = {
    undercurl = config.undercurl,
    underline = not config.undercurl,
    sp = theme.diag.info,
  },
  DiagnosticUnderlineHint = {
    undercurl = config.undercurl,
    underline = not config.undercurl,
    sp = theme.diag.hint,
  },

  LspSignatureActiveParameter = { fg = theme.diag.warning },
  LspCodeLens = { fg = theme.syn.comment },

  -- vcs
  diffAdded = { fg = theme.vcs.added },
  diffRemoved = { fg = theme.vcs.removed },
  diffDeleted = { fg = theme.vcs.removed },
  diffChanged = { fg = theme.vcs.changed },
  diffOldFile = { fg = theme.vcs.removed },
  diffNewFile = { fg = theme.vcs.added },
  -- diffFile = { fg = c.steelGray },
  -- diffLine = { fg = c.steelGray },
  -- diffIndexLine = { link = 'Identifier' },
}
local syntaxgroups = {
  -- *Comment	any comment
  Comment = vim.tbl_extend(
    "force",
    { fg = theme.syn.comment_documentation },
    config.commentStyle
  ),

  -- *Constant	any constant
  Constant = { fg = theme.syn.constant_builtin },
  String = { fg = theme.syn.string },
  Character = { link = "String" },
  Number = { fg = theme.syn.number },
  Boolean = { fg = theme.syn.constant_builtin, bold = true },
  Float = { link = "Number" },

  -- *Identifier	any variable name
  Identifier = { fg = theme.syn.identifier },
  --  Function	function name (also: methods for classes)
  Function = vim.tbl_extend(
    "force",
    { fg = theme.syn.func_builtin },
    config.functionStyle
  ),

  -- *Statement	any statement
  Statement = vim.tbl_extend(
    "force",
    { fg = theme.syn.statement },
    config.statementStyle
  ),
  --  Conditional	if, then, else, endif, switch, etc.
  --  Repeat		for, do, while, etc.
  --  Label		case, default, etc.
  --  Operator	"sizeof", "+", "*", etc.
  Operator = { fg = theme.syn.operator },
  --  Keyword	any other keyword
  Keyword = vim.tbl_extend(
    "force",
    { fg = theme.syn.keyword },
    config.keywordStyle
  ),
  Exception = { fg = theme.syn.exception },
  PreProc = { fg = theme.syn.preproc },
  Type = vim.tbl_extend("force", { fg = theme.syn.type }, config.typeStyle),
  Special = { fg = theme.syn.character_special },
  Delimiter = { fg = theme.syn.delimiter },
  Underlined = { underline = true },
  Bold = { bold = true },
  Italic = { italic = true },
  Ignore = { link = "NonText" },
  Error = { fg = theme.diag.error },
  Todo = { fg = theme.ui.fg_reverse, bg = theme.diag.info, bold = true },
  qfLineNr = { link = "lineNr" },
  qfFileName = { link = "Directory" },
  markdownCode = { fg = theme.syn.string },
  markdownCodeBlock = { fg = theme.syn.string },
  markdownEscape = { fg = "NONE" },
}
local treesittergroups = {
  -- Treesitter
  -- HACK: a lot of these have `nocombine` because of overly-eager captures
  --       in many built-in highlight queries.
  --(@keyword.debug defined below)
  ["@attribute"] = { fg = theme.syn.attribute, nocombine = true },
  ["@character.special"] = { fg = theme.syn.character_special, bold = true },
  ["@comment.documentation"] = { fg = theme.syn.comment_documentation },
  ["@comment.error"] = { fg = theme.syn.error },
  ["@comment.note"] = { fg = theme.syn.info },
  ["@comment.todo"] = { fg = theme.syn.todo },
  ["@comment.warning"] = { fg = theme.syn.warning },
  ["@conceal"] = { link = "Conceal" },
  ["@constant.builtin"] = {
    fg = theme.syn.constant_builtin,
    bold = true,
    nocombine = true,
  },
  ["@constructor"] = { fg = theme.syn.constructor, nocombine = true },
  ["@diff.delta"] = { fg = theme.vcs.changed },
  ["@diff.minus"] = { fg = theme.vcs.removed },
  ["@diff.plus"] = { fg = theme.vcs.added },
  ["@error"] = { link = "Error" },
  ["@event"] = { fg = theme.syn.event, nocombine = true },
  ["@function.builtin"] = { fg = theme.syn.func_builtin, italic = true },
  ["@function.macro"] = { link = "@macro" },
  ["@function.method"] = { fg = theme.syn.method, nocombine = true },
  ["@keyword"] = { fg = theme.syn.keyword, nocombine = true },
  ["@keyword.conditional"] = { fg = theme.syn.conditional, nocombine = true },
  ["@keyword.coroutine"] = {
    fg = theme.syn.keyword_coroutine,
    nocombine = true,
  },
  ["@keyword.directive"] = { fg = theme.syn.preproc, nocombine = true },
  ["@keyword.directive.conditional"] = {
    fg = theme.syn.preproc_conditional,
    nocombine = true,
  },
  ["@keyword.directive.define"] = { fg = theme.syn.define, nocombine = true },
  ["@keyword.exception"] = { fg = theme.syn.exception, nocombine = true },
  ["@keyword.function"] = { fg = theme.syn.keyword_function, nocombine = true },
  ["@keyword.import"] = { fg = theme.syn.include, nocombine = true },
  ["@keyword.modifier"] = { link = "@keyword" },
  ["@keyword.modifier.lifetime"] = { link = "@attribute" },
  ["@keyword.modifier.mutability"] = {
    fg = theme.syn.storage_class,
    nocombine = true,
  },
  ["@keyword.operator"] = {
    fg = theme.syn.keyword_operator,
    nocombine = true,
    bold = true,
  },
  ["@keyword.repeat"] = {
    fg = theme.syn.repeat_,
    nocombine = true,
    bold = true,
  },
  ["@keyword.return"] = { fg = theme.syn.keyword_return, nocombine = true },
  ["@label"] = { fg = theme.syn.label, nocombine = true },
  ["@macro"] = { fg = theme.syn.macro, nocombine = true },
  ["@markup"] = { fg = theme.syn.text },
  ["@markup.danger"] = { link = "@comment.error" },
  ["@markup.emphasis"] = { link = "Italic" },
  ["@markup.environment"] = {
    fg = theme.syn.text_environment,
    nocombine = true,
  },
  ["@markup.environment.name"] = {
    fg = theme.syn.text_environment_name,
    nocombine = true,
  },
  ["@markup.heading.1"] = { fg = theme.syn.error, bold = true },
  ["@markup.heading.1.marker"] = { link = "@punctuation.special" },
  ["@markup.heading.2"] = { fg = theme.syn.warning, bold = true },
  ["@markup.heading.2.marker"] = { link = "@markup.heading.1.marker" },
  ["@markup.heading.3"] = { fg = theme.syn.keyword, bold = true },
  ["@markup.heading.3.marker"] = { link = "@markup.heading.1.marker" },
  ["@markup.heading.4"] = { fg = theme.syn.string, bold = true },
  ["@markup.heading.4.marker"] = { link = "@markup.heading.1.marker" },
  ["@markup.heading.5"] = { fg = theme.syn.type, bold = true },
  ["@markup.heading.5.marker"] = { link = "@markup.heading.1.marker" },
  ["@markup.heading.6"] = { fg = theme.syn.fold, bold = true },
  ["@markup.heading.6.marker"] = { link = "@markup.heading.1.marker" },
  ["@markup.link"] = { fg = theme.syn.text_reference, underline = true },
  ["@markup.link.label"] = { link = "@string.special" },
  ["@markup.link.url"] = { link = "@string.special.url" },
  ["@markup.list"] = { link = "@punctuation.special" },
  ["@markup.math"] = { fg = theme.syn.text_math },
  ["@markup.quote"] = { link = "@comment" },
  ["@markup.raw"] = { fg = theme.syn.text_literal, nocombine = true },
  ["@markup.raw.delimiter"] = { link = "@markup.environment" },
  ["@markup.strike"] = { strikethrough = true },
  -- ["@markup.strong"] = "Bold",
  ["@markup.underline"] = { underline = true },
  ["@module"] = { fg = theme.syn.namespace, italic = true, nocombine = true },
  ["@module.builtin"] = {
    fg = theme.syn.module_builtin,
    bold = true,
    nocombine = true,
  },
  ["@operator"] = { fg = theme.syn.operator, nocombine = true },
  ["@property"] = { fg = theme.syn.property, nocombine = true },
  ["@punctuation"] = { fg = theme.syn.delimiter, nocombine = true },
  ["@punctuation.bracket"] = {
    fg = theme.syn.punctuation_bracket,
    nocombine = true,
  },
  ["@punctuation.delimiter"] = {
    fg = theme.syn.punctuation_delimiter,
    nocombine = true,
  },
  ["@punctuation.special"] = {
    fg = theme.syn.punctuation_special,
    nocombine = true,
  },
  ["@string.documentation"] = { link = "@comment.documentation" },
  ["@string.escape"] = {
    fg = theme.syn.string_escape,
    italic = true,
    nocombine = true,
  },
  ["@string.keycode"] = { link = "SpecialKey" },
  ["@string.regexp"] = { fg = theme.syn.string_regex, nocombine = true },
  ["@string.special"] = { fg = theme.syn.string_special, nocombine = true },
  ["@string.special.path"] = {
    fg = theme.syn.namespace,
    underline = true,
    nocombine = true,
  },
  ["@structure"] = { fg = theme.syn.structure, bold = true, nocombine = true },
  ["@tag"] = { fg = theme.syn.tag, bold = true, nocombine = true },
  ["@tag.attribute"] = { fg = theme.syn.tag_attribute, nocombine = true },
  ["@tag.builtin"] = { link = "@type.builtin" },
  ["@tag.delimiter"] = { fg = theme.syn.tag_delimiter, nocombine = true },
  ["@type"] = { fg = theme.syn.type, nocombine = true },
  ["@type.builtin"] = { fg = theme.syn.type_builtin, nocombine = true },
  ["@type.definition"] = { fg = theme.syn.type_builtin, nocombine = true },
  ["@type.pointer"] = { link = "@keyword.modifier.mutability" },
  ["@variable"] = { fg = theme.syn.variable, nocombine = true },
  ["@variable.builtin"] = {
    fg = theme.syn.variable_builtin,
    italic = true,
    nocombine = true,
  },
  ["@variable.member"] = { fg = theme.syn.field, nocombine = true },
  ["@variable.parameter"] = {
    fg = theme.syn.parameter,
    italic = true,
    nocombine = true,
  },
}

local lsp_groups = {
  -- LSP
  ["@lsp.mod.annotation"] = { fg = theme.syn.annotation, nocombine = true },
  ["@lsp.mod.constant"] = { link = "@constant" },
  ["@lsp.mod.interpolation"] = { link = "@string.special" },
  ["@lsp.mod.readonly"] = { link = "@lsp.mod.constant" },
  ["@lsp.mod.static"] = { italic = true },
  ["@lsp.type.boolean"] = { link = "@boolean" },
  ["@lsp.type.character"] = { link = "@character" },
  ["@lsp.type.class"] = { fg = theme.syn.class, nocombine = true },
  ["@lsp.type.decorator"] = { fg = theme.syn.decorator },
  ["@lsp.type.enum"] = { fg = theme.syn.enum, bold = true, nocombine = true },
  ["@lsp.type.enumMember"] = { fg = theme.syn.field_enum, nocombine = true },
  ["@lsp.type.escapeSequence"] = { link = "@string.escape" },
  ["@lsp.type.event"] = { link = "@event" },
  ["@lsp.type.float"] = { link = "@number.float" },
  ["@lsp.type.identifier"] = { link = "Identifier" },
  ["@lsp.type.interface"] = { fg = theme.syn.interface, nocombine = true },
  ["@lsp.type.keyword"] = { link = "@keyword" },
  ["@lsp.type.lifetime"] = { link = "@attribute" },
  ["@lsp.type.macro"] = { link = "@macro" },
  ["@lsp.type.method"] = { link = "@function.method" },
  ["@lsp.type.namespace"] = { link = "@module" },
  ["@lsp.type.number"] = { link = "@number" },
  -- ["@lsp.type.operator"] = NONE,
  ["@lsp.type.parameter"] = { link = "@variable.parameter" },
  ["@lsp.type.property"] = { link = "@property" },
  ["@lsp.type.string"] = { link = "@string" },
  ["@lsp.type.struct"] = { link = "@structure" },
  ["@lsp.type.type"] = { link = "@type" },
  ["@lsp.type.typeAlias"] = { link = "@type.definition" },
  ["@lsp.type.typeParameter"] = {
    fg = theme.syn.type_parameter,
    italic = true,
    nocombine = true,
  },
  ["@lsp.type.variable"] = { link = "@variable" },
  ["@lsp.typemod.deriveHelper.attribute"] = { link = "@attribute" },
  ["@lsp.typemod.function.builtin"] = {
    link = "@lsp.typemod.function.defaultLibrary",
  },
  ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
  ["@lsp.typemod.function.readonly"] = { link = "@lsp.type.function" },
  ["@lsp.typemod.keyword.conditional"] = { link = "@keyword.conditional" },
  -- ["@lsp.typemod.string.constant"] = NONE,
  ["@lsp.typemod.string.escape"] = { link = "@lsp.type.escapeSequence" },
  -- ["@lsp.typemod.string.readonly"] = NONE,
  -- ["@lsp.typemod.string.static"] = NONE,
  ["@lsp.typemod.type.declaration"] = { link = "@type.definition" },
  ["@lsp.typemod.type.defaultLibrary"] = { link = "@type.builtin" },
  ["@lsp.typemod.type.readonly"] = { link = "@lsp.type.type" },
  ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
  LspInlayHint = { link = "@comment.documentation" },
}

local lang_groups = {
  -- Lua
  -- ["@constructor.lua"] = "@structure.lua",
  -- ["@lsp.typemod.function.declaration.lua"] = "@lsp.type.function.lua",
  -- ["@lsp.typemod.function.global.lua"] = "@lsp.type.function.lua",
  -- ["@lsp.typemod.variable.defaultLibrary.lua"] = "@lsp.type.struct.lua",
  -- ["@lsp.typemod.variable.definition.lua"] = "@variable.builtin.lua",
  -- ["@module.builtin.lua"] = "@structure.lua",
  cStorageClass = { fg = palette.dragonYellow, italic = true },
}

local plugin_groups = {
  -- Gitsigns
  GitSignsAdd = { fg = theme.vcs.added, bg = theme.ui.bg_gutter },
  GitSignsChange = { fg = theme.vcs.changed, bg = theme.ui.bg_gutter },
  GitSignsDelete = { fg = theme.vcs.removed, bg = theme.ui.bg_gutter },
  -- TreeSitter Extensions
  TreesitterContext = { link = "Folded" },
  TreesitterContextLineNumber = {
    fg = theme.ui.special,
    bg = theme.ui.bg_gutter,
  },
  -- Telescope
  TelescopeBorder = { fg = theme.ui.float.fg_border, bg = theme.ui.bg },
  TelescopeTitle = { fg = theme.ui.special },
  TelescopeSelection = { link = "CursorLine" },
  TelescopeSelectionCaret = { link = "CursorLineNr" },
  TelescopeResultsClass = { link = "Structure" },
  TelescopeResultsStruct = { link = "Structure" },
  TelescopeResultsField = { link = "@field" },
  TelescopeResultsMethod = { link = "Function" },
  TelescopeResultsVariable = { link = "@variable" },

  -- Dap-UI
  -- DapUIVariable = { link = "Normal" },
  DapUIScope = { link = "Special" }, -- guifg=#00F1F5"
  DapUIType = { link = "Type" }, -- guifg=#D484FF"
  -- DapUIValue = { link = "Normal" },
  DapUIModifiedValue = { fg = theme.syn.special1, bold = true }, -- guifg=#00F1F5 gui=bold"
  DapUIDecoration = { fg = theme.ui.float.fg_border }, -- guifg=#00F1F5"
  DapUIThread = { fg = theme.syn.identifier }, --guifg=#A9FF68"
  DapUIStoppedThread = { fg = theme.syn.special1 }, --guifg=#00f1f5"
  -- DapUIFrameName = { link = "Normal"},
  DapUISource = { fg = theme.syn.special2 }, -- guifg=#D484FF"
  DapUILineNumber = { fg = theme.syn.special1 }, -- guifg=#00f1f5"
  DapUIFloatBorder = { fg = theme.ui.float.fg_border }, -- guifg=#00F1F5"
  DapUIWatchesEmpty = { fg = theme.diag.error }, -- guifg=#F70067"
  DapUIWatchesValue = { fg = theme.syn.identifier }, -- guifg=#A9FF68"
  DapUIWatchesError = { fg = theme.diag.error }, --guifg=#F70067"
  DapUIBreakpointsPath = { link = "Directory" }, --guifg=#00F1F5"
  DapUIBreakpointsInfo = { fg = theme.diag.info }, --guifg=#A9FF68"
  DapUIBreakpointsCurrentLine = { fg = theme.syn.identifier, bold = true }, --guifg=#A9FF68 gui=bold"
  -- DapUIBreakpointsLine = {}, -- DapUILineNumber"
  DapUIBreakpointsDisabledLine = { link = "Comment" }, --guifg=#424242"
  -- DapUICurrentFrameName = {}, -- DapUIBreakpointsCurrentLine"
  DapUIStepOver = { fg = theme.syn.special1 }, --guifg=#00f1f5"
  DapUIStepInto = { fg = theme.syn.special1 }, --guifg=#00f1f5"
  DapUIStepBack = { fg = theme.syn.special1 }, --guifg=#00f1f5"
  DapUIStepOut = { fg = theme.syn.special1 }, --guifg=#00f1f5"
  DapUIStop = { fg = theme.diag.error }, --guifg=#F70067"
  DapUIPlayPause = { fg = theme.syn.string }, --guifg=#A9FF68"
  DapUIRestart = { fg = theme.syn.string }, --guifg=#A9FF68"
  DapUIUnavailable = { fg = theme.syn.comment }, --guifg=#424242"
  -- Floaterm
  FloatermBorder = { fg = theme.ui.float.fg_border, bg = theme.ui.bg },
  -- NeoVim                         = {},
  healthError = { fg = theme.diag.error },
  healthSuccess = { fg = theme.diag.ok },
  healthWarning = { fg = theme.diag.warning },
  -- Cmp
  CmpDocumentation = { link = "NormalFloat" },
  CmpDocumentationBorder = { link = "FloatBorder" },
  CmpCompletion = { link = "Pmenu" },
  CmpCompletionSel = { fg = "NONE", bg = theme.ui.pmenu.bg_sel },
  CmpCompletionBorder = { fg = theme.ui.bg_search, bg = theme.ui.pmenu.bg },
  CmpCompletionThumb = { link = "PmenuThumb" },
  CmpCompletionSbar = { link = "PmenuSbar" },
  CmpItemAbbr = { fg = theme.ui.pmenu.fg },
  CmpItemAbbrDeprecated = {
    fg = theme.syn.comment_documentation,
    strikethrough = true,
  },
  CmpItemAbbrMatch = { fg = theme.syn.func_builtin },
  CmpItemAbbrMatchFuzzy = { link = "CmpItemAbbrMatch" },
  CmpItemKindDefault = { fg = theme.syn.annotation },
  CmpItemMenu = { fg = theme.syn.comment_documentation },
  CmpItemKindVariable = { fg = theme.ui.fg_dim },
  CmpItemKindFunction = { link = "Function" },
  CmpItemKindMethod = { link = "Function" },
  CmpItemKindConstructor = { link = "@constructor" },
  CmpItemKindClass = { link = "Type" },
  CmpItemKindInterface = { link = "Type" },
  CmpItemKindStruct = { link = "Type" },
  CmpItemKindProperty = { link = "@property" },
  CmpItemKindField = { link = "@field" },
  CmpItemKindEnum = { link = "Type" },
  CmpItemKindSnippet = { fg = theme.syn.statement },
  CmpItemKindText = { fg = theme.ui.pmenu.fg },
  CmpItemKindModule = { link = "@include" },
  CmpItemKindFile = { link = "Directory" },
  CmpItemKindFolder = { link = "Directory" },
  CmpItemKindKeyword = { link = "@keyword" },
  CmpItemKindTypeParameter = { link = "Type" },
  CmpItemKindConstant = { link = "Constant" },
  CmpItemKindOperator = { link = "Operator" },
  CmpItemKindReference = { link = "Type" },
  CmpItemKindEnumMember = { link = "Constant" },
  CmpItemKindValue = { link = "String" },
  CmpItemKindCopilot = { link = "String" },
  -- CmpItemKindUnit = {},
  -- CmpItemKindEvent = {},
  -- CmpItemKindColor = {},
  BlinkCmpItemIdx = { link = "Comment" },
  BlinkCmpSignatureHelpBorder = { link = "@keyword" },
  BlinkCmpMenuBorder = { link = "@keyword" },
  BlinkCmpDocBorder = { link = "@keyword" },

  -- IndentBlankline
  IndentBlanklineChar = { fg = theme.ui.whitespace },
  IndentBlanklineSpaceChar = { fg = theme.ui.whitespace },
  IndentBlanklineSpaceCharBlankline = { fg = theme.ui.whitespace },
  IndentBlanklineContextChar = { fg = theme.ui.special },
  IndentBlanklineContextStart = { sp = theme.ui.special, underline = true },
  IblIndent = { fg = theme.ui.whitespace },
  IblWhitespace = { fg = theme.ui.whitespace },
  IblScope = { fg = theme.ui.special },
  -- Lazy
  LazyProgressTodo = { fg = theme.ui.nontext },
  -- Illuminate
  IlluminatedWordWrite = { bg = theme.ui.bg_p2 },
  IlluminatedWordText = { link = "IlluminatedWordWrite" },
  IlluminatedWordRead = { link = "IlluminatedWordWrite" },
  -- Inline
  InclineNormal = { fg = theme.syn.constant_builtin },
  InclineNormalNC = { fg = theme.ui.special },
}

local groups = vim.tbl_extend(
  "force",
  editorgroups,
  syntaxgroups,
  treesittergroups,
  plugin_groups,
  lsp_groups,
  lang_groups
)

for group, opts in pairs(groups) do
  vim.api.nvim_set_hl(0, group, opts)
end
